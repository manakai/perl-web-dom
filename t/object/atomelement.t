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
    is $el->$method_name, '';
    
    $el->$method_name ('hge');
    is $el->$method_name, 'hge';
    is $el->get_attribute_ns (XML_NS, $local_name), 'hge';
    is $el->attributes->[0]->prefix, 'xml';
    
    $el->$method_name (undef);
    is $el->$method_name, '';
    is $el->attributes->length, 1;
    
    $el->$method_name (0);
    is $el->$method_name, '0';
    
    done $c;
  } n => 7, name => [$method_name, $local_name, 'string xml attr'];
}

for my $test (
  ['rights', 'type', undef, 'text'],
  ['subtitle', 'type', undef, 'text'],
  ['summary', 'type', undef, 'text'],
  ['title', 'type', undef, 'text'],
  ['content', 'type', undef, 'text'],
  ['category', 'term', undef, ''],
  ['category', 'label', undef, ''],
  ['generator', 'version', undef, ''],
  ['link', 'type', undef, ''],
  ['in-reply-to', 'type', undef, '', ATOM_THREAD_NS],
) {
  my $attr = $test->[1];
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ($test->[4] || ATOM_NS, $test->[0]);
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

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'link');
  is $el->rel, '';

  $el->rel ('hoge');
  is $el->rel, 'http://www.iana.org/assignments/relation/hoge';
  is $el->get_attribute_ns (undef, 'rel'), 'hoge';

  $el->rel ('');
  is $el->rel, 'http://www.iana.org/assignments/relation/';
  is $el->get_attribute_ns (undef, 'rel'), '';

  $el->rel ('http://www.iana.org/assignments/relation/');
  is $el->rel, 'http://www.iana.org/assignments/relation/';
  is $el->get_attribute_ns (undef, 'rel'),
      'http://www.iana.org/assignments/relation/';

  $el->rel ('http://hoge/');
  is $el->rel, 'http://hoge/';
  is $el->get_attribute_ns (undef, 'rel'), 'http://hoge/';

  $el->rel ('hogeF');
  is $el->rel, 'http://www.iana.org/assignments/relation/hogeF';
  is $el->get_attribute_ns (undef, 'rel'), 'hogeF';

  $el->rel ('http://www.iana.org/assignments/relation/hoge');
  is $el->rel, 'http://www.iana.org/assignments/relation/hoge';
  is $el->get_attribute_ns (undef, 'rel'), 'hoge';

  $el->rel ("http://www.iana.org/assignments/relation/hoge\x0A");
  is $el->rel, "http://www.iana.org/assignments/relation/hoge\x0A";
  is $el->get_attribute_ns (undef, 'rel'), "hoge\x0A";

  $el->rel ('ho/ge?');
  is $el->rel, 'http://www.iana.org/assignments/relation/ho/ge?';
  is $el->get_attribute ('rel'), 'ho/ge?';

  $el->set_attribute (rel => 'http://www.iana.org/assignments/relation/hoge');
  is $el->rel, 'http://www.iana.org/assignments/relation/hoge';

  $el->rel ('http://www.iana.org/assignments/relation/ho:ge');
  is $el->rel, 'http://www.iana.org/assignments/relation/ho:ge';
  is $el->get_attribute ('rel'), 'http://www.iana.org/assignments/relation/ho:ge';

  done $c;
} n => 20, name => 'link.rel';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'link');

  $el->rel ('replies');
  is $el->type, 'application/atom+xml';

  $el->set_attribute (rel => 'http://www.iana.org/assignments/relation/replies');
  is $el->type, 'application/atom+xml';

  $el->rel ('Replies');
  is $el->type, '';

  done $c;
} n => 3, name => 'link.type rel=replies';

for my $el_name (qw(rights subtitle summary title content)) {
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

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'content');
  $el->set_attribute (src => '');
  is $el->container, undef;
  done $c;
} n => 1, name => 'container src';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'content');
  my $div = $doc->create_element ('div');
  $el->append_child ($div);
  $el->set_attribute (type => 'xhtml');
  $el->set_attribute (src => '');
  is $el->container, $div;
  done $c;
} n => 1, name => 'container src';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'content');
  $el->set_attribute (type => 'xhtml');
  $el->set_attribute (src => '');
  is $el->container, undef;
  done $c;
} n => 1, name => 'container src';

