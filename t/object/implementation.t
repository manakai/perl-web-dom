use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Internal;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;

  my $impl1 = $doc1->implementation;
  my $impl2 = $doc2->implementation;

  ok $impl1;
  like $impl1, qr{^Web::DOM::Implementation=};

  ok $impl1 eq $impl1;
  ok not $impl1 ne $impl1;
  ok not $impl2 eq $impl1;
  ok $impl2 ne $impl1;
  ok $impl1 ne undef;
  ok not $impl1 eq undef;
  is $impl1 cmp $impl1, 0;
  isnt $impl1 cmp $impl2, 0;

  # XXX test unitinialized warning by eq/ne/cmp-ing with undef
  
  done $c;
} name => 'eq', n => 10;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $dom1 = $doc->implementation;
  my $dom2 = $doc->implementation;

  is $dom1, $dom2;

  my $dom_s = $dom1 . '';

  undef $dom1;
  undef $dom2;

  is $doc->implementation . '', $dom_s;
  isnt $doc->implementation, $dom_s;

  done $c;
} n => 3;

test {
  my $c = shift;
  
  my $impl = Web::DOM::Implementation->new;
  isa_ok $impl, 'Web::DOM::Implementation';
  
  done $c;
} name => 'constructor', n => 1;

{
  package test::DestroyCallback;
  sub DESTROY {
    $_[0]->();
  }
}

test {
  my $c = shift;

  my $invoked;
  my $doc = new Web::DOM::Document;
  $doc->set_user_data (destroy => bless sub {
                         $invoked = 1;
                       }, 'test::DestroyCallback');

  my $impl = $doc->implementation;

  undef $doc;
  ok !$invoked;

  undef $impl;
  ok $invoked;

  done $c;
} name => 'destroy', n => 2;

