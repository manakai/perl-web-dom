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
  my $doc = Web::DOM::Document->new;

  my $el = $doc->create_element ('abc');
  isa_ok $el, 'Web::DOM::Element';
  is $el->node_type, 1;
  is $el->prefix, undef;
  is $el->namespace_uri, q<http://www.w3.org/1999/xhtml>;
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
  is $el->namespace_uri, q<http://www.w3.org/1999/xhtml>;
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
  is $el->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $el->manakai_local_name, 'v:circle';
  done $c;
} n => 3, name => 'create_element local name with :';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element (':circle');
  is $el->prefix, undef;
  is $el->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $el->manakai_local_name, ':circle';
  done $c;
} n => 3, name => 'create_element local name starting with :';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ("\x{6000}");
  is $el->prefix, undef;
  is $el->namespace_uri, q<http://www.w3.org/1999/xhtml>;
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
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_element_ns bad name';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  dies_here_ok {
    $doc->create_element_ns (undef, ':hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
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
  is $@->name, 'NamespaceError';
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
  is $@->name, 'NamespaceError';
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
  is $@->name, 'NamespaceError';
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
  is $@->name, 'NamespaceError';
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
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_element_ns undef';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut