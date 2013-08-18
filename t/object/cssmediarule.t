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
  my $css = from_style_el '@media {}';
  my $rule = $css->css_rules->[0];
  is $rule->type, 4;
  is $rule->parent_rule, undef;
  is $rule->parent_style_sheet, $css;
  done $c;
} n => 3, name => 'basic';

test {
  my $c = shift;
  my $css = from_style_el '@media {}';
  my $rule = $css->css_rules->[0];

  my $list = $rule->css_rules;
  isa_ok $list, 'Web::DOM::CSSRuleList';
  is $list->length, 0;

  is $rule->css_rules, $list;

  done $c;
} n => 3, name => 'css_rules empty';

test {
  my $c = shift;
  my $css = from_style_el '@media {p{} Q{}}';
  my $rule = $css->css_rules->[0];

  my $list = $rule->css_rules;
  isa_ok $list, 'Web::DOM::CSSRuleList';
  is $list->length, 2;
  is $list->[0]->selector_text, 'p';
  is $list->[1]->selector_text, 'Q';

  is $list->[0]->parent_rule, $rule;
  is $list->[1]->parent_rule, $rule;
  is $list->[0]->parent_style_sheet, $css;
  is $list->[1]->parent_style_sheet, $css;

  done $c;
} n => 8, name => 'css_rules not empty';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
