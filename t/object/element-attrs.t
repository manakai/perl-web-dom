use strict;
use warnings;
no warnings 'utf8';
use Path::Tiny;
use lib glob path (__FILE__)->parent->parent->parent->child ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob path (__FILE__)->parent->parent->parent->child ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::Differences;
use Test::DOM::Exception;
use Web::DOM::Document;

{
  package test::DestroyCallback;
  sub DESTROY {
    $_[0]->();
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc,
    $doc->implementation->create_document_type ('a', '', ''),
    $doc->create_text_node ('b'),
    $doc->create_comment ('b'),
    $doc->create_processing_instruction ('cc', ''),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      my $attrs = $node->attributes;
      is $attrs, undef;
      ok not $node->has_attributes;
      done $c;
    } n => 2, name => ['attributes', $node->node_type];
  }
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $attrs = $el->attributes;
  isa_ok $attrs, 'Web::DOM::NamedNodeMap';
  is scalar @$attrs, 0;
  ok not $el->has_attributes;
  done $c;
} n => 3, name => 'attributes no attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute ('hoge' => '');
  my $attrs = $el->attributes;
  isa_ok $attrs, 'Web::DOM::NamedNodeMap';
  is scalar @$attrs, 1;
  ok $el->has_attributes;
  done $c;
} n => 3, name => 'attributes with simple attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('aa', 'hoge' => '');
  my $attrs = $el->attributes;
  isa_ok $attrs, 'Web::DOM::NamedNodeMap';
  is scalar @$attrs, 1;
  ok $el->has_attributes;
  done $c;
} n => 3, name => 'attributes with node attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute ('hoge' => '');
  $el->set_attribute_ns ('fuga', 'aaa' => 'bb');
  my $attrs = $el->attributes;
  isa_ok $attrs, 'Web::DOM::NamedNodeMap';
  is scalar @$attrs, 2;
  ok $el->has_attributes;
  done $c;
} n => 3, name => 'attributes with attrs';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute (hoge => 'fuga');

  my $attrs = $el->attributes;
  isa_ok $attrs, 'Web::DOM::NamedNodeMap';
  is $attrs->length, 1;
  is scalar @$attrs, 1;
  my $node1 = $attrs->[0];
  isa_ok $node1, 'Web::DOM::Attr';
  is $node1->namespace_uri, undef;
  is $node1->prefix, undef;
  is $node1->local_name, 'hoge';
  is $node1->value, 'fuga';
  is $attrs->[1], undef;
  is $attrs->item (0), $node1;

  $node1->value ('aaa');
  is $el->get_attribute ('hoge'), 'aaa';

  done $c;
} n => 11, name => 'attributes NamedNodeMap simple attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('aa', hoge => 'fuga');

  my $attrs = $el->attributes;
  isa_ok $attrs, 'Web::DOM::NamedNodeMap';
  is $attrs->length, 1;
  is scalar @$attrs, 1;
  my $node1 = $attrs->[0];
  isa_ok $node1, 'Web::DOM::Attr';
  is $node1->namespace_uri, 'aa';
  is $node1->prefix, undef;
  is $node1->local_name, 'hoge';
  is $node1->value, 'fuga';
  is $attrs->[1], undef;
  is $attrs->item (0), $node1;

  $node1->value ('aaa');
  is $el->get_attribute ('hoge'), 'aaa';

  done $c;
} n => 11, name => 'attributes NamedNodeMap node attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');

  is $el->get_attribute ('hoge'), undef;
  is $el->get_attribute ('fuga'), undef;
  is $el->get_attribute ('12'), undef;
  is $el->get_attribute ('xml:lang'), undef;
  is $el->get_attribute ('abc:lang'), undef;

  is $el->get_attribute_ns (undef, 'hoge'), undef;
  is $el->get_attribute_ns ('', 'hoge'), undef;
  is $el->get_attribute_ns ('http://hoge/', 'hoge'), undef;
  is $el->get_attribute_ns ('http://hoge/', 'fuga:hoge'), undef;
  is $el->get_attribute_ns ('http://hoge/', '210'), undef;

  done $c;
} n => 10, name => 'get attribute not found';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');

  $el->set_attribute (hoge => 'ab de');
  is $el->get_attribute ('hoge'), 'ab de';
  is $el->get_attribute_ns (undef, 'hoge'), 'ab de';
  is $el->get_attribute_ns ('', 'hoge'), 'ab de';

  done $c;
} n => 3, name => 'set_attribute new attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');

  $el->set_attribute_ns (undef, hoge => 'ab de');
  is $el->get_attribute ('hoge'), 'ab de';
  is $el->get_attribute_ns (undef, 'hoge'), 'ab de';
  is $el->get_attribute_ns ('', 'hoge'), 'ab de';

  done $c;
} n => 3, name => 'set_attribute_ns new attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');

  $el->set_attribute_ns ('http://hoge/', 'foo' => 'aa');
  is $el->get_attribute ('foo'), 'aa';
  is $el->get_attribute_ns ('http://hoge/', 'foo'), 'aa';
  is $el->get_attribute_ns ('http://fuga/', 'foo'), undef;
  is $el->get_attribute_ns (undef, 'foo'), undef;
  is $el->get_attribute_ns ('', 'foo'), undef;

  done $c;
} n => 5, name => 'set_attribute_ns new namespaced attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');

  $el->set_attribute_ns ('http://hoge/', 'hoge:foo' => 'aa');
  is $el->get_attribute ('foo'), undef;
  is $el->get_attribute ('hoge:foo'), 'aa';
  is $el->get_attribute_ns ('http://hoge/', 'foo'), 'aa';
  is $el->get_attribute_ns ('http://hoge/', 'hoge:foo'), undef;
  is $el->get_attribute_ns ('http://fuga/', 'foo'), undef;
  is $el->get_attribute_ns (undef, 'hoge:foo'), undef;
  is $el->get_attribute_ns (undef, 'foo'), undef;
  is $el->get_attribute_ns ('', 'foo'), undef;

  done $c;
} n => 8, name => 'set_attribute_ns new namespaced prefixed attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');
  $el->set_attribute (hoge => 'fuga');

  $el->set_attribute (hoge => 'aa bb');
  is $el->get_attribute ('hoge'), 'aa bb';

  $el->set_attribute_ns (undef, 'hoge' => 'bb ee ');
  is $el->get_attribute ('hoge'), 'bb ee ';

  done $c;
} n => 2, name => 'set change simple value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('aa', hoge => 'fuga');

  $el->set_attribute (hoge => 'aa bb');
  is $el->get_attribute_ns ('aa', 'hoge'), 'aa bb';

  $el->set_attribute_ns ('aa', 'hoge' => 'bb ee ');
  is $el->get_attribute_ns ('aa', 'hoge'), 'bb ee ';

  done $c;
} n => 2, name => 'set change node value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('aa', 'b:hoge' => 'fuga');

  $el->set_attribute ('b:hoge' => 'aa bb');
  is $el->get_attribute_ns ('aa', 'hoge'), 'aa bb';

  $el->set_attribute_ns ('aa', 'c:hoge' => 'bb ee ');
  is $el->get_attribute_ns ('aa', 'hoge'), 'bb ee ';

  done $c;
} n => 2, name => 'set change node value, changing prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');

  $el->set_attribute_ns (undef, hoge => 'fuga');
  $el->set_attribute_ns ('http://a/', hoge => 'a b');

  is $el->get_attribute ('hoge'), 'fuga';
  is $el->get_attribute_ns (undef, 'hoge'), 'fuga';
  is $el->get_attribute_ns ('http://a/', 'hoge'), 'a b';

  $el->set_attribute ('hoge' => 'AA');
  is $el->get_attribute_ns (undef, 'hoge'), 'AA';
  is $el->get_attribute_ns ('http://a/', 'hoge'), 'a b';
  
  done $c;
} n => 5, name => 'get/set attributes with same name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('f');
  $el->set_attribute ('bb' => 'cc');
  $el->set_attribute ('xx' => 'cc');
  $el->set_attribute_ns ('undef', 'gg' => 'cc');

  $el->set_attribute ('aa' => '');
  $el->set_attribute ('bb' => '');
  $el->set_attribute_ns (undef, 'xx' => '');
  $el->set_attribute_ns (undef, 'yy' => '');
  $el->set_attribute_ns ('undef', 'gg' => '');
  $el->set_attribute_ns ('undef', 'hh' => '');

  is $el->get_attribute ('aa'), '';
  is $el->get_attribute ('bb'), '';
  is $el->get_attribute ('xx'), '';
  is $el->get_attribute ('yy'), '';
  is $el->get_attribute_ns ('undef', 'gg'), '';
  is $el->get_attribute_ns ('undef', 'hh'), '';

  done $c;
} n => 6, name => 'set empty values';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('f');
  $el->set_attribute ('bb' => 'cc');
  $el->set_attribute ('xx' => 'cc');
  $el->set_attribute_ns ('undef', 'gg' => 'cc');

  $el->set_attribute ('aa' => undef);
  $el->set_attribute ('bb' => undef);
  $el->set_attribute_ns (undef, 'xx' => undef);
  $el->set_attribute_ns (undef, 'yy' => undef);
  $el->set_attribute_ns ('undef', 'gg' => undef);
  $el->set_attribute_ns ('undef', 'hh' => undef);

  is $el->get_attribute ('aa'), '';
  is $el->get_attribute ('bb'), '';
  is $el->get_attribute ('xx'), '';
  is $el->get_attribute ('yy'), '';
  is $el->get_attribute_ns ('undef', 'gg'), '';
  is $el->get_attribute_ns ('undef', 'hh'), '';

  done $c;
} n => 6, name => 'set undef values';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);

  my $el = $doc->create_element ('hoge');
  $el->set_attribute (aai => '134 "');

  is $el->get_attribute ('aai'), '134 "';
  is $el->get_attribute ('AAI'), '134 "';
  is $el->get_attribute ('aAi'), '134 "';
  is $el->get_attribute ("aA\x{0130}"), undef;
  is $el->get_attribute ("aA\x{0131}"), undef;

  is $el->get_attribute_ns (undef, 'aai'), '134 "';
  is $el->get_attribute_ns (undef, 'AAI'), undef;
  is $el->get_attribute_ns (undef, 'aAi'), undef;

  ok $el->has_attribute ('aai');
  ok $el->has_attribute ('AAI');
  ok $el->has_attribute ('aAi');
  ok not $el->has_attribute ("aA\x{0130}");
  ok not $el->has_attribute ("aA\x{0131}");

  ok $el->has_attribute_ns (undef, 'aai');
  ok not $el->has_attribute_ns (undef, 'AAI');
  ok not $el->has_attribute_ns (undef, 'aAi');

  done $c;
} n => 16, name => 'get/has html case-insensitivity';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);

  my $el = $doc->create_element ('hoge');
  $el->set_attribute_ns ("bb", "d:aai" => '134 "');

  is $el->get_attribute ('d:aai'), '134 "';
  is $el->get_attribute ('d:AAI'), '134 "';
  is $el->get_attribute ('d:aAi'), '134 "';
  is $el->get_attribute ("d:aA\x{0130}"), undef;
  is $el->get_attribute ("d:aA\x{0131}"), undef;

  is $el->get_attribute_ns ("bb", 'aai'), '134 "';
  is $el->get_attribute_ns ("bb", 'AAI'), undef;
  is $el->get_attribute_ns ("bb", 'aAi'), undef;

  ok $el->has_attribute ('d:aai');
  ok $el->has_attribute ('d:AAI');
  ok $el->has_attribute ('d:aAi');
  ok not $el->has_attribute ("d:aA\x{0130}");
  ok not $el->has_attribute ("d:aA\x{0131}");

  ok $el->has_attribute_ns ("bb", 'aai');
  ok not $el->has_attribute_ns ("bb", 'AAI');
  ok not $el->has_attribute_ns ("bb", 'aAi');

  done $c;
} n => 16, name => 'get/has html case-insensitivity, local name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);

  my $el = $doc->create_element ('hoge');
  $el->set_attribute_ns ("bb", "aai:bb" => '134 "');

  is $el->get_attribute ('aai:bb'), '134 "';
  is $el->get_attribute ('AAI:bb'), '134 "';
  is $el->get_attribute ('aAi:bb'), '134 "';
  is $el->get_attribute ("aA\x{0130}:bb"), undef;
  is $el->get_attribute ("aA\x{0131}:bb"), undef;

  ok $el->get_attribute ('aai:bb');
  ok $el->get_attribute ('AAI:bb');
  ok $el->get_attribute ('aAi:bb');
  ok not $el->get_attribute ("aA\x{0130}:bb");
  ok not $el->get_attribute ("aA\x{0131}:bb");

  done $c;
} n => 10, name => 'get/has html case-insensitivity, prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('hoge');
  $el->set_attribute (aai => '134 "');

  is $el->get_attribute ('aai'), '134 "';
  is $el->get_attribute ('AAI'), undef;
  is $el->get_attribute ('aAi'), undef;
  is $el->get_attribute ("aA\x{0130}"), undef;
  is $el->get_attribute ("aA\x{0131}"), undef;

  is $el->get_attribute_ns (undef, 'aai'), '134 "';
  is $el->get_attribute_ns (undef, 'AAI'), undef;
  is $el->get_attribute_ns (undef, 'aAi'), undef;

  ok $el->get_attribute ('aai');
  ok not $el->get_attribute ('AAI');
  ok not $el->get_attribute ('aAi');
  ok not $el->get_attribute ("aA\x{0130}");
  ok not $el->get_attribute ("aA\x{0131}");

  ok $el->get_attribute_ns (undef, 'aai');
  ok not $el->get_attribute_ns (undef, 'AAI');
  ok not $el->get_attribute_ns (undef, 'aAi');

  done $c;
} n => 16, name => 'get/has xml case-insensitivity';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);

  my $el = $doc->create_element_ns (undef, 'hoge');
  $el->set_attribute (aai => '134 "');

  is $el->get_attribute ('aai'), '134 "';
  is $el->get_attribute ('AAI'), undef;
  is $el->get_attribute ('aAi'), undef;
  is $el->get_attribute ("aA\x{0130}"), undef;
  is $el->get_attribute ("aA\x{0131}"), undef;

  is $el->get_attribute_ns (undef, 'aai'), '134 "';
  is $el->get_attribute_ns (undef, 'AAI'), undef;
  is $el->get_attribute_ns (undef, 'aAi'), undef;

  ok $el->get_attribute ('aai');
  ok not $el->get_attribute ('AAI');
  ok not $el->get_attribute ('aAi');
  ok not $el->get_attribute ("aA\x{0130}");
  ok not $el->get_attribute ("aA\x{0131}");

  ok $el->get_attribute_ns (undef, 'aai');
  ok not $el->get_attribute_ns (undef, 'AAI');
  ok not $el->get_attribute_ns (undef, 'aAi');

  done $c;
} n => 16, name => 'get/has html case-insensitivity, non-HTML element';

