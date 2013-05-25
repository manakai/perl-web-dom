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
  ['feed', 'id', 'atom_id'],
  ['entry', 'id', 'atom_id'],
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
  is $entry->attributes->length, 1;
  is $entry->child_nodes->length, 3;
  is $entry->child_nodes->[0]->local_name, 'id';
  is $entry->child_nodes->[1]->local_name, 'title';
  is $entry->child_nodes->[2]->local_name, 'updated';
  done $c;
} n => 12, name => 'add_new_entry id title lang';

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

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
