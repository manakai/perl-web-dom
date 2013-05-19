package Web::DOM::NodeIterator;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::NodeFilter;

push our @CARP_NOT, qw(Web::DOM::NodeFilter);

sub root ($) {
  return $_[0]->{root};
} # root

sub reference_node ($) {
  return $_[0]->{reference_node}; # or undef
} # reference_node

sub pointer_before_reference_node ($) {
  return $_[0]->{pointer_before_reference_node}; # or false
} # pointer_before_reference_node

sub expand_entity_references ($) { 0 }

sub what_to_show ($) {
  return $_[0]->{what_to_show};
} # what_to_show

sub filter ($) {
  return $_[0]->{filter}; # or undef
} # filter

sub _traverse ($$) {
  # 1.-2.
  my $node = $_[0]->{reference_node};
  my $before_node = $_[0]->{pointer_before_reference_node};

  # 3.
  {
    # 1.
    if ($_[1]) { # next
      unless ($before_node) {
        my $col = $_[0]->{collection};
        my $found;
        my $new_node;
        for (@$col) {
          if ($_ eq $node) {
            $found = 1;
          } elsif ($found) {
            $new_node = $_;
            last;
          }
        }
        return undef unless defined $new_node;
        $node = $new_node;
      } else {
        $before_node = 0;
      }
    } else { # previous
      if ($before_node) {
        my $col = $_[0]->{collection};
        my $new_node;
        for (@$col) {
          if ($_ eq $node) {
            last;
          } else {
            $new_node = $_;
          }
        }
        return undef unless defined $new_node;
        $node = $new_node;
      } else {
        $before_node = 1;
      }
    }

    # 2.
    my $result = $_[0]->Web::DOM::NodeFilter::_filter ($node);

    # 3.
    if ($result == FILTER_ACCEPT) {
      last;
    } else {
      redo;
    }
  } # 3.

  # 4.
  $_[0]->{pointer_before_reference_node} = $before_node;
  return $_[0]->{reference_node} = $node;
} # _traverse

sub next_node ($) {
  return $_[0]->_traverse ('next');
} # next_node

sub previous_node ($) {
  return $_[0]->_traverse (not 'next');
} # previous_node

sub detach ($) {
  return undef;
} # detach

sub _nodes_removed ($$$) {
  my ($self, $old_nodes, $removed_ids) = @_;

  # 1.
  my $removed_id;
  my $ref = $self->{reference_node} or return;
  if ($removed_ids->{$$ref->[1]}) {
    $removed_id = $$ref->[1];
  } else {
    my $parent = $ref->parent_node;
    while ($parent) {
      if ($removed_ids->{$$parent->[1]}) {
        $removed_id = $$parent->[1];
        last;
      }
      $parent = $parent->parent_node;
    }
    return unless defined $removed_id;
  }

  my $before;
  my $after;
  my $found;
  for (@$old_nodes) {
    if ($$_->[1] == $$ref->[1]) {
      $found = 1;
    } elsif ($removed_ids->{$$_->[1]}) {
      #
    } else {
      if ($found) {
        $after = $_;
        last;
      } else {
        $before = $_;
      }
    }
  }
  ## $before can't be undef here.

  # 2.
  unless ($self->{pointer_before_reference_node}) {
    $self->{reference_node} = $before;
    return;
  }

  # 3.
  if ($self->{pointer_before_reference_node} and defined $after) {
    $self->{reference_node} = $after;
    return;
  }

  # 4.
  $self->{reference_node} = $before;
  delete $self->{pointer_before_reference_node};
} # _nodes_removed

sub DESTROY ($) {
  ${$_[0]->{root}}->[0]->destroy_iterator ($_[0]);
} # DESTROY

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
