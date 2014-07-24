package Web::DOM::HTMLCollection;
use strict;
use warnings;
use Web::DOM::Collection;
push our @ISA, qw(Web::DOM::Collection);
our $VERSION = '1.0';
use Web::DOM::Internal;

use overload
    '%{}' => sub {
      if (defined ${$_[0]}->[4] and
          ${${$_[0]}->[0]}->[0]->{revision} == ${$_[0]}->[5]) {
        return ${$_[0]}->[4];
      } else {
        return ${$_[0]}->[4] = do {
          my %data = map {
            my $name = ($_->namespace_uri || '') eq HTML_NS
                ? $_->get_attribute_ns (undef, 'name') : undef;
            my $id = $_->get_attribute_ns (undef, 'id');
            (
             (defined $name && length $name ? ($name => $_) : ()),
             (defined $id && length $id ? ($id => $_) : ()),
            );
          } reverse $_[0]->to_list;
          tie my %hash, 'Web::DOM::Internal::ReadOnlyHash', \%data;
          delete ${$_[0]}->[2];
          ${$_[0]}->[5] = ${${$_[0]}->[0]}->[0]->{revision};
          \%hash;
        };
      }
    },
    fallback => 1;

sub named_item ($$) {
  return $_[0]->{$_[1]};
} # named_item

1;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
