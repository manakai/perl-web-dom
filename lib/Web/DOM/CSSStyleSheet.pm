package Web::DOM::CSSStyleSheet;
use strict;
use warnings;
our $VERSION = '3.0';
use Carp;
use Web::DOM::StyleSheet;
push our @ISA, qw(Web::DOM::StyleSheet);
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

# XXXtest
sub owner_rule ($) {
  my $id = ${$_[0]}->[2]->{owner};
  return defined $id && defined ${$_[0]}->{data}->[$id]->{rule_type}
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

# XXX insert_rule

# XXX delete_rule

# XXX css_text

# XXXtest
sub manakai_is_default_namespace ($$) {
  my $uri = ''.$_[1];
  for my $rule (@{$_[0]->css_rules}) {
    next unless $rule->type == NAMESPACE_RULE;
    if ($rule->prefix eq '') {
      return $uri eq $rule->namespace_uri;
    }
  }
  return 0;
} # manakai_is_default_namespace

# XXXtest
sub manakai_lookup_namespace_prefix ($$) {
  return undef unless defined $_[1];
  my $uri = ''.$_[1];
  return undef if $uri eq '';
  for my $rule (@{$_[0]->css_rules}) {
    next unless $rule->type == NAMESPACE_RULE;
    if ($uri eq $rule->namespace_uri) {
      my $prefix = $rule->prefix;
      return $prefix if $prefix ne '';
    }
  }
  return undef;
} # manakai_lookup_namespace_prefix

# XXXtest
sub manakai_lookup_namespace_uri ($$) {
  my $prefix = defined $_[1] ? ''.$_[1] : '';
  for my $rule (@{$_[0]->css_rules}) {
    next unless $rule->type == NAMESPACE_RULE;
    if ($prefix eq $rule->prefix) {
      my $uri = $rule->namespace_uri;
      return $uri;
    }
  }
  return undef;
} # manakai_lookup_namespace_uri

1;

=head1 LICENSE

Copyright 2007-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
