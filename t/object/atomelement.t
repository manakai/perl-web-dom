use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
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

for (
  ['author', 'name'],
  ['author', 'email'],
  ['contributor', 'name'],
  ['contributor', 'email'],
) {
  my ($el_name, $cel_name) = @$_;
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (ATOM_NS, $el_name);
    is $el->$cel_name, '';
    $el->$cel_name ('hoge');
    is $el->$cel_name, 'hoge';
    is $el->child_nodes->length, 1;
    is $el->child_nodes->[0]->node_type, 1;
    is $el->child_nodes->[0]->namespace_uri, ATOM_NS;
    is $el->child_nodes->[0]->local_name, $cel_name;
    is $el->child_nodes->[0]->child_nodes->length, 1;
    is $el->child_nodes->[0]->child_nodes->[0]->node_type, 3;
    is $el->child_nodes->[0]->text_content, 'hoge';
    $el->$cel_name ('fuga');
    is $el->child_nodes->[0]->text_content, 'fuga';
    $el->$cel_name ('');
    is $el->child_nodes->[0]->child_nodes->length, 0;
    done $c;
  } n => 11, name => ['string setter', $el_name, $cel_name];
  
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (ATOM_NS, $el_name);
    my $el2 = $doc->create_element_ns (undef, $cel_name);
    $el2->text_content ('hoge');
    my $el3 = $doc->create_element_ns (ATOM_NS, 'atom:' . $cel_name);
    $el3->inner_html ('<p>fuga</p>abc<!---->d');
    $el->append_child ($el2);
    $el->append_child ($el3);
    is $el->$cel_name, 'fugaabcd';
    $el->$cel_name ('abc<&');
    is $el3->inner_html, 'abc&lt;&amp;';
    done $c;
  } n => 2, name => ['string setter / existing elements',
                     $el_name, $cel_name];
}

for (
  ['author', 'uri'],
) {
  my ($el_name, $cel_name) = @$_;
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (ATOM_NS, $el_name);
    is $el->$cel_name, '';
    $el->$cel_name ('http://hoge/');
    is $el->$cel_name, 'http://hoge/';
    is $el->child_nodes->length, 1;
    is $el->child_nodes->[0]->node_type, 1;
    is $el->child_nodes->[0]->namespace_uri, ATOM_NS;
    is $el->child_nodes->[0]->local_name, $cel_name;
    is $el->child_nodes->[0]->child_nodes->length, 1;
    is $el->child_nodes->[0]->child_nodes->[0]->node_type, 3;
    is $el->child_nodes->[0]->text_content, 'http://hoge/';
    $el->$cel_name ('fuga');
    is $el->child_nodes->[0]->text_content, 'fuga';
    is $el->$cel_name, '';
    $el->$cel_name ('');
    is $el->child_nodes->[0]->child_nodes->length, 0;
    done $c;
  } n => 12, name => ['url setter', $el_name, $cel_name];
  
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (ATOM_NS, $el_name);
    my $el2 = $doc->create_element_ns (undef, $cel_name);
    $el2->text_content ('hoge');
    my $el3 = $doc->create_element_ns (ATOM_NS, 'atom:' . $cel_name);
    $el3->inner_html ('<p>fuga</p>abc<!---->d');
    $el->append_child ($el2);
    $el->append_child ($el3);
    is $el->$cel_name, '';
    $el3->set_attribute_ns (XML_NS, 'base' => 'ftp://hoge');
    is $el->$cel_name, 'ftp://hoge/fugaabcd';
    $el->$cel_name ('abc<&');
    is $el3->inner_html, 'abc&lt;&amp;';
    done $c;
  } n => 3, name => ['url setter / existing elements',
                     $el_name, $cel_name];
} # $el_name, $cel_name

for (
  ['author', 'name'],
  ['contributor', 'name'],
) {
  my ($el_name, $cel_name) = @$_;
  my $method_name = $cel_name . '_element';
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (ATOM_NS, $el_name);
    my $el2 = $el->$method_name;
    is $el2, undef;
    my $el3 = $doc->create_element_ns (ATOM_NS, $cel_name);
    $el->append_child ($el3);
    is $el->$method_name, $el3;
    my $el4 = $doc->create_element_ns (undef, $cel_name);
    $el->insert_before ($el4, $el3);
    is $el->$method_name, $el3;
    $el->remove_child ($el3);
    is $el->$method_name, undef;
    done $c;
  } n => 4, name => ['child element reflect', $el_name, $cel_name];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->dom_config->{manakai_create_child_element} = 1;
    my $el = $doc->create_element_ns (ATOM_NS, $el_name);
    my $el2 = $el->$method_name;
    isa_ok $el2, 'Web::DOM::Element';
    is $el2->namespace_uri, ATOM_NS;
    is $el2->local_name, $cel_name;
    is $el->$method_name, $el2;
    done $c;
  } n => 4, name => ['child element reflect', $el_name, $cel_name];
} # $el_name, $cel_name

