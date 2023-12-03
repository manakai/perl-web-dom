use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

## See also: htmltemplateelement.t

{
  package test::DestroyCallback;
  sub DESTROY {
    $_[0]->();
  }
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');

  $doc2->adopt_node ($el);

  isa_ok $el, 'Web::DOM::Element';
  is $el->node_type, $el->ELEMENT_NODE;
  is $el->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el->prefix, undef;
  is $el->local_name, 'aa';
  is $el->child_nodes->length, 0;
  is $el->attributes->length, 0;
  is $el->owner_document, $doc2;
  
  is $$el->[0], $$doc2->[0];
  isnt $$el->[0], $$doc->[0];

  done $c;
} n => 10, name => 'adopt element empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $text = $doc->create_text_node ('bbb');
  $el->append_child ($text);

  $doc2->adopt_node ($el);

  isa_ok $el, 'Web::DOM::Element';
  is $el->node_type, $el->ELEMENT_NODE;
  is $el->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el->prefix, undef;
  is $el->local_name, 'aa';
  is $el->child_nodes->length, 1;
  is $el->attributes->length, 0;
  is $el->owner_document, $doc2;
  is $el->parent_node, undef;

  is $el->first_child, $text;
  is $text->data, 'bbb';
  is $text->child_nodes->length, 0;
  is $text->owner_document, $doc2;
  is $text->parent_node, $el;
  
  is $$el->[0], $$doc2->[0];
  is $$text->[0], $$doc2->[0];
  isnt $$el->[0], $$doc->[0];

  done $c;
} n => 17, name => 'adopt element has child';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $text = $doc->create_text_node ('bbb');
  $el->append_child ($el2);
  $el2->append_child ($el3);
  $el3->append_child ($text);

  $doc2->adopt_node ($el);

  is $el->child_nodes->length, 1;
  is $el->attributes->length, 0;
  is $el->owner_document, $doc2;
  is $el->parent_node, undef;
  is $el->first_child, $el2;

  is $el2->child_nodes->length, 1;
  is $el2->attributes->length, 0;
  is $el2->owner_document, $doc2;
  is $el2->parent_node, $el;
  is $el2->first_child, $el3;

  is $el3->child_nodes->length, 1;
  is $el3->attributes->length, 0;
  is $el3->owner_document, $doc2;
  is $el3->parent_node, $el2;
  is $el3->first_child, $text;

  is $text->data, 'bbb';
  is $text->child_nodes->length, 0;
  is $text->owner_document, $doc2;
  is $text->parent_node, $el3;
  
  done $c;
} n => 19, name => 'adopt element has descendant';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el->set_attribute ('hoge' => 'abb');

  $doc2->adopt_node ($el);

  is $el->local_name, 'aa';
  is $el->child_nodes->length, 0;
  is $el->attributes->length, 1;
  is $el->owner_document, $doc2;
  is $el->get_attribute ('hoge'), 'abb';
  is $el->get_attribute_node ('hoge')->owner_document, $doc2;
  is $el->get_attribute_node ('hoge')->owner_element, $el;
  
  is $$el->[0], $$doc2->[0];
  isnt $$el->[0], $$doc->[0];

  done $c;
} n => 9, name => 'adopt element with simple attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el->set_attribute_ns ('http://', 'fuga:hoge' => 'abb');
  my $attr = $el->get_attribute_node_ns ('http://', 'hoge');

  $doc2->adopt_node ($el);

  is $el->local_name, 'aa';
  is $el->child_nodes->length, 0;
  is $el->attributes->length, 1;
  is $el->owner_document, $doc2;
  is $el->get_attribute ('fuga:hoge'), 'abb';
  is $el->get_attribute_node ('fuga:hoge')->owner_document, $doc2;
  is $el->get_attribute_node ('fuga:hoge'), $attr;
  is $attr->owner_element, $el;
  
  is $$el->[0], $$doc2->[0];
  is $$attr->[0], $$doc2->[0];
  isnt $$el->[0], $$doc->[0];

  done $c;
} n => 11, name => 'adopt element with node attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el0 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el->set_attribute_ns ('http://', 'fuga:hoge' => 'abb');
  $el0->append_child ($el);
  my $attr = $el->get_attribute_node_ns ('http://', 'hoge');

  $doc2->adopt_node ($el0);

  is $el->local_name, 'aa';
  is $el->child_nodes->length, 0;
  is $el->attributes->length, 1;
  is $el->owner_document, $doc2;
  is $el->get_attribute ('fuga:hoge'), 'abb';
  is $el->get_attribute_node ('fuga:hoge')->owner_document, $doc2;
  is $el->get_attribute_node ('fuga:hoge'), $attr;
  is $attr->owner_element, $el;
  
  is $$el->[0], $$doc2->[0];
  is $$attr->[0], $$doc2->[0];
  isnt $$el->[0], $$doc->[0];

  done $c;
} n => 11, name => 'adopt element with child element with node attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el->append_child ($el2);
  $el->append_child ($el3);
  $el->append_child ($el4);
  my $children = $el->child_nodes;
  is $children->length, 3;

  $doc2->adopt_node ($el);

  is $children->length, 3;
  is $children->[0], $el2;
  is $children->[1], $el3;
  is $children->[2], $el4;

  my $el5 = $doc2->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  $el->append_child ($el5);

  is $children->length, 4;
  is $children->[3], $el5;

  done $c;
} n => 7, name => 'adopt element child_nodes';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el->append_child ($el2);
  $el->append_child ($el3);
  $el->append_child ($el4);
  my $children = $el->children;
  is $children->length, 3;

  $doc2->adopt_node ($el);

  is $children->length, 3;
  is $children->[0], $el2;
  is $children->[1], $el3;
  is $children->[2], $el4;

  my $el5 = $doc2->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  $el->append_child ($el5);

  is $children->length, 4;
  is $children->[3], $el5;

  done $c;
} n => 7, name => 'adopt element children';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el0 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el0->append_child ($el);
  $el->append_child ($el2);
  $el->append_child ($el3);
  $el->append_child ($el4);
  my $children = $el->children;
  is $children->length, 3;

  $doc2->adopt_node ($el0);

  is $children->length, 3;
  is $children->[0], $el2;
  is $children->[1], $el3;
  is $children->[2], $el4;

  my $el5 = $doc2->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  $el->append_child ($el5);

  is $children->length, 4;
  is $children->[3], $el5;

  done $c;
} n => 7, name => 'adopt element children';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el->append_child ($el2);
  $el->append_child ($el3);
  $el->append_child ($el4);
  my $children = $el->get_elements_by_tag_name ('*');
  is $children->length, 3;

  $doc2->adopt_node ($el);

  is $children->length, 3;
  is $children->[0], $el2;
  is $children->[1], $el3;
  is $children->[2], $el4;

  my $el5 = $doc2->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  $el->append_child ($el5);

  is $children->length, 4;
  is $children->[3], $el5;

  done $c;
} n => 7, name => 'adopt element get_elements_by_tag_name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el0 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el0->append_child ($el);
  $el->append_child ($el2);
  $el->append_child ($el3);
  $el->append_child ($el4);
  my $children = $el->get_elements_by_tag_name ('*');
  is $children->length, 3;

  $doc2->adopt_node ($el0);

  is $children->length, 3;
  is $children->[0], $el2;
  is $children->[1], $el3;
  is $children->[2], $el4;

  my $el5 = $doc2->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  $el->append_child ($el5);

  is $children->length, 4;
  is $children->[3], $el5;

  done $c;
} n => 7, name => 'adopt element get_elements_by_tag_name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $called;
  $el->set_user_data (destroy => bless sub {
                        $called = 1;
                      }, 'test::DestroyCallback');

  $doc2->adopt_node ($el);

  ok not $called;
  undef $el;
  ok $called;

  done $c;
} n => 2, name => 'adopt element destroy';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el->append_child ($el2);
  my $called;
  $el2->set_user_data (destroy => bless sub {
                         $called = 1;
                       }, 'test::DestroyCallback');
  undef $el2;

  $doc2->adopt_node ($el);

  ok not $called;
  undef $el;
  ok $called;

  done $c;
} n => 2, name => 'adopt element destroy';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el->append_child ($el2);

  $doc2->adopt_node ($el2);

  is $el->child_nodes->length, 0;
  is $el->owner_document, $doc;

  is $el2->parent_node, undef;
  is $el2->owner_document, $doc2;

  done $c;
} n => 4, name => 'adopt element with parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $attr = $doc->create_attribute ('aa');
  $attr->value ('hoge');
  $el->set_attribute_node ($attr);

  $doc2->adopt_node ($attr);

  is $el->attributes->length, 0;
  is $el->owner_document, $doc;
  is $el->get_attribute ('aa'), undef;

  is $attr->owner_element, undef;
  is $attr->owner_document, $doc2;

  done $c;
} n => 5, name => 'adopt element with attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $called;
  $doc->set_user_data (destroy => bless sub {
                         $called = 1;
                       }, 'test::DestroyCallback');
  undef $doc;

  $doc2->adopt_node ($el);

  ok $called;

  done $c;
} n => 1, name => 'adopt element destroy';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;
  
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el->set_attribute ('fuga' => 12);

  my $called;
  $doc->set_user_data (destroy => bless sub {
                         $called = 1;
                       }, 'test::DestroyCallback');
  undef $doc;
  $doc2->adopt_node ($el->get_attribute_node ('fuga'));

  ok not $called;
  undef $el;

  ok $called;

  done $c;
} n => 2, name => 'adopt element destroy';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;

  my $node = $doc->create_processing_instruction ('aa', 'bb');
  my $node2 = $doc2->adopt_node ($node);

  is $node2, $node;
  is $node2->owner_document, $doc2;

  done $c;
} n => 2, name => 'adopt_node return value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;

  dies_here_ok {
    $doc2->adopt_node ($doc);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotSupportedError';
  is $@->message, 'Cannot adopt document node';

  is $doc2->owner_document, undef;
  isnt $$doc2->[0], $$doc->[0];

  done $c;
} n => 6, name => 'adopt_node document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aaa');
  my $node2 = $doc->adopt_node ($node);

  is $node2, $node;
  is $node2->owner_document, $doc;
  
  done $c;
} n => 2, name => 'adopt_node same document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aaa');
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ab');
  $node->append_child ($el);

  $doc->adopt_node ($node);

  is $node->owner_document, $doc;
  is $el->owner_document, $doc;
  is $el->parent_node, $node;
  is $node->parent_node, undef;
  
  done $c;
} n => 4, name => 'adopt_node same document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aaa');
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ab');
  $node->append_child ($el);

  $doc->adopt_node ($el);

  is $node->owner_document, $doc;
  is $el->owner_document, $doc;
  is $el->parent_node, undef;
  is $node->parent_node, undef;
  
  done $c;
} n => 4, name => 'adopt_node same document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aaa');
  my $attr = $doc->create_attribute ('ab');
  $node->set_attribute_node ($attr);

  $doc->adopt_node ($attr);

  is $node->owner_document, $doc;
  is $attr->owner_document, $doc;
  is $node->parent_node, undef;
  is $attr->owner_element, undef;
  is $node->get_attribute ('ab'), undef;
  
  done $c;
} n => 5, name => 'adopt_node same document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  dies_here_ok {
    $doc->adopt_node (undef);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->name, 'TypeError';
  is $@->message, 'The argument is not a Node';

  done $c;
} n => 4, name => 'adopt_node not Node';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;

  my $dt1 = $doc1->create_document_type_definition ('hoge');
  my $et1 = $doc1->create_element_type_definition ('foo');
  my $at1 = $doc1->create_attribute_definition ('foo');
  my $ent1 = $doc1->create_general_entity ('bar');
  my $not1 = $doc1->create_notation ('bar');
  my $pi1 = $doc1->create_processing_instruction ('hoge', '');
  $dt1->set_element_type_definition_node ($et1);
  $et1->set_attribute_definition_node ($at1);
  $dt1->set_general_entity_node ($ent1);
  $dt1->set_notation_node ($not1);
  $doc1->dom_config->{manakai_allow_doctype_children} = 1;
  $dt1->append_child ($pi1);

  $doc2->adopt_node ($dt1);

  is $dt1->owner_document, $doc2;
  is $et1->owner_document, $doc2;
  is $at1->owner_document, $doc2;
  is $ent1->owner_document, $doc2;
  is $not1->owner_document, $doc2;
  is $pi1->owner_document, $doc2;
  is $dt1->parent_node, undef;
  is $et1->owner_document_type_definition, $dt1;
  is $at1->owner_element_type_definition, $et1;
  is $ent1->owner_document_type_definition, $dt1;
  is $not1->owner_document_type_definition, $dt1;
  is $pi1->parent_node, $dt1;
  is $dt1->child_nodes->length, 1;
  is $dt1->child_nodes->[0], $pi1;
  is $dt1->element_types->length, 1;
  is $dt1->element_types->[0], $et1;
  is $et1->attribute_definitions->length, 1;
  is $et1->attribute_definitions->[0], $at1;
  is $dt1->general_entities->length, 1;
  is $dt1->general_entities->[0], $ent1;
  is $dt1->notations->length, 1;
  is $dt1->notations->[0], $not1;

  done $c;
} n => 22, name => 'adopt document type';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;

  my $df = $doc1->create_document_fragment;
  is $df->owner_document, $doc1;

  is $doc2->adopt_node ($df), $df;
  is $df->owner_document, $doc2;

  done $c;
} n => 3, name => 'adopt document fragment, normal, no child';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;

  my $df = $doc1->create_document_fragment;
  my $el = $doc1->create_element ('x');
  $df->append_child ($el);
  is $df->owner_document, $doc1;
  is $el->owner_document, $doc1;

  is $doc2->adopt_node ($df), $df;
  is $df->owner_document, $doc2;
  is $el->owner_document, $doc2;

  done $c;
} n => 5, name => 'adopt document fragment, normal, with child';

run_tests;

=head1 LICENSE

Copyright 2012-2023 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
