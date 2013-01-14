package Web::DOM::HTMLElement;
use strict;
use warnings;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::Element);
use Web::DOM::Internal;
use Web::DOM::Element;
use Web::DOM::Exception;

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

sub translate ($;$) {
  if (@_ > 1) {
    $_[0]->set_attribute_ns (undef, translate => $_[1] ? 'yes' : 'no');
    return unless defined wantarray;
  }

  my $value = ($_[0]->namespace_uri || '') eq HTML_NS
      ? $_[0]->get_attribute_ns (undef, 'translate') : undef;
  if (defined $value) {
    if ($value eq '' or $value =~ /\A[Yy][Ee][Ss]\z/) {
      return 1;
    } elsif ($value =~ /\A[Nn][Oo]\z/) {
      return 0;
    }
  }
  my $pe = $_[0]->parent_element;
  if (defined $pe) {
    return $pe->Web::DOM::HTMLElement::translate;
  }
  return 1;
} # translate

sub draggable ($;$) {
  if (@_ > 1) {
    $_[0]->set_attribute_ns (undef, 'draggable', $_[1] ? 'true' : 'false');
    return unless defined wantarray;
  }

  my $value = $_[0]->get_attribute_ns (undef, 'draggable');
  if (defined $value) {
    if ($value =~ /\A[Tt][Rr][Uu][Ee]\z/) {
      return 1;
    } elsif ($value =~ /\A[Ff][Aa][Ll][Ss][Ee]\z/) {
      return 0;
    }
  }
  if (($_[0]->namespace_uri || '') eq HTML_NS) {
    my $ln = $_[0]->local_name;
    if ($ln eq 'img') {
      return 1;
    } elsif ($ln eq 'a' and $_[0]->has_attribute_ns (undef, 'href')) {
      return 1;
    }
  }
  return 0;
} # draggable

sub contenteditable ($;$) {
  if (@_ > 1) {
    my $value = ''.$_[1];
    if ($value =~ /\A[Tt][Rr][Uu][Ee]\z/) {
      $_[0]->set_attribute_ns (undef, contenteditable => 'true');
    } elsif ($value =~ /\A[Ff][Aa][Ll][Ss][Ee]\z/) {
      $_[0]->set_attribute_ns (undef, contenteditable => 'false');
    } elsif ($value =~ /\A[Ii][Nn][Hh][Ee][Rr][Ii][Tt]\z/) {
      $_[0]->remove_attribute_ns (undef, 'contenteditable');
    } else {
      _throw Web::DOM::Exception 'SyntaxError',
          'An invalid |contenteditable| value is specified';
    }
    return unless defined wantarray;
  }

  my $value = $_[0]->get_attribute_ns (undef, 'contenteditable');
  if (defined $value) {
    if ($value =~ /\A[Tt][Rr][Uu][Ee]\z/) {
      return 'true';
    } elsif ($value =~ /\A[Ff][Aa][Ll][Ss][Ee]\z/) {
      return 'false';
    }
  }
  return 'inherit';
} # contenteditable

_define_reflect_idref contextmenu => 'contextmenu',
    'Web::DOM::HTMLMenuElement';

# XXX dataset itemtype itemref itemprop properties itemvalue dropzone
# command* style

## ------ User interaction ------

# XXX tabindex click focus blur accesskey_label is_contenteditable
# spellcheck force_spell_check

package Web::DOM::HTMLUnknownElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLHtmlElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string version => 'version';

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

_define_reflect_string charset => 'charset';
_define_reflect_string rev => 'rev';
_define_reflect_string target => 'target';

package Web::DOM::HTMLMetaElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string name => 'name';
_define_reflect_string content => 'content';
_define_reflect_string http_equiv => 'http-equiv';

_define_reflect_string scheme => 'scheme';

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

sub event ($;$) { '' }
sub html_for ($;$) { '' }

package Web::DOM::HTMLBodyElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
# XXX WindowEventHandlers
use Web::DOM::Element;

_define_reflect_string_undef text => 'text';
_define_reflect_string_undef link => 'link';
_define_reflect_string_undef alink => 'alink';
_define_reflect_string_undef vlink => 'vlink';
_define_reflect_string_undef bgcolor => 'bgcolor';
_define_reflect_string background => 'background';

package Web::DOM::HTMLHeadingElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string align => 'align';

