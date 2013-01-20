use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $pi = $doc->create_processing_instruction ('hoge', 'fuga');
  isa_ok $pi, 'Web::DOM::ProcessingInstruction';
  isa_ok $pi, 'Web::DOM::CharacterData';
  isa_ok $pi, 'Web::DOM::Node';

  is $pi->node_type, $pi->PROCESSING_INSTRUCTION_NODE;
  is $pi->node_name, 'hoge';
  is $pi->target, 'hoge';
  is $pi->node_value, 'fuga';
  is $pi->data, 'fuga';
  is $pi->first_child, undef;
  is $pi->namespace_uri, undef;
  is $pi->prefix, undef;
  is $pi->manakai_local_name, undef;
  is $pi->local_name, undef;

  is $pi->data, 'fuga';
  is $pi->node_value, 'fuga';
  is $pi->text_content, 'fuga';

  $pi->node_value ('fuga2');
  is $pi->node_value, 'fuga2';
  is $pi->data, 'fuga2';
  is $pi->text_content, 'fuga2';

  $pi->data ('abc');
  is $pi->node_value, 'abc';
  is $pi->data, 'abc';
  is $pi->text_content, 'abc';

  $pi->text_content ('abc');
  is $pi->node_value, 'abc';
  is $pi->data, 'abc';
  is $pi->text_content, 'abc';

  done $c;
} n => 25, name => 'create_processing_instruction';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $pi = $doc->create_processing_instruction ('f', 'aaa');
  $pi->data (undef);
  is $pi->data, '';
  done $c;
} n => 1, name => 'data TreatNullAs=EmptyString';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $pi = $doc->create_processing_instruction ('hoge', 'foo');
  
  is $pi->manakai_base_uri, undef;

  $pi->manakai_base_uri ('http://foo/');
  is $pi->manakai_base_uri, undef;

  $pi->manakai_base_uri ('0');
  is $pi->manakai_base_uri, undef;

  $pi->manakai_base_uri (undef);
  is $pi->manakai_base_uri, undef;

  done $c;
} n => 4, name => 'manakai_base_uri';

run_tests;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
