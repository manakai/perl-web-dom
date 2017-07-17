package Web::DOM::Error;
use strict;
use warnings;
no warnings 'utf8';
our $VERSION = '2.0';
use Carp;

$Web::DOM::Error::L1ObjectClass->{(__PACKAGE__)} = 1;

use overload
    '""' => 'stringify', bool => sub { 1 },
    cmp => sub {
      carp "Use of uninitialized value in string comparison (cmp)"
          unless defined $_[1];
      overload::StrVal ($_[0]) cmp overload::StrVal ($_[1])
    },
    fallback => 1;

sub is_error ($$) {
  return $Web::DOM::Error::L1ObjectClass->{ref $_[1]};
} # is_error

sub new ($$) {
  my $self = bless {name => 'Error',
                    message => defined $_[1] ? ''.$_[1] : ''}, $_[0];
  $self->_set_stacktrace;
  return $self;
} # new

sub _set_stacktrace ($) {
  my $self = $_[0];
  if (Carp::shortmess =~ /at (.+) line ([0-9]+)\.?$/) {
    $self->{file_name} = $1;
    $self->{line_number} = $2;
  }
  # XXX stack
} # _set_stacktrace

sub wrap ($$) {
  return $_[1] if $_[0]->is_error ($_[1]);
  return $_[0]->new (
    (defined $_[1] && length $_[1]) ? $_[1] : "Something's wrong"
  );
} # wrap

sub name ($) { $_[0]->{name} }
sub file_name ($) { $_[0]->{file_name} }
sub line_number ($) { $_[0]->{line_number} || 0 }
sub message ($) { $_[0]->{message} }

sub stringify ($) {
  my $self = $_[0];
  my $name = $self->name;
  my $msg = $self->message;
  if (length $msg) {
    $msg = $name . ': ' . $msg if length $name;
  } else {
    $msg = $name;
  }
  my $fn = $self->file_name;
  return sprintf "%s at %s line %d.\n",
      $msg, defined $fn ? $fn : '(unknown)', $self->line_number || 0;
} # stringify

1;

=head1 LICENSE

Copyright 2012-2017 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
