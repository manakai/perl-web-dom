package Web::DOM::Error;
use strict;
use warnings;
no warnings 'utf8';
our $VERSION = '1.0';
use Carp;

use overload
    '""' => \&_stringify, bool => sub { 1 },
    cmp => sub {
      carp "Use of uninitialized value in string comparison (cmp)"
          unless defined $_[1];
      overload::StrVal ($_[0]) cmp overload::StrVal ($_[1])
    },
    fallback => 1;

sub name ($) { 'Error' }
sub file_name ($) { $_[0]->{file_name} }
sub line_number ($) { $_[0]->{line_number} || 0 }

sub message ($) {
  return defined $_[0]->{message} && length $_[0]->{message}
      ? $_[0]->{message} : $_[0]->name;
} # message

sub _stringify ($) {
  my $fn = $_[0]->file_name;
  return sprintf "%s at %s line %d.\n",
      $_[0]->message, defined $fn ? $fn : '(unknown)', $_[0]->line_number;
} # _stringify

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
