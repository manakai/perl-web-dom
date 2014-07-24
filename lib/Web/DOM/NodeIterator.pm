package Web::DOM::NodeIterator;
use strict;
use warnings;
our $VERSION = '2.0';
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

sub _traverse ($$;$) {
  # $self, $direction_is_next, $for_remove

  ## 1.-2.
  my $node = $_[0]->{reference_node};
  my $before_node = $_[0]->{pointer_before_reference_node};

  ## 3.
  my $root = $_[0]->{root};
  {
    ## 3.1.
    if ($_[1]) { # next
      unless ($before_node) {
        my $new_node = $_[2] ? undef : $node->first_child;
        if (not defined $new_node) {
          NEXT: {
            $new_node = $node->next_sibling;
            if (not defined $new_node) {
              $new_node = $node->parent_node;
              if (not defined $new_node or $new_node eq $root) {
                ## $node is the root node of the iterator.
                return undef;
              } else {
                $node = $new_node;
                redo NEXT;
              }
            }
          } # NEXT
        }
        $node = $new_node;
      } else {
        $before_node = 0;
      }
    } else { # previous
      if ($before_node) {
        return undef if $node eq $root;
        my $new_node = $node->previous_sibling;
        if (defined $new_node) {
          PREV: {
            $node = $new_node;
            $new_node = $node->last_child;
            if (defined $new_node) {
              redo PREV;
            }
          }
        } else {
          $new_node = $node->parent_node;
          return undef if not defined $new_node;
          $node = $new_node;
        }
      } else {
        $before_node = 1;
      }
    }

    ## 3.2.
    my $result = $_[2] ? FILTER_ACCEPT : $_[0]->Web::DOM::NodeFilter::_filter ($node); # or throw

    ## 3.3.
    if ($result == FILTER_ACCEPT) {
      last;
    } else {
      redo;
    }
  } # 3.

  ## 4.
  $_[0]->{pointer_before_reference_node} = $before_node;
  $$node->[0]->change_iterator_reference_node ($_[0], $node);
  return $node;
} # _traverse

sub next_node ($) {
  return $_[0]->_traverse ('next'); # or throw
} # next_node

sub previous_node ($) {
  return $_[0]->_traverse (not 'next'); # or throw
} # previous_node

sub detach ($) {
  return undef;
} # detach

1;

=head1 LICENSE

Copyright 2013-2014 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
