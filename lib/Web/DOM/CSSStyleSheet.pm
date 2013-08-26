package Web::DOM::CSSStyleSheet;
use strict;
use warnings;
our $VERSION = '5.0';
use Carp;
use Web::DOM::StyleSheet;
push our @ISA, qw(Web::DOM::StyleSheet);
push our @CARP_NOT, qw(Web::DOM::Exception);
use Web::DOM::Exception;
use Web::DOM::CSSRule;

use overload
    '""' => sub {
      return ref ($_[0]) . '=DOM(' . ${$_[0]}->[2] . ')';
    },
    bool => sub { 1 },
    cmp => sub {
      carp "Use of uninitialized value in string comparison (cmp)"
          unless defined $_[1];
      overload::StrVal ($_[0]) cmp overload::StrVal ($_[1])
    },
    fallback => 1;

sub type ($) {
  return 'text/css';
} # type

sub owner_rule ($) {
  my $id = ${$_[0]}->[2]->{owner};
  return defined $id && defined ${$_[0]}->[0]->{data}->[$id]->{rule_type}
      ? ${$_[0]}->[0]->node ($id) : undef;
} # owner_rule

sub css_rules ($) {
  my $self = $_[0];

  # XXX origin check

  return $$self->[0]->collection ('css_rules', $self, sub {
    my $node = $_[0];
    return @{$$node->[2]->{rule_ids} or []};
  });
} # css_rules

## This method is also used by |Web::DOM::CSSGroupingRule|.
sub insert_rule ($$$) {
  my $self = $_[0];
  my $rule = ''.$_[1];
  # WebIDL: unsigned long
  my $index = $_[2] % 2**32;

  ## 1.
  my $self_rule_type = ${$_[0]}->[2]->{rule_type};
  if ($self_rule_type eq 'sheet') {
    # XXX origin
  }

  ## 2. Insert a CSS rule
  {
    ## 1.
    my $parser = ${$_[0]}->[0]->css_parser;
    $parser->init_parser;
    if (${$_[0]}->[2]->{rule_type} eq 'sheet') {
      $parser->context (${$_[0]}->[2]->{context});
    } else {
      my $parent = $_[0]->parent_style_sheet;
      $parser->context ($parent ? $$parent->[2]->{context} : undef);
    }
    my $parsed = $parser->parse_char_string_as_rule ($rule);

    ## 2.
    unless (defined $parsed->{rules}->[1]) {
      _throw Web::DOM::Exception 'SyntaxError',
          'The specified rule is invalid';
    }

    ## 3.
    my $new_type = $parsed->{rules}->[1]->{rule_type};
    if ($new_type eq 'charset') {
      _throw Web::DOM::Exception 'SyntaxError',
          '@charset is not allowed';
    }

    ## 4.-5.
    if ($index > scalar @{${$_[0]}->[2]->{rule_ids} or []}) {
      _throw Web::DOM::Exception 'IndexSizeError',
          'The specified rule index is invalid';
    }

    ## 6.
    if ($new_type eq 'import') {
      if ($self_rule_type ne 'sheet') {
        _throw Web::DOM::Exception 'HierarchyRequestError',
            'The specified rule cannot be inserted in this rule';
      }
      if ($index > 0 and
          ${$_[0]}->[0]->{data}->[${$_[0]}->[2]->{rule_ids}->[$index-1]]->{rule_type} ne 'charset' and
          ${$_[0]}->[0]->{data}->[${$_[0]}->[2]->{rule_ids}->[$index-1]]->{rule_type} ne 'import') {
        _throw Web::DOM::Exception 'HierarchyRequestError',
            'The specified rule cannot be inserted at the specified index';
      }
      if (defined ${$_[0]}->[2]->{rule_ids}->[$index] and
          ${$_[0]}->[0]->{data}->[${$_[0]}->[2]->{rule_ids}->[$index]]->{rule_type} eq 'charset') {
        _throw Web::DOM::Exception 'HierarchyRequestError',
            'The specified rule cannot be inserted at the specified index';
      }
    } elsif ($new_type eq 'namespace') {
      if ($self_rule_type ne 'sheet') {
        _throw Web::DOM::Exception 'HierarchyRequestError',
            'The specified rule cannot be inserted in this rule';
      }
      if ($index > 0 and
          ${$_[0]}->[0]->{data}->[${$_[0]}->[2]->{rule_ids}->[$index-1]]->{rule_type} ne 'charset' and
          ${$_[0]}->[0]->{data}->[${$_[0]}->[2]->{rule_ids}->[$index-1]]->{rule_type} ne 'import' and
          ${$_[0]}->[0]->{data}->[${$_[0]}->[2]->{rule_ids}->[$index-1]]->{rule_type} ne 'namespace') {
        _throw Web::DOM::Exception 'HierarchyRequestError',
            'The specified rule cannot be inserted at the specified index';
      }
      if (defined ${$_[0]}->[2]->{rule_ids}->[$index] and
          (${$_[0]}->[0]->{data}->[${$_[0]}->[2]->{rule_ids}->[$index]]->{rule_type} eq 'charset' or
           ${$_[0]}->[0]->{data}->[${$_[0]}->[2]->{rule_ids}->[$index]]->{rule_type} eq 'import')) {
        _throw Web::DOM::Exception 'HierarchyRequestError',
            'The specified rule cannot be inserted at the specified index';
      }

      ## 7.
      if (grep { $_ ne 'charset' and $_ ne 'import' and $_ ne 'namespace' }
          map { ${$_[0]}->[0]->{data}->[$_]->{rule_type} }
          @{${$_[0]}->[2]->{rule_ids} or []}) {
        _throw Web::DOM::Exception 'InvalidStateError',
            '@namespace cannot be inserted to this style sheet';
      }
    }
    
    ## 8.
    my $new_id = ${$_[0]}->[0]->import_parsed_ss ($parsed, ${$_[0]}->[1]);
    splice @{${$_[0]}->[2]->{rule_ids} or []}, $index, 0, ($new_id);
    ## New rule's |owner_sheet| is set by |import_parsed_ss|.
    ${$_[0]}->[0]->{data}->[$new_id]->{parent_id} = ${$_[0]}->[1];
    ${$_[0]}->[0]->children_changed (${$_[0]}->[1], 0);

    if ($new_type eq 'namespace') {
      $_[0]->_rebuild_nsmap; # $_[0] is always style sheet
    }

    # XXX notification

    ## 9.
    return $index;
  }
} # insert_rule