for (
  ['author', 'name'],
  ['author', 'email'],
  ['contributor', 'name'],
  ['contributor', 'email'],
  ['feed', 'id', 'atom_id'],
  ['entry', 'id', 'atom_id'],
  ['source', 'id', 'atom_id'],
) {
  my ($el_name, $cel_name, $method_name) = @$_;
  $method_name ||= $cel_name;
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (ATOM_NS, $el_name);
    is $el->$method_name, '';
    $el->$method_name ('hoge');
    is $el->$method_name, 'hoge';
    is $el->child_nodes->length, 1;
    is $el->child_nodes->[0]->node_type, 1;
    is $el->child_nodes->[0]->namespace_uri, ATOM_NS;
    is $el->child_nodes->[0]->local_name, $cel_name;
    is $el->child_nodes->[0]->child_nodes->length, 1;
    is $el->child_nodes->[0]->child_nodes->[0]->node_type, 3;
    is $el->child_nodes->[0]->text_content, 'hoge';
    $el->$method_name ('fuga');
    is $el->child_nodes->[0]->text_content, 'fuga';
    $el->$method_name ('');
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
    is $el->$method_name, 'fugaabcd';
    $el->$method_name ('abc<&');
    is $el3->inner_html, 'abc&lt;&amp;';
    done $c;
  } n => 2, name => ['string setter / existing elements',
                     $el_name, $cel_name];
}

for (
  ['author', 'uri'],
  ['feed', 'icon'],
  ['feed', 'logo'],
  ['source', 'icon'],
  ['source', 'logo'],
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
    is $el->$cel_name, '';
    $el->$cel_name ('abc<&');
    is $el3->inner_html, 'abc&lt;&amp;';
    done $c;
  } n => 3, name => ['url setter / existing elements',
                     $el_name, $cel_name];
} # $el_name, $cel_name

for (
  ['content', 'src'],
  ['category', 'scheme'],
  ['generator', 'uri'],
  ['link', 'href'],
  ['in-reply-to', 'href', ATOM_THREAD_NS],
  ['in-reply-to', 'ref', ATOM_THREAD_NS],
  ['in-reply-to', 'source', ATOM_THREAD_NS],
) {
  my ($el_name, $cel_name, $ns) = @$_;
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ($ns || ATOM_NS, $el_name);
    is $el->$cel_name, '';
    $el->$cel_name ('http://hoge/');
    is $el->$cel_name, 'http://hoge/';
    is $el->attributes->length, 1;
    is $el->attributes->[0]->node_type, 2;
    is $el->attributes->[0]->namespace_uri, undef;
    is $el->attributes->[0]->local_name, $cel_name;
    is $el->attributes->[0]->value, 'http://hoge/';
    $el->$cel_name ('fuga');
    is $el->attributes->[0]->value, 'fuga';
    is $el->$cel_name, 'fuga';
    $el->$cel_name ('');
    is $el->attributes->[0]->value, '';
    $el->set_attribute_ns (XML_NS, 'xml:base' => 'hoge:');
    is $el->$cel_name, 'about:blank';
    done $c;
  } n => 11, name => ['url attr setter', $el_name, $cel_name];
} # $el_name, $cel_name

