package Web::DOM::AttributeDefinition;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;
push our @ISA, qw(Web::DOM::Node);
use Carp;

our @EXPORT;
sub import ($;@) {
  my $from_class = shift;
  my ($to_class, $file, $line) = caller;
  for (@_ ? @_ : @EXPORT) {
    my $code = $from_class->can ($_)
        or croak qq{"$_" is not exported by the $from_class module at $file line $line};
    no strict 'refs';
    *{$to_class . '::' . $_} = $code;
  }
} # import

sub node_name ($) {
  return ${${$_[0]}->[2]->{node_name}};
} # node_name

sub node_value ($) {
  return ${$_[0]}->[2]->{node_value};
} # node_value

sub owner_element_type_definition ($) {
  if (my $id = ${$_[0]}->[2]->{owner}) {
    return ${$_[0]}->[0]->node ($id);
  } else {
    return undef;
  }
} # owner_element_type_definition

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

# XXX
sub declared_type {
  return NO_TYPE_ATTR;
}

# XXX
sub allowed_tokens {
  return [];
}

## |DefaultValueType|
sub UNKNOWN_DEFAULT () { 0 }
sub FIXED_DEFAULT () { 1 }
sub REQUIRED_DEFAULT () { 2 }
sub IMPLIED_DEFAULT () { 3 }
sub EXPLICIT_DEFAULT () { 4 }

# XXX
sub default_type {
  return UNKNOWN_DEFAULT;
}

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