for my $name (
  undef, '', '124', "\x{00}", "\x70\x{D8F0}",
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');

    dies_here_ok {
      $el->set_attribute ($name => 'abc');
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'InvalidCharacterError';
    is $@->message, 'The name is not an XML Name';
    
    is $el->get_attribute ($name), undef;

    done $c;
  } n => 5, name => ['set_attribute not XML name', $name];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');

    dies_here_ok {
      $el->set_attribute_ns (undef, $name => 'abc');
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'InvalidCharacterError';
    is $@->message, 'The qualified name is not an XML Name';
    
    is $el->get_attribute ($name), undef;

    done $c;
  } n => 5, name => ['set_attribute_ns not XML name', $name];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute ('hoge:fuga' => 'abc');
  is $el->get_attribute ('hoge:fuga'), 'abc';
  is $el->get_attribute_ns (undef, 'hoge:fuga'), 'abc';

  done $c;
} n => 2, name => 'set_attribute not XML NCName';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute ("AB\x{0130}\x{0131}" => "ABC");
  is $el->get_attribute ("ab\x{0130}\x{0131}"), undef;
  is $el->get_attribute ("AB\x{0130}\x{0131}"), "ABC";

  done $c;
} n => 2, name => 'set_attribute case-sensitivity xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('a');

  $el->set_attribute ("AB\x{0130}\x{0131}" => "ABC");
  is $el->get_attribute ("ab\x{0130}\x{0131}"), "ABC";
  is $el->get_attribute ("AB\x{0130}\x{0131}"), "ABC";

  $doc->manakai_is_html (0);
  is $el->get_attribute ("ab\x{0130}\x{0131}"), "ABC";
  is $el->get_attribute ("AB\x{0130}\x{0131}"), undef;

  done $c;
} n => 4, name => 'set_attribute case-sensitivity html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ("foo", "ab\x{0130}\x{0131}:c" => "dd");

  $el->set_attribute ("AB\x{0130}\x{0131}:c" => "ABC");
  is $el->get_attribute ("ab\x{0130}\x{0131}:c"), "ABC";
  is $el->get_attribute ("AB\x{0130}\x{0131}:c"), "ABC";

  $doc->manakai_is_html (0);
  is $el->get_attribute ("ab\x{0130}\x{0131}:c"), "ABC";
  is $el->get_attribute ("AB\x{0130}\x{0131}:c"), undef;

  is $el->get_attribute_ns ("foo", "c"), "ABC";

  done $c;
} n => 5, name => 'set_attribute case-sensitivity html, prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ("foo", "c:ab\x{0130}\x{0131}" => "dd");

  $el->set_attribute ("c:AB\x{0130}\x{0131}" => "ABC");
  is $el->get_attribute ("c:ab\x{0130}\x{0131}"), "ABC";
  is $el->get_attribute ("c:AB\x{0130}\x{0131}"), "ABC";

  $doc->manakai_is_html (0);
  is $el->get_attribute ("c:ab\x{0130}\x{0131}"), "ABC";
  is $el->get_attribute ("c:AB\x{0130}\x{0131}"), undef;

  is $el->get_attribute_ns ("foo", "ab\x{0130}\x{0131}"), "ABC";
  is $el->get_attribute_ns ("foo", "AB\x{0130}\x{0131}"), undef;

  done $c;
} n => 6, name => 'set_attribute case-sensitivity html, local name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns ('hoge', 'a');

  $el->set_attribute ("AB\x{0130}\x{0131}" => "ABC");
  is $el->get_attribute ("ab\x{0130}\x{0131}"), undef;
  is $el->get_attribute ("AB\x{0130}\x{0131}"), "ABC";

  done $c;
} n => 2, name => 'set_attribute case-sensitivity html non-html element';

