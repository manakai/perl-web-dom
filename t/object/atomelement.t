use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::Document;
use Web::DOM::Internal;

for (
  ['xmlbase', 'base'],
  ['xmllang', 'lang'],
) {
  my ($method_name, $local_name) = @$_;
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (ATOM_NS, 'hoge');
    is $el->xmlbase, '';
    
    $el->xmlbase ('hge');
    is $el->xmlbase, 'hge';
    is $el->get_attribute_ns (XML_NS, 'base'), 'hge';
    is $el->attributes->[0]->prefix, 'xml';
    
    $el->xmlbase (undef);
    is $el->xmlbase, '';
    is $el->attributes->length, 1;
    
    $el->xmlbase (0);
    is $el->xmlbase, '0';
    
    done $c;
  } n => 7, name => [$method_name, $local_name, 'string xml attr'];
}

for my $test (
  ['rights', 'type', undef, 'text'],
  ['subtitle', 'type', undef, 'text'],
  ['summary', 'type', undef, 'text'],
  ['title', 'type', undef, 'text'],
) {
  my $attr = $test->[1];
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (ATOM_NS, $test->[0]);
    is $el->$attr, $test->[3];
    $el->$attr ('hoge ');
    is $el->$attr, 'hoge ';
    is $el->get_attribute ($test->[2] || $attr), 'hoge ';
    $el->$attr ('0');
    is $el->$attr, '0';
    $el->$attr ('');
    is $el->$attr, '';
    $el->set_attribute ($test->[2] || $attr => 124);
    is $el->$attr, 124;
    $el->$attr ("\x{5000}");
    is $el->$attr, "\x{5000}";
    $el->$attr (undef);
    is $el->$attr, '';
    $el->set_attribute ($test->[2] || $attr => 124);
    is $el->$attr, 124;
    done $c;
  } n => 9, name => ['string reflect attributes', @$test];
}

for my $el_name (qw(rights subtitle summary title)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (ATOM_NS, $el_name);
    my $el2 = $el->container;
    is $el2, $el;
    my $el3 = $doc->create_element ('div');
    $el->append_child ($el3);
    is $el->container, $el;
    done $c;
  } n => 2, name => [$el_name, 'textconstruct.container', 'no type attr'];

  for my $type (qw(text html hoge HTML)) {
    test {
      my $c = shift;
      my $doc = new Web::DOM::Document;
      my $el = $doc->create_element_ns (ATOM_NS, $el_name);
      $el->set_attribute (type => $type);
      my $el2 = $el->container;
      is $el2, $el;
      my $el3 = $doc->create_element ('div');
      $el->append_child ($el3);
      is $el->container, $el;
      done $c;
    } n => 2, name => [$el_name, 'textconstruct.container', $type];
  }

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (ATOM_NS, $el_name);
    $el->set_attribute (type => 'xhtml');
    my $el2 = $el->container;
    is $el2, undef;
    my $el3 = $doc->create_element ('div');
    $el->append_child ($el3);
    is $el->container, $el3;
    my $el4 = $doc->create_element_ns (undef, 'div');
    $el->insert_before ($el4, $el3);
    is $el->container, $el3;
    $el->remove_child ($el3);
    is $el->container, undef;
    done $c;
  } n => 4, name => [$el_name, 'textconstruct.container', 'xhtml'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->dom_config->{manakai_create_child_element} = 1;
    my $el = $doc->create_element_ns (ATOM_NS, $el_name);
    $el->set_attribute (type => 'xhtml');
    my $el2 = $el->container;
    isa_ok $el2, 'Web::DOM::Element';
    is $el2->namespace_uri, HTML_NS;
    is $el2->local_name, 'div';
    is $el->container, $el2;
    done $c;
  } n => 4, name => [$el_name, 'textconstruct.container', 'xhtml', 'create'];
} # $el_name

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
