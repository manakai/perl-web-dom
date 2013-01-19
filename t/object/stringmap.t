use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

{
  package test::DestroyCallback;
  sub DESTROY {
    $_[0]->();
  }
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  my $ds = $el->dataset;
  $ds->{hoge} = 'foo';
  ok exists $ds->{hoge};
  is $ds->{hoge}, 'foo';
  is $el->get_attribute ('data-hoge'), 'foo';
  $ds->{hoge} = 'fuga';
  is $el->get_attribute ('data-hoge'), 'fuga';
  delete $ds->{hoge};
  ok not exists $ds->{hoge};
  is $ds->{hoge}, undef;
  ok not $el->has_attribute ('data-hoge');
  $ds->{124} = 'abc';
  is $el->get_attribute ('data-124'), 'abc';
  done $c;
} n => 8, name => 'basic';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('foo');
  my $ds = $el->dataset;
  $ds->{hoge_fuga_} = 124;
  ok exists $ds->{hoge_fuga_};
  is $ds->{hoge_fuga_}, 124;
  is $el->get_attribute_ns (undef, 'data-hoge-fuga-'), 124;
  delete $ds->{hoge_fuga_};
  is $el->get_attribute_ns (undef, 'data-hoge-fuga-'), undef;
  done $c;
} n => 4, name => 'underscore';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  my $ds = $el->dataset;
  is $ds->{'hoeg-fuga'}, undef;
  dies_here_ok {
    $ds->{'hoge-fuga'} = 124;
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'Key cannot contain the hyphen character';
  is $ds->{'hoge-fuga'}, undef;
  $el->set_attribute_ns (undef, 'data-hoge-fuga' => 52);
  is $ds->{'hoge-fuga'}, undef;
  delete $ds->{'hoge-fuga'};
  is $el->get_attribute_ns (undef, 'data-hoge-fuga'), 52;
  ok not exists $ds->{'hoge-fuga'};
  done $c;
} n => 9, name => 'hyphen';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('foo');
  my $ds = $el->dataset;
  $ds->{''} = 124;
  ok exists $ds->{''};
  is $ds->{''}, 124;
  is $el->get_attribute_ns (undef, 'data-'), 124;
  delete $ds->{''};
  is $el->get_attribute_ns (undef, 'data-'), undef;
  done $c;
} n => 4, name => 'empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  $el->set_attribute_ns (undef, 'data-hoge' => 12);
  $el->set_attribute_ns (undef, 'data-' => 5);
  $el->set_attribute_ns ('http://foo/', 'data-hoge2' => 6);
  $el->set_attribute_ns (undef, 'data-hoge-Fuga' => 64);
  $el->set_attribute_ns (undef, 'data-hoge_fuga' => 64);
  my $ds = $el->dataset;
  %$ds = ();
  is $el->attributes->length, 1;
  is $el->get_attribute_ns ('http://foo/', 'data-hoge2'), 6;
  ok not keys %$ds;
  done $c;
} n => 3, name => 'clear';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  $el->set_attribute_ns (undef, 'data-hoge' => 12);
  $el->set_attribute_ns (undef, 'data-' => 5);
  $el->set_attribute_ns ('http://foo/', 'data-hoge2' => 6);
  $el->set_attribute_ns (undef, 'data-hoge-Fuga' => 64);
  $el->set_attribute_ns (undef, 'data-hoge_fuga' => 64);
  my $ds = $el->dataset;
  is_deeply {map { $_ => 1 } keys %$ds}, {hoge => 1, '' => 1, hoge_Fuga => 1};
  is_deeply {map { $_ => 1 } keys %$ds}, {hoge => 1, '' => 1, hoge_Fuga => 1};
  $ds->{ab_} = 124;
  is_deeply {map { $_ => 1 } keys %$ds},
      {hoge => 1, '' => 1, hoge_Fuga => 1, ab_ => 1};
  $el->set_attribute_ns (undef, 'data-aaa' => 44);
  is_deeply {map { $_ => 1 } keys %$ds},
      {hoge => 1, '' => 1, hoge_Fuga => 1, ab_ => 1, aaa => 1};
  ok scalar keys %$ds;
  done $c;
} n => 5, name => 'keys';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hh');
  
  my $called;
  $el->set_user_data (destroy => bless sub {
                        $called = 1;
                      }, 'test::DestroyCallback');
  my $ds = $el->dataset;

  $ds->{abc} = 124;
  $ds->{124} = 4231;
  delete $ds->{abc};

  undef $el;

  ok not $called;

  undef $ds;
  
  ok $called;
  done $c;
} n => 2, name => 'destroy';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  my $ds1 = $el->dataset;
  my $ds2 = $el->dataset;

  ok $ds1 eq $ds2;
  ok $ds2 eq $ds1;
  ok not $ds1 ne $ds2;
  ok not $ds2 ne $ds1;
  ok not $ds1 eq undef;
  ok not undef eq $ds1;
  ok $ds1 ne undef;
  ok undef ne $ds1;
  is $ds1 cmp $ds2, 0;
  
  my $el2 = $doc->create_element ('aa');
  my $ds3 = $el2->dataset;

  ok not $ds1 eq $ds3;
  ok $ds1 ne $ds3;
  isnt $ds1 cmp $ds3, 0;

  my $s_ds3 = ''.$ds3;
  undef $ds3;

  my $ds4 = $el2->dataset;

  is $ds4.'', $s_ds3;

  done $c;
} n => 13, name => 'comparison';

run_tests;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
