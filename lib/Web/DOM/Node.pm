package Web::DOM::Node;
use strict;
use warnings;
no warnings 'utf8';
our $VERSION = '1.0';
use Web::DOM::TypeError;
use Web::DOM::Exception;
use Carp;
our @CARP_NOT = qw(Web::DOM::Exception Web::DOM::TypeError);
use Exporter::Lite;
use Char::Class::XML qw(
  InXMLNameChar InXMLNameStartChar
  InXMLNCNameChar InXMLNCNameStartChar
);

use overload
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

our @EXPORT = qw(
  ELEMENT_NODE ATTRIBUTE_NODE TEXT_NODE CDATA_SECTION_NODE 
  ENTITY_REFERENCE_NODE ENTITY_NODE PROCESSING_INSTRUCTION_NODE
  COMMENT_NODE DOCUMENT_NODE DOCUMENT_TYPE_NODE DOCUMENT_FRAGMENT_NODE
  NOTATION_NODE ELEMENT_TYPE_DEFINITION_NODE ATTRIBUTE_DEFINITION_NODE
  XPATH_NAMESPACE_NODE
);

sub ELEMENT_NODE () { 1 }
sub ATTRIBUTE_NODE () { 2 }
sub TEXT_NODE () { 3 }
sub CDATA_SECTION_NODE () { 4 }
sub ENTITY_REFERENCE_NODE () { 5 }
sub ENTITY_NODE () { 6 }
sub PROCESSING_INSTRUCTION_NODE () { 7 }
sub COMMENT_NODE () { 8 }
sub DOCUMENT_NODE () { 9 }
sub DOCUMENT_TYPE_NODE () { 10 }
sub DOCUMENT_FRAGMENT_NODE () { 11 }
sub NOTATION_NODE () { 12 }
sub XPATH_NAMESPACE_NODE () { 13 }
sub ELEMENT_TYPE_DEFINITION_NODE () { 81001 }
sub ATTRIBUTE_DEFINITION_NODE () { 81002 }

sub node_type ($) {
  return ${$_[0]}->[2]->{node_type};
} # node_type

sub node_name ($) {
  die ref ($_[0]) . "::node_name not implemented";
} # node_name

sub namespace_uri ($) {
  return ${${$_[0]}->[2]->{namespace_uri} || \undef};
} # namespace_uri

sub prefix ($;$) {
  if (@_ > 1) {
    # 1.
    my $prefix = $_[1];

    # 2.
    unless (${$_[0]}->[2]->{namespace_uri}) {
      _throw Web::DOM::Exception 'NamespaceError',
          'Namespace prefix can only be specified for namespaced node';
    }

    if (defined $prefix and length $prefix) {
      # 4.1.
      unless ($prefix =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
        _throw Web::DOM::Exception 'InvalidCharacterError',
            'The prefix is not an XML Name';
      }

      # 4.2.
      unless ($prefix =~ /\A\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*\z/) {
        _throw Web::DOM::Exception 'NamespaceError',
            'The prefix is not an XML NCName';
      }

      # 5.
      ${$_[0]}->[2]->{prefix} = Web::DOM::Internal->text ($prefix);
    } else {
      # 3., 5.
      delete ${$_[0]}->[2]->{prefix};
    }
  } # setter
  return ${${$_[0]}->[2]->{prefix} || \undef};
} # prefix

*local_name = \&manakai_local_name;

sub manakai_local_name ($) {
  return ${${$_[0]}->[2]->{local_name} || \undef};
} # manakai_local_name

# XXX NodeExodus

# XXX baseURI

sub owner_document ($) {
  return ${$_[0]}->[0]->node (0);
} # owner_document

sub attributes ($) {
  return undef;
} # attributes

sub has_attributes ($) {
  return 0;
} # has_attributes

sub parent_node ($) {
  my $self = shift;
  my $pid = $$self->[2]->{parent_node};
  return undef unless defined $pid;
  return $$self->[0]->node ($pid);
} # parent_node

sub parent_element ($) {
  my $self = shift;
  my $pid = $$self->[2]->{parent_node};
  return undef unless defined $pid;
  my $node = $$self->[0]->node ($pid);
  return undef unless $node->node_type == ELEMENT_NODE;
  return $node;
} # parent_element