test {
  my $c = shift;

  my $impl = new Web::DOM::Implementation;
  my $doc = $impl->create_document;
  
  isa_ok $doc, 'Web::DOM::Document';
  isa_ok $doc, 'Web::DOM::XMLDocument';

  is $doc->node_type, $doc->DOCUMENT_NODE;
  is $doc->first_child, undef;

  is $doc->url, 'about:blank';
  is $doc->document_uri, $doc->url;
  is $doc->content_type, 'application/xml';
  is $doc->character_set, 'UTF-8';
  is !!$doc->manakai_is_html, !!0;
  is $doc->compat_mode, 'CSS1Compat';
  is $doc->manakai_compat_mode, 'no quirks';
  is $doc->owner_document, undef;

  done $c;
} name => 'create_document', n => 12;

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;
  
  my $doc = $impl->create_document (undef, 'hoge');
  isa_ok $doc, 'Web::DOM::XMLDocument';
  my $el = $doc->first_child;
  is $el->node_type, 1;
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->manakai_local_name, 'hoge';
  is scalar @{$el->attributes}, 0;
  is $el->owner_document, $doc;

  done $c;
} n => 7, name => 'create_document / local name';

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;
  
  my $doc = $impl->create_document ('about:', 'hoge');
  isa_ok $doc, 'Web::DOM::XMLDocument';
  my $el = $doc->first_child;
  is $el->node_type, 1;
  is $el->prefix, undef;
  is $el->namespace_uri, 'about:';
  is $el->manakai_local_name, 'hoge';
  is scalar @{$el->attributes}, 0;
  is $el->owner_document, $doc;

  done $c;
} n => 7, name => 'create_document / nsed local name';

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;
  
  my $doc = $impl->create_document ('fuga', 'aa:hoge');
  isa_ok $doc, 'Web::DOM::XMLDocument';
  my $el = $doc->first_child;
  is $el->node_type, 1;
  is $el->prefix, 'aa';
  is $el->namespace_uri, 'fuga';
  is $el->manakai_local_name, 'hoge';
  is scalar @{$el->attributes}, 0;
  is $el->owner_document, $doc;

  done $c;
} n => 7, name => 'create_document / local name';

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;
  
  my $doc = $impl->create_document ('', 'hoge');
  isa_ok $doc, 'Web::DOM::XMLDocument';
  my $el = $doc->first_child;
  is $el->node_type, 1;
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->manakai_local_name, 'hoge';
  is scalar @{$el->attributes}, 0;
  is $el->owner_document, $doc;

  done $c;
} n => 7, name => 'create_document / local name';

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;
  
  dies_here_ok {
    $impl->create_document (undef, '12hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';

  done $c;
} n => 4, name => 'create_document / bad qname';

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;
  
  dies_here_ok {
    $impl->create_document ('http://www.w3.org/2000/xmlns/', 'aa:hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';

  done $c;
} n => 4, name => 'create_document / bad namespace';

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;
  
  dies_here_ok {
    $impl->create_document (undef, 'aa:hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';

  done $c;
} n => 4, name => 'create_document / bad namespace';

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;
  
  dies_here_ok {
    $impl->create_document (undef, 'aa:12hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The qualified name is not an XML QName';

  done $c;
} n => 4, name => 'create_document / bad namespace';

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;
  my $doc = $impl->create_document ('', '');
  isa_ok $doc, 'Web::DOM::Document';
  is $doc->first_child, undef;
  done $c;
} n => 2, name => 'create_document / empty element name';

test {
  my $c = shift;
  my $doc1 = Web::DOM::Document->new;
  my $el = $doc1->create_element ('hoge');
  dies_here_ok {
    $doc1->implementation->create_document (undef, undef, $el);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'Third argument is not a DocumentType';
  done $c;
} n => 3, name => 'create_document / doctype not a doctype';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $doc2 = $doc->implementation->create_document (undef, undef, $dt);
  is $doc2->child_nodes->length, 1;
  is $doc2->child_nodes->[0], $dt;
  is $dt->owner_document, $doc2;
  is $dt->parent_node, $doc2;
  done $c;
} n => 4, name => 'create_document doctype';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  $doc->append_child ($dt);
  my $doc2 = $doc->implementation->create_document (undef, undef, $dt);
  is $doc2->child_nodes->length, 1;
  is $doc2->child_nodes->[0], $dt;
  is $dt->owner_document, $doc2;
  is $dt->parent_node, $doc2;
  is $doc->child_nodes->length, 0;
  done $c;
} n => 5, name => 'create_document doctype in use';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $doc2 = $doc->implementation->create_document (undef, 'hoge', $dt);
  is $doc2->child_nodes->length, 2;
  is $doc2->child_nodes->[0], $dt;
  my $el = $doc2->last_child;
  is $el->node_type, 1;
  is $el->namespace_uri, undef;
  is $el->prefix, undef;
  is $el->local_name, 'hoge';
  is $dt->owner_document, $doc2;
  is $dt->parent_node, $doc2;
  done $c;
} n => 8, name => 'create_document qname doctype';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $doc2 = $doc->implementation->create_document
      ('undef', ['aa', 'hoge'], $dt);
  is $doc2->child_nodes->length, 2;
  is $doc2->child_nodes->[0], $dt;
  my $el = $doc2->last_child;
  is $el->node_type, 1;
  is $el->namespace_uri, 'undef';
  is $el->prefix, 'aa';
  is $el->local_name, 'hoge';
  is $dt->owner_document, $doc2;
  is $dt->parent_node, $doc2;
  done $c;
} n => 8, name => 'create_document qname doctype';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  dies_here_ok {
    $doc->implementation->create_document
        ('undef', ['aa', 'ho:ge'], $dt);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The local name is not an XML NCName';
  is $dt->parent_node, undef;
  done $c;
} n => 5, name => 'create_document arrayref qname invalid';

