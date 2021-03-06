package Web::DOM::HTMLAllCollection;
use strict;
use warnings;
use Web::DOM::HTMLCollection;
push our @ISA, qw(Web::DOM::Collection);
our $VERSION = '5.0';
use Web::DOM::Internal;
use Web::DOM::_Defs;

use overload
    bool => sub { 1 },
    '%{}' => sub {
      if (defined ${$_[0]}->[4] and
          ${${$_[0]}->[0]}->[0]->{revision} == ${$_[0]}->[5]) {
        return ${$_[0]}->[4];
      } else {
        return ${$_[0]}->[4] = do {
          my $name_to_elements = {};
          for ($_[0]->to_list) {
            my $id = $_->id;
            push @{$name_to_elements->{$id} ||= []}, $_ if length $id;
            if ($Web::DOM::_Defs->{all_named}
                    ->{$_->namespace_uri || ''}->{$_->local_name}) {
              my $name = $_->get_attribute_ns (undef, 'name');
              push @{$name_to_elements->{$name} ||= []}, $_
                  if defined $name and length $name and not $name eq $id;
            }
          }
          for my $name (keys %$name_to_elements) {
            my $list = $name_to_elements->{$name};
            if (@$list == 1) {
              $name_to_elements->{$name} = $list->[0];
            } else {
              my $filter_ = ${$_[0]}->[1];
              my $filter = sub {
                my $int = ${$_[0]}->[0];
                return grep {
                  my $node = $int->node ($_);
                  my $id = $node->id;
                  if (length $id and $id eq $name) {
                    1;
                  } elsif ($Web::DOM::_Defs->{all_named}
                           ->{$node->namespace_uri || ''}->{$node->local_name}) {
                    my $n = $node->get_attribute_ns (undef, 'name');
                    if (defined $n and length $n and $n eq $name) {
                      1;
                    } else {
                      0;
                    }
                  } else {
                    0;
                  }
                } $filter_->($_[0]);
              };
              $name_to_elements->{$name} = ${${$_[0]}->[0]}->[0]->collection
                  ([@{${$_[0]}->[3]}, 'n', $_], ${$_[0]}->[0], $filter);
            }
          } # $name
          tie my %hash, 'Web::DOM::Internal::ReadOnlyHash', $name_to_elements;
          delete ${$_[0]}->[2];
          ${$_[0]}->[5] = ${${$_[0]}->[0]}->[0]->{revision};
          \%hash;
        };
      }
    },
    fallback => 1;

sub item ($;$) {
  return undef unless defined $_[1];
  my $index = ''.$_[1];
  my $i = '' . do { no warnings; 0+$index };
  if ($index eq $i) {
    return $_[0]->SUPER::item ($index);
  } else {
    return $_[0]->named_item ($index);
  }
} # item

sub named_item ($$) {
  return $_[0]->{$_[1]};
} # named_item

1;

=head1 LICENSE

Copyright 2012-2015 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