for (
  ['author', 'name'],
  ['contributor', 'name'],
  ['feed', 'generator'],
  ['feed', 'subtitle'],
  ['feed', 'title'],
  ['feed', 'updated'],
  ['feed', 'rights'],
  ['entry', 'content'],
  ['entry', 'published'],
  ['entry', 'rights'],
  ['entry', 'source'],
  ['entry', 'summary'],
  ['entry', 'title'],
  ['entry', 'updated'],
  ['source', 'generator'],
  ['source', 'rights'],
  ['source', 'subtitle'],
  ['source', 'title'],
  ['source', 'updated'],
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

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->dom_config->{manakai_create_child_element} = 1;
    my $el = $doc->create_element_ns (ATOM_NS, $el_name);
    my $el3 = $doc->create_element_ns (ATOM_NS, 'entry');
    $el->append_child ($el3);
    my $el2 = $el->$method_name;
    isa_ok $el2, 'Web::DOM::Element';
    is $el2->namespace_uri, ATOM_NS;
    is $el2->local_name, $cel_name;
    is $el->$method_name, $el2;
    if ($el_name eq 'feed') {
      is $el2->previous_sibling, undef;
      is $el3->previous_sibling, $el2;
    } else {
      is $el2->previous_sibling, $el3;
      is $el3->previous_sibling, undef;
    }
    done $c;
  } n => 6, name => ['child element reflect, after', $el_name, $cel_name];
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
      '-2013-05-01T00:12:44Z',
      '2013-05-01T00:12:44',
      ' 2013-05-01T00:12:44  ',
      '29999-12-31T23:59:59Z',
      '+29999-12-31T23:59:59Z',
    ) {
      $el->text_content ($_);
      is $el->value, 0;
    }

    $el->text_content ('2013-05-01t00:12:44Z');
    is $el->value, 1367367164;

    $el->text_content ('2013-05-01T00:12:44z');
    is $el->value, 1367367164;

    $el->text_content ('hoge');
    for (
      -12415 + -62135596800 - 367*12*24*3600,
      -1 + -62135596800 - 367*12*24*3600,
      -0.001 + -62135596800 - 367*12*24*3600,
    ) {
      $el->value ($_);
      is $el->text_content, 'hoge';
    }

    $el->value (884541340799);
    is $el->text_content, '29999-12-31T23:59:59Z';

    $el->value (1430272255.912);
    is $el->value, 1430272255.912;
    like $el->text_content, qr/\A2015-04-29T01:50:55.91[0-9]+Z\z/;

    $el->text_content ('2015-04-29T01:50:55.0001Z');
    is $el->value, 1430272255.0001;
    $el->value (1430272255.0001);
    like $el->text_content, qr/\A2015-04-29T01:50:55.000[0-9]+Z\z/;

    $el->text_content ('2015-04-29T01:50:55.9015Z');
    is $el->value, 1430272255.9015;
    $el->value (1430272255.9015);
    like $el->text_content, qr/\A2015-04-29T01:50:55.901[0-9]+Z\z/;

    $el->text_content ('1015-04-29T01:50:55.000Z');
    is $el->value, -30126722945, '55.000Z';
    $el->text_content ('1015-04-29T01:50:55.0001Z');
    is $el->value, -30126722944.9999;
    $el->value (-30126722944.9999);
    like $el->text_content, qr/\A1015-04-29T01:50:55.0000[0-9]+Z\z/;

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

