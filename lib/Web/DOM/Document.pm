package Web::DOM::Document;
use strict;
use warnings;
no warnings 'utf8';
our $VERSION = '4.0';
use Web::DOM::Node;
use Web::DOM::ParentNode;
use Web::DOM::XPathEvaluator;
push our @ISA, qw(Web::DOM::ParentNode Web::DOM::XPathEvaluator
                  Web::DOM::Node);
use Web::DOM::Internal;
use Web::DOM::TypeError;
use Web::DOM::Exception;
use Char::Class::XML qw(
  InXMLNameChar InXMLNameStartChar
  InXMLNCNameChar InXMLNCNameStartChar
);
# XXX EventHandlers

sub new ($) {
  my $data = {node_type => DOCUMENT_NODE};
  my $objs = Web::DOM::Internal::Objects->new;
  my $id = $objs->add_data ($data);
  $objs->{rc}->[$id]++;
  # XXX origin
  return $objs->node ($id);
} # new

## ------ Basic node properties ------

sub node_name ($) {
  return '#document';
} # node_name

sub owner_document ($) {
  return undef;
} # owner_document

## ------ Document properties ------

sub content_type ($) {
  return ${$_[0]}->[2]->{content_type} || 'application/xml';
} # content_type

## Internal method.
##
## Set the content type of the document.  It must be a lowercase
## canonical valid MIME type without parameters.  It can be
## "text/html" iff it is an HTML document.  This method must be
## invoked after |manakai_is_html| method as that method mutates the
## content type of the document.
sub _set_content_type ($$) {
  ${$_[0]}->[2]->{content_type} = $_[1];
} # _set_content_type

sub manakai_is_html ($;$) {
  my $self = $_[0];
  if (@_ > 1) {
    if ($_[1]) {
      $$self->[2]->{is_html} = 1;
      $$self->[2]->{content_type} = 'text/html';
    } else {
      delete $$self->[2]->{is_html};
      delete $$self->[2]->{compat_mode};
      delete $$self->[2]->{content_type};
    }
    for my $cols (@{$$self->[0]->{cols} or []}) {
      next unless $cols;
      for my $key (keys %$cols) {
        next unless $cols->{$key};
        delete ${$cols->{$key}}->[2];
        delete ${$cols->{$key}}->[4];
      }
    }
  }
  return $$self->[2]->{is_html};
} # manakai_is_html

sub compat_mode ($) {
  my $self = $_[0];
  if ($$self->[2]->{is_html}) {
    if (defined $$self->[2]->{compat_mode} and
        $$self->[2]->{compat_mode} eq 'quirks') {
      return 'BackCompat';
    }
  }
  return 'CSS1Compat';
} # compat_mode

sub manakai_compat_mode ($;$) {
  my $self = $_[0];
  if ($$self->[2]->{is_html}) {
    if (@_ > 1 and defined $_[1] and
        {'no quirks' => 1, 'limited quirks' => 1, 'quirks' => 1}->{$_[1]}) {
      $$self->[2]->{compat_mode} = $_[1];
      for my $cols (@{$$self->[0]->{cols} or []}) {
        next unless $cols;
        for my $key (keys %$cols) {
          next unless $cols->{$key};
          delete ${$cols->{$key}}->[2];
          delete ${$cols->{$key}}->[4];
        }
      }
    }
    return $$self->[2]->{compat_mode} || 'no quirks';
  } else {
    return 'no quirks';
  }
} # manakai_compat_mode

sub manakai_is_srcdoc ($;$) {
  if (@_ > 1) {
    if ($_[1]) {
      ${$_[0]}->[2]->{is_srcdoc} = 1;
    } else {
      delete ${$_[0]}->[2]->{is_srcdoc};
    }
    delete ${$_[0]}->[0]->{document_base_url};
    delete ${$_[0]}->[0]->{document_base_url_revision};
  }
  return ${$_[0]}->[2]->{is_srcdoc};
} # manakai_is_srcdoc

sub character_set ($) {
  require Web::Encoding;
  return Web::Encoding::encoding_name_to_compat_name
      (${$_[0]}->[2]->{encoding} || 'utf-8');
} # character_set

*charset = \&character_set;

sub input_encoding ($;$) {
  if (@_ > 1) {
    require Web::Encoding;
    my $name = Web::Encoding::encoding_label_to_name (''.$_[1]);
    ${$_[0]}->[2]->{encoding} = $name
        if Web::Encoding::is_encoding_label ($name);
  }
  return $_[0]->character_set;
} # input_encoding

sub manakai_charset ($;$) {
  if (@_ > 1) {
    if (defined $_[1]) {
      ${$_[0]}->[2]->{manakai_charset} = ''.$_[1];
    } else {
      delete ${$_[0]}->[2]->{manakai_charset};
    }
  }
  return ${$_[0]}->[2]->{manakai_charset};
} # manakai_charset

