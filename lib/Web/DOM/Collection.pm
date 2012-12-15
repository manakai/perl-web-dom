package Web::DOM::Collection;
use strict;
use warnings;
our $VERSION = '1.0';
use Carp;

use overload
    '@{}' => sub {
      return ${$_[0]}->[2] ||= do {
        my $list = $_[0]->to_a;
        Internals::SvREADONLY (@$list, 1);
        $list;
      };
      ## Strictly speaking, $obj->[$index]'s $index has to be
      ## converted to IDL |unsigned long| value before actual |getter|
      ## processing (or the |FETCH| method in Perl |tie| terminology).
      ## However, Perl's builtin convertion of array index, which
      ## clamps the value within the range of 32-bit signed long
      ## <http://qiita.com/items/f479744bed8633338fb5>, makes
      ## WebIDL-specific processing redundant.  (Also note that Perl
      ## can't handle array with length greater than or equal to
      ## 2^31.)
    },
    '""' => sub {
      return ref ($_[0]) . '=DOM(' . ${$_[0]}->[2] . ')';
    },
    bool => sub { 1 },
    cmp => sub {
      carp "Use of uninitialized value in string comparison (cmp)"
          unless defined $_[1];
      overload::StrVal ($_[0]) cmp overload::StrVal ($_[1])
    },
    fallback => 1;

sub item ($$) {
  # unsigned long
  return undef if $_[1] % 2**32 >= 2**31;
  return $_[0]->[$_[1] % 2**32]; # or undef
} # item

sub length ($) {
  return 0+@{$_[0]};
} # length

sub to_a ($) {
  return [$_[0]->to_list];
} # to_a

sub as_list ($) {
  return $_[0]->to_a;
} # as_list

sub to_list ($) {
  die "|to_list| not implemented";
} # to_list

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
