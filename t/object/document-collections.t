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
  my $el = $doc->create_element ('hoge');
  $el->id ('foo');
  $doc->append_child ($el);

  is $doc->get_element_by_id ('foo'), $el;
  is $doc->get_element_by_id ('FOO'), undef;

  done $c;
} n => 2, name => 'get_element_by_id';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('hoge');
  my $el2 = $doc->create_element ('hoge');
  $el2->id ('foo');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  is $doc->get_element_by_id ('foo'), $el2;
  is $doc->get_element_by_id ('FOO'), undef;

  done $c;
} n => 2, name => 'get_element_by_id';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('hoge');
  my $el2 = $doc->create_element ('hoge');
  my $el3 = $doc->create_element ('hoge');
  $el2->id ('foo');
  $el3->id ('foo');
  $doc->append_child ($el1);
  $el1->append_child ($el2);
  $el1->append_child ($el3);

  is $doc->get_element_by_id ('foo'), $el2;

  done $c;
} n => 1, name => 'get_element_by_id';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('hoge');
  my $el2 = $doc->create_element ('hoge');
  $el2->id ('');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  is $doc->get_element_by_id (''), undef;

  done $c;
} n => 1, name => 'get_element_by_id';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('hoge');
  my $el2 = $doc->create_element ('hoge');
  $el2->id ('120');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  is $doc->get_element_by_id ('120'), $el2;

  done $c;
} n => 1, name => 'get_element_by_id';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('hoge');
  my $el2 = $doc->create_element ('hoge');
  $el2->id ('abc  def');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  is $doc->get_element_by_id ('abc  def'), $el2;

  done $c;
} n => 1, name => 'get_element_by_id';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $col1 = $doc->images;
  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 0;
  is $doc->images, $col1;

  my $el1 = $doc->create_element ('img');
  $doc->append_child ($el1);

  is $doc->images->length, 1;
  is $col1->length, 1;
  is $col1->[0], $el1;

  my $el2 = $doc->create_element ('img');
  $el1->append_child ($el2);

  is $col1->length, 2;
  is $col1->[1], $el2;

  done $c;
} n => 8, name => 'images';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $col1 = $doc->embeds;
  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 0;
  is $doc->embeds, $col1;

  my $el1 = $doc->create_element ('embed');
  $doc->append_child ($el1);

  is $doc->embeds->length, 1;
  is $col1->length, 1;
  is $col1->[0], $el1;

  my $el2 = $doc->create_element ('embed');
  $el1->append_child ($el2);

  is $col1->length, 2;
  is $col1->[1], $el2;

  is $doc->plugins, $doc->embeds;
  is $doc->plugins, $doc->embeds;

  done $c;
} n => 10, name => 'embeds plugins';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $col1 = $doc->forms;
  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 0;
  is $doc->forms, $col1;

  my $el1 = $doc->create_element ('form');
  $doc->append_child ($el1);

  is $doc->forms->length, 1;
  is $col1->length, 1;
  is $col1->[0], $el1;

  my $el2 = $doc->create_element ('form');
  $el1->append_child ($el2);

  is $col1->length, 2;
  is $col1->[1], $el2;

  done $c;
} n => 8, name => 'forms';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $col1 = $doc->scripts;
  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 0;
  is $doc->scripts, $col1;

  my $el1 = $doc->create_element ('script');
  $doc->append_child ($el1);

  is $doc->scripts->length, 1;
  is $col1->length, 1;
  is $col1->[0], $el1;

  my $el2 = $doc->create_element ('script');
  $el1->append_child ($el2);

  is $col1->length, 2;
  is $col1->[1], $el2;

  done $c;
} n => 8, name => 'scripts';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $col1 = $doc->applets;
  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 0;
  is $doc->applets, $col1;

  my $el1 = $doc->create_element ('applet');
  $doc->append_child ($el1);

  is $doc->applets->length, 1;
  is $col1->length, 1;
  is $col1->[0], $el1;

  my $el2 = $doc->create_element ('applet');
  $el1->append_child ($el2);

  is $col1->length, 2;
  is $col1->[1], $el2;

  done $c;
} n => 8, name => 'applets';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $col1 = $doc->links;

  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 0;

  my $el1 = $doc->create_element ('a');
  $doc->append_child ($el1);

  is $col1->length, 0;

  my $el2 = $doc->create_element ('a');
  $el1->append_child ($el2);
  
  is $col1->length, 0;

  $el2->set_attribute (href => 'hoge');

  is $col1->length, 1;
  is $col1->[0], $el2;

  my $el3 = $doc->create_element ('area');
  $el1->append_child ($el3);

  is $col1->length, 1;

  $el3->set_attribute (href => '');

  is $col1->length, 2;
  is $col1->[1], $el3;

  $el2->remove_attribute ('href');
  is $col1->length, 1;
  is $col1->[0], $el3;

  $el1->remove_child ($el3);
  is $col1->length, 0;

  is $doc->links, $col1;
  
  done $c;
} n => 13, name => 'links';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $col1 = $doc->anchors;

  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 0;

  my $el1 = $doc->create_element ('a');
  $doc->append_child ($el1);

  is $col1->length, 0;

  my $el2 = $doc->create_element ('a');
  $el1->append_child ($el2);
  
  is $col1->length, 0;

  $el2->set_attribute (name => 'hoge');

  is $col1->length, 1;
  is $col1->[0], $el2;

  my $el3 = $doc->create_element ('area');
  $el1->append_child ($el3);

  is $col1->length, 1;

  $el3->set_attribute (name => '');

  is $col1->length, 1;
  is $col1->[0], $el2;

  $el2->remove_attribute ('name');
  is $col1->length, 0;

  $el1->remove_child ($el3);
  is $col1->length, 0;

  is $doc->anchors, $col1;
  
  done $c;
} n => 12, name => 'anchors';

