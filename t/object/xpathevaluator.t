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

test {
  my $c = shift;
  my $eval = Web::DOM::XPathEvaluator->new;
  isa_ok $eval, 'Web::DOM::XPathEvaluator';
  my $exp = $eval->create_expression ('hoge');
  isa_ok $exp, 'Web::DOM::XPathExpression';
  done $c;
} n => 2, name => 'new';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $exp = $eval->create_expression ('foo');
  isa_ok $exp, 'Web::DOM::XPathExpression';
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (undef, 'foo');
  $doc->append_child ($el);
  is $exp->evaluate ($doc)->iterate_next, $el;
  done $c;
} n => 2, name => 'create_expression';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  dies_here_ok {
    $eval->create_expression ('<');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The specified expression is syntactically invalid';
  done $c;
} n => 4, name => 'create_expression xpath syntax error';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  dies_here_ok {
    $eval->create_expression ('hpge:fuga');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message,
      'The specified expression has unresolvable namespace prefix |hpge|';
  done $c;
} n => 4, name => 'create_expression xpath nsprefix error';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $called = 0;
  my $prefix;
  my $self;
  my $code = sub {
    $self = $_[0];
    $prefix = $_[1];
    $called++;
    return 'http://a/';
  };
  my $expr = $eval->create_expression ('hpge:fuga', $code);
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://a/', 'fuga');
  $doc->append_child ($el);
  is $expr->evaluate ($doc)->iterate_next, $el;
  is $self, $code;
  is $prefix, 'hpge';
  is $called, 1;
  done $c;
} n => 4, name => 'create_expression xpath prefix resolved';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $el2 = $doc->create_element ('aa');
  $el2->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:hpge', 'http://a/');
  my $resolver = $eval->create_ns_resolver ($el2);
  my $expr = $eval->create_expression ('hpge:fuga', $resolver);
  my $el = $doc->create_element_ns ('http://a/', 'fuga');
  $doc->append_child ($el);
  is $expr->evaluate ($doc)->iterate_next, $el;
  done $c;
} n => 1, name => 'create_expression xpath nsresolver resolved';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  dies_here_ok {
    $eval->create_expression ('hpge:fuga', 'abc');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not an XPathNSResolver';
  done $c;
} n => 3, name => 'create_expression not resolver';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  dies_here_ok {
    $eval->create_expression;
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The specified expression is syntactically invalid';
  done $c;
} n => 4, name => 'create_expression no argument';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  dies_here_ok {
    $eval->create_ns_resolver;
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The argument is not a Node';
  done $c;
} n => 3, name => 'create_ns_resolver no argument';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  dies_here_ok {
    $eval->create_ns_resolver ($eval);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The argument is not a Node';
  done $c;
} n => 3, name => 'create_ns_resolver not Node';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $resolver = $eval->create_ns_resolver ($el);
  isa_ok $resolver, 'Web::DOM::XPathNSResolver';
  is $resolver->lookup_namespace_uri ('hpoge'), undef;
  is $resolver->lookup_namespace_uri ('xml'), undef;
  $el->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:aa', 'http://aa/');
  is $resolver->lookup_namespace_uri ('aa'), 'http://aa/';
  done $c;
} n => 4, name => 'create_ns_resolver';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  $doc->append_child ($el);
  my $result = $eval->evaluate ('child::*', $doc);
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
  dies_here_ok {
    $eval->evaluate ();
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a Node';
  done $c;
} n => 3, name => 'no args';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $eval->evaluate ('hoge');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a Node';
  done $c;
} n => 3, name => 'no contextNode args';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $eval->evaluate ('hoge', $eval);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a Node';
  done $c;
} n => 3, name => 'bad contextNode args';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $eval->evaluate ('hoge::', $doc);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The specified expression is syntactically invalid';
  done $c;
} n => 4, name => 'xpath syntax error';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $eval->evaluate ('hoge:fuga', $doc);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The specified expression has unresolvable namespace prefix |hoge|';
  done $c;
} n => 4, name => 'xpath namespace error';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $eval->evaluate ('hoge:fuga', $doc, 'abx');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The third argument is not an XPathNSResolver';
  done $c;
} n => 3, name => 'bad resolver';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  $doc->append_child ($el);
  my $self;
  my $prefix;
  my $invoked = 0;
  my $code = sub {
    $invoked++;
    $self = $_[0];
    $prefix = $_[1];
    return 'http://www.w3.org/1999/xhtml';
  };
  my $result = $eval->evaluate ('child::b:aa', $doc, $code);
  isa_ok $result, 'Web::DOM::XPathResult';
  is $result->result_type, $result->UNORDERED_NODE_ITERATOR_TYPE;
  is $result->iterate_next, $el;
  is $result->iterate_next, undef;
  is $result->iterate_next, undef;
  is $invoked, 1;
  is $self, $code;
  is $prefix, 'b';
  done $c;
} n => 8, name => 'evaluate nsresolver code';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  $doc->append_child ($el);
  my $el2 = $doc->create_element_ns (undef, 'aaga');
  $el2->set_attribute (hoge => '');
  $el2->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:b', 'http://www.w3.org/1999/xhtml');
  my $node = $el2->get_attribute_node ('hoge');
  my $resolver = $eval->create_ns_resolver ($node);
  my $result = $eval->evaluate ('child::b:aa', $doc, $resolver);
  isa_ok $result, 'Web::DOM::XPathResult';
  is $result->result_type, $result->UNORDERED_NODE_ITERATOR_TYPE;
  is $result->iterate_next, $el;
  is $result->iterate_next, undef;
  is $result->iterate_next, undef;
  done $c;
} n => 5, name => 'evaluate nsresolver node';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $eval->evaluate ('hoge:fuga', $doc, sub { die });
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The specified expression has unresolvable namespace prefix |hoge|';
  done $c;
} n => 4, name => 'bad resolver';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $eval->evaluate ('hoge:fuga', $doc, sub { return undef });
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The specified expression has unresolvable namespace prefix |hoge|';
  done $c;
} n => 4, name => 'bad resolver';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  $doc->append_child ($el);
  my $self;
  my $prefix;
  my $invoked = 0;
  my $code = sub {
    $invoked++;
    $self = $_[0];
    $prefix = $_[1];
    return '';
  };
  my $result = $eval->evaluate ('child::b:aa', $doc, $code);
  isa_ok $result, 'Web::DOM::XPathResult';
  is $result->result_type, $result->UNORDERED_NODE_ITERATOR_TYPE;
  is $result->iterate_next, undef;
  is $result->iterate_next, undef;
  is $invoked, 1;
  is $self, $code;
  is $prefix, 'b';
  done $c;
} n => 7, name => 'evaluate nsresolver code empty';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  $doc->append_child ($el);
  my $el2 = $doc->create_element_ns (undef, 'aaga');
  $el2->set_attribute (hoge => '');
  $el2->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:b', 'http://www.w3.org/1999/xhtml');
  my $node = $el2->get_attribute_node ('hoge');
  my $resolver = $eval->create_ns_resolver ($node);
  my $result = $eval->evaluate ('child::b:aa', $doc, $resolver, 2**16);
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
  my $el = $doc->create_element ('aa');
  $doc->append_child ($el);
  my $result = $eval->evaluate ('child::*', $doc, undef, 2**16+9);
  isa_ok $result, 'Web::DOM::XPathResult';
  is $result->result_type, 9;
  is $result->single_node_value, $el;
  done $c;
} n => 3, name => 'evaluate result type';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $eval->evaluate ('child::*', $doc, undef, 12);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The result is not compatible with the specified type';
  done $c;
} n => 3, name => 'evaluate result type bad';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $eval->evaluate ('child::*', $doc, undef, undef, 'fuga');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The fifth argument is not an object';
  done $c;
} n => 3, name => 'evaluate result bad';

test {
  my $c = shift;
  my $eval = new Web::DOM::XPathEvaluator;
  my $doc = new Web::DOM::Document;
  my $result = $doc->evaluate ('child::*', $doc);
  my $result2 = $eval->evaluate ('child::*', $doc, undef, undef, $result);
  isa_ok $result2, 'Web::DOM::XPathResult';
  isnt $result2, $result;
  is $result2->result_type, 4;
  done $c;
} n => 3, name => 'evaluate result ignored';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('template');

  my $el2 = $doc->create_element ('p');
  $el->content->append_child ($el2);
  my $el3 = $doc->create_element ('p');
  $el->append_child ($el3);

  my $result = $doc->evaluate ('.//p', $el);
  is $result->result_type, $result->UNORDERED_NODE_ITERATOR_TYPE;
  is $result->iterate_next, $el3;
  is $result->iterate_next, undef;
  is $result->iterate_next, undef;

  done $c;
} n => 4, name => 'template content';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
