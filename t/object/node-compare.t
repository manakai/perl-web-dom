use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::Differences;
use Test::DOM::Exception;
use Web::DOM::Document;
use Web::DOM::Node;

test {
  my $c = shift;
  ok DOCUMENT_POSITION_DISCONNECTED;
  ok DOCUMENT_POSITION_PRECEDING;
  ok DOCUMENT_POSITION_FOLLOWING;
  ok DOCUMENT_POSITION_CONTAINS;
  ok DOCUMENT_POSITION_CONTAINED_BY;
  ok DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  ok +Web::DOM::Node->DOCUMENT_POSITION_DISCONNECTED;
  ok +Web::DOM::Node->DOCUMENT_POSITION_PRECEDING;
  ok +Web::DOM::Node->DOCUMENT_POSITION_FOLLOWING;
  ok +Web::DOM::Node->DOCUMENT_POSITION_CONTAINS;
  ok +Web::DOM::Node->DOCUMENT_POSITION_CONTAINED_BY;
  ok +Web::DOM::Node->DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  my $doc = Web::DOM::Document->new;
  ok $doc->DOCUMENT_POSITION_DISCONNECTED;
  ok $doc->DOCUMENT_POSITION_PRECEDING;
  ok $doc->DOCUMENT_POSITION_FOLLOWING;
  ok $doc->DOCUMENT_POSITION_CONTAINS;
  ok $doc->DOCUMENT_POSITION_CONTAINED_BY;
  ok $doc->DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  done $c;
} n => 18, name => 'constants';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');

  dies_here_ok {
    $node->compare_document_position (undef);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->name, 'TypeError';
  is $@->message, 'The argument is not a Node';
  
  done $c;
} n => 4, name => 'compare not node';

