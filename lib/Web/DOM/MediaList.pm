package Web::DOM::MediaList;
use strict;
use warnings;
our $VERSION = '3.0';
use Carp;
use Web::DOM::Internal;

use overload
    '@{}' => sub {
      my $serializer = ${${$_[0]}->[0]}->[0]->css_serializer;
      my $list = [map {
        $serializer->serialize_mq ($_);
      } @{${${$_[0]}->[0]}->[2]->{mqs}}];
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

sub item ($$) {
  my $n = _idl_unsigned_long $_[1];
  return undef if $n >= 2**31; # perl array

  my $mq = ${${$_[0]}->[0]}->[2]->{mqs}->[$n];
  return undef if not defined $mq;
  my $serializer = ${${$_[0]}->[0]}->[0]->css_serializer;
  return $serializer->serialize_mq ($mq);
} # item

sub media_text ($;$) {
  if (@_ > 1) {
    my $parser = ${${$_[0]}->[0]}->[0]->css_parser;
    $parser->init_parser;
    ${${$_[0]}->[0]}->[2]->{mqs} = $parser->parse_char_string_as_mq_list
        (defined $_[1] ? ''.$_[1] : '');
    # XXX notify the change
  }
  return unless defined wantarray;

  my $serializer = ${${$_[0]}->[0]}->[0]->css_serializer;
  return $serializer->serialize_mq_list (${${$_[0]}->[0]}->[2]->{mqs});
} # media_text

sub append_medium ($$) {
  my $parser = ${${$_[0]}->[0]}->[0]->css_parser;
  $parser->init_parser;
  my $parsed = $parser->parse_char_string_as_mq (''.$_[1]);
  return unless defined $parsed;

  my $serializer = ${${$_[0]}->[0]}->[0]->css_serializer;
  my $serialized = $serializer->serialize_mq ($parsed);
  for (@{${${$_[0]}->[0]}->[2]->{mqs}}) {
    if ($serializer->serialize_mq ($_) eq $serialized) {
      return;
    }
  }

  push @{${${$_[0]}->[0]}->[2]->{mqs}}, $parsed;
  # XXX notification
  return;
} # append_medium

sub delete_medium ($$) {
  my $parser = ${${$_[0]}->[0]}->[0]->css_parser;
  $parser->init_parser;
  my $parsed = $parser->parse_char_string_as_mq (''.$_[1]);
  return unless defined $parsed;

  my $serializer = ${${$_[0]}->[0]}->[0]->css_serializer;
  my $serialized = $serializer->serialize_mq ($parsed);
  @{${${$_[0]}->[0]}->[2]->{mqs}} = grep {
    not $serializer->serialize_mq ($_) eq $serialized;
  } @{${${$_[0]}->[0]}->[2]->{mqs}};
  # XXX notification
  return;
} # delete_medium

1;

=head1 LICENSE

Copyright 2013-2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

