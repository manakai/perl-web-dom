package Web::DOM::NodeFilter;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Internal;
use Web::DOM::Exception;

our @CARP_NOT = qw(Web::DOM::Exception);

our @EXPORT;
*import = \&Web::DOM::Internal::import;

push @EXPORT, qw(FILTER_ACCEPT FILTER_REJECT FILTER_SKIP);
sub FILTER_ACCEPT () { 1 }
sub FILTER_REJECT () { 2 }
sub FILTER_SKIP () { 3 }

push @EXPORT, qw(SHOW_ALL SHOW_ELEMENT SHOW_ATTRIBUTE SHOW_TEXT
                 SHOW_CDATA_SECTION SHOW_ENTITY_REFERENCE SHOW_ENTITY
                 SHOW_PROCESSING_INSTRUCTION SHOW_COMMENT SHOW_DOCUMENT
                 SHOW_DOCUMENT_TYPE SHOW_DOCUMENT_FRAGMENT SHOW_NOTATION);
sub SHOW_ALL () { 0xFFFFFFFF }
sub SHOW_ELEMENT () { 0x1 }
sub SHOW_ATTRIBUTE () { 0x2 }
sub SHOW_TEXT () { 0x4 }
sub SHOW_CDATA_SECTION () { 0x8 }
sub SHOW_ENTITY_REFERENCE () { 0x10 }
sub SHOW_ENTITY () { 0x20 }
sub SHOW_PROCESSING_INSTRUCTION () { 0x40 }
sub SHOW_COMMENT () { 0x80 }
sub SHOW_DOCUMENT () { 0x100 }
sub SHOW_DOCUMENT_TYPE () { 0x200 }
sub SHOW_DOCUMENT_FRAGMENT () { 0x400 }
sub SHOW_NOTATION () { 0x800 }

## Invoked by Web::DOM::NodeIterator and Web::DOM::TreeWalker.
sub _filter ($$) {
  # 1.
  _throw Web::DOM::Exception 'InvalidStateError', 'Traversaler is active'
      if $_[0]->{active};

  # 2.
  my $n = $_[1]->node_type - 1;

  # 3.
  return FILTER_SKIP unless $_[0]->{what_to_show} & (1 << $n);

  # 4.
  return FILTER_ACCEPT unless $_[0]->{filter};

  # 5., 7.
  local $_[0]->{active} = 1;

  # 6., 8.-9.
  my $value = $_[0]->{filter}->(undef, $_[1]); # rethrow any exception
      ## Argument to the filter is not explicitly defined in the spec...
  return unpack 'S', pack 'S', $value % 2**16;
} # _filter

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
