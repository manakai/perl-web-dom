package Web::DOM::TreeWalker;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::NodeFilter;
use Web::DOM::TypeError;
use Web::DOM::Exception;

our @CARP_NOT = qw(Web::DOM::TypeError Web::DOM::Exception);

sub root ($) {
  return $_[0]->{root};
} # root

sub what_to_show ($) {
  return $_[0]->{what_to_show};
} # what_to_show

sub filter ($) {
  return $_[0]->{filter}; # or undef
} # filter

sub expand_entity_references ($) { 0 }

sub current_node ($;$) {
  if (@_ > 1) {
    _throw Web::DOM::TypeError 'The new value is not a Node'
        unless UNIVERSAL::isa ($_[1], 'Web::DOM::Node');
    $_[0]->{current_node} = $_[1];
  }
  return $_[0]->{current_node};
} # current_node

sub _filter ($$) {
  # 1.
  _throw Web::DOM::Exception 'InvalidStateError', 'TreeWalker is active'
      if $_[0]->{active};

  # 2.
  my $n = $_[1]->node_type - 1;

  # 3.
  return FILTER_SKIP unless $_[0]->{what_to_show} & (1 << $n);

  # 4.
  return FILTER_ACCEPT unless $_[0]->{filter};

  # 5., 7.
  local $_[0]->{active} = 1;

  # 6., 8.-9.
  my $value = $_[0]->{filter}->(undef, $_[1]); # rethrow any exception
      ## Argument to the filter is not explicitly defined in the spec...
  return unpack 'S', pack 'S', $value % 2**16;
} # _filter

sub parent_node ($) {
  # 1.
  my $node = $_[0]->{current_node};

  # 2.
  while (defined $node and $node ne $_[0]->{root}) {
    # 1.
    $node = $node->parent_node;

    # 2.
    if (defined $node and $_[0]->_filter ($node) == FILTER_ACCEPT) { # or throw
      return $_[0]->{current_node} = $node;
    }
  }

  # 3.
  return undef;
} # parent_node

sub _traverse_children ($$) {
  # 1.
  my $node = $_[0]->{current_node};

  # 2.
  $node = $_[1] ? $node->first_child : $node->last_child;

  # 3.
  MAIN: while ($node) {
    # 1.
    my $result = $_[0]->_filter ($node); # or throw

    # 2.
    if ($result == FILTER_ACCEPT) {
      return $_[0]->{current_node} = $node;
    }

    # 3.
    if ($result == FILTER_SKIP) {
      # 1.
      my $child = $_[1] ? $node->first_child : $node->last_child;
      
      # 2.
      if ($child) {
        $node = $child;
        next MAIN;
      }
    }

    # 4.
    while ($node) {
      # 1.
      my $sibling = $_[1] ? $node->next_sibling : $node->previous_sibling;
      
      # 2.
      if ($sibling) {
        $node = $sibling;
        next MAIN;
      }

      # 3.
      my $parent = $node->parent_node;
      if (not $parent or $parent eq $_[0]->{current_node}) {
        # 4.
        return undef;
      } else {
        # 5.
        $node = $parent;
      }
    }
  } # MAIN

  return undef;
} # _traverse_children

sub first_child ($) {
  return $_[0]->_traverse_children ('first');
} # first_child

sub last_child ($) {
  return $_[0]->_traverse_children (not 'first');
} # last_child

sub _traverse_siblings ($$) {
  # 1.
  my $node = $_[0]->{current_node};

  # 2.
  return undef if $node eq $_[0]->{root};
  
  # 3.
  {
    # 1.
    my $sibling = $_[1] ? $node->next_sibling : $node->previous_sibling;

    # 2.
    while ($sibling) {
      # 1.
      $node = $sibling;

      # 2.
      my $result = $_[0]->_filter ($node); # or throw

      # 3.
      if ($result == FILTER_ACCEPT) {
        return $_[0]->{current_node} = $node;
      }

      # 4.
      $sibling = $_[1] ? $node->first_child : $node->last_child;
      
      # 5.
      if ($result == FILTER_REJECT or not $sibling) {
        $sibling = $_[1] ? $node->next_sibling : $node->previous_sibling;
      }
    }

    # 3.
    $node = $node->parent_node;

    # 4.
    return undef if not $node or $node eq $_[0]->{root};

    # 5.
    return undef if $_[0]->_filter ($node) == FILTER_ACCEPT; # or throw

    # 6.
    redo;
  } # 3.
} # _traverse_siblings

sub next_sibling ($) {
  return $_[0]->_traverse_siblings ('next');
} # next_sibling

sub previous_sibling ($) {
  return $_[0]->_traverse_siblings (not 'next');
} # previous_sibling

sub previous_node ($) {
  # 1.
  my $node = $_[0]->{current_node};

  # 2.
  while ($node ne $_[0]->{root}) {
    # 1.
    my $sibling = $node->previous_sibling;
    
    # 2.
    while ($sibling) {
      # 1.
      $node = $sibling;

      # 2.
      my $result = $_[0]->_filter ($node); # or throw

      # 3.
      while ($result != FILTER_REJECT and $node->last_child) {
        $node = $node->last_child;
        $result = $_[0]->_filter ($node); # or throw
      }

      # 4.
      if ($result == FILTER_ACCEPT) {
        return $_[0]->{current_node} = $node;
      }

      # 5.
      $sibling = $node->previous_sibling;
    }

    # 3.
    if ($node eq $_[0]->{root} or not $node->parent_node) {
      return undef;
    }

    # 4.
    $node = $node->parent_node;

    # 5.
    if ($_[0]->_filter ($node) == FILTER_ACCEPT) { # or throw
      return $_[0]->{current_node} = $node;
    }
  }

  # 3.
  return undef;
} # previous_node

sub next_node ($) {
  # 1.
  my $node = $_[0]->{current_node};

  # 2.
  my $result = FILTER_ACCEPT;

  # 3.
  {
    # 1.
    while ($result != FILTER_REJECT and $node->first_child) {
      # 1.
      $node = $node->first_child;

      # 2.
      my $result = $_[0]->_filter ($node); # or throw

      # 3.
      if ($result == FILTER_ACCEPT) {
        return $_[0]->{current_node} = $node;
      }
    }

    # 2.
    FOLLOW: {
      return undef if $node eq $_[0]->{root};
      my $sibling = $node->next_sibling;
      if ($sibling) {
        $node = $sibling;
      } else {
        $node = $node->parent_node;
        return undef if not $node or $node eq $_[0]->{root};
        redo FOLLOW;
      }
      return undef unless $node;
    } # FOLLOW
    ## According to the spec, strictly, $node need to not follow
    ## $_[0]->{root} at this point, but is it really checked by
    ## browsers?

    # 3.
    $result = $_[0]->_filter ($node); # or throw
      
    # 4.
    if ($result == FILTER_ACCEPT) {
      return $_[0]->{current_node} = $node;
    }

    # 5.
    redo;
  } # 3.
} # previous_node

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
