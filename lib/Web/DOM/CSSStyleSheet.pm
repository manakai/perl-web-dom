package Web::DOM::CSSStyleSheet;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::StyleSheet;
push our @ISA, qw(Web::DOM::StyleSheet);
use Web::DOM::CSSRule;

sub owner_rule ($) {
  return ${$_[0]}->[0]->rule (${$_[0]}->[2]->{owner_rule}); # or undef
} # owner_rule

# XXX css_rules

# XXX insert_rule

# XXX delete_rule

# XXX css_text

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
