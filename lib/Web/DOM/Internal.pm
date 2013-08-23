package Web::DOM::Internal;
use strict;
use warnings;
no warnings 'utf8';
use Carp;

## Web::DOM internal data structure and core utilities

our @EXPORT;

## "Interned" string
my $Text = {};
sub text ($$) {
  return defined $_[1] ? $Text->{$_[1]} ||= \(''.$_[1]) : undef;
} # text

## Namespace URLs
push @EXPORT, qw(HTML_NS SVG_NS MML_NS XML_NS XMLNS_NS ATOM_NS ATOM_THREAD_NS);
sub HTML_NS () { q<http://www.w3.org/1999/xhtml> }
sub SVG_NS () { q<http://www.w3.org/2000/svg> }
sub MML_NS () { q<http://www.w3.org/1998/Math/MathML> }
sub XML_NS () { q<http://www.w3.org/XML/1998/namespace> }
sub XMLNS_NS () { q<http://www.w3.org/2000/xmlns/> }
sub ATOM_NS () { q<http://www.w3.org/2005/Atom> }
sub ATOM_THREAD_NS () { q<http://purl.org/syndication/thread/1.0> }

sub import ($;@) {
  my $from_class = shift;
  my ($to_class, $file, $line) = caller;
  no strict 'refs';
  for (@_ ? @_ : @{$from_class . '::EXPORT'}) {
    my $code = $from_class->can ($_)
        or croak qq{"$_" is not exported by the $from_class module at $file line $line};
    *{$to_class . '::' . $_} = $code;
  }
} # import

push @EXPORT, qw(_resolve_url);
sub _resolve_url ($$) {
  require Web::URL::Canonicalize;
  return Web::URL::Canonicalize::url_to_canon_url ($_[0], $_[1]);
} # _resolve_url

## Internal data structure for DOM tree.
##
## This module is for internal use only.  Applications should not use
## this module directly.
##
## This module has no test by itself.  Tests for Node and its
## subclasses covers this module.

package Web::DOM::Internal::Objects;
use Scalar::Util qw(weaken);
push our @CARP_NOT, qw(Web::DOM::Exception Web::DOM::StringArray);

## Nodes of a DOM document share an object store, which is represented
## by this class.  Each node in the store is distinguished by the node
## ID.  Node ID #0 is always the |Document| node for the tree.
##
## Nodes of the document form several trees, which are identified by
## tree IDs.  This ID is used for, e.g., garbage collection.
##
## Objects belongging to the store is not limited to nodes.  Non-node
## objects controlled by the store include |HTMLCollection| objects
## returned by the |get_elements_by_tag_name| method and DOM range
## objects.

sub new ($) {
  return bless {
    ## Nodes
    next_node_id => 0,
    # data nodes rc

    ## Trees
    next_tree_id => 0,
    # tree_id

    ## Lists
    # cols tokens strmap iterators

    ## CSS
    # source_style media

    ## Other objects
    # impl
    # config config_obj config_hashref config_names
  }, $_[0];
} # new

## Various characteristics of the node are put into the "data" hash
## reference for the node.
##
## For the purpose of the internal, two separete types of concepts are
## treated as "nodes": DOM |Node| and CSSOM |StyleSheet| or |CSSRule|.
## The "data" hash reference for the DOM |Node| contains |node_type|
## value representing the node type.  The "data" hash reference for
## the CSSOM object contains |rule_type| value representing the rule
## type (or the "style sheet" type).
##
## A tree can contain both DOM |Node| and CSSOM objects.  For example,
## an HTML |style| element |Node| might have a reference to a CSSOM
## |StyleSheet| in the "sheet" field (corresponding to the |sheet|
## attribute), which is considered as a parent-child link similar to
## the |childNodes| attribute of DOM |Node|s, and the |StyleSheet|
## would have a reference to the |Node| in the "owner" field
## (corresponding to the |ownerNode| attribute), which isconsidered as
## a child-parent link similar to the |parentNode| attribute of DOM
## |Node|s.

sub add_data ($$) {
  my $self = shift;
  my $id = $self->{next_node_id}++;
  $self->{data}->[$id] = $_[0];
  $self->{tree_id}->[$id] = $self->{next_tree_id}++;
  ## The |import_parsed_ss| method can also add |data| to the
  ## internal.
  return $id;
} # add_data

## The |Node| / |StyleSheet| / |CSSRule| object exposed to the
## application is a blessed reference to the array reference, which
## consists of following members:
##
##   0 - The object store object
##   1 - The node ID
##   2 - The node data
##
## Its the reference to the reference, not just the reference, to
## allow overloading of |@{}| and |%{}| in some kinds of nodes.

## Node data
##
## |Node|
##   all_declarations_processed     boolean   [all declarations processed]
##   allowed_tokens                 [string]  Allowed tokens
##   attributes                     [attr]    Attributes by index
##   attribute_definitions          {node_id} Attribute definitions
##   attribute_type                 integer   [attribute type]
##   attrs                          {{attr}}  Attributes by name
##   child_nodes                    [node_id] Child nodes
##   class_list                     [string]  Classes
##   compat_mode                    string    Quirksness
##   content_type                   string    MIME type
##   data                           \string   Data
##   declared_type                  integer   Declared type
##   default_type                   integer   Default type
##   element_types                  {node_id} Element types
##   encoding                       string    Character encoding
##   event_listeners                {}[]      Event listener callbacks
##   general_entities               {node_id} General entities
##   is_html                        boolean   An HTML document?
##   is_srcdoc                      boolean   An iframe srcdoc document?
##   is_XMLDocument                 boolean   An XMLDocument?
##   local_name                     \string   Local name
##   manakai_charset                string    Content-Type charset=""
##   manakai_entity_base_uri        \string   Entity base URL
##   manakai_entity_uri             \string   Entity URL
##   manakai_has_bom                boolean   Has BOM?
##   name                           \string   Name
##   namespace_uri                  \string   Namespace URL
##   node_name                      \string   Node name
##   node_type                      integer   Node type
##   node_value                     string    Node value
##   no_strict_error_checking       boolean   !Strict error checking flag
##   notations                      {node_id} Notations
##   notation_name                  string    Notation name
##   owner                          node_id   Owner
##   parent_node                    node_id   Parent node
##   prefix                         \string   Namespace prefix
##   public_id                      \string   Public ID
##   return_value                   string    Return value
##   serialize_as_cdata             boolean   CDATA section?
##   sheet                          node_id   Style sheet
##   system_id                      \string   System ID
##   target                         \string   Target
##   url                            string    Document URL
##   user_data                      {object}  User data
##   value                          string    Value
##   xml_encoding                   string    XML encoding=""
##   xml_standalone                 boolean   XML standalone=""
##   xml_version                    string    XML version
##
## |StyleSheet| / |CSSRule|
##   rule_type, rule_ids, parent_id, selectors,
##   prop_keys, prop_values, prop_importants, encoding,
##   href, mqs, prefix, nsurl       - See |Web::CSS::Parser|
##   owner                          node_id   Owner |Node| or |@import|
##   owner_sheet                    node_id   Owner style sheet
##   sheet                          node_id   Style sheet (for |@import|)

my $NodeClassByNodeType = {
  2 => 'Web::DOM::Attr',
  3 => 'Web::DOM::Text',
  6 => 'Web::DOM::Entity',
  7 => 'Web::DOM::ProcessingInstruction',
  8 => 'Web::DOM::Comment',
  10 => 'Web::DOM::DocumentType',
  11 => 'Web::DOM::DocumentFragment',
  12 => 'Web::DOM::Notation',
  81001 => 'Web::DOM::ElementTypeDefinition',
  81002 => 'Web::DOM::AttributeDefinition',
};

my $ElementClass = {};
my $ClassToModule = {};

## Mapping of element names from element interfaces' classes
for (
  ['*' => 'HTMLUnknownElement'],
  ['html' => 'HTMLHtmlElement'],
  ['head' => 'HTMLHeadElement'],
  ['title' => 'HTMLTitleElement'],
  ['base' => 'HTMLBaseElement'],
  ['link' => 'HTMLLinkElement'],
  ['meta' => 'HTMLMetaElement'],
  ['style' => 'HTMLStyleElement'],
  ['script' => 'HTMLScriptElement'],
  ['noscript' => 'HTMLElement'],
  ['body' => 'HTMLBodyElement'],
  ['article' => 'HTMLElement'],
  ['section' => 'HTMLElement'],
  ['nav' => 'HTMLElement'],
  ['aside' => 'HTMLElement'],
  ['h1' => 'HTMLHeadingElement'],
  ['h2' => 'HTMLHeadingElement'],
  ['h3' => 'HTMLHeadingElement'],
  ['h4' => 'HTMLHeadingElement'],
  ['h5' => 'HTMLHeadingElement'],
  ['h6' => 'HTMLHeadingElement'],
  ['hgroup' => 'HTMLElement'],
  ['header' => 'HTMLElement'],
  ['footer' => 'HTMLElement'],
  ['address' => 'HTMLElement'],
  ['p' => 'HTMLParagraphElement'],
  ['hr' => 'HTMLHRElement'],
  ['pre' => 'HTMLPreElement'],
  ['blockquote' => 'HTMLQuoteElement'],
  ['ol' => 'HTMLOListElement'],
  ['ul' => 'HTMLUListElement'],
  ['li' => 'HTMLLIElement'],
  ['dl' => 'HTMLDListElement'],
  ['dt' => 'HTMLElement'],
  ['dd' => 'HTMLElement'],
  ['figure' => 'HTMLElement'],
  ['figcaption' => 'HTMLElement'],
  ['div' => 'HTMLDivElement'],
  ['a' => 'HTMLAnchorElement'],
  ['em' => 'HTMLElement'],
  ['strong' => 'HTMLElement'],
  ['small' => 'HTMLElement'],
  ['s' => 'HTMLElement'],
  ['cite' => 'HTMLElement'],
  ['q' => 'HTMLQuoteElement'],
  ['dfn' => 'HTMLElement'],
  ['abbr' => 'HTMLElement'],
  ['data' => 'HTMLDataElement'],
  ['time' => 'HTMLTimeElement'],
  ['code' => 'HTMLElement'],
  ['var' => 'HTMLElement'],
  ['samp' => 'HTMLElement'],
  ['kbd' => 'HTMLElement'],
  ['sub' => 'HTMLElement'],
  ['sup' => 'HTMLElement'],
  ['i' => 'HTMLElement'],
  ['b' => 'HTMLElement'],
  ['u' => 'HTMLElement'],
  ['mark' => 'HTMLElement'],
  ['ruby' => 'HTMLElement'],
  ['rt' => 'HTMLElement'],
  ['rp' => 'HTMLElement'],
  ['bdi' => 'HTMLElement'],
  ['bdo' => 'HTMLElement'],
  ['span' => 'HTMLSpanElement'],
  ['br' => 'HTMLBRElement'],
  ['wbr' => 'HTMLElement'],
  ['ins' => 'HTMLModElement'],
  ['del' => 'HTMLModElement'],
  ['img' => 'HTMLImageElement'],
  ['iframe' => 'HTMLIFrameElement'],
  ['embed' => 'HTMLEmbedElement'],
  ['object' => 'HTMLObjectElement'],
  ['param' => 'HTMLParamElement'],
  ['video' => 'HTMLVideoElement'],
  ['audio' => 'HTMLAudioElement'],
  ['source' => 'HTMLSourceElement'],
  ['track' => 'HTMLTrackElement'],
  ['canvas' => 'HTMLCanvasElement'],
  ['map' => 'HTMLMapElement'],
  ['area' => 'HTMLAreaElement'],
  ['table' => 'HTMLTableElement'],
  ['caption' => 'HTMLTableCaptionElement'],
  ['colgroup' => 'HTMLTableColElement'],
  ['col' => 'HTMLTableColElement'],
  ['tbody' => 'HTMLTableSectionElement'],
  ['thead' => 'HTMLTableSectionElement'],
  ['tfoot' => 'HTMLTableSectionElement'],
  ['tr' => 'HTMLTableRowElement'],
  ['td' => 'HTMLTableDataCellElement'],
  ['th' => 'HTMLTableHeaderCellElement'],
  ['form' => 'HTMLFormElement'],
  ['fieldset' => 'HTMLFieldSetElement'],
  ['legend' => 'HTMLLegendElement'],
  ['label' => 'HTMLLabelElement'],
  ['input' => 'HTMLInputElement'],
  ['button' => 'HTMLButtonElement'],
  ['select' => 'HTMLSelectElement'],
  ['datalist' => 'HTMLDataListElement'],
  ['optgroup' => 'HTMLOptGroupElement'],
  ['option' => 'HTMLOptionElement'],
  ['textarea' => 'HTMLTextAreaElement'],
  ['keygen' => 'HTMLKeygenElement'],
  ['output' => 'HTMLOutputElement'],
  ['progress' => 'HTMLProgressElement'],
  ['meter' => 'HTMLMeterElement'],
  ['details' => 'HTMLDetailsElement'],
  ['summary' => 'HTMLElement'],
  ['menu' => 'HTMLMenuElement'],
  ['menuitem' => 'HTMLMenuItemElement'],
  ['dialog' => 'HTMLDialogElement'],
  ['applet' => 'HTMLAppletElement'],
  ['marquee' => 'HTMLMarqueeElement'],
  ['frameset' => 'HTMLFrameSetElement'],
  ['frame' => 'HTMLFrameElement'],
  ['basefont' => 'HTMLElement'],
  ['dir' => 'HTMLDirectoryElement'],
  ['font' => 'HTMLFontElement'],
  ['listing' => 'HTMLElement'],
  ['plaintext' => 'HTMLElement'],
  ['xmp' => 'HTMLElement'],
  ['acronym' => 'HTMLElement'],
  ['noframes' => 'HTMLElement'],
  ['noembed' => 'HTMLElement'],
  ['strike' => 'HTMLElement'],
  ['big' => 'HTMLElement'],
  ['blink' => 'HTMLElement'],
  ['center' => 'HTMLElement'],
  ['nobr' => 'HTMLElement'],
  ['tt' => 'HTMLElement'],
  ['template' => 'HTMLTemplateElement'],
) {
  $ElementClass->{Web::DOM::Internal::HTML_NS}->{$_->[0]}
      = "Web::DOM::$_->[1]";
  $ClassToModule->{"Web::DOM::$_->[1]"} = "Web::DOM::HTMLElement";
}
for (
  ['*', 'AtomElement'],
  ['id', 'AtomIdElement'],
  ['icon', 'AtomIconElement'],
  ['name', 'AtomNameElement'],
  ['uri', 'AtomUriElement'],
  ['email', 'AtomEmailElement'],
  ['logo', 'AtomLogoElement'],
  ['rights', 'AtomRightsElement'],
  ['subtitle', 'AtomSubtitleElement'],
  ['summary', 'AtomSummaryElement'],
  ['title', 'AtomTitleElement'],
  ['author', 'AtomAuthorElement'],
  ['contributor', 'AtomContributorElement'],
  ['published', 'AtomPublishedElement'],
  ['updated', 'AtomUpdatedElement'],
  ['feed', 'AtomFeedElement'],
  ['entry', 'AtomEntryElement'],
  ['source', 'AtomSourceElement'],
  ['content', 'AtomContentElement'],
  ['category', 'AtomCategoryElement'],
  ['generator', 'AtomGeneratorElement'],
  ['link', 'AtomLinkElement'],
) {
  $ElementClass->{Web::DOM::Internal::ATOM_NS}->{$_->[0]}
      = "Web::DOM::$_->[1]";
  $ClassToModule->{"Web::DOM::$_->[1]"} = "Web::DOM::AtomElement";
}
for (
  ['*', 'AtomElement'],
  ['in-reply-to', 'AtomThreadInReplyToElement'],
  ['total', 'AtomThreadTotalElement'],
) {
  $ElementClass->{Web::DOM::Internal::ATOM_THREAD_NS}->{$_->[0]}
      = "Web::DOM::$_->[1]";
  $ClassToModule->{"Web::DOM::$_->[1]"} = "Web::DOM::AtomElement";
}

my $RuleClassByRuleType = {
  #sheet => 'Web::DOM::CSSStyleSheet',
  style => 'Web::DOM::CSSStyleRule',
  charset => 'Web::DOM::CSSCharsetRule',
  import => 'Web::DOM::CSSImportRule',
  media => 'Web::DOM::CSSMediaRule',
  font_face => 'Web::DOM::CSSFontFaceRule',
  page => 'Web::DOM::CSSPageRule',
  namespace => 'Web::DOM::CSSNamespaceRule',
};

my $ModuleLoaded = {};

sub node ($$) {
  my ($self, $id) = @_;
  return $self->{nodes}->[$id] if defined $self->{nodes}->[$id];

  my $data = $self->{data}->[$id];
  my $class;
  my $module;
  if (defined (my $nt = $data->{node_type})) {
    if ($nt == 1) {
      my $ns = $data->{namespace_uri} || \'';
      $class = $ElementClass->{$$ns}->{${$data->{local_name}}} ||
          $ElementClass->{$$ns}->{'*'} ||
          'Web::DOM::Element';
    } elsif ($nt == 9) {
      $class = $data->{is_XMLDocument}
          ? 'Web::DOM::XMLDocument' : 'Web::DOM::Document';
    } else {
      $class = $NodeClassByNodeType->{$nt};
    }
    $module = $ClassToModule->{$class} || $class;
  } else {
    if ($data->{rule_type} eq 'sheet') {
      $class = $module = 'Web::DOM::CSSStyleSheet';
    } else {
      $class = $RuleClassByRuleType->{$data->{rule_type}} ||
          'Web::DOM::CSSUnknownRule';
      $module = 'Web::DOM::CSSRule';
    }
  }
  if (not $ModuleLoaded->{$module}++) {
    eval qq{ require $module } or die $@;
  }
  my $node = bless \[$self, $id, $data], $class;
  weaken ($self->{nodes}->[$id] = $node);
  return $node;
} # node

## Live collection data structure
##
##   0 - The root node
##   1 - Filter
##   2 - List of the nodes in the collection
##   3 - Collection keys
##   4 - Hash reference for %{} operation
##
## $self->{cols}->[$root_node_id]->
## 
##   - {anchors}                  - $doc->anchors
##   - {attributes}               - $el->attributes
##   - {attribute_definitions}    - $et->attribute_definitions
##   - {author_elements}          - $el->author_elements
##   - {category_elements}        - $el->category_elements
##   - {cells}                    - $el->cells
##   - {child_nodes}              - $node->child_nodes
##   - {children}                 - $node->children
##   - {contributor_elements}     - $el->contributor_elements
##   - {css_rules}                - $css->css_rules
##   - {element_types}            - $dt->element_types
##   - {embeds}                   - $doc->embeds
##   - {entry_elements}           - $el->entry_elements
##   - {forms}                    - $doc->forms
##   - {general_entities}         - $dt->general_entities
##   - {images}                   - $doc->images
##   - {iterator}                 - $node->_iterator (Web::DOM::NodeIterator)
##   - {link_elements}            - $el->link_elements
##   - {links}                    - $doc->links
##   - {notations}                - $dt->notations
##   - {options}                  - $el->options
##   - {rights_elements}          - $el->rights_elements
##   - {rows}                     - $el->rows
##   - {scripts}                  - $doc->scripts
##   - {tbodies}                  - $table->tbodies
##   - {"by_class_name$;$cls"}    - $node->get_elements_by_class_name ($cls)
##   - {"by_tag_name$;$ln"}       - $node->get_elements_by_tag_name ($ln)
##   - {"by_tag_name_ns$;$n$;$l"} - $node->get_elements_by_tag_name_ns ($n, $l)
##   - {"by_name$;$name"}         - $doc->get_elements_by_name ($name)
##   - {"all$;$name$;..."}        - $doc->all->{$name}->...

my $CollectionClass = {
  child_nodes => 'Web::DOM::NodeList',
  attributes => 'Web::DOM::NamedNodeMap',
  attribute_definitions => 'Web::DOM::NamedNodeMap',
  element_types => 'Web::DOM::NamedNodeMap',
  general_entities => 'Web::DOM::NamedNodeMap',
  notations => 'Web::DOM::NamedNodeMap',
  by_name => 'Web::DOM::NodeList',
  all => 'Web::DOM::HTMLAllCollection',
  css_rules => 'Web::DOM::CSSRuleList',
}; # $CollectionClass

sub collection ($$$$) {
  my ($self, $keys, $root_node, $filter) = @_;
  my $key = ref $keys ? (join $;, map {
    defined $_ ? do {
      s/($;|\x00)/\x00$1/g;
      $_;
    } : '';
  } @$keys) : $keys;
  my $id = $$root_node->[1];
  return $self->{cols}->[$id]->{$key}
      if defined $self->{cols}->[$id]->{$key};
  my $class = $CollectionClass->{ref $keys ? $keys->[0] : $key}
      || 'Web::DOM::HTMLCollection';
  if (not $ModuleLoaded->{$class}++) {
    eval qq{ require $class } or die $@;
  }
  my $nl = bless \[$root_node, $filter, undef, $keys], $class;
  weaken ($self->{cols}->[$id]->{$key} = $nl);
  return $nl;
} # collection

sub collection_by_el ($$$$$) {
  my ($self, $node, $key, $ns, $ln) = @_;
  return $self->collection ($key, $node, sub {
    my $node = $_[0];
    my $data = $$node->[0]->{data};
    my @node_id = @{$data->[$$node->[1]]->{child_nodes} or []};
    my @id;
    while (@node_id) {
      my $id = shift @node_id;
      next unless $data->[$id]->{node_type} == 1; # ELEMENT_NODE
      unshift @node_id, @{$data->[$id]->{child_nodes} or []};
      next unless ${$data->[$id]->{local_name}} eq $ln;
      next unless ${$data->[$id]->{namespace_uri} || \''} eq $ns;
      push @id, $id;
    }
    return @id;
  });
} # collection_by_el

## NodeIterators
##
## $self->{iterators}->[$node_id]->[]
##
##   - {root}                          - Root node
##   - {reference_node}                - Reference node
##   - {pointer_before_reference_node} - Boolean
##   - {what_to_show}                  - Bit vector
##   - {filter}                        - Code reference
##   - {collection}                    = Iterator collection
sub iterator ($$$$) {
  require Web::DOM::NodeIterator;
  my $it = bless {
    root => $_[1],
    reference_node => $_[1],
    pointer_before_reference_node => 1,
    what_to_show => $_[2],
    filter => $_[3],
    collection => $_[1]->_iterator,
  }, 'Web::DOM::NodeIterator';
  my $list = $_[0]->{iterators}->[${$_[1]}->[1]] ||= [];
  weaken ($list->[@$list] = $it);
  return $it;
} # iterator

sub destroy_iterator ($$) {
  my $root = $_[1]->{root};
  my $list = $_[0]->{iterators}->[$$root->[1]] || [];
  my $found;
  my $found_other;
  for (0..$#$list) {
    next unless $list->[$_];
    if ($list->[$_] eq $_[1]) {
      delete $list->[$_];
      $found = 1;
      last if $found_other;
    } else {
      $found_other = 1;
      last if $found;
    }
  }
  unless ($found_other) {
    delete $_[0]->{cols}->[$$root->[1]]->{iterator};
  }
} # destroy_iterator

## Live token data structure
##
##   \ DOMStringArray
##
## $self->{tokens}->[$node_id]->
## 
##   - {class_list}           - $el->class_list
##   - {rel_list}             - $el->rel_list
##   - {dropzone}             - $el->dropzone
##   - {headers}              - $el->headers
##   - {html_for}             - $el->html_for
##   - {itemprop}             - $el->itemprop
##   - {itemref}              - $el->itemref
##   - {itemtype}             - $el->itemtype
##   - {sandbox}              - $el->sandbox
##   - {sizes}                - $el->sizes
##
## $element->class_name ------------------------------------------->+
## $$element->[2]->{attr...}... = class attribute <--------------<--+
##   |                                                              |
##   v $element->_attribute_is                                      |
## $$element->[2]->{class_list} = classes arrayref                  |
## $$element->[0]->{tokenlists}->{class_list}->[$id] =weak= bless [ |
##   ::DOMStringArray::                                             |
##   0 - classes arrayref                                           |
##   1 - update steps --------------------------------------------->+
## ], DOMTokenList

our $TokenListClass = {
  class_list => 'Web::DOM::TokenList',
  rel_list => 'Web::DOM::TokenList',
};

sub tokens ($$$$$) {
  my ($self, $key, $node, $updater, $attr_name) = @_;
  my $id = $$node->[1];
  return $self->{tokens}->[$id]->{$key}
      if $self->{tokens}->[$id]->{$key};

  my $uniquer = sub {
    my %found;
    @{$$node->[2]->{$key}} = grep {
      length $_ and not $found{$_}++;
    } @{$$node->[2]->{$key}};
  };
  my %found;
  $$node->[2]->{$key} ||= [
    grep { length $_ and not $found{$_}++ }
    split /[\x09\x0A\x0C\x0D\x20]+/,
    do { my $v = $node->get_attribute_ns (undef, $attr_name);
         defined $v ? $v : '' }
  ];

  require Web::DOM::StringArray;
  require Web::DOM::Exception;
  tie my @array, 'Web::DOM::StringArray', $$node->[2]->{$key}, sub {
    $uniquer->();
    $updater->();
  }, sub {
    if ($_[0] eq '') {
      _throw Web::DOM::Exception 'SyntaxError',
          'The token cannot be the empty string';
    } elsif ($_[0] =~ /[\x09\x0A\x0C\x0D\x20]/) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The token cannot contain any ASCII white space character';
    }
    return $_[0];
  };

  my $class = $TokenListClass->{$key} || 'Web::DOM::SettableTokenList';
  if (not $ModuleLoaded->{$class}++) {
    eval qq{ require $class } or die $@;
  }
  my $nl = bless \@array, $class;
  weaken ($self->{tokens}->[$id]->{$key} = $nl);

  return $nl;
} # tokens

sub children_changed ($$$) {
  my $cols = $_[0]->{cols};
  my @key = qw(child_nodes children attributes element_types general_entities
               notations attribute_definitions iterator css_rules);
  if ($_[2] == 1 or $_[2] == 2) { # old child is ELEMENT_NODE or ATTRIBUTE_NODE
    @key = ();
  }

  my @id = ($_[1]);
  while (@id) {
    my $id = shift @id;
    next unless defined $id;
    for my $key (@key ? @key : keys %{$cols->[$id] or {}}) {
      my $col = $cols->[$id]->{$key};
      next unless defined $col; # HTMLAllCollection is false!
      my $old = $key eq 'iterator' ? [@$col] : undef;

      delete $$col->[2];
      delete $$col->[4];

      if ($key eq 'iterator') {
        my $new = [@$col];
        my $new_found = {};
        $new_found->{$$_->[1]} = 1 for @$new;
        my $not_found = {};
        for (@$old) {
          next if $new_found->{$$_->[1]};
          $not_found->{$$_->[1]} = 1;
        }
        if (keys %$not_found) {
          for (@{$_[0]->{iterators}->[$_[1]] || []}) {
            $_->_nodes_removed ($old, $not_found);
          }
        }
      } # iterator
    }
    push @id, $_[0]->{data}->[$id]->{parent_node};
    @key = ('iterator') if @key;
  }
} # children_changed

## DOMStringMap
sub strmap ($$) {
  my ($self, $el) = @_;
  return $self->{strmap}->[$$el->[1]] if defined $self->{strmap}->[$$el->[1]];
  require Web::DOM::StringMap;
  my $map = bless \[], 'Web::DOM::StringMap';
  tie my %hash, 'Web::DOM::StringMap::Hash', $el;
  $$map->[0] = \%hash;
  weaken ($self->{strmap}->[$$el->[1]] = $map);
  return $map;
} # strmap

## DOMImplementation
sub impl ($) {
  my $self = shift;
  return $self->{impl} || do {
    require Web::DOM::Implementation;
    my $impl = bless \[$self], 'Web::DOM::Implementation';
    weaken ($self->{impl} = $impl);
    $impl;
  };
} # impl

## DOMConfiguration
sub config ($) {
  my $self = shift;
  return $self->{config_obj} || do {
    require Web::DOM::Configuration;
    my $config = bless \[$self], 'Web::DOM::Configuration';
    weaken ($self->{config_obj} = $config);
    $config;
  };
} # config

sub config_hashref ($) {
  my $self = shift;
  my $config = $self->config;
  return $$config->[1] ||= do {
    require Web::DOM::Configuration;
    tie my %config, 'Web::DOM::Configuration::Hash', $self;
    \%config;
  };
} # config_hashref

sub import_parsed_ss ($$) {
  my ($self, $ss) = @_;
  ## $ss - Parsed style sheet data structure (See Web::CSS::Parser)
  ## (This method is destructive and some data in $ss is used as
  ## part of the internal.)

  my $id_delta = $self->{next_node_id};
  my $tree_id = $self->{next_tree_id}++;

  ## $ss->{rules}->[0] is always the style sheet construct
  for my $rule (@{$ss->{rules}}) {
    my $id = $id_delta + delete $rule->{id};
    $rule->{parent_id} += $id_delta if defined $rule->{parent_id};
    @{$rule->{rule_ids}} = map { $_ + $id_delta } @{$rule->{rule_ids}}
        if $rule->{rule_ids};
    $rule->{owner_sheet} = $id_delta + 0 if $id != $id_delta;
    $self->{data}->[$id] = $rule;
    $self->{tree_id}->[$id] = $tree_id;
  }

  ## $ss->{base_urlref} is ignored

  $self->{next_node_id} += @{$ss->{rules}};
  $self->{rc}->[$id_delta + 0] += @{$ss->{rules}} - 1; # |owner_sheet|

  return $id_delta + 0;

  ## This method is invoked by
  ## |Web::CSS::Parser::process_style_element|.
} # import_parsed_ss

sub source_style ($$$) {
  my ($self, $type, $obj) = @_;
  return $self->{source_style}->[$$obj->[1]] || do {
    require Web::DOM::CSSStyleDeclaration;
    ## $type = 'rule', $obj = CSSStyleRule - Declarations in the style rule
    my $style = bless \[$type, $obj], 'Web::DOM::CSSStyleDeclaration';
    weaken ($self->{source_style}->[$$obj->[1]] = $style);
    $style;
  };
} # source_style

sub media ($$) {
  my ($self, $obj) = @_;
  return $self->{media}->[$$obj->[1]] || do {
    require Web::DOM::MediaList;
    my $list = bless \[$obj], 'Web::DOM::MediaList';
    weaken ($self->{media}->[$$obj->[1]] = $list);
    $list;
  };
} # media

sub connect ($$$) {
  my ($self, $id => $parent_id) = @_;
  my @id = ($id);
  my $tree_id = $self->{tree_id}->[$parent_id];
  while (@id) {
    my $id = shift @id;
    $self->{tree_id}->[$id] = $tree_id;
    my $data = $self->{data}->[$id];
    push @id, grep { not ref $_ } @{$data->{attributes} or []};
    push @id,
        @{$data->{child_nodes} or []},
        @{$data->{rule_ids} or []},
        grep { defined $_ } 
        values %{$data->{element_types} or {}},
        values %{$data->{general_entities} or {}},
        values %{$data->{notations} or {}},
        values %{$data->{attribute_definitions} or {}},
        $data->{sheet};
  }
} # connect

sub disconnect ($$) {
  my ($self, $id) = @_;
  my @id = ($id);
  my $tree_id = $self->{next_tree_id}++;
  while (@id) {
    my $id = shift @id;
    $self->{tree_id}->[$id] = $tree_id;
    my $data = $self->{data}->[$id];
    push @id, grep { not ref $_ } @{$data->{attributes} or []};
    push @id,
        @{$data->{child_nodes} or []},
        @{$data->{rule_ids} or []},
        grep { defined $_ } 
        values %{$data->{element_types} or {}},
        values %{$data->{general_entities} or {}},
        values %{$data->{notations} or {}},
        values %{$data->{attribute_definitions} or {}},
        $data->{sheet};

    ## If the disconnected node is a CSS rule and contained in a style
    ## sheet, decrement the reference count for the sheet.  (The
    ## reference itself should be removed by the invokee after the
    ## invocation of this method.)
    if (defined $data->{owner_sheet}) {
      $self->{rc}->[$data->{owner_sheet}]--;
    }
  }
} # disconnect

## Move a node, with its descendants and their related objects, from
## the document to another (this) document.  Please note that this
## method is not enough for the "adopt" operation as defined in the
## DOM Standard; that operation requires more than this method does,
## including removal of the parent node of the node.  This method
## assumes that $node has no parent or owner.
sub adopt ($$) {
  my ($new_int, $node) = @_;
  my $old_int = $$node->[0];
  return if $old_int eq $new_int;

  my @old_id = ($$node->[1]);
  my $new_tree_id = $new_int->{next_tree_id}++;
  my %id_map;
  my @data;
  while (@old_id) {
    my $old_id = shift @old_id;
    my $new_id = $new_int->{next_node_id}++;
    $id_map{$old_id} = $new_id;

    my $data = $new_int->{data}->[$new_id]
        = delete $old_int->{data}->[$old_id];
    push @data, $data;

    delete $old_int->{tree_id}->[$old_id];
    $new_int->{tree_id}->[$new_id] = $new_tree_id;

    push @old_id, grep { not ref $_ } @{$data->{attributes} or []};
    push @old_id,
        @{$data->{child_nodes} or []},
        @{$data->{rule_ids} or []},
        grep { defined $_ } 
        values %{$data->{element_types} or {}},
        values %{$data->{general_entities} or {}},
        values %{$data->{notations} or {}},
        values %{$data->{attribute_definitions} or {}},
        $data->{sheet};

    if (my $node = delete $old_int->{nodes}->[$old_id]) {
      weaken ($new_int->{nodes}->[$new_id] = $node);
      $$node->[0] = $new_int;
      $$node->[1] = $new_id;
    }

    if (my $cols = delete $old_int->{cols}->[$old_id]) {
      $new_int->{cols}->[$new_id] = $cols;
      for (values %$cols) {
        delete $$_->[2] if defined $_;
        delete $$_->[4] if defined $_;
      }
    }

    if (my $its = delete $old_int->{iterators}->[$old_id]) {
      $new_int->{iterators}->[$new_id] = $its;
    }

    $new_int->{rc}->[$new_id] = delete $old_int->{rc}->[$old_id]
        if $old_int->{rc}->[$old_id];
  }
  
  for my $data (@data) {
    @{$data->{attributes}} = map {
      ref $_ ? $_ : $id_map{$_};
    } @{$data->{attributes}} if $data->{attributes};
    for (values %{$data->{attrs} or {}}) {
      for my $ln (keys %$_) {
        if (defined $_->{$ln} and not ref $_->{$ln}) {
          $_->{$ln} = $id_map{$_->{$ln}};
        }
      }
    }
    @{$data->{child_nodes}} = map { $id_map{$_} } @{$data->{child_nodes}}
        if $data->{child_nodes};
    @{$data->{rule_ids}} = map { $id_map{$_} } @{$data->{rule_ids}}
        if $data->{rule_ids};
    for my $key (qw(element_types general_entities notations
                    attribute_definitions)) {
      for (keys %{$data->{$key} or {}}) {
        if (defined $data->{$key}->{$_}) {
          $data->{$key}->{$_} = $id_map{$data->{$key}->{$_}};
        }
      }
    }
    for (qw(sheet
            parent_node owner
            owner_sheet)) {
      $data->{$_} = $id_map{$data->{$_}} if defined $data->{$_};
    }
  }
} # adopt

sub gc ($$) {
  return if @{$_[0]->{data} or []} > 100 and 0.95 > rand 1;
  my ($self, $id) = @_;

  my $osid = $self->{data}->[$id]->{owner_sheet};
  if (defined $osid) {
    ## |rc| is used to not free style sheet until all rules
    ## referencing it are freed.
    $self->{rc}->[$osid]--;
  }

  delete $self->{nodes}->[$id];
  my $tree_id = $self->{tree_id}->[$id];
  return if $tree_id == 0;
  my @id = grep { defined $self->{tree_id}->[$_] and 
                  $self->{tree_id}->[$_] == $tree_id } 0..$#{$self->{tree_id}};
  for (@id) {
    return if $self->{nodes}->[$_] or ($self->{rc}->[$_] or 0) > 0;
  }
  for (@id) {
    delete $self->{data}->[$_];
    delete $self->{tree_id}->[$_];
    delete $self->{rc}->[$_];
    delete $self->{cols}->[$_];
    delete $self->{iterators}->[$_];
  }
} # gc

sub DESTROY ($) {
  {
    local $@;
    eval { die };
    warn "Potential memory leak detected" if $@ =~ /during global destruction/;
  }
} # DESTROY

package Web::DOM::Internal::ReadOnlyHash;
use Carp;

sub TIEHASH ($$) {
  return bless $_[1], $_[0]
} # TIEHASH

sub FETCH ($$) {
  return $_[0]->{$_[1]}; # or undef
} # FETCH

sub STORE ($$$) {
  croak 'Modification of a read-only value attempted';
} # STORE

sub DELETE ($$) {
  croak 'Modification of a read-only value attempted';
} # DELETE

sub CLEAR ($) {
  croak 'Modification of a read-only value attempted';
} # CLEAR

sub EXISTS ($$) {
  return exists $_[0]->{$_[1]};
} # EXISTS

sub FIRSTKEY ($) {
  keys %{$_[0]};
  return each %{$_[0]}; # or undef
} # FIRSTKEY

sub NEXTKEY ($$) {
  return each %{$_[0]}; # or undef
} # NEXTKEY

sub SCALAR ($) {
  return scalar %{$_[0]};
} # SCALAR

sub DESTROY ($) {
  {
    local $@;
    eval { die };
    warn "Potential memory leak detected" if $@ =~ /during global destruction/;
  }
} # DESTROY

1;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
