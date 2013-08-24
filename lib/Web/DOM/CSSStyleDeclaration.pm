package Web::DOM::CSSStyleDeclaration;
use strict;
use warnings;
our $VERSION = '4.0';
use Carp;
use Web::CSS::Props;

use overload
    '@{}' => sub {
      my $list = [];
      if (${$_[0]}->[0] eq 'rule') {
        $list = [map { $Web::CSS::Props::Key->{$_}->{css} } @{${${$_[0]}->[1]}->[2]->{prop_keys}}];
      }
      Internals::SvREADONLY (@$list, 1);
      Internals::SvREADONLY ($_, 1) for @$list;
      return $list;
    },
    '""' => sub {
      return ref ($_[0]) . '=DOM(' . ${$_[0]}->[1] . ')';
    },
    bool => sub { 1 },
    cmp => sub {
      carp "Use of uninitialized value in string comparison (cmp)"
          unless defined $_[1];
      overload::StrVal ($_[0]) cmp overload::StrVal ($_[1])
    },
    fallback => 1;

sub length ($) {
  if (${$_[0]}->[0] eq 'rule') {
    return scalar @{${${$_[0]}->[1]}->[2]->{prop_keys}};
  } else {
    return 0;
  }
} # length

sub item ($$) {
  # WebIDL: unsigned long
  my $n = $_[1] % 2**32;
  return '' if $n >= 2**31;
  if (${$_[0]}->[0] eq 'rule') {
    my $key = ${${$_[0]}->[1]}->[2]->{prop_keys}->[$n];
    if (defined $key) {
      return $Web::CSS::Props::Key->{$key}->{css};
    } else {
      return '';
    }
  } else {
    return '';
  }
} # item

sub get_property_value ($$) {
  my $prop_name = ''.$_[1];

  ## 1.
  $prop_name =~ tr/A-Z/a-z/; ## ASCII case-insensitive.

  ## 2.-4.
  require Web::CSS::Serializer;
  my $se = Web::CSS::Serializer->new;
  my $str = $se->serialize_prop_value (${${$_[0]}->[1]}->[2], $prop_name);
  return defined $str ? $str : '';
} # get_property_value

sub get_property_priority ($$) {
  my $prop_name = ''.$_[1];

  ## 1.
  $prop_name =~ tr/A-Z/a-z/; ## ASCII case-insensitive.

  ## 2.-4.
  require Web::CSS::Serializer;
  my $se = Web::CSS::Serializer->new;
  my $str = $se->serialize_prop_priority (${${$_[0]}->[1]}->[2], $prop_name);
  return defined $str ? $str : '';
} # get_property_priority

sub set_property ($$;$$) {
  my $self = $_[0];
  my $prop_name = ''.$_[1];
  my $value = defined $_[2] ? ''.$_[2] : '';
  my $priority = defined $_[3] ? ''.$_[3] : '';

  ## 1.
  # XXX If readonly, NoModificationAllowedError

  ## 2.
  $prop_name =~ tr/A-Z/a-z/; ## ASCII case-insensitive.

  ## 3.
  my $def = $Web::CSS::Props::Prop->{$prop_name} or return;
  
  ## 4.
  if ($value eq '') {
    $self->remove_property ($prop_name);
    return;
  }

  ## 5.
  $priority =~ tr/A-Z/a-z/; ## ASCII case-insensitive
  unless ($priority eq '' or $priority eq 'important') {
    return;
  }

  ## 6.-8. & Set a CSS property
  my $parser = Web::CSS::Parser->new; # XXX reuse / context
  my $parsed = $parser->parse_char_string_as_prop_value ($prop_name, $value);
  if (defined $parsed) {
    if (${$_[0]}->[0] eq 'rule') {
      my $decl = ${${$_[0]}->[1]}->[2];
      for my $key (@{$parsed->{prop_keys}}) {
        push @{$decl->{prop_keys}}, $key;
        $decl->{prop_values}->{$key} = $parsed->{prop_values}->{$key};
        if ($priority eq 'important') {
          $decl->{prop_importants}->{$key} = 1;
        } else {
          delete $decl->{prop_importants}->{$key};
        }
      }
      my $fnd = {};
      @{$decl->{prop_keys}} = grep { not $fnd->{$_}++ } @{$decl->{prop_keys}};
    }
  }

  return;
} # set_property

sub remove_property ($$) {
  my $self = $_[0];
  my $prop_name = ''.$_[1];

  ## 1.
  # XXX read-only

  ## 2.
  $prop_name =~ tr/A-Z/a-z/; ## ASCII case-insensitive.

  ## 3.
  my $value = $self->get_property_value ($prop_name);

  ## 4.-5.
  my $def = $Web::CSS::Props::Prop->{$prop_name} or return $value;
  if (${$_[0]}->[0] eq 'rule') {
    my $data = ${${$_[0]}->[1]}->[2];
    my %removed = $def->{longhand_subprops}
        ? map { $_ => 1 } @{$def->{longhand_subprops}}
        : ($def->{key} => 1);
    @{$data->{prop_keys}} = grep { not $removed{$_} } @{$data->{prop_keys}};
    for my $key (keys %removed) {
      delete $data->{prop_values}->{$key};
      delete $data->{prop_importants}->{$key};
    }
  }
  
  ## 6.
  return $value;
} # remove_property

for my $name (keys %$Web::CSS::Props::Attr) {
  my $def = $Web::CSS::Props::Attr->{$name};
  my $css_name = $def->{css};
  no strict 'refs';
  *$name = sub ($;$) {
    if (@_ > 1) {
      $_[0]->set_property ($css_name => $_[1]);
    }
    return unless defined wantarray;
    return $_[0]->get_property_value ($css_name);
  };
}

sub parent_rule ($) {
  if (${$_[0]}->[0] eq 'rule') {
    return ${$_[0]}->[1];
  } else {
    return undef;
  }
} # parent_rule

sub css_text ($;$) {
  my $data;
  if (${$_[0]}->[0] eq 'rule') {
    $data = ${${$_[0]}->[1]}->[2];
  }
  if (@_ > 1) {
    ## 1.
    # XXX read-only

    ## 2.-3.
    require Web::CSS::Parser;
    my $parser = Web::CSS::Parser->new; # XXX reuse / context
    my $parsed = $parser->parse_char_string_as_prop_decls (''.$_[1]);
    $data->{prop_keys} = $parsed->{prop_keys};
    $data->{prop_values} = $parsed->{prop_values};
    $data->{prop_importants} = $parsed->{prop_importants};
  }
  return unless defined wantarray;

  require Web::CSS::Serializer;
  my $se = Web::CSS::Serializer->new;
  return $se->serialize_prop_decls ($data);
} # css_text

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