for (
  [undef, 'application/xml'],
  ['http://www.w3.org/1999/xhtml', 'application/xhtml+xml'],
  ['http://www.w3.org/2000/svg', 'image/svg+xml'],
  ['hoge', 'application/xml'],
) {
  my ($ns, $mime) = @$_;
  test {
    my $c = shift;
    my $doc0 = new Web::DOM::Document;
    my $impl = $doc0->implementation;

    my $doc = $impl->create_document ($ns, 'hoge');
    is $doc->content_type, $mime;
    done $c;
  } n => 1;
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $impl = $doc->implementation;
  my $dt = $impl->create_document_type ('hoge', 'abc', 'x x y');
  isa_ok $dt, 'Web::DOM::DocumentType';
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->name, 'hoge';
  is $dt->public_id, 'abc';
  is $dt->system_id, 'x x y';
  is $dt->owner_document, $doc;
  is $dt->first_child, undef;
  done $c;
} n => 7, name => 'create_document_type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $impl = $doc->implementation;
  my $dt = $impl->create_document_type ('hoge', 'a"b\'c', 'x "x\' y');
  isa_ok $dt, 'Web::DOM::DocumentType';
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->name, 'hoge';
  is $dt->public_id, 'a"b\'c';
  is $dt->system_id, 'x "x\' y';
  is $dt->owner_document, $doc;
  is $dt->first_child, undef;
  done $c;
} n => 7, name => 'create_document_type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $impl = $doc->implementation;
  my $dt = $impl->create_document_type ('hTml', '', '');
  isa_ok $dt, 'Web::DOM::DocumentType';
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->name, 'hTml';
  is $dt->public_id, '';
  is $dt->system_id, '';
  is $dt->owner_document, $doc;
  is $dt->first_child, undef;
  done $c;
} n => 7, name => 'create_document_type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $impl = $doc->implementation;
  dies_here_ok {
    $impl->create_document_type ('120', '', '');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_document_type not Name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $impl = $doc->implementation;
  dies_here_ok {
    $impl->create_document_type ('abc:120', '', '');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_document_type not QName';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $impl = $doc->implementation;
  my $dt = $impl->create_document_type ('', '', '');
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->node_name, '';
  is $dt->public_id, '';
  is $dt->system_id, '';
  done $c;
} n => 4, name => 'create_document_type not strict empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $impl = $doc->implementation;
  my $dt = $impl->create_document_type ('012:41', 'abc', 'def');
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->node_name, '012:41';
  is $dt->public_id, 'abc';
  is $dt->system_id, 'def';
  done $c;
} n => 4, name => 'create_document_type not strict not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);
  my $impl = $doc->implementation;
  my $dt = $impl->create_document_type ("\x{FFFF}012:41", 'abc', 'def');
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->node_name, "\x{FFFF}012:41";
  is $dt->public_id, 'abc';
  is $dt->system_id, 'def';
  done $c;
} n => 4, name => 'create_document_type not strict not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $impl = $doc->implementation;
  eval {
    $impl->create_document_type ("\x{FFFF}", '', '');
    ok 0;
  };
  ok 1;
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_document_type U+FFFF';

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;

  my $dt = $impl->create_document_type ('hTml', '', '');
  isa_ok $dt, 'Web::DOM::DocumentType';
  ok $dt->owner_document;

  my $dt2 = $impl->create_document_type ('hoge', '', '');
  is $dt2->owner_document, $dt->owner_document;

  done $c;
} n => 3, name => 'create_document_type from new impl';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('foo');
  is $dt->name, 'foo';
  is $dt->public_id, '';
  is $dt->system_id, '';
  done $c;
} n => 3, name => 'create_document_type null';

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;

  my $doc = $impl->create_html_document;
  isa_ok $doc, 'Web::DOM::Document';
  ok not $doc->isa ('Web::DOM::XMLDocument');

  is $doc->node_type, $doc->DOCUMENT_NODE;
  is $doc->local_name, undef;

  is $doc->url, 'about:blank';
  is $doc->document_uri, $doc->url;
  is $doc->content_type, 'text/html';
  is $doc->character_set, 'UTF-8';
  is !!$doc->manakai_is_html, !!1;
  is $doc->compat_mode, 'CSS1Compat';
  is $doc->manakai_compat_mode, 'no quirks';
  is $doc->owner_document, undef;

  is scalar @{$doc->child_nodes}, 2;

  my $dt = $doc->first_child;
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->name, 'html';
  is $dt->public_id, '';
  is $dt->system_id, '';
  is scalar @{$dt->child_nodes}, 0;

  my $html = $doc->last_child;
  is $html->node_type, 1;
  is $html->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $html->prefix, undef;
  is $html->manakai_local_name, 'html';
  is scalar @{$html->child_nodes}, 2;

  my $head = $html->first_child;
  is $head->node_type, 1;
  is $head->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $head->prefix, undef;
  is $head->manakai_local_name, 'head';
  is scalar @{$head->child_nodes}, 0;

  my $body = $html->last_child;
  is $body->node_type, 1;
  is $body->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $body->prefix, undef;
  is $body->manakai_local_name, 'body';
  is scalar @{$body->child_nodes}, 0;

  done $c;
} n => 33, name => 'create_html_document without args';

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;

  my $doc = $impl->create_html_document ('');
  isa_ok $doc, 'Web::DOM::Document';
  ok not $doc->isa ('Web::DOM::XMLDocument');

  is $doc->node_type, $doc->DOCUMENT_NODE;
  is $doc->local_name, undef;

  is $doc->url, 'about:blank';
  is $doc->document_uri, $doc->url;
  is $doc->content_type, 'text/html';
  is $doc->character_set, 'UTF-8';
  is !!$doc->manakai_is_html, !!1;
  is $doc->compat_mode, 'CSS1Compat';
  is $doc->manakai_compat_mode, 'no quirks';
  is $doc->owner_document, undef;

  is scalar @{$doc->child_nodes}, 2;

  my $dt = $doc->first_child;
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->name, 'html';
  is $dt->public_id, '';
  is $dt->system_id, '';
  is scalar @{$dt->child_nodes}, 0;

  my $html = $doc->last_child;
  is $html->node_type, 1;
  is $html->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $html->prefix, undef;
  is $html->manakai_local_name, 'html';
  is scalar @{$html->child_nodes}, 2;

  my $head = $html->first_child;
  is $head->node_type, 1;
  is $head->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $head->prefix, undef;
  is $head->manakai_local_name, 'head';
  is scalar @{$head->child_nodes}, 1;

  my $title = $head->first_child;
  is $title->node_type, 1;
  is $title->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $title->prefix, undef;
  is $title->manakai_local_name, 'title';
  is scalar @{$title->child_nodes}, 1;

  my $text = $title->first_child;
  is $text->node_type, 3;
  is $text->data, '';
  is scalar @{$text->child_nodes}, 0;

  my $body = $html->last_child;
  is $body->node_type, 1;
  is $body->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $body->prefix, undef;
  is $body->manakai_local_name, 'body';
  is scalar @{$body->child_nodes}, 0;

  done $c;
} n => 41, name => 'create_html_document with empty arg';

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;

  my $doc = $impl->create_html_document ('Ho ge');
  isa_ok $doc, 'Web::DOM::Document';
  ok not $doc->isa ('Web::DOM::XMLDocument');

  is $doc->node_type, $doc->DOCUMENT_NODE;
  is $doc->local_name, undef;

  is $doc->url, 'about:blank';
  is $doc->document_uri, $doc->url;
  is $doc->content_type, 'text/html';
  is $doc->character_set, 'UTF-8';
  is !!$doc->manakai_is_html, !!1;
  is $doc->compat_mode, 'CSS1Compat';
  is $doc->manakai_compat_mode, 'no quirks';
  is $doc->owner_document, undef;

  is scalar @{$doc->child_nodes}, 2;

  my $dt = $doc->first_child;
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->name, 'html';
  is $dt->public_id, '';
  is $dt->system_id, '';
  is scalar @{$dt->child_nodes}, 0;

  my $html = $doc->last_child;
  is $html->node_type, 1;
  is $html->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $html->prefix, undef;
  is $html->manakai_local_name, 'html';
  is scalar @{$html->child_nodes}, 2;

  my $head = $html->first_child;
  is $head->node_type, 1;
  is $head->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $head->prefix, undef;
  is $head->manakai_local_name, 'head';
  is scalar @{$head->child_nodes}, 1;

  my $title = $head->first_child;
  is $title->node_type, 1;
  is $title->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $title->prefix, undef;
  is $title->manakai_local_name, 'title';
  is scalar @{$title->child_nodes}, 1;

  my $text = $title->first_child;
  is $text->node_type, 3;
  is $text->data, 'Ho ge';
  is scalar @{$text->child_nodes}, 0;

  my $body = $html->last_child;
  is $body->node_type, 1;
  is $body->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $body->prefix, undef;
  is $body->manakai_local_name, 'body';
  is scalar @{$body->child_nodes}, 0;

  done $c;
} n => 41, name => 'create_html_document with arg';

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;
  my $doc = $impl->create_atom_feed_document ('hoge');

  isa_ok $doc, 'Web::DOM::Document';
  ok not $doc->isa ('Web::DOM::XMLDocument');

  is $doc->url, 'about:blank';
  is $doc->content_type, 'application/atom+xml';
  is $doc->character_set, 'UTF-8';
  ok not $doc->manakai_is_html;
  is $doc->compat_mode, 'CSS1Compat';
  is $doc->manakai_compat_mode, 'no quirks';

  my $feed = $doc->first_child;
  is $feed->namespace_uri, ATOM_NS;
  is $feed->local_name, 'feed';

  is $feed->atom_id, 'hoge';
  is $feed->title_element->text_content, '';
  is $feed->xmllang, '';
  is $feed->attributes->length, 1;
  is $feed->child_nodes->length, 3;
  is $feed->child_nodes->[0]->local_name, 'id';
  is $feed->child_nodes->[1]->local_name, 'title';
  is $feed->child_nodes->[2]->local_name, 'updated';
  done $c;
} n => 18, name => 'create_atom_feed_document id only';

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;
  my $doc = $impl->create_atom_feed_document ('hoge', 'aa', 'bb');

  isa_ok $doc, 'Web::DOM::Document';
  ok not $doc->isa ('Web::DOM::XMLDocument');

  is $doc->url, 'about:blank';
  is $doc->content_type, 'application/atom+xml';
  is $doc->character_set, 'UTF-8';
  ok not $doc->manakai_is_html;
  is $doc->compat_mode, 'CSS1Compat';
  is $doc->manakai_compat_mode, 'no quirks';

  my $feed = $doc->first_child;
  is $feed->namespace_uri, ATOM_NS;
  is $feed->local_name, 'feed';

  is $feed->atom_id, 'hoge';
  is $feed->title_element->text_content, 'aa';
  is $feed->xmllang, 'bb';
  is $feed->attributes->[0]->prefix, 'xml';
  is $feed->attributes->length, 1;
  is $feed->child_nodes->length, 3;
  is $feed->child_nodes->[0]->local_name, 'id';
  is $feed->child_nodes->[1]->local_name, 'title';
  is $feed->child_nodes->[2]->local_name, 'updated';
  done $c;
} n => 19, name => 'create_atom_feed_document id title lang';

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;
  my $doc = $impl->create_atom_entry_document ('hoge');

  isa_ok $doc, 'Web::DOM::Document';
  ok not $doc->isa ('Web::DOM::XMLDocument');

  is $doc->url, 'about:blank';
  is $doc->content_type, 'application/atom+xml';
  is $doc->character_set, 'UTF-8';
  ok not $doc->manakai_is_html;
  is $doc->compat_mode, 'CSS1Compat';
  is $doc->manakai_compat_mode, 'no quirks';

  my $entry = $doc->first_child;
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
} n => 18, name => 'create_atom_entry_document id only';

