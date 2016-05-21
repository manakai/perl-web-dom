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
  [[HTML_NS, 'a'], ['Element', 'HTMLElement', 'HTMLAnchorElement'],
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
  [[HTML_NS, 'data'], ['Element', 'HTMLElement', 'HTMLDataElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'time'], ['Element', 'HTMLElement', 'HTMLTimeElement'],
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
  [[HTML_NS, 'rp'], ['Element', 'HTMLElement'],
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
   ['Element', 'HTMLElement', 'HTMLTableCellElement'],
   ['HTMLUnknownElement', 'HTMLTableDataCellElement']],
  [[HTML_NS, 'th'],
   ['Element', 'HTMLElement', 'HTMLTableCellElement'],
   ['HTMLUnknownElement', 'HTMLTableHeaderCellElement']],
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
  [[HTML_NS, 'datalist'], ['Element', 'HTMLElement', 'HTMLDataListElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'optgroup'], ['Element', 'HTMLElement', 'HTMLOptGroupElement'],
   ['HTMLUnknownElement', 'HTMLOptionElement']],
  [[HTML_NS, 'option'], ['Element', 'HTMLElement', 'HTMLOptionElement'],
   ['HTMLUnknownElement', 'HTMLOptGroupElement']],
  [[HTML_NS, 'textarea'], ['Element', 'HTMLElement', 'HTMLTextAreaElement'],
   ['HTMLUnknownElement', 'HTMLOptGroupElement']],
  [[HTML_NS, 'keygen'], ['Element', 'HTMLElement', 'HTMLKeygenElement'],
   ['HTMLUnknownElement', 'HTMLOptGroupElement']],
  [[HTML_NS, 'output'], ['Element', 'HTMLElement', 'HTMLOutputElement'],
   ['HTMLUnknownElement', 'HTMLOptGroupElement']],
  [[HTML_NS, 'progress'], ['Element', 'HTMLElement', 'HTMLProgressElement'],
   ['HTMLUnknownElement', 'HTMLOptGroupElement']],
  [[HTML_NS, 'meter'], ['Element', 'HTMLElement', 'HTMLMeterElement'],
   ['HTMLUnknownElement', 'HTMLOptGroupElement']],
  [[HTML_NS, 'details'], ['Element', 'HTMLElement', 'HTMLDetailsElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'summary'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'menu'], ['Element', 'HTMLElement', 'HTMLMenuElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'menuitem'], ['Element', 'HTMLElement', 'HTMLMenuItemElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'template'], ['Element', 'HTMLElement', 'HTMLTemplateElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'slot'], ['Element', 'HTMLElement', 'HTMLSlotElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'picture'], ['Element', 'HTMLElement', 'HTMLPictureElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'applet'], ['Element', 'HTMLElement', 'HTMLAppletElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'marquee'], ['Element', 'HTMLElement', 'HTMLMarqueeElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'frameset'], ['Element', 'HTMLElement', 'HTMLFrameSetElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'frame'], ['Element', 'HTMLElement', 'HTMLFrameElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'basefont'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement', 'HTMLBaseFontElement']],
  [[HTML_NS, 'font'], ['Element', 'HTMLElement', 'HTMLFontElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'listing'], ['Element', 'HTMLElement', 'HTMLPreElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'plaintext'], ['Element', 'HTMLElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'xmp'], ['Element', 'HTMLElement', 'HTMLPreElement'],
   ['HTMLUnknownElement']],
  [[HTML_NS, 'acronym'], ['Element', 'HTMLElement'], ['HTMLUnknownElement']],
  [[HTML_NS, 'noframes'], ['Element', 'HTMLElement'], ['HTMLUnknownElement']],
  [[HTML_NS, 'noembed'], ['Element', 'HTMLElement'], ['HTMLUnknownElement']],
  [[HTML_NS, 'strike'], ['Element', 'HTMLElement'], ['HTMLUnknownElement']],
  [[HTML_NS, 'big'], ['Element', 'HTMLElement'], ['HTMLUnknownElement']],
  [[HTML_NS, 'blink'], ['Element', 'HTMLElement', 'HTMLUnknownElement'], ['']],
  [[HTML_NS, 'center'], ['Element', 'HTMLElement'], ['HTMLUnknownElement']],
  [[HTML_NS, 'nobr'], ['Element', 'HTMLElement'], ['HTMLUnknownElement']],
  [[HTML_NS, 'tt'], ['Element', 'HTMLElement'], ['HTMLUnknownElement']],
  [[HTML_NS, 'bgsound'], ['Element', 'HTMLElement', 'HTMLUnknownElement'], []],
  [[HTML_NS, 'isindex'], ['Element', 'HTMLElement', 'HTMLUnknownElement'], []],
  [[HTML_NS, 'multicol'], ['Element', 'HTMLElement', 'HTMLUnknownElement'],
   []],
  [[HTML_NS, 'nextid'], ['Element', 'HTMLElement', 'HTMLUnknownElement'], []],
  [[HTML_NS, 'rb'], ['Element', 'HTMLElement'], ['HTMLUnknownElement']],
  [[HTML_NS, 'rtc'], ['Element', 'HTMLElement'], ['HTMLUnknownElement']],
  [[HTML_NS, 'rbc'], ['Element', 'HTMLElement', 'HTMLUnknownElement'], []],
  [[HTML_NS, 'image'], ['Element', 'HTMLElement', 'HTMLUnknownElement'], []],
  [[HTML_NS, 'spacer'], ['Element', 'HTMLElement', 'HTMLUnknownElement'], []],
  [[HTML_NS, 'unknown'], ['Element', 'HTMLElement', 'HTMLUnknownElement'], []],
  [[HTML_NS, 'Strong'], ['Element', 'HTMLElement', 'HTMLUnknownElement'], []],
  [[HTML_NS, "\x{500}"], ['Element', 'HTMLElement', 'HTMLUnknownElement'], []],
  [[HTML_NS, [undef, 'html:p']],
   ['Element', 'HTMLElement', 'HTMLUnknownElement'], []],
  [[ATOM_NS, 'hoge'], ['Element', 'AtomElement'], ['AtomLinkElement']],
  [[ATOM_NS, 'id'], ['Element', 'AtomElement', 'AtomIdElement'], []],
  [[ATOM_NS, 'icon'], ['Element', 'AtomElement', 'AtomIconElement'], []],
  [[ATOM_NS, 'name'], ['Element', 'AtomElement', 'AtomNameElement'], []],
  [[ATOM_NS, 'uri'], ['Element', 'AtomElement', 'AtomUriElement'], []],
  [[ATOM_NS, 'email'], ['Element', 'AtomElement', 'AtomEmailElement'], []],
  [[ATOM_NS, 'logo'], ['Element', 'AtomElement', 'AtomLogoElement'], []],
  [[ATOM_NS, 'rights'], ['Element', 'AtomElement', 'AtomTextConstruct',
                         'AtomRightsElement'], []],
  [[ATOM_NS, 'subtitle'], ['Element', 'AtomElement', 'AtomTextConstruct',
                           'AtomSubtitleElement'], []],
  [[ATOM_NS, 'summary'], ['Element', 'AtomElement', 'AtomTextConstruct',
                          'AtomSummaryElement'], []],
  [[ATOM_NS, 'title'], ['Element', 'AtomElement', 'AtomTextConstruct',
                        'AtomTitleElement'], []],
  [[ATOM_NS, 'author'], ['Element', 'AtomElement', 'AtomPersonConstruct',
                         'AtomAuthorElement'], []],
  [[ATOM_NS, 'contributor'], ['Element', 'AtomElement', 'AtomPersonConstruct',
                              'AtomContributorElement'], []],
  [[ATOM_NS, 'updated'], ['Element', 'AtomElement', 'AtomDateConstruct',
                          'AtomUpdatedElement'], []],
  [[ATOM_NS, 'published'], ['Element', 'AtomElement', 'AtomDateConstruct',
                            'AtomPublishedElement'], []],
  [[ATOM_NS, 'feed'], ['Element', 'AtomElement', 'AtomFeedElement'], []],
  [[ATOM_NS, 'entry'], ['Element', 'AtomElement', 'AtomEntryElement'], []],
  [[ATOM_NS, 'source'], ['Element', 'AtomElement', 'AtomSourceElement'], []],
  [[ATOM_NS, 'content'], ['Element', 'AtomElement', 'AtomContentElement'], []],
  [[ATOM_NS, 'category'], ['Element', 'AtomElement',
                           'AtomCategoryElement'], []],
  [[ATOM_NS, 'generator'], ['Element', 'AtomElement',
                            'AtomGeneratorElement'], []],
  [[ATOM_NS, 'link'], ['Element', 'AtomElement', 'AtomLinkElement'], []],
  [[ATOM_THREAD_NS, 'hoge'], ['Element', 'AtomElement'], []],
  [[ATOM_THREAD_NS, 'in-reply-to'], ['Element', 'AtomElement',
                                     'AtomThreadInReplyToElement'], []],
  [[ATOM_THREAD_NS, 'total'], ['Element', 'AtomElement',
                               'AtomThreadTotalElement'], []],
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->strict_error_checking (0);
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
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'el');

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
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'abc');
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

  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoGe');
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
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  
  is $el->manakai_base_uri, undef;

  $el->manakai_base_uri ('http://foo/');
  is $el->manakai_base_uri, undef;

  $el->manakai_base_uri ('0');
  is $el->manakai_base_uri, undef;

  $el->manakai_base_uri (undef);
  is $el->manakai_base_uri, undef;

  done $c;
} n => 4, name => 'manakai_base_uri';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e2');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e3');

  $el1->append_child ($el2);

  my $return = $el2->insert_adjacent_element ('beforebegin', $el3);
  is $return, $el3;

  is $el3->parent_node, $el1;
  is $el3->previous_sibling, undef;
  is $el3->next_sibling, $el2;

  done $c;
} n => 4, name => 'insert_adjacent_element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e2');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e3');

  $el1->append_child ($el2);

  my $return = $el2->insert_adjacent_element ('AfterEND', $el3);
  is $return, $el3;

  is $el3->parent_node, $el1;
  is $el3->previous_sibling, $el2;
  is $el3->next_sibling, undef;

  done $c;
} n => 4, name => 'insert_adjacent_element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e2');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e3');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e4');

  $el1->append_child ($el2);
  $el2->append_child ($el4);

  my $return = $el2->insert_adjacent_element ('afterbegin', $el3);
  is $return, $el3;

  is $el3->parent_node, $el2;
  is $el3->previous_sibling, undef;
  is $el3->next_sibling, $el4;

  done $c;
} n => 4, name => 'insert_adjacent_element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e2');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e3');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e4');

  $el1->append_child ($el2);
  $el2->append_child ($el4);

  my $return = $el2->insert_adjacent_element ('BEFOREEND', $el3);
  is $return, $el3;

  is $el3->parent_node, $el2;
  is $el3->previous_sibling, $el4;
  is $el3->next_sibling, undef;

  done $c;
} n => 4, name => 'insert_adjacent_element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e3');

  is $el1->insert_adjacent_element ('beforebegin', $el3), undef;
  is $el3->parent_node, undef;

  done $c;
} n => 2, name => 'insert_adjacent_element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e3');

  is $el1->insert_adjacent_element ('afterend', $el3), undef;
  is $el3->parent_node, undef;

  done $c;
} n => 2, name => 'insert_adjacent_element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e3');

  dies_here_ok {
    $el1->insert_adjacent_element ('hoge', $el3);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'Unknown position is specified';
  is $el3->parent_node, undef;

  done $c;
} n => 5, name => 'insert_adjacent_element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');
  $doc->append_child ($el1);
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e3');

  dies_here_ok {
    $el1->insert_adjacent_element ('beforebegin', $el3);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document node cannot have two element children';
  is $el3->parent_node, undef;

  done $c;
} n => 5, name => 'insert_adjacent_element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');
  $doc->append_child ($el1);
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e3');

  dies_here_ok {
    $el1->insert_adjacent_element ('afterend', $el3);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document node cannot have two element children';
  is $el3->parent_node, undef;

  done $c;
} n => 5, name => 'insert_adjacent_element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');

  dies_here_ok {
    $el1->insert_adjacent_element ('beforeend', 'hoge');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The argument is not an Element';

  done $c;
} n => 3, name => 'insert_adjacent_element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e2');

  $el1->append_child ($el2);

  $el2->insert_adjacent_text ('beforebegin', 'foo');

  is $el1->child_nodes->length, 2;
  is $el1->first_child->node_type, 3;
  is $el1->first_child->data, 'foo';

  done $c;
} n => 3, name => 'insert_adjacent_text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e2');

  $el1->append_child ($el2);

  $el2->insert_adjacent_text ('afterend', 'foo');

  is $el1->child_nodes->length, 2;
  is $el1->last_child->node_type, 3;
  is $el1->last_child->data, 'foo';

  done $c;
} n => 3, name => 'insert_adjacent_text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e2');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e4');

  $el1->append_child ($el2);
  $el2->append_child ($el4);

  $el2->insert_adjacent_text ('afterbegin', 'foo');

  is $el2->child_nodes->length, 2;
  is $el2->first_child->node_type, 3;
  is $el2->first_child->data, 'foo';

  done $c;
} n => 3, name => 'insert_adjacent_text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e2');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e4');

  $el1->append_child ($el2);
  $el2->append_child ($el4);

  $el2->insert_adjacent_text ('BEFOREEND', 'foo');

  is $el2->child_nodes->length, 2;
  is $el2->last_child->node_type, 3;
  is $el2->last_child->data, 'foo';

  done $c;
} n => 3, name => 'insert_adjacent_text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');

  is $el1->insert_adjacent_text ('beforebegin', 'abcde'), undef;
  is $el1->child_nodes->length, 0;

  done $c;
} n => 2, name => 'insert_adjacent_text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');

  is $el1->insert_adjacent_text ('afterend', 'abcde'), undef;
  is $el1->child_nodes->length, 0;

  done $c;
} n => 2, name => 'insert_adjacent_text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');

  dies_here_ok {
    $el1->insert_adjacent_text ('hoge', 'foobar');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'Unknown position is specified';
  is $el1->child_nodes->length, 0;

  done $c;
} n => 5, name => 'insert_adjacent_text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');
  $doc->append_child ($el1);
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e3');

  dies_here_ok {
    $el1->insert_adjacent_text ('beforebegin', 'foobar');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document node cannot contain this kind of node';
  is $el3->parent_node, undef;

  done $c;
} n => 5, name => 'insert_adjacent_text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e1');
  $doc->append_child ($el1);
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e3');

  dies_here_ok {
    $el1->insert_adjacent_text ('afterend', 'foobar');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document node cannot contain this kind of node';
  is $el3->parent_node, undef;

  done $c;
} n => 5, name => 'insert_adjacent_text';

run_tests;

=head1 LICENSE

Copyright 2012-2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