for my $test (
  ['published'],
  ['updated'],
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (ATOM_NS, $test->[0]);
    is $el->value, 0;

    $el->value (155);
    is $el->value, 155;
    is $el->text_content, '1970-01-01T00:02:35Z';
    is $el->child_nodes->length, 1;

    for (
      [-62135596800, '0001-01-01T00:00:00Z'],
      [-61785086115, '0012-02-09T20:04:45Z'],
      [-59323550115, '0090-02-09T20:04:45Z'],
      [-30228177315, '1012-02-09T20:04:45Z'],
      [-4982615715, '1812-02-09T20:04:45Z'],
      [-154324515, '1965-02-09T20:04:45Z'],
      [-124515, '1969-12-30T13:24:45Z'],
      [0, '1970-01-01T00:00:00Z'],
      [515123455, '1986-04-29T01:50:55Z'],
      [15252151635, '2453-04-27T12:47:15Z'],
      [133485926399, '6199-12-31T23:59:59Z'],
      [193444156799, '8099-12-31T23:59:59Z'],
      [253402300799, '9999-12-31T23:59:59Z'],
      [884541340799, '29999-12-31T23:59:59Z'],
    ) {
      $el->value ($_->[0]);
      is $el->value, $_->[0], "$_->[0] roundtrip";
      is $el->text_content, $_->[2] || $_->[1], "$_->[0] -> date";
      is $el->child_nodes->length, 1;

      $el->inner_html ("<p>$_->[1]</p>");
      is $el->value, $_->[0], "$_->[1] -> value";

      #use DateTime;
      #my $dt = DateTime->from_epoch (epoch => $_->[0]);
      #is $dt->ymd('-') . 'T' . $dt->hms(':') . 'Z', $_->[1];
    }

    for (
      '',
      'abc',
      '2013-05-01 00:12:44Z',
      '2013-05-01t00:12:44Z',
      '-2013-05-01T00:12:44Z',
      '2013-05-01T00:12:44',
      ' 2013-05-01T00:12:44  ',
    ) {
      $el->text_content ($_);
      is $el->value, 0;
    }

    $el->text_content ('hoge');
    for (
      -12415 + -62135596800,
      -1 + -62135596800,
      -0.001 + -62135596800,
    ) {
      $el->value ($_);
      is $el->text_content, 'hoge';
    }

    $el->value (1430272255.912);
    is $el->value, 1430272255.912;
    is $el->text_content, '2015-04-29T01:50:55.912Z';

    $el->text_content ('2015-04-29T01:50:55.0001Z');
    is $el->value, 1430272255.0001;
    $el->value (1430272255.0001);
    is $el->text_content, '2015-04-29T01:50:55.0001Z';

    $el->text_content ('2015-04-29T01:50:55.9015Z');
    is $el->value, 1430272255.9015;
    $el->value (1430272255.9015);
    is $el->text_content, '2015-04-29T01:50:55.9015Z';

    $el->text_content ('1015-04-29T01:50:55.000Z');
    is $el->value, -30126722945, '55.000Z';
    $el->text_content ('1015-04-29T01:50:55.0001Z');
    is $el->value, -30126722944.9999;
    $el->value (-30126722944.9999);
    is $el->text_content, '1015-04-29T01:50:55.000099Z';

    done $c;
  } n => 4 + 14*4 + 7 + 3 + 9, name => ['AtomDateConstruct.value', @$test];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (ATOM_NS, $test->[0]);

    for my $value (0+"nan", 0+"inf", 0-"inf") {
      dies_here_ok {
        $el->value ($value);
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->message, 'The value is out of range';
      
      is $el->text_content, '';
      is $el->first_child, undef;
    }

    done $c;
  } n => 5 * 3, name => ['AtomDateConstruct.value', @$test, 'webidl domperl'];
    
} # $test

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