package Web::DOM::HTMLParagraphElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string align => 'align';

package Web::DOM::HTMLHRElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string align => 'align';
_define_reflect_string color => 'color';
_define_reflect_string size => 'size';
_define_reflect_string width => 'width';
_define_reflect_boolean noshade => 'noshade';

package Web::DOM::HTMLPreElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_long width => 'width', sub { 0 };

package Web::DOM::HTMLQuoteElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX cite

package Web::DOM::HTMLOListElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Internal;
use Web::DOM::Node;
use Web::DOM::Element;

_define_reflect_string type => 'type';
_define_reflect_boolean reversed => 'reversed';

_define_reflect_long start => 'start', sub {
  if ($_[0]->reversed) {
    my @n = grep {
      $_->node_type == ELEMENT_NODE and
      $_->manakai_element_type_match (HTML_NS, 'li');
    } $_[0]->child_nodes->to_list;
    return scalar @n;
  } else {
    return 1;
  }
};

_define_reflect_boolean compact => 'compact';

package Web::DOM::HTMLUListElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_boolean compact => 'compact';
_define_reflect_string type => 'type';

package Web::DOM::HTMLLIElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_long value => 'value', sub { 0 };
_define_reflect_string type => 'type';

package Web::DOM::HTMLDListElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_boolean compact => 'compact';

package Web::DOM::HTMLDivElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string align => 'align';

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

_define_reflect_string coords => 'coords';
_define_reflect_string charset => 'charset';
_define_reflect_string name => 'name';
_define_reflect_string rev => 'rev';
_define_reflect_string shape => 'shape';

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
use Web::DOM::Element;

_define_reflect_string clear => 'clear';

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

# XXX longdesc

_define_reflect_string align => 'align';
_define_reflect_string name => 'name';
_define_reflect_string_undef border => 'border';
_define_reflect_unsigned_long hspace => 'hspace', sub { 0 };
_define_reflect_unsigned_long vspace => 'vspace', sub { 0 };

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

# XXX longdesc

_define_reflect_string align => 'align';
_define_reflect_string frameborder => 'frameborder';
_define_reflect_string scrolling => 'scrolling';
_define_reflect_string_undef marginwidth => 'marginwidth';
_define_reflect_string_undef marginheight => 'marginheight';

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

_define_reflect_string align => 'align';
_define_reflect_string name => 'name';

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

_define_reflect_string align => 'align';
_define_reflect_string archive => 'archive';
_define_reflect_string_undef border => 'border';
_define_reflect_string code => 'code';
_define_reflect_boolean declare => 'declare';
_define_reflect_unsigned_long hspace => 'hspace', sub { 0 };
_define_reflect_string standby => 'standby';
_define_reflect_unsigned_long vspace => 'vspace', sub { 0 };
_define_reflect_string codetype => 'codetype';

# XXX codebase

package Web::DOM::HTMLParamElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string name => 'name';
_define_reflect_string value => 'value';

_define_reflect_string type => 'type';
_define_reflect_string valuetype => 'valuetype';

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

_define_reflect_boolean nohref => 'nohref';

package Web::DOM::HTMLTableElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Internal;
use Web::DOM::Node;
use Web::DOM::Element;

_define_reflect_boolean sortable => 'sortable';

# XXX more...

_define_reflect_string align => 'align';
_define_reflect_string border => 'border';
_define_reflect_string frame => 'frame';
_define_reflect_string rules => 'rules';
_define_reflect_string summary => 'summary';
_define_reflect_string width => 'width';
_define_reflect_string_undef bgcolor => 'bgcolor';
_define_reflect_string_undef cellpadding => 'cellpadding';
_define_reflect_string_undef cellspacing => 'cellspacing';

sub caption ($;$) {
  if (@_ > 1) {
    _throw Web::DOM::TypeError
        'The new value is not a |caption| element'
        if defined $_[1] and
           not UNIVERSAL::isa ($_[1], 'Web::DOM::HTMLTableCaptionElement');
    _throw Web::DOM::Exception 'HierarchyRequestError',
        'The new value is not a |caption| element' unless defined $_[1];
    my $cap = $_[0]->caption; # recursive!
    $_[0]->remove_child ($cap) if defined $cap;
    $_[0]->insert_before ($_[1], $_[0]->first_child);
    return unless defined wantarray;
  }

  for ($_[0]->child_nodes->to_list) {
    if ($_->node_type == ELEMENT_NODE and
        $_->manakai_element_type_match (HTML_NS, 'caption')) {
      return $_;
    }
  }
  return undef;
} # caption

