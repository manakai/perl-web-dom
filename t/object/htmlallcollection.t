use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->parent->parent->child ('t_deps/modules/*/lib')->stringify;
use lib glob path (__FILE__)->parent->parent->parent->child ('t_deps/lib')->stringify;
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
  my $node = $doc;
  my $called;
  $node->set_user_data (destroy => bless sub {
                         $called = 1;
                       }, 'test::DestroyCallback');

  my $nl = $doc->all;
  undef $doc;
  isa_ok $nl, 'Web::DOM::HTMLAllCollection';
  ok !$nl->isa ('Web::DOM::HTMLCollection');
  is scalar @$nl, 0;
  is $nl->length, 0;

  undef $node;
  ok not $called;

  undef $nl;
  ok $called;

  done $c;
} n => 6, name => 'children empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  $doc->append_child ($node);
  $node->append_child ($doc->create_element ('b'));
  $node->append_child ($doc->create_element ('b'));
  my $called;
  $node->set_user_data (destroy => bless sub {
                         $called = 1;
                       }, 'test::DestroyCallback');

  my $nl = $doc->all;
  undef $doc;
  isa_ok $nl, 'Web::DOM::HTMLAllCollection';
  ok !$nl->isa ('Web::DOM::HTMLCollection');
  is scalar @$nl, 3;
  is $nl->length, 3;

  undef $node;
  ok not $called;

  undef $nl;
  ok $called;

  done $c;
} n => 6, name => 'children not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element ('a');
  $doc->append_child ($node);

  my $nl = $doc->all;
  my $nl2 = $doc->all;
  
  is $nl2, $nl;

  my $doc2 = new Web::DOM::Document;
  my $node2 = $doc2->create_element ('b');
  $doc2->append_child ($node2);
  my $nl3 = $doc2->all;

  isnt $nl3, $nl;

  $node->append_child ($node2);

  is scalar @$nl, 2;
  is $nl->length, 2;
  
  done $c;
} n => 4, name => 'children liveness and sameness';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  my $node2 = $doc->create_text_node ('a');
  $doc->append_child ($node);

  my $nl = $doc->all;

  dies_here_ok {
    $nl->[0] = $node2;
  };
  ok not ref $@;
  like $@, qr{^Modification of a read-only value attempted};

  is scalar @$nl, 1;
  ok not $node->has_child_nodes;
  ok not $node2->parent_node;

  done $c;
} n => 6, name => 'children read-only';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  my $node2 = $doc->create_element ('a');
  my $node3 = $doc->create_element ('a');
  $node->append_child ($node3);
  $doc->append_child ($node);

  my $nl = $doc->all;

  dies_here_ok {
    $nl->[0] = $node2;
  };
  ok not ref $@;
  like $@, qr{^Modification of a read-only value attempted};
  is scalar @$nl, 2;
  is $nl->[0], $node;
  is $nl->[1], $node3;
  is $node3->parent_node, $node;
  ok not $node2->parent_node;

  $$node3->[100] = 13;
  is $$node3->[100], 13;

  done $c;
} n => 9, name => 'child_nodes read-only';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  $doc->append_child ($node);

  my $nl = $doc->all;
  my $nl_s = $nl . '';
  undef $nl;

  my $nl2 = $doc->all;
  my $nl2_s = $nl2 . '';
  
  ok $nl2_s eq $nl_s;
  ok not $nl2_s ne $nl_s;
  ok not $nl2 eq $nl_s;
  ok $nl2 ne $nl_s;
  ok not $nl2 eq undef;
  ok $nl2 ne undef;
  ok $nl2 eq $doc->all;
  ok not $nl2 ne $doc->all;
  is $nl2 cmp $doc->all, 0;
  isnt $nl2 cmp $doc->all, undef;

  my $doc2 = new Web::DOM::Document;
  my $nl3 = $doc2->all;
  ok $nl3 ne $nl2;
  ok not $nl3 eq $nl2;

  ok defined $nl2;
  ok not not $nl2;

  done $c;
} n => 14, name => 'children comparison';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $nl = $doc->all;

  is $nl->length, 0;
  is scalar @$nl, 0;

  is $nl->item (0), undef;
  is $nl->item (1), undef;
  is $nl->item (2), undef;
  is $nl->item (0+"inf"), undef;
  is $nl->item (0+"-inf"), undef;
  is $nl->item (0+"nan"), undef;
  is $nl->item (+0**1), undef;
  is $nl->item (0/"-inf"), undef;
  is $nl->item (-1), undef;
  is $nl->item (-3), undef;

  is $nl->[0], undef;
  is $nl->[1], undef;
  is $nl->[2], undef;
  is scalar $nl->[0+"inf"], undef;
  is scalar $nl->[0+"-inf"], undef;
  is scalar $nl->[0+"nan"], undef;
  is $nl->[+0**1], undef;
  is $nl->[0/"-inf"], undef;
  is scalar $nl->[-1], undef;
  is scalar $nl->[-3], undef;

  done $c;
} n => 22, name => 'children items, empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element ('a');
  my $nl = $doc->all;
  my $el = $doc->create_element ('b');
  $doc->append_child ($el);

  is $nl->length, 1;
  is scalar @$nl, 1;

  is $nl->item (0), $el;
  is $nl->item (1), undef;
  is $nl->item (2), undef;
  is $nl->item (0+"inf"), $el;
  is $nl->item (0+"-inf"), $el;
  is $nl->item (0+"nan"), $el;
  is $nl->item (+0**1), $el;
  if ((0/"-inf") eq '-0') {
    is $nl->item (0/"-inf"), $el;
  } else {
    is $nl->item (0/"-inf"), $el;
  }
  is $nl->item (0.52), $el;
  is $nl->item (-0.52), $el;
  is $nl->item (1.42), undef;
  is $nl->item (-1.323), undef;
  is $nl->item (-1), undef;
  is $nl->item (-3), undef;

  is $nl->[0], $el;
  is $nl->[1], undef;
  is $nl->[2], undef;
  is scalar $nl->[0+"inf"], $el;
  is scalar $nl->[0+"-inf"], [$el]->["-inf"];
  is scalar $nl->[0+"nan"], $el;
  is $nl->[+0**1], $el;
  is $nl->[0/"-inf"], $el;
  is $nl->[0.542], $el;
  is $nl->[1.444], undef;
  is scalar $nl->[-1], $el;
  is scalar $nl->[-3], undef;
  is scalar $nl->[-2**31], undef;
  ok exists $nl->[0];
  ok exists $nl->[0.55];
  ok exists $nl->[-1];
  ok not exists $nl->[-2];
  ok not exists $nl->[1];
  ok not exists $nl->[2**31];

  done $c;
} n => 35, name => 'children items, empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $nl = $doc->all;

  my $array1 = $nl->to_a;
  is ref $array1, 'ARRAY';
  is_deeply $array1, [];
  push @$array1, 1;
  is_deeply $array1, [1];

  $array1 = $nl->as_list;
  is ref $array1, 'ARRAY';
  is_deeply $array1, [];
  push @$array1, 1;
  is_deeply $array1, [1];

  isnt $nl->to_a, $nl->to_a;
  isnt $nl->as_list, $nl->as_list;
  isnt $nl->to_a, $nl->as_list;

  my @array2 = $nl->to_list;
  is 0+@array2, 0;
  push @array2, 1;
  is 0+@array2, 1;
  
  is 0+@$nl, 0;

  done $c;
} n => 12, name => 'children perl binding empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;
  my $nl = $doc->all;
  my $el1 = $doc->create_element ('f');
  my $el2 = $doc->create_element ('f');
  $doc->append_child ($el1);
  $doc->append_child ($el2);

  my $array1 = $nl->to_a;
  is ref $array1, 'ARRAY';
  is_deeply $array1, [$el1, $el2];
  push @$array1, 2;
  is_deeply $array1, [$el1, $el2, 2];

  $array1 = $nl->as_list;
  is ref $array1, 'ARRAY';
  is_deeply $array1, [$el1, $el2];
  push @$array1, 2;
  is_deeply $array1, [$el1, $el2, 2];

  isnt $nl->to_a, $nl->to_a;
  isnt $nl->as_list, $nl->as_list;
  isnt $nl->to_a, $nl->as_list;

  my @array2 = $nl->to_list;
  is 0+@array2, 2;
  push @array2, 3;
  is 0+@array2, 3;
  is $array2[0], $el1;
  is $array2[1], $el2;
  
  is 0+@$nl, 2;

  done $c;
} n => 14, name => 'children perl binding not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('aa');
  my $el2 = $doc->create_element ('aa');
  $el2->set_attribute (id => 'hoge');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  my $col = $doc->all;
  is $col->length, 2;
  is $col->{hoge}, $el2;
  is $col->{fuga}, undef;

  $el1->set_attribute (id => 'fuga');
  is $col->length, 2;
  is $col->{hoge}, $el2;
  is $col->{fuga}, $el1;

  $el2->id ('fuga');
  is $col->length, 2;
  is $col->{hoge}, undef;
  isa_ok $col->{fuga}, 'Web::DOM::HTMLAllCollection';
  is $col->{fuga}->length, 2;
  is $col->{fuga}->[0], $el1;
  is $col->{fuga}->[1], $el2;

  done $c;
} n => 12, name => 'mutation';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  $doc->append_child ($el1);
  $el1->name ('foo');

  my $all = $doc->all;
  is $all->length, 1;

  is $all->item (0), $el1;
  is $all->[0], $el1;
  is $all->named_item (0), undef;
  is $all->{0}, undef;
  is $all->{foo}, $el1;
  is $all->named_item ('foo'), $el1;
  is $all->item ('foo'), $el1;

  is $all->item (1), undef;
  is $all->[1], undef;
  is $all->{1}, undef;
  is $all->named_item (1), undef;

  done $c;
} n => 12, name => 'all items name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns (undef, 'a');
  $doc->append_child ($el1);
  $el1->id ('foo');

  my $all = $doc->all;
  is $all->length, 1;

  is $all->item (0), $el1;
  is $all->[0], $el1;
  is $all->named_item (0), undef;
  is $all->{0}, undef;
  is $all->{foo}, $el1;
  is $all->named_item ('foo'), $el1;
  is $all->item ('foo'), $el1;

  is $all->item (1), undef;
  is $all->[1], undef;
  is $all->{1}, undef;
  is $all->named_item (1), undef;

  done $c;
} n => 12, name => 'all items id';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('hoge');
  $doc->append_child ($el1);
  $el1->set_attribute (name => 'foo');

  my $all = $doc->all;
  is $all->length, 1;

  is $all->item (0), $el1;
  is $all->[0], $el1;
  is $all->named_item (0), undef;
  is $all->{0}, undef;
  is $all->{foo}, undef;
  is $all->named_item ('foo'), undef;
  is $all->item ('foo'), undef;
  ok not exists $all->{foo};
  ok not exists $all->{0};

  is $all->item (1), undef;
  is $all->[1], undef;
  is $all->{1}, undef;
  is $all->named_item (1), undef;

  done $c;
} n => 14, name => 'all items name not name element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns (undef, 'a');
  $doc->append_child ($el1);
  $el1->id ('4');

  my $all = $doc->all;
  is $all->length, 1;

  is $all->item (0), $el1;
  is $all->[0], $el1;
  is $all->named_item (0), undef;
  is $all->{0}, undef;
  is $all->{4}, $el1;
  is $all->named_item ('4'), $el1;
  is $all->item ('4'), undef;

  is $all->item (4), undef;
  is $all->[4], undef;
  is $all->{1}, undef;
  is $all->named_item (1), undef;

  done $c;
} n => 12, name => 'all items id number';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('hg');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('hg');
  $el2->id ('foo');
  my $el3 = $doc->create_element ('hg');
  $el3->id ('foo');
  $el1->append_child ($el2);
  $el1->append_child ($el3);

  my $all = $doc->all;
  is $all->length, 3;
  my $col = $all->{foo};
  is $all->named_item ('foo'), $col;
  is $all->item ('foo'), $col;
  isa_ok $col, 'Web::DOM::HTMLAllCollection';
  is $col->length, 2;
  is $col->[0], $el2;
  is $col->[1], $el3;
  
  my $col2 = $col->item ('foo');
  isa_ok $col2, 'Web::DOM::HTMLAllCollection';
  is $col2->length, 2;
  isnt $col2, $col;
  is $col2->[0], $el2;
  is $col2->[1], $el3;

  my $col3 = $col2->named_item ('foo');
  isa_ok $col2, 'Web::DOM::HTMLAllCollection';
  is $col2->length, 2;

  done $c;
} n => 14, name => 'all nameditem collection';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('foo');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('frame');
  $el2->id ('hoge');
  $el2->name ('hoge');
  $el1->append_child ($el2);

  my $all = $doc->all;
  is $all->length, 2;

  is $all->{hoge}, $el2;
  done $c;
} n => 2, name => 'all nameditem id/name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  my $el3 = $doc->create_element ('a');
  $doc->append_child ($el1);
  $el1->append_child ($el2);
  $el1->append_child ($el3);
  $el1->id ('aa');
  $el2->id ('aa');

  my $col = $doc->all->{aa};
  is $col->length, 2;

  $el3->id ('aa');
  is $col->length, 3;

  is $col->[0], $el1;
  is $col->[1], $el2;
  is $col->[2], $el3;
  
  $el1->id ('');
  is $col->length, 2;

  is $col->[0], $el2;
  is $col->[1], $el3;

  done $c;
} n => 8, name => 'all nameditem mutation';

