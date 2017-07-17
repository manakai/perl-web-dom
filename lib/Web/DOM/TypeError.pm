package Web::DOM::TypeError;
use strict;
use warnings;
use Web::DOM::Error;
push our @ISA, qw(Web::DOM::Error);
our $VERSION = '2.0';

sub new ($$) {
  my $self = bless {name => 'TypeError',
                    message => defined $_[1] ? $_[1] : ''}, $_[0];
  $self->_set_stacktrace;
  return $self;
} # new

sub _throw ($$) {
  die $_[0]->new ($_[1]);
} # _throw

1;

=head1 LICENSE

Copyright 2012-2017 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