for my $qname (
  ':hoge', 'fuga:', 'abc:124', ':',
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');

    dies_here_ok {
      $el->set_attribute_ns ('hpofgexs', $qname => 'hh');
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'NamespaceError';
    is $@->message, 'The qualified name is not an XML QName';
    
    is $el->get_attribute_ns (undef, $qname), undef;
    done $c;
  } n => 5, name => ['get_attribute_ns non-qname', $qname];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('x');

  dies_here_ok {
    $el->set_attribute_ns (undef, 'hoge:fuga' => 'a');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';

  is $el->get_attribute ('hoge:fuga'), undef;

  done $c;
} n => 5, name => 'get_attribute_ns prefixed null namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  dies_here_ok {
    $el->set_attribute_ns (undef, 'xml:lang' => 'en');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';

  is $el->get_attribute_ns (undef, 'lang'), undef;
  is $el->get_attribute_ns (undef, 'xml:lang'), undef;
  is $el->get_attribute_ns ('http://www.w3.org/XML/1998/namespace', 'lang'), undef;

  done $c;
} n => 7, name => 'set_attribute_ns xml: prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  dies_here_ok {
    $el->set_attribute_ns ('hoge', 'xml:lang' => 'en');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Prefix |xml| cannot be bound to anything other than XML namespace';

  is $el->get_attribute_ns (undef, 'lang'), undef;
  is $el->get_attribute_ns (undef, 'xml:lang'), undef;
  is $el->get_attribute_ns ('hoge', 'lang'), undef;
  is $el->get_attribute_ns ('hoge', 'xml:lang'), undef;
  is $el->get_attribute_ns ('http://www.w3.org/XML/1998/namespace', 'lang'), undef;

  done $c;
} n => 9, name => 'set_attribute_ns xml: prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute_ns ('http://www.w3.org/XML/1998/namespace', 'lang', 'ss');
  
  is $el->get_attribute_ns ('http://www.w3.org/XML/1998/namespace', 'lang'), 'ss';

  done $c;
} n => 1, name => 'set_attribute_ns xml: namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute_ns ('http://www.w3.org/XML/1998/namespace', 'xml:lang', 'ss');
  
  is $el->get_attribute_ns ('http://www.w3.org/XML/1998/namespace', 'lang'), 'ss';

  done $c;
} n => 1, name => 'set_attribute_ns xml: prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  dies_here_ok {
    $el->set_attribute_ns ('hoge', 'xmlns:lang' => 'en');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';

  is $el->get_attribute_ns (undef, 'lang'), undef;
  is $el->get_attribute_ns (undef, 'xmlns:lang'), undef;
  is $el->get_attribute_ns ('hoge', 'lang'), undef;
  is $el->get_attribute_ns ('hoge', 'xmlns:lang'), undef;
  is $el->get_attribute_ns ('http://www.w3.org/2000/xmlns/', 'lang'), undef;

  done $c;
} n => 9, name => 'set_attribute_ns xml: prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  dies_here_ok {
    $el->set_attribute_ns ('hoge', 'xmlns' => 'en');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';

  is $el->get_attribute_ns (undef, 'xmlns'), undef;
  is $el->get_attribute_ns (undef, 'xmlns:xmlns'), undef;
  is $el->get_attribute_ns ('hoge', 'xmlns'), undef;
  is $el->get_attribute_ns ('hoge', 'xmlns:xmlns'), undef;
  is $el->get_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns'), undef;

  done $c;
} n => 9, name => 'set_attribute_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  dies_here_ok {
    $el->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'XMLns' => 'en');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';

  is $el->get_attribute_ns (undef, 'XMLns'), undef;
  is $el->get_attribute_ns (undef, 'xmlns:XMLns'), undef;
  is $el->get_attribute_ns ('hoge', 'XMLns'), undef;
  is $el->get_attribute_ns ('hoge', 'xmlns:XMLns'), undef;
  is $el->get_attribute_ns ('http://www.w3.org/2000/xmlns/', 'XMLns'), undef;

  done $c;
} n => 9, name => 'set_attribute_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  dies_here_ok {
    $el->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'XMLns:hoge' => 'en');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';

  is $el->get_attribute_ns (undef, 'hoge'), undef;
  is $el->get_attribute_ns (undef, 'XMLns:hoge'), undef;
  is $el->get_attribute_ns ('hoge', 'hoge'), undef;
  is $el->get_attribute_ns ('hoge', 'XMLns:hoge'), undef;
  is $el->get_attribute_ns ('http://www.w3.org/2000/xmlns/', 'hoge'), undef;

  done $c;
} n => 9, name => 'set_attribute_ns xmlns:';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns', 'foo');
  is $el->get_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns'), 'foo';

  done $c;
} n => 1, name => 'set_attribute_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:hoge', 'foo');
  is $el->get_attribute_ns ('http://www.w3.org/2000/xmlns/', 'hoge'), 'foo';

  done $c;
} n => 1, name => 'set_attribute_ns xmlns:';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:xmlns', 'foo');
  is $el->get_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns'), 'foo';

  done $c;
} n => 1, name => 'set_attribute_ns xmlns:xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:ab', 'foo');
  is $el->get_attribute_ns ('http://www.w3.org/2000/xmlns/', 'ab'), 'foo';

  done $c;
} n => 1, name => 'set_attribute_ns xmlns:';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  $doc->strict_error_checking (0);

  $el->set_attribute ('123 hoge' => 'abc');
  is $el->get_attribute ('123 hoge'), 'abc';
  
  my $attr = $el->get_attribute_node ('123 hoge');
  is $attr->prefix, undef;
  is $attr->local_name, '123 hoge';
  is $attr->namespace_uri, undef;

  done $c;
} n => 4, name => 'set_attribute not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  $doc->strict_error_checking (0);

  dies_here_ok {
    $el->set_attribute ('' => 'abc');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The name is not an XML Name';
  is $el->get_attribute (''), undef;
  is $el->attributes->length, 0;

  done $c;
} n => 6, name => 'set_attribute not strict empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  $doc->strict_error_checking (0);

  $el->set_attribute_ns (undef, '123 hoge' => 'abc');
  is $el->get_attribute ('123 hoge'), 'abc';
  
  my $attr = $el->get_attribute_node ('123 hoge');
  is $attr->prefix, undef;
  is $attr->local_name, '123 hoge';
  is $attr->namespace_uri, undef;

  done $c;
} n => 4, name => 'set_attribute_ns not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  $doc->strict_error_checking (0);

  dies_here_ok {
    $el->set_attribute_ns (undef, '' => 'abc');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  is $el->get_attribute (''), undef;
  is $el->attributes->length, 0;

  done $c;
} n => 6, name => 'set_attribute_ns not strict empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  $doc->strict_error_checking (0);

  $el->set_attribute_ns (undef, ':hoge' => 'abc');
  is $el->get_attribute (':hoge'), 'abc';
  
  my $attr = $el->get_attribute_node (':hoge');
  is $attr->prefix, undef;
  is $attr->local_name, ':hoge';
  is $attr->namespace_uri, undef;

  done $c;
} n => 4, name => 'set_attribute_ns not strict :name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  $doc->strict_error_checking (0);

  $el->set_attribute_ns (undef, 'hoge:' => 'abc');
  is $el->get_attribute ('hoge:'), 'abc';
  
  my $attr = $el->get_attribute_node ('hoge:');
  is $attr->prefix, undef;
  is $attr->local_name, 'hoge:';
  is $attr->namespace_uri, undef;

  done $c;
} n => 4, name => 'set_attribute_ns not strict name:';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  $doc->strict_error_checking (0);

  $el->set_attribute_ns ('abc', 'hoge::fuga:' => 'abc');
  is $el->get_attribute ('hoge::fuga:'), 'abc';
  
  my $attr = $el->get_attribute_node ('hoge::fuga:');
  is $attr->prefix, 'hoge';
  is $attr->local_name, ':fuga:';
  is $attr->namespace_uri, 'abc';

  done $c;
} n => 4, name => 'set_attribute_ns not strict name:';

