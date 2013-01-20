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
  my $node = $doc->create_general_entity ('hoge');
  is $node->node_type, $node->ENTITY_NODE;
  is $node->node_name, 'hoge';
  is $node->node_value, '';
  is $node->text_content, '';
  $node->node_value ('foo');
  is $node->node_value, 'foo';
  is $node->text_content, 'foo';
  $node->node_value ('bar');
  is $node->node_value, 'bar';
  is $node->text_content, 'bar';
  $node->node_value (undef);
  is $node->node_value, '';
  is $node->text_content, '';
  is $node->owner_document_type_definition, undef;
  ok not $node->has_replacement_tree;
  $node->has_replacement_tree (1);
  ok not $node->has_replacement_tree;
  is $node->input_encoding, undef;
  done $c;
} n => 14, name => 'basic node properties';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_general_entity ('hoge');
  
  $node->public_id ('hoge');
  is $node->public_id, 'hoge';
  
  $node->public_id ('hoge "');
  is $node->public_id, 'hoge "';
  
  $node->public_id (undef);
  is $node->public_id, '';

  done $c;
} n => 3, name => 'public_id setter';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_general_entity ('hoge');
  
  $node->system_id ('hoge');
  is $node->system_id, 'hoge';
  
  $node->system_id ('hoge "');
  is $node->system_id, 'hoge "';
  
  $node->system_id (undef);
  is $node->system_id, '';

  done $c;
} n => 3, name => 'system_id setter';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ent = $doc->create_general_entity ('foo');
  is $ent->xml_version, undef;
  $ent->xml_version ('1.1');
  is $ent->xml_version, '1.1';
  $ent->xml_version (1.0);
  is $ent->xml_version, '1';
  $ent->xml_version (undef);
  is $ent->xml_version, undef;
  $ent->xml_version ('');
  is $ent->xml_version, '';
  done $c;
} n => 5, name => 'xml_version';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ent = $doc->create_general_entity ('foo');
  is $ent->xml_encoding, undef;
  $ent->xml_encoding ('utF-8');
  is $ent->xml_encoding, 'utF-8';
  $ent->xml_encoding (1.0);
  is $ent->xml_encoding, '1';
  $ent->xml_encoding (undef);
  is $ent->xml_encoding, undef;
  $ent->xml_encoding ('');
  is $ent->xml_encoding, '';
  done $c;
} n => 5, name => 'xml_encoding';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ent = $doc->create_general_entity ('foo');
  is $ent->notation_name, undef;
  $ent->notation_name ('utF-8');
  is $ent->notation_name, 'utF-8';
  $ent->notation_name (1.0);
  is $ent->notation_name, '1';
  $ent->notation_name (undef);
  is $ent->notation_name, undef;
  $ent->notation_name ('');
  is $ent->notation_name, '';
  done $c;
} n => 5, name => 'notation_name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ent = $doc->create_general_entity ('aa');
  ok not $ent->is_externally_declared;
  $ent->is_externally_declared (1);
  ok $ent->is_externally_declared;
  $ent->is_externally_declared (undef);
  ok not $ent->is_externally_declared;
  done $c;
} n => 3, name => 'is_externally_declared';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ent = $doc->create_general_entity ('foo');
  is $ent->manakai_charset, undef;
  $ent->manakai_charset ('utF-8');
  is $ent->manakai_charset, 'utF-8';
  $ent->manakai_charset (1.0);
  is $ent->manakai_charset, '1';
  $ent->manakai_charset (undef);
  is $ent->manakai_charset, undef;
  $ent->manakai_charset ('');
  is $ent->manakai_charset, '';
  done $c;
} n => 5, name => 'manakai_charset';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ent = $doc->create_general_entity ('aa');
  ok not $ent->manakai_has_bom;
  $ent->manakai_has_bom (1);
  ok $ent->manakai_has_bom;
  $ent->manakai_has_bom (undef);
  ok not $ent->manakai_has_bom;
  done $c;
} n => 3, name => 'manakai_has_bom';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ent = $doc->create_general_entity ('a');
  is $ent->manakai_entity_uri, undef;

  is $ent->base_uri, 'about:blank';
  $doc->manakai_set_url ('http://FOO');
  is $ent->base_uri, 'http://foo/';
  is $ent->manakai_entity_uri, undef;

  $ent->manakai_entity_uri ('http://BAR');
  is $ent->manakai_entity_uri, 'http://bar/';

  $ent->manakai_entity_uri ('./HOGE');
  is $ent->manakai_entity_uri, 'http://foo/HOGE';

  $ent->manakai_entity_uri (undef);
  is $ent->manakai_entity_uri, undef;

  $ent->system_id ('http://hoge');
  is $ent->manakai_entity_uri, 'http://hoge/';

  $ent->system_id ('abc');
  is $ent->manakai_entity_uri, 'http://foo/abc';

  $ent->declaration_base_uri ('ftp://bc');
  is $ent->manakai_entity_uri, 'ftp://bc/abc';

  $ent->manakai_entity_uri ('bb');
  is $ent->manakai_entity_uri, 'ftp://bc/bb';

  $ent->declaration_base_uri ('ftp://bcd/');
  is $ent->manakai_entity_uri, 'ftp://bc/bb';

  done $c;
} n => 12, name => 'manakai_entity_uri';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ent = $doc->create_general_entity ('a');

  is $ent->manakai_entity_base_uri, 'about:blank';
  
  $doc->manakai_set_url ('http://hoge');
  is $ent->manakai_entity_base_uri, 'http://hoge/';

  $ent->manakai_entity_base_uri ('fuga');
  is $ent->manakai_entity_base_uri, 'http://hoge/fuga';

  $ent->manakai_entity_base_uri (undef);
  is $ent->manakai_entity_base_uri, 'http://hoge/';

  $ent->manakai_entity_uri ('fuga/abc');
  is $ent->manakai_entity_base_uri, 'http://hoge/fuga/abc';

  $ent->manakai_entity_base_uri ('bbb');
  is $ent->manakai_entity_base_uri, 'http://hoge/fuga/bbb';

  done $c;
} n => 6, name => 'manakai_entity_base_uri';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ent = $doc->create_general_entity ('aa');

  is $ent->declaration_base_uri, 'about:blank';
  is $ent->manakai_declaration_base_uri, $ent->declaration_base_uri;

  $doc->manakai_set_url ('ftp://fuga/');
  is $ent->declaration_base_uri, 'ftp://fuga/';
  is $ent->manakai_declaration_base_uri, $ent->declaration_base_uri;

  $ent->declaration_base_uri ('abc/def');
  is $ent->declaration_base_uri, 'ftp://fuga/abc/def';
  is $ent->manakai_declaration_base_uri, $ent->declaration_base_uri;

  $ent->manakai_declaration_base_uri ('hpge/../abcd/def');
  is $ent->declaration_base_uri, 'ftp://fuga/abcd/def';
  is $ent->manakai_declaration_base_uri, $ent->declaration_base_uri;

  $ent->manakai_declaration_base_uri (undef);
  is $ent->declaration_base_uri, 'ftp://fuga/';
  is $ent->manakai_declaration_base_uri, $ent->declaration_base_uri;
  
  done $c;
} n => 10, name => 'declaration_base_uri';

run_tests;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
