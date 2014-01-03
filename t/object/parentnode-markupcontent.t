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
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('aa');

  is $el->inner_html, '';

  $el->inner_html ('<p title>ho&ge</P>foo<p>bar');
  is $el->inner_html, '<p title="">ho&amp;ge</p>foo<p>bar</p>';

  $el->inner_html (undef);
  is $el->inner_html, '';

  $el->inner_html ('<tr><td>hoge<th>foo');
  is $el->inner_html, 'hogefoo';

  done $c;
} n => 4, name => 'element.inner_html html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('table');

  is $el->inner_html, '';

  $el->inner_html ('<p title>ho&ge</P>foo<p>bar');
  is $el->inner_html, '<p title="">ho&amp;ge</p>foo<p>bar</p>';

  $el->inner_html ('<tr><td>hoge<th>foo');
  is $el->inner_html, '<tbody><tr><td>hoge</td><th>foo</th></tr></tbody>';

  $el->inner_html (undef);
  is $el->inner_html, '';

  done $c;
} n => 4, name => 'element.inner_html html table';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'g');

  is $el->inner_html, '';

  $el->inner_html ('<p title>ho&ge</P>foo<p>bar');
  is $el->inner_html, '<p title="">ho&amp;ge</p>foo<p>bar</p>';

  $el->inner_html (undef);
  is $el->inner_html, '';

  $el->inner_html ('<tr><td>hoge<th>fo<![CDATA[o]]>');
  is $el->inner_html, '<tr><td>hoge<th>foo</th></td></tr>';

  done $c;
} n => 4, name => 'element.inner_html html svg';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $df = $doc->create_document_fragment;

  is $df->inner_html, '';

  $df->inner_html ('hoge<p>foo');
  is $df->inner_html, 'hoge<p>foo</p>';

  $df->inner_html (undef);
  is $df->inner_html, '';

  $df->inner_html ('hoge<p>foo<tr>aa');
  is $df->inner_html, 'hoge<p>fooaa</p>';

  done $c;
} n => 4, name => 'df.inner_html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);

  is $doc->inner_html, '';

  $doc->inner_html ('hoge<p>foo<p>bar');
  is $doc->inner_html,
      '<html><head></head><body>hoge<p>foo</p><p>bar</p></body></html>';

  $doc->inner_html (undef);
  is $doc->inner_html, '<html><head></head><body></body></html>';

  $doc->inner_html ('hoge<P>foo<tr>aa');
  is $doc->inner_html, '<html><head></head><body>hoge<p>fooaa</p></body></html>';

  $doc->inner_html ('<!DOCTYPE HTML><title>ho<>&amp;ge');
  is $doc->inner_html, '<!DOCTYPE html><html><head><title>ho&lt;&gt;&amp;ge</title></head><body></body></html>';

  done $c;
} n => 5, name => 'doc.inner_html html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');

  is $el->inner_html, '';

  dies_here_ok {
    $el->inner_html ('<p title>ho&ge</P>foo<p>bar');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The given string is ill-formed as XML';
  is $el->inner_html, '';

  $el->inner_html ('<p title="">ho&amp;ge</p>foo<p>bar</p>');
  is $el->inner_html, '<p xmlns="http://www.w3.org/1999/xhtml" title="">ho&amp;ge</p>foo<p xmlns="http://www.w3.org/1999/xhtml">bar</p>';

  dies_here_ok {
    $el->inner_html ('<tr><td>hoge<th>foo');
  };
  is $@->name, 'SyntaxError';
  is $@->message, 'The given string is ill-formed as XML';
  is $el->inner_html, '<p xmlns="http://www.w3.org/1999/xhtml" title="">ho&amp;ge</p>foo<p xmlns="http://www.w3.org/1999/xhtml">bar</p>';

  $el->inner_html ('<tr><td xmlns="">hoge<th xmlns="http://ns1/">foo</th></td></tr >');
  is $el->inner_html, '<tr xmlns="http://www.w3.org/1999/xhtml"><td xmlns="">hoge<th xmlns="http://ns1/">foo</th></td></tr>';

  $el->inner_html (undef);
  is $el->inner_html, '';

  done $c;
} n => 13, name => 'element.inner_html xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'g');

  is $el->inner_html, '';

  dies_here_ok {
    $el->inner_html ('<p title>ho&ge</P>foo<p>bar');
  };
  is $@->name, 'SyntaxError';
  is $@->message, 'The given string is ill-formed as XML';
  is $el->inner_html, '';

  $el->inner_html ('<p title="">ho&amp;ge</p>foo<p>bar</p>');
  is $el->inner_html, '<p xmlns="http://www.w3.org/2000/svg" title="">ho&amp;ge</p>foo<p xmlns="http://www.w3.org/2000/svg">bar</p>';

  $el->inner_html (undef);
  is $el->inner_html, '';

  $el->inner_html ('<tr><td>hoge<th>fo<![CDATA[o]]></th></td></tr>');
  is $el->inner_html, '<tr xmlns="http://www.w3.org/2000/svg"><td>hoge<th>foo</th></td></tr>';

  done $c;
} n => 8, name => 'element.inner_html xml svg';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;

  is $df->inner_html, '';

  dies_here_ok {
    $df->inner_html ('hoge<p>foo');
  };
  is $@->name, 'SyntaxError';
  is $@->message, 'The given string is ill-formed as XML';
  is $df->inner_html, '';

  $df->inner_html ('hoge<p>foo</p>');
  is $df->inner_html, 'hoge<p xmlns="http://www.w3.org/1999/xhtml">foo</p>';

  $df->inner_html (undef);
  is $df->inner_html, '';

  $df->inner_html ('hoge<p>foo<tr>aa</tr></p>');
  is $df->inner_html, 'hoge<p xmlns="http://www.w3.org/1999/xhtml">foo<tr>aa</tr></p>';

  done $c;
} n => 8, name => 'df.inner_html xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  is $doc->inner_html, '';

  dies_here_ok {
    $doc->inner_html ('hoge<p>foo<p>bar');
  };
  is $@->name, 'SyntaxError';
  is $@->message, 'The given string is ill-formed as XML';
  is $doc->inner_html, '';

  dies_here_ok {
    $doc->inner_html ('hoge<p>foo<p>bar</p></p>');
  };
  is $doc->inner_html, '';

  $doc->inner_html ('<!--hoge--><p>foo<p>bar</p></p>');
  is $doc->inner_html, '<!--hoge--><p xmlns="">foo<p>bar</p></p>';

  dies_here_ok {
    $doc->inner_html (undef);
  };
  is $doc->inner_html, '<!--hoge--><p xmlns="">foo<p>bar</p></p>';

  $doc->inner_html ('<P>foo<tr>aa</tr></P>');
  is $doc->inner_html, '<P xmlns="">foo<tr>aa</tr></P>';

  dies_here_ok {
    $doc->inner_html ('<!DOCTYPE HTML><title>ho<>&amp;ge');
  };
  is $doc->inner_html, '<P xmlns="">foo<tr>aa</tr></P>';

  $doc->inner_html ('<!DOCTYPE HTML><title>ho&lt;>&amp;ge</title>');
  is $doc->inner_html, '<!DOCTYPE HTML><title xmlns="">ho&lt;&gt;&amp;ge</title>';

  done $c;
} n => 14, name => 'doc.inner_html xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('template');
  $el->inner_html ('<P>abc</P>aaa');
  is $el->first_child, undef;
  is $el->content->child_nodes->length, 2;
  is $el->content->first_child->local_name, 'p';
  is $el->content->last_child->data, 'aaa';
  is $el->inner_html, '<p>abc</p>aaa';
  $el->manakai_append_text ('hoge');
  is $el->child_nodes->length, 1;
  $el->inner_html ('');
  is $el->content->child_nodes->length, 0;
  done $c;
} n => 7, name => '<template>.innerHTML HTML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('template');
  $el->inner_html ('<P>abc</P>aaa');
  is $el->first_child, undef;
  is $el->content->child_nodes->length, 2;
  is $el->content->first_child->local_name, 'P';
  is $el->content->last_child->data, 'aaa';
  is $el->inner_html, '<P xmlns="http://www.w3.org/1999/xhtml">abc</P>aaa';
  $el->manakai_append_text ('hoge');
  is $el->child_nodes->length, 1;
  $el->inner_html ('');
  is $el->content->child_nodes->length, 0;
  done $c;
} n => 7, name => '<template>.innerHTML XML';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
