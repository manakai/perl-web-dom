use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::CSS;

test {
  my $c = shift;
  my $css = from_style_el 'p{}';
  my $rule = $css->css_rules->[0];
  isa_ok $rule, 'Web::DOM::CSSStyleRule';
  is $rule->type, 1;
  is $rule->parent_rule, undef;
  is $rule->parent_style_sheet, $css;
  done $c;
} n => 4, name => 'type, parent';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
