use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::CSS;
use Web::DOM::CSSRule;

test {
  my $c = shift;
  is UNKNOWN_RULE, 0;
  ok STYLE_RULE;
  ok IMPORT_RULE;
  ok MEDIA_RULE;
  ok FONT_FACE_RULE;
  ok PAGE_RULE;
  ok NAMESPACE_RULE;
  done $c;
} n => 7, name => 'constants class';

test {
  my $c = shift;
  is +Web::DOM::CSSRule->UNKNOWN_RULE, 0;
  ok +Web::DOM::CSSRule->STYLE_RULE;
  ok +Web::DOM::CSSRule->IMPORT_RULE;
  ok +Web::DOM::CSSRule->MEDIA_RULE;
  ok +Web::DOM::CSSRule->FONT_FACE_RULE;
  ok +Web::DOM::CSSRule->PAGE_RULE;
  ok +Web::DOM::CSSRule->NAMESPACE_RULE;
  done $c;
} n => 7, name => 'constants class';

test {
  my $c = shift;
  my $css = from_style_el 'p{}';
  my $rule = $css->css_rules->[0];
  is $rule->UNKNOWN_RULE, 0;
  ok $rule->STYLE_RULE;
  ok $rule->IMPORT_RULE;
  ok $rule->MEDIA_RULE;
  ok $rule->FONT_FACE_RULE;
  ok $rule->PAGE_RULE;
  ok $rule->NAMESPACE_RULE;
  done $c;
} n => 7, name => 'constants instance';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