test {
  my $c = shift;

  my $doc = new Web::DOM::Document;
  is $doc->compare_document_position ($doc), 0;

  my $node = $doc->create_element ('foo');
  is $node->compare_document_position ($node), 0;

  done $c;
} n => 2, name => 'compare same';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;

  my $result1 = $doc1->compare_document_position ($doc2);
  my $result2 = $doc2->compare_document_position ($doc1);

  ok $result1 & DOCUMENT_POSITION_DISCONNECTED;
  ok $result2 & DOCUMENT_POSITION_DISCONNECTED;
  ok $result1 & DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  ok $result2 & DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  ok $result1 & DOCUMENT_POSITION_PRECEDING
      || $result2 & DOCUMENT_POSITION_PRECEDING;
  ok $result1 & DOCUMENT_POSITION_FOLLOWING
      || $result2 & DOCUMENT_POSITION_FOLLOWING;
  ok $result1 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_PRECEDING) ||
     $result2 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_PRECEDING);
  ok $result1 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_FOLLOWING) ||
     $result2 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_FOLLOWING);
  isnt $result1, $result2;

  my $result3 = $doc1->compare_document_position ($doc2);
  my $result4 = $doc2->compare_document_position ($doc1);
  is $result1, $result3;
  is $result2, $result4;
  
  done $c;
} n => 11, name => 'compare different document';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $node1 = $doc1->create_element ('foo');
  my $node2 = $doc2->create_element ('bar');

  my $result1 = $node1->compare_document_position ($node2);
  my $result2 = $node2->compare_document_position ($node1);

  ok $result1 & DOCUMENT_POSITION_DISCONNECTED;
  ok $result2 & DOCUMENT_POSITION_DISCONNECTED;
  ok $result1 & DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  ok $result2 & DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  ok $result1 & DOCUMENT_POSITION_PRECEDING
      || $result2 & DOCUMENT_POSITION_PRECEDING;
  ok $result1 & DOCUMENT_POSITION_FOLLOWING
      || $result2 & DOCUMENT_POSITION_FOLLOWING;
  ok $result1 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_PRECEDING) ||
     $result2 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_PRECEDING);
  ok $result1 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_FOLLOWING) ||
     $result2 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_FOLLOWING);
  isnt $result1, $result2;

  my $result3 = $node1->compare_document_position ($node2);
  my $result4 = $node2->compare_document_position ($node1);
  is $result1, $result3;
  is $result2, $result4;
  
  done $c;
} n => 11, name => 'compare different document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('foo');
  my $node2 = $doc->create_element ('bar');

  my $result1 = $node1->compare_document_position ($node2);
  my $result2 = $node2->compare_document_position ($node1);

  ok $result1 & DOCUMENT_POSITION_DISCONNECTED;
  ok $result2 & DOCUMENT_POSITION_DISCONNECTED;
  ok $result1 & DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  ok $result2 & DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  ok $result1 & DOCUMENT_POSITION_PRECEDING
      || $result2 & DOCUMENT_POSITION_PRECEDING;
  ok $result1 & DOCUMENT_POSITION_FOLLOWING
      || $result2 & DOCUMENT_POSITION_FOLLOWING;
  ok $result1 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_PRECEDING) ||
     $result2 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_PRECEDING);
  ok $result1 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_FOLLOWING) ||
     $result2 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_FOLLOWING);
  isnt $result1, $result2;

  my $result3 = $node1->compare_document_position ($node2);
  my $result4 = $node2->compare_document_position ($node1);
  is $result1, $result3;
  is $result2, $result4;
  
  done $c;
} n => 11, name => 'compare different tree';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  $el1->append_child ($el2);

  my $result1 = $el1->compare_document_position ($el2);
  my $result2 = $el2->compare_document_position ($el1);
  
  is $result1, DOCUMENT_POSITION_CONTAINED_BY | DOCUMENT_POSITION_FOLLOWING;
  is $result2, DOCUMENT_POSITION_CONTAINS | DOCUMENT_POSITION_PRECEDING;

  done $c;
} n => 2, name => 'compare is parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  my $el3 = $doc->create_element ('b');
  $el1->append_child ($el2);
  $el2->append_child ($el3);

  my $result1 = $el1->compare_document_position ($el3);
  my $result2 = $el3->compare_document_position ($el1);
  
  is $result1, DOCUMENT_POSITION_CONTAINED_BY | DOCUMENT_POSITION_FOLLOWING;
  is $result2, DOCUMENT_POSITION_CONTAINS | DOCUMENT_POSITION_PRECEDING;

  done $c;
} n => 2, name => 'compare is ancestor';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  my $el3 = $doc->create_element ('a');
  my $el4 = $doc->create_element ('a');
  $el1->append_child ($el2);
  $el1->append_child ($el3);
  $el1->append_child ($el4);

  is $el1->compare_document_position ($el2),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;
  is $el1->compare_document_position ($el3),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;
  is $el1->compare_document_position ($el4),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;
  is $el2->compare_document_position ($el3),
      DOCUMENT_POSITION_FOLLOWING;
  is $el2->compare_document_position ($el4),
      DOCUMENT_POSITION_FOLLOWING;
  is $el3->compare_document_position ($el2),
      DOCUMENT_POSITION_PRECEDING;
  is $el4->compare_document_position ($el2),
      DOCUMENT_POSITION_PRECEDING;
  is $el2->compare_document_position ($el1),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
  is $el3->compare_document_position ($el1),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
  is $el4->compare_document_position ($el1),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;

  done $c;
} n => 10, name => 'compare siblings';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  my $el3 = $doc->create_element ('a');
  my $el4 = $doc->create_element ('a');
  my $el5 = $doc->create_element ('a');
  $el1->append_child ($el2);
  $el1->append_child ($el3);
  $el2->append_child ($el4);
  $el3->append_child ($el5);

  is $el4->compare_document_position ($el5),
      DOCUMENT_POSITION_FOLLOWING;
  is $el5->compare_document_position ($el4),
      DOCUMENT_POSITION_PRECEDING;

  done $c;
} n => 2, name => 'compare sibling children';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');
  $el->set_attribute (hoge => 1);
  $el->set_attribute (fuga => 2);

  my $attr1 = $el->get_attribute_node ('hoge');
  my $attr2 = $el->get_attribute_node ('fuga');

  is $attr1->compare_document_position ($attr2),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  is $attr2->compare_document_position ($attr1),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  is $attr1->compare_document_position ($el),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
  is $el->compare_document_position ($attr1),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;

  done $c;
} n => 4, name => 'compare attrs of same element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  $el1->append_child ($el2);
  $el1->set_attribute (hoge => 1);
  $el2->set_attribute (fuga => 2);

  my $attr1 = $el1->get_attribute_node ('hoge');
  my $attr2 = $el2->get_attribute_node ('fuga');

  is $attr1->compare_document_position ($attr2),
      DOCUMENT_POSITION_FOLLOWING;
  is $attr2->compare_document_position ($attr1),
      DOCUMENT_POSITION_PRECEDING;
  is $attr2->compare_document_position ($el1),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
  is $el1->compare_document_position ($attr2),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;
  is $attr1->compare_document_position ($el2),
      DOCUMENT_POSITION_FOLLOWING;
  is $el2->compare_document_position ($attr1),
      DOCUMENT_POSITION_PRECEDING;

  done $c;
} n => 6, name => 'compare attrs of parent element';

