package Web::DOM::TouchList;
use strict;
use warnings;
our $VERSION = '2.0';
use Web::DOM::Internal;

sub length ($) {
  return scalar @{$_[0]};
} # length

sub item ($$) {
  my $n = _idl_unsigned_long $_[1];
  return undef if $n >= 2**31; # perl array
  return $_[0]->[$n]; # or undef
} # item

sub to_a ($) { [@{$_[0]}] }
sub as_list ($) { [@{$_[0]}] }
sub to_list ($) { @{$_[0]} }

1;

=head1 LICENSE

Copyright 2013-2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
