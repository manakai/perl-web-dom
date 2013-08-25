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
  my $css = from_style_el '@charset "uTf-8";';
  my $rule = $css->css_rules->[0];
  is $rule->type, 2;
  is $rule->parent_rule, undef;
  is $rule->parent_style_sheet, $css;
  is $rule->encoding, 'uTf-8';
  $rule->encoding ('abc');
  is $rule->encoding, 'abc';
  done $c;
} n => 5, name => 'basic';

test {
  my $c = shift;
  my $css = from_style_el '@charset "utF-8";';
  my $rule = $css->css_rules->[0];
  
  is $rule->css_text, '@charset "utF-8";';

  done $c;
} n => 1, name => 'css_text getter';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