for my $test (
  [[undef, 'foo:bar'] => [undef, 'foo', 'bar']],
  [[undef, 'xml:lang'] => [undef, 'xml', 'lang']],
  [['http://foo/', 'xml:lang'] => ['http://foo/', 'xml', 'lang']],
  [['http://www.w3.org/XML/1998/namespace', 'hoge:lang'] =>
   ['http://www.w3.org/XML/1998/namespace', 'hoge', 'lang']],
  [[undef, 'xmlns'] => [undef, undef, 'xmlns']],
  [['http://hoge/', 'xmlns'] => ['http://hoge/', undef, 'xmlns']],
  [['http://www.w3.org/2000/xmlns/', 'hoge:lang'] =>
   ['http://www.w3.org/2000/xmlns/', 'hoge', 'lang']],
  [['http://www.w3.org/2000/xmlns/', 'fuga'] =>
   ['http://www.w3.org/2000/xmlns/', undef, 'fuga']],
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');
    $doc->strict_error_checking (0);

    $el->set_attribute_ns (@{$test->[0]} => 'abc');
    my $attr = $el->attributes->[0];
    is $attr->namespace_uri, $test->[1]->[0];
    is $attr->prefix, $test->[1]->[1];
    is $attr->local_name, $test->[1]->[2];

    done $c;
  } n => 3, name => ['set_attribute_ns', @{$test->[0]}];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  $el->set_attribute_ns ('http://hoge', ['fuga', 'abc'] => 'a');
  my $attr = $el->attributes->[0];
  is $attr->prefix, 'fuga';
  is $attr->local_name, 'abc';
  is $attr->namespace_uri, 'http://hoge';
  done $c;
} n => 3, name => 'set_attribute_ns qname as arrayref';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  $el->set_attribute_ns ('http://hoge', [undef, 'abc'] => 1);
  my $attr = $el->attributes->[0];
  is $attr->prefix, undef;
  is $attr->local_name, 'abc';
  is $attr->namespace_uri, 'http://hoge';
  done $c;
} n => 3, name => 'set_attribute_ns ncname as arrayref';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  dies_here_ok {
    $el->set_attribute_ns ('http://hoge', [undef, 'a:bc'] => 2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The local name is not an XML NCName';
  is $el->attributes->length, 0;
  done $c;
} n => 5, name => 'create_attribute_ns arrayref error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  dies_here_ok {
    $el->set_attribute_ns ('http://hoge', ['a:b', 'abc'] => 4);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The prefix is not an XML NCName';
  is $el->attributes->length, 0;
  done $c;
} n => 5, name => 'create_attribute_ns arrayref error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  dies_here_ok {
    $el->set_attribute_ns ('http://hoge', [':', 'abc'] => 45);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The prefix is not an XML NCName';
  is $el->attributes->length, 0;
  done $c;
} n => 5, name => 'create_attribute_ns arrayref error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  dies_here_ok {
    $el->set_attribute_ns ('http://hoge', ['', 'abc'] => 532);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The prefix is not an XML NCName';
  is $el->attributes->length, 0;
  done $c;
} n => 5, name => 'create_attribute_ns arrayref error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $el = $doc->create_element ('hoge');
  $el->set_attribute_ns ('http://hoge', [undef, 'a:bc'] => 442);
  my $attr = $el->attributes->[0];
  is $attr->prefix, undef;
  is $attr->local_name, 'a:bc';
  is $attr->namespace_uri, 'http://hoge';
  done $c;
} n => 3, name => 'set_attribute_ns arrayref not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $el = $doc->create_element ('hoge');
  $el->set_attribute_ns ('http://hoge', ['12:ab', 'abc'] => 2);
  my $attr = $el->attributes->[0];
  is $attr->prefix, '12:ab';
  is $attr->local_name, 'abc';
  is $attr->namespace_uri, 'http://hoge';
  done $c;
} n => 3, name => 'set_attribute_ns arrayref not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $el = $doc->create_element ('hoge');
  $el->set_attribute_ns ('http://hoge', ['12:ab', 'a:b:c'] => 42);
  my $attr = $el->attributes->[0];
  is $attr->prefix, '12:ab';
  is $attr->local_name, 'a:b:c';
  is $attr->namespace_uri, 'http://hoge';
  done $c;
} n => 3, name => 'set_attribute_ns arrayref not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  
  ok not $el->has_attribute ('ab');
  ok not $el->has_attribute ('ab:foo');
  ok not $el->has_attribute ('53333');
  ok not $el->has_attribute ('');
  ok not $el->has_attribute (undef);

  ok not $el->has_attribute_ns (undef, 'ab');
  ok not $el->has_attribute_ns (undef, 'ab:foo');
  ok not $el->has_attribute_ns (undef, '53333');
  ok not $el->has_attribute_ns (undef, '');
  ok not $el->has_attribute_ns (undef, undef);
  ok not $el->has_attribute_ns ('', '');
  ok not $el->has_attribute_ns ('aab', '');
  ok not $el->has_attribute_ns ('aab', 'fe');
  ok not $el->has_attribute_ns ('aab', 'aa:fe');

  done $c;
} n => 14, name => 'has no attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute (hoge => 'fua');
  
  ok $el->has_attribute ('hoge');
  ok not $el->has_attribute ('Hoge');
  ok $el->has_attribute_ns (undef, 'hoge');
  ok $el->has_attribute_ns ('', 'hoge');
  ok not $el->has_attribute_ns ('aaa', 'hoge');
  ok not $el->has_attribute_ns ('aaa', 'aaa:hoge');
  ok not $el->has_attribute_ns (undef, 'aaa:hoge');

  done $c;
} n => 7, name => 'has simple attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('aa', hoge => 'fua');
  
  ok $el->has_attribute ('hoge');
  ok not $el->has_attribute ('Hoge');
  ok not $el->has_attribute_ns (undef, 'hoge');
  ok not $el->has_attribute_ns ('', 'hoge');
  ok $el->has_attribute_ns ('aa', 'hoge');
  ok not $el->has_attribute_ns ('aa', 'aaa:hoge');
  ok not $el->has_attribute_ns (undef, 'aaa:hoge');

  done $c;
} n => 7, name => 'has node attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('aa', "bb:hoge" => 'fua');
  
  ok not $el->has_attribute ('hoge');
  ok not $el->has_attribute ('Hoge');
  ok $el->has_attribute ('bb:hoge');
  ok not $el->has_attribute_ns (undef, 'hoge');
  ok not $el->has_attribute_ns ('', 'hoge');
  ok $el->has_attribute_ns ('aa', 'hoge');
  ok not $el->has_attribute_ns ('aa', 'aaa:hoge');
  ok not $el->has_attribute_ns (undef, 'aaa:hoge');
  ok not $el->has_attribute_ns ('bb', 'hoge');
  ok not $el->has_attribute_ns ('aa', 'bb:hoge');

  done $c;
} n => 10, name => 'has prefixed node attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute (hoge => '');
  ok $el->has_attribute ('hoge');
  ok $el->has_attribute_ns ('', 'hoge');

  $el->set_attribute (fuga => '0');
  ok $el->has_attribute ('fuga');
  ok $el->has_attribute_ns ('', 'fuga');

  done $c;
} n => 4, name => 'has false value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('hoge', 'foo:bar' => 'aa');

  ok $el->has_attribute ('foo:bar');
  ok not $el->has_attribute ('bar');
  ok not $el->has_attribute_ns (undef, 'foo:bar');
  ok not $el->has_attribute_ns (undef, 'bar');
  ok not $el->has_attribute_ns ('', 'bar');
  ok $el->has_attribute_ns ('hoge', 'bar');

  done $c;
} n => 6, name => 'has qname';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->remove_attribute ('hoge');
  $el->remove_attribute ('120');
  $el->remove_attribute_ns (undef, 'hoge');
  $el->remove_attribute_ns ('', 'hoge');
  $el->remove_attribute_ns ('', 'hoge:fuga');
  $el->remove_attribute_ns ('', 'hoge:120');
  $el->remove_attribute_ns ('http://hoge', 'hoge:a120');
  $el->remove_attribute_ns ('http://hoge', 'hoge:120');

  is $el->get_attribute ('hoge'), undef;

  done $c;
} n => 1, name => 'remove no attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute ('hoge' => 'fuga');

  $el->remove_attribute ('hoge');

  is $el->get_attribute ('hoge'), undef;

  done $c;
} n => 1, name => 'remove_attribute null namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute ('hoge' => 'fuga');

  $el->remove_attribute_ns (undef, 'hoge');

  is $el->get_attribute ('hoge'), undef;

  done $c;
} n => 1, name => 'remove_attribute_ns null namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute ('hoge' => 'fuga');

  $el->remove_attribute_ns ('', 'hoge');

  is $el->get_attribute ('hoge'), undef;

  done $c;
} n => 1, name => 'remove_attribute_ns null namespace empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('htoge', 'fuga' => '');
  
  $el->remove_attribute ('fuga');

  is $el->get_attribute ('fuga'), undef;
  is $el->get_attribute_ns ('htoge', 'fuga'), undef;

  done $c;
} n => 2, name => 'remove_attribute namespaced unprefixed attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('htoge', 'fuga' => '');
  
  $el->remove_attribute_ns (undef, 'fuga');

  is $el->get_attribute ('fuga'), '';
  is $el->get_attribute_ns ('htoge', 'fuga'), '';

  done $c;
} n => 2, name => 'remove_attribute_ns namespaced unprefixed attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('htoge', 'fuga' => '');
  
  $el->remove_attribute_ns ('', 'fuga');

  is $el->get_attribute ('fuga'), '';
  is $el->get_attribute_ns ('htoge', 'fuga'), '';

  done $c;
} n => 2, name => 'remove_attribute_ns namespaced unprefixed attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('htoge', 'fuga' => '');
  
  $el->remove_attribute_ns ('htoge', 'fuga');

  is $el->get_attribute ('fuga'), undef;
  is $el->get_attribute_ns ('htoge', 'fuga'), undef;

  done $c;
} n => 2, name => 'remove_attribute_ns namespaced unprefixed attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('htoge', 'aa:fuga' => '');
  
  $el->remove_attribute ('fuga');

  is $el->get_attribute ('fuga'), undef;
  is $el->get_attribute_ns ('htoge', 'fuga'), '';

  done $c;
} n => 2, name => 'remove_attribute namespaced prefixed attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('htoge', 'aa:fuga' => '');
  
  $el->remove_attribute ('aa:fuga');

  is $el->get_attribute ('fuga'), undef;
  is $el->get_attribute ('aa:fuga'), undef;
  is $el->get_attribute_ns ('htoge', 'fuga'), undef;
  is $el->get_attribute_ns ('htoge', 'aa:fuga'), undef;

  done $c;
} n => 4, name => 'remove_attribute namespaced prefixed attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('htoge', 'aa:fuga' => '');
  
  $el->remove_attribute_ns ('htoge', 'fuga');

  is $el->get_attribute ('fuga'), undef;
  is $el->get_attribute_ns ('htoge', 'fuga'), undef;

  done $c;
} n => 2, name => 'remove_attribute_ns namespaced prefixed attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('abc', 'hoge' => 'fuga1');
  $el->set_attribute_ns (undef, 'hoge' => 'fuga2');

  $el->remove_attribute ('hoge');

  is $el->get_attribute_ns (undef, 'hoge'), 'fuga2';
  is $el->get_attribute_ns ('abc', 'hoge'), undef;

  done $c;
} n => 2, name => 'remove_attribute multiple attrs with same name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns (undef, 'hoge' => '1');

  $el->remove_attribute ('HOGE');
  is $el->get_attribute_ns (undef, 'hoge'), '1';

  $el->remove_attribute ('HoGe');
  is $el->get_attribute_ns (undef, 'hoge'), '1';

  $el->remove_attribute ('hoge');
  is $el->get_attribute_ns (undef, 'hoge'), undef;

  done $c;
} n => 3, name => 'remove_attribute case-sensitivity xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns (undef, 'hoge' => '1');

  $el->remove_attribute ('HOGE');
  is $el->get_attribute_ns (undef, 'hoge'), undef;

  done $c;
} n => 1, name => 'remove_attribute case-sensitivity html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('gg', 'fuga:hoge' => '1');

  $el->remove_attribute ('FuGA:HOGE');
  is $el->get_attribute_ns ('gg', 'hoge'), undef;

  done $c;
} n => 1, name => 'remove_attribute case-sensitivity html, namespaced';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns (undef, 'hOGe' => '1');

  $el->remove_attribute ('hoge');
  is $el->get_attribute_ns (undef, 'hOGe'), '1';

  done $c;
} n => 1, name => 'remove_attribute case-sensitivity html, uppercase';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  
  my $attr1 = $el->get_attribute_node ('hoge');
  is $attr1, undef;

  my $attr2 = $el->get_attribute_node_ns (undef, 'hoge');
  is $attr2, undef;

  my $attr3 = $el->get_attribute_node_ns ('fuga', 'hoge');
  is $attr3, undef;

  done $c;
} n => 3, name => 'get node not found';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  $el->set_attribute (hoge => 213);

  my $attr1 = $el->get_attribute_node ('hoge');
  isa_ok $attr1, 'Web::DOM::Attr';
  is $attr1->namespace_uri, undef;
  is $attr1->prefix, undef;
  is $attr1->local_name, 'hoge';
  is $attr1->value, '213';
  ok $attr1->specified;
  
  done $c;
} n => 6, name => 'get_attribute_node simple attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  $el->set_attribute (hoge => 213);

  my $attr1 = $el->get_attribute_node_ns (undef, 'hoge');
  isa_ok $attr1, 'Web::DOM::Attr';
  is $attr1->namespace_uri, undef;
  is $attr1->prefix, undef;
  is $attr1->local_name, 'hoge';
  is $attr1->value, '213';
  ok $attr1->specified;
  
  done $c;
} n => 6, name => 'get_attribute_node_ns simple attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  $el->set_attribute (hoge => 213);

  my $attr1 = $el->get_attribute_node_ns ('', 'hoge');
  isa_ok $attr1, 'Web::DOM::Attr';
  is $attr1->namespace_uri, undef;
  is $attr1->prefix, undef;
  is $attr1->local_name, 'hoge';
  is $attr1->value, '213';
  ok $attr1->specified;
  
  done $c;
} n => 6, name => 'get_attribute_node_ns simple attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  $el->set_attribute_ns ('fuga', "aab:hoge" => 213);

  my $attr1 = $el->get_attribute_node ('aab:hoge');
  isa_ok $attr1, 'Web::DOM::Attr';
  is $attr1->namespace_uri, 'fuga';
  is $attr1->prefix, 'aab';
  is $attr1->local_name, 'hoge';
  is $attr1->value, '213';
  ok $attr1->specified;
  
  done $c;
} n => 6, name => 'get_attribute_node node attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  $el->set_attribute_ns ('fuga', hoge => 213);

  my $attr1 = $el->get_attribute_node_ns ('fuga', 'hoge');
  isa_ok $attr1, 'Web::DOM::Attr';
  is $attr1->namespace_uri, 'fuga';
  is $attr1->prefix, undef;
  is $attr1->local_name, 'hoge';
  is $attr1->value, '213';
  ok $attr1->specified;
  
  done $c;
} n => 6, name => 'get_attribute_node_ns node attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  $el->set_attribute (hoge1 => 33);
  $el->set_attribute_ns ('aaa', 'hoge1' => 424);

  my $attr1 = $el->get_attribute_node ('hoge1');
  is $attr1->value, '33';

  my $attr2 = $el->get_attribute_node_ns (undef, 'hoge1');
  is $attr2->value, '33';

  my $attr3 = $el->get_attribute_node_ns ('aaa', 'hoge1');
  is $attr3->value, '424';

  done $c;
} n => 3, name => 'get_attribute_node duplicate';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute (hoge => 'aa');

  my $attr1 = $el->get_attribute_node ('HoGe');
  is $attr1, undef;

  my $attr3 = $el->get_attribute_node_ns (undef, 'HoGe');
  is $attr3, undef;

  $doc->manakai_is_html (1);

  my $attr2 = $el->get_attribute_node ('HoGe');
  isa_ok $attr2, 'Web::DOM::Attr';
  is $attr2->name, 'hoge';

  my $attr4 = $el->get_attribute_node_ns (undef, 'HoGe');
  is $attr4, undef;

  done $c;
} n => 5, name => 'get_attribute_node case-sensitivity';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (undef, 'a');
  $el->set_attribute (hoge => 'aa');

  my $attr1 = $el->get_attribute_node ('HoGe');
  is $attr1, undef;

  my $attr3 = $el->get_attribute_node_ns (undef, 'HoGe');
  is $attr3, undef;

  $doc->manakai_is_html (1);

  my $attr2 = $el->get_attribute_node ('HoGe');
  is $attr2, undef;

  my $attr4 = $el->get_attribute_node_ns (undef, 'HoGe');
  is $attr4, undef;

  done $c;
} n => 4, name => 'get_attribute_node case-sensitivity';

