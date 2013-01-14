package Web::DOM::SettableTokenList;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::TokenList;
push our @ISA, qw(Web::DOM::TokenList);

sub value ($;$) {
  if (@_ > 1) {
    (tied @{$_[0]})->replace_by_bare (grep { length $_ }
                                      split /[\x09\x0A\x0C\x0D\x20]+/, $_[1]);
  }
  return ''.$_[0];
} # value

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

