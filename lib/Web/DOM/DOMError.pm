package Web::DOM::DOMError;
use strict;
use warnings;
our $VERSION = '1.0';

sub new ($$;$) {
  return bless {name => ''.$_[1],
                message => defined $_[2] ? ''.$_[2] : ''}, $_[0];
} # new

sub name ($) {
  return $_[0]->{name};
} # name

sub message ($) {
  return $_[0]->{message};
} # message

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
