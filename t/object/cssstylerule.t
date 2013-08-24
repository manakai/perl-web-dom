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

test {
  my $c = shift;
  my $css = from_style_el 'p {}';
  my $rule = $css->css_rules->[0];

  my $style = $rule->style;
  isa_ok $style, 'Web::DOM::CSSStyleDeclaration';
  is $style->parent_rule, $rule;

  is $rule->style, $style;

  undef $rule;
  undef $css;

  isa_ok $style->parent_rule, 'Web::DOM::CSSStyleRule';
  isa_ok $style->parent_rule->parent_style_sheet, 'Web::DOM::CSSStyleSheet';

  done $c;
} n => 5, name => 'style';

test {
  my $c = shift;
  my $css = from_style_el 'p >Q\s {}';
  my $rule = $css->css_rules->[0];

  $rule->style ('display: none ');
  is $rule->style->css_text, 'display: none;';

  done $c;
} n => 1, name => 'style setter';

test {
  my $c = shift;
  my $css = from_style_el 'p >Q\s {}';
  my $rule = $css->css_rules->[0];

  is $rule->selector_text, 'p > Qs';

  $rule->selector_text ('hoGe *.foo+bar');
  is $rule->selector_text, 'hoGe .foo + bar';

  $rule->selector_text ('aa|foo');
  is $rule->selector_text, 'hoGe .foo + bar';

  done $c;
} n => 3, name => 'selector_text';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
