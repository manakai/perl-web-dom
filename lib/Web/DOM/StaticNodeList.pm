package Web::DOM::StaticNodeList;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::NodeList;
push our @ISA, qw(Web::DOM::NodeList);

use overload
    '@{}' => sub {
      return ${$_[0]}->[2] ||= do {
        my $list = $_[0]->to_a;
        Internals::SvREADONLY (@$list, 1);
        Internals::SvREADONLY ($_, 1) for @$list;
        $list;
      };
    },
    fallback => 1;

sub to_list ($) {
  return @{${$_[0]}->[1]};
} # to_list

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
