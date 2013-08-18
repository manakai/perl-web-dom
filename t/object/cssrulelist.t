use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::Differences;
use Test::DOM::Exception;
use Test::DOM::CSS;

test {
  my $c = shift;
  my $css = from_style_el '';

  my $list = $css->css_rules;
  isa_ok $list, 'Web::DOM::CSSRuleList';
  is $list->length, 0;

  is $list->[0], undef;
  is scalar $list->[-1], undef;

  is $list->item (0), undef;
  is $list->item (-1), undef;

  eq_or_diff $list->to_a, [];
  eq_or_diff [$list->to_list], [];

  is scalar @$list, 0;
  eq_or_diff [@$list], [];

  done $c;
} n => 10, name => 'css_rules empty';

test {
  my $c = shift;
  my $css = from_style_el 'p{}@media{}';

  my $list = $css->css_rules;
  isa_ok $list, 'Web::DOM::CSSRuleList';
  is $list->length, 2;

  is $list->[0]->type, 1;
  is $list->[1]->type, 4;
  is $list->[2], undef;

  is $list->item (0), $list->[0];
  is $list->item (2**32), $list->[0];
  is $list->item (1.3), $list->[1];
  is $list->item (2), undef;

  eq_or_diff [$list->to_list], [$list->[0], $list->[1]];
  eq_or_diff $list->to_a, [$list->[0], $list->[1]];

  my $a = $list->to_a;
  push @$a, 'aa';
  eq_or_diff $a, [@$list, 'aa'];

  is scalar @$list, 2;
  eq_or_diff [@$list], [$list->[0], $list->[1]];

  dies_here_ok {
    $list->[3] = 'aa';
  };
  like $@, qr{^Modification of a read-only value attempted};

  done $c;
} n => 16, name => 'css_rules not empty';

# XXX css_rules mutation

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