for my $method (qw(set_attribute_node set_attribute_node_ns)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    
    my $attr = $doc->create_attribute ('hoge');
    $attr->value ('fuga');
    
    my $el = $doc->create_element ('foo');

    $el->$method ($attr);

    is $el->get_attribute ('hoge'), 'fuga';
    is $el->get_attribute_ns (undef, 'hoge'), 'fuga';
    is $attr->owner_element, $el;

    is $$el->[0], $$attr->[0];
    is $$el->[0]->{tree_id}->[$$el->[1]],
        $$attr->[0]->{tree_id}->[$$attr->[1]];

    done $c;
  } n => 5, name => [$method, 'new attr, null namespace'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    
    my $attr = $doc->create_attribute_ns ('abc', 'a:hoge');
    $attr->value ('fuga');
    
    my $el = $doc->create_element ('foo');

    $el->$method ($attr);

    is $el->get_attribute ('a:hoge'), 'fuga';
    is $el->get_attribute_ns ('abc', 'hoge'), 'fuga';
    is $attr->owner_element, $el;

    is $$el->[0], $$attr->[0];
    is $$el->[0]->{tree_id}->[$$el->[1]],
        $$attr->[0]->{tree_id}->[$$attr->[1]];

    done $c;
  } n => 5, name => [$method, 'new attr, non-null namespace'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    
    my $attr = $doc->create_attribute ('hoge');
    $attr->value ('fuga');
    
    my $el = $doc->create_element ('foo');
    $el->set_attribute (hoge => '213');

    $el->$method ($attr);

    is $el->get_attribute ('hoge'), 'fuga';
    is $el->get_attribute_ns (undef, 'hoge'), 'fuga';
    is $attr->owner_element, $el;
    is scalar @{$el->attributes}, 1;

    is $$el->[0], $$attr->[0];
    is $$el->[0]->{tree_id}->[$$el->[1]],
        $$attr->[0]->{tree_id}->[$$attr->[1]];

    done $c;
  } n => 6, name => [$method, 'replace simple attr'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    
    my $attr = $doc->create_attribute_ns ('aa', 'hoge');
    $attr->value ('fuga');
    
    my $el = $doc->create_element ('foo');
    $el->set_attribute_ns ('aa', hoge => '213');

    $el->$method ($attr);

    is $el->get_attribute_ns ('aa', 'hoge'), 'fuga';
    is $attr->owner_element, $el;
    is scalar @{$el->attributes}, 1;

    is $$el->[0], $$attr->[0];
    is $$el->[0]->{tree_id}->[$$el->[1]],
        $$attr->[0]->{tree_id}->[$$attr->[1]];

    done $c;
  } n => 5, name => [$method, 'replace node attr'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    
    my $attr = $doc->create_attribute ('hoge');
    $attr->value ('fuga');
    
    my $el = $doc->create_element ('foo');
    $el->set_attribute (hoge => '213');

    my $old_attr = $el->$method ($attr);
    isa_ok $old_attr, 'Web::DOM::Attr';
    is $old_attr->prefix, undef;
    is $old_attr->namespace_uri, undef;
    is $old_attr->local_name, 'hoge';
    is $old_attr->value, '213';
    ok $old_attr->specified;
    is $old_attr->owner_element, undef;

    is $$el->[0], $$attr->[0];
    is $$el->[0], $$old_attr->[0];
    is $$el->[0]->{tree_id}->[$$el->[1]],
        $$attr->[0]->{tree_id}->[$$attr->[1]];
    isnt $$el->[0]->{tree_id}->[$$el->[1]],
        $$old_attr->[0]->{tree_id}->[$$old_attr->[1]];

    done $c;
  } n => 11, name => [$method, 'replace simple attr, return'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    
    my $attr = $doc->create_attribute_ns ('aa', 'b:hoge');
    $attr->value ('fuga');
    
    my $el = $doc->create_element ('foo');
    $el->set_attribute_ns ('aa', 'c:hoge' => '213');

    my $old_attr = $el->$method ($attr);
    isa_ok $old_attr, 'Web::DOM::Attr';
    is $old_attr->prefix, 'c';
    is $old_attr->namespace_uri, 'aa';
    is $old_attr->local_name, 'hoge';
    is $old_attr->value, '213';
    ok $old_attr->specified;
    is $old_attr->owner_element, undef;

    is $$el->[0], $$attr->[0];
    is $$el->[0], $$old_attr->[0];
    is $$el->[0]->{tree_id}->[$$el->[1]],
        $$attr->[0]->{tree_id}->[$$attr->[1]];
    isnt $$el->[0]->{tree_id}->[$$el->[1]],
        $$old_attr->[0]->{tree_id}->[$$old_attr->[1]];

    done $c;
  } n => 11, name => [$method, 'replace node attr, return'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    
    my $attr = $doc->create_attribute_ns ('aa', 'b:hoge');
    $attr->value ('fuga');
    
    my $el = $doc->create_element ('foo');
    $el->set_attribute_ns ('aa', 'c:hoge' => '213');
    my $called;
    $el->get_attribute_node_ns ('aa', 'hoge')
        ->set_user_data (destroy => bless sub {
                           $called = 1;
                         }, 'test::DestroyCallback');

    $el->$method ($attr);
    ok $called;

    done $c;
  } n => 1, name => [$method, 'replace node attr, destroy implicitly'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    
    my $attr = $doc->create_attribute_ns ('aa', 'b:hoge');
    $attr->value ('fuga');
    
    my $el = $doc->create_element ('foo');
    $el->set_attribute_ns ('aa', 'c:hoge' => '213');
    my $called;
    $el->get_attribute_node_ns ('aa', 'hoge')
        ->set_user_data (destroy => bless sub {
                           $called = 1;
                         }, 'test::DestroyCallback');

    my $old = $el->$method ($attr);
    undef $old;
    ok $called;

    done $c;
  } n => 1, name => [$method, 'replace node attr, destroy explicitly'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');
    $el->set_attribute ('hoge' => 'aa');
    my $attr = $el->get_attribute_node ('hoge');

    my $el2 = $doc->create_element ('b');
    dies_here_ok {
      $el2->$method ($attr);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'InUseAttributeError';
    is $@->message, 'The specified attribute has already attached to another node';

    ok $el->has_attribute ('hoge');
    ok not $el2->has_attribute ('hoge');
    is $attr->owner_element, $el;

    done $c;
  } n => 7, name => [$method, 'inuse'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');
    $el->set_attribute ('hoge' => 'aa');
    my $attr = $el->get_attribute_node ('hoge');

    my $doc2 = new Web::DOM::Document;
    my $el2 = $doc2->create_element ('b');
    dies_here_ok {
      $el2->$method ($attr);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'InUseAttributeError';
    is $@->message, 'The specified attribute has already attached to another node';

    ok $el->has_attribute ('hoge');
    ok not $el2->has_attribute ('hoge');
    is $attr->owner_element, $el;

    done $c;
  } n => 7, name => [$method, 'inuse, another document'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');
    $el->set_attribute (hoge => 4);

    my $attr = $el->get_attribute_node ('hoge');
    is $el->$method ($attr), $attr;

    is $attr->owner_element, $el;
    ok $attr->specified;
    is $el->get_attribute ('hoge'), 4;

    done $c;
  } n => 4, name => [$method, 'same element'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');
    my $el2 = $doc->create_element ('b');
    
    dies_here_ok {
      $el->$method ($el2);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->name, 'TypeError';
    is $@->message, 'The argument is not an Attr';

    done $c;
  } n => 4, name => [$method, 'not attr'];

  test {
    my $c = shift;
    my $doc1 = new Web::DOM::Document;
    my $doc2 = new Web::DOM::Document;

    my $el1 = $doc1->create_element ('a');
    my $attr2 = $doc2->create_attribute ('hoge');
    $attr2->value ('fuga');

    $el1->$method ($attr2);

    is $el1->owner_document, $doc1;
    is $attr2->owner_document, $doc1;
    is $el1->get_attribute ('hoge'), 'fuga';

    done $c;
  } n => 3, name => [$method, 'from different document'];
} # set_attribute_node / set_attribute_node_ns

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('a');
  my $attr = $doc->create_attribute ('hRef');
  $el->set_attribute (href => 12);
  my $old_attr = $el->get_attribute_node ('href');
  my $old = $el->set_attribute_node ($attr);
  is $old, $old_attr;
  is $old->owner_element, undef;
  is $old->local_name, 'href';
  is $attr->owner_element, $el;
  done $c;
} n => 4, name => 'set_attribute_node HTML matching';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('a');
  my $attr = $doc->create_attribute_ns (undef, 'hRef');
  $el->set_attribute (href => 12);
  my $old_attr = $el->get_attribute_node ('href');
  my $old = $el->set_attribute_node_ns ($attr);
  is $old, undef;
  is $old_attr->owner_element, $el;
  is $old_attr->local_name, 'href';
  is $attr->owner_element, $el;
  done $c;
} n => 4, name => 'set_attribute_node_ns HTML matching';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');
  $el->set_attribute (hoge => 4);

  my $attr = $el->get_attribute_node ('hoge');

  is $$el->[0], $$attr->[0];
  is $$el->[0]->{tree_id}->[$$el->[1]],
      $$attr->[0]->{tree_id}->[$$attr->[1]];

  $el->remove_attribute_node ($attr);

  is $el->get_attribute ('hoge'), undef;
  is $el->attributes->length, 0;

  is $$el->[0], $$attr->[0];
  isnt $$el->[0]->{tree_id}->[$$el->[1]],
      $$attr->[0]->{tree_id}->[$$attr->[1]];

  done $c;
} n => 6, name => 'remove_attribute_node null namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ("aaa", "bb:hoge" => 4);

  my $attr = $el->get_attribute_node ('bb:hoge');

  is $$el->[0], $$attr->[0];
  is $$el->[0]->{tree_id}->[$$el->[1]],
      $$attr->[0]->{tree_id}->[$$attr->[1]];

  $el->remove_attribute_node ($attr);

  is $el->get_attribute ('bb:hoge'), undef;
  is $el->attributes->length, 0;

  is $$el->[0], $$attr->[0];
  isnt $$el->[0]->{tree_id}->[$$el->[1]],
      $$attr->[0]->{tree_id}->[$$attr->[1]];

  done $c;
} n => 6, name => 'remove_attribute_node non-null namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  $el->set_attribute ('hh' => 44);

  my $attr = $el->get_attribute_node ('hh');
  my $attr2 = $el->remove_attribute_node ($attr);

  is $attr2, $attr;
  is $attr2->owner_element, undef;
  ok $attr2->specified;

  done $c;
} n => 3, name => 'remove_attribute_node returned';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute ('b7a');
  my $el = $doc->create_element ('aa');

  dies_here_ok {
    $el->remove_attribute_node ($attr);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'The specified attribute is not an attribute of the element';

  is $attr->owner_element, undef;
  is $el->attributes->length, 0;

  done $c;
} n => 6, name => 'remove_attribute_node no owner';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute ('b7a');
  my $el = $doc->create_element ('aa');
  my $el2 = $doc->create_element ('aa');
  $el2->set_attribute_node ($attr);

  dies_here_ok {
    $el->remove_attribute_node ($attr);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'The specified attribute is not an attribute of the element';

  is $attr->owner_element, $el2;
  is $el->attributes->length, 0;
  is $el2->attributes->length, 1;

  done $c;
} n => 7, name => 'remove_attribute_node different owner';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $attr = $doc2->create_attribute ('b7a');
  my $el = $doc->create_element ('aa');
  my $el2 = $doc2->create_element ('aa');
  $el2->set_attribute_node ($attr);

  dies_here_ok {
    $el->remove_attribute_node ($attr);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'The specified attribute is not an attribute of the element';

  is $attr->owner_element, $el2;
  is $el->attributes->length, 0;
  is $el2->attributes->length, 1;

  done $c;
} n => 7, name => 'remove_attribute_node different doc different owner';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $attr = $doc2->create_attribute ('b7a');
  my $el = $doc->create_element ('aa');

  dies_here_ok {
    $el->remove_attribute_node ($attr);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'The specified attribute is not an attribute of the element';

  is $attr->owner_element, undef;
  is $el->attributes->length, 0;

  done $c;
} n => 6, name => 'remove_attribute_node different doc no owner';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $doc->append_child ($el);

  dies_here_ok {
    $el->remove_attribute_node ($doc);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->name, 'TypeError';
  is $@->message, 'The argument is not an Attr';

  is $el->attributes->length, 0;
  is $$doc->[0]->{tree_id}->[$$doc->[1]],
      $$el->[0]->{tree_id}->[$$el->[1]];

  done $c;
} n => 6, name => 'remove_attribute_node not attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $doc->append_child ($el);

  dies_here_ok {
    $el->remove_attribute_node (undef);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->name, 'TypeError';
  is $@->message, 'The argument is not an Attr';

  is $el->attributes->length, 0;

  done $c;
} n => 5, name => 'remove_attribute_node not attr';

