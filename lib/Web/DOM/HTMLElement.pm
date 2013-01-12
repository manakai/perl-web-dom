package Web::DOM::HTMLElement;
use strict;
use warnings;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::Element);
use Web::DOM::Element;

# XXX implements *EventHandlers

_define_reflect_string title => 'title';
_define_reflect_string lang => 'lang';
_define_reflect_string itemid => 'itemid';
_define_reflect_string accesskey => 'accesskey';

_define_reflect_boolean itemscope => 'itemscope';
_define_reflect_boolean hidden => 'hidden';

_define_reflect_enumerated dir => 'dir', {
  ltr => 'ltr',
  rtl => 'rtl',
  auto => 'auto',
};

# XXX translate dataset itemtype itemref itemprop properties itemvalue
# tabindex click focus blur accesskey_label draggable dropzone
# contenteditable is_contenteditable contextmenu spellcheck
# forcespellcheck command* style

package Web::DOM::HTMLUnknownElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLHtmlElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLHeadElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLTitleElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Node;

sub text ($;$) {
  if (@_ > 1) {
    $_[0]->text_content ($_[1]);
  }
  
  return join '',
      map { $_->data }
      grep { $_->node_type == TEXT_NODE } @{$_[0]->child_nodes};
} # text

package Web::DOM::HTMLBaseElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX href

_define_reflect_string target => 'target';

package Web::DOM::HTMLLinkElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
# XXX LinkStyle
use Web::DOM::Element;

# XXX href rellist disabled sizes

_define_reflect_string rel => 'rel';
_define_reflect_string media => 'media';
_define_reflect_string hreflang => 'hreflang';
_define_reflect_string type => 'type';
_define_reflect_string crossorigin => 'crossorigin';

package Web::DOM::HTMLMetaElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string name => 'name';
_define_reflect_string content => 'content';
_define_reflect_string http_equiv => 'http-equiv';

package Web::DOM::HTMLStyleElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
# XXX LinkStyle
use Web::DOM::Element;

# XXX disabled

_define_reflect_string type => 'type';
_define_reflect_string media => 'media';
_define_reflect_boolean scoped => 'scoped';

package Web::DOM::HTMLScriptElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Node;
use Web::DOM::Element;

# XXX src async

_define_reflect_string type => 'type';
_define_reflect_string charset => 'charset';
_define_reflect_string crossorigin => 'crossorigin';
_define_reflect_boolean defer => 'defer';

sub text ($;$) {
  if (@_ > 1) {
    $_[0]->text_content ($_[1]);
  }
  
  return join '',
      map { $_->data }
      grep { $_->node_type == TEXT_NODE } @{$_[0]->child_nodes};
} # text

package Web::DOM::HTMLBodyElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
# XXX WindowEventHandlers

package Web::DOM::HTMLHeadingElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLParagraphElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLHRElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLPreElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLQuoteElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX cite

package Web::DOM::HTMLOListElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string type => 'type';
_define_reflect_boolean reversed => 'reversed';

# XXX start

package Web::DOM::HTMLUListElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLLIElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_long value => 'value', sub { 0 };

package Web::DOM::HTMLDListElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLDivElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLAnchorElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX href ping rel_list URLUtils

_define_reflect_string target => 'target';
_define_reflect_string download => 'download';
_define_reflect_string rel => 'rel';
_define_reflect_string hreflang => 'hreflang';
_define_reflect_string type => 'type';

sub text ($;$) {
  if (@_ > 1) {
    $_[0]->text_content ($_[1]);
  }
  return $_[0]->text_content;
} # text

package Web::DOM::HTMLDataElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string value => 'value';

package Web::DOM::HTMLTimeElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string datetime => 'datetime';

package Web::DOM::HTMLSpanElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLBRElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLModElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX cite

_define_reflect_string datetime => 'datetime';

package Web::DOM::HTMLImageElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX constructor src

_define_reflect_string alt => 'alt';
_define_reflect_string srcset => 'srcset';
_define_reflect_string crossorigin => 'crossorigin';
_define_reflect_string usemap => 'usemap';
_define_reflect_boolean ismap => 'ismap';

# XXX width height natural_width natural_height complete

package Web::DOM::HTMLIFrameElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX src sandbox content_document content_window

_define_reflect_string srcdoc => 'srcdoc';
_define_reflect_string name => 'name';
_define_reflect_boolean seamless => 'seamless';
_define_reflect_boolean allowfullscreen => 'allowfullscreen';
_define_reflect_string width => 'width';
_define_reflect_string height => 'height';

package Web::DOM::HTMLEmbedElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;
# XXX plugin-specific interface

# XXX legacycaller

_define_reflect_string src => 'src';
_define_reflect_string type => 'type';
_define_reflect_string width => 'width';
_define_reflect_string height => 'height';

package Web::DOM::HTMLObjectElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;
# XXX plugin-specific interface

# XXX legacycaller form content_document content_window will_validate
# validity validation_message check_validity set_custom_validity

_define_reflect_string data => 'data';
_define_reflect_string type => 'type';
_define_reflect_boolean typemustmatch => 'typemustmatch';
_define_reflect_string name => 'name';
_define_reflect_string usemap => 'usemap';
_define_reflect_string width => 'width';
_define_reflect_string height => 'height';

