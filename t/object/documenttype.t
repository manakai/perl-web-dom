use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('hoge', '', '');
  isa_ok $dt, 'Web::DOM::DocumentType';
  isa_ok $dt, 'Web::DOM::Node';
  
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->node_name, 'hoge';
  is $dt->name, 'hoge';
  is $dt->public_id, '';
  is $dt->system_id, '';

  is $dt->namespace_uri, undef;
  is $dt->prefix, undef;
  is $dt->manakai_local_name, undef;
  is $dt->local_name, undef;
  is $dt->first_child, undef;

  is $dt->node_value, undef;
  is $dt->text_content, undef;

  $dt->node_value ('hoge');
  is $dt->node_value, undef;
  is $dt->text_content, undef;

  $dt->text_content ('hoge');
  is $dt->node_value, undef;
  is $dt->text_content, undef;

  done $c;
} n => 18, name => 'document type attributes - empty ids';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type
      ('hoge', 'ho "\'ge', 'fu\'"ga');
  isa_ok $dt, 'Web::DOM::DocumentType';
  isa_ok $dt, 'Web::DOM::Node';
  
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->node_name, 'hoge';
  is $dt->name, 'hoge';
  is $dt->public_id, q{ho "'ge};
  is $dt->system_id, q{fu'"ga};

  is $dt->first_child, undef;

  done $c;
} n => 8, name => 'document type attributes';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  
  $dt->public_id ('hoge');
  is $dt->public_id, 'hoge';
  
  $dt->public_id ('hoge "');
  is $dt->public_id, 'hoge "';
  
  $dt->public_id (undef);
  is $dt->public_id, '';

  done $c;
} n => 3, name => 'public_id setter';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  
  $dt->system_id ('hoge');
  is $dt->system_id, 'hoge';
  
  $dt->system_id ('hoge "');
  is $dt->system_id, 'hoge "';
  
  $dt->system_id (undef);
  is $dt->system_id, '';

  done $c;
} n => 3, name => 'system_id setter';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->create_document_type_definition ('aA');
  is $dt->declaration_base_uri, 'about:blank';
  is $dt->manakai_declaration_base_uri, $dt->declaration_base_uri;

  $doc->manakai_set_url ('http://aa');
  is $dt->declaration_base_uri, 'http://aa/';
  is $dt->manakai_declaration_base_uri, $dt->declaration_base_uri;

  done $c;
} n => 4, name => 'declaration_base_uri';

run_tests;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
