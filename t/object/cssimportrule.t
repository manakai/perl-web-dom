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
  my $css = from_style_el '@import "hoGe.css";';
  my $rule = $css->css_rules->[0];
  is $rule->type, 3;
  is $rule->parent_rule, undef;
  is $rule->parent_style_sheet, $css;
  is $rule->href, 'hoGe.css';
  done $c;
} n => 4, name => 'basic';

test {
  my $c = shift;
  my $css = from_style_el '@import "a" screen  , print  ;';
  my $rule = $css->css_rules->[0];

  my $media = $rule->media;
  is $media->media_text, 'screen, print';
  is $media->[0], 'screen';
  is $media->[1], 'print';

  $rule->media ('abc, speech');
  is $media->media_text, 'abc, speech';

  done $c;
} n => 4, name => 'media';

test {
  my $c = shift;
  my $css = from_style_el '@import "a" screen  , print  ;';
  my $rule = $css->css_rules->[0];

  my $media = $rule->media;
  undef $css;
  undef $rule;

  is $media->media_text, 'screen, print';

  done $c;
} n => 1, name => 'media ref';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
