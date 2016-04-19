use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::XPathEvaluator;
use Web::DOM::Document;
use Web::DOM::XPathResult;

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $doc->append_child ($el);
  my $expr = $eval->create_expression ('child::*');
  my $result = $expr->evaluate($doc);
  isa_ok $result, 'Web::DOM::XPathResult';
  is $result->result_type, $result->UNORDERED_NODE_ITERATOR_TYPE;
  is $result->iterate_next, $el;
  is $result->iterate_next, undef;
  is $result->iterate_next, undef;
  done $c;
} n => 5, name => 'evaluate ok';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $expr = $eval->create_expression ('hoge');
  dies_here_ok {
    $expr->evaluate ();
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The first argument is not a Node';
  done $c;
} n => 3, name => 'no args';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $expr = $eval->create_expression ('hoge');
  dies_here_ok {
    $expr->evaluate ($eval);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The first argument is not a Node';
  done $c;
} n => 3, name => 'bad contextNode args';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $doc->append_child ($el);
  my $el2 = $doc->create_element_ns (undef, 'aaga');
  $el2->set_attribute (hoge => '');
  $el2->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:b', 'http://www.w3.org/1999/xhtml');
  my $node = $el2->get_attribute_node ('hoge');
  my $resolver = $eval->create_ns_resolver ($node);
  my $expr = $eval->create_expression ('child::b:aa', $resolver);
  my $result = $expr->evaluate ($doc, 2**16);
  isa_ok $result, 'Web::DOM::XPathResult';
  is $result->result_type, $result->UNORDERED_NODE_ITERATOR_TYPE;
  is $result->iterate_next, $el;
  is $result->iterate_next, undef;
  is $result->iterate_next, undef;
  done $c;
} n => 5, name => 'evaluate result type';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $doc->append_child ($el);
  my $expr = $eval->create_expression ('child::*', undef);
  my $result = $expr->evaluate ($doc, 2**16+9);
  isa_ok $result, 'Web::DOM::XPathResult';
  is $result->result_type, 9;
  is $result->single_node_value, $el;
  done $c;
} n => 3, name => 'evaluate result type';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $expr = $eval->create_expression ('child::*');
  dies_here_ok {
    $expr->evaluate ($doc, 12);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The result is not compatible with the specified type';
  done $c;
} n => 3, name => 'evaluate result type bad';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $expr = $doc->create_expression ('child::*');
  dies_here_ok {
    $expr->evaluate ($doc, undef, 'fuga');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The third argument is not an object';
  done $c;
} n => 3, name => 'evaluate result bad';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $result = $doc->evaluate ('child::*', $doc);
  my $expr = $eval->create_expression ('child::*');
  my $result2 = $expr->evaluate ($doc, undef, $result);
  isa_ok $result2, 'Web::DOM::XPathResult';
  isnt $result2, $result;
  is $result2->result_type, 4;
  done $c;
} n => 3, name => 'evaluate result ignored';

for my $test (
  [NUMBER_TYPE, '"hoge"'],
  [NUMBER_TYPE, '1 = 3'],
  [NUMBER_TYPE, '/'],
  [STRING_TYPE, '44'],
  [STRING_TYPE, '4 = 4'],
  [STRING_TYPE, '/'],
  [BOOLEAN_TYPE, '44.4'],
  [BOOLEAN_TYPE, '"aa"'],
  [BOOLEAN_TYPE, '/'],
  [UNORDERED_NODE_ITERATOR_TYPE, '44'],
  [UNORDERED_NODE_ITERATOR_TYPE, '5 = 5'],
  [UNORDERED_NODE_ITERATOR_TYPE, '"abc"'],
  [ORDERED_NODE_ITERATOR_TYPE, '44'],
  [ORDERED_NODE_ITERATOR_TYPE, '5 = 5'],
  [ORDERED_NODE_ITERATOR_TYPE, '"abc"'],
  [UNORDERED_NODE_SNAPSHOT_TYPE, '44'],
  [UNORDERED_NODE_SNAPSHOT_TYPE, '5 = 5'],
  [UNORDERED_NODE_SNAPSHOT_TYPE, '"abc"'],
  [ORDERED_NODE_SNAPSHOT_TYPE, '44'],
  [ORDERED_NODE_SNAPSHOT_TYPE, '5 = 5'],
  [ORDERED_NODE_SNAPSHOT_TYPE, '"abc"'],
  [ANY_UNORDERED_NODE_TYPE, '44'],
  [ANY_UNORDERED_NODE_TYPE, '5 = 5'],
  [ANY_UNORDERED_NODE_TYPE, '"abc"'],
  [FIRST_ORDERED_NODE_TYPE, '44'],
  [FIRST_ORDERED_NODE_TYPE, '5 = 5'],
  [FIRST_ORDERED_NODE_TYPE, '"abc"'],
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $expr = $doc->create_expression ($test->[1]);
    dies_here_ok {
      $expr->evaluate ($doc, $test->[0]);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->message, 'The result is not compatible with the specified type';
    done $c;
  } n => 3, name => ['evaluate type', @$test];
}

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $expr = $doc->create_expression ('"abc"/child::*');
  dies_here_ok {
    $expr->evaluate ($doc);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'XPath evaluation failed';
  done $c;
} n => 4, name => 'evaluate xpath evaluation error';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
