use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->parent->parent->child
    ('t_deps/modules/*/lib')->stringify;
use lib glob path (__FILE__)->parent->parent->parent->child
    ('t_deps/lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;

  my $el = $doc->create_element ('abc');
  isa_ok $el, 'Web::DOM::Element';
  is $el->node_type, 1;
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->manakai_local_name, q<abc>;
  is $el->tag_name, q<abc>;
  is $el->owner_document, $doc;
  is scalar @{$el->attributes}, 0;

  done $c;
} n => 8, name => 'create_element / XML, Name';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  $doc->manakai_is_html (1);

  my $el = $doc->create_element ('abc');
  isa_ok $el, 'Web::DOM::Element';
  is $el->node_type, 1;
  is $el->prefix, undef;
  is $el->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $el->manakai_local_name, q<abc>;
  is $el->tag_name, q<ABC>;
  is $el->owner_document, $doc;
  is scalar @{$el->attributes}, 0;

  done $c;
} n => 8, name => 'create_element / HTML, Name';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;

  my $el = $doc->create_element ("abc\x{5000}\x{1E000}");
  isa_ok $el, 'Web::DOM::Element';
  is $el->node_type, 1;
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->manakai_local_name, qq<abc\x{5000}\x{1E000}>;
  is $el->tag_name, qq<abc\x{5000}\x{1E000}>;
  is $el->owner_document, $doc;
  is scalar @{$el->attributes}, 0;

  done $c;
} n => 8, name => 'create_element / XML, Name non-ASCII';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  $doc->manakai_is_html (1);

  my $el = $doc->create_element ("abc\x{5000}\x{1E000}");
  isa_ok $el, 'Web::DOM::Element';
  is $el->node_type, 1;
  is $el->prefix, undef;
  is $el->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $el->manakai_local_name, qq<abc\x{5000}\x{1E000}>;
  is $el->tag_name, qq<ABC\x{5000}\x{1E000}>;
  is $el->owner_document, $doc;
  is scalar @{$el->attributes}, 0;

  done $c;
} n => 8, name => 'create_element / HTML, Name non-ASCII';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;

  dies_here_ok {
    $doc->create_element ('1abc');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The local name is not an XML Name';

  done $c;
} n => 4, name => 'create_element / XML, not Name';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  $doc->manakai_is_html (1);

  dies_here_ok {
    $doc->create_element ('1abc');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The local name is not an XML Name';

  done $c;
} n => 4, name => 'create_element / HTML, not Name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('v:circle');
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->manakai_local_name, 'v:circle';
  done $c;
} n => 3, name => 'create_element local name with :';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element (':circle');
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->manakai_local_name, ':circle';
  done $c;
} n => 3, name => 'create_element local name starting with :';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ("\x{6000}");
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->manakai_local_name, "\x{6000}";
  done $c;
  undef $c;
} n => 3, name => 'create_element with non-ASCII local name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element;
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The local name is not an XML Name';
  done $c;
} n => 4, name => 'create_element undef';

for my $mime (qw(
  application/xhtml+xml
)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->_set_content_type ($mime);
    my $el = $doc->create_element ('foo');
    is $el->namespace_uri, 'http://www.w3.org/1999/xhtml';
    done $c;
  } n => 1, name => ['create_element', $mime];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->manakai_is_html (1);
    $doc->_set_content_type ($mime);
    my $el = $doc->create_element ('foo');
    is $el->namespace_uri, 'http://www.w3.org/1999/xhtml';
    done $c;
  } n => 1, name => ['create_element HTML', $mime];
}

