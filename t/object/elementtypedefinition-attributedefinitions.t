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
  my $dt = $doc->create_document_type_definition ('a');
  my $et = $doc->create_element_type_definition ('a');
  my $col = $et->attribute_definitions;
  isa_ok $col, 'Web::DOM::NamedNodeMap';
  is $col->length, 0;
  is scalar @$col, 0;
  is $et->get_attribute_definition_node ('hoge'), undef;
  done $c;
} n => 4, name => 'empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('a');
  my $node = $doc->create_attribute_definition ('foo');
  my $et = $doc->create_element_type_definition ('a');
  my $node2 = $et->set_attribute_definition_node ($node);
  is $node2, undef;
  is $node->owner_element_type_definition, $et;
  is $et->attribute_definitions->length, 1;
  is $et->attribute_definitions->[0], $node;

  is $$et->[0]->{tree_id}->[$$et->[1]],
      $$node->[0]->{tree_id}->[$$node->[1]];

  done $c;
} n => 5, name => 'set_attribute_definition_node new';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('a');
  my $node0 = $doc->create_attribute_definition ('foo');
  my $et = $doc->create_element_type_definition ('a');
  $et->set_attribute_definition_node ($node0);

  my $node = $doc->create_attribute_definition ('foo');
  my $node2 = $et->set_attribute_definition_node ($node);
  is $node2, $node0;
  is $node2->owner_element_type_definition, undef;
  is $node->owner_element_type_definition, $et;
  is $et->attribute_definitions->length, 1;
  is $et->attribute_definitions->[0], $node;

  is $$et->[0]->{tree_id}->[$$et->[1]],
      $$node->[0]->{tree_id}->[$$node->[1]];
  isnt $$et->[0]->{tree_id}->[$$et->[1]],
      $$node0->[0]->{tree_id}->[$$node0->[1]];

  done $c;
} n => 7, name => 'set_attribute_definition_node change';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('a');
  my $node = $doc->create_attribute_definition ('foo');
  my $et = $doc->create_element_type_definition ('a');
  $et->set_attribute_definition_node ($node);

  my $node2 = $et->set_attribute_definition_node ($node);
  is $node2, $node;
  is $node->owner_element_type_definition, $et;
  is $et->attribute_definitions->length, 1;
  is $et->attribute_definitions->[0], $node;

  is $$et->[0]->{tree_id}->[$$et->[1]],
      $$node->[0]->{tree_id}->[$$node->[1]];

  done $c;
} n => 5, name => 'set_attribute_definition_node same';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt1 = $doc->create_document_type_definition ('a');
  my $dt2 = $doc->create_document_type_definition ('a');
  my $node = $doc->create_attribute_definition ('foo');
  my $et1 = $doc->create_element_type_definition ('a');
  my $et2 = $doc->create_element_type_definition ('a');
  $et1->set_attribute_definition_node ($node);

  dies_here_ok {
    $et2->set_attribute_definition_node ($node);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The specified node has already attached to another node';
  is $node->owner_element_type_definition, $et1;
  is $et1->attribute_definitions->length, 1;
  is $et2->attribute_definitions->length, 0;

  is $$et1->[0]->{tree_id}->[$$et1->[1]],
      $$node->[0]->{tree_id}->[$$node->[1]];

  done $c;
} n => 8, name => 'set_attribute_definition_node inuse';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $dt1 = $doc1->create_document_type_definition ('a');
  my $dt2 = $doc2->create_document_type_definition ('a');
  my $et1 = $doc1->create_element_type_definition ('a');
  my $et2 = $doc2->create_element_type_definition ('a');
  my $node = $doc1->create_attribute_definition ('foo');
  $et1->set_attribute_definition_node ($node);

  dies_here_ok {
    $et2->set_attribute_definition_node ($node);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The specified node has already attached to another node';
  is $node->owner_element_type_definition, $et1;
  is $et1->attribute_definitions->length, 1;
  is $et2->attribute_definitions->length, 0;

  is $$et1->[0]->{tree_id}->[$$et1->[1]],
      $$node->[0]->{tree_id}->[$$node->[1]];

  done $c;
} n => 8, name => 'set_attribute_definition_node inuse another document';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $dt = $doc1->create_document_type_definition ('a');
  my $node = $doc2->create_attribute_definition ('foo');

  my $et = $doc1->create_element_type_definition ('a');
  my $node2 = $et->set_attribute_definition_node ($node);
  is $node2, undef;
  is $node->owner_element_type_definition, $et;
  is $et->attribute_definitions->length, 1;
  is $et->attribute_definitions->[0], $node;
  is $node->owner_document, $doc1;

  is $$et->[0], $$node->[0];
  isnt $$node->[0], $$doc2->[0];
  is $$et->[0]->{tree_id}->[$$et->[1]],
      $$node->[0]->{tree_id}->[$$node->[1]];

  done $c;
} n => 8, name => 'set_attribute_definition_node adopt';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('a');
  my $et = $doc->create_element_type_definition ('a');
  dies_here_ok {
    $et->set_attribute_definition_node (undef);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->name, 'TypeError';
  is $@->message, 'The argument is not an AttributeDefinition';
  is $et->attribute_definitions->length, 0;
  done $c;
} n => 5, name => 'set_attribute_definition_node not node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('a');
  my $et = $doc->create_element_type_definition ('a');
  my $node = $doc->create_element ('foo');
  dies_here_ok {
    $et->set_attribute_definition_node ($node);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->name, 'TypeError';
  is $@->message, 'The argument is not an AttributeDefinition';
  is $et->attribute_definitions->length, 0;
  done $c;
} n => 5, name => 'set_attribute_definition_node different node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('a');
  my $et = $doc->create_element_type_definition ('a');
  my $node = $doc->create_attribute_definition ('hoi');
  my $node2 = $doc->create_attribute_definition ('hoi');
  $et->set_attribute_definition_node ($node);
  my $called;
  $node->set_user_data (destroy => bless sub {
                          $called = 1;
                        }, 'test::DestroyCallback');
  undef $node;
  ok not $called;
  
  $et->set_attribute_definition_node ($node2);
  ok $called;
  
  done $c;
} n => 2, name => 'set_attribute_definition_node destroy';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('a');
  my $et = $doc->create_element_type_definition ('a');
  my $node = $doc->create_attribute_definition ('hoi');
  $et->set_attribute_definition_node ($node);
  
  my $node2 = $et->remove_attribute_definition_node ($node);
  is $node2, $node;
  is $node->owner_element_type_definition, undef;
  is $et->attribute_definitions->length, 0;
  
  isnt $$et->[0]->{tree_id}->[$$et->[1]],
      $$node->[0]->{tree_id}->[$$node->[1]];

  done $c;
} n => 4, name => 'remove_attribute_definition_node removed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('a');
  my $et = $doc->create_element_type_definition ('a');
  my $node = $doc->create_attribute_definition ('hoi');

  dies_here_ok {
    $et->remove_attribute_definition_node ($node);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'The specified node is not attached to the context object';
  is $node->owner_element_type_definition, undef;
  is $et->attribute_definitions->length, 0;
  
  isnt $$et->[0]->{tree_id}->[$$et->[1]],
      $$node->[0]->{tree_id}->[$$node->[1]];

  done $c;
} n => 7, name => 'remove_attribute_definition_node not found';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('a');
  my $et = $doc->create_element_type_definition ('a');
  my $node = $doc2->create_attribute_definition ('hoi');

  dies_here_ok {
    $et->remove_attribute_definition_node ($node);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'The specified node is not attached to the context object';
  is $node->owner_element_type_definition, undef;
  is $et->attribute_definitions->length, 0;
  
  isnt $$et->[0], $$node->[0];

  done $c;
} n => 7, name => 'remove_attribute_definition_node not found different document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('a');
  my $et = $doc->create_element_type_definition ('a');
  dies_here_ok {
    $et->remove_attribute_definition_node (undef);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->name, 'TypeError';
  is $@->message, 'The argument is not an AttributeDefinition';
  is $et->attribute_definitions->length, 0;
  done $c;
} n => 5, name => 'remove_attribute_definition_node not node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('a');
  my $et = $doc->create_element_type_definition ('a');
  my $node = $doc->create_element ('foo');
  dies_here_ok {
    $et->remove_attribute_definition_node ($node);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->name, 'TypeError';
  is $@->message, 'The argument is not an AttributeDefinition';
  is $et->attribute_definitions->length, 0;
  done $c;
} n => 5, name => 'remove_attribute_definition_node different node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('a');
  my $et = $doc->create_element_type_definition ('a');
  my $node = $doc->create_attribute_definition ('hoi');
  $et->set_attribute_definition_node ($node);
  my $called;
  $node->set_user_data (destroy => bless sub {
                          $called = 1;
                        }, 'test::DestroyCallback');
  undef $node;
  ok not $called;
  
  $et->remove_attribute_definition_node ($et->attribute_definitions->[0]);
  ok $called;
  
  done $c;
} n => 2, name => 'remove_attribute_definition_node destroy';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('a');
  my $et = $doc->create_element_type_definition ('a');
  my $col = $et->attribute_definitions;
  isa_ok $col, 'Web::DOM::NamedNodeMap';
  is $col->length, 0;
  is scalar @$col, 0;
  done $c;
} n => 3, name => 'attribute_definitions empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('a');
  my $et = $doc->create_element_type_definition ('a');
  my $node1 = $doc->create_attribute_definition ('foo');
  my $node2 = $doc->create_attribute_definition ('bar');
  $et->set_attribute_definition_node ($node1);
  $et->set_attribute_definition_node ($node2);
  my $col = $et->attribute_definitions;
  isa_ok $col, 'Web::DOM::NamedNodeMap';
  is $col->length, 2;
  is scalar @$col, 2;
  is $col->[0], $node1;
  is $col->[1], $node2;

  is $et->attribute_definitions, $col;
  done $c;
} n => 6, name => 'attribute_definitions not empty';

run_tests;

=head1 LICENSE

Copyright 2012-2014 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