sub manakai_has_bom ($;$) {
  if (@_ > 1) {
    if ($_[1]) {
      ${$_[0]}->[2]->{manakai_has_bom} = 1;
    } else {
      delete ${$_[0]}->[2]->{manakai_has_bom};
    }
  }
  return ${$_[0]}->[2]->{manakai_has_bom};
} # manakai_has_bom

sub url ($) {
  return defined ${$_[0]}->[2]->{url}
      ? ${$_[0]}->[2]->{url} : 'about:blank';
} # url

*document_uri = \&url;

sub manakai_set_url ($$) {
  # 1.
  my $url = _resolve_url ''.$_[1], 'about:blank';

  # 2.
  if (not defined $url) {
    _throw Web::DOM::Exception 'SyntaxError',
        'Cannot resolve the specified URL';
  }

  # 3.
  ${$_[0]}->[2]->{url} = $url;
  delete ${$_[0]}->[0]->{document_base_url};
  delete ${$_[0]}->[0]->{document_base_url_revision};
  return;
} # manakai_set_url

# XXX origin

# XXX location

# XXX domain

sub manakai_entity_base_uri ($;$) {
  if (@_ > 1) {
    if (not defined $_[1]) {
      # 1.
      delete ${$_[0]}->[2]->{manakai_entity_base_uri};
    } else {
      # 2.
      ${$_[0]}->[2]->{manakai_entity_base_uri}
          = Web::DOM::Internal->text (_resolve_url ''.$_[1], $_[0]->url);
    }
  }

  # 1.
  return ${${$_[0]}->[2]->{manakai_entity_base_uri}}
      if ${$_[0]}->[2]->{manakai_entity_base_uri};

  # 2.
  return $_[0]->url;
} # manakai_entity_base_uri

# XXX referrer cookie lastModified

sub xml_version ($;$) {
  if (@_ > 1) {
    my $version = ''.$_[1];
    if ($version eq '1.0' or $version eq '1.1' or
        ${$_[0]}->[2]->{no_strict_error_checking}) {
      ${$_[0]}->[2]->{xml_version} = $version;
    } else {
      _throw Web::DOM::Exception 'NotSupportedError',
          'Specified XML version is not supported';
    }
  }
  return defined ${$_[0]}->[2]->{xml_version}
      ? ${$_[0]}->[2]->{xml_version} : '1.0';
} # xml_version

sub xml_encoding ($;$) {
  if (@_ > 1) {
    if (defined $_[1]) {
      ${$_[0]}->[2]->{xml_encoding} = ''.$_[1];
    } else {
      delete ${$_[0]}->[2]->{xml_encoding};
    }
  }
  return ${$_[0]}->[2]->{xml_encoding};
} # xml_encoding

sub xml_standalone ($;$) {
  if (@_ > 1) {
    if ($_[1]) {
      ${$_[0]}->[2]->{xml_standalone} = 1;
    } else {
      delete ${$_[0]}->[2]->{xml_standalone};
    }
  }
  return ${$_[0]}->[2]->{xml_standalone};
} # xml_standalone

sub all_declarations_processed ($;$) {
  if (@_ > 1) {
    if ($_[1]) {
      ${$_[0]}->[2]->{all_declarations_processed} = 1;
    } else {
      delete ${$_[0]}->[2]->{all_declarations_processed};
    }
  }
  return ${$_[0]}->[2]->{all_declarations_processed};
} # all_declarations_processed

## ------ Document configuration ------

sub implementation ($) {
  return ${$_[0]}->[0]->impl;
} # implementation

sub dom_config ($) {
  return ${$_[0]}->[0]->config;
} # dom_config

sub strict_error_checking ($;$) {
  if (@_ > 1) {
    if ($_[1]) {
      delete ${$_[0]}->[2]->{no_strict_error_checking};
    } else {
      ${$_[0]}->[2]->{no_strict_error_checking} = 1;
    }
  }
  return not ${$_[0]}->[2]->{no_strict_error_checking};
} # strict_error_checking

## ------ Attributes ------

sub dir ($;$) {
  my $de = shift->manakai_html;
  if (defined $de) {
    return $de->dir (@_);
  } else {
    return '';
  }
} # dir

# XXX *color

## ------ Content ------

sub text_content ($;$) {
  if (${$_[0]}->[0]->{config}->{not_manakai_strict_document_children}) {
    return shift->SUPER::text_content (@_);
  } else {
    return undef;
  }
} # text_content

sub manakai_append_text ($$) {
  if (${$_[0]}->[0]->{config}->{not_manakai_strict_document_children}) {
    $_[0]->SUPER::manakai_append_text ($_[1]);
  }
  return $_[0];
} # manakai_append_text