sub create_caption ($) {
  my $caption = $_[0]->caption;
  unless (defined $caption) {
    $caption = $_[0]->owner_document->create_element ('caption');
    $_[0]->insert_before ($caption, $_[0]->first_child);
  }
  return $caption;
} # create_caption

sub delete_caption ($) {
  my $caption = $_[0]->caption;
  $_[0]->remove_child ($caption) if defined $caption;
  return;
} # delete_caption

sub thead ($;$) {
  if (@_ > 1) {
    _throw Web::DOM::TypeError
        'The new value is not a |thead| element'
        if defined $_[1] and
           not UNIVERSAL::isa ($_[1], 'Web::DOM::HTMLTableSectionElement');
    _throw Web::DOM::Exception 'HierarchyRequestError',
        'The new value is not a |thead| element'
            if not defined $_[1] or not $_[1]->local_name eq 'thead';
    my $current = $_[0]->thead; # recursive!
    $_[0]->remove_child ($current) if defined $current;
    my $after;
    for ($_[0]->child_nodes->to_list) {
      next unless $_->node_type == ELEMENT_NODE;
      next if $_->manakai_element_type_match (HTML_NS, 'caption');
      next if $_->manakai_element_type_match (HTML_NS, 'colgroup');
      $after = $_;
      last;
    }
    $_[0]->insert_before ($_[1], $after);
    return unless defined wantarray;
  }

  for ($_[0]->child_nodes->to_list) {
    if ($_->node_type == ELEMENT_NODE and
        $_->manakai_element_type_match (HTML_NS, 'thead')) {
      return $_;
    }
  }
  return undef;
} # thead

sub create_thead ($) {
  my $current = $_[0]->thead;
  unless (defined $current) {
    $current = $_[0]->owner_document->create_element ('thead');
    $_[0]->thead ($current);
  }
  return $current;
} # create_thead

sub delete_thead ($) {
  my $current = $_[0]->thead;
  $_[0]->remove_child ($current) if defined $current;
  return;
} # delete_thead

sub tfoot ($;$) {
  if (@_ > 1) {
    _throw Web::DOM::TypeError
        'The new value is not a |tfoot| element'
        if defined $_[1] and
           not UNIVERSAL::isa ($_[1], 'Web::DOM::HTMLTableSectionElement');
    _throw Web::DOM::Exception 'HierarchyRequestError',
        'The new value is not a |tfoot| element'
            if not defined $_[1] or not $_[1]->local_name eq 'tfoot';
    my $current = $_[0]->tfoot; # recursive!
    $_[0]->remove_child ($current) if defined $current;
    my $after;
    for ($_[0]->child_nodes->to_list) {
      next unless $_->node_type == ELEMENT_NODE;
      next if $_->manakai_element_type_match (HTML_NS, 'caption');
      next if $_->manakai_element_type_match (HTML_NS, 'colgroup');
      next if $_->manakai_element_type_match (HTML_NS, 'thead');
      $after = $_;
      last;
    }
    $_[0]->insert_before ($_[1], $after);
    return unless defined wantarray;
  }

  for ($_[0]->child_nodes->to_list) {
    if ($_->node_type == ELEMENT_NODE and
        $_->manakai_element_type_match (HTML_NS, 'tfoot')) {
      return $_;
    }
  }
  return undef;
} # tfoot

sub create_tfoot ($) {
  my $current = $_[0]->tfoot;
  unless (defined $current) {
    $current = $_[0]->owner_document->create_element ('tfoot');
    $_[0]->tfoot ($current);
  }
  return $current;
} # create_tfoot

sub delete_tfoot ($) {
  my $current = $_[0]->tfoot;
  $_[0]->remove_child ($current) if defined $current;
  return;
} # delete_tfoot

sub tbodies ($) {
  my $self = shift;
  return $$self->[0]->collection ('tbodies', $self, sub {
    my $node = $_[0];
    return grep {
      $$node->[0]->{data}->[$_]->{node_type} == ELEMENT_NODE and
      ${$$node->[0]->{data}->[$_]->{namespace_uri} || \''} eq HTML_NS and
      ${$$node->[0]->{data}->[$_]->{local_name}} eq 'tbody';
    } @{$$node->[0]->{data}->[$$node->[1]]->{child_nodes} or []};
  });
} # tbodies

