package Web::DOM::Internal;
use strict;
use warnings;
no warnings 'utf8';
use Carp;

our @EXPORT;

my $Text = {};

sub text ($$) {
  return defined $_[1] ? $Text->{$_[1]} ||= \(''.$_[1]) : undef;
} # text

push @EXPORT, qw(HTML_NS SVG_NS XML_NS XMLNS_NS);
sub HTML_NS () { q<http://www.w3.org/1999/xhtml> }
sub SVG_NS () { q<http://www.w3.org/2000/svg> }
sub XML_NS () { q<http://www.w3.org/XML/1998/namespace> }
sub XMLNS_NS () { q<http://www.w3.org/2000/xmlns/> }

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

    ## Collections
    # cols

    ## Token lists
    # tokens

    ## Other objects
    # impl
    # config config_obj config_hashref config_names
  }, $_[0];
} # new

## Various characteristics of the node is put into the "data" hash
## reference for the node.

sub add_data ($$) {
  my $self = shift;
  my $id = $self->{next_node_id}++;
  $self->{data}->[$id] = $_[0];
  $self->{tree_id}->[$id] = $self->{next_tree_id}++;
  return $id;
} # add_data

## The |Node| object exposed to the application is a blessed reference
## to the array reference, which consists of following members:
##
##   0 - The object store object
##   1 - The node ID
##   2 - The node data
##
## Its the reference to the reference, not just the reference, to
## allow overloading of |@{}| and |%{}| in some kinds of nodes.

## Node data
##
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
##   general_entities               {node_id} General entities
##   is_html                        boolean   An HTML document?
##   is_srcdoc                      boolean   An iframe srcdoc document?
##   is_XMLDocument                 boolean   An XMLDocument?
##   local_name                     \string   Local name
##   manakai_base_uri               string    [base URI]
##   manakai_charset                string    Content-Type charset=""
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
##   system_id                      \string   System ID
##   target                         \string   Target
##   url                            string    Document URL
##   user_data                      {object}  User data
##   value                          string    Value
##   xml_encoding                   string    XML encoding=""
##   xml_standalone                 boolean   XML standalone=""
##   xml_version                    string    XML version

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
  ['basefont' => 'HTMLBaseFontElement'],
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

sub node ($$) {
  my ($self, $id) = @_;
  return $self->{nodes}->[$id] if $self->{nodes}->[$id];

  my $data = $self->{data}->[$id];
  my $class;
  my $nt = $data->{node_type};
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
  my $module = $ClassToModule->{$class} || $class;
  eval qq{ require $module } or die $@;
  my $node = bless \[$self, $id, $data], $class;
  weaken ($self->{nodes}->[$id] = $node);
  return $node;
} # node

## Live collection data structure
##
##   0 - The root node
##   1 - Filter
##   2 - List of the nodes in the collection
##   3 - Collection key
##   4 - Hash reference for %{} operation
##
## $self->{cols}->[$root_node_id]->
## 
##   - {child_nodes}              - $node->child_nodes
##   - {attributes}               - $node->attributes
##   - {attribute_definitions}    - $node->attribute_definitions
##   - {element_types}            - $node->element_types
##   - {general_entities}         - $node->general_entities
##   - {notations}                - $node->notations
##   - {children}                 - $node->children
##   - {images}                   - $node->images
##   - {embeds}                   - $node->embeds
##   - {forms}                    - $node->forms
##   - {scripts}                  - $node->scripts
##   - {links}                    - $node->links
##   - {anchors}                  - $node->anchors
##   - {tbodies}                  - $node->tbodies
##   - {rows}                     - $node->rows
##   - {cells}                    - $node->cells
##   - {options}                  - $node->options
##   - {"by_class_name$;$cls"}    - $node->get_elements_by_class_name ($cls)
##   - {"by_tag_name$;$ln"}       - $node->get_elements_by_tag_name ($ln)
##   - {"by_tag_name_ns$;$n$;$l"} - $node->get_elements_by_tag_name_ns ($n, $l)
##   - {"by_name$;$name"}         - $node->get_elements_by_name ($name)

my $CollectionClass = {
  child_nodes => 'Web::DOM::NodeList',
  attributes => 'Web::DOM::NamedNodeMap',
  attribute_definitions => 'Web::DOM::NamedNodeMap',
  element_types => 'Web::DOM::NamedNodeMap',
  general_entities => 'Web::DOM::NamedNodeMap',
  notations => 'Web::DOM::NamedNodeMap',
  by_name => 'Web::DOM::NodeList',
}; # $CollectionClass

sub collection ($$$$) {
  my ($self, $key, $root_node, $filter) = @_;
  my $id = $$root_node->[1];
  return $self->{cols}->[$id]->{$key}
      if $self->{cols}->[$id]->{$key};
  my $class = $CollectionClass->{[split /$;/, $key]->[0]}
      || 'Web::DOM::HTMLCollection';
  eval qq{ require $class } or die $@;
  my $nl = bless \[$root_node, $filter, undef, $key], $class;
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

## Live token data structure
##
##   \ DOMStringArray
##
## $self->{tokens}->[$node_id]->
## 
##   - {class_list}           - $el->class_list
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

our $TokenListClass = {};

sub tokens ($$$$) {
  my ($self, $key, $node, $updater) = @_;
  my $id = $$node->[1];
  return $self->{tokens}->[$id]->{$key}
      if $self->{tokens}->[$id]->{$key};

  require Web::DOM::StringArray;
  require Web::DOM::Exception;
  tie my @array, 'Web::DOM::StringArray', $$node->[2]->{$key} ||= [], $updater,
      sub {
        if ($_[0] eq '') {
          _throw Web::DOM::Exception 'SyntaxError',
              'The token cannot be the empty string';
        } elsif ($_[0] =~ /[\x09\x0A\x0C\x0D\x20]/) {
          _throw Web::DOM::Exception 'InvalidCharacterError',
              'The token cannot contain any ASCII white space character';
        }
        return $_[0];
      };

  my $class = $TokenListClass->{$key} || 'Web::DOM::TokenList';
  eval qq{ require $class } or die $@;
  my $nl = bless \@array, $class;
  weaken ($self->{tokens}->[$id]->{$key} = $nl);

  return $nl;
} # tokens

sub children_changed ($$$) {
  my $cols = $_[0]->{cols};
  for ($cols->[$_[1]]->{child_nodes},
       $cols->[$_[1]]->{children},
       $cols->[$_[1]]->{attributes},
       $cols->[$_[1]]->{element_types},
       $cols->[$_[1]]->{general_entities},
       $cols->[$_[1]]->{notations},
       $cols->[$_[1]]->{attribute_definitions}) {
    next unless $_;
    delete $$_->[2];
    delete $$_->[4];
  }

  if ($_[2] == 1 or $_[2] == 2) { # old child is ELEMENT_NODE or ATTRIBUTE_NODE
    my @id = ($_[1]);
    while (@id) {
      my $id = shift @id;
      next unless defined $id;
      for my $key (keys %{$cols->[$id] or {}}) {
        next unless $cols->[$id]->{$key};
        delete ${$cols->[$id]->{$key}}->[2];
        delete ${$cols->[$id]->{$key}}->[4];
      }
      push @id, $_[0]->{data}->[$id]->{parent_node};
    }
  }
} # children_changed

sub impl ($) {
  my $self = shift;
  return $self->{impl} || do {
    require Web::DOM::Implementation;
    my $impl = bless \[$self], 'Web::DOM::Implementation';
    weaken ($self->{impl} = $impl);
    $impl;
  };
} # impl

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

sub connect ($$$) {
  my ($self, $id => $parent_id) = @_;
  my @id = ($id);
  my $tree_id = $self->{tree_id}->[$parent_id];
  while (@id) {
    my $id = shift @id;
    $self->{tree_id}->[$id] = $tree_id;
    push @id, grep { not ref $_ } @{$self->{data}->[$id]->{attributes} or []};
    push @id,
        @{$self->{data}->[$id]->{child_nodes} or []},
        grep { defined $_ } 
        values %{$self->{data}->[$id]->{element_types} or {}},
        values %{$self->{data}->[$id]->{general_entities} or {}},
        values %{$self->{data}->[$id]->{notations} or {}},
        values %{$self->{data}->[$id]->{attribute_definitions} or {}};
  }
} # connect

sub disconnect ($$) {
  my ($self, $id) = @_;
  my @id = ($id);
  my $tree_id = $self->{next_tree_id}++;
  while (@id) {
    my $id = shift @id;
    $self->{tree_id}->[$id] = $tree_id;
    push @id, grep { not ref $_ } @{$self->{data}->[$id]->{attributes} or []};
    push @id,
        @{$self->{data}->[$id]->{child_nodes} or []},
        grep { defined $_ } 
        values %{$self->{data}->[$id]->{element_types} or {}},
        values %{$self->{data}->[$id]->{general_entities} or {}},
        values %{$self->{data}->[$id]->{notations} or {}},
        values %{$self->{data}->[$id]->{attribute_definitions} or {}};
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
        grep { defined $_ } 
        values %{$data->{element_types} or {}},
        values %{$data->{general_entities} or {}},
        values %{$data->{notations} or {}},
        values %{$data->{attribute_definitions} or {}};

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
    for my $key (qw(element_types general_entities notations
                    attribute_definitions)) {
      for (keys %{$data->{$key} or {}}) {
        if (defined $data->{$key}->{$_}) {
          $data->{$key}->{$_} = $id_map{$data->{$key}->{$_}};
        }
      }
    }
    for (qw(parent_node owner)) {
      $data->{$_} = $id_map{$data->{$_}} if defined $data->{$_};
    }
  }
} # adopt

# XXX should we drop the "rc" concept and hard code that the node ID
# "0" can't be freed until the nodes within the document has been
# freed?
sub gc ($$) {
  my ($self, $id) = @_;
  delete $self->{nodes}->[$id];
  my $tree_id = $self->{tree_id}->[$id];
  my @id = grep { defined $self->{tree_id}->[$_] and 
                  $self->{tree_id}->[$_] == $tree_id } 0..$#{$self->{tree_id}};
  for (@id) {
    return if $self->{nodes}->[$_] or $self->{rc}->[$_];
  }
  for (@id) {
    delete $self->{data}->[$_];
    delete $self->{tree_id}->[$_];
    delete $self->{rc}->[$_];
    delete $self->{cols}->[$_];
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
