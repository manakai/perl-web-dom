package Web::DOM::MediaList;
use strict;
use warnings;
our $VERSION = '1.0';
use Carp;
use Web::CSS::MediaQueries::Parser;
use Web::CSS::MediaQueries::Serializer;

use overload
    '@{}' => sub {
      my $se = Web::CSS::MediaQueries::Serializer->new;
      my $list = [map { $se->serialize_mq ($_) } @{${${$_[0]}->[0]}->[2]->{mqs}}];
      Internals::SvREADONLY (@$list, 1);
      Internals::SvREADONLY ($_, 1) for @$list;
      return $list;
    },
    '""' => sub {
      return $_[0]->media_text;
    },
    bool => sub { 1 },
    cmp => sub {
      carp "Use of uninitialized value in string comparison (cmp)"
          unless defined $_[1];
      overload::StrVal ($_[0]) cmp overload::StrVal ($_[1])
    },
    fallback => 1;

sub length ($) {
  return scalar @{${${$_[0]}->[0]}->[2]->{mqs}};
} # length

# XXXspec: DOMString?
sub item ($$) {
  # WebIDL: unsigned long
  my $n = $_[1] % 2**32;
  return undef if $n >= 2**31;

  my $mq = ${${$_[0]}->[0]}->[2]->{mqs}->[$n];
  return undef if not defined $mq;
  my $se = Web::CSS::MediaQueries::Serializer->new;
  return $se->serialize_mq ($mq);
} # item

sub media_text ($;$) {
  if (@_ > 1) {
    my $pa = Web::CSS::MediaQueries::Parser->new; # XXX reuse, context
    ${${$_[0]}->[0]}->[2]->{mqs} = $pa->parse_char_string_as_mq_list
        (defined $_[1] ? ''.$_[1] : '');
    # XXX notify the change
  }
  return unless defined wantarray;

  my $se = Web::CSS::MediaQueries::Serializer->new;
  return $se->serialize_mq_list (${${$_[0]}->[0]}->[2]->{mqs});
} # media_text

sub append_medium ($$) {
  my $pa = Web::CSS::MediaQueries::Parser->new; # XXX reuse, context
  my $parsed = $pa->parse_char_string_as_mq (''.$_[1]);
  return unless defined $parsed;

  my $se = Web::CSS::MediaQueries::Serializer->new;
  my $serialized = $se->serialize_mq ($parsed);
  for (@{${${$_[0]}->[0]}->[2]->{mqs}}) {
    if ($se->serialize_mq ($_) eq $serialized) {
      return;
    }
  }

  push @{${${$_[0]}->[0]}->[2]->{mqs}}, $parsed;
  # XXX notification
  return;
} # append_medium

sub delete_medium ($$) {
  my $pa = Web::CSS::MediaQueries::Parser->new; # XXX reuse, context
  my $parsed = $pa->parse_char_string_as_mq (''.$_[1]);
  return unless defined $parsed;

  my $se = Web::CSS::MediaQueries::Serializer->new;
  my $serialized = $se->serialize_mq ($parsed);
  @{${${$_[0]}->[0]}->[2]->{mqs}} = grep {
    not $se->serialize_mq ($_) eq $serialized;
  } @{${${$_[0]}->[0]}->[2]->{mqs}};
  # XXX notification
  return;
} # delete_medium

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