sub create_tbody ($) {
  my $tbody;
  for (reverse $_[0]->child_nodes->to_list) {
    if ($_->node_type == ELEMENT_NODE and
        $_->manakai_element_type_match (HTML_NS, 'tbody')) {
      $tbody = $_;
      last;
    }
  }
  my $new = $_[0]->owner_document->create_element ('tbody');
  $_[0]->insert_before ($new, $tbody ? $tbody->next_sibling : undef);
  return $new;
} # create_tbody

sub rows ($) {
  my $self = shift;
  return $$self->[0]->collection ('rows', $self, sub {
    my $node = $_[0];
    my @head;
    my @body;
    my @foot;
    for (@{$$node->[0]->{data}->[$$node->[1]]->{child_nodes} or []}) {
      my $data = $$node->[0]->{data}->[$_];
      next unless $data->{node_type} == ELEMENT_NODE;
      next unless ${$data->{namespace_uri} || \''} eq HTML_NS;
      my $ln = ${$data->{local_name}};
      if ($ln eq 'tbody') {
        push @body, @{$$node->[0]->{data}->[$_]->{child_nodes} or []};
      } elsif ($ln eq 'thead') {
        push @head, @{$$node->[0]->{data}->[$_]->{child_nodes} or []};
      } elsif ($ln eq 'tfoot') {
        push @foot, @{$$node->[0]->{data}->[$_]->{child_nodes} or []};
      } elsif ($ln eq 'tr') {
        push @body, $_;
      }
    }
    return grep {
      $$node->[0]->{data}->[$_]->{node_type} == ELEMENT_NODE and
      ${$$node->[0]->{data}->[$_]->{namespace_uri} || \''} eq HTML_NS and
      ${$$node->[0]->{data}->[$_]->{local_name}} eq 'tr';
    } @head, @body, @foot;
  });
} # rows

sub insert_row ($;$) {
  # WebIDL: long optional
  my $index = unpack 'l', pack 'L', (defined $_[1] ? $_[1] : -1) % 2**32;
  my $rows = $_[0]->rows;
  my $row_count = $rows->length;

  if ($index < -1 or $index > $row_count) {
    _throw Web::DOM::Exception 'IndexSizeError',
        'The specified row index is invalid';
  } elsif ($row_count == 0) {
    my $tbodies = $_[0]->tbodies;
    if ($tbodies->length == 0) {
      my $doc = $_[0]->owner_document;
      my $tbody = $doc->create_element ('tbody');
      my $tr = $doc->create_element ('tr');
      $tbody->append_child ($tr);
      $_[0]->append_child ($tbody);
      return $tr;
    } else {
      my $tr = $_[0]->owner_document->create_element ('tr');
      return $tbodies->[-1]->append_child ($tr);
    }
  } elsif ($index == -1 or $index == $row_count) {
    my $tr = $_[0]->owner_document->create_element ('tr');
    return $rows->[-1]->parent_node->append_child ($tr);
  } else {
    my $tr = $_[0]->owner_document->create_element ('tr');
    my $after = $rows->[$index];
    return $after->parent_node->insert_before ($tr, $after);
  }
} # insert_row

sub delete_row ($$) {
  # WebIDL: long
  my $index = unpack 'l', pack 'L', $_[1] % 2**32;
  my $rows = $_[0]->rows;
  my $row_count = @$rows;

  # 1.
  $index = $row_count - 1 if $index == -1;

  # 2.
  if ($index < 0 or $index >= $row_count) {
    _throw Web::DOM::Exception 'IndexSizeError',
        'The specified row index is invalid';
  }

  # 3.
  my $row = $rows->[$index];
  $row->parent_node->remove_child ($row);
  return;
} # delete_row

package Web::DOM::HTMLTableCaptionElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string align => 'align';

package Web::DOM::HTMLTableColElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_unsigned_long_positive span => 'span', sub { 1 };

_define_reflect_string align => 'align';
_define_reflect_string width => 'width';
_define_reflect_string ch => 'char';
_define_reflect_string ch_off => 'charoff';
_define_reflect_string valign => 'valign';

