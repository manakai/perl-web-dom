package Web::DOM::XPathResult;
use strict;
use warnings;
our $VERSION = '2.0';
use Web::DOM::Internal;
use Web::DOM::TypeError;
use Web::DOM::Exception;
push our @CARP_NOT, qw(Web::DOM::TypeError Web::DOM::Exception);

our @EXPORT;
*import = \&Web::DOM::Internal::import;

sub ANY_TYPE                       () { 0 }
sub NUMBER_TYPE                    () { 1 }
sub STRING_TYPE                    () { 2 }
sub BOOLEAN_TYPE                   () { 3 }
sub UNORDERED_NODE_ITERATOR_TYPE   () { 4 }
sub ORDERED_NODE_ITERATOR_TYPE     () { 5 }
sub UNORDERED_NODE_SNAPSHOT_TYPE   () { 6 }
sub ORDERED_NODE_SNAPSHOT_TYPE     () { 7 }
sub ANY_UNORDERED_NODE_TYPE        () { 8 }
sub FIRST_ORDERED_NODE_TYPE        () { 9 }

push @EXPORT, qw(ANY_TYPE NUMBER_TYPE STRING_TYPE BOOLEAN_TYPE
                 UNORDERED_NODE_ITERATOR_TYPE ORDERED_NODE_ITERATOR_TYPE
                 UNORDERED_NODE_SNAPSHOT_TYPE ORDERED_NODE_SNAPSHOT_TYPE
                 ANY_UNORDERED_NODE_TYPE FIRST_ORDERED_NODE_TYPE);

sub result_type ($) {
  return $_[0]->{result_type};
} # result_type

sub boolean_value ($) {
  _throw Web::DOM::TypeError
      'The result is not compatible with the specified type'
          unless $_[0]->{result_type} == BOOLEAN_TYPE;
  return $_[0]->{result}->{value};
} # boolean_value

sub number_value ($) {
  _throw Web::DOM::TypeError
      'The result is not compatible with the specified type'
          unless $_[0]->{result_type} == NUMBER_TYPE;
  return $_[0]->{result}->{value};
} # number_value

sub string_value ($) {
  _throw Web::DOM::TypeError
      'The result is not compatible with the specified type'
          unless $_[0]->{result_type} == STRING_TYPE;
  return $_[0]->{result}->{value};
} # string_value

sub single_node_value ($) {
  _throw Web::DOM::TypeError
      'The result is not compatible with the specified type'
          unless $_[0]->{result_type} == ANY_UNORDERED_NODE_TYPE or
                 $_[0]->{result_type} == FIRST_ORDERED_NODE_TYPE;
  return $_[0]->{result}->{value}->[0]; # or undef
} # single_node_value

sub snapshot_length ($) {
  _throw Web::DOM::TypeError
      'The result is not compatible with the specified type'
          unless $_[0]->{result_type} == UNORDERED_NODE_SNAPSHOT_TYPE or
                 $_[0]->{result_type} == ORDERED_NODE_SNAPSHOT_TYPE;
  return scalar @{$_[0]->{result}->{value}};
} # snapshot_length

sub invalid_iterator_state ($) {
  return not $_[0]->{revision} == ${$_[0]->{current_revision_ref}};
} # invalid_iterator_state

sub iterate_next ($) {
  _throw Web::DOM::TypeError
      'The result is not compatible with the specified type'
          unless $_[0]->{result_type} == UNORDERED_NODE_ITERATOR_TYPE or
                 $_[0]->{result_type} == ORDERED_NODE_ITERATOR_TYPE;

  _throw Web::DOM::Exception 'InvalidStateError',
      'This object is invalid' if $_[0]->invalid_iterator_state;

  return $_[0]->{result}->{value}->[$_[0]->{index}++];
} # iterate_next

sub snapshot_item ($$) {
  # WebIDL: unsigned long
  my $n = $_[1] % 2**32;
  return undef if $n >= 2**31;

  _throw Web::DOM::TypeError
      'The result is not compatible with the specified type'
          unless $_[0]->{result_type} == UNORDERED_NODE_SNAPSHOT_TYPE or
                 $_[0]->{result_type} == ORDERED_NODE_SNAPSHOT_TYPE;

  return $_[0]->{result}->{value}->[$n]; # or undef
} # snapshot_item

sub DESTROY ($) {
  {
    local $@;
    eval { die };
    warn "Potential memory leak detected" if $@ =~ /during global destruction/;
  }
} # DESTROY

1;

=head1 LICENSE

Copyright 2013-2014 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
