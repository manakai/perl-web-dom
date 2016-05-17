package Web::DOM::TokenList;
use strict;
use warnings;
our $VERSION = '6.0';
use Web::DOM::Internal;
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
  my $n = _idl_unsigned_long $_[1];
  return undef if $n >= 2**31; # perl array
  return $_[0]->[$n]; # or undef
} # item

# XXX $tokens->{$token} ?

sub contains ($$) {
  my $token = ''.$_[1];
  return defined [grep { $_ eq $token } @{$_[0]}]->[0];
} # contains

sub add ($;@) {
  my %found = map { $_ => 1 } @{$_[0]};
  ((tied @{+shift})->append (grep { not $found{$_}++ } @_));
  return undef;
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
  (tied @$self)->replace_by_bare (@$self, $token);
  return 1;
} # toggle

sub replace ($$$) {
  my $self = $_[0];
  my $token = ''.$_[1];
  my $new_token = ''.$_[2];

  if ($token eq '' or $new_token eq '') {
    # 1.
    _throw Web::DOM::Exception 'SyntaxError',
        'The token cannot be the empty string';
  } elsif ($token =~ /[\x09\x0A\x0C\x0D\x20]/ or
           $new_token =~ /[\x09\x0A\x0C\x0D\x20]/) {
    # 2.
    _throw Web::DOM::Exception 'InvalidCharacterError',
        'The token cannot contain any ASCII white space character';
  }

  my @new;
  my $replaced = 0;
  for (@$self) {
    if ($_ eq $token) {
      # 4.
      push @new, $new_token;
      $replaced = 1;
    } else {
      push @new, $_;
    }
  }

  # 3.
  return unless $replaced;

  # 5.
  (tied @$self)->replace_by_bare (@new);
  return;
} # replace

sub supports ($$) {
  return !!(tied @{$_[0]})->validate (''.$_[1]);
} # supports

sub value ($;$) {
  if (@_ > 1) {
    (tied @{$_[0]})->replace_by_bare (grep { length $_ }
                                      split /[\x09\x0A\x0C\x0D\x20]+/, $_[1]);
  }
  return ''.$_[0];
} # value

sub DESTROY ($) {
  {
    local $@;
    eval { die };
    warn "Potential memory leak detected" if $@ =~ /during global destruction/;
  }
} # DESTROY

1;

=head1 LICENSE

Copyright 2013-2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