package Web::DOM::HTMLTableSectionElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Internal;
use Web::DOM::Node;
use Web::DOM::Element;

_define_reflect_string align => 'align';
_define_reflect_string ch => 'char';
_define_reflect_string ch_off => 'charoff';
_define_reflect_string valign => 'valign';

sub rows ($) {
  my $self = shift;
  return $$self->[0]->collection ('rows', $self, sub {
    my $node = $_[0];
    return grep {
      $$node->[0]->{data}->[$_]->{node_type} == ELEMENT_NODE and
      ${$$node->[0]->{data}->[$_]->{namespace_uri} || \''} eq HTML_NS and
      ${$$node->[0]->{data}->[$_]->{local_name}} eq 'tr';
    } @{$$node->[0]->{data}->[$$node->[1]]->{child_nodes} or []};
  });
} # rows

sub insert_row ($;$) {
  # WebIDL: long optional
  my $index = unpack 'l', pack 'L', (defined $_[1] ? $_[1] : -1) % 2**32;
  my $rows = $_[0]->rows;
  my $row_count = $rows->length;

  if ($index < -1 or $index > $row_count) {
    _throw Web::DOM::Exception 'IndexSizeError',
        'The specified row index is invalid';
  } elsif ($index == -1 or $index == $row_count) {
    my $tr = $_[0]->owner_document->create_element ('tr');
    return $_[0]->append_child ($tr);
  } else {
    my $tr = $_[0]->owner_document->create_element ('tr');
    my $after = $rows->[$index];
    return $_[0]->insert_before ($tr, $after);
  }
} # insert_row

sub delete_row ($$) {
  # WebIDL: long
  my $index = unpack 'l', pack 'L', $_[1] % 2**32;
  my $rows = $_[0]->rows;

  if ($index < 0 or $index >= @$rows) {
    _throw Web::DOM::Exception 'IndexSizeError',
        'The specified row index is invalid';
  }

  $_[0]->remove_child ($rows->[$index]);
  return;
} # delete_row

package Web::DOM::HTMLTableRowElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Internal;
use Web::DOM::Node;
use Web::DOM::Element;

_define_reflect_string align => 'align';
_define_reflect_string_undef bgcolor => 'bgcolor';
_define_reflect_string ch => 'char';
_define_reflect_string ch_off => 'charoff';
_define_reflect_string valign => 'valign';

sub row_index ($) {
  my $parent = $_[0]->parent_node or return -1;
  return -1 unless $parent->node_type == ELEMENT_NODE;
  return -1 unless ($parent->namespace_uri || '') eq HTML_NS;
  my $parent_ln = $parent->local_name;
  if ($parent_ln eq 'tbody' or $parent_ln eq 'thead' or
      $parent_ln eq 'tfoot') {
    my $gp = $parent->parent_node or return -1;
    return -1 unless $gp->node_type == ELEMENT_NODE;
    return -1 unless $gp->manakai_element_type_match (HTML_NS, 'table');
    my $i = 0;
    for ($gp->rows->to_list) {
      return $i if $_ eq $_[0];
      $i++;
    }
  } elsif ($parent_ln eq 'table') {
    my $i = 0;
    for ($parent->rows->to_list) {
      return $i if $_ eq $_[0];
      $i++;
    }
  }
  return -1;
} # row_index

sub section_row_index ($) {
  my $parent = $_[0]->parent_node or return -1;
  return -1 unless $parent->node_type == ELEMENT_NODE;
  return -1 unless ($parent->namespace_uri || '') eq HTML_NS;
  my $parent_ln = $parent->local_name;
  if ($parent_ln eq 'tbody' or $parent_ln eq 'thead' or
      $parent_ln eq 'tfoot' or $parent_ln eq 'table') {
    my $i = 0;
    for ($parent->rows->to_list) {
      return $i if $_ eq $_[0];
      $i++;
    }
  }
  return -1;
} # section_row_index

sub cells ($) {
  my $self = shift;
  return $$self->[0]->collection ('cells', $self, sub {
    my $node = $_[0];
    return grep {
      $$node->[0]->{data}->[$_]->{node_type} == ELEMENT_NODE and
      ${$$node->[0]->{data}->[$_]->{namespace_uri} || \''} eq HTML_NS and
      ${$$node->[0]->{data}->[$_]->{local_name}} =~ /\At[dh]\z/; # td/th
    } @{$$node->[0]->{data}->[$$node->[1]]->{child_nodes} or []};
  });
} # cells

