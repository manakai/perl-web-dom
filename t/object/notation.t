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
  my $node = $doc->create_notation ('hoge');
  is $node->node_type, $node->NOTATION_NODE;
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
  my $node = $doc->create_notation ('hoge');
  
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
  my $node = $doc->create_notation ('hoge');
  
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
  my $ent = $doc->create_notation ('aa');

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