sub manakai_append_indexed_string ($$) {
  if (${$_[0]}->[0]->{config}->{not_manakai_strict_document_children}) {
    $_[0]->SUPER::manakai_append_indexed_string ($_[1]);
  }
  return undef;
} # manakai_append_indexed_string

sub doctype ($) {
  for ($_[0]->child_nodes->to_list) {
    if ($_->node_type == DOCUMENT_TYPE_NODE) {
      return $_;
    }
  }
  return undef;
} # doctype

sub document_element ($) {
  for ($_[0]->child_nodes->to_list) {
    if ($_->node_type == ELEMENT_NODE) {
      return $_;
    }
  }
  return undef;
} # document_element

sub manakai_html ($) {
  my $html = $_[0]->document_element or return undef;
  return $html if $html->manakai_element_type_match (HTML_NS, 'html');
  return undef;
} # manakai_html

sub atom_feed_element ($) {
  my $el = $_[0]->document_element or return undef;
  return $el if $el->manakai_element_type_match (ATOM_NS, 'feed');
  return undef;
} # atom_feed_element

sub head ($) {
  my $html = $_[0]->manakai_html or return undef;
  for ($html->child_nodes->to_list) {
    if ($_->manakai_element_type_match (HTML_NS, 'head')) {
      return $_;
    }
  }
  return undef;
} # head

*manakai_head = \&head;

sub title ($;$) {
  my $self = $_[0];

  my $title_el;
  my $re = $self->document_element;
  if (defined $re) {
    if ($re->manakai_element_type_match (SVG_NS, 'svg')) {
      for ($re->children->to_list) {
        if ($_->manakai_element_type_match (SVG_NS, 'title')) {
          if (@_ > 1) {
            $_->text_content ($_[1]);
          }
          $title_el = $_;
          last;
        }
      }

      if (@_ > 1) {
        $title_el = $self->create_element_ns (SVG_NS, 'title');
        $re->append_child ($title_el);
        $title_el->text_content ($_[1]);
      }
    } elsif (($re->namespace_uri || '') eq HTML_NS) {
      $title_el = $self->get_elements_by_tag_name ('title')->[0];
      if (defined $title_el) {
        if (@_ > 1) {
          $title_el->text_content ($_[1]);
        }
      } else {
        my $head = $self->head;
        if (defined $head) {
          $title_el = $self->create_element ('title');
          if (@_ > 1) {
            $head->append_child ($title_el);
            $title_el->text_content ($_[1]);
          }
        }
      }
    } else {
      return unless defined wantarray;
      $title_el = $self->get_elements_by_tag_name ('title')->[0];
    }
  } else {
    return unless defined wantarray;
    $title_el = $self->get_elements_by_tag_name ('title')->[0];
  }
  return unless defined wantarray;

  my $value = '';
  if (defined $title_el) {
    $value = join '', map { $_->data }
        grep { $_->node_type == TEXT_NODE } $title_el->child_nodes->to_list;
  }
  $value =~ s/[\x09\x0A\x0C\x0D\x20]+/ /g;
  $value =~ s/\A //;
  $value =~ s/ \z//;
  return $value;
} # title

sub body ($;$) {
  my $self = $_[0];
  if (@_ > 1) {
    # WebIDL
    if (defined $_[1] and
        not UNIVERSAL::isa ($_[1], 'Web::DOM::HTMLElement')) {
      _throw Web::DOM::TypeError 'The argument is not an HTMLElement';
    }

    # 1.
    if (not defined $_[1] or
        not HTML_NS eq ($_[1]->namespace_uri || '') or
        not ($_[1]->local_name eq 'body' or $_[1]->local_name eq 'frameset')) {
      _throw Web::DOM::Exception 'HierarchyRequestError',
          'The specified value cannot be used as the body element';
    }

    my $body = $self->body; # recursive!
    
    if (defined $body and $body eq $_[1]) {
      # 2.
      #
    } elsif (defined $body) {
      # 3.
      $body->parent_node->replace_child ($_[1], $body);
    } else {
      my $de = $self->document_element;
      if (defined $de) {
        # 5.
        $de->append_child ($_[1]);
      } else {
        # 4.
        _throw Web::DOM::Exception 'HierarchyRequestError',
            'There is no root element';
      }
    }
    return unless defined wantarray;
  }

  # The body element
  my $html = $self->manakai_html or return undef;
  for ($html->child_nodes->to_list) {
    next unless $_->node_type == ELEMENT_NODE;
    if ($_->manakai_element_type_match (HTML_NS, 'body') or
        $_->manakai_element_type_match (HTML_NS, 'frameset')) {
      return $_;
    }
  }
  return undef;
} # body

