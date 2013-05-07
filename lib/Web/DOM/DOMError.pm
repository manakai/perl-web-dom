package Web::DOM::DOMError;
use strict;
use warnings;
our $VERSION = '1.0';

sub new ($$) {
  return bless {name => ''.$_[1]}, $_[0];
} # new

sub name ($) {
  return $_[0]->{name};
} # name

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
