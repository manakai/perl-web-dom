package Web::DOM::Text;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::CharacterData;
push our @ISA, qw(Web::DOM::CharacterData);
use Web::DOM::Node;
use Web::DOM::Exception;

# XXX Constructor

sub node_name ($) {
  return '#text';
} # node_name

sub split_text ($$) {
  my $node = $_[0];
  # WebIDL: unsigned long
  my $offset = $_[1] % 2**32;

  # Split

  # 1.
  my $length = $node->length;

  # 2.
  if ($length < $offset) {
    _throw Web::DOM::Exception 'IndexSizeError',
        'Offset is greater than the length';
  }

  # 3.-5.
  my $new_node = $node->owner_document->create_text_node
      ($node->substring_data ($offset, $length - $offset));

  # 6.
  my $parent = $node->parent_node;

  # 7.
  if (defined $parent) {
    # 1.
    $parent->insert_before ($new_node, $node->next_sibling);

    # 2.-5.
    # XXX range
  }

  # 8.
  $node->replace_data ($offset, $length - $offset, '');
  
  # 9.
  if (not defined $parent) {
    # 1.-2.
    # XXX range
  }

  # 10.
  return $new_node;
} # split_text

sub whole_text ($) {
  my $self = shift;
  my $parent = $self->parent_node or return $self->data;
  my $found;
  my @text;
  for my $node ($parent->child_nodes->to_list) {
    if ($node->node_type == TEXT_NODE) {
      push @text, $node;
      $found = 1 if $node eq $self;
    } else {
      if ($found and @text) {
        return join '', map { $_->data } @text;
      }
      @text = ();
    }
  }
  if ($found and @text) {
    return join '', map { $_->data } @text;
  }
  die "The node not found...";
} # whole_text

sub serialize_as_cdata ($;$) {
  if (@_ > 1) {
    if ($_[1]) {
      ${$_[0]}->[2]->{serialize_as_cdata} = 1;
    } else {
      delete ${$_[0]}->[2]->{serialize_as_cdata};
    }
  }
  return ${$_[0]}->[2]->{serialize_as_cdata};
} # serialize_as_cdata

1;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