# XXX need O(1) implementation...
# XXX <https://github.com/whatwg/dom/commit/1e953d1b2205dbf0ca78af82e6fd7c59a04c347e>
# XXX Move to ParentNode
sub get_element_by_id ($$) {
  my $id = ''.$_[1];
  return undef unless length $id;
  my @nodes = $_[0]->child_nodes->to_list;
   while (@nodes) {
    my $node = shift @nodes;
    next unless $node->node_type == ELEMENT_NODE;
    return $node if $node->id eq $id;
    unshift @nodes, $node->child_nodes->to_list;
  }
  return undef;
} # get_element_by_id

sub images ($) {
  return ${$_[0]}->[0]->collection_by_el ($_[0], 'images', HTML_NS, 'img');
} # images

sub embeds ($) {
  return ${$_[0]}->[0]->collection_by_el ($_[0], 'embeds', HTML_NS, 'embed');
} # embeds

*plugins = \&embeds;

sub forms ($) {
  return ${$_[0]}->[0]->collection_by_el ($_[0], 'forms', HTML_NS, 'form');
} # forms

sub scripts ($) {
  return ${$_[0]}->[0]->collection_by_el ($_[0], 'scripts', HTML_NS, 'script');
} # scripts

sub applets ($) {
  return ${$_[0]}->[0]->collection_by_el ($_[0], 'applets', HTML_NS, 'applet');
} # applets

sub links ($) {
  my $self = $_[0];
  return $$self->[0]->collection ('links', $self, sub {
    my $node = $_[0];
    my $data = $$node->[0]->{data};
    my @node_id = @{$data->[$$node->[1]]->{child_nodes} or []};
    my @id;
    while (@node_id) {
      my $id = shift @node_id;
      next unless $data->[$id]->{node_type} == ELEMENT_NODE;
      unshift @node_id, @{$data->[$id]->{child_nodes} or []};
      next unless ${$data->[$id]->{local_name}} eq 'a' or
                  ${$data->[$id]->{local_name}} eq 'area';
      next unless ${$data->[$id]->{namespace_uri} || \''} eq HTML_NS;
      next unless defined $data->[$id]->{attrs}->{''}->{href}; # AttrValueRef
      push @id, $id;
    }
    return @id;
  });
} # links

sub anchors ($) {
  my $self = $_[0];
  return $$self->[0]->collection ('anchors', $self, sub {
    my $node = $_[0];
    my $data = $$node->[0]->{data};
    my @node_id = @{$data->[$$node->[1]]->{child_nodes} or []};
    my @id;
    while (@node_id) {
      my $id = shift @node_id;
      next unless $data->[$id]->{node_type} == ELEMENT_NODE;
      unshift @node_id, @{$data->[$id]->{child_nodes} or []};
      next unless ${$data->[$id]->{local_name}} eq 'a';
      next unless ${$data->[$id]->{namespace_uri} || \''} eq HTML_NS;
      next unless defined $data->[$id]->{attrs}->{''}->{name}; # AttrValueRef
      push @id, $id;
    }
    return @id;
  });
} # anchors

sub get_elements_by_name ($$) {
  my $self = $_[0];
  my $name = ''.$_[1];
  return $$self->[0]->collection (['by_name', $name], $self, sub {
    my $node = $_[0];
    my $data = $$node->[0]->{data};
    my @node_id = @{$data->[$$node->[1]]->{child_nodes} or []};
    my @id;
    while (@node_id) {
      my $id = shift @node_id;
      next unless $data->[$id]->{node_type} == ELEMENT_NODE;
      unshift @node_id, @{$data->[$id]->{child_nodes} or []};
      next unless ${$data->[$id]->{namespace_uri} || \''} eq HTML_NS;
      next unless defined (my $value = $data->[$id]->{attrs}->{''}->{name}); # AttrValueRef
      if (ref $value) {
        next unless $name eq join '', map { $_->[0] } @$value; # AttrValueRef/IndexedString
      } else {
        next unless $name eq join '', map { $_->[0] } @{$data->[$value]->{data}}; # IndexedString
      }
      push @id, $id;
    }
    return @id;
  });
} # get_elements_by_name

sub all ($) {
  my $self = $_[0];
  return $$self->[0]->collection (['all'], $self, sub {
    my $node = $_[0];
    my $data = $$node->[0]->{data};
    my @node_id = @{$data->[$$node->[1]]->{child_nodes} or []};
    my @id;
    while (@node_id) {
      my $id = shift @node_id;
      next unless $data->[$id]->{node_type} == ELEMENT_NODE;
      unshift @node_id, @{$data->[$id]->{child_nodes} or []};
      push @id, $id;
    }
    return @id;
  });
} # all

# XXX commands css_element_map

# XXX getter

## ------ Node factory ------