for my $name ('', 'aaa', 'abc d') {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $col1 = $doc->get_elements_by_name ($name);
    isa_ok $col1, 'Web::DOM::NodeList';
    is $col1->length, 0;

    my $el1 = $doc->create_element ('agaw');
    $el1->set_attribute (name => 'abc');
    $doc->append_child ($el1);

    my $el2 = $doc->create_element ('agaw');
    $el2->set_attribute (name => $name);
    $el1->append_child ($el2);

    is $col1->length, 1;
    is $col1->[0], $el2;

    my $el3 = $doc->create_element ('input');
    $el3->set_attribute (name => 'aab');
    $el2->append_child ($el3);

    is $col1->length, 1;

    $el3->set_attribute (name => $name);

    is $col1->length, 2;
    is $col1->[1], $el3;

    $el2->remove_child ($el3);
    is $col1->length, 1;
    is $col1->[0], $el2;

    my $el4 = $doc->create_element_ns (undef, 'aa');
    $el4->set_attribute (name => $name);
    $el2->append_child ($el4);

    is $col1->length, 1;
    
    is $doc->get_elements_by_name ($name), $col1;
    isnt $doc->get_elements_by_name ('AAA'), $col1;
    
    done $c;
  } n => 12, name => ['get_elements_by_name', $name];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $col = $doc->all;
  isa_ok $col, 'Web::DOM::HTMLAllCollection';
  is $col->length, 0;
  is $doc->all, $col;
  done $c;
} n => 3, name => 'all empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  $doc->inner_html (q{<p>hoge<p>fiuga});
  my $col = $doc->all;
  isa_ok $col, 'Web::DOM::HTMLAllCollection';
  is $col->length, 5;
  is $doc->all, $col;
  is $col->[0]->local_name, 'html';
  is $col->[1]->local_name, 'head';
  is $col->[2]->local_name, 'body';
  is $col->[3]->local_name, 'p';
  is $col->[4]->local_name, 'p';
  $col->[4]->inner_html (q{ho<span>aaa</span>});
  is $col->length, 6;
  is $col->[3]->local_name, 'p';
  is $col->[4]->local_name, 'p';
  is $col->[5]->local_name, 'span';
  done $c;
} n => 12, name => 'all not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->name ('');
  $doc->append_child ($el);
  is $doc->all->{''}, undef;
  is $doc->all->named_item (''), undef;
  done $c;
} n => 2, name => 'all[empty]';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->id ('');
  $doc->append_child ($el);
  is $doc->all->{''}, undef;
  is $doc->all->named_item (''), undef;
  done $c;
} n => 2, name => 'all[empty]';

run_tests;

=head1 LICENSE

Copyright 2012-2014 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
