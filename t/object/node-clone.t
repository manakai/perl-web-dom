use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $clone = $doc->clone_node;
  isa_ok $clone, 'Web::DOM::Document';
  ok not $clone->isa ('Web::DOM::XMLDocument');
  isnt $clone, $doc;
  is $clone->node_type, $clone->DOCUMENT_NODE;
  ok not $clone->manakai_is_html;
  is $clone->manakai_compat_mode, 'no quirks';
  is $clone->child_nodes->length, 0;
  is $clone->content_type, 'application/xml';
  is $clone->url, 'about:blank';
  # original unique origin

  done $c;
} n => 9, name => 'document empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $clone = $doc->clone_node (1);
  isa_ok $clone, 'Web::DOM::Document';
  ok not $clone->isa ('Web::DOM::XMLDocument');
  isnt $clone, $doc;
  is $clone->node_type, $clone->DOCUMENT_NODE;
  ok not $clone->manakai_is_html;
  is $clone->manakai_compat_mode, 'no quirks';
  is $clone->child_nodes->length, 0;
  is $clone->content_type, 'application/xml';
  is $clone->url, 'about:blank';
  # original unique origin

  done $c;
} n => 9, name => 'document empty deep';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $doc->append_child ($el);

  my $clone = $doc->clone_node;
  isa_ok $clone, 'Web::DOM::Document';
  ok not $clone->isa ('Web::DOM::XMLDocument');
  isnt $clone, $doc;
  is $clone->node_type, $clone->DOCUMENT_NODE;
  ok not $clone->manakai_is_html;
  is $clone->manakai_compat_mode, 'no quirks';
  is $clone->child_nodes->length, 0;
  is $clone->content_type, 'application/xml';
  is $clone->url, 'about:blank';
  # original unique origin

  done $c;
} n => 9, name => 'document not empty not deep';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $doc->append_child ($el);

  my $clone = $doc->clone_node (1);
  isa_ok $clone, 'Web::DOM::Document';
  ok not $clone->isa ('Web::DOM::XMLDocument');
  isnt $clone, $doc;
  is $clone->node_type, $clone->DOCUMENT_NODE;
  ok not $clone->manakai_is_html;
  is $clone->manakai_compat_mode, 'no quirks';
  is $clone->child_nodes->length, 1;
  is $clone->content_type, 'application/xml';
  is $clone->url, 'about:blank';
  # original unique origin

  my $el2 = $clone->first_child;
  is $el2->tag_name, $el->tag_name;
  is $el2->first_child, undef;
  isnt $el2, $el;

  done $c;
} n => 12, name => 'document deep';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new->implementation->create_document;
  my $clone = $doc->clone_node;
  isa_ok $clone, 'Web::DOM::XMLDocument';
  is $clone->first_child, undef;
  ok not $clone->manakai_is_html;
  done $c;
} n => 3, name => 'xmldocument';

for my $compat_mode ('quirks', 'limited quirks', 'no quirks') {
  test {
    my $c = shift;
    my $doc = Web::DOM::Document->new;
    $doc->manakai_is_html (1);
    $doc->manakai_compat_mode ($compat_mode);

    my $clone = $doc->clone_node (1);
    isa_ok $clone, 'Web::DOM::Document';
    ok $clone->manakai_is_html;
    is $clone->content_type, 'text/html';
    is $clone->manakai_compat_mode, $compat_mode;

    done $c;
  } n => 4, name => ['htmldocument', $compat_mode];
}

for my $ct (qw(text/html application/xml application/rss+xml
               image/png image/svg+xml text/xml text/xsl)) {
  test {
    my $c = shift;
    my $d1 = new Web::DOM::Document;
    $d1->_set_content_type ($ct);

    my $d2 = $d1->clone_node;
    is $d2->content_type, $ct;

    done $c;
  } n => 1, name => ['document', 'content_type', $ct];
}