sub create_element ($$) {
  my $self = $_[0];
  my $ln = ''.$_[1];

  # 1.
  if ($$self->[2]->{no_strict_error_checking}) {
    unless (length $ln) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The local name is not an XML Name';
    }
  } else {
    unless ($ln =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The local name is not an XML Name';
    }
  }

  # 2.
  if ($$self->[2]->{is_html}) {
    $ln =~ tr/A-Z/a-z/; ## ASCII lowercase
  }

  # 3.
  my $data = {node_type => ELEMENT_NODE,
              namespace_uri => $Web::DOM::Internal::Text->{(HTML_NS)},
              local_name => ($Web::DOM::Internal::Text->{$ln} ||= \$ln)};
  my $id = $$self->[0]->add_data ($data);
  my $node = $$self->[0]->node ($id);
  if ($ln eq 'template') {
    my $tmpl_doc = $$self->[0]->template_doc;
    my $df_id = $$tmpl_doc->[0]->add_data ({node_type => DOCUMENT_FRAGMENT_NODE});
    $$self->[0]->set_template_content ($id => $$tmpl_doc->[0]->node ($df_id));
  }
  return $node;
} # create_element

sub create_element_ns {
  my $self = $_[0];
  my $qname;
  my $prefix;
  my $ln;
  my $not_strict = $$self->[0]->{data}->[0]->{no_strict_error_checking};

  # DOMPERL
  if (defined $_[2] and ref $_[2] eq 'ARRAY') {
    $prefix = $_[2]->[0];
    $prefix = ''.$prefix if defined $prefix;
    $ln = ''.$_[2]->[1];
    $qname = defined $prefix ? $prefix . ':' . $ln : $ln;
  } else {
    $qname = ''.$_[2];
  }

  # 1.
  my $nsurl = defined $_[1] ? length $_[1] ? ''.$_[1] : undef : undef;

  if ($not_strict) {
    unless (length $qname) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The qualified name is not an XML Name';
    }
  } else {
    # 2.
    unless ($qname =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The qualified name is not an XML Name';
    }

    # 3.
    if (defined $ln) {
      if (defined $prefix and
          not $prefix =~ /\A\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*\z/) {
        _throw Web::DOM::Exception 'NamespaceError',
            'The prefix is not an XML NCName';
      }
      unless ($ln =~ /\A\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*\z/) {
        _throw Web::DOM::Exception 'NamespaceError',
            'The local name is not an XML NCName';
      }
    }
    unless ($qname =~ /\A\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*(?::\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*)?\z/) {
      _throw Web::DOM::Exception 'NamespaceError',
          'The qualified name is not an XML QName';
    }
  } # strict

  # 4.
  if (not defined $ln) {
    $ln = $qname;
    if ($ln =~ s{\A([^:]+):(?=.)}{}s) {
      $prefix = $1;
    }
  }

  unless ($not_strict) {
    # 5.
    if (defined $prefix and not defined $nsurl) {
      _throw Web::DOM::Exception 'NamespaceError',
          'Namespace prefix cannot be bound to the null namespace';
    }

    # 6.
    if (defined $prefix and $prefix eq 'xml' and
        (not defined $nsurl or $nsurl ne XML_NS)) {
      _throw Web::DOM::Exception 'NamespaceError',
          'Prefix |xml| cannot be bound to anything other than XML namespace';
    }

    # 7.
    if (($qname eq 'xmlns' or (defined $prefix and $prefix eq 'xmlns')) and
        (not defined $nsurl or $nsurl ne XMLNS_NS)) {
      _throw Web::DOM::Exception 'NamespaceError',
          'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
    }

    # 8.
    if (defined $nsurl and $nsurl eq XMLNS_NS and
        not ($qname eq 'xmlns' or (defined $prefix and $prefix eq 'xmlns'))) {
      _throw Web::DOM::Exception 'NamespaceError',
          'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';
    }
  } # strict

  # 9.
  my $data = {node_type => ELEMENT_NODE,
              local_name => ($Web::DOM::Internal::Text->{$ln} ||= \$ln)};
  $data->{namespace_uri} = ($Web::DOM::Internal::Text->{$nsurl} ||= \$nsurl)
      if defined $nsurl;
  $data->{prefix} = ($Web::DOM::Internal::Text->{$prefix} ||= \$prefix)
      if defined $prefix;
  my $id = $$self->[0]->add_data ($data);
  my $node = $$self->[0]->node ($id);
  if ($ln eq 'template' and defined $nsurl and $nsurl eq HTML_NS) {
    my $tmpl_doc = $$self->[0]->template_doc;
    my $df_id = $$tmpl_doc->[0]->add_data
        ({node_type => DOCUMENT_FRAGMENT_NODE});
    $$self->[0]->set_template_content ($id => $$tmpl_doc->[0]->node ($df_id));
  }
  return $node;
} # create_element_ns

