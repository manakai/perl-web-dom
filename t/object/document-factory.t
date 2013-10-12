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
  my $doc = new Web::DOM::Document;

  my $df = $doc->create_document_fragment;
  isa_ok $df, 'Web::DOM::DocumentFragment';
  is $df->node_type, $df->DOCUMENT_FRAGMENT_NODE;
  is $df->first_child, undef;
  is $df->owner_document, $doc;

  my $df2 = $doc->create_document_fragment;
  isnt $df2, $df;
  done $c;
} n => 5, name => 'create_document_fragment';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $text = $doc->create_text_node ('hoge');
  isa_ok $text, 'Web::DOM::Text';
  is $text->node_type, $text->TEXT_NODE;
  is $text->data, 'hoge';
  is $text->owner_document, $doc;
  done $c;
} n => 4, name => 'create_text_node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $text = $doc->create_text_node (\'hoge');
  isa_ok $text, 'Web::DOM::Text';
  is $text->node_type, $text->TEXT_NODE;
  is $text->data, 'hoge';
  is $text->owner_document, $doc;
  done $c;
} n => 4, name => 'create_text_node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $text = $doc->create_text_node;
  isa_ok $text, 'Web::DOM::Text';
  is $text->node_type, $text->TEXT_NODE;
  is $text->data, '';
  is $text->owner_document, $doc;
  done $c;
} n => 4, name => 'create_text_node undef';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $comment = $doc->create_comment ('hoge');
  isa_ok $comment, 'Web::DOM::Comment';
  is $comment->node_type, $comment->COMMENT_NODE;
  is $comment->data, 'hoge';
  is $comment->owner_document, $doc;
  done $c;
} n => 4, name => 'create_comment';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $comment = $doc->create_comment (\'hoge');
  isa_ok $comment, 'Web::DOM::Comment';
  is $comment->node_type, $comment->COMMENT_NODE;
  is $comment->data, 'hoge';
  is $comment->owner_document, $doc;
  done $c;
} n => 4, name => 'create_comment';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $comment = $doc->create_comment;
  isa_ok $comment, 'Web::DOM::Comment';
  is $comment->node_type, $comment->COMMENT_NODE;
  is $comment->data, '';
  is $comment->owner_document, $doc;
  done $c;
} n => 4, name => 'create_comment undef';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $pi = $doc->create_processing_instruction ('hoge', 'fuga');
  isa_ok $pi, 'Web::DOM::ProcessingInstruction';
  is $pi->node_type, $pi->PROCESSING_INSTRUCTION_NODE;
  is $pi->target, 'hoge';
  is $pi->data, 'fuga';
  done $c;
} n => 4, name => 'create_processing_instruction';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $pi = $doc->create_processing_instruction ('xml', 'fuga');
  isa_ok $pi, 'Web::DOM::ProcessingInstruction';
  is $pi->node_type, $pi->PROCESSING_INSTRUCTION_NODE;
  is $pi->target, 'xml';
  is $pi->data, 'fuga';
  done $c;
} n => 4, name => 'create_processing_instruction xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $pi = $doc->create_processing_instruction ('aaa', '');
  isa_ok $pi, 'Web::DOM::ProcessingInstruction';
  is $pi->node_type, $pi->PROCESSING_INSTRUCTION_NODE;
  is $pi->target, 'aaa';
  is $pi->data, '';
  done $c;
} n => 4, name => 'create_processing_instruction empty value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $pi = $doc->create_processing_instruction ('aaa');
  isa_ok $pi, 'Web::DOM::ProcessingInstruction';
  is $pi->node_type, $pi->PROCESSING_INSTRUCTION_NODE;
  is $pi->target, 'aaa';
  is $pi->data, '';
  done $c;
} n => 4, name => 'create_processing_instruction undef value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $pi = $doc->create_processing_instruction ('xml:hoge', 'fuga');
  isa_ok $pi, 'Web::DOM::ProcessingInstruction';
  is $pi->node_type, $pi->PROCESSING_INSTRUCTION_NODE;
  is $pi->target, 'xml:hoge';
  is $pi->data, 'fuga';
  done $c;
} n => 4, name => 'create_processing_instruction not ncname';

