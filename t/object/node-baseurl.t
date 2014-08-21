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
  is $doc->base_uri, 'about:blank';
  done $c;
} n => 1, name => 'document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://hoge/');
  is $doc->base_uri, 'http://hoge/';
  done $c;
} n => 1, name => 'document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('base');
  $el->set_attribute (href => 'http://hoge');
  $doc->append_child ($el);
  is $doc->base_uri, 'http://hoge/';
  done $c;
} n => 1, name => 'document <base href>';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el2 = $doc->create_element ('foo');
  $doc->append_child ($el2);
  my $el = $doc->create_element ('base');
  $el->set_attribute (href => 'http://hoge');
  $el2->append_child ($el);
  my $el3 = $doc->create_element ('base');
  $el3->set_attribute (href => 'http://fuga');
  $el2->append_child ($el3);
  is $doc->base_uri, 'http://hoge/';
  done $c;
} n => 1, name => 'document <base href>';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el2 = $doc->create_element ('foo');
  $doc->append_child ($el2);
  my $el4 = $doc->create_element ('base');
  $el2->append_child ($el4);
  my $el = $doc->create_element ('base');
  $el->set_attribute (href => 'http://hoge');
  $el2->append_child ($el);
  my $el3 = $doc->create_element ('base');
  $el3->set_attribute (href => 'http://fuga');
  $el2->append_child ($el3);
  is $doc->base_uri, 'http://hoge/';
  done $c;
} n => 1, name => 'document <base href>';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://abc/');
  my $el2 = $doc->create_element ('foo');
  $el2->set_attribute_ns
      ('http://www.w3.org/XML/1998/namespace', 'xml:base', 'http://ac/');
  $doc->append_child ($el2);
  my $el = $doc->create_element ('base');
  $el->set_attribute (href => 'hoge');
  $el2->append_child ($el);
  my $el3 = $doc->create_element ('base');
  $el3->set_attribute (href => 'http://fuga');
  $el2->append_child ($el3);
  is $doc->base_uri, 'http://abc/hoge';
  done $c;
} n => 1, name => 'document <base href>';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://abc/');
  my $el2 = $doc->create_element ('foo');
  $el2->set_attribute_ns
      ('http://www.w3.org/XML/1998/namespace', 'xml:base', 'http://ac/');
  $doc->append_child ($el2);
  my $el = $doc->create_element ('base');
  $el->set_attribute (href => 'http://ab:hoge');
  $el2->append_child ($el);
  my $el3 = $doc->create_element ('base');
  $el3->set_attribute (href => 'http://fuga');
  $el2->append_child ($el3);
  is $doc->base_uri, 'http://abc/';
  done $c;
} n => 1, name => 'document <base href>';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  is $doc->base_uri, 'about:blank';
  $$doc->[0]->{document_base_url} = 'hoge';
  is $doc->base_uri, 'hoge'; # cached!
  $doc->manakai_set_url ('http://hoge/fuga#');
  is $doc->base_uri, 'http://hoge/fuga#';
  my $base = $doc->create_element ('base');
  $doc->append_child ($base);
  is $doc->base_uri, 'http://hoge/fuga#';
  $base->href ('http://foo/bar');
  is $doc->base_uri, 'http://foo/bar';
  done $c;
} n => 5, name => 'document base changed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://abc/');
  my $attr = $doc->create_attribute_ns
      ('http://www.w3.org/XML/1998/namespace', 'base');
  $attr->value ('http://foo');
  is $attr->base_uri, 'http://abc/';
  done $c;
} n => 1, name => 'attr xml:base no owner';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://abc/');
  my $el = $doc->create_element ('ff');
  my $attr = $doc->create_attribute_ns
      ('http://www.w3.org/XML/1998/namespace', 'base');
  $attr->value ('http://foo');
  $el->set_attribute_node ($attr);
  is $attr->base_uri, 'http://abc/';
  done $c;
} n => 1, name => 'attr xml:base with owner no parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://abc/');
  my $el2 = $doc->create_element ('ff');
  my $el = $doc->create_element ('ff');
  my $attr = $doc->create_attribute_ns
      ('http://www.w3.org/XML/1998/namespace', 'base');
  $attr->value ('http://foo');
  $el->set_attribute_node ($attr);
  $el2->append_child ($el);
  is $attr->base_uri, 'http://abc/';
  done $c;
} n => 1, name => 'attr xml:base with owner and parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://abc/');
  my $el2 = $doc->create_element ('ff');
  $el2->set_attribute_ns
      ('http://www.w3.org/XML/1998/namespace', 'xml:base', 'http://def/');
  my $el = $doc->create_element ('ff');
  my $attr = $doc->create_attribute_ns
      ('http://www.w3.org/XML/1998/namespace', 'base');
  $attr->value ('http://foo');
  $el->set_attribute_node ($attr);
  $el2->append_child ($el);
  is $attr->base_uri, 'http://def/';
  done $c;
} n => 1, name => 'attr xml:base with owner and parent xml:base';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://foo/');
  my $attr = $doc->create_attribute ('xml:base');
  is $attr->base_uri, 'http://foo/';
  done $c;
} n => 1, name => 'attr no owner';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://foo/');
  my $el = $doc->create_element ('aa');
  my $attr = $doc->create_attribute ('xml:base');
  is $attr->base_uri, 'http://foo/';
  $el->set_attribute_node ($attr);
  done $c;
} n => 1, name => 'attr with owner';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://foo/');
  my $el = $doc->create_element ('aa');
  $el->set_attribute_ns
      ('http://www.w3.org/XML/1998/namespace', 'xml:base', 'http://def/');
  my $attr = $doc->create_attribute ('xml_base');
  $el->set_attribute_node ($attr);
  is $attr->base_uri, 'http://def/';
  done $c;
} n => 1, name => 'attr with owner xml:base';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://abc/');
  my $el = $doc->create_element ('aa');
  is $el->base_uri, 'http://abc/';
  done $c;
} n => 1, name => 'element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://abc/');
  my $el = $doc->create_element ('aa');
  $el->set_attribute_ns
      ('http://www.w3.org/XML/1998/namespace', 'xml:base', 'http://def/');
  is $el->base_uri, 'http://def/';
  done $c;
} n => 1, name => 'element xml:base';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://abc/');
  my $el = $doc->create_element ('aa');
  my $el2 = $doc->create_element ('b');
  $el2->append_child ($el);
  $el2->set_attribute_ns
      ('http://www.w3.org/XML/1998/namespace', 'xml:base', 'http://def/');
  is $el->base_uri, 'http://def/';
  done $c;
} n => 1, name => 'element parent xml:base';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
