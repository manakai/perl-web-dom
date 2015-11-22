package Web::DOM::TokenList;
use strict;
use warnings;
our $VERSION = '3.0';
use Web::DOM::Exception;
use Carp;
push our @CARP_NOT, qw(Web::DOM::Exception Web::DOM::StringArray);

use overload
    '""' => sub {
      return ((tied @{$_[0]})->serialize);
    },
    bool => sub { 1 },
    cmp => sub {
      carp "Use of uninitialized value in string comparison (cmp)"
          unless defined $_[1];
      overload::StrVal ($_[0]) cmp overload::StrVal ($_[1]);
    },
    fallback => 1;

sub length ($) {
  return scalar @{$_[0]};
} # length

sub item ($$) {
  # WebIDL: unsigned long
  my $n = $_[1] % 2**32;
  return undef if $n >= 2**31;
  return $_[0]->[$n]; # or undef
} # item

# XXX $tokens->{$token} ?

sub contains ($$) {
  my $token = ''.$_[1];

  if ($token eq '') {
    # 1.
    _throw Web::DOM::Exception 'SyntaxError',
        'The token cannot be the empty string';
  } elsif ($token =~ /[\x09\x0A\x0C\x0D\x20]/) {
    # 2.
    _throw Web::DOM::Exception 'InvalidCharacterError',
        'The token cannot contain any ASCII white space character';
  }

  # 3.
  return defined [grep { $_ eq $token } @{$_[0]}]->[0];
} # contains

sub add ($;@) {
  my %found = map { $_ => 1 } @{$_[0]};
  return ((tied @{+shift})->append (grep { not $found{$_}++ } @_));
} # add

sub remove ($;@) {
  my $self = shift;
  my @token = map { ''.$_ } @_;
  for my $token (@token) {
    if ($token eq '') {
      # 1.
      _throw Web::DOM::Exception 'SyntaxError',
          'The token cannot be the empty string';
    } elsif ($token =~ /[\x09\x0A\x0C\x0D\x20]/) {
      # 2.
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The token cannot contain any ASCII white space character';
    }
  }
  my %token = map { $_ => 1 } @token;
  (tied @$self)->replace_by_bare (grep { not $token{$_} } @$self);
  return;
} # remove

sub toggle ($$;$) {
  my $self = $_[0];
  my $token = ''.$_[1];
  my $force = @_ > 2 ? !!$_[2] : undef;

  if ($token eq '') {
    # 1.
    _throw Web::DOM::Exception 'SyntaxError',
        'The token cannot be the empty string';
  } elsif ($token =~ /[\x09\x0A\x0C\x0D\x20]/) {
    # 2.
    _throw Web::DOM::Exception 'InvalidCharacterError',
        'The token cannot contain any ASCII white space character';
  }

  my $has_token = defined [grep { $_ eq $token } @$self]->[0];
  if ($has_token and not $force) {
    # 3.1.
    (tied @$self)->replace_by_bare (grep { $_ ne $token } @$self);
    return 0;
  }

  if ($has_token and $force) {
    # 3.2.
    return 1;
  }

  if (defined $force and not $force) {
    # 4.1.
    return 0;
  }

  # 4.2.
  return 0 unless (tied @{$_[0]})->validate ($token);

  # 4.3.
  (tied @$self)->replace_by_bare (@$self, $token);
  return 1;
} # toggle

sub DESTROY ($) {
  {
    local $@;
    eval { die };
    warn "Potential memory leak detected" if $@ =~ /during global destruction/;
  }
} # DESTROY

1;

=head1 LICENSE

Copyright 2013-2015 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
