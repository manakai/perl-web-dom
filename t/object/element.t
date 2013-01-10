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

for my $test (
  [[undef, 'hoge'], ['Element'], ['HTMLElement']],
  [[HTML_NS, 'fuga'], ['Element', 'HTMLElement', 'HTMLUnknownElement'], []],
  [[HTML_NS, 'html'], ['Element', 'HTMLElement', 'HTMLHtmlElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'head'], ['Element', 'HTMLElement', 'HTMLHeadElement'],
   ['HTMLUnknownElement', 'HTMLHtmlElement']],
  [[undef, 'head'], ['Element'],
   ['HTMLElement', 'HTMLUnknownElement', 'HTMLHtmlElement']],
  [[HTML_NS, 'title'], ['Element', 'HTMLElement', 'HTMLTitleElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'base'], ['Element', 'HTMLElement', 'HTMLBaseElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'link'], ['Element', 'HTMLElement', 'HTMLLinkElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'meta'], ['Element', 'HTMLElement', 'HTMLMetaElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'style'], ['Element', 'HTMLElement', 'HTMLStyleElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'script'], ['Element', 'HTMLElement', 'HTMLScriptElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'noscript'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'body'], ['Element', 'HTMLElement', 'HTMLBodyElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'article'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'section'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'nav'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'aside'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'h1'], ['Element', 'HTMLElement', 'HTMLHeadingElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'h2'], ['Element', 'HTMLElement', 'HTMLHeadingElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'h3'], ['Element', 'HTMLElement', 'HTMLHeadingElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'h4'], ['Element', 'HTMLElement', 'HTMLHeadingElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'h5'], ['Element', 'HTMLElement', 'HTMLHeadingElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'h6'], ['Element', 'HTMLElement', 'HTMLHeadingElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'hgroup'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'header'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'footer'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'address'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'p'], ['Element', 'HTMLElement', 'HTMLParagraphElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'hr'], ['Element', 'HTMLElement', 'HTMLHRElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'pre'], ['Element', 'HTMLElement', 'HTMLPreElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'blockquote'], ['Element', 'HTMLElement', 'HTMLQuoteElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'ol'], ['Element', 'HTMLElement', 'HTMLOListElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'ul'], ['Element', 'HTMLElement', 'HTMLUListElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'li'], ['Element', 'HTMLElement', 'HTMLLIElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'dl'], ['Element', 'HTMLElement', 'HTMLDListElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'dt'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'dd'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'figure'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'figcaption'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'div'], ['Element', 'HTMLElement', 'HTMLDivElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'em'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'strong'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'small'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 's'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'cite'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'q'], ['Element', 'HTMLElement', 'HTMLQuoteElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'dfn'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'abbr'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'time'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'code'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'var'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'samp'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'kbd'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'sub'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'sup'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'i'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'b'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'u'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'mark'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'ruby'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'rt'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'rb'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'bdi'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'bdo'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'span'], ['Element', 'HTMLElement', 'HTMLSpanElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'br'], ['Element', 'HTMLElement', 'HTMLBRElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'wbr'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'ins'], ['Element', 'HTMLElement', 'HTMLModElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'del'], ['Element', 'HTMLElement', 'HTMLModElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'img'], ['Element', 'HTMLElement', 'HTMLImageElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'iframe'], ['Element', 'HTMLElement', 'HTMLIFrameElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'embed'], ['Element', 'HTMLElement', 'HTMLEmbedElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'object'], ['Element', 'HTMLElement', 'HTMLObjectElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'param'], ['Element', 'HTMLElement', 'HTMLParamElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'video'],
   ['Element', 'HTMLElement', 'HTMLMediaElement', 'HTMLVideoElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'audio'],
   ['Element', 'HTMLElement', 'HTMLMediaElement', 'HTMLAudioElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'source'],
   ['Element', 'HTMLElement', 'HTMLSourceElement'],
   ['HTMLUnknownElement', 'HTMLMediaElement']],
  [[HTML_NS, 'track'],
   ['Element', 'HTMLElement', 'HTMLTrackElement'],
   ['HTMLUnknownElement', 'HTMLMediaElement']],
  [[HTML_NS, 'canvas'], ['Element', 'HTMLElement', 'HTMLCanvasElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'map'], ['Element', 'HTMLElement', 'HTMLMapElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'area'], ['Element', 'HTMLElement', 'HTMLAreaElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'table'], ['Element', 'HTMLElement', 'HTMLTableElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'caption'], ['Element', 'HTMLElement', 'HTMLTableCaptionElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'colgroup'], ['Element', 'HTMLElement', 'HTMLTableColElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'col'], ['Element', 'HTMLElement', 'HTMLTableColElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'tbody'], ['Element', 'HTMLElement', 'HTMLTableSectionElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'thead'], ['Element', 'HTMLElement', 'HTMLTableSectionElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'tfoot'], ['Element', 'HTMLElement', 'HTMLTableSectionElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'tr'], ['Element', 'HTMLElement', 'HTMLTableRowElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'td'],
   ['Element', 'HTMLElement', 'HTMLTableCellElement', 
    'HTMLTableDataCellElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'th'],
   ['Element', 'HTMLElement', 'HTMLTableCellElement',
    'HTMLTableHeaderCellElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'form'], ['Element', 'HTMLElement', 'HTMLFormElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'fieldset'], ['Element', 'HTMLElement', 'HTMLFieldSetElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'legend'], ['Element', 'HTMLElement', 'HTMLLegendElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'label'], ['Element', 'HTMLElement', 'HTMLLabelElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'input'], ['Element', 'HTMLElement', 'HTMLInputElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'button'], ['Element', 'HTMLElement', 'HTMLButtonElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'select'], ['Element', 'HTMLElement', 'HTMLSelectElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'summary'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns (@{$test->[0]});
    for (@{$test->[1]}) {
      ok $el->isa ("Web::DOM::$_");
    }
    for (@{$test->[2]}) {
      ok not $el->isa ("Web::DOM::$_");
    }
    done $c;
  } name => ['interface', @{$test->[0]}], n => @{$test->[1]} + @{$test->[2]};
}

test {
  my $c = shift;
  
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('el');

  isa_ok $el, 'Web::DOM::Element';
  is $el->node_type, $el->ELEMENT_NODE;
  is $el->local_name, 'el';
  is $el->manakai_local_name, 'el';
  is $el->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el->prefix, undef;
  is $el->tag_name, 'el';
  is $el->manakai_tag_name, 'el';
  is $el->node_name, $el->tag_name;

  is $el->node_value, undef;
  $el->node_value ('hoge');
  is $el->node_value, undef;

  done $c;
} name => 'basic / XHTML', n => 11;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('abc');
  is $el->local_name, 'abc';
  is $el->manakai_local_name, 'abc';
  is $el->prefix, undef;
  is $el->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el->tag_name, 'ABC';
  is $el->manakai_tag_name, 'abc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / HTML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns (undef, 'abc');
  is $el->local_name, 'abc';
  is $el->manakai_local_name, 'abc';
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->tag_name, 'abc';
  is $el->manakai_tag_name, 'abc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / null in HTML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns
      ('http://www.w3.org/1999/xhtml', 'HoGe:aBc');
  is $el->local_name, 'aBc';
  is $el->manakai_local_name, 'aBc';
  is $el->prefix, 'HoGe';
  is $el->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el->tag_name, 'HOGE:ABC';
  is $el->manakai_tag_name, 'HoGe:aBc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / HTML prefixed in HTML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns ('http://hoge', 'aBc');
  is $el->local_name, 'aBc';
  is $el->manakai_local_name, 'aBc';
  is $el->prefix, undef;
  is $el->namespace_uri, 'http://hoge';
  is $el->tag_name, 'aBc';
  is $el->manakai_tag_name, 'aBc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / XML in HTML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns ('http://hoge', 'AA:aBc');
  is $el->local_name, 'aBc';
  is $el->manakai_local_name, 'aBc';
  is $el->prefix, 'AA';
  is $el->namespace_uri, 'http://hoge';
  is $el->tag_name, 'AA:aBc';
  is $el->manakai_tag_name, 'AA:aBc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / XML prefixed in HTML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (undef, 'aBc');
  is $el->local_name, 'aBc';
  is $el->manakai_local_name, 'aBc';
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->tag_name, 'aBc';
  is $el->manakai_tag_name, 'aBc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / null in XML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aBc');
  is $el->local_name, 'aBc';
  is $el->manakai_local_name, 'aBc';
  is $el->prefix, undef;
  is $el->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el->tag_name, 'aBc';
  is $el->manakai_tag_name, 'aBc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / HTML in XML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://hoge', 'aBc');
  is $el->local_name, 'aBc';
  is $el->manakai_local_name, 'aBc';
  is $el->prefix, undef;
  is $el->namespace_uri, 'http://hoge';
  is $el->tag_name, 'aBc';
  is $el->manakai_tag_name, 'aBc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / XML in XML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://hoge', 'AA:aBc');
  is $el->local_name, 'aBc';
  is $el->manakai_local_name, 'aBc';
  is $el->prefix, 'AA';
  is $el->namespace_uri, 'http://hoge';
  is $el->tag_name, 'AA:aBc';
  is $el->manakai_tag_name, 'AA:aBc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / XML prefixed in XML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('hoGe');
  ok $el->manakai_element_type_match
      ('http://www.w3.org/1999/xhtml', 'hoGe');
  ok not $el->manakai_element_type_match
      ('http://www.w3.org/1999/xhtml', 'hoge');
  ok not $el->manakai_element_type_match (undef, 'hoGe');
  ok not $el->manakai_element_type_match ('', 'hoGe');

  done $c;
} n => 4, name => 'manakai_element_type_match';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element_ns (undef, 'hoGe');
  ok not $el->manakai_element_type_match
      ('http://www.w3.org/1999/xhtml', 'hoGe');
  ok not $el->manakai_element_type_match
      ('http://www.w3.org/1999/xhtml', 'hoge');
  ok $el->manakai_element_type_match (undef, 'hoGe');
  ok $el->manakai_element_type_match ('', 'hoGe');

  done $c;
} n => 4, name => 'manakai_element_type_match';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  
  is $el->manakai_base_uri, undef;

  $el->manakai_base_uri ('http://foo/');
  is $el->manakai_base_uri, 'http://foo/';

  $el->manakai_base_uri ('0');
  is $el->manakai_base_uri, '0';

  $el->manakai_base_uri (undef);
  is $el->manakai_base_uri, undef;

  done $c;
} n => 4, name => 'manakai_base_uri';

run_tests;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
