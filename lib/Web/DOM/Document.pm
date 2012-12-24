package Web::DOM::Document;
use strict;
use warnings;
no warnings 'utf8';
our $VERSION = '1.0';
use Web::DOM::Node;
use Web::DOM::RootNode;
push our @ISA, qw(Web::DOM::RootNode Web::DOM::Node);
use Web::DOM::Internal;
use Web::DOM::Exception;
use Char::Class::XML qw(
  InXMLNameChar InXMLNameStartChar
  InXMLNCNameChar InXMLNCNameStartChar
);

sub new ($) {
  my $data = {node_type => DOCUMENT_NODE};
  my $objs = Web::DOM::Internal::Objects->new;
  my $id = $objs->add_data ($data);
  $objs->{rc}->[$id]++;
  # XXX origin
  return $objs->node ($id);
} # new

sub node_name ($) {
  return '#document';
} # node_name

sub owner_document ($) {
  return undef;
} # owner_document

sub text_content ($;$) {
  return undef;
} # text_content

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
      }
    }
  }
  return $$self->[2]->{is_html};
} # manakai_is_html

sub content_type ($) {
  return ${$_[0]}->[2]->{content_type} || 'application/xml';
} # content_type

sub character_set ($) {
  return ${$_[0]}->[2]->{encoding} || 'utf-8';
} # character_set

*charset = \&character_set;

sub input_encoding ($;$) {
  if (@_ > 1) {
    # XXX if an Encoding encoding name, set it.
  }
  return $_[0]->character_set;
} # input_encoding

sub url ($) {
  return ${$_[0]}->[2]->{url} || 'about:blank';
} # url

*document_uri = \&url;

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
    }
    return $$self->[2]->{compat_mode} || 'no quirks';
  } else {
    return 'no quirks';
  }
} # manakai_compat_mode

sub implementation ($) {
  return ${$_[0]}->[0]->impl;
} # implementation

sub create_element ($$) {
  my $self = $_[0];
  my $ln = ''.$_[1];

  # XXX strictErrorChecking

  # 1.
  unless ($ln =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
    _throw Web::DOM::Exception 'InvalidCharacterError',
        'The local name is not an XML Name';
  }

  # 2.
  if ($$self->[2]->{is_html}) {
    $ln =~ tr/A-Z/a-z/; ## ASCII lowercase
  }

  # 3.
  my $data = {node_type => ELEMENT_NODE,
              namespace_uri => Web::DOM::Internal->text (HTML_NS),
              local_name => Web::DOM::Internal->text ($ln)};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_element

sub create_element_ns {
  my $self = $_[0];
  my $qname = ''.$_[2];

  # XXX DOMPERL's handling of $qname
  # XXX strictErrorChecking

  # 1.
  my $nsurl = defined $_[1] ? length $_[1] ? ''.$_[1] : undef : undef;

  # 2.
  unless ($qname =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
    _throw Web::DOM::Exception 'InvalidCharacterError',
        'The qualified name is not an XML Name';
  }

  # 3.
  unless ($qname =~ /\A\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*(?::\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*)?\z/) {
    _throw Web::DOM::Exception 'NamespaceError',
        'The qualified name is not an XML QName';
  }

  # 4.
  my ($prefix, $ln) = split /:/, $qname, 2;
  ($prefix, $ln) = (undef, $prefix) unless defined $ln;

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

  # 9.
  my $data = {node_type => ELEMENT_NODE,
              prefix => Web::DOM::Internal->text ($prefix),
              namespace_uri => Web::DOM::Internal->text ($nsurl),
              local_name => Web::DOM::Internal->text ($ln)};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_element_ns

sub create_attribute ($$) {
  my $self = $_[0];
  my $ln = ''.$_[1];

  # XXX strictErrorChecking

  # 1.
  unless ($ln =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
    _throw Web::DOM::Exception 'InvalidCharacterError',
        'The local name is not an XML Name';
  }

  # 2.
  my $data = {node_type => ATTRIBUTE_NODE,
              local_name => Web::DOM::Internal->text ($ln),
              value => ''};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_attribute

sub create_attribute_ns {
  my $self = $_[0];
  my $qname = ''.$_[2];

  # XXX DOMPERL's handling of $qname
  # XXX strictErrorChecking

  # 1.
  my $nsurl = defined $_[1] ? length $_[1] ? ''.$_[1] : undef : undef;

  # 2.
  unless ($qname =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
    _throw Web::DOM::Exception 'InvalidCharacterError',
        'The qualified name is not an XML Name';
  }

  # 3.
  unless ($qname =~ /\A\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*(?::\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*)?\z/) {
    _throw Web::DOM::Exception 'NamespaceError',
        'The qualified name is not an XML QName';
  }

  # 4.
  my ($prefix, $ln) = split /:/, $qname, 2;
  ($prefix, $ln) = (undef, $prefix) unless defined $ln;

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
  my $id = ${$_[0]}->[0]->add_data
      ({node_type => TEXT_NODE, data => \(''.$_[1])});
  return ${$_[0]}->[0]->node ($id);
} # create_text_node

sub create_cdata_section ($) {
  _throw Web::DOM::Exception 'NotSupportedError',
      'CDATASection is obsolete';
} # create_cdata_section

sub create_comment ($) {
  my $id = ${$_[0]}->[0]->add_data
      ({node_type => COMMENT_NODE, data => \(''.$_[1])});
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
  
  # 3.
  my $id = $$self->[0]->add_data
      ({node_type => PROCESSING_INSTRUCTION_NODE,
        target => Web::DOM::Internal->text ($target), data => \$data});
  return $$self->[0]->node ($id);
} # create_processing_instruction

sub import_node ($$;$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The argument is not a Node';
  }

  # 1.
  if ($_[1]->node_type == DOCUMENT_NODE) {
    _throw Web::DOM::Exception 'NotSupportedError',
        'Cannot import document node';
  }

  # 2.
  return $_[1]->_clone ($_[0], $_[2]);
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
    # Adopt 1. Remove
    if (defined $$node->[2]->{parent_node}) {
      $node->parent_node->remove_child ($node);
    } elsif (defined $$node->[2]->{owner_element}) {
      $node->owner_element->remove_attribute_node ($node);
    }

    # Adopt 2.
    ${$_[0]}->[0]->adopt ($node);

    # Adopt 3.
    if ($$node->[2]->{node_type} == ELEMENT_NODE) {
      # XXX affected by a base URL change.
    }
  }

  # 3.
  return $node;
} # adopt_node

# XXX createEvent

# XXX createRange

# XXX createNodeIterator

# XXX createTreeWalker

sub xml_version ($;$) {
  if (@_ > 1) {
    my $version = ''.$_[1];
    if ($version eq '1.0' or $version eq '1.1') {
      ${$_[0]}->[2]->{xml_version} = $_[1];
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

# XXX getElementById

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
