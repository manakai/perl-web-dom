package Web::DOM::HTMLAllCollection;
use strict;
use warnings;
use Web::DOM::HTMLCollection;
push our @ISA, qw(Web::DOM::HTMLCollection);
our $VERSION = '1.0';
use Web::DOM::Internal;

use overload
    bool => sub { 0 },
    '%{}' => sub {
      return ${$_[0]}->[4] ||= do {
        my %data;
        for (reverse $_[0]->to_list) {
          my $name = ($_->namespace_uri || '') eq HTML_NS
              ? $_->get_attribute_ns (undef, 'name') : undef;
          my $id = $_->get_attribute_ns (undef, 'id');
          $data{$name} ||= undef if defined $name;
          $data{$id} ||= undef if defined $id;
          
          undef $name if defined $name and not {
            a => 1, applet => 1, area => 1, embed => 1, form => 1,
            frame => 1, frameset => 1, iframe => 1, img => 1, object => 1,
          }->{$_->local_name};
          undef $name if defined $name and defined $id and $name eq $id;

          push @{$data{$name} ||= []}, $_ if defined $name;
          push @{$data{$id} ||= []}, $_ if defined $id;
        }
        for (keys %data) {
          if (@{$data{$_} or []} == 0) {
            $data{$_} = undef;
          } elsif (@{$data{$_}} == 1) {
            $data{$_} = $data{$_}->[0];
          } else {
            my $name = $_;
            my $filter_ = ${$_[0]}->[1];
            my $filter = sub {
              my $int = ${$_[0]}->[0];
              return grep {
                my $node = $int->node ($_);
                my $id = $node->get_attribute_ns (undef, 'id');
                if (defined $id and $id eq $name) {
                  1;
                } elsif (not {
                  a => 1, applet => 1, area => 1, embed => 1, form => 1,
                  frame => 1, frameset => 1, iframe => 1, img => 1,
                  object => 1,
                }->{$node->local_name}) {
                  0;
                } elsif (not HTML_NS eq ($node->namespace_uri || '')) {
                  0;
                } else {
                  my $n = $node->get_attribute_ns (undef, 'name');
                  defined $n && $n eq $name;
                }
              } $filter_->($_[0]);
            };
            $data{$_} = ${${$_[0]}->[0]}->[0]->collection
                ([@{${$_[0]}->[3]}, 'n', $_], ${$_[0]}->[0], $filter);
          }
        }
        tie my %hash, 'Web::DOM::Internal::ReadOnlyHash', \%data;
        \%hash;
      };
    },
    '&{}' => sub {
      my $self = shift;
      return sub { $self->item (@_) };
    },
    fallback => 1;

sub item ($$) {
  my $index = ''.$_[1];
  if ($index =~ /\A[0-9]+\z/) {
    return $_[0]->SUPER::item ($index);
  } else {
    return $_[0]->named_item ($index);
  }
} # item

sub tags ($$) {
  my $tag_name = ''.$_[1];
  if (${${$_[0]}->[0]}->[0]->{data}->[0]->{is_html}) {
    $tag_name =~ tr/A-Z/a-z/; ## ASCII case-insensitive.
  }
  my $filter_ = ${$_[0]}->[1];
  my $filter = sub {
    my $int = ${$_[0]}->[0];
    return grep {
      ${$int->{data}->[$_]->{namespace_uri} || \''} eq HTML_NS and
      ${$int->{data}->[$_]->{local_name}} eq $tag_name;
    } $filter_->($_[0]);
  };
  return ${${$_[0]}->[0]}->[0]->collection
      ([@{${$_[0]}->[3]}, 't', $tag_name], ${$_[0]}->[0], $filter);
} # tags

1;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut