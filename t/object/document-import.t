use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc2 = new Web::DOM::Document;

  dies_here_ok {
    $doc2->import_node ('hoge');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->name, 'TypeError';
  is $@->message, 'The argument is not a Node';

  done $c;
} n => 4, name => 'not node';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;

  dies_here_ok {
    $doc2->import_node ($doc1);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotSupportedError';
  is $@->message, 'Cannot import document node';
  is $doc2->owner_document, undef;

  done $c;
} n => 5, name => 'document';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $el = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'aaa');
  $el->text_content ('hoge');

  my $el2 = $doc2->import_node ($el);
  isnt $el2, $el;
  is $el->owner_document, $doc1;
  is $el2->owner_document, $doc2;
  is $el->text_content, 'hoge';
  is $el2->text_content, '';
  is $el2->node_name, 'aaa';

  done $c;
} n => 6, name => 'element not deep';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $el = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'aaa');
  $el->text_content ('hoge');
  $el->set_attribute (hoge => 'baaaa');

  my $el2 = $doc2->import_node ($el);
  isnt $el2, $el;
  is $el->owner_document, $doc1;
  is $el2->owner_document, $doc2;
  is $el->text_content, 'hoge';
  is $el2->text_content, '';
  is $el2->node_name, 'aaa';
  is $el2->get_attribute ('hoge'), 'baaaa';

  done $c;
} n => 7, name => 'element attr';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $el = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'aaa');
  my $el3 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'aaa');
  $el->append_child ($el3);
  $el3->text_content ('hoge');

  my $el2 = $doc2->import_node ($el, 1);
  isnt $el2, $el;
  is $el->owner_document, $doc1;
  is $el2->owner_document, $doc2;
  is $el->text_content, 'hoge';
  is $el2->text_content, 'hoge';
  is $el2->node_name, 'aaa';
  is $el2->first_child->node_name, 'aaa';

  done $c;
} n => 7, name => 'element deep';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $text = $doc1->create_text_node ('hoge');

  my $text2 = $doc2->import_node ($text);
  isnt $text2, $text;
  is $text->owner_document, $doc1;
  is $text2->owner_document, $doc2;
  is $text->text_content, 'hoge';
  is $text2->text_content, 'hoge';
  $text2->text_content ('fuga');
  is $text->text_content, 'hoge';
  is $text2->text_content, 'fuga';

  done $c;
} n => 7, name => 'text';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $attr = $doc1->create_attribute ('aaa');
  $attr->value ('hoge');

  my $attr2 = $doc2->import_node ($attr);
  isnt $attr2, $attr;
  isa_ok $attr2, 'Web::DOM::Attr';
  is $attr->owner_document, $doc1;
  is $attr2->owner_document, $doc2;
  is $attr->text_content, 'hoge';
  is $attr2->text_content, 'hoge';
  $attr2->text_content ('fuga');
  is $attr->text_content, 'hoge';
  is $attr2->text_content, 'fuga';

  done $c;
} n => 8, name => 'attr';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $attr = $doc1->create_attribute_ns ('aa', 'bb:aaa');
  $attr->value ('hoge');

  my $attr2 = $doc2->import_node ($attr);
  isnt $attr2, $attr;
  isa_ok $attr2, 'Web::DOM::Attr';
  is $attr->owner_document, $doc1;
  is $attr2->owner_document, $doc2;
  is $attr->text_content, 'hoge';
  is $attr2->text_content, 'hoge';
  $attr2->text_content ('fuga');
  is $attr->text_content, 'hoge';
  is $attr2->text_content, 'fuga';
  is $attr2->prefix, 'bb';
  is $attr2->namespace_uri, 'aa';
  is $attr2->local_name, 'aaa';

  done $c;
} n => 11, name => 'attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aaa');
  
  my $el2 = $doc->import_node ($el);
  isnt $el2, $el;
  isa_ok $el2, 'Web::DOM::Element';
  is $el2->node_name, 'aaa';

  done $c;
} n => 3, name => 'same document';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $el1 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'aaa');
  my $el2 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'aaa');
  $el1->append_child ($el2);
  
  my $el3 = $doc2->import_node ($el2);
  isnt $el3, $el2;
  is $el3->parent_node, undef;
  is $el2->parent_node, $el1;

  done $c;
} n => 3, name => 'parent';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $el1 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'aaa');
  my $el2 = $doc1->create_attribute ('aaa');
  $el1->set_attribute_node ($el2);
  
  my $el3 = $doc2->import_node ($el2);
  isnt $el3, $el2;
  is $el3->owner_element, undef;
  is $el2->owner_element, $el1;

  done $c;
} n => 3, name => 'owner element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  my $dt = $doc->implementation->create_document_type ('foo', '', '');
  my $pi = $doc->create_processing_instruction ('aa', 'hoge');
  $dt->append_child ($pi);
  $doc->dom_config->{manakai_allow_doctype_children} = 0;
  
  my $dt2 = $doc2->import_node ($dt, 1);
  is $dt2->child_nodes->length, 1;
  is $dt2->first_child->node_name, 'aa';
  is $dt2->first_child->data, 'hoge';

  ok $doc->strict_error_checking;
  ok $doc->dom_config->{manakai_strict_document_children};
  ok not $doc->dom_config->{manakai_allow_doctype_children};

  ok $doc2->strict_error_checking;
  ok $doc2->dom_config->{manakai_strict_document_children};
  ok not $doc2->dom_config->{manakai_allow_doctype_children};
  
  done $c;
} n => 9, name => 'strict document children not';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  my $dt = $doc->implementation->create_document_type ('foo', '', '');
  my $pi = $doc->create_processing_instruction ('aa', 'hoge');
  $dt->append_child ($pi);
  $doc->dom_config->{manakai_strict_document_children} = 0;
  $doc->strict_error_checking (0);
  
  my $dt2 = $doc2->import_node ($dt, 1);
  is $dt2->child_nodes->length, 1;
  is $dt2->first_child->node_name, 'aa';
  is $dt2->first_child->data, 'hoge';

  ok not $doc->strict_error_checking;
  ok not $doc->dom_config->{manakai_strict_document_children};
  ok $doc->dom_config->{manakai_allow_doctype_children};

  ok $doc2->strict_error_checking;
  ok $doc2->dom_config->{manakai_strict_document_children};
  ok not $doc2->dom_config->{manakai_allow_doctype_children};
  
  done $c;
} n => 9, name => 'strict document children not';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  my $dt = $doc->implementation->create_document_type ('foo', '', '');
  my $pi = $doc->create_processing_instruction ('aa', 'hoge');
  $dt->append_child ($pi);
  $doc2->dom_config->{manakai_allow_doctype_children} = 1;
  $doc2->dom_config->{manakai_strict_document_children} = 0;
  $doc2->strict_error_checking (0);
  
  my $dt2 = $doc2->import_node ($dt, 1);
  is $dt2->child_nodes->length, 1;
  is $dt2->first_child->node_name, 'aa';
  is $dt2->first_child->data, 'hoge';

  ok $doc->strict_error_checking;
  ok $doc->dom_config->{manakai_strict_document_children};
  ok $doc->dom_config->{manakai_allow_doctype_children};

  ok not $doc2->strict_error_checking;
  ok not $doc2->dom_config->{manakai_strict_document_children};
  ok $doc2->dom_config->{manakai_allow_doctype_children};
  
  done $c;
} n => 9, name => 'strict document children not';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', '4412');
  $doc->strict_error_checking (1);

  my $el2 = $doc2->import_node ($el);
  is $el2->node_type, $el2->ELEMENT_NODE;
  is $el2->prefix, undef;
  is $el2->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el2->local_name, '4412';

  ok $doc->strict_error_checking;
  ok $doc2->strict_error_checking;
  done $c;
} n => 6, name => 'strict_error_checking';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', '4412');

  my $el2 = $doc2->import_node ($el);
  is $el2->node_type, $el2->ELEMENT_NODE;
  is $el2->prefix, undef;
  is $el2->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el2->local_name, '4412';

  ok not $doc->strict_error_checking;
  ok $doc2->strict_error_checking;
  done $c;
} n => 6, name => 'strict_error_checking';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', '4412');
  $doc2->strict_error_checking (0);

  my $el2 = $doc2->import_node ($el);
  is $el2->node_type, $el2->ELEMENT_NODE;
  is $el2->prefix, undef;
  is $el2->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el2->local_name, '4412';

  ok not $doc->strict_error_checking;
  ok not $doc2->strict_error_checking;
  done $c;
} n => 6, name => 'strict_error_checking';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
