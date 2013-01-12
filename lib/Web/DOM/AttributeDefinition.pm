package Web::DOM::AttributeDefinition;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;
push our @ISA, qw(Web::DOM::Node);

our @EXPORT;

sub node_name ($) {
  return ${${$_[0]}->[2]->{node_name}};
} # node_name

sub owner_element_type_definition ($) {
  if (my $id = ${$_[0]}->[2]->{owner}) {
    return ${$_[0]}->[0]->node ($id);
  } else {
    return undef;
  }
} # owner_element_type_definition

sub node_value ($;$) {
  if (@_ > 1) {
    ${$_[0]}->[2]->{node_value} = defined $_[1] ? ''.$_[1] : '';
  }
  return defined ${$_[0]}->[2]->{node_value}
      ? ${$_[0]}->[2]->{node_value} : '';
} # node_value

*text_content = \&node_value;

sub manakai_append_text ($$) {
  ${$_[0]}->[2]->{node_value} .= ref $_[1] eq 'SCALAR' ? ${$_[1]} : $_[1];
  return $_[0];
} # manakai_append_text

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

sub declared_type ($;$) {
  if (@_ > 1) {
    ${$_[0]}->[2]->{declared_type} = $_[1] % 2**16;
  }
  return ${$_[0]}->[2]->{declared_type} || NO_TYPE_ATTR;
} # declared_type

sub allowed_tokens ($;$) {
  my $arrayref = ${$_[0]}->[2]->{allowed_tokens_arrayref} ||= do {
    require Web::DOM::StringArray;
    tie my @array, 'Web::DOM::StringArray',
        ${$_[0]}->[2]->{allowed_tokens} ||= [], sub { }, sub { $_[0] };
    \@array;
  };
  if (@_ > 1) {
    require Scalar::Util;
    require overload;
    if (not defined $_[1] or
        not (ref $_[1] eq 'ARRAY' or
             Scalar::Util::reftype ($_[1]) eq 'ARRAY' or
             overload::Method ($_[1], '@{}'))) {
      _throw Web::DOM::TypeError
          "Can't interpret the assigned value as an array reference";
    }
    @$arrayref = @{$_[1]};
  }
  return $arrayref;
} # allowed_tokens

## |DefaultValueType|
sub UNKNOWN_DEFAULT () { 0 }
sub FIXED_DEFAULT () { 1 }
sub REQUIRED_DEFAULT () { 2 }
sub IMPLIED_DEFAULT () { 3 }
sub EXPLICIT_DEFAULT () { 4 }

push @EXPORT, qw(
  UNKNOWN_DEFAULT FIXED_DEFAULT REQUIRED_DEFAULT IMPLIED_DEFAULT
  EXPLICIT_DEFAULT
);

sub default_type ($;$) {
  if (@_ > 1) {
    ${$_[0]}->[2]->{default_type} = $_[1] % 2**16;
  }
  return ${$_[0]}->[2]->{default_type} || UNKNOWN_DEFAULT;
} # default_type

1;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