for my $name (qw(
  a applet button embed form frame frameset iframe img input map meta
  object select textarea
)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ($name);
    $el->set_attribute (name => 'hoge');
    $doc->append_child ($el);
    is $doc->all->{hoge}, $el;
    done $c;
  } n => 1, name => ['all', $name, 'has name 1'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ($name);
    $el->set_attribute (name => 'hoge');
    my $el2 = $doc->create_element ($name);
    $el2->set_attribute (name => 'hoge');
    $doc->append_child ($el);
    $el->append_child ($el2);
    is $doc->all->{hoge}->length, 2;
    is $doc->all->{hoge}->[0], $el;
    is $doc->all->{hoge}->[1], $el2;
    done $c;
  } n => 3, name => ['all', $name, 'has name 2'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (undef, $name);
    $el->set_attribute (name => 'hoge');
    $doc->append_child ($el);
    is $doc->all->{hoge}, undef;
    done $c;
  } n => 1, name => ['all', $name, 'has name 1'];
}

for my $name (qw(
  p div option
)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ($name);
    $el->set_attribute (name => 'hoge');
    $doc->append_child ($el);
    is $doc->all->{hoge}, undef;
    done $c;
  } n => 1, name => ['all', $name, 'has name 1'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ($name);
    $el->set_attribute (name => 'hoge');
    my $el2 = $doc->create_element ($name);
    $el2->set_attribute (name => 'hoge');
    $doc->append_child ($el);
    $el->append_child ($el2);
    is $doc->all->{hoge}, undef;
    done $c;
  } n => 1, name => ['all', $name, 'has name 2'];
}

run_tests;

=head1 LICENSE

Copyright 2012-2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
