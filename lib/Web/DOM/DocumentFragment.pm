package Web::DOM::DocumentFragment;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;
use Web::DOM::ParentNode;
push our @ISA, qw(Web::DOM::ParentNode Web::DOM::Node);

# XXX constructor

# XXX ancestor

sub node_name ($) {
  return '#document-fragment';
} # node_name

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