for my $test (
  {el => 'link', 'prefix' => 'thr', name => 'updated', ns => ATOM_THREAD_NS,
   method => 'thread_updated'},
) {
  my $method = $test->{method};
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (ATOM_NS, $test->{el});
    is $el->$method, 0;

    $el->$method (155);
    is $el->$method, 155;
    is $el->get_attribute_ns ($test->{ns}, $test->{name}),
        '1970-01-01T00:02:35Z';
    is $el->attributes->length, 1;

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
    ) {
      $el->$method ($_->[0]);
      is $el->$method, $_->[0], "$_->[0] roundtrip";
      is $el->get_attribute_ns ($test->{ns}, $test->{name}),
          $_->[2] || $_->[1], "$_->[0] -> date";
      is $el->attributes->length, 1;

      $el->set_attribute_ns ($test->{ns}, ['hoge', $test->{name}] => $_->[1]);
      is $el->$method, $_->[0], "$_->[1] -> $method";
    }

    for (
      '',
      'abc',
      '2013-05-01 00:12:44Z',
      '-2013-05-01T00:12:44Z',
      '2013-05-01T00:12:44',
      ' 2013-05-01T00:12:44  ',
    ) {
      $el->set_attribute_ns ($test->{ns}, [undef, $test->{name}] => $_);
      is $el->$method, 0;
    }

    $el->set_attribute_ns ($test->{ns}, [undef, $test->{name}] => '2013-05-01t00:12:44Z');
    is $el->$method, 1367367164;

    $el->set_attribute_ns ($test->{ns}, [undef, $test->{name}] => '2013-05-01T00:12:44z');
    is $el->$method, 1367367164;

    $el->set_attribute_ns ($test->{ns}, [undef, $test->{name}] => 'hoge');
    for (
      -12415 + -62135596800 - 367*12*24*3600,
      -1 + -62135596800 - 367*12*24*3600,
      -0.001 + -62135596800 - 367*12*24*3600,
    ) {
      $el->$method ($_);
      is $el->get_attribute_ns ($test->{ns}, $test->{name}), 'hoge';
    }

    $el->$method (1430272255.912);
    is $el->$method, 1430272255.912;
    like $el->get_attribute_ns ($test->{ns}, $test->{name}),
        qr/\A2015-04-29T01:50:55.91[0-9]+Z\z/;

    $el->set_attribute_ns
        ($test->{ns}, [undef, $test->{name}] => '2015-04-29T01:50:55.0001Z');
    is $el->$method, 1430272255.0001;
    $el->$method (1430272255.0001);
    like $el->get_attribute_ns ($test->{ns}, $test->{name}),
        qr/\A2015-04-29T01:50:55.000[0-9]+Z\z/;

    $el->set_attribute_ns
        ($test->{ns}, [undef, $test->{name}] => '2015-04-29T01:50:55.9015Z');
    is $el->$method, 1430272255.9015;
    $el->$method (1430272255.9015);
    like $el->get_attribute_ns ($test->{ns}, $test->{name}),
        qr/\A2015-04-29T01:50:55.901[0-9]+Z\z/;

    $el->set_attribute_ns
        ($test->{ns}, [undef, $test->{name}] => '1015-04-29T01:50:55.000Z');
    is $el->$method, -30126722945, '55.000Z';
    $el->set_attribute_ns
        ($test->{ns}, [undef, $test->{name}] => '1015-04-29T01:50:55.0001Z');
    is $el->$method, -30126722944.9999;
    $el->$method (-30126722944.9999);
    like $el->get_attribute_ns ($test->{ns}, $test->{name}),
        qr/\A1015-04-29T01:50:55.00009[0-9]+Z\z/;

    done $c;
  } n => 4 + 13*4 + 6 + 2 + 3 + 9, name => ['datetime', $method, %$test];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (ATOM_NS, $test->{el});

    $method; # Perl 5.8 compat
    for my $value (0+"nan", 0+"inf", 0-"inf") {
      dies_here_ok {
        $el->$method ($value);
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->message, 'The value is out of range';
      
      is $el->get_attribute_ns ($test->{ns}, $test->{name}), undef;
      is $el->attributes->[0], undef;
    }

    done $c;
  } n => 5 * 3, name => ['datetime', $method, %$test, 'webidl domperl'];
} # $test