sub child_nodes ($) {
  my $node = $_[0];
  return $$node->[0]->collection ('child_nodes', $node, sub {
    my $node = $_[0];
    return @{$$node->[0]->{data}->[$$node->[1]]->{child_nodes} or []};
  });
} # child_nodes

sub has_child_nodes ($) {
  return !!@{${$_[0]}->[2]->{child_nodes} or []};
} # has_child_nodes

sub first_child ($) {
  my $self = shift;
  my $id = $$self->[2]->{child_nodes}->[0];
  return undef unless defined $id;
  return $$self->[0]->node ($id);
} # first_child

sub last_child ($) {
  my $self = shift;
  my $id = $$self->[2]->{child_nodes}->[-1];
  return undef unless defined $id;
  return $$self->[0]->node ($id);
} # last_child

sub previous_sibling ($) {
  my $self = shift;
  my $parent_id = $$self->[2]->{parent_node};
  return undef unless defined $parent_id;
  my $self_id = $$self->[1];
  my $children = $$self->[0]->{data}->[$parent_id]->{child_nodes};
  for (0..$#$children) {
    if ($children->[$_] == $self_id) {
      if ($_ == 0) {
        return undef;
      } else {
        return $$self->[0]->node ($children->[$_ - 1]);
      }
    }
  }
  die "This node is not a child of the parent node";
} # previous_sibling

sub next_sibling ($) {
  my $self = shift;
  my $parent_id = $$self->[2]->{parent_node};
  return undef unless defined $parent_id;
  my $self_id = $$self->[1];
  my $children = $$self->[0]->{data}->[$parent_id]->{child_nodes};
  for (0..$#$children) {
    if ($children->[$_] == $self_id) {
      if ($_ == $#$children) {
        return undef;
      } else {
        return $$self->[0]->node ($children->[$_ + 1]);
      }
    }
  }
  die "This node is not a child of the parent node";
} # next_sibling

sub append_child ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The first argument is not a Node';
  }

  # append
  {
    # pre-insert
    return $_[0]->_pre_insert ($_[1]);
  }
} # append_child

sub insert_before ($$$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The first argument is not a Node';
  }
  if (defined $_[2] and not UNIVERSAL::isa ($_[2], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The second argument is not a Node';
  }

  return $_[0]->_pre_insert ($_[1], $_[2]);
} # insert_before

sub replace_child ($$$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The first argument is not a Node';
  }
  unless (UNIVERSAL::isa ($_[2], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The second argument is not a Node';
  }

  return $_[0]->_pre_insert ($_[1], undef, $_[2]);
} # replace_child

