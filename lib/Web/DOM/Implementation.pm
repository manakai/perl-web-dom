package Web::DOM::Implementation;
use strict;
use warnings;
no warnings 'utf8';
our $VERSION = '5.0';
use Carp;
our @CARP_NOT = qw(Web::DOM::Document Web::DOM::TypeError);
use Web::DOM::Node;
use Web::DOM::Internal;
use Web::DOM::TypeError;
use Web::DOM::Exception;

use overload
    '""' => sub {
      return ref ($_[0]) . '=DOM(' . ${$_[0]}->[0] . ')';
    },
    bool => sub { 1 },
    cmp => sub {
      carp "Use of uninitialized value in string comparison (cmp)"
          unless defined $_[1];
      overload::StrVal ($_[0]) cmp overload::StrVal ($_[1])
    },
    fallback => 1;

sub new ($) {
  require Web::DOM::Document;
  my $doc = Web::DOM::Document->new;
  return $doc->implementation;
} # new

sub create_document ($;$$$) {
  my ($self, $ns, $qn, $doctype) = @_;
  $ns = ''.$ns if defined $ns;
  $qn = ''.$qn if defined $qn and (not ref $qn or not ref $qn eq 'ARRAY');
  if (ref $qn eq 'ARRAY') {
    $qn->[0] = ''.$qn->[0] if defined $qn->[0];
    $qn->[1] = ''.$qn->[1];
  }

  ## WebIDL
  if (defined $doctype and
      not UNIVERSAL::isa ($doctype, 'Web::DOM::DocumentType')) {
    _throw Web::DOM::TypeError 'Third argument is not a DocumentType';
  }

  ## 1.
  my $data = {node_type => DOCUMENT_NODE, is_XMLDocument => 1};
  my $objs = Web::DOM::Internal::Objects->new;
  my $id = $objs->add_data ($data);
  $objs->{rc}->[$id]++;
  my $doc = $objs->node ($id);

  ## 2.
  my $el;

  ## WebIDL, 3.
  if (defined $qn and length $qn) {
    $el = $doc->create_element_ns ($ns, $qn); # or throw
  }

  ## 4.
  $doc->append_child ($doctype) if defined $doctype;

  ## 5.
  $doc->append_child ($el) if defined $el;

  ## 6.
  # XXX origin

  ## 7.
  if (defined $ns) {
    if ($ns eq HTML_NS) {
      $doc->_set_content_type ('application/xhtml+xml');
    } elsif ($ns eq SVG_NS) {
      $doc->_set_content_type ('image/svg+xml');
    }
  }

  ## 8.
  return $doc;
} # create_document

sub create_html_document ($;$) {
  ## 1., 2.
  require Web::DOM::Document;
  my $doc = Web::DOM::Document->new;
  $doc->manakai_is_html (1);
  #$doc->_set_content_type ('text/html');

  ## 3.
  my $dt = $doc->implementation->create_document_type ('html', '', '');
  $doc->append_child ($dt);

  ## 4.
  my $html = $doc->create_element_ns (HTML_NS, 'html');
  $doc->append_child ($html);

  # 5.
  my $head = $doc->create_element_ns (HTML_NS, 'head');
  $html->append_child ($head);

  # 6.
  if (defined $_[1]) {
    # 1.
    my $title = $doc->create_element_ns (HTML_NS, 'title');
    $head->append_child ($title);

    # 2.
    my $text = $doc->create_text_node ($_[1]);
    $title->append_child ($text);
  }

  # 7.
  my $body = $doc->create_element_ns (HTML_NS, 'body');
  $html->append_child ($body);
  
  # 8.
  # XXX origin

  # 9.
  return $doc;
} # create_html_document

sub create_atom_feed_document ($$;$$) {
  # 1.
  require Web::DOM::Document;
  my $doc = Web::DOM::Document->new;
  
  # 2.
  $doc->_set_content_type ('application/atom+xml');

  # 3.
  my $feed = $doc->create_element_ns (ATOM_NS, 'feed');

  # 5.
  my $id = $doc->create_element_ns (ATOM_NS, 'id');
  $id->text_content ($_[1]);
  $feed->append_child ($id);

  # 6.
  my $title = $doc->create_element_ns (ATOM_NS, 'title');
  $title->text_content (defined $_[2] ? $_[2] : '');
  $feed->append_child ($title);

  # 4.
  $feed->set_attribute_ns
      (XML_NS, ['xml', 'lang'] => defined $_[3] ? $_[3] : '');

  # 7.
  my $updated = $doc->create_element_ns (ATOM_NS, 'updated');
  $updated->value (time);
  $feed->append_child ($updated);

  # 8.
  $doc->append_child ($feed);

  # 9.
  return $doc;
} # create_atom_feed_document

sub create_atom_entry_document ($$;$$) {
  # 1.
  require Web::DOM::Document;
  my $doc = Web::DOM::Document->new;
  
  # 2.
  $doc->_set_content_type ('application/atom+xml');

  # 3.
  my $entry = $doc->create_element_ns (ATOM_NS, 'entry');

  # 5.
  my $id = $doc->create_element_ns (ATOM_NS, 'id');
  $id->text_content ($_[1]);
  $entry->append_child ($id);

  # 6.
  my $title = $doc->create_element_ns (ATOM_NS, 'title');
  $title->text_content (defined $_[2] ? $_[2] : '');
  $entry->append_child ($title);

  # 4.
  $entry->set_attribute_ns
      (XML_NS, ['xml', 'lang'] => defined $_[3] ? $_[3] : '');

  # 7.
  my $updated = $doc->create_element_ns (ATOM_NS, 'updated');
  $updated->value (time);
  $entry->append_child ($updated);

  # 8.
  $doc->append_child ($entry);

  # 9.
  return $doc;
} # create_atom_entry_document

sub create_document_type ($$;$$) {
  my $self = $_[0];
  my $qname = ''.$_[1];
  my $pubid = defined $_[2] ? ''.$_[2] : '';
  my $sysid = defined $_[3] ? ''.$_[3] : '';

  unless ($$self->[0]->{data}->[0]->{no_strict_error_checking}) {
    unless ($qname =~ /\A\p{InNCNameStartChar}\p{InNCNameChar}*(?::\p{InNCNameStartChar}\p{InNCNameChar}*)?\z/) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The qualified name is not an XML QName';
    }
  } # strict

  my $data = {node_type => DOCUMENT_TYPE_NODE,
              name => Web::DOM::Internal->text ($qname),
              public_id => Web::DOM::Internal->text ($pubid),
              system_id => Web::DOM::Internal->text ($sysid)};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_document_type

sub has_feature ($) { 1 }

1;

=head1 LICENSE

Copyright 2012-2017 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
