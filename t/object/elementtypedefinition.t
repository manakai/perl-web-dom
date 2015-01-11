use strict;
use warnings;
no warnings 'utf8';
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
  my $node = $doc->create_element_type_definition ('hoge');
  is $node->node_type, $node->ELEMENT_TYPE_DEFINITION_NODE;
  is $node->node_name, 'hoge';
  is $node->node_value, undef;
  is $node->text_content, undef;
  $node->node_value ('foo');
  is $node->node_value, undef;
  is $node->text_content, undef;
  $node->node_value (undef);
  is $node->node_value, undef;
  is $node->text_content, undef;
  is $node->owner_document_type_definition, undef;
  done $c;
} n => 9, name => 'basic node properties';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $et = $doc->create_element_type_definition ('hoge');
  
  is $et->content_model_text, undef;
  
  $et->content_model_text ('(hoge | fuga)');
  is $et->content_model_text, '(hoge | fuga)';

  $et->content_model_text (undef);
  is $et->content_model_text, undef;

  done $c;
} n => 3, name => 'content_model_text';

for my $test (
  ['EMPTY'],
  ['ANY'],
  ["  EMPTY\x09" => 'EMPTY'],
  [' ANY' => 'ANY'],
  ['(ab)' => '(ab)'],
  ['(#PCDATA | foo | bar  )' => '(#PCDATA | foo | bar)'],
  ['(a,b)' => '(a, b)'],
  ['(abc, cd  ,ef* ) ' => '(abc, cd, ef*)'],
  ['(abc,(cd  ,ef*)) ' => '(abc, (cd, ef*))'],
  ['(abc,(cd  ,ef*))+' => '(abc, (cd, ef*))+'],
  ['(ab , #PCDATA+)' => '(ab, #PCDATA+)'],
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $et = $doc->create_element_type_definition ('hoge');
    $et->content_model_text ($test->[0]);
    is $et->content_model_text, $test->[1] || $test->[0];
    done $c;
  } n => 1, name => ['content_model_text', $test->[0]];
}

for my $test (
  '',
  'any',
  ' ',
  '(aba',
  '(foo)!',
  '  (any)**',
  '(a & b & c)',
  '(ab cd)',
  ')ab(',
  '(ab++)',
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $et = $doc->create_element_type_definition ('hoge');
    dies_here_ok {
      $et->content_model_text ($test);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'SyntaxError';
    is $@->message, 'The specified text is not a valid content model';
    is $et->content_model_text, undef;
    done $c;
  } n => 5, name => ['content_model_text', $test];
}

run_tests;

=head1 LICENSE

Copyright 2012-2015 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
