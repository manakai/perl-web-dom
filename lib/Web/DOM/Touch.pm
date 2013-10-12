package Web::DOM::Touch;
use strict;
use warnings;
our $VERSION = '1.0';

sub identifier ($) { $_[0]->{identifier} }
sub target ($) { $_[0]->{target} }
sub screen_x ($) { $_[0]->{screen_x} }
sub screen_y ($) { $_[0]->{screen_y} }
sub client_x ($) { $_[0]->{client_x} }
sub client_y ($) { $_[0]->{client_y} }
sub page_x ($) { $_[0]->{page_x} }
sub page_y ($) { $_[0]->{page_y} }

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