sub _pre_insert ($$;$$) {
  my ($parent, $node, $child, $old_child) = @_;

  # pre-insert / replace
  my $parent_nt = $$parent->[2]->{node_type};

  # 1.
  unless ($parent_nt == ELEMENT_NODE or
          $parent_nt == DOCUMENT_FRAGMENT_NODE or
          $parent_nt == DOCUMENT_NODE) {
    _throw Web::DOM::Exception 'HierarchyRequestError',
        'The parent node cannot have a child';
  }

  # 2.
  if ($$parent->[0] eq $$node->[0]) {
    my $id = $$parent->[1];
    while (defined $id) {
      if ($id == $$node->[1]) {
        _throw Web::DOM::Exception 'HierarchyRequestError',
            'The child is an inclusive ancestors of the parent';
      }
      $id = $$parent->[0]->{data}->[$id]->{parent_node};
    }
  }
  
  # 3.
  if (defined $child) {
    if ($$parent->[0] eq $$child->[0]) {
      my $rc_parent = $$child->[2]->{parent_node};
      if (not defined $rc_parent or $rc_parent != $$parent->[1]) {
        _throw Web::DOM::Exception 'NotFoundError',
            'The reference child is not a child of the parent node';
      }
    } else {
      _throw Web::DOM::Exception 'NotFoundError',
          'The reference child is not a child of the parent node';
    }
  }

  my $node_nt = $$node->[2]->{node_type};
  if ($node_nt == TEXT_NODE) {
    # 5.
    if ($parent_nt == DOCUMENT_NODE) {
      _throw Web::DOM::Exception 'HierarchyRequestError',
          'Document node cannot contain this kind of node';
    }
  } elsif ($node_nt == DOCUMENT_TYPE_NODE) {
    # 5.
    if ($parent_nt != DOCUMENT_NODE) {
      _throw Web::DOM::Exception 'HierarchyRequestError',
          'Document type cannot be contained by this kind of node';
    }
  } elsif ($node_nt == DOCUMENT_FRAGMENT_NODE or
           $node_nt == ELEMENT_NODE or
           $node_nt == PROCESSING_INSTRUCTION_NODE or
           $node_nt == COMMENT_NODE) {
    #
  } else {
    # 4.
    _throw Web::DOM::Exception 'HierarchyRequestError',
        'The parent cannot contain this kind of node';
  }

  # 6.
  if ($parent_nt == DOCUMENT_NODE) {
    if ($node_nt == ELEMENT_NODE) {
      # 6.2.
      if (defined $old_child) { # replace
        my $has_child;
        for (@{$$parent->[2]->{child_nodes}}) {
          my $data = $$parent->[0]->{data}->[$_];
          if ($$old_child->[0] eq $$parent->[0] and $$old_child->[1] == $_) {
            $has_child = 1;
          } elsif ($data->{node_type} == ELEMENT_NODE) {
            _throw Web::DOM::Exception 'HierarchyRequestError',
                'Document node cannot have two element children';
          } elsif ($has_child and $data->{node_type} == DOCUMENT_TYPE_NODE) {
            _throw Web::DOM::Exception 'HierarchyRequestError',
                'Element cannot precede the document type';
          }
        }
      } else { # pre-insert
        my $has_child;
        for (@{$$parent->[2]->{child_nodes}}) {
          my $data = $$parent->[0]->{data}->[$_];
          if ($data->{node_type} == ELEMENT_NODE) {
            _throw Web::DOM::Exception 'HierarchyRequestError',
                'Document node cannot have two element children';
          } elsif (defined $child and $_ == $$child->[1]) {
            $has_child = 1;
          }
          if ($has_child and $data->{node_type} == DOCUMENT_TYPE_NODE) {
            _throw Web::DOM::Exception 'HierarchyRequestError',
                'Element cannot precede the document type';
          }
        }
      }
    } elsif ($node_nt == DOCUMENT_TYPE_NODE) {
      # 6.3.
      if (defined $old_child) { # replace
        my $has_child;
        for (@{$$parent->[2]->{child_nodes}}) {
          my $data = $$parent->[0]->{data}->[$_];
          if ($$old_child->[0] eq $$parent->[0] and $$old_child->[1] == $_) {
            $has_child = 1;
          } elsif ($data->{node_type} == DOCUMENT_TYPE_NODE) {
            _throw Web::DOM::Exception 'HierarchyRequestError',
                'Document node cannot have two doctype children';
          } elsif ($data->{node_type} == ELEMENT_NODE and not $has_child) {
            _throw Web::DOM::Exception 'HierarchyRequestError',
                'Element cannot precede the document type';
          }
        }
      } else { # pre-insert
        my $has_child;
        for (@{$$parent->[2]->{child_nodes}}) {
          my $data = $$parent->[0]->{data}->[$_];
          if (defined $child and $_ == $$child->[1]) {
            $has_child = 1;
          }
          if ($data->{node_type} == ELEMENT_NODE and not $has_child) {
            _throw Web::DOM::Exception 'HierarchyRequestError',
                'Element cannot precede the document type';
          } elsif ($data->{node_type} == DOCUMENT_TYPE_NODE) {
            _throw Web::DOM::Exception 'HierarchyRequestError',
                'Document node cannot have two doctype children';
          }
        }
      }
    } elsif ($node_nt == DOCUMENT_FRAGMENT_NODE) {
      # 6.1.1.
      my $has_element;
      for (@{$$node->[2]->{child_nodes}}) {
        my $data = $$node->[0]->{data}->[$_];
        if ($data->{node_type} == ELEMENT_NODE) {
          if ($has_element) {
            _throw Web::DOM::Exception 'HierarchyRequestError',
                'Document node cannot have two element children';
          }
          $has_element = 1;
        } elsif ($data->{node_type} == TEXT_NODE) {
          _throw Web::DOM::Exception 'HierarchyRequestError',
              'Document node cannot contain this kind of node';
        }
      }

      # 6.1.2.
      if ($has_element) {
        if (defined $old_child) { # replace
          my $has_child;
          for (@{$$parent->[2]->{child_nodes}}) {
            my $data = $$parent->[0]->{data}->[$_];
            if ($$old_child->[0] eq $$parent->[0] and $$old_child->[1] == $_) {
              $has_child = 1;
            } elsif ($data->{node_type} == ELEMENT_NODE) {
              _throw Web::DOM::Exception 'HierarchyRequestError',
                  'Document node cannot have two element children';
            } elsif ($has_child and $data->{node_type} == DOCUMENT_TYPE_NODE) {
              _throw Web::DOM::Exception 'HierarchyRequestError',
                  'Element cannot precede the document type';
            }
          }
        } else { # pre-insert
          my $has_child;
          for (@{$$parent->[2]->{child_nodes}}) {
            my $data = $$parent->[0]->{data}->[$_];
            if ($data->{node_type} == ELEMENT_NODE) {
              _throw Web::DOM::Exception 'HierarchyRequestError',
                  'Document node cannot have two element children';
            } elsif (defined $child and $_ == $$child->[1]) {
              $has_child = 1;
            }
            if ($has_child and $data->{node_type} == DOCUMENT_TYPE_NODE) {
              _throw Web::DOM::Exception 'HierarchyRequestError',
                  'Element cannot precede the document type';
            }
          }
        }
      }
    }
  }

  # 7.-8.
  my $insert_position = 0;
  if (defined $child or # pre-insert (insertBefore)
      defined $old_child) { # replace
    my $child_id = defined $child ? $$child->[1] : $$old_child->[1];
    for (0..$#{$$parent->[2]->{child_nodes}}) {
      my $id = $$parent->[2]->{child_nodes}->[$_];
      if ($id == $child_id) {
        $insert_position += $_;
        last;
      } elsif ($$node->[0] eq $$parent->[0] and $id == $$node->[1]) {
        ## $node is a preceding sibling of $child.  Since it is
        ## removed from the parent in Step 8., insert position has to
        ## be decreased here.
        $insert_position--;
      }
    }
  } else { # pre-insert (appendChild)
    $insert_position = @{$$parent->[2]->{child_nodes} or []};
    if ($$node->[0] eq $$parent->[0] and
        defined $$node->[2]->{parent_node} and
        $$node->[2]->{parent_node} == $$parent->[1]) {
      ## $node is a child of $parent.  Since it is removed from the
      ## parent in Step 8., insert position has to be decreated here.
      $insert_position--;
    }
  }
  
  # 9. adopt
  {
    # Adopt 1.
    if ($$node->[2]->{node_type} == ELEMENT_NODE) {
      # XXX affected by a base URL change.
    }

    # Adopt 2. Remove
    if (defined (my $old_parent_id = $$node->[2]->{parent_node})) {
      # Remove 1.
      my $old_parent = $$node->[0]->{data}->[$old_parent_id];
      
      # Remove 2.-5.
      # XXX range
      
      # Remove 6.-7.
      # XXX mutation
      
      # Remove 8.
      @{$old_parent->{child_nodes}}
          = grep { $_ != $$node->[1] } @{$old_parent->{child_nodes}};
      $$node->[0]->children_changed ($old_parent_id, $$node->[2]->{node_type});

      # Remove 9.
      # XXX node is removed
    }

    # Adopt 3.
    # ownerDocument
    # XXX adopt
  } # adopt

  # Replace 10. remove ("suppress observers flag" set)
  if (defined $old_child) {
    # Remove 1.
    #

    # Remove 2.-5.
    # XXX range
    
    # Remove 6.
    #

    # Remove 7.
    # XXX mutation

    # Remove 8.
    splice @{$$parent->[2]->{child_nodes}}, $insert_position, 1, ();
    ## Redundant
    #$$parent->[0]->children_changed ($$parent->[1], $$old_child->[2]->{node_type});
    delete $$old_child->[2]->{parent_node};
    $$old_child->[0]->disconnect ($$old_child->[1]);
    
    # Remove 9.
    #
  } # remove

  # Pre-insert 10. / Replace 11. insert
  {
    # XXX "suppress observers flag" is set if it's replace.

    # Insert 1.
    #

    # Insert 2.-3.
    # XXX range

    if ($node_nt == DOCUMENT_FRAGMENT_NODE) {
      # Insert 4.
      my @node = @{$$node->[2]->{child_nodes} or []};
      
      # Insert 5.
      # XXX mutation

      # Insert 6. remove
      {
        # Remove 1.
        #

        # Remove 2.-5.
        # XXX range
        
        # Remove 6.
        #

        # Remove 7.
        # XXX mutation

        # Remove 8.
        @{$$node->[2]->{child_nodes}} = ();
        $$node->[0]->children_changed ($$node->[1], ELEMENT_NODE);
        
        # Remove 9.
        #
      } # remove

      # Insert 7.
      # XXX mutation
      
      # Insert 8.
      splice @{$$parent->[2]->{child_nodes}}, $insert_position, 0, @node;
      $$parent->[0]->children_changed ($$parent->[1], ELEMENT_NODE);
      for my $node_id (@node) {
        $$node->[0]->{data}->[$node_id]->{parent_node} = $$parent->[1];
        $$parent->[0]->connect ($node_id => $$parent->[1]);
      }
      
      # Insert 9.
      # XXX node is inserted
    } else {
      # Insert 7.
      # XXX mutation
      
      # Insert 4., 8.
      splice @{$$parent->[2]->{child_nodes}}, $insert_position, 0, $$node->[1];
      $$parent->[0]->children_changed
          ($$parent->[1], $$node->[2]->{node_type});
      $$node->[2]->{parent_node} = $$parent->[1];
      $$parent->[0]->connect ($$node->[1] => $$parent->[1]);

      # Insert 9.
      # XXX node is inserted
    }
  } # insert

  if (defined $old_child) {
    # Replace 12.
    # XXX $nodes = $node is df ? $node->child_nodes : $node
    
    # Replace 13.
    # XXX mutation

    # Replace 14.
    # XXX node is removed / node is inserted
  }

  # Pre-insert 11. / Replace 15.
  return $node;
} # _insert