for my $test (
  {parent => 'feed', child => 'author', method => 'author_elements'},
  {parent => 'feed', child => 'category', method => 'category_elements'},
  {parent => 'feed', child => 'contributor', method => 'contributor_elements'},
  {parent => 'feed', child => 'link', method => 'link_elements'},
  {parent => 'feed', child => 'entry', method => 'entry_elements'},
  {parent => 'entry', child => 'author', method => 'author_elements'},
  {parent => 'entry', child => 'category', method => 'category_elements'},
  {parent => 'entry', child => 'contributor',
   method => 'contributor_elements'},
  {parent => 'entry', child => 'link', method => 'link_elements'},
  {parent => 'entry', child => 'in-reply-to', ns => ATOM_THREAD_NS,
   method => 'thread_in_reply_to_elements'},
  {parent => 'source', child => 'author', method => 'author_elements'},
  {parent => 'source', child => 'category', method => 'category_elements'},
  {parent => 'source', child => 'contributor',
   method => 'contributor_elements'},
  {parent => 'source', child => 'link', method => 'link_elements'},
) {
  my $method = $test->{method};
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (ATOM_NS, $test->{parent});
    my $list = $el->$method;
    isa_ok $list, 'Web::DOM::HTMLCollection';
    is $el->$method, $list;
    is $list->length, 0;

    my $el1 = $doc->create_element_ns
        ($test->{ns} || ATOM_NS, $test->{child});
    $el->append_child ($el1);
    
    is $list->length, 1;
    is $list->[0], $el1;

    my $el2 = $doc->create_element_ns (undef, $test->{child});
    $el->append_child ($el2);
    $el->append_child ($doc->create_text_node ('hoge'));
    my $el3 = $doc->create_element_ns
        ($test->{ns} || ATOM_NS, $test->{child});
    $el->append_child ($el3);
    my $el4 = $doc->create_element_ns
        ($test->{ns} || ATOM_NS, 'hoge');
    my $el5 = $doc->create_element_ns
        ($test->{ns} || ATOM_NS, $test->{child});
    $el4->append_child ($el5);
    $el->append_child ($el4);

    is $list->length, 2;
    is $list->[1], $el3;

    $el->remove_child ($el1);

    is $list->length, 1;
    is $list->[0], $el3;

    done $c;
  } n => 9, name => ['htmlcollection', $test->{parent}, $test->{method}];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'feed');
  is $el->get_entry_element_by_id (''), undef;
  is $el->get_entry_element_by_id ('hoge'), undef;
  is $el->get_entry_element_by_id ('fuga abc'), undef;
  done $c;
} n => 3, name => 'get_entry_element_by_id empty element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'feed');
  my $entry0 = $doc->create_element_ns (undef, 'entry');
  my $id0 = $doc->create_element_ns (ATOM_NS, 'id');
  $id0->text_content ('fuga fuga');
  $entry0->append_child ($id0);
  my $entry1 = $doc->create_element_ns (ATOM_NS, 'entry');
  $entry1->atom_id ('fuga fuga');
  my $entry2 = $doc->create_element_ns (ATOM_NS, 'entry');
  $entry2->atom_id ('fuga fuga');
  is $el->get_entry_element_by_id ('fuga fuga'), undef;
  $el->append_child ($entry1);
  $el->append_child ($entry2);
  is $el->get_entry_element_by_id ('fuga fuga'), $entry1;
  $entry1->atom_id ('abc');
  is $el->get_entry_element_by_id ('fuga fuga'), $entry2;
  is $el->get_entry_element_by_id ('abc'), $entry1;
  done $c;
} n => 4, name => 'get_entry_element_by_id non empty element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'feed');
  
  my $entry = $el->add_new_entry ('hoge');
  is $el->first_child, $entry;
  is $el->last_child, $entry;

  is $entry->namespace_uri, ATOM_NS;
  is $entry->local_name, 'entry';

  is $entry->atom_id, 'hoge';
  is $entry->title_element->text_content, '';
  is $entry->xmllang, '';
  is $entry->attributes->length, 1;
  is $entry->child_nodes->length, 3;
  is $entry->child_nodes->[0]->local_name, 'id';
  is $entry->child_nodes->[1]->local_name, 'title';
  is $entry->child_nodes->[2]->local_name, 'updated';
  done $c;
} n => 12, name => 'add_new_entry id only';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'feed');
  
  my $entry = $el->add_new_entry ('hoge', 'aa', 'bb', 'cc');
  is $el->first_child, $entry;
  is $el->last_child, $entry;

  is $entry->namespace_uri, ATOM_NS;
  is $entry->local_name, 'entry';

  is $entry->atom_id, 'hoge';
  is $entry->title_element->text_content, 'aa';
  is $entry->xmllang, 'bb';
  is $entry->attributes->[0]->prefix, 'xml';
  is $entry->attributes->length, 1;
  is $entry->child_nodes->length, 3;
  is $entry->child_nodes->[0]->local_name, 'id';
  is $entry->child_nodes->[1]->local_name, 'title';
  is $entry->child_nodes->[2]->local_name, 'updated';
  done $c;
} n => 13, name => 'add_new_entry id title lang';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'entry');
  my $list = $el->entry_author_elements;
  is $list, $el->author_elements;
  isa_ok $list, 'Web::DOM::HTMLCollection';
  done $c;
} n => 2, name => 'entry_author_elements empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'entry');
  my $el2 = $doc->create_element_ns (ATOM_NS, 'author');
  $el->append_child ($el2);
  my $list = $el->entry_author_elements;
  is $list, $el->author_elements;
  isa_ok $list, 'Web::DOM::HTMLCollection';
  done $c;
} n => 2, name => 'entry_author_elements has author';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'entry');
  my $el2 = $doc->create_element_ns (ATOM_NS, 'author');
  $el->append_child ($el2);
  my $el3 = $doc->create_element_ns (ATOM_NS, 'source');
  my $el4 = $doc->create_element_ns (ATOM_NS, 'author');
  $el3->append_child ($el4);
  $el->append_child ($el3);
  my $list = $el->entry_author_elements;
  is $list, $el->author_elements;
  isa_ok $list, 'Web::DOM::HTMLCollection';
  done $c;
} n => 2, name => 'entry_author_elements has author, source > author';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'entry');
  my $el2 = $doc->create_element_ns (undef, 'author');
  $el->append_child ($el2);
  my $el3 = $doc->create_element_ns (ATOM_NS, 'source');
  my $el4 = $doc->create_element_ns (ATOM_NS, 'author');
  $el3->append_child ($el4);
  $el->append_child ($el3);
  my $list = $el->entry_author_elements;
  is $list, $el3->author_elements;
  isa_ok $list, 'Web::DOM::HTMLCollection';
  done $c;
} n => 2, name => 'entry_author_elements has source > author';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'entry');
  my $el3 = $doc->create_element_ns (ATOM_NS, 'source');
  $el->append_child ($el3);
  my $list = $el->entry_author_elements;
  is $list, $el3->author_elements;
  isa_ok $list, 'Web::DOM::HTMLCollection';
  done $c;
} n => 2, name => 'entry_author_elements has source';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'entry');
  my $el3 = $doc->create_element_ns (ATOM_NS, 'source');
  $el->append_child ($el3);
  my $el4 = $doc->create_element_ns (ATOM_NS, 'feed');
  $el4->append_child ($el);
  my $list = $el->entry_author_elements;
  is $list, $el3->author_elements;
  isa_ok $list, 'Web::DOM::HTMLCollection';
  done $c;
} n => 2, name => 'entry_author_elements has feed, source';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'entry');
  my $el4 = $doc->create_element_ns (ATOM_NS, 'feed');
  $el4->append_child ($el);
  my $list = $el->entry_author_elements;
  is $list, $el4->author_elements;
  isa_ok $list, 'Web::DOM::HTMLCollection';
  done $c;
} n => 2, name => 'entry_author_elements has feed parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'entry');
  my $el2 = $doc->create_element_ns (ATOM_NS, 'author');
  $el->append_child ($el2);
  my $el4 = $doc->create_element_ns (ATOM_NS, 'feed');
  $el4->append_child ($el);
  my $list = $el->entry_author_elements;
  is $list, $el->author_elements;
  isa_ok $list, 'Web::DOM::HTMLCollection';
  done $c;
} n => 2, name => 'entry_author_elements has feed parent, author';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'entry');
  is $el->entry_rights_element, undef;
  done $c;
} n => 1, name => 'entry_rights_element empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'entry');
  my $el2 = $doc->create_element_ns (ATOM_NS, 'rights');
  $el->append_child ($el2);
  is $el->entry_rights_element, $el2;
  done $c;
} n => 1, name => 'entry_rights_element has rights';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'entry');
  my $el2 = $doc->create_element_ns (ATOM_NS, 'rights');
  my $el3 = $doc->create_element_ns (ATOM_NS, 'rights');
  $el->append_child ($el2);
  $el->append_child ($el3);
  is $el->entry_rights_element, $el2;
  done $c;
} n => 1, name => 'entry_rights_element has multiple rights';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'entry');
  my $el2 = $doc->create_element_ns (undef, 'rights');
  my $el3 = $doc->create_element_ns (ATOM_NS, 'rights');
  $el->append_child ($el2);
  $el->append_child ($el3);
  is $el->entry_rights_element, $el3;
  done $c;
} n => 1, name => 'entry_rights_element has a rights';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'entry');
  my $el2 = $doc->create_element_ns (ATOM_NS, 'feed');
  my $el3 = $doc->create_element_ns (ATOM_NS, 'rights');
  $el2->append_child ($el);
  $el2->append_child ($el3);
  is $el->entry_rights_element, $el3;
  done $c;
} n => 1, name => 'entry_rights_element has feed rights';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'entry');
  my $el2 = $doc->create_element_ns (ATOM_NS, 'feed');
  $el2->append_child ($el);
  $doc->dom_config->{manakai_create_child_element} = 1;
  my $node = $el->entry_rights_element;
  is $node, $el->first_child;
  is $node->namespace_uri, ATOM_NS;
  is $node->local_name, 'rights';
  is $node->parent_node, $el;
  is $el2->child_nodes->length, 1;
  done $c;
} n => 5, name => 'entry_rights_element create element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'link');

  is $el->thread_count, 0;

  $el->thread_count (125);
  is $el->thread_count, 125;
  is $el->get_attribute_ns (ATOM_THREAD_NS, 'count'), '125';

  $el->thread_count (0);
  is $el->thread_count, 0;
  is $el->get_attribute_ns (ATOM_THREAD_NS, 'count'), '0';

  $el->thread_count (-125 + 2**32);
  is $el->thread_count, 0;
  is $el->get_attribute_ns (ATOM_THREAD_NS, 'count'), '4294967171';
  is $el->attributes->[0]->prefix, 'thr';

  $el->thread_count (2**31 - 1);
  is $el->thread_count, 2147483647;
  is $el->get_attribute_ns (ATOM_THREAD_NS, 'count'), '2147483647';
  is $el->attributes->[0]->prefix, 'thr';

  $el->attributes->[0]->prefix ('thread');
  $el->thread_count (1242.41);
  is $el->thread_count, 1242;
  is $el->get_attribute_ns (ATOM_THREAD_NS, 'count'), '1242';
  is $el->attributes->[0]->prefix, 'thread';

  $el->set_attribute_ns (ATOM_THREAD_NS, 'count' => 'abc');
  is $el->thread_count, 0;

  $el->set_attribute_ns (ATOM_THREAD_NS, 'count' => '+120.13abc');
  is $el->thread_count, 120;

  $el->set_attribute_ns (ATOM_THREAD_NS, 'count' => '-5000');
  is $el->thread_count, 0;

  done $c;
} n => 17, name => 'link.thread_count';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_NS, 'link');
  $el->thread_updated (124);
  is $el->attributes->[0]->prefix, 'thr';

  $el->attributes->[0]->prefix ('thread');
  $el->thread_updated (171);
  is $el->attributes->[0]->prefix, 'thread';

  done $c;
} n => 2, name => 'link.thread_updated namespace prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (ATOM_THREAD_NS, 'total');

  is $el->value, 0;

  $el->value (125);
  is $el->value, 125;
  is $el->text_content, '125';

  $el->value (0);
  is $el->value, 0;
  is $el->text_content, '0';

  $el->value (-125 + 2**32);
  is $el->value, 0;
  is $el->text_content, '4294967171';

  $el->value (2**31 - 1);
  is $el->value, 2147483647;
  is $el->text_content, '2147483647';

  $el->value (1242.41);
  is $el->value, 1242;
  is $el->text_content, '1242';

  $el->text_content ('abc');
  is $el->value, 0;

  $el->text_content ('+120.13abc');
  is $el->value, 120;

  $el->text_content ('-5000');
  is $el->value, 0;
  
  $el->text_content ('');
  $el->append_child ($doc->create_element ('hoge'))
      ->append_child ($doc->create_text_node ('134'));
  $el->append_child ($doc->create_text_node ('5'));
  is $el->value, 1345;

  done $c;
} n => 15, name => 'total.value';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