sub insert_cell ($;$) {
  # WebIDL: long optional
  my $index = unpack 'l', pack 'L', (defined $_[1] ? $_[1] : -1) % 2**32;
  my $cells = $_[0]->cells;
  my $cell_count = $cells->length;

  if ($index < -1 or $index > $cell_count) {
    _throw Web::DOM::Exception 'IndexSizeError',
        'The specified cell index is invalid';
  } elsif ($index == -1 or $index == $cell_count) {
    my $td = $_[0]->owner_document->create_element ('td');
    return $_[0]->append_child ($td);
  } else {
    my $td = $_[0]->owner_document->create_element ('td');
    my $after = $cells->[$index];
    return $_[0]->insert_before ($td, $after);
  }
} # insert_cell

sub delete_cell ($$) {
  # WebIDL: long
  my $index = unpack 'l', pack 'L', $_[1] % 2**32;
  my $cells = $_[0]->cells;

  if ($index < 0 or $index >= @$cells) {
    _throw Web::DOM::Exception 'IndexSizeError',
        'The specified cell index is invalid';
  }

  $_[0]->remove_child ($cells->[$index]);
  return;
} # delete_cell

package Web::DOM::HTMLTableCellElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Internal;
use Web::DOM::Node;
use Web::DOM::Element;

_define_reflect_unsigned_long colspan => 'colspan', sub { 1 };
_define_reflect_unsigned_long rowspan => 'rowspan', sub { 1 };

# XXX headers

_define_reflect_string align => 'align';
_define_reflect_string axis => 'axis';
_define_reflect_string height => 'height';
_define_reflect_string ch => 'char';
_define_reflect_string ch_off => 'charoff';
_define_reflect_boolean nowrap => 'nowrap';
_define_reflect_string valign => 'valign';
_define_reflect_string width => 'width';
_define_reflect_string_undef bgcolor => 'bgcolor';

sub cell_index ($) {
  my $parent = $_[0]->parent_node or return -1;
  return -1 unless $parent->node_type == ELEMENT_NODE;
  return -1 unless $parent->manakai_element_type_match (HTML_NS, 'tr');
  my $i = 0;
  for ($parent->cells->to_list) {
    return $i if $_ eq $_[0];
    $i++;
  }
  return -1;
} # cell_index

package Web::DOM::HTMLTableDataCellElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLTableCellElement);
use Web::DOM::Element;

_define_reflect_string abbr => 'abbr';

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
use Web::DOM::Element;

_define_reflect_boolean disabled => 'disabled';
_define_reflect_string name => 'name';

sub type ($) { 'fieldset' }

# XXX and more

package Web::DOM::HTMLLegendElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX form

_define_reflect_string align => 'align';

package Web::DOM::HTMLLabelElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string html_for => 'for';

# XXX form control

package Web::DOM::HTMLInputElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX autocomplete checked form files formaction height indeterminate
# list src value* width ...