for my $test (
  [[] => ''],
  [[['abc', 42, 55]] => 'abc'],
  [[['abc', 42, 55], ['x', 4, 51]] => 'abcx'],
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');

    $el->manakai_set_attribute_indexed_string_ns
        (undef, foo => $test->[0]);
    is $el->get_attribute_ns (undef, 'foo'), $test->[1];
    eq_or_diff $el->manakai_get_attribute_indexed_string_ns (undef, 'foo'),
        $test->[0];

    done $c;
  } n => 2, name => ['manakai_set_attribute_indexed_string_ns', @$test];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  is $el->manakai_get_attribute_indexed_string_ns (undef, 'aa'), undef;
  is $el->manakai_get_attribute_indexed_string_ns ('http://foo/', 'aa'), undef;
  is $el->manakai_get_attribute_indexed_string_ns (undef, '12:aa'), undef;

  done $c;
} n => 3, name => ['manakai_get_attribute_indexed_string_ns', 'not found'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('foo');

  dies_here_ok {
    $el->manakai_set_attribute_indexed_string_ns
        (undef, 'foo:bar' => [['ab', 4, 5]]);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';

  is $el->attributes->length, 0;

  done $c;
} n => 5, name => ['manakai_set_attribute_indexed_string_ns', 'bad name'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $el = $doc->create_element ('foo');

  is $el->manakai_set_attribute_indexed_string_ns
      (undef, [undef, '35foo!bar'] => [['ab', 4, 5]]), undef;
  is $el->get_attribute_ns (undef, '35foo!bar'), 'ab';

  is $el->attributes->length, 1;
  is $el->attributes->[0]->prefix, undef;
  is $el->attributes->[0]->local_name, '35foo!bar';
  is $el->attributes->[0]->value, 'ab';

  done $c;
} n => 6, name => ['manakai_set_attribute_indexed_string_ns', 'bad name not strict'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  $el->manakai_set_attribute_indexed_string_ns
      ('http://a/b', ['foo', 'baz'] => [['aaa', 32, 44], ['e', 4, 66]]);
  is $el->get_attribute_ns ('http://a/b', 'baz'), 'aaae';
  eq_or_diff $el->manakai_get_attribute_indexed_string_ns
      ('http://a/b', 'baz'), [['aaa', 32, 44], ['e', 4, 66]];
  done $c;
} n => 2, name => 'manakai_set_attribute_indexed_string_ns namespaced';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  dies_here_ok {
    $el->manakai_set_attribute_indexed_string_ns (undef, 'aaa' => 'abc');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The argument is not an IndexedString';
  is $el->attributes->length, 0;
  done $c;
} n => 4, name => 'manakai_set_attribute_indexed_string_ns bad value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  dies_here_ok {
    $el->manakai_set_attribute_indexed_string_ns (undef, 'aaa' => ['abc']);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The argument is not an IndexedString';
  is $el->attributes->length, 0;
  done $c;
} n => 4, name => 'manakai_set_attribute_indexed_string_ns bad value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');
  $el->set_attribute_ns ('http://foo', 'a:bar' => 'abc');
  eq_or_diff $el->manakai_get_attribute_indexed_string_ns
      ('http://foo', 'bar'), [['abc', -1, 0]];
  done $c;
} n => 1, name => 'manakai_get_attribute_indexed_string_ns complex attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $list = $el->get_attribute_names;
  is ref $list, 'ARRAY';
  is 0+@$list, 0;
  done $c;
} n => 2, name => 'get_attribute_names empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute (foo => 1);
  $el->set_attribute (hoge => 42);
  my $list = $el->get_attribute_names;
  is ref $list, 'ARRAY';
  is 0+@$list, 2;
  is $list->[0], 'foo';
  is $list->[1], 'hoge';
  done $c;
} n => 4, name => 'get_attribute_names simple attrs';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute (foo => 1);
  $el->set_attribute_ns (q<about:blank>, hoge => 42);
  my $list = $el->get_attribute_names;
  is ref $list, 'ARRAY';
  is 0+@$list, 2;
  is $list->[0], 'foo';
  is $list->[1], 'hoge';
  done $c;
} n => 4, name => 'get_attribute_names simple and complex attrs';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute (foo => 1);
  $el->set_attribute_ns (q<about:blank>, 'abc:hoge' => 42);
  my $list = $el->get_attribute_names;
  is ref $list, 'ARRAY';
  is 0+@$list, 2;
  is $list->[0], 'foo';
  is $list->[1], 'abc:hoge';
  done $c;
} n => 4, name => 'get_attribute_names prefixed qname';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns (undef, hoge => 1);
  $el->set_attribute_ns (q<about:blank>, hoge => 42);
  my $list = $el->get_attribute_names;
  is ref $list, 'ARRAY';
  is 0+@$list, 2;
  is $list->[0], 'hoge';
  is $list->[1], 'hoge';
  done $c;
} n => 4, name => 'get_attribute_names duplicate names';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute (foo => 1);
  $el->set_attribute (hoge => 42);
  my $list = $el->get_attribute_names;
  $el->remove_attribute ('hoge');
  is ref $list, 'ARRAY';
  is 0+@$list, 2;
  is $list->[0], 'foo';
  is $list->[1], 'hoge';
  my $list2 = $el->get_attribute_names;
  isnt $list2, $list;
  is 0+@$list2, 1;
  is $list2->[0], 'foo';
  done $c;
} n => 7, name => 'get_attribute_names mutation';

run_tests;

=head1 LICENSE

Copyright 2012-2015 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
