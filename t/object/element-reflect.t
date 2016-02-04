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
  my $el = $doc->create_element_ns (undef, 'aA');

  my $list1 = $el->manakai_ids;
  is_deeply $list1, [];

  $el->set_attribute (id => 'foo');

  my $list2 = $el->manakai_ids;
  is_deeply $list2, ['foo'];

  $el->set_attribute_ns ('http://hoge/', 'id' => 'bar');

  my $list3 = $el->manakai_ids;
  is_deeply $list3, ['foo'];

  is_deeply $list1, [];
  isnt $list2, $list1;
  isnt $list3, $list1;

  done $c;
} n => 6, name => 'manakai_ids';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  is_deeply [@{$el->class_list}], [];

  $el->set_attribute (class => '  hoge fuga hoge');
  is_deeply [@{$el->class_list}], ['hoge', 'fuga'];

  $el->set_attribute (class => "anc\x0Adde\x0B\x0D\x09");
  is_deeply [@{$el->class_list}], ['anc', "dde\x0B"];

  $el->remove_attribute ('class');
  is_deeply [@{$el->class_list}], [];

  $el->set_attribute_ns (undef, class => "anc\x0A\x0Cdde\x0B");
  is_deeply [@{$el->class_list}], ['anc', "dde\x0B"];

  $el->remove_attribute_ns (undef, 'class');
  is_deeply [@{$el->class_list}], [];

  my $attr = $doc->create_attribute ('class');
  $attr->value ('foo bar');
  $el->set_attribute_node ($attr);
  is_deeply [@{$el->class_list}], ['foo', 'bar'];

  $el->remove_attribute_node ($attr);
  is_deeply [@{$el->class_list}], [];

  $el->set_attribute_node_ns ($attr);
  is_deeply [@{$el->class_list}], ['foo', 'bar'];

  $attr->value ('ab c');
  is_deeply [@{$el->class_list}], ['ab', 'c'];
  
  $attr->value ('');
  is_deeply [@{$el->class_list}], [];

  $attr->node_value ('ab cd');
  is_deeply [@{$el->class_list}], ['ab', 'cd'];

  $attr->text_content ('ab c ab');
  is_deeply [@{$el->class_list}], ['ab', 'c'];

  $doc->adopt_node ($attr);
  is_deeply [@{$el->class_list}], [];

  $el->set_attribute_ns ('http://www.w3.org/1999/xhtml', 'html:class', 'aa');
  is_deeply [@{$el->class_list}], [];

  $el->inner_html (q{<p class="foo"></p>});
  is_deeply [@{$el->first_child->class_list}], ['foo'];

  done $c;
} n => 16, name => 'class_list / attribute is set / attribute is removed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');

  is $el->id, '';

  $el->id ('hoge');
  is $el->id, 'hoge';

  $el->id (0);
  is $el->id, '0';

  $el->id (undef);
  is $el->id, '';

  done $c;
} n => 4, name => 'id';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');

  is $el->class_name, '';

  $el->class_name ('hoge');
  is $el->class_name, 'hoge';
  is_deeply [@{$el->class_list}], ['hoge'];

  $el->class_name (0);
  is $el->class_name, '0';
  is_deeply [@{$el->class_list}], ['0'];

  $el->class_name (undef);
  is $el->class_name, '';
  is_deeply [@{$el->class_list}], [];

  $el->class_name ('hoge fuga  ');
  is $el->class_name, 'hoge fuga  ';
  is_deeply [@{$el->class_list}], ['hoge', 'fuga'];

  done $c;
} n => 9, name => 'class_name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  my $tokens = $el->class_list;

  isa_ok $tokens, 'Web::DOM::TokenList';
  is scalar @$tokens, 0;

  push @$tokens, 'aaa';
  is $el->class_name, 'aaa';

  $el->set_attribute (class => 'bb  ccc  ');
  is ''.$tokens, 'bb  ccc  ';
  is $el->get_attribute ('class'), 'bb  ccc  ';
  
  done $c;
} n => 5, name => 'class_list';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->class_list ('ab cd ab AAA');
  is $el->class_list->value, 'ab cd ab AAA';
  done $c;
} n => 1, name => 'class_list PutForwards';

run_tests;

=head1 LICENSE

Copyright 2012-2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