_define_reflect_string accept => 'accept';
_define_reflect_string alt => 'alt';
_define_reflect_boolean autofocus => 'autofocus';
_define_reflect_boolean default_checked => 'checked';
_define_reflect_string dirname => 'dirname';
_define_reflect_boolean disabled => 'disabled';
_define_reflect_enumerated formenctype => 'formenctype', {
  'application/x-www-form-urlencoded' => 'application/x-www-form-urlencoded',
  'multipart/form-data' => 'multipart/form-data',
  'text/plain' => 'text/plain',
  '#invalid' => 'application/x-www-form-urlencoded',
  # #missing
};
_define_reflect_enumerated formmethod => 'formmethod', {
  get => 'get',
  post => 'post',
  dialog => 'dialog',
  '#invalid' => 'get',
  # #missing
};
_define_reflect_boolean formnovalidate => 'formnovalidate';
_define_reflect_string formtarget => 'formtarget';
_define_reflect_enumerated inputmode => 'inputmode', {
  verbatim => 'verbatim',
  latin => 'latin',
  'latin-name' => 'latin-name',
  'latin-prose' => 'latin-prose',
  'full-width-latin' => 'full-width-latin',
  kana => 'kana',
  katakana => 'katakana',
  numeric => 'numeric',
  tel => 'tel',
  email => 'email',
  url => 'url',
  # #missing => default
};
_define_reflect_string max => 'max';
_define_reflect_long_nn maxlength => 'maxlength', sub { -1 };
_define_reflect_string min => 'min';
_define_reflect_boolean multiple => 'multiple';
_define_reflect_string name => 'name';
_define_reflect_string pattern => 'pattern';
_define_reflect_string placeholder => 'placeholder';
_define_reflect_boolean readonly => 'readonly';
_define_reflect_boolean required => 'required';
_define_reflect_unsigned_long size => 'size', sub { 0 };
_define_reflect_string step => 'step';
_define_reflect_enumerated type => 'type', {
  hidden => 'hidden',
  text => 'text',
  search => 'search',
  tel => 'tel',
  url => 'url',
  email => 'email',
  password => 'password',
  datetime => 'datetime',
  date => 'date',
  month => 'month',
  week => 'week',
  time => 'time',
  'datetime-local' => 'datetime-local',
  number => 'number',
  range => 'range',
  color => 'color',
  checkbox => 'checkbox',
  radio => 'radio',
  file => 'file',
  submit => 'submit',
  image => 'image',
  reset => 'reset',
  button => 'button',
  '#missing' => 'text',
};
_define_reflect_string default_value => 'value';

_define_reflect_string align => 'align';
_define_reflect_string usemap => 'usemap';

package Web::DOM::HTMLButtonElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX form formaction menu and more...

_define_reflect_boolean autofocus => 'autofocus';
_define_reflect_boolean disabled => 'disabled';
_define_reflect_enumerated formenctype => 'formenctype', {
  'application/x-www-form-urlencoded' => 'application/x-www-form-urlencoded',
  'multipart/form-data' => 'multipart/form-data',
  'text/plain' => 'text/plain',
  '#invalid' => 'application/x-www-form-urlencoded',
  # #missing
};
_define_reflect_enumerated formmethod => 'formmethod', {
  get => 'get',
  post => 'post',
  dialog => 'dialog',
  '#invalid' => 'get',
  # #missing
};
_define_reflect_boolean formnovalidate => 'formnovalidate';
_define_reflect_string formtarget => 'formtarget';
_define_reflect_string name => 'name';
_define_reflect_enumerated type => 'type', {
  submit => 'submit',
  reset => 'reset',
  button => 'button',
  menu => 'menu',
  '#missing' => 'submit',
};
_define_reflect_string value => 'value';

package Web::DOM::HTMLSelectElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX form

_define_reflect_boolean autofocus => 'autofocus';
_define_reflect_boolean disabled => 'disabled';
_define_reflect_boolean multiple => 'multiple';
_define_reflect_string name => 'name';
_define_reflect_boolean required => 'required';
_define_reflect_unsigned_long size => 'size', sub { 0 };

sub type ($) {
  if ($_[0]->has_attribute ('multiple')) {
    return 'select-multiple';
  } else {
    return 'select-one';
  }
} # type

package Web::DOM::HTMLDataListElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX 

package Web::DOM::HTMLOptGroupElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_boolean disabled => 'disabled';
_define_reflect_string label => 'label';

package Web::DOM::HTMLOptionElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX constructor form label selected value text index

_define_reflect_boolean disabled => 'disabled';
_define_reflect_boolean default_selected => 'selected';

package Web::DOM::HTMLTextAreaElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX autocomplete form

_define_reflect_boolean autofocus => 'autofocus';
_define_reflect_unsigned_long_positive cols => 'cols', sub { 20 };
_define_reflect_string dirname => 'dirname';
_define_reflect_boolean disabled => 'disabled';
_define_reflect_enumerated inputmode => 'inputmode', {
  verbatim => 'verbatim',
  latin => 'latin',
  'latin-name' => 'latin-name',
  'latin-prose' => 'latin-prose',
  'full-width-latin' => 'full-width-latin',
  kana => 'kana',
  katakana => 'katakana',
  numeric => 'numeric',
  tel => 'tel',
  email => 'email',
  url => 'url',
  # #missing => default
};
_define_reflect_long_nn maxlength => 'maxlength', sub { -1 };
_define_reflect_string name => 'name';
_define_reflect_string placeholder => 'placeholder';
_define_reflect_boolean readonly => 'readonly';
_define_reflect_boolean required => 'required';
_define_reflect_unsigned_long_positive rows => 'rows', sub { 2 };
_define_reflect_enumerated wrap => 'wrap', {
  soft => 'soft',
  hard => 'hard',
  '#missing' => 'soft',
};

