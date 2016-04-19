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
  $doc->manakai_is_html (1);
  $doc->inner_html (q{<!DOCTYPE html><p itemscope>hoge<p itemscope>fuga<span itemscope>aa</span><br itemscope itemprop=aa>});
  my $items = $doc->get_items;
  isa_ok $items, 'Web::DOM::NodeList';
  is scalar @$items, 3;
  is $items->[0]->text_content, 'hoge';
  is $items->[1]->text_content, 'fugaaa';
  is $items->[2]->text_content, 'aa';
  done $c;
} n => 5, name => 'get_items';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $df = $doc->create_document_fragment;
  $df->inner_html (q{<p itemscope>hoge<p itemscope>fuga<span itemscope>aa</span><br itemscope itemprop=aa>});
  my $items = $df->get_items;
  is scalar @$items, 3;
  is $items->[0]->local_name, 'p';
  is $items->[1]->local_name, 'p';
  is $items->[2]->local_name, 'span';
  done $c;
} n => 4, name => 'df get_items';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns (undef, 'aa');
  my $df = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'div');
  $el->append_child ($df);
  $df->inner_html (q{<p itemscope>hoge<p itemscope>fuga<svg><sp itemscope>aa</sp></svg><br itemscope itemprop=aa>});
  my $items = $df->get_items;
  is scalar @$items, 2;
  is $items->[0]->local_name, 'p';
  is $items->[1]->local_name, 'p';
  done $c;
} n => 3, name => 'el get_items';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  $doc->inner_html (q{<!DOCTYPE html><p itemscope>a<p itemscope itemprop=a><p itemscope itemtype="http://abc/ http://xya/"><p itemscope itemtype="http://abc/">});
  is $doc->get_items (undef)->length, 3;
  is $doc->get_items ('')->length, 3;
  is $doc->get_items ('hoge')->length, 0;
  is $doc->get_items ('http://abc/')->length, 2;
  is $doc->get_items ('http://xya/')->length, 1;
  is $doc->get_items ('HTTP://xya/')->length, 0;
  is $doc->get_items ('http://abc/  http://xya/ ')->length, 1;
  is $doc->get_items ('http://xya/ 
http://abc/  ')->length, 1;
  is $doc->get_items ('http://abc/  http://xya/ http://abc/')->length, 1;
  is $doc->get_items ('http://abc/  http://xya/ http://abc/d')->length, 0;
  is $doc->get_items ('http://abc/  http://abc/ http://abc/')->length, 2;
  done $c;
} n => 11, name => 'get_items typed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->set_attribute ('itemscope', '');
  is $el->get_items->length, 1;
  done $c;
} n => 1, name => 'get_item self';

run_tests;

=head1 LICENSE

Copyright 2014 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
