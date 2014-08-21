package Web::DOM::Attr;
use strict;
use warnings;
our $VERSION = '2.0';
use Web::DOM::Node;
push our @ISA, qw(Web::DOM::Node);
use Web::DOM::TypeError;

our @EXPORT;

*node_name = \&name;
*manakai_name = \&name;

sub name ($) {
  if (${$_[0]}->[2]->{prefix}) {
    return ${${$_[0]}->[2]->{prefix}} . ':' . ${${$_[0]}->[2]->{local_name}};
  } else {
    return ${${$_[0]}->[2]->{local_name}};
  }
} # name

sub is_id ($) {
  return (not ${$_[0]}->[2]->{namespace_uri} and
          ${${$_[0]}->[2]->{local_name}} eq 'id');
} # is_id

sub value ($;$) {
  if (@_ > 1) {
    # XXX mutation?

    # IndexedString
    ${$_[0]}->[2]->{data} = [[''.$_[1], -1, 0]];

    if (my $oe = $_[0]->owner_element) {
      $oe->_attribute_is
          (${$_[0]}->[2]->{namespace_uri}, ${$_[0]}->[2]->{local_name},
           set => 1, changed => 1);
    }
  }
  return join '', map { $_->[0] } @{${$_[0]}->[2]->{data}}; # IndexedString
} # value

*node_value = \&value;
*text_content = \&value;

sub manakai_get_indexed_string ($) {
  return [map {
    [$_->[0], $_->[1], $_->[2]]; # string copy
  } @{${$_[0]}->[2]->{data}}]; # IndexedString
} # manakai_get_indexed_string

sub manakai_append_text ($$) {
  # XXX mutation?

  # IndexedStringSegment
  my $segment = [ref $_[1] eq 'SCALAR' ? ${$_[1]} : $_[1], -1, 0];
  $segment->[0] = ''.$segment->[0] if ref $_[1];

  push @{${$_[0]}->[2]->{data}}, $segment;

  if (my $oe = $_[0]->owner_element) {
    $oe->_attribute_is
        (${$_[0]}->[2]->{namespace_uri}, ${$_[0]}->[2]->{local_name},
         set => 1, changed => 1);
  }
  return $_[0];
} # manakai_append_text

sub manakai_append_indexed_string ($$) {
  # XXX mutation?

  # IndexedString
  _throw Web::DOM::TypeError 'The argument is not an IndexedString'
      if not ref $_[1] eq 'ARRAY' or
         grep { not ref $_ eq 'ARRAY' } @{$_[1]};

  push @{${$_[0]}->[2]->{data}}, map {
    [''.$_->[0], 0+$_->[1], 0+$_->[2]]; # string copy
  } @{$_[1]};

  if (my $oe = $_[0]->owner_element) {
    $oe->_attribute_is
        (${$_[0]}->[2]->{namespace_uri}, ${$_[0]}->[2]->{local_name},
         set => 1, changed => 1);
  }

  return;
} # manakai_append_indexed_string

sub specified ($) { 1 }

sub owner_element ($) {
  if (my $id = ${$_[0]}->[2]->{owner}) {
    return ${$_[0]}->[0]->node ($id);
  } else {
    return undef;
  }
} # owner_element

## |DeclaredValueType|
sub NO_TYPE_ATTR () { 0 }
sub CDATA_ATTR () { 1 }
sub ID_ATTR () { 2 }
sub IDREF_ATTR () { 3 }
sub IDREFS_ATTR () { 4 }
sub ENTITY_ATTR () { 5 }
sub ENTITIES_ATTR () { 6 }
sub NMTOKEN_ATTR () { 7 }
sub NMTOKENS_ATTR () { 8 }
sub NOTATION_ATTR () { 9 }
sub ENUMERATION_ATTR () { 10 }
sub UNKNOWN_ATTR () { 11 }

push @EXPORT, qw(
  NO_TYPE_ATTR CDATA_ATTR ID_ATTR IDREF_ATTR IDREFS_ATTR ENTITY_ATTR
  ENTITIES_ATTR NMTOKEN_ATTR NMTOKENS_ATTR NOTATION_ATTR ENUMERATION_ATTR
  UNKNOWN_ATTR
);

sub manakai_attribute_type ($;$) {
  if (@_ > 1) {
    ${$_[0]}->[2]->{attribute_type} = $_[1] % 2**16;
  }
  return ${$_[0]}->[2]->{attribute_type} || 0;
} # manakai_attribute_type

1;

=head1 LICENSE

Copyright 2012-2014 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