for my $type (qw(element_type_definition general_entity notation)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;

    my $el = $doc->create_document_type_definition ('a');
    my $method1 = 'create_' . $type;
    my $attr1 = $doc->$method1 ('hoge');
    my $attr2 = $doc->$method1 ('fuga');
    my $method2 = 'set_' . $type . '_node';
    $el->$method2 ($attr1);
    $el->$method2 ($attr2);

    is $attr2->compare_document_position ($attr1),
        DOCUMENT_POSITION_FOLLOWING |
        DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
    is $attr1->compare_document_position ($attr2),
        DOCUMENT_POSITION_PRECEDING |
        DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
    is $attr1->compare_document_position ($el),
        DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
    is $el->compare_document_position ($attr1),
        DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;

    $doc->append_child ($el);
    is $attr1->compare_document_position ($el),
        DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
    is $el->compare_document_position ($attr1),
        DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;
    is $attr1->compare_document_position ($doc),
        DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
    is $doc->compare_document_position ($attr1),
        DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;

    done $c;
  } n => 8, name => ['compare', $type];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_document_type_definition ('a');
  my $attr1 = $doc->create_general_entity ('hoge');
  my $attr2 = $doc->create_notation ('zfuga');
  my $attr3 = $doc->create_element_type_definition ('afuga');
  my $pi = $doc->create_processing_instruction ('hoge');
  $el->set_general_entity_node ($attr1);
  $el->set_notation_node ($attr2);
  $el->set_element_type_definition_node ($attr3);
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  $el->append_child ($pi);

  is $attr1->compare_document_position ($attr2),
      DOCUMENT_POSITION_FOLLOWING |
      DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  is $attr2->compare_document_position ($attr3),
      DOCUMENT_POSITION_FOLLOWING |
      DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  is $attr1->compare_document_position ($attr3),
      DOCUMENT_POSITION_FOLLOWING |
      DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  is $attr1->compare_document_position ($pi), DOCUMENT_POSITION_FOLLOWING;
  is $attr2->compare_document_position ($pi), DOCUMENT_POSITION_FOLLOWING;
  is $attr3->compare_document_position ($pi), DOCUMENT_POSITION_FOLLOWING;
  is $attr2->compare_document_position ($attr1),
      DOCUMENT_POSITION_PRECEDING |
      DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  is $attr3->compare_document_position ($attr1),
      DOCUMENT_POSITION_PRECEDING |
      DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  is $attr3->compare_document_position ($attr2),
      DOCUMENT_POSITION_PRECEDING |
      DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  is $pi->compare_document_position ($attr1), DOCUMENT_POSITION_PRECEDING;
  is $pi->compare_document_position ($attr2), DOCUMENT_POSITION_PRECEDING;
  is $pi->compare_document_position ($attr3), DOCUMENT_POSITION_PRECEDING;

  done $c;
} n => 12, name => ['compare document type children'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element_type_definition ('a');
  my $attr1 = $doc->create_attribute_definition ('hoge');
  my $attr2 = $doc->create_attribute_definition ('fuga');
  $el->set_attribute_definition_node ($attr1);
  $el->set_attribute_definition_node ($attr2);

  is $attr2->compare_document_position ($attr1),
      DOCUMENT_POSITION_PRECEDING |
      DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  is $attr1->compare_document_position ($attr2),
      DOCUMENT_POSITION_FOLLOWING |
      DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  is $attr1->compare_document_position ($el),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
  is $el->compare_document_position ($attr1),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;

  my $dt = $doc->create_document_type_definition ('foo');
  $dt->set_element_type_definition_node ($el);
  my $notation = $doc->create_notation ('hoge');
  $dt->set_notation_node ($notation);

  is $attr1->compare_document_position ($el),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
  is $el->compare_document_position ($attr1),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;
  is $attr1->compare_document_position ($dt),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
  is $dt->compare_document_position ($attr1),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;
  is $attr1->compare_document_position ($notation),
      DOCUMENT_POSITION_PRECEDING;
  is $notation->compare_document_position ($attr1),
      DOCUMENT_POSITION_FOLLOWING;

  $doc->append_child ($dt);

  is $attr1->compare_document_position ($el),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
  is $el->compare_document_position ($attr1),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;
  is $attr1->compare_document_position ($dt),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
  is $dt->compare_document_position ($attr1),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;
  is $attr1->compare_document_position ($notation),
      DOCUMENT_POSITION_PRECEDING;
  is $notation->compare_document_position ($attr1),
      DOCUMENT_POSITION_FOLLOWING;
  is $attr1->compare_document_position ($doc),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
  is $doc->compare_document_position ($attr1),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;

  done $c;
} n => 18, name => ['compare attribute definitions'];

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $el1 = $doc1->create_element ('a');
  my $el2 = $doc2->create_element ('a');

  ok not $el1->contains ($el2);
  ok not $el2->contains ($el1);

  done $c;
} n => 2, name => 'contains different document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');

  ok not $el1->contains ($el2);
  ok not $el2->contains ($el1);

  done $c;
} n => 2, name => 'contains different tree';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');

  ok not $node->contains (undef);
  
  done $c;
} n => 1, name => 'contains undef';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  
  dies_here_ok {
    $node->contains ('hoge');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->name, 'TypeError';
  is $@->message, 'The argument is not a Node';
  
  done $c;
} n => 4, name => 'contains not node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');

  ok $el->contains ($el);

  done $c;
} n => 1, name => 'contains self';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  $el1->append_child ($el2);

  ok $el1->contains ($el2);
  ok not $el2->contains ($el1);

  done $c;
} n => 2, name => 'contains parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  my $el3 = $doc->create_element ('a');
  $el1->append_child ($el2);
  $el2->append_child ($el3);

  ok $el1->contains ($el3);
  ok not $el3->contains ($el1);

  done $c;
} n => 2, name => 'contains ancestor';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  $el2->set_attribute (hoge => 12);
  my $attr = $el2->get_attribute_node ('hoge');
  $el1->append_child ($el2);

  ok not $el1->contains ($attr);
  ok not $attr->contains ($el1);

  done $c;
} n => 2, name => 'contains attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el2 = $doc->create_document_type_definition ('a');
  my $attr = $doc->create_element_type_definition ('hoge');
  $el2->set_element_type_definition_node ($attr);
  $doc->append_child ($el2);

  ok not $doc->contains ($attr);
  ok not $attr->contains ($doc);

  done $c;
} n => 2, name => 'contains element type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el2 = $doc->create_document_type_definition ('a');
  my $attr = $doc->create_general_entity ('hoge');
  $el2->set_general_entity_node ($attr);
  $doc->append_child ($el2);

  ok not $doc->contains ($attr);
  ok not $attr->contains ($doc);

  done $c;
} n => 2, name => 'contains general entity';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el2 = $doc->create_document_type_definition ('a');
  my $attr = $doc->create_notation ('hoge');
  $el2->set_notation_node ($attr);
  $doc->append_child ($el2);

  ok not $doc->contains ($attr);
  ok not $attr->contains ($doc);

  done $c;
} n => 2, name => 'contains notation';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el1 = $doc->create_document_type_definition ('b');
  my $el2 = $doc->create_element_type_definition ('a');
  my $attr = $doc->create_attribute_definition ('hoge');
  $el2->set_attribute_definition_node ($attr);
  $el1->set_element_type_definition_node ($el2);
  $doc->append_child ($el1);

  ok not $el1->contains ($attr);
  ok not $attr->contains ($el1);
  ok not $doc->contains ($attr);
  ok not $attr->contains ($doc);

  done $c;
} n => 4, name => 'contains attribute definition';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  $doc->inner_html (q{<!DOCTYPE html><html><head><title>aaa</title><link><base><p>aaaaa<span>afwww</span><span>afwww</span>afffff<p>aaaa<br><img>});
  eq_or_diff $doc->_tree_node_indexes, [0];
  for (
    ['html' => [0, 1]],
    ['body' => [0, 1, 1]],
    ['title' => [0, 1, 0, 0]],
    ['link' => [0, 1, 0, 1]],
    ['img' => [0, 1, 1, 1, 2]],
  ) {
    eq_or_diff $doc->query_selector ($_->[0])->_tree_node_indexes, $_->[1];
  }
  $doc->append_child ($doc->create_comment ('aa'));
  eq_or_diff $doc->last_child->_tree_node_indexes, [0, 2];
  my $el = $doc->create_element ('aa');
  $doc->body->first_child->replace_child ($el, $doc->body->first_child->first_child);
  eq_or_diff $el->_tree_node_indexes, [0, 1, 1, 0, 0];
  eq_or_diff $doc->query_selector ('span')->_tree_node_indexes, [0, 1, 1, 0, 1];
  $el->parent_node->remove_child ($el);
  eq_or_diff $doc->query_selector ('span')->_tree_node_indexes, [0, 1, 1, 0, 0];
  eq_or_diff $el->_tree_node_indexes, [0];
  done $c;
} n => 11, name => '_tree_node_indexes';

run_tests;

=head1 LICENSE

Copyright 2012-2014 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