sub create_attribute ($$) {
  my $self = $_[0];
  my $ln = ''.$_[1];

  # 1.
  if ($$self->[2]->{no_strict_error_checking}) {
    unless (length $ln) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The local name is not an XML Name';
    }
  } else {
    unless ($ln =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The local name is not an XML Name';
    }
  }

  # 2.
  if ($$self->[2]->{is_html}) {
    $ln =~ tr/A-Z/a-z/; ## ASCII lowercase
  }

  # 3.
  my $data = {node_type => ATTRIBUTE_NODE,
              local_name => Web::DOM::Internal->text ($ln),
              value => ''};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_attribute

sub create_attribute_ns {
  my $self = $_[0];
  my $qname;
  my $prefix;
  my $ln;
  my $not_strict = $$self->[0]->{data}->[0]->{no_strict_error_checking};

  # WebIDL / 1.
  my $nsurl = defined $_[1] ? length $_[1] ? ''.$_[1] : undef : undef;

  # DOMPERL
  if (defined $_[2] and ref $_[2] eq 'ARRAY') {
    $prefix = $_[2]->[0];
    $prefix = ''.$prefix if defined $prefix;
    $ln = ''.$_[2]->[1];
    $qname = defined $prefix ? $prefix . ':' . $ln : $ln;
  } else {
    $qname = ''.$_[2];
  }

  if ($not_strict) {
    unless (length $qname) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The qualified name is not an XML Name';
    }
  } else {
    # 2.
    unless ($qname =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The qualified name is not an XML Name';
    }

    # 3.
    if (defined $ln) {
      if (defined $prefix and
          not $prefix =~ /\A\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*\z/) {
        _throw Web::DOM::Exception 'NamespaceError',
            'The prefix is not an XML NCName';
      }
      unless ($ln =~ /\A\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*\z/) {
        _throw Web::DOM::Exception 'NamespaceError',
            'The local name is not an XML NCName';
      }
    }
    unless ($qname =~ /\A\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*(?::\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*)?\z/) {
      _throw Web::DOM::Exception 'NamespaceError',
          'The qualified name is not an XML QName';
    }
  } # strict

  # 4.
  unless (defined $ln) {
    $ln = $qname;
    if ($ln =~ s{\A([^:]+):(?=.)}{}s) {
      $prefix = $1;
    }
  }

  unless ($not_strict) {
    # 5.
    if (defined $prefix and not defined $nsurl) {
      _throw Web::DOM::Exception 'NamespaceError',
          'Namespace prefix cannot be bound to the null namespace';
    }

    # 6.
    if (defined $prefix and $prefix eq 'xml' and
        (not defined $nsurl or $nsurl ne XML_NS)) {
      _throw Web::DOM::Exception 'NamespaceError',
          'Prefix |xml| cannot be bound to anything other than XML namespace';
    }

    # 7.
    if (($qname eq 'xmlns' or (defined $prefix and $prefix eq 'xmlns')) and
        (not defined $nsurl or $nsurl ne XMLNS_NS)) {
      _throw Web::DOM::Exception 'NamespaceError',
          'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
    }

    # 8.
    if (defined $nsurl and $nsurl eq XMLNS_NS and
        not ($qname eq 'xmlns' or (defined $prefix and $prefix eq 'xmlns'))) {
      _throw Web::DOM::Exception 'NamespaceError',
          'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';
    }
  } # strict

  # 9.
  my $data = {node_type => ATTRIBUTE_NODE,
              prefix => Web::DOM::Internal->text ($prefix),
              namespace_uri => Web::DOM::Internal->text ($nsurl),
              local_name => Web::DOM::Internal->text ($ln),
              value => ''};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_attribute_ns

sub create_document_fragment ($) {
  my $id = ${$_[0]}->[0]->add_data ({node_type => DOCUMENT_FRAGMENT_NODE});
  return ${$_[0]}->[0]->node ($id);
} # create_document_fragment

sub create_text_node ($) {
  ## See also ParentNode::manakai_append_text

  # IndexedStringSegment
  my $segment = [ref $_[1] eq 'SCALAR' ? ${$_[1]} : $_[1], -1, 0];
  $segment->[0] = ''.$segment->[0] if ref $segment->[0];

  my $id = ${$_[0]}->[0]->add_data
      ({node_type => TEXT_NODE,
        data => length $segment->[0] ? [$segment] : []});
  return ${$_[0]}->[0]->node ($id);
} # create_text_node

sub create_cdata_section ($) {
  _throw Web::DOM::Exception 'NotSupportedError',
      'CDATASection is obsolete';
} # create_cdata_section

sub create_comment ($) {
  # IndexedStringSegment
  my $segment = [ref $_[1] eq 'SCALAR' ? ${$_[1]} : $_[1], -1, 0];
  $segment->[0] = ''.$segment->[0] if ref $segment->[0];

  my $id = ${$_[0]}->[0]->add_data
      ({node_type => COMMENT_NODE,
        data => length $segment->[0] ? [$segment] : []});
  return ${$_[0]}->[0]->node ($id);
} # create_comment