for my $name (
  undef, '', '1353', "\x00aa", "\x{FFFE}",
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    dies_here_ok {
      $doc->create_processing_instruction ($name, 'fuga');
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'InvalidCharacterError';
    is $@->message, 'The target is not an XML Name';
    done $c;
  } n => 4, name => ['create_processing_instruction not xml Name', $name];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_processing_instruction ('hoge120', 'a?>b');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The data cannot contain ?>';
  done $c;
} n => 4, name => 'create_processing_instruction bad data';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_processing_instruction;
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The target is not an XML Name';
  done $c;
} n => 4, name => 'create_processing_instruction undef';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  dies_here_ok {
    $doc->create_processing_instruction ('', 'aa');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The target is not an XML Name';
  done $c;
} n => 4, name => 'create_processing_instruction not strict empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $pi = $doc->create_processing_instruction ('0123', 'foo');
  is $pi->node_type, $pi->PROCESSING_INSTRUCTION_NODE;
  is $pi->node_name, '0123';
  is $pi->data, 'foo';
  done $c;
} n => 3, name => 'create_processing_instruction not strict not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $pi = $doc->create_processing_instruction ('abc', 'fo?>o');
  is $pi->node_type, $pi->PROCESSING_INSTRUCTION_NODE;
  is $pi->node_name, 'abc';
  is $pi->data, 'fo?>o';
  done $c;
} n => 3, name => 'create_processing_instruction not strict ?>';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  dies_here_ok {
    $doc->create_cdata_section ("a");
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotSupportedError';
  is $@->message, 'CDATASection is obsolete';
  
  done $c;
} n => 4, name => 'create_cdata_section';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  dies_here_ok {
    $doc->create_entity_reference ("a");
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotSupportedError';
  is $@->message, 'EntityReference is obsolete';
  
  done $c;
} n => 4, name => 'create_entity_reference';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('hoge');
  isa_ok $dt, 'Web::DOM::DocumentType';
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->node_name, 'hoge';
  is $dt->name, 'hoge';
  is $dt->public_id, '';
  is $dt->system_id, '';
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document, $doc;
  done $c;
} n => 9, name => 'create_document_type_definition';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition (':hoge');
  isa_ok $dt, 'Web::DOM::DocumentType';
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->node_name, ':hoge';
  is $dt->name, ':hoge';
  is $dt->public_id, '';
  is $dt->system_id, '';
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document, $doc;
  done $c;
} n => 9, name => 'create_document_type_definition not qname';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $dt = $doc->create_document_type_definition ('120hoge');
  isa_ok $dt, 'Web::DOM::DocumentType';
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->node_name, '120hoge';
  is $dt->name, '120hoge';
  is $dt->public_id, '';
  is $dt->system_id, '';
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document, $doc;
  done $c;
} n => 9, name => 'create_document_type_definition not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $dt = $doc->create_document_type_definition ('');
  isa_ok $dt, 'Web::DOM::DocumentType';
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->node_name, '';
  is $dt->name, '';
  is $dt->public_id, '';
  is $dt->system_id, '';
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document, $doc;
  done $c;
} n => 9, name => 'create_document_type_definition not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_document_type_definition ('');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_document_type_definition not name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_document_type_definition ('120hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_document_type_definition not name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_general_entity ('hoge');
  isa_ok $dt, 'Web::DOM::Entity';
  is $dt->node_type, $dt->ENTITY_NODE;
  is $dt->node_name, 'hoge';
  is $dt->public_id, '';
  is $dt->system_id, '';
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document_type_definition, undef;
  is $dt->owner_document, $doc;
  done $c;
} n => 9, name => 'create_general_entity';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_general_entity (':hoge');
  isa_ok $dt, 'Web::DOM::Entity';
  is $dt->node_type, $dt->ENTITY_NODE;
  is $dt->node_name, ':hoge';
  is $dt->public_id, '';
  is $dt->system_id, '';
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document_type_definition, undef;
  is $dt->owner_document, $doc;
  done $c;
} n => 9, name => 'create_general_entity not qname';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $dt = $doc->create_general_entity ('120hoge');
  isa_ok $dt, 'Web::DOM::Entity';
  is $dt->node_type, $dt->ENTITY_NODE;
  is $dt->node_name, '120hoge';
  is $dt->public_id, '';
  is $dt->system_id, '';
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document_type_definition, undef;
  is $dt->owner_document, $doc;
  done $c;
} n => 9, name => 'create_general_entity not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $dt = $doc->create_general_entity ('');
  isa_ok $dt, 'Web::DOM::Entity';
  is $dt->node_type, $dt->ENTITY_NODE;
  is $dt->node_name, '';
  is $dt->public_id, '';
  is $dt->system_id, '';
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document_type_definition, undef;
  is $dt->owner_document, $doc;
  done $c;
} n => 9, name => 'create_general_entity not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_general_entity ('');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_general_entity not name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_general_entity ('120hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_general_entity not name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_notation ('hoge');
  isa_ok $dt, 'Web::DOM::Notation';
  is $dt->node_type, $dt->NOTATION_NODE;
  is $dt->node_name, 'hoge';
  is $dt->public_id, '';
  is $dt->system_id, '';
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document_type_definition, undef;
  is $dt->owner_document, $doc;
  done $c;
} n => 9, name => 'create_notation';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_notation (':hoge');
  isa_ok $dt, 'Web::DOM::Notation';
  is $dt->node_type, $dt->NOTATION_NODE;
  is $dt->node_name, ':hoge';
  is $dt->public_id, '';
  is $dt->system_id, '';
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document, $doc;
  is $dt->owner_document_type_definition, undef;
  done $c;
} n => 9, name => 'create_notation not qname';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $dt = $doc->create_notation ('120hoge');
  isa_ok $dt, 'Web::DOM::Notation';
  is $dt->node_type, $dt->NOTATION_NODE;
  is $dt->node_name, '120hoge';
  is $dt->public_id, '';
  is $dt->system_id, '';
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document, $doc;
  is $dt->owner_document_type_definition, undef;
  done $c;
} n => 9, name => 'create_notation not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $dt = $doc->create_notation ('');
  isa_ok $dt, 'Web::DOM::Notation';
  is $dt->node_type, $dt->NOTATION_NODE;
  is $dt->node_name, '';
  is $dt->public_id, '';
  is $dt->system_id, '';
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document, $doc;
  is $dt->owner_document_type_definition, undef;
  done $c;
} n => 9, name => 'create_notation not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_notation ('');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_notation not name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_notation ('120hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_notation not name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_element_type_definition ('hoge');
  isa_ok $dt, 'Web::DOM::ElementTypeDefinition';
  is $dt->node_type, $dt->ELEMENT_TYPE_DEFINITION_NODE;
  is $dt->node_name, 'hoge';
  is $dt->attribute_definitions->length, 0;
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document_type_definition, undef;
  is $dt->owner_document, $doc;
  done $c;
} n => 8, name => 'create_element_type_definition';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_element_type_definition (':hoge');
  isa_ok $dt, 'Web::DOM::ElementTypeDefinition';
  is $dt->node_type, $dt->ELEMENT_TYPE_DEFINITION_NODE;
  is $dt->node_name, ':hoge';
  is $dt->attribute_definitions->length, 0;
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document, $doc;
  is $dt->owner_document_type_definition, undef;
  done $c;
} n => 8, name => 'create_element_type_definition not qname';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $dt = $doc->create_element_type_definition ('120hoge');
  isa_ok $dt, 'Web::DOM::ElementTypeDefinition';
  is $dt->node_type, $dt->ELEMENT_TYPE_DEFINITION_NODE;
  is $dt->node_name, '120hoge';
  is $dt->attribute_definitions->length, 0;
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document, $doc;
  is $dt->owner_document_type_definition, undef;
  done $c;
} n => 8, name => 'create_element_type_definition not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $dt = $doc->create_element_type_definition ('');
  isa_ok $dt, 'Web::DOM::ElementTypeDefinition';
  is $dt->node_type, $dt->ELEMENT_TYPE_DEFINITION_NODE;
  is $dt->node_name, '';
  is $dt->attribute_definitions->length, 0;
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document, $doc;
  is $dt->owner_document_type_definition, undef;
  done $c;
} n => 8, name => 'create_element_type_definition not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_type_definition ('');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_element_type_definition not name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_type_definition ('120hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_element_type_definition not name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_attribute_definition ('hoge');
  isa_ok $dt, 'Web::DOM::AttributeDefinition';
  is $dt->node_type, $dt->ATTRIBUTE_DEFINITION_NODE;
  is $dt->node_name, 'hoge';
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_element_type_definition, undef;
  is $dt->owner_document, $doc;
  is $dt->node_value, '';
  is $dt->declared_type, $dt->NO_TYPE_ATTR;
  is $dt->default_type, $dt->UNKNOWN_DEFAULT;
  is scalar @{$dt->allowed_tokens}, 0;
  done $c;
} n => 11, name => 'create_attribute_definition';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_attribute_definition (':hoge');
  isa_ok $dt, 'Web::DOM::AttributeDefinition';
  is $dt->node_type, $dt->ATTRIBUTE_DEFINITION_NODE;
  is $dt->node_name, ':hoge';
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document, $doc;
  is $dt->owner_element_type_definition, undef;
  is $dt->node_value, '';
  is $dt->declared_type, $dt->NO_TYPE_ATTR;
  is $dt->default_type, $dt->UNKNOWN_DEFAULT;
  is scalar @{$dt->allowed_tokens}, 0;
  done $c;
} n => 11, name => 'create_attribute_definition not qname';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $dt = $doc->create_attribute_definition ('120hoge');
  isa_ok $dt, 'Web::DOM::AttributeDefinition';
  is $dt->node_type, $dt->ATTRIBUTE_DEFINITION_NODE;
  is $dt->node_name, '120hoge';
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document, $doc;
  is $dt->owner_element_type_definition, undef;
  is $dt->node_value, '';
  is $dt->declared_type, $dt->NO_TYPE_ATTR;
  is $dt->default_type, $dt->UNKNOWN_DEFAULT;
  is scalar @{$dt->allowed_tokens}, 0;
  done $c;
} n => 11, name => 'create_attribute_definition not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $dt = $doc->create_attribute_definition ('');
  isa_ok $dt, 'Web::DOM::AttributeDefinition';
  is $dt->node_type, $dt->ATTRIBUTE_DEFINITION_NODE;
  is $dt->node_name, '';
  is $dt->child_nodes->length, 0;
  is $dt->parent_node, undef;
  is $dt->owner_document, $doc;
  is $dt->owner_element_type_definition, undef;
  is $dt->node_value, '';
  is $dt->declared_type, $dt->NO_TYPE_ATTR;
  is $dt->default_type, $dt->UNKNOWN_DEFAULT;
  is scalar @{$dt->allowed_tokens}, 0;
  done $c;
} n => 11, name => 'create_attribute_definition not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_attribute_definition ('');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_attribute_definition not name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_attribute_definition ('120hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_attribute_definition not name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $view = bless {}, 'Web::DOM::WindowProxy';
  my $target = $doc->create_text_node ('');
  my $touch = $doc->create_touch
      ($view, $target, 1+2**32, 2+2**32, 3+2**32, 4+2**32, 5+2**32);
  isa_ok $touch, 'Web::DOM::Touch';
  is $touch->target, $target;
  is $touch->identifier, 1;
  is $touch->page_x, 2;
  is $touch->page_y, 3;
  is $touch->screen_x, 4;
  is $touch->screen_y, 5;
  is $touch->client_x, 0;
  is $touch->client_y, 0;
  done $c;
} n => 9, name => 'create_touch';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $view = bless {}, 'Web::DOM::WindowProxy';
  dies_here_ok {
    $doc->create_touch ($view);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not an EventTarget';
  done $c;
} n => 3, name => 'create_touch bad target';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_touch ('aa', $doc);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The first argument is not a WindowProxy';
  done $c;
} n => 3, name => 'create_touch bad view';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $tl = $doc->create_touch_list;
  isa_ok $tl, 'Web::DOM::TouchList';
  is $tl->length, 0;
  done $c;
} n => 2, name => 'create_touch_list empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $view = bless {}, 'Web::DOM::WindowProxy';
  my $target = $doc->create_text_node ('');
  my $t1 = $doc->create_touch ($view, $target, 1, 2, 3, 4, 5);
  my $t2 = $doc->create_touch ($view, $target, 6, 7, 8, 9, 10);
  my $tl = $doc->create_touch_list ($t1, $t2, $t1);
  isa_ok $tl, 'Web::DOM::TouchList';
  is $tl->length, 3;
  is $tl->[0], $t1;
  is $tl->[1], $t2;
  is $tl->[2], $t1;
  done $c;
} n => 5, name => 'create_touch_list';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $view = bless {}, 'Web::DOM::WindowProxy';
  my $target = $doc->create_text_node ('');
  my $t1 = $doc->create_touch ($view, $target, 1, 2, 3, 4, 5);
  my $t2 = $doc->create_touch ($view, $target, 6, 7, 8, 9, 10);
  dies_here_ok {
    $doc->create_touch_list ($t1, 'abc', $t2);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'An argument is not a Touch';
  done $c;
} n => 3, name => 'create_touch_list bad args';

run_tests;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