package Web::DOM::HTMLParamElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string name => 'name';
_define_reflect_string value => 'value';

package Web::DOM::HTMLMediaElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string crossorigin => 'crossorigin';
_define_reflect_boolean autoplay => 'autoplay';
_define_reflect_boolean loop => 'loop';
_define_reflect_boolean controls => 'controls';
_define_reflect_boolean default_muted => 'muted';

# XXX and more

package Web::DOM::HTMLVideoElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLMediaElement);
use Web::DOM::Element;

_define_reflect_unsigned_long width => 'width', sub { 0 };
_define_reflect_unsigned_long height => 'height', sub { 0 };

# XXX video_width video_height poster

package Web::DOM::HTMLAudioElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLMediaElement);

# XXX constructor

package Web::DOM::HTMLSourceElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX src

_define_reflect_string type => 'type';
_define_reflect_string media => 'media';

package Web::DOM::HTMLTrackElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX src

_define_reflect_enumerated kind => 'kind', {
  'subtitles' => 'subtitles',
  'captions' => 'captions',
  'descriptions' => 'descriptions',
  'chapters' => 'chapters',
  'metadata' => 'metadata',
  '#missing' => 'subtitles',
};
_define_reflect_string srclang => 'srclang';
_define_reflect_string label => 'label';
_define_reflect_boolean default => 'default';

our @EXPORT = qw(NONE LOADING LOADED ERROR);

sub NONE () { 0 }
sub LOADING () { 1 }
sub LOADED () { 2 }
sub ERROR () { 3 }

# XXX ready_state track

package Web::DOM::HTMLCanvasElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_unsigned_long width => 'width', sub { 300 };
_define_reflect_unsigned_long height => 'height', sub { 150 };

# XXX and more

package Web::DOM::HTMLMapElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string name => 'name';

# XXX areas images

package Web::DOM::HTMLAreaElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX href ping rel_list URLUtils

_define_reflect_string alt => 'alt';
_define_reflect_string coords => 'coords';
_define_reflect_string shape => 'shape';
_define_reflect_string target => 'target';
_define_reflect_string download => 'download';
_define_reflect_string rel => 'rel';
_define_reflect_string hreflang => 'hreflang';
_define_reflect_string type => 'type';

package Web::DOM::HTMLTableElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_boolean sortable => 'sortable';

# XXX more...

package Web::DOM::HTMLTableCaptionElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLTableColElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_unsigned_long_positive span => 'span', sub { 1 };

package Web::DOM::HTMLTableSectionElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX

package Web::DOM::HTMLTableRowElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX

package Web::DOM::HTMLTableCellElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_unsigned_long colspan => 'colspan', sub { 1 };
_define_reflect_unsigned_long rowspan => 'rowspan', sub { 1 };

# XXX headers cell_index

package Web::DOM::HTMLTableDataCellElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLTableCellElement);

package Web::DOM::HTMLTableHeaderCellElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLTableCellElement);
use Web::DOM::Element;

_define_reflect_enumerated scope => 'scope', {
  row => 'row',
  col => 'col',
  rowgroup => 'rowgroup',
  colgroup => 'colgroup',
  # #missing => #auto
};
_define_reflect_string abbr => 'abbr';
_define_reflect_string sorted => 'sorted';

# XXX sort

package Web::DOM::HTMLFormElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string accept_charset => 'accept-charset';
_define_reflect_enumerated autocomplete => 'autocomplete', {
  on => 'on',
  off => 'off',
  '#missing' => 'on',
};
_define_reflect_enumerated enctype => 'enctype', {
  'application/x-www-form-urlencoded' => 'application/x-www-form-urlencoded',
  'multipart/form-data' => 'multipart/form-data',
  'text/plain' => 'text/plain',
  '#invalid' => 'application/x-www-form-urlencoded',
  # #missing
};
_define_reflect_enumerated encode => 'enctype', {
  'application/x-www-form-urlencoded' => 'application/x-www-form-urlencoded',
  'multipart/form-data' => 'multipart/form-data',
  'text/plain' => 'text/plain',
  '#invalid' => 'application/x-www-form-urlencoded',
  # #missing
};
_define_reflect_enumerated method => 'method', {
  get => 'get',
  post => 'post',
  dialog => 'dialog',
  '#invalid' => 'get',
  # #missing
};
_define_reflect_string name => 'name';
_define_reflect_boolean novalidate => 'novalidate';
_define_reflect_string target => 'target';

# XXX action elements length getter submit reset check_validity

package Web::DOM::HTMLFieldSetElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLLegendElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLLabelElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLInputElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLButtonElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLSelectElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLDataListElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLOptGroupElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLOptionElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLTextAreaElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLKeygenElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLOutputElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLProgressElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLMeterElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLDetailsElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLMenuElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLMenuItemElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLDialogElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLAppletElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLMarqueeElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLFrameSetElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLFrameElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLBaseFontElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLDirectoryElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLFontElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLTemplateElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