sub remove_child ($$) {
  my ($parent, $child) = @_;
  # XXX
  my $id = $$child->[1];
  @{$$parent->[2]->{child_nodes}} = grep { $_ ne $id } @{$$parent->[2]->{child_nodes}};
  $$parent->[0]->children_changed ($$parent->[1], $$child->[2]->{node_type});
  delete $$child->[2]->{parent_node};
  $$child->[0]->disconnect ($$child->[1]);
  return $child;
} # remove_child

# XXX mutators

sub node_value ($;$) {
  return undef;
} # node_value

sub text_content ($;$) {
  return undef;
} # text_content

sub normalize ($) {
  my $self = shift;
  my $int = $$self->[0];
  my $new_child_nodes = [];
  my @text_id;

  my $normalize = sub {
    my $node_id;
    while (@text_id) {
      # 1.
      $node_id = shift @text_id;

      # 2.
      my $length = length ${$int->{data}->[$node_id]->{data}};

      # 3. Remove
      if ($length == 0) {
        # Remove 1.
        #
        
        # Remove 2.-5.
        # XXX range

        # Remove 6.-7.
        # XXX mutation

        # Remove 8.
        #$int->children_changed ($$self->[1], TEXT_NODE); # redundant
        delete $int->{data}->[$node_id]->{parent_node};
        $int->disconnect ($node_id);
        # don't include $node_id to $new_child_nodes
        
        # Remove 9.
        $int->node ($node_id); # for DESTROY
        # XXX node is removed
        return unless @text_id;
        next;
      } else {
        last;
      }
    }

    # 4., 5. Replace data (simplified)
    # XXX mutation
    ${$int->{data}->[$node_id]->{data}}
        .= join '', map { ${$int->{data}->[$_]->{data}} } @text_id;
    # XXX range

    # 6.-7.
    # XXX range

    # 8. Remove (simplified)
    push @$new_child_nodes, $node_id;
    for (@text_id) {
      # XXX range
      # XXX mutation
      #$int->children_changed ($$self->[1], TEXT_NODE); # redundant
      delete $int->{data}->[$_]->{parent_node};
      $int->disconnect ($_);
      # don't include $_ to $new_child_nodes
      # XXX node is removed
      $int->node ($_); # for DESTROY
    }
  }; # normalize

  for my $node_id (@{$$self->[2]->{child_nodes} or []}) {
    my $nt = $int->{data}->[$node_id]->{node_type};
    if ($nt == TEXT_NODE) {
      push @text_id, $node_id;
    } else {
      if (@text_id) {
        $normalize->();
        @text_id = ();
      }
      if ($nt == ELEMENT_NODE) {
        $int->node ($node_id)->normalize;
        push @$new_child_nodes, $node_id;
      } else {
        push @$new_child_nodes, $node_id;
      }
    }
  }
  if (@text_id) {
    $normalize->();
  }
  $int->children_changed ($$self->[1], ELEMENT_NODE);
  @{$$self->[2]->{child_nodes} or []} = @$new_child_nodes;
} # normalize