test {
  my $c = shift;
  my $impl = new Web::DOM::Implementation;
  my $doc = $impl->create_atom_entry_document ('hoge', 'aa', 'bb');

  isa_ok $doc, 'Web::DOM::Document';
  ok not $doc->isa ('Web::DOM::XMLDocument');

  is $doc->url, 'about:blank';
  is $doc->content_type, 'application/atom+xml';
  is $doc->character_set, 'UTF-8';
  ok not $doc->manakai_is_html;
  is $doc->compat_mode, 'CSS1Compat';
  is $doc->manakai_compat_mode, 'no quirks';

  my $entry = $doc->first_child;
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
} n => 19, name => 'create_atom_entry_document id title lang';

for my $feature (
  '',
  'core',
  'Core',
  'org.w3c.dom',
  'org.W3C.DOM',
  'org.w3.svg',
) {
  test {
    my $c = shift;
    my $impl = new Web::DOM::Implementation;
    ok $impl->has_feature ($feature);
    ok $impl->has_feature ($feature, '');
    ok $impl->has_feature ($feature, '1.0');
    ok $impl->has_feature ($feature, 2.0);
    done $c;
  } n => 4, name => ['has_feature', $feature];
}

for my $feature (
  'http://www.w3.org/TR/SVG',
  'http://www.W3.org/tr/svg',
  'org.w3c.dom.svg',
  'ORG.w3c.SVG',
  'org.w3c.svg',
) {
  test {
    my $c = shift;
    my $impl = new Web::DOM::Implementation;
    ok $impl->has_feature ($feature . 'hogex');
    ok $impl->has_feature ($feature . 'hoge', '');
    ok $impl->has_feature ($feature, 'no such version');
    ok $impl->has_feature ($feature . 'hoge', 'no such version');
    done $c;
  } n => 4, name => ['has_feature', $feature];
}

run_tests;

=head1 LICENSE

Copyright 2012-2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
