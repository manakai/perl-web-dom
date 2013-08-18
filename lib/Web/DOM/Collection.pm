package Web::DOM::Collection;
use strict;
use warnings;
our $VERSION = '1.0';
use Carp;

## Collection - superclass of |Web::DOM::NodeList|,
## |Web::DOM::NamedNodeMap|, |Web::DOM::HTMLCollection|, and
## |Web::DOM::CSSRuleList|.

use overload
    '@{}' => sub {
      return ${$_[0]}->[2] ||= do {
        my $list = $_[0]->to_a;
        Internals::SvREADONLY (@$list, 1);
        Internals::SvREADONLY ($_, 1) for @$list;
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
      return ref ($_[0]) . '=DOM(' . ${$_[0]}->[0] . ',' . (join $;, map {
        defined $_ ? do {
          s/($;|\x00)/\x00$1/g;
          $_;
        } : '';
      } @{ref ${$_[0]}->[3] ? ${$_[0]}->[3] : [${$_[0]}->[3]]}) . ')';
    },
    bool => sub { 1 },
    cmp => sub {
      carp "Use of uninitialized value in string comparison (cmp)"
          unless defined $_[1];
      overload::StrVal ($_[0]) cmp overload::StrVal ($_[1])
    },
    fallback => 1;

sub item ($$) {
  # WebIDL: unsigned long
  my $n = $_[1] % 2**32;
  return undef if $n >= 2**31;
  return $_[0]->[$n]; # or undef
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

# XXX Should the result of this method cached?
sub to_list ($) {
  my $node = ${$_[0]}->[0];
  my $int = $$node->[0];
  return (map { $int->node ($_) } (${$_[0]}->[1]->($node)));
} # to_list

1;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