# XXX cloneNode

sub is_same_node ($$) {
  return 0 unless defined $_[1];

  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The argument is not a Node';
  }
  
  return $_[0] eq $_[1];
} # is_same_node

sub is_equal_node ($$) {
  my ($node1, $node2) = @_;

  return 0 unless defined $node2;

  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The argument is not a Node';
  }

  my $nt1 = $node1->node_type;
  my $nt2 = $node2->node_type;

  return 0 if $nt1 != $nt2;

  if ($nt1 == ELEMENT_NODE or $nt2 == ATTRIBUTE_NODE) {
    return 0 unless $node1->local_name eq $node2->local_name;
    my $ns1 = $node1->namespace_uri;
    my $ns2 = $node2->namespace_uri;
    return 0 if defined $ns1 and not defined $ns2;
    return 0 if not defined $ns1 and defined $ns2;
    return 0 if defined $ns1 and not $ns1 eq $ns2;

    if ($nt1 == ELEMENT_NODE) {
      my $prefix1 = $node1->prefix;
      my $prefix2 = $node2->prefix;
      return 0 if defined $prefix1 and not defined $prefix2;
      return 0 if not defined $prefix1 and defined $prefix2;
      return 0 if defined $prefix1 and not $prefix1 eq $prefix2;

      my $attrs1 = $node1->attributes->to_a;
      my $attrs2 = $node2->attributes->to_a;
      return 0 unless @$attrs1 == @$attrs2;
      my %attrs1;
      for (@$attrs1) {
        my $nsurl = $_->namespace_uri;
        $attrs1{defined $nsurl ? $nsurl : ''}->{$_->local_name} = $_->value;
      }
      for (@$attrs2) {
        my $nsurl = $_->namespace_uri;
        my $value1 = $attrs1{defined $nsurl ? $nsurl : ''}->{$_->local_name};
        return 0 unless defined $value1;
        return 0 unless $value1 eq $_->value;
      }
    } elsif ($nt1 == ATTRIBUTE_NODE) {
      return 0 unless $node1->value eq $node2->value;
    }
  } elsif ($nt1 == TEXT_NODE or $nt1 == COMMENT_NODE) {
    return 0 unless $node1->data eq $node2->data;
  } elsif ($nt1 == DOCUMENT_TYPE_NODE) {
    return 0 unless $node1->name eq $node2->name;
    return 0 unless $node1->public_id eq $node2->public_id;
    return 0 unless $node1->system_id eq $node2->system_id;
  } elsif ($nt1 == PROCESSING_INSTRUCTION_NODE) {
    return 0 unless $node1->target eq $node2->target;
    return 0 unless $node1->data eq $node2->data;
  }

  my @child1 = $node1->child_nodes->to_list;
  my @child2 = $node2->child_nodes->to_list;
  return 0 unless @child1 == @child2;
  for (0..$#child1) {
    return 0 unless $child1[$_]->is_equal_node ($child2[$_]);
  }
  return 1;
} # is_equal_node

# XXX compareDocumentPosition contains

# XXX namespace lookup

sub set_user_data ($$$) {
  ${$_[0]}->[2]->{user_data}->{$_[1]} = $_[2];
} # set_user_data

sub DESTROY ($) {
  my $self = shift;
  $$self->[0]->gc ($$self->[1]);
} # DESTROY

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