sub type ($) { 'textarea' }

sub default_value ($;$) {
  if (@_ > 1) {
    $_[0]->text_content ($_[1]);
  }
  return $_[0]->text_content;
} # default_value

# XXX value text_length validation labels selection

package Web::DOM::HTMLKeygenElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX form keytype

_define_reflect_boolean autofocus => 'autofocus';
_define_reflect_string challenge => 'challenge';
_define_reflect_boolean disabled => 'disabled';
_define_reflect_string name => 'name';

sub type ($) { 'keygen' }

# XXX validity labels

package Web::DOM::HTMLOutputElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX form html_for

_define_reflect_string name => 'name';

sub type ($) { 'output' }

# XXX default_value value validity labels

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
use Web::DOM::Element;

_define_reflect_boolean open => 'open';

package Web::DOM::HTMLMenuElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string type => 'type';
_define_reflect_string label => 'label';

_define_reflect_boolean compact => 'compact';

package Web::DOM::HTMLMenuItemElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX icon command

_define_reflect_enumerated type => 'type', {
  'command' => 'command',
  'checkbox' => 'checkbox',
  'radio' => 'radio',
  '#missing' => 'command',
};
_define_reflect_string label => 'label';
_define_reflect_string radiogroup => 'radiogroup';
_define_reflect_boolean disabled => 'disabled';
_define_reflect_boolean checked => 'checked';
_define_reflect_boolean default => 'default';

package Web::DOM::HTMLDialogElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_boolean open => 'open';

# XXX return_value show* close

package Web::DOM::HTMLAppletElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX codebase object

_define_reflect_string align => 'align';
_define_reflect_string alt => 'alt';
_define_reflect_string archive => 'archive';
_define_reflect_string code => 'code';
_define_reflect_string height => 'height';
_define_reflect_string name => 'name';
_define_reflect_string width => 'width';
_define_reflect_unsigned_long hspace => 'hspace', sub { 0 };
_define_reflect_unsigned_long vspace => 'vspace', sub { 0 };

package Web::DOM::HTMLMarqueeElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_enumerated behavior => 'behavior', {
  'scroll' => 'scroll',
  'slide' => 'slide',
  'alternate' => 'alternate',
  '#missing' => 'scroll',
};
_define_reflect_string bgcolor => 'bgcolor';
_define_reflect_enumerated direction => 'direction', {
  'left' => 'left',
  'right' => 'right',
  'up' => 'up',
  'down' => 'down',
  '#missing' => 'left',
};
_define_reflect_string height => 'height';
_define_reflect_unsigned_long hspace => 'hspace', sub { 0 };
_define_reflect_unsigned_long scrollamount => 'scrollamount', sub { 6 };
_define_reflect_unsigned_long scrolldelay => 'scrolldelay', sub { 85 };
_define_reflect_unsigned_long vspace => 'vspace', sub { 0 };
_define_reflect_string width => 'width';
_define_reflect_boolean truespeed => 'truespeed';

# XXX loop on* start stop

package Web::DOM::HTMLFrameSetElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
# XXX WindowEventHandlers
use Web::DOM::Element;

_define_reflect_string cols => 'cols';
_define_reflect_string rows => 'rows';

package Web::DOM::HTMLFrameElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

# XXX src longdesc content*

_define_reflect_string name => 'name';
_define_reflect_string scrolling => 'scrolling';
_define_reflect_string frameborder => 'frameborder';
_define_reflect_boolean noresize => 'noresize';
_define_reflect_string_undef marginheight => 'marginheight';
_define_reflect_string_undef marginwidth => 'marginwidth';

package Web::DOM::HTMLBaseFontElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string color => 'color';
_define_reflect_string face => 'face';
_define_reflect_long size => 'size', sub { 0 };

package Web::DOM::HTMLDirectoryElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_boolean compact => 'compact';

package Web::DOM::HTMLFontElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
use Web::DOM::Element;

_define_reflect_string color => 'color';
_define_reflect_string face => 'face';
_define_reflect_string size => 'size';

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