for my $ct (qw(utf-8 iso-2022-jp euc-jp windows-1252)) {
  test {
    my $c = shift;
    my $d1 = new Web::DOM::Document;
    $d1->input_encoding ($ct);

    my $d2 = $d1->clone_node;
    is $d2->character_set, $ct;

    done $c;
  } n => 1, name => ['document', 'character_set', $ct];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $el = $doc->create_element ('a');
  $df->append_child ($el);

  my $clone = $df->clone_node (0);
  isa_ok $clone, 'Web::DOM::DocumentFragment';
  is $clone->node_type, $clone->DOCUMENT_FRAGMENT_NODE;
  is $clone->first_child, undef;
  is $clone->owner_document, $doc;

  isnt $clone, $df;
  
  done $c;
} n => 5, name => 'document fragment';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $el = $doc->create_element ('a');
  $df->append_child ($el);
  my $el2 = $doc->create_element ('b');
  $el->append_child ($el2);

  my $clone = $df->clone_node (1);
  isa_ok $clone, 'Web::DOM::DocumentFragment';
  is $clone->node_type, $clone->DOCUMENT_FRAGMENT_NODE;
  is $clone->owner_document, $doc;

  is $clone->first_child->first_child->local_name, 'b';

  isnt $clone, $df;
  
  done $c;
} n => 5, name => 'document fragment with children';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('af', 'bb', 'cc');

  my $clone = $dt->clone_node (1);
  isa_ok $clone, 'Web::DOM::DocumentType';
  is $clone->node_type, $clone->DOCUMENT_TYPE_NODE;
  is $clone->name, 'af';
  is $clone->public_id, 'bb';
  is $clone->system_id, 'cc';
  is $clone->owner_document, $doc;
  
  done $c;
} n => 6, name => 'document type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $text = $doc->create_text_node ('aaa b');
  my $clone = $text->clone_node;
  isa_ok $clone, 'Web::DOM::Text';
  is $clone->node_type, $clone->TEXT_NODE;
  is $clone->data, 'aaa b';
  done $c;
} n => 3, name => 'text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $comment = $doc->create_comment ('aaa b');
  my $clone = $comment->clone_node;
  isa_ok $clone, 'Web::DOM::Comment';
  is $clone->node_type, $clone->COMMENT_NODE;
  is $clone->data, 'aaa b';
  done $c;
} n => 3, name => 'comment';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $pi = $doc->create_processing_instruction ('aa', 'aaa b');
  my $clone = $pi->clone_node;
  isa_ok $clone, 'Web::DOM::ProcessingInstruction';
  is $clone->node_type, $clone->PROCESSING_INSTRUCTION_NODE;
  is $clone->target, 'aa';
  is $clone->data, 'aaa b';
  done $c;
} n => 4, name => 'pi';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute_ns ('hoge', 'fuga:aAa');
  $attr->value ('aaabb');
  $attr->specified (0);
  
  my $clone = $attr->clone_node;
  isa_ok $clone, 'Web::DOM::Attr';
  is $clone->node_type, $clone->ATTRIBUTE_NODE;
  is $clone->prefix, 'fuga';
  is $clone->namespace_uri, 'hoge';
  is $clone->local_name, 'aAa';
  is $clone->value, 'aaabb';
  ok $clone->specified;
  is $clone->owner_element, undef;

  done $c;
} n => 8, name => 'attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('hoge', 'fuga:aAa');
  $el->text_content ('aaabb');
  
  my $clone = $el->clone_node;
  isa_ok $clone, 'Web::DOM::Element';
  is $clone->node_type, $clone->ELEMENT_NODE;
  is $clone->prefix, 'fuga';
  is $clone->namespace_uri, 'hoge';
  is $clone->local_name, 'aAa';
  is $clone->text_content, '';
  is $clone->parent_node, undef;

  done $c;
} n => 7, name => 'element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('hoge', 'fuga:aAa');
  $el->text_content ('aaabb');
  
  my $clone = $el->clone_node (1);
  isa_ok $clone, 'Web::DOM::Element';
  is $clone->node_type, $clone->ELEMENT_NODE;
  is $clone->prefix, 'fuga';
  is $clone->namespace_uri, 'hoge';
  is $clone->local_name, 'aAa';
  is $clone->text_content, 'aaabb';
  is $clone->parent_node, undef;

  done $c;
} n => 7, name => 'element deep';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('hoge', 'fuga:aAa');
  $el->text_content ('aaabb');
  $el->append_child ($doc->create_element ('fuga'));
  
  my $clone = $el->clone_node (1);
  isa_ok $clone, 'Web::DOM::Element';
  is $clone->node_type, $clone->ELEMENT_NODE;
  is $clone->prefix, 'fuga';
  is $clone->namespace_uri, 'hoge';
  is $clone->local_name, 'aAa';
  is $clone->text_content, 'aaabb';
  is $clone->child_nodes->length, 2;
  is $clone->last_child->local_name, 'fuga';
  is $clone->parent_node, undef;

  done $c;
} n => 9, name => 'element deep';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns
      ('http://www.w3.org/1999/xhtml', 'fuga:aAa');
  $el->text_content ('aaabb');
  
  my $clone = $el->clone_node (1);
  isa_ok $clone, 'Web::DOM::Element';
  is $clone->node_type, $clone->ELEMENT_NODE;
  is $clone->prefix, 'fuga';
  is $clone->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $clone->local_name, 'aAa';
  is $clone->text_content, 'aaabb';
  is $clone->parent_node, undef;

  done $c;
} n => 7, name => 'element html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns
      ('http://www.w3.org/1999/xhtml', 'fuga:aAa');
  $el->text_content ('aaabb');
  $el->set_attribute (hoge => 'fuga');
  $el->set_attribute_ns ('aaa', hoge => 'fuga2');
  
  my $clone = $el->clone_node (1);
  isa_ok $clone, 'Web::DOM::Element';
  is $clone->node_type, $clone->ELEMENT_NODE;
  is $clone->prefix, 'fuga';
  is $clone->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $clone->local_name, 'aAa';
  is $clone->text_content, 'aaabb';
  is $clone->parent_node, undef;
  is $clone->get_attribute_ns (undef, 'hoge'), 'fuga';
  is $clone->get_attribute_ns ('aaa', 'hoge'), 'fuga2';

  done $c;
} n => 9, name => 'element html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  $el1->append_child ($el2);

  my $el3 = $el2->clone_node (1);
  isnt $el3, $el2;
  is $el3->parent_node, undef;
  is $el2->parent_node, $el1;

  done $c;
} n => 3, name => 'parent_node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_attribute ('a');
  $el1->set_attribute_node ($el2);

  my $el3 = $el2->clone_node (1);
  isnt $el3, $el2;
  is $el3->owner_element, undef;
  is $el2->owner_element, $el1;

  done $c;
} n => 3, name => 'owner_element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;
  my $node = $doc->create_text_node ('hoge');
  $doc->append_child ($node);
  $doc->dom_config->{manakai_strict_document_children} = 1;
  
  my $doc2 = $doc->clone_node (1);
  is $doc2->child_nodes->length, 1;
  is $doc2->first_child->data, 'hoge';
  ok $doc2->strict_error_checking;
  ok $doc2->dom_config->{manakai_strict_document_children};
  ok not $doc2->dom_config->{manakai_allow_doctype_children};

  ok $doc->strict_error_checking;
  ok $doc->dom_config->{manakai_strict_document_children};
  ok not $doc->dom_config->{manakai_allow_doctype_children};
  
  done $c;
} n => 8, name => 'strict document children not';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;
  my $node = $doc->create_text_node ('hoge');
  $doc->append_child ($node);
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  $doc->strict_error_checking (0);
  
  my $doc2 = $doc->clone_node (1);
  is $doc2->child_nodes->length, 1;
  is $doc2->first_child->data, 'hoge';
  ok $doc2->strict_error_checking;
  ok $doc2->dom_config->{manakai_strict_document_children};
  ok not $doc2->dom_config->{manakai_allow_doctype_children};

  ok not $doc->strict_error_checking;
  ok not $doc->dom_config->{manakai_strict_document_children};
  ok $doc->dom_config->{manakai_allow_doctype_children};
  
  done $c;
} n => 8, name => 'strict document children not';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  my $dt = $doc->implementation->create_document_type ('foo', '', '');
  my $pi = $doc->create_processing_instruction ('aa', 'hoge');
  $dt->append_child ($pi);
  $doc->dom_config->{manakai_allow_doctype_children} = 0;
  
  my $dt2 = $dt->clone_node (1);
  is $dt2->child_nodes->length, 1;
  is $dt2->first_child->node_name, 'aa';
  is $dt2->first_child->data, 'hoge';

  ok $doc->strict_error_checking;
  ok $doc->dom_config->{manakai_strict_document_children};
  ok not $doc->dom_config->{manakai_allow_doctype_children};
  
  done $c;
} n => 6, name => 'strict document children not';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  my $dt = $doc->implementation->create_document_type ('foo', '', '');
  my $pi = $doc->create_processing_instruction ('aa', 'hoge');
  $dt->append_child ($pi);
  $doc->dom_config->{manakai_strict_document_children} = 0;
  $doc->strict_error_checking (0);
  
  my $dt2 = $dt->clone_node (1);
  is $dt2->child_nodes->length, 1;
  is $dt2->first_child->node_name, 'aa';
  is $dt2->first_child->data, 'hoge';

  ok not $doc->strict_error_checking;
  ok not $doc->dom_config->{manakai_strict_document_children};
  ok $doc->dom_config->{manakai_allow_doctype_children};
  
  done $c;
} n => 6, name => 'strict document children not';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $el = $doc->create_element ('4412');
  $doc->strict_error_checking (1);

  my $el2 = $el->clone_node;
  is $el2->node_type, $el2->ELEMENT_NODE;
  is $el2->prefix, undef;
  is $el2->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el2->local_name, '4412';

  ok $doc->strict_error_checking;
  done $c;
} n => 5, name => 'strict_error_checking';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $el = $doc->create_element ('4412');

  my $el2 = $el->clone_node;
  is $el2->node_type, $el2->ELEMENT_NODE;
  is $el2->prefix, undef;
  is $el2->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el2->local_name, '4412';

  ok not $doc->strict_error_checking;
  done $c;
} n => 5, name => 'strict_error_checking';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ent = $doc->create_general_entity ('hoge');
  $ent->public_id ('foo');
  $ent->system_id ('bar');
  $ent->notation_name ('hoge1');
  $ent->node_value ('ab d');

  my $ent2 = $ent->clone_node;
  isa_ok $ent2, 'Web::DOM::Entity';
  is $ent2->node_name, 'hoge';
  is $ent2->public_id, 'foo';
  is $ent2->system_id, 'bar';
  is $ent2->notation_name, 'hoge1';
  is $ent2->node_value, 'ab d';

  done $c;
} n => 6, name => 'entity';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ent = $doc->create_notation ('hoge');
  $ent->public_id ('foo');
  $ent->system_id ('bar');

  my $ent2 = $ent->clone_node;
  isa_ok $ent2, 'Web::DOM::Notation';
  is $ent2->node_name, 'hoge';
  is $ent2->public_id, 'foo';
  is $ent2->system_id, 'bar';

  done $c;
} n => 4, name => 'notation';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $adef = $doc->create_attribute_definition ('hoge');
  $adef->declared_type (4);
  $adef->default_type (55);
  push @{$adef->allowed_tokens}, 'hoge', 'aab';
  $adef->node_value ('ab c');

  my $adef2 = $adef->clone_node;
  isa_ok $adef2, 'Web::DOM::AttributeDefinition';
  is $adef2->node_name, 'hoge';
  is $adef2->declared_type, 4;
  is $adef2->default_type, 55;
  is_deeply $adef2->allowed_tokens, ['hoge', 'aab'];
  isnt $adef2->allowed_tokens, $adef->allowed_tokens;
  is $adef2->node_value, 'ab c';

  done $c;
} n => 7, name => 'attribute_definition';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $et = $doc->create_element_type_definition ('hoge');

  my $et2 = $et->clone_node;
  isa_ok $et2, 'Web::DOM::ElementTypeDefinition';
  is $et2->node_name, 'hoge';
  is scalar @{$et2->attribute_definitions}, 0;

  done $c;
} n => 3, name => 'element_type empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $et = $doc->create_element_type_definition ('hoge');
  my $adef = $doc->create_attribute_definition ('hoge');
  $adef->declared_type (4);
  $adef->default_type (55);
  push @{$adef->allowed_tokens}, 'hoge', 'aab';
  $adef->node_value ('ab c');
  $et->set_attribute_definition_node ($adef);

  my $et2 = $et->clone_node;
  isnt $et2, $et;
  isa_ok $et2, 'Web::DOM::ElementTypeDefinition';
  is $et2->node_name, 'hoge';
  is scalar @{$et2->attribute_definitions}, 1;

  my $adef2 = $et2->attribute_definitions->[0];
  isnt $adef2, $adef;
  isa_ok $adef2, 'Web::DOM::AttributeDefinition';
  is $adef2->node_name, 'hoge';
  is $adef2->declared_type, 4;
  is $adef2->default_type, 55;
  is_deeply $adef2->allowed_tokens, ['hoge', 'aab'];
  isnt $adef2->allowed_tokens, $adef->allowed_tokens;
  is $adef2->node_value, 'ab c';

  done $c;
} n => 12, name => 'element_type non-empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('aa');

  my $ent = $doc->create_general_entity ('hoge1');
  $ent->public_id ('foo1');
  $ent->system_id ('bar1');
  $ent->notation_name ('hoge11');
  $ent->node_value ('ab d1');

  my $not = $doc->create_notation ('hoge2');
  $not->public_id ('foo2');
  $not->system_id ('bar2');

  my $et = $doc->create_element_type_definition ('hoge3');
  my $adef = $doc->create_attribute_definition ('hoge4');
  $adef->declared_type (4);
  $adef->default_type (55);
  push @{$adef->allowed_tokens}, 'hoge', 'aab';
  $adef->node_value ('ab c');
  $et->set_attribute_definition_node ($adef);

  my $pi = $doc->create_processing_instruction ('bb', 'cc');

  $dt->set_element_type_definition_node ($et);
  $dt->set_general_entity_node ($ent);
  $dt->set_notation_node ($not);
  {
    local $doc->dom_config->{manakai_allow_doctype_children} = 1;
    $dt->append_child ($pi);
  }

  my $dt2 = $dt->clone_node;
  isnt $dt2, $dt;
  isa_ok $dt2, 'Web::DOM::DocumentType';
  is $dt2->child_nodes->length, 0;

  my $et2 = $dt2->element_types->[0];
  isnt $et2, $et;
  isa_ok $et2, 'Web::DOM::ElementTypeDefinition';
  is $et2->node_name, 'hoge3';
  is scalar @{$et2->attribute_definitions}, 1;

  my $adef2 = $et2->attribute_definitions->[0];
  isnt $adef2, $adef;
  isa_ok $adef2, 'Web::DOM::AttributeDefinition';
  is $adef2->node_name, 'hoge4';
  is $adef2->declared_type, 4;
  is $adef2->default_type, 55;
  is_deeply $adef2->allowed_tokens, ['hoge', 'aab'];
  isnt $adef2->allowed_tokens, $adef->allowed_tokens, 'copied allowed_tokens';
  is $adef2->node_value, 'ab c';

  my $ent2 = $dt2->general_entities->[0];
  isnt $ent2, $ent;
  isa_ok $ent2, 'Web::DOM::Entity';
  is $ent2->node_name, 'hoge1';
  is $ent2->public_id, 'foo1';
  is $ent2->system_id, 'bar1';
  is $ent2->notation_name, 'hoge11';
  is $ent2->node_value, 'ab d1';

  my $not2 = $dt2->notations->[0];
  isnt $not2, $not;
  isa_ok $not2, 'Web::DOM::Notation';
  is $not2->node_name, 'hoge2';
  is $not2->public_id, 'foo2';
  is $not2->system_id, 'bar2';

  done $c;
} n => 27, name => 'document type';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
