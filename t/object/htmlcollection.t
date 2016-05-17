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
  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $called;
  $node->set_user_data (destroy => bless sub {
                         $called = 1;
                       }, 'test::DestroyCallback');

  my $nl = $node->children;
  isa_ok $nl, 'Web::DOM::HTMLCollection';
  is scalar @$nl, 0;
  is $nl->length, 0;

  undef $node;
  ok not $called;

  undef $nl;
  ok $called;

  done $c;
} n => 5, name => 'children empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  $node->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b'));
  $node->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b'));
  my $called;
  $node->set_user_data (destroy => bless sub {
                         $called = 1;
                       }, 'test::DestroyCallback');

  my $nl = $node->children;
  isa_ok $nl, 'Web::DOM::HTMLCollection';
  is scalar @$nl, 2;
  is $nl->length, 2;

  undef $node;
  ok not $called;

  undef $nl;
  ok $called;

  done $c;
} n => 5, name => 'children not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');

  my $nl = $node->children;
  my $nl2 = $node->children;
  
  is $nl2, $nl;

  my $node2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b');
  my $nl3 = $node2->children;

  isnt $nl3, $nl;

  $node->append_child ($node2);

  is scalar @$nl, 1;
  is $nl->length, 1;
  
  done $c;
} n => 4, name => 'children liveness and sameness';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $node2 = $doc->create_text_node ('a');

  my $nl = $node->children;

  dies_here_ok {
    $nl->[0] = $node2;
  };
  ok not ref $@;
  like $@, qr{^Modification of a read-only value attempted};

  is scalar @$nl, 0;
  ok not $node->has_child_nodes;
  ok not $node2->parent_node;

  done $c;
} n => 6, name => 'children read-only';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $node2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $node3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  $node->append_child ($node3);

  my $nl = $node->children;

  dies_here_ok {
    $nl->[0] = $node2;
  };
  ok not ref $@;
  like $@, qr{^Modification of a read-only value attempted};
  is scalar @$nl, 1;
  is $nl->[0], $node3;
  is $node3->parent_node, $node;
  ok not $node2->parent_node;

  $$node3->[100] = 13;
  is $$node3->[100], 13;

  done $c;
} n => 8, name => 'child_nodes read-only';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');

  my $nl = $node->children;
  my $nl_s = $nl . '';
  undef $nl;

  my $nl2 = $node->children;
  my $nl2_s = $nl2 . '';
  
  ok $nl2_s eq $nl_s;
  ok not $nl2_s ne $nl_s;
  ok not $nl2 eq $nl_s;
  ok $nl2 ne $nl_s;
  ok not $nl2 eq undef;
  ok $nl2 ne undef;
  ok $nl2 eq $node->children;
  ok not $nl2 ne $node->children;
  is $nl2 cmp $node->children, 0;
  isnt $nl2 cmp $node->children, undef;

  my $nl3 = $doc->children;
  ok $nl3 ne $nl2;
  ok not $nl3 eq $nl2;

  ok $nl2;

  done $c;
} n => 13, name => 'children comparison';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $nl = $node->children;

  is $nl->length, 0;
  is scalar @$nl, 0;

  is $nl->item (0), undef;
  is $nl->item (1), undef;
  is $nl->item (2), undef;
  is $nl->item (0+"inf"), undef;
  is $nl->item (0+"-inf"), undef;
  is $nl->item (0+"nan"), undef;
  is $nl->item (+0**1), undef;
  is $nl->item (-0**1), undef;
  is $nl->item (-1), undef;
  is $nl->item (-3), undef;

  is $nl->[0], undef;
  is $nl->[1], undef;
  is $nl->[2], undef;
  is scalar $nl->[0+"inf"], undef;
  is scalar $nl->[0+"-inf"], undef;
  is scalar $nl->[0+"nan"], undef;
  is $nl->[+0**1], undef;
  is $nl->[-0**1], undef;
  is scalar $nl->[-1], undef;
  is scalar $nl->[-3], undef;

  done $c;
} n => 22, name => 'children items, empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $nl = $node->children;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b');
  $node->append_child ($el);

  is $nl->length, 1;
  is scalar @$nl, 1;

  is $nl->item (0), $el;
  is $nl->item (1), undef;
  is $nl->item (2), undef;
  is $nl->item (0+"inf"), $el;
  is $nl->item (0+"-inf"), $el;
  is $nl->item (0+"nan"), $el;
  is $nl->item (+0**1), $el;
  is $nl->item (-0**1), $el;
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
  is scalar $nl->[0+"-inf"], [$el]->[0+"-inf"];
  is scalar $nl->[0+"nan"], $el;
  is $nl->[+0**1], $el;
  is $nl->[-0**1], $el;
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
  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $nl = $node->children;

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
  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $nl = $node->children;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'f');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'f');
  $node->append_child ($el1);
  $node->append_child ($el2);

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
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el1->set_attribute (id => 'abc');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fuga');
  $el2->set_attribute (name => 'def');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  my $col = $doc->get_elements_by_tag_name ('*');
  is $col->length, 2;
  
  is $col->named_item ('abc'), $el1;
  is $col->{abc}, $el1;

  is $col->named_item ('def'), $el2;
  is $col->{def}, $el2;
  ok exists $col->{def};

  is $col->named_item ('fuga'), undef;
  is $col->{fuga}, undef;
  ok not exists $col->{fuga};

  dies_here_ok {
    delete $col->{abc};
  };
  like $@, qr{^Modification of a read-only value attempted};

  dies_here_ok {
    $col->{fuga} = $el2;
  };
  like $@, qr{^Modification of a read-only value attempted};

  ok 2 == keys %$col;
  is_deeply [sort { $a cmp $b } keys %$col], ['abc', 'def'];
  
  done $c;
} n => 15, name => 'named_items';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el1->set_attribute (id => 'abc');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fuga');
  $el2->set_attribute (id => 'abc');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  my $col = $doc->get_elements_by_tag_name ('*');
  is $col->{abc}, $el1;

  done $c;
} n => 1, name => 'named_item duplicate';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el1->set_attribute (id => 'abc');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fuga');
  $el2->set_attribute (name => 'abc');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  my $col = $doc->get_elements_by_tag_name ('*');
  is $col->{abc}, $el1;

  done $c;
} n => 1, name => 'named_item duplicate';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el1->set_attribute (name => 'abc');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fuga');
  $el2->set_attribute (id => 'abc');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  my $col = $doc->get_elements_by_tag_name ('*');
  is $col->{abc}, $el1;

  done $c;
} n => 1, name => 'named_item duplicate';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el1->set_attribute (name => 'abc');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fuga');
  $el2->set_attribute (name => 'abc');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  my $col = $doc->get_elements_by_tag_name ('*');
  is $col->{abc}, $el1;

  done $c;
} n => 1, name => 'named_item duplicate';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el1->set_attribute (name => 'def');
  $el1->set_attribute (id => 'abc');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fuga');
  $el2->set_attribute (name => 'abc');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  my $col = $doc->get_elements_by_tag_name ('*');
  is $col->{abc}, $el1;

  done $c;
} n => 1, name => 'named_item duplicate';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el1->set_attribute (id => '');
  $doc->append_child ($el1);

  my $col = $doc->get_elements_by_tag_name ('*');
  is $col->{''}, undef;

  done $c;
} n => 1, name => 'named_item empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el1->set_attribute (name => '');
  $doc->append_child ($el1);

  my $col = $doc->get_elements_by_tag_name ('*');
  is $col->{''}, undef;
  is $col->{'  '}, undef;

  done $c;
} n => 2, name => 'named_item empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns (undef, 'hoge');
  $el1->set_attribute (id => 'abc');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fuga');
  $el2->set_attribute (name => 'abc');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  my $col = $doc->get_elements_by_tag_name ('*');
  is $col->{abc}, $el1;

  done $c;
} n => 1, name => 'named_item duplicate';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns (undef, 'hoge');
  $el1->set_attribute (name => 'abc');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fuga');
  $el2->set_attribute (id => 'abc');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  my $col = $doc->get_elements_by_tag_name ('*');
  is $col->{abc}, $el2;

  done $c;
} n => 1, name => 'named_item duplicate';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el2->set_attribute (id => 'hoge');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  my $col = $doc->get_elements_by_tag_name_ns ('*', '*');
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
  is $col->{fuga}, $el1;

  done $c;
} n => 9, name => 'mutation';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el1->class_name ('fuga');
  $el1->id ('aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el2->class_name ('Fuga');
  $el2->id ('aa');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  my $col = $doc->get_elements_by_class_name ('Fuga');
  is $col->length, 1;
  is $col->[0], $el2;
  is $col->{fuga}, undef;
  is $col->{aa}, $el2;

  $doc->manakai_is_html (1);
  $doc->manakai_compat_mode ('quirks');

  is $col->length, 2;
  is $col->{aa}, $el1;

  done $c;
} n => 6, name => 'mutation';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el1->class_name ('fuga');
  $el1->id ('aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el2->class_name ('Fuga');
  $el2->id ('aa');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  my $col = $doc->get_elements_by_class_name ('Fuga');
  is $col->length, 1;
  is $col->[0], $el2;
  is $col->{fuga}, undef;
  is $col->{aa}, $el2;

  $doc->manakai_compat_mode ('quirks');

  is $col->length, 2;
  is $col->{aa}, $el1;

  done $c;
} n => 6, name => 'mutation';

run_tests;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