for my $mime (qw(
  application/xml text/xml text/plain application/rdf+xml image/svg+xml
  application/octet-stream text/css text/javascript application/json
  text/html
)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->_set_content_type ($mime);
    my $el = $doc->create_element ('foo');
    is $el->namespace_uri, undef;
    done $c;
  } n => 1, name => ['create_element', $mime];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->manakai_is_html (1);
    $doc->_set_content_type ($mime);
    my $el = $doc->create_element ('foo');
    is $el->namespace_uri, 'http://www.w3.org/1999/xhtml';
    done $c;
  } n => 1, name => ['create_element HTML', $mime];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $el = $doc->create_element_ns (undef, 'hoge');
  isa_ok $el, 'Web::DOM::Element';
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->manakai_local_name, 'hoge';
  is $el->owner_document, $doc;
  is scalar @{$el->attributes}, 0;
  done $c;
} n => 6, name => 'create_element_ns, null ns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $el = $doc->create_element_ns (undef, 'HOGE');
  isa_ok $el, 'Web::DOM::Element';
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->manakai_local_name, 'HOGE';
  is $el->owner_document, $doc;
  is scalar @{$el->attributes}, 0;
  done $c;
} n => 6, name => 'create_element_ns, null ns, uppercase';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $el = $doc->create_element_ns (q<http://www.w3.org/1999/xhtml>, 'Hoge');
  isa_ok $el, 'Web::DOM::Element';
  is $el->prefix, undef;
  is $el->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $el->manakai_local_name, 'Hoge';
  is $el->owner_document, $doc;
  is scalar @{$el->attributes}, 0;
  done $c;
} n => 6, name => 'create_element_ns, HTML ns, mixed case';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (q<ho ge>, 'fuga');
  is $el->prefix, undef;
  is $el->namespace_uri, q<ho ge>;
  is $el->manakai_local_name, 'fuga';
  done $c;
} n => 3, name => 'create_element_ns default namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (q<ho ge>, 'abc:fuga');
  is $el->prefix, 'abc';
  is $el->namespace_uri, q<ho ge>;
  is $el->manakai_local_name, 'fuga';
  done $c;
} n => 3, name => 'create_element_ns prefixed namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('', 'fuga');
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->manakai_local_name, 'fuga';
  done $c;
} n => 3, name => 'create_element_ns empty namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (undef, 'a');
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->manakai_local_name, 'a';
  done $c;
}n => 3, name => 'create_element_ns name.length = 1';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns (undef, '120');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_element_ns bad name';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  dies_here_ok {
    $doc->create_element_ns (undef, ':hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_element_ns bad qname';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  dies_here_ok {
    $doc->create_element_ns (undef, 'hoge:');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_element_ns bad qname';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  dies_here_ok {
    $doc->create_element_ns (undef, ':');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_element_ns bad qname';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  dies_here_ok {
    $doc->create_element_ns (q<fuga>, 'hoge:120');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_element_ns bad qname';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  dies_here_ok {
    $doc->create_element_ns (undef, 'hoge:fuga:abbc');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_element_ns bad qname';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns (undef, q<h:Fuga>);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';
  done $c;
} n => 4, name => 'create_element_ns null namespaced prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns (undef, q<xml:Fuga>);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';
  done $c;
} n => 4, name => 'create_element_ns null namespaced prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns (undef, q<xmlns:Fuga>);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';
  done $c;
} n => 4, name => 'create_element_ns null namespaced prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns (q<http://hoge/fuga>, q<xml:Fuga>);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message,
      'Prefix |xml| cannot be bound to anything other than XML namespace';
  done $c;
} n => 4, name => 'create_element_ns xml namespace prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (q<http://www.w3.org/XML/1998/namespace>, q<xml:Father>);
  is $el->prefix, 'xml';
  is $el->namespace_uri, q<http://www.w3.org/XML/1998/namespace>;
  is $el->manakai_local_name, q<Father>;
  done $c;
} n => 3, name => 'create_element_ns xml namespace prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (q<http://www.w3.org/XML/1998/namespace>, q<nonxml:Father>);
  is $el->prefix, 'nonxml';
  is $el->namespace_uri, q<http://www.w3.org/XML/1998/namespace>;
  is $el->manakai_local_name, q<Father>;
  done $c;
} n => 3, name => 'create_element_ns xml namespace URL';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (q<http://www.w3.org/XML/1998/namespace>, q<Father>);
  is $el->prefix, undef;
  is $el->namespace_uri, q<http://www.w3.org/XML/1998/namespace>;
  is $el->manakai_local_name, q<Father>;
  done $c;
} n => 3, name => 'create_element_ns xml namespace URL';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns (q<http://hoge/fuga>, q<xmlns:Fuga>);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message,
      'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
  done $c;
} n => 4, name => 'create_element_ns xmlns namespace prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns (undef, 'xmlns');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message,
      'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
  done $c;
} n => 4, name => 'create_element_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns ('http://hoge/', 'xmlns');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message,
      'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
  done $c;
} n => 4, name => 'create_element_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns (undef, 'xmlns:hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';
  done $c;
} n => 4, name => 'create_element_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns ('http://hpoge', 'xmlns:hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message,
      'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
  done $c;
} n => 4, name => 'create_element_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns ('http://www.w3.org/2000/xmlns/', 'hloge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';
  done $c;
} n => 4, name => 'create_element_ns XMLNS namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns ('http://www.w3.org/2000/xmlns/', 'fuga:hloge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';
  done $c;
} n => 4, name => 'create_element_ns XMLNS namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/2000/xmlns/', 'xmlns');
  is $el->prefix, undef;
  is $el->namespace_uri, 'http://www.w3.org/2000/xmlns/';
  is $el->manakai_local_name, 'xmlns';
  done $c;
} n => 3, name => 'create_element_ns XMLNS namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:xmlns');
  is $el->prefix, 'xmlns';
  is $el->namespace_uri, 'http://www.w3.org/2000/xmlns/';
  is $el->manakai_local_name, 'xmlns';
  done $c;
} n => 3, name => 'create_element_ns XMLNS namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:fuga');
  is $el->prefix, 'xmlns';
  is $el->namespace_uri, 'http://www.w3.org/2000/xmlns/';
  is $el->manakai_local_name, 'fuga';
  done $c;
} n => 3, name => 'create_element_ns XMLNS namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns;
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_element_ns undef';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $el = $doc->create_element ('124 aa');
  is $el->namespace_uri, undef;
  is $el->prefix, undef;
  is $el->local_name, '124 aa';
  done $c;
} n => 3, name => 'create_element not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);

  my $attr = $doc->create_element_ns (undef, '123 hoge' => 'abc');
  is $attr->prefix, undef;
  is $attr->local_name, '123 hoge';
  is $attr->namespace_uri, undef;

  done $c;
} n => 3, name => 'create_element_ns not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);

  dies_here_ok {
    $doc->create_element_ns (undef, '' => 'abc');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML QName';

  done $c;
} n => 4, name => 'create_element_ns not strict empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);

  my $attr = $doc->create_element_ns (undef, ':hoge' => 'abc');
  is $attr->prefix, undef;
  is $attr->local_name, ':hoge';
  is $attr->namespace_uri, undef;

  done $c;
} n => 3, name => 'create_element_ns not strict :name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);

  my $attr = $doc->create_element_ns (undef, 'hoge:' => 'abc');
  is $attr->prefix, undef;
  is $attr->local_name, 'hoge:';
  is $attr->namespace_uri, undef;

  done $c;
} n => 3, name => 'create_element_ns not strict name:';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  $doc->strict_error_checking (0);

  my $attr = $doc->create_element_ns ('abc', 'hoge::fuga:' => 'abc');
  is $attr->prefix, 'hoge';
  is $attr->local_name, ':fuga:';
  is $attr->namespace_uri, 'abc';

  done $c;
} n => 3, name => 'create_element_ns not strict name:';

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
    $doc->strict_error_checking (0);

    my $attr = $doc->create_element_ns (@{$test->[0]} => 'abc');
    is $attr->namespace_uri, $test->[1]->[0];
    is $attr->prefix, $test->[1]->[1];
    is $attr->local_name, $test->[1]->[2];

    done $c;
  } n => 3, name => ['create_element_ns', @{$test->[0]}];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://hoge', ['fuga', 'abc']);
  is $el->prefix, 'fuga';
  is $el->local_name, 'abc';
  is $el->namespace_uri, 'http://hoge';
  done $c;
} n => 3, name => 'create_element_ns qname as arrayref';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://hoge', [undef, 'abc']);
  is $el->prefix, undef;
  is $el->local_name, 'abc';
  is $el->namespace_uri, 'http://hoge';
  done $c;
} n => 3, name => 'create_element_ns ncname as arrayref';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns ('http://hoge', [undef, 'a:bc']);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The local name is not an XML NCName';
  done $c;
} n => 4, name => 'create_element_ns arrayref error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns ('http://hoge', ['a:b', 'abc']);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The prefix is not an XML NCName';
  done $c;
} n => 4, name => 'create_element_ns arrayref error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns ('http://hoge', [':', 'abc']);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The prefix is not an XML NCName';
  done $c;
} n => 4, name => 'create_element_ns arrayref error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns ('http://hoge', ['', 'abc']);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The prefix is not an XML NCName';
  done $c;
} n => 4, name => 'create_element_ns arrayref error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $el = $doc->create_element_ns ('http://hoge', [undef, 'a:bc']);
  is $el->prefix, undef;
  is $el->local_name, 'a:bc';
  is $el->namespace_uri, 'http://hoge';
  done $c;
} n => 3, name => 'create_element_ns arrayref not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $el = $doc->create_element_ns ('http://hoge', ['12:ab', 'abc']);
  is $el->prefix, '12:ab';
  is $el->local_name, 'abc';
  is $el->namespace_uri, 'http://hoge';
  done $c;
} n => 3, name => 'create_element_ns arrayref not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $el = $doc->create_element_ns ('http://hoge', ['12:ab', 'a:b:c']);
  is $el->prefix, '12:ab';
  is $el->local_name, 'a:b:c';
  is $el->namespace_uri, 'http://hoge';
  done $c;
} n => 3, name => 'create_element_ns arrayref not strict';

run_tests;

=head1 LICENSE

Copyright 2012-2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