## This method is also used by |Web::DOM::CSSGroupingRule|.
sub delete_rule ($$) {
  # WebIDL: unsigned long
  my $index = $_[1] % 2**32;
  
  ## 1.
  if (${$_[0]}->[2]->{rule_type} eq 'sheet') {
    # XXX origin
  }

  ## 2. Remove a CSS rule
  {
    ## 1.-2.
    if ($index >= scalar @{${$_[0]}->[2]->{rule_ids} or []}) {
      _throw Web::DOM::Exception 'IndexSizeError',
          'The specified rule index is invalid';
    }

    ## 3.
    my $old_rule_id = ${$_[0]}->[2]->{rule_ids}->[$index];
    my $old_rule = ${$_[0]}->[0]->node ($old_rule_id);

    ## 4.
    if ($$old_rule->[2]->{rule_type} eq 'namespace') {
      for (map { ${$_[0]}->[0]->{data}->[$_] } @{${$_[0]}->[2]->{rule_ids}}) {
        my $type = $_->{rule_type};
        if ($type eq 'charset' or $type eq 'import' or $type eq 'namespace') {
          #
        } else {
          _throw Web::DOM::Exception 'InvalidStateError',
              'Namespace rule cannot be deleted if there are following rules';
        }
      }
    }

    ## 5.
    splice @{${$_[0]}->[2]->{rule_ids}}, $index, 1, ();

    ## 6.
    delete $$old_rule->[2]->{parent_id}; # parent CSS rule
    $$old_rule->[0]->disconnect ($old_rule_id); # parent CSS style sheet
    my $new_int = ref ($$old_rule->[0])->new;
    $new_int->adopt ($old_rule);
    ${$_[0]}->[0]->children_changed (${$_[0]}->[1], 0);

    if ($$old_rule->[2]->{rule_type} eq 'namespace') {
      $_[0]->_rebuild_nsmap; # $_[0] is always style sheet
    }

    # XXX notification

    ## $old_rule->DESTROY is implicitly invoked such that that node
    ## data might be discarded.
  }
  return undef;
} # delete_rule

sub css_text ($) {
  # XXX setter (not specced yet)

  my $serializer = ${$_[0]}->[0]->css_serializer;
  return $serializer->serialize_rule ({rules => ${$_[0]}->[0]->{data}}, ${$_[0]}->[1]);
} # css_text

sub _rebuild_nsmap ($) {
  my $self = $_[0];
  my $context = $$self->[2]->{context};
  $context->{prefix_to_url} = {};
  $context->{url_to_prefixes} = {};

  for my $rule (@{$self->css_rules}) {
    next unless $rule->type == NAMESPACE_RULE;
    my $prefix = $rule->prefix;
    my $nsurl = $rule->namespace_uri;
    if (length $prefix and defined $context->{prefix_to_url}->{$prefix}) {
      @{$context->{url_to_prefixes}->{$context->{prefix_to_url}->{$prefix}}}
          = grep { $_ ne $prefix } @{$context->{url_to_prefixes}->{$context->{prefix_to_url}->{$prefix}}};
    }
    $context->{prefix_to_url}->{$prefix} = $nsurl;
    push @{$context->{url_to_prefixes}->{$nsurl} ||= []},
        $prefix if length $prefix;
  }
} # _rebuild_nsmap

sub manakai_is_default_namespace ($$) {
  my $uri = defined $_[1] ? ''.$_[1] : '';
  my $url = ${$_[0]}->[2]->{context}->get_url_by_prefix ('');
  return defined $url && $url eq $uri;
} # manakai_is_default_namespace

sub manakai_lookup_namespace_prefix ($$) {
  my $uri = defined $_[1] ? ''.$_[1] : '';
  return ${$_[0]}->[2]->{context}->get_prefix_by_url ($uri);
} # manakai_lookup_namespace_prefix

sub manakai_lookup_namespace_uri ($$) {
  my $prefix = defined $_[1] ? ''.$_[1] : '';
  return ${$_[0]}->[2]->{context}->get_url_by_prefix ($prefix);
} # manakai_lookup_namespace_uri

1;

=head1 LICENSE

Copyright 2007-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
