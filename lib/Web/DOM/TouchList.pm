package Web::DOM::TouchList;
use strict;
use warnings;
our $VERSION = '1.0';

sub length ($) {
  return scalar @{$_[0]};
} # length

sub item ($$) {
  # WebIDL: unsigned long
  my $n = $_[1] % 2**32;
  return undef if $n >= 2**31;
  return $_[0]->[$n]; # or undef
} # item

sub to_a ($) { [@{$_[0]}] }
sub as_list ($) { [@{$_[0]}] }
sub to_list ($) { @{$_[0]} }

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
