use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::Differences;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $int = $$doc->[0];

  $int->import_parsed_ss ({rules => [
    {id => 0, rule_type => 'sheet', rule_ids => []},
  ]});

  my $sheet = $int->node (1);
  isa_ok $sheet, 'Web::DOM::CSSStyleSheet';

  is $$sheet->[0], $int;
  is $$sheet->[1], 1;
  is $$sheet->[2], $int->{data}->[1];
  is $int->{tree_id}->[1], 1;
  is $int->{rc}->[1], 0;

  undef $sheet;

  is $int->{data}->[1], undef;
  
  done $c;
} n => 7, name => ['style sheet only'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $int = $$doc->[0];

  $int->import_parsed_ss ({rules => [
    {id => 0, rule_type => 'sheet', rule_ids => [1]},
    {id => 1, rule_type => 'style', parent_id => 0},
  ]});

  my $sheet = $int->node (1);
  isa_ok $sheet, 'Web::DOM::CSSStyleSheet';

  is $$sheet->[0], $int;
  is $$sheet->[1], 1;
  is $$sheet->[2], $int->{data}->[1];
  is $int->{tree_id}->[1], 1;
  is $int->{rc}->[1], 1;
  eq_or_diff $$sheet->[2]->{rule_ids}, [2];
  is $$sheet->[2]->{owner_sheet}, undef;

  my $rule = $int->node (2);
  isa_ok $rule, 'Web::DOM::CSSStyleRule';

  is $$rule->[0], $int;
  is $$rule->[1], 2;
  is $$rule->[2], $int->{data}->[2];
  is $int->{tree_id}->[2], 1;
  is $$rule->[2]->{parent_id}, 1;
  is $$rule->[2]->{owner_sheet}, 1;

  undef $sheet;

  is $int->{data}->[1]->{rule_type}, 'sheet';
  is $int->{data}->[2]->{rule_type}, 'style';

  undef $rule;

  is $int->{data}->[1], undef;
  is $int->{data}->[2], undef;
  
  done $c;
} n => 19, name => ['style sheet with a rule'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $int = $$doc->[0];

  $int->import_parsed_ss ({rules => [
    {id => 0, rule_type => 'sheet', rule_ids => [1]},
    {id => 1, rule_type => 'media', rule_ids => [2], parent_id => 0},
    {id => 2, rule_type => 'style', parent_id => 1},
  ]});

  $int->disconnect (2);

  is $int->{tree_id}->[1], 1;
  is $int->{tree_id}->[2], 2;
  is $int->{tree_id}->[3], 2;

  is $int->{rc}->[1], 0;

  done $c;
} n => 4, name => 'disconnect rule_ids';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $int = $$doc->[0];

  $int->import_parsed_ss ({rules => [
    {id => 0, rule_type => 'sheet', rule_ids => [1]},
    {id => 1, rule_type => 'media', rule_ids => [2], parent_id => 0},
    {id => 2, rule_type => 'style', parent_id => 1},
  ]});

  $int->connect (1 => 0);

  is $int->{tree_id}->[0], 0;
  is $int->{tree_id}->[1], 0;
  is $int->{tree_id}->[2], 0;

  done $c;
} n => 3, name => 'connect';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $int = $$doc->[0];

  $int->import_parsed_ss ({rules => [
    {id => 0, rule_type => 'sheet', rule_ids => [1]},
    {id => 1, rule_type => 'media', rule_ids => [2], parent_id => 0},
    {id => 2, rule_type => 'style', parent_id => 1},
  ]});

  $int->node (2); # ->gc

  is $int->{rc}->[1], 1;

  $int->node (3); # ->gc

  is $int->{rc}->[1], undef;
  is $int->{data}->[1], undef;

  done $c;
} n => 3, name => 'gc';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