sub create_entity_reference ($) {
  _throw Web::DOM::Exception 'NotSupportedError',
      'EntityReference is obsolete';
} # create_entity_reference

sub create_processing_instruction ($$$) {
  my $self = $_[0];
  my $target = ''.$_[1];
  my $data = ''.$_[2];

  if ($$self->[2]->{no_strict_error_checking}) {
    unless (length $target) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The target is not an XML Name';
    }
  } else {
    # 1.
    unless ($target =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The target is not an XML Name';
    }

    # 2.
    if ($data =~ /\?>/) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The data cannot contain ?>';
    }
  } # strict
  
  # 3.
  my $id = $$self->[0]->add_data
      ({node_type => PROCESSING_INSTRUCTION_NODE,
        target => Web::DOM::Internal->text ($target),
        data => length $data ? [[$data, -1, 0]] : []}); # IndexedString
  return $$self->[0]->node ($id);
} # create_processing_instruction

sub create_document_type_definition ($$) {
  my $self = $_[0];
  my $qname = ''.$_[1];

  unless ($$self->[2]->{no_strict_error_checking}) {
    unless ($qname =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The qualified name is not an XML Name';
    }
  } # strict

  my $data = {node_type => DOCUMENT_TYPE_NODE,
              name => Web::DOM::Internal->text ($qname),
              public_id => Web::DOM::Internal->text (''),
              system_id => Web::DOM::Internal->text ('')};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_document_type_definition

sub create_element_type_definition ($$) {
  my $self = $_[0];
  my $qname = ''.$_[1];

  unless ($$self->[2]->{no_strict_error_checking}) {
    unless ($qname =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The qualified name is not an XML Name';
    }
  } # strict

  my $data = {node_type => ELEMENT_TYPE_DEFINITION_NODE,
              node_name => Web::DOM::Internal->text ($qname)};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_element_type_definition

sub create_attribute_definition ($$) {
  my $self = $_[0];
  my $qname = ''.$_[1];

  unless ($$self->[2]->{no_strict_error_checking}) {
    unless ($qname =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The qualified name is not an XML Name';
    }
  } # strict

  my $data = {node_type => ATTRIBUTE_DEFINITION_NODE,
              node_name => Web::DOM::Internal->text ($qname),
              node_value => ''};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_attribute_definition

sub create_general_entity ($$) {
  my $self = $_[0];
  my $qname = ''.$_[1];

  unless ($$self->[2]->{no_strict_error_checking}) {
    unless ($qname =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The qualified name is not an XML Name';
    }
  } # strict

  my $data = {node_type => ENTITY_NODE,
              name => Web::DOM::Internal->text ($qname),
              public_id => Web::DOM::Internal->text (''),
              system_id => Web::DOM::Internal->text ('')};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_general_entity

sub create_notation ($$) {
  my $self = $_[0];
  my $qname = ''.$_[1];

  unless ($$self->[2]->{no_strict_error_checking}) {
    unless ($qname =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The qualified name is not an XML Name';
    }
  } # strict

  my $data = {node_type => NOTATION_NODE,
              name => Web::DOM::Internal->text ($qname),
              public_id => Web::DOM::Internal->text (''),
              system_id => Web::DOM::Internal->text ('')};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_notation

sub import_node ($$;$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The argument is not a Node';
  }
  my $deep = !!$_[2];

  # 1.
  if ($_[1]->node_type == DOCUMENT_NODE) {
    _throw Web::DOM::Exception 'NotSupportedError',
        'Cannot import document node';
  }

  # 2.
  return $_[1]->_clone ($_[0], $deep);
} # import_node

sub adopt_node ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The argument is not a Node';
  }
  
  # 1.
  my $node = $_[1];
  if ($node->node_type == DOCUMENT_NODE) {
    _throw Web::DOM::Exception 'NotSupportedError',
        'Cannot adopt document node';
  }

  # 2. Adopt
  {
    # Adopt 2. Remove
    if (defined $$node->[2]->{parent_node}) {
      $$node->[0]->remove_node
          ($$node->[2]->{parent_node}, $$node->[1], 0);
    } elsif (defined $$node->[2]->{owner}) {
      my $node_nt = $$node->[2]->{node_type};
      if ($node_nt == ATTRIBUTE_NODE) {
        $node->owner_element->remove_attribute_node ($node);
      } elsif ($node_nt == ELEMENT_TYPE_DEFINITION_NODE) {
        $node->owner_document_type_definition
            ->remove_element_type_definition_node ($node);
      } elsif ($node_nt == ENTITY_NODE) {
        $node->owner_document_type_definition
            ->remove_general_entity_node ($node);
      } elsif ($node_nt == NOTATION_NODE) {
        $node->owner_document_type_definition->remove_notation_node ($node);
      } elsif ($node_nt == ATTRIBUTE_DEFINITION_NODE) {
        $node->owner_element_type_definition
            ->remove_attribute_definition_node ($node);
      }
    }

    # Adopt 3.
    ${$_[0]}->[0]->adopt ($node);

    # Adopt 4. Adopting steps
    if ($$node->[2]->{node_type} == ELEMENT_NODE) {
      # XXX
    }
  }

  # 3.
  return $node;
} # adopt_node

sub create_event ($$) {
  my $str = ''.$_[1];
  $str =~ tr/A-Z/a-z/; ## ASCII case-insensitive.
  my $if = {
    customevent => 'CustomEvent',
    event => 'Event',
    events => 'Event',
    htmlevents => 'Event',
    keyboardevent => 'KeyboardEvent',
    keyevents => 'KeyboardEvent',
    messageevent => 'MessageEvent',
    mouseevent => 'MouseEvent',
    mouseevents => 'MouseEvent',
    touchevent => 'TouchEvent',
    uievent => 'UIEvent',
    uievents => 'UIEvent',
  }->{$str}
      or _throw Web::DOM::Exception 'NotSupportedError',
          'Unknown event interface';
  
  require Web::DOM::Event;
  return "Web::DOM::$if"->_new;
} # create_event

# XXX createRange

sub create_node_iterator ($;$$$) {
  # WebIDL
  _throw Web::DOM::TypeError 'The first argument is not a Node'
      unless UNIVERSAL::isa ($_[1], 'Web::DOM::Node');
  my $wts = defined $_[2]
      ? unpack 'L', pack 'L', $_[2] % 2**32 # WebIDL unsigned long
      : 0xFFFFFFFF;
  _throw Web::DOM::TypeError 'The third argument is not a code reference'
      if defined $_[3] and not ref $_[3] eq 'CODE';
  # $_[4] (expand entity references) is obsolete

  return ${$_[0]}->[0]->iterator ($_[1], $wts, $_[3]);
} # create_node_iterator

sub create_tree_walker ($;$$$) {
  # WebIDL
  _throw Web::DOM::TypeError 'The first argument is not a Node'
      unless UNIVERSAL::isa ($_[1], 'Web::DOM::Node');
  my $wts = defined $_[2]
      ? unpack 'L', pack 'L', $_[2] % 2**32 # WebIDL unsigned long
      : 0xFFFFFFFF;
  _throw Web::DOM::TypeError 'The third argument is not a code reference'
      if defined $_[3] and not ref $_[3] eq 'CODE';
  # $_[4] (expand entity references) is obsolete

  require Web::DOM::TreeWalker;
  return bless {
    root => $_[1],
    current_node => $_[1],
    what_to_show => $wts,
    filter => $_[3],
  }, 'Web::DOM::TreeWalker';
} # create_tree_walker

sub create_touch ($$$$$$$$) {
  # WebIDL
  _throw Web::DOM::TypeError 'The first argument is not a WindowProxy'
      unless UNIVERSAL::isa ($_[1], 'Web::DOM::WindowProxy');
  _throw Web::DOM::TypeError 'The second argument is not an EventTarget'
      unless UNIVERSAL::isa ($_[2], 'Web::DOM::EventTarget');
  require Web::DOM::Touch;
  return bless {
    target => $_[2],
    identifier => (unpack 'l', pack 'L', $_[3] % 2**32), # WebIDL long
    page_x => (unpack 'l', pack 'L', $_[4] % 2**32), # WebIDL long
    page_y => (unpack 'l', pack 'L', $_[5] % 2**32), # WebIDL long
    screen_x => (unpack 'l', pack 'L', $_[6] % 2**32), # WebIDL long
    screen_y => (unpack 'l', pack 'L', $_[7] % 2**32), # WebIDL long
    client_x => 0,
    client_y => 0,
  }, 'Web::DOM::Touch';
} # create_touch

sub create_touch_list ($;@) {
  shift;
  # WebIDL
  for (@_) {
    _throw Web::DOM::TypeError 'An argument is not a Touch'
        unless UNIVERSAL::isa ($_, 'Web::DOM::Touch');
  }
  require Web::DOM::TouchList;
  my $list = bless [@_], 'Web::DOM::TouchList';
  Internals::SvREADONLY (@$list, 1);
  Internals::SvREADONLY ($_, 1) for @$list;
  return $list;
} # create_touch_list

## ------ Markup interaction ------

# XXX open close write writeln current_script

sub clear ($) { }

# XXX readystate onreadystatechange

## ------ Browsing context and user interaction ------

# XXX default_view active_element has_focus design_mode *command*

1;

=head1 LICENSE

Copyright 2007-2015 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
