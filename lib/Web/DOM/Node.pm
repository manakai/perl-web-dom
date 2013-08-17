package Web::DOM::Node;
use strict;
use warnings;
no warnings 'utf8';
our $VERSION = '1.0';
use Web::DOM::TypeError;
use Web::DOM::Exception;
use Web::DOM::Internal;
use Web::DOM::EventTarget;
push our @ISA, qw(Web::DOM::EventTarget);
use Carp;
our @CARP_NOT = qw(Web::DOM::Exception Web::DOM::TypeError);
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

our @EXPORT;
*import = \&Web::DOM::Internal::import;

push @EXPORT, qw(
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
    my $prefix = defined $_[1] ? ''.$_[1] : undef;

    # 2.
    unless (${$_[0]}->[2]->{namespace_uri}) {
      if (not ${$_[0]}->[2]->{local_name} or
          not ${$_[0]}->[0]->{data}->[0]->{no_strict_error_checking}) {
        _throw Web::DOM::Exception 'NamespaceError',
            'Namespace prefix can only be specified for namespaced node';
      }
    }

    if (defined $prefix and length $prefix) {
      unless (${$_[0]}->[0]->{data}->[0]->{no_strict_error_checking}) {
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

sub manakai_expanded_uri ($) {
  my $self = shift;
  my $ln = $self->local_name;
  if (defined $ln) {
    my $nsuri = $self->namespace_uri;
    if (defined $nsuri) {
      return $nsuri . $ln;
    } else {
      return $ln;
    }
  } else {
    return undef;
  }
} # manakai_expanded_uri

sub base_uri ($) {
  my $self = $_[0];
  my $nt = $self->node_type;
  if ($nt == DOCUMENT_NODE) {
    # 1. document base URL
    # XXX <http://html5.org/tools/web-apps-tracker?from=7961&to=7962> is not applied yet
    
    # 1. fallback base URL
    my $fallback_base_url = do {
      # 1.
      if ($self->manakai_is_srcdoc) {
        # XXX
      }

      # 2.
      my $url = $self->url;
      if ($url eq 'about:blank' and 'XXX') {
        # XXX
      }

      # 3.
      $url;
    };

    # 2.
    my $base = [grep { $_->has_attribute_ns (undef, 'href') } $self->get_elements_by_tag_name_ns (HTML_NS, 'base')->to_list]->[0];
    if (defined $base) {
      my $url = $base->get_attribute_ns (undef, 'href');
      
      # 3.
      my $result = _resolve_url $url, $fallback_base_url;

      # 4.
      return defined $result ? $result : $fallback_base_url;
    } else {
      return $fallback_base_url;
    }
  } elsif ($nt == ATTRIBUTE_NODE) {
    if (($self->namespace_uri || '') eq XML_NS and
        $self->local_name eq 'base') {
      # 2.
      my $n = $self->owner_element;
      $n = defined $n ? $n->parent_node : undef;
      return $n->base_uri if defined $n;
    } else {
      # 3.
      my $n = $self->owner_element;
      return $n->base_uri if defined $n;
    }
  } elsif ($nt == ELEMENT_NODE and
           my $attr = $self->get_attribute_node_ns (XML_NS, 'base')) {
    # 4.
    my $url = _resolve_url $attr->value, $attr->base_uri;
    return $url if defined $url;
  }
  
  # 5.
  my $n = $self->parent_node;
  return $n->base_uri if defined $n;

  # 6.
  return $self->owner_document->base_uri;
} # base_uri

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

*manakai_parent_element = \&parent_element;

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
  if (not $parent_nt == DOCUMENT_TYPE_NODE or
      not $$parent->[0]->{config}->{manakai_allow_doctype_children}) {
    unless ($parent_nt == ELEMENT_NODE or
            $parent_nt == DOCUMENT_FRAGMENT_NODE or
            $parent_nt == DOCUMENT_NODE) {
      _throw Web::DOM::Exception 'HierarchyRequestError',
          'The parent node cannot have a child';
    }
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
      # XXX host
    }
  }
  
  # 3.
  if (defined $child or defined $old_child) {
    if ($$parent->[0] eq ${$child || $old_child}->[0]) {
      my $rc_parent = ${$child || $old_child}->[2]->{parent_node};
      if (not defined $rc_parent or $rc_parent != $$parent->[1]) {
        _throw Web::DOM::Exception 'NotFoundError',
            'The reference child is not a child of the parent node';
      }
    } else {
      _throw Web::DOM::Exception 'NotFoundError',
          'The reference child is not a child of the parent node';
    }
  }

  my $not_strict_doc
      = $$parent->[0]->{config}->{not_manakai_strict_document_children};
  my $node_nt = $$node->[2]->{node_type};
  if ($node_nt == TEXT_NODE) {
    # 5.
    if ($parent_nt == DOCUMENT_NODE and not $not_strict_doc) {
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
  if ($parent_nt == DOCUMENT_NODE and not $not_strict_doc) {
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
  } # document children

  if ($parent_nt == DOCUMENT_TYPE_NODE) {
    if ($node_nt == DOCUMENT_FRAGMENT_NODE) {
      for (@{$$node->[2]->{child_nodes}}) {
        my $data = $$node->[0]->{data}->[$_];
        unless ($data->{node_type} == PROCESSING_INSTRUCTION_NODE) {
          _throw Web::DOM::Exception 'HierarchyRequestError',
              'The node cannot be contain this kind of node';
        }        
      }
    } elsif ($node_nt != PROCESSING_INSTRUCTION_NODE) {
      _throw Web::DOM::Exception 'HierarchyRequestError',
          'The node cannot be contain this kind of node';
    }
  } # doctype children

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
    # Adopt 1. Remove
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

    # Adopt 2.
    $$parent->[0]->adopt ($node);

    # Adopt 3.
    if ($$node->[2]->{node_type} == ELEMENT_NODE) {
      # XXX affected by a base URL change.
    }
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
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The argument is not a Node';
  }

  # Pre-remove 1.
  my ($parent, $child) = @_;
  if ($$child->[0] ne $$parent->[0] or
      not defined $$child->[2]->{parent_node} or
      $$child->[2]->{parent_node} != $$parent->[1]) {
    _throw Web::DOM::Exception 'NotFoundError',
        'The specified node is not a child of this node';
  }

  # Pre-remove 2. Remove
  {
    # Remove 1.-5.
    # XXX range

    # Remove 6.-7.
    # XXX mutation

    # Remove 8.
    my $child_id = $$child->[1];
    @{$$parent->[2]->{child_nodes}} = grep {
      $_ != $child_id;
    } @{$$parent->[2]->{child_nodes}};
    delete $$child->[2]->{parent_node};
    $$parent->[0]->children_changed ($$parent->[1], $$child->[2]->{node_type});
    $$child->[0]->disconnect ($$child->[1]);

    # Remove 9.
    # XXX node is removed
  }

  # Pre-remove 3.
  return $child;
} # remove_child

# XXX mutators

sub node_value ($;$) {
  return undef;
} # node_value

sub text_content ($;$) {
  return undef;
} # text_content

sub manakai_append_text ($$) {
  return $_[0];
} # manakai_append_text

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
  return;
} # normalize

sub clone_node ($;$) {
  return $_[0]->_clone ($_[0]->owner_document || $_[0], !!$_[1]);
} # clone_node

# XXX DOMDTDEF
sub _clone {
  # 1.
  my ($node, $od, $deep) = @_;

  my $orig_strict_error_checking = $od->strict_error_checking;
  $od->strict_error_checking (0);
  my $orig_strict_document_children
      = $od->dom_config->{manakai_strict_document_children};
  $od->dom_config->{manakai_strict_document_children} = 0;
  my $orig_allow_doctype_children
      = $od->dom_config->{manakai_allow_doctype_children};
  $od->dom_config->{manakai_allow_doctype_children} = 1;
  
  # 2.-4.
  my $copy;
  my $nt = $node->node_type;
  if ($nt == ELEMENT_NODE) {
    $copy = $od->create_element_ns
        ($node->namespace_uri, $node->manakai_tag_name);
    for ($node->attributes->to_list) {
      $copy->set_attribute_ns ($_->namespace_uri, $_->name, $_->value);
    }
  } elsif ($nt == TEXT_NODE) {
    $copy = $od->create_text_node ($node->data);
  } elsif ($nt == COMMENT_NODE) {
    $copy = $od->create_comment ($node->data);
  } elsif ($nt == PROCESSING_INSTRUCTION_NODE) {
    $copy = $od->create_processing_instruction ($node->target, $node->data);
  } elsif ($nt == DOCUMENT_TYPE_NODE) {
    $copy = $od->implementation->create_document_type
        ($node->name, $node->public_id, $node->system_id);
    for my $sub ($node->element_types->to_list) {
      my $copy_sub = $od->create_element_type_definition ($sub->node_name);
      for my $sub_sub ($sub->attribute_definitions->to_list) {
        my $copy_sub_sub = $od->create_attribute_definition
            ($sub_sub->node_name);
        $copy_sub_sub->node_value ($sub_sub->node_value);
        $copy_sub_sub->declared_type ($sub_sub->declared_type);
        $copy_sub_sub->default_type ($sub_sub->default_type);
        $copy_sub_sub->allowed_tokens ($sub_sub->allowed_tokens);
        $copy_sub->set_attribute_definition_node ($copy_sub_sub);
      }
      $copy->set_element_type_definition_node ($copy_sub);
    }
    for my $sub ($node->general_entities->to_list) {
      my $copy_sub = $od->create_general_entity ($sub->node_name);
      $copy_sub->public_id ($sub->public_id);
      $copy_sub->system_id ($sub->system_id);
      $copy_sub->notation_name ($sub->notation_name);
      $copy_sub->node_value ($sub->node_value);
      $copy->set_general_entity_node ($copy_sub);
    }
    for my $sub ($node->notations->to_list) {
      my $copy_sub = $od->create_notation ($sub->node_name);
      $copy_sub->public_id ($sub->public_id);
      $copy_sub->system_id ($sub->system_id);
      $copy->set_notation_node ($copy_sub);
    }
  } elsif ($nt == ATTRIBUTE_NODE) {
    $copy = $od->create_attribute_ns ($node->namespace_uri, $node->name);
    $copy->value ($node->value);
  } elsif ($nt == DOCUMENT_NODE) {
    $od->strict_error_checking ($orig_strict_error_checking);
    $od->dom_config->{manakai_strict_document_children}
        = $orig_strict_document_children;
    $od->dom_config->{manakai_allow_doctype_children}
        = $orig_allow_doctype_children;

    if ($node->isa ('Web::DOM::XMLDocument')) {
      $copy = Web::DOM::Document->new->implementation->create_document;
    } else {
      $copy = Web::DOM::Document->new;
    }
    $od = $copy;

    $orig_strict_error_checking = $od->strict_error_checking;
    $od->strict_error_checking (0);
    $orig_strict_document_children
        = $od->dom_config->{manakai_strict_document_children};
    $od->dom_config->{manakai_strict_document_children} = 0;
    $orig_allow_doctype_children
        = $od->dom_config->{manakai_allow_doctype_children};
    $od->dom_config->{manakai_allow_doctype_children} = 1;
  } elsif ($nt == DOCUMENT_FRAGMENT_NODE) {
    $copy = $od->create_document_fragment;
  } elsif ($nt == ELEMENT_TYPE_DEFINITION_NODE) {
    $copy = $od->create_element_type_definition ($node->node_name);
    for my $sub ($node->attribute_definitions->to_list) {
      my $copy_sub = $od->create_attribute_definition ($sub->node_name);
      $copy_sub->node_value ($sub->node_value);
      $copy_sub->declared_type ($sub->declared_type);
      $copy_sub->default_type ($sub->default_type);
      $copy_sub->allowed_tokens ($sub->allowed_tokens);
      $copy->set_attribute_definition_node ($copy_sub);
    }
  } elsif ($nt == ATTRIBUTE_DEFINITION_NODE) {
    $copy = $od->create_attribute_definition ($node->node_name);
    $copy->node_value ($node->node_value);
    $copy->declared_type ($node->declared_type);
    $copy->default_type ($node->default_type);
    $copy->allowed_tokens ($node->allowed_tokens);
  } elsif ($nt == ENTITY_NODE) {
    $copy = $od->create_general_entity ($node->node_name);
    $copy->public_id ($node->public_id);
    $copy->system_id ($node->system_id);
    $copy->notation_name ($node->notation_name);
    $copy->node_value ($node->node_value);
  } elsif ($nt == NOTATION_NODE) {
    $copy = $od->create_notation ($node->node_name);
    $copy->public_id ($node->public_id);
    $copy->system_id ($node->system_id);
  } else {
    die "Unknown node type $nt";
  }

  # 5.
  # XXX cloning steps

  # 6.
  if ($deep) {
    for ($node->child_nodes->to_list) {
      $copy->append_child ($_->_clone ($od, 1));
    }
  }

  $od->strict_error_checking ($orig_strict_error_checking);
  $od->dom_config->{manakai_strict_document_children}
      = $orig_strict_document_children;
  $od->dom_config->{manakai_allow_doctype_children}
      = $orig_allow_doctype_children;

  # 7.
  return $copy;
} # _clone

sub is_same_node ($$) {
  return 0 unless defined $_[1];

  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The argument is not a Node';
  }
  
  return $_[0] eq $_[1];
} # is_same_node

# XXX DOMDTDEF
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

    for (qw(element_types general_entities notations)) {
      my $objs1 = $node1->$_->to_a;
      my $objs2 = $node2->$_->to_a;
      return 0 unless @$objs1 == @$objs2;
      my %objs1;
      for (@$objs1) {
        $objs1{$_->node_name} = $_;
      }
      for (@$objs2) {
        my $obj1 = $objs1{$_->node_name} or return 0;
        return 0 unless $obj1->is_equal_node ($_);
      }
    }
  } elsif ($nt1 == PROCESSING_INSTRUCTION_NODE) {
    return 0 unless $node1->target eq $node2->target;
    return 0 unless $node1->data eq $node2->data;
  } elsif ($nt1 == ELEMENT_TYPE_DEFINITION_NODE) {
    return 0 unless $node1->node_name eq $node2->node_name;

    my $objs1 = $node1->attribute_definitions->to_a;
    my $objs2 = $node2->attribute_definitions->to_a;
    return 0 unless @$objs1 == @$objs2;
    my %objs1;
    for (@$objs1) {
      $objs1{$_->node_name} = $_;
    }
    for (@$objs2) {
      my $obj1 = $objs1{$_->node_name} or return 0;
      return 0 unless $obj1->is_equal_node ($_);
    }
  } elsif ($nt1 == ATTRIBUTE_DEFINITION_NODE) {
    return 0 unless $node1->node_name eq $node2->node_name;
    return 0 unless $node1->node_value eq $node2->node_value;
    return 0 unless $node1->declared_type eq $node2->declared_type;
    return 0 unless $node1->default_type eq $node2->default_type;
    
    my $tokens1 = $node1->allowed_tokens;
    my $tokens2 = $node2->allowed_tokens;
    return 0 unless @$tokens1 == @$tokens2;

    my %tokens1 = map { $_ => 1 } @$tokens1;
    for (@$tokens2) {
      return 0 unless $tokens1{$_};
    }
    my %tokens2 = map { $_ => 1 } @$tokens2;
    for (@$tokens1) {
      return 0 unless $tokens2{$_};
    }
  } elsif ($nt1 == ENTITY_NODE) {
    return 0 unless $node1->node_name eq $node2->node_name;
    return 0 unless $node1->node_value eq $node2->node_value;
    return 0 unless $node1->public_id eq $node2->public_id;
    return 0 unless $node1->system_id eq $node2->system_id;
    my $nn1 = $node1->notation_name;
    my $nn2 = $node2->notation_name;
    return 0 if defined $nn1 and not defined $nn2;
    return 0 if not defined $nn1 and defined $nn2;
    return 0 if defined $nn1 and not $nn1 eq $nn2;
  } elsif ($nt1 == NOTATION_NODE) {
    return 0 unless $node1->node_name eq $node2->node_name;
    return 0 unless $node1->public_id eq $node2->public_id;
    return 0 unless $node1->system_id eq $node2->system_id;
  }

  my @child1 = $node1->child_nodes->to_list;
  my @child2 = $node2->child_nodes->to_list;
  return 0 unless @child1 == @child2;
  for (0..$#child1) {
    return 0 unless $child1[$_]->is_equal_node ($child2[$_]);
  }
  return 1;
} # is_equal_node

sub DOCUMENT_POSITION_DISCONNECTED () { 0x01 }
sub DOCUMENT_POSITION_PRECEDING () { 0x02 }
sub DOCUMENT_POSITION_FOLLOWING () { 0x04 }
sub DOCUMENT_POSITION_CONTAINS () { 0x08 }
sub DOCUMENT_POSITION_CONTAINED_BY () { 0x10 }
sub DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC () { 0x20 }

push @EXPORT, qw(
  DOCUMENT_POSITION_DISCONNECTED DOCUMENT_POSITION_PRECEDING
  DOCUMENT_POSITION_FOLLOWING DOCUMENT_POSITION_CONTAINS
  DOCUMENT_POSITION_CONTAINED_BY DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC
);

sub compare_document_position ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The argument is not a Node';
  }

  # 1.
  my $ref = $_[0];
  my $other = $_[1];

  # 2.
  return 0 if $ref eq $other;

  # 3.
  if (not $$ref->[0] eq $$other->[0]) {
    return DOCUMENT_POSITION_DISCONNECTED |
           DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
           ($$ref->[0] < $$other->[0] ? DOCUMENT_POSITION_PRECEDING
                                       : DOCUMENT_POSITION_FOLLOWING);
  } elsif (not $$ref->[0]->{tree_id}->[$$ref->[1]] ==
               $$other->[0]->{tree_id}->[$$other->[1]]) {
    return DOCUMENT_POSITION_DISCONNECTED |
           DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
           ($$ref->[0]->{tree_id}->[$$ref->[1]] <
            $$other->[0]->{tree_id}->[$$other->[1]]
               ? DOCUMENT_POSITION_PRECEDING
               : DOCUMENT_POSITION_FOLLOWING);
  }

  my $ref_nt = $ref->node_type;
  my $other_nt = $other->node_type;
  if ($ref_nt == $other_nt and $ref_nt == ATTRIBUTE_NODE) {
    my $ref_oe = $ref->owner_element;
    my $other_oe = $other->owner_element;
    if ($ref_oe and $other_oe and $ref_oe eq $other_oe) {
      for ($other_oe->attributes->to_list) {
        if ($_ eq $other) {
          return DOCUMENT_POSITION_PRECEDING |
              DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
        } elsif ($_ eq $ref) {
          return DOCUMENT_POSITION_FOLLOWING |
              DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
        }
      }
    }
  } elsif (($other_nt == ELEMENT_TYPE_DEFINITION_NODE or
            $other_nt == ENTITY_NODE or
            $other_nt == NOTATION_NODE) and
           ($ref_nt == ELEMENT_TYPE_DEFINITION_NODE or
            $ref_nt == ENTITY_NODE or
            $ref_nt == NOTATION_NODE)) {
    my $ref_oe = $ref->owner_document_type_definition;
    my $other_oe = $other->owner_document_type_definition;
    if ($ref_oe and $other_oe and $ref_oe eq $other_oe) {
      for ($other_oe->general_entities->to_list,
           $other_oe->notations->to_list,
           $other_oe->element_types->to_list) {
        if ($_ eq $other) {
          return DOCUMENT_POSITION_PRECEDING |
              DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
        } elsif ($_ eq $ref) {
          return DOCUMENT_POSITION_FOLLOWING |
              DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
        }
      }
    }
  } elsif ($ref_nt == $other_nt and $ref_nt == ATTRIBUTE_DEFINITION_NODE) {
    my $ref_oe = $ref->owner_element_type_definition;
    my $other_oe = $other->owner_element_type_definition;
    if ($ref_oe and $other_oe and $ref_oe eq $other_oe) {
      for ($other_oe->attribute_definitions->to_list) {
        if ($_ eq $other) {
          return DOCUMENT_POSITION_PRECEDING |
              DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
        } elsif ($_ eq $ref) {
          return DOCUMENT_POSITION_FOLLOWING |
              DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
        }
      }
    }
  }

  # 4.
  my @ref = ();
  my $ref_p = $ref;
  if ($ref_nt == ATTRIBUTE_NODE) {
    $ref_p = $ref_p->owner_element;
    unshift @ref, -1;
  } elsif ($ref_nt == ELEMENT_TYPE_DEFINITION_NODE or
           $ref_nt == ENTITY_NODE or
           $ref_nt == NOTATION_NODE) {
    $ref_p = $ref_p->owner_document_type_definition;
    if ($ref_p) {
      my $i = 0;
      for (reverse ($ref_p->general_entities->to_list,
                    $ref_p->notations->to_list,
                    $ref_p->element_types->to_list)) {
        $i--;
        last if $_ eq $ref;
      }
      unshift @ref, $i;
    } else {
      unshift @ref, -1;
    }
  } elsif ($ref_nt == ATTRIBUTE_DEFINITION_NODE) {
    $ref_p = $ref_p->owner_element_type_definition;
    if ($ref_p) {
      my $i = 0;
      for (reverse $ref_p->attribute_definitions->to_list) {
        $i--;
        last if $_ eq $ref;
      }
      unshift @ref, $i;
      my $ref2 = $ref_p;
      $ref_p = $ref_p->owner_document_type_definition;
      if ($ref_p) {
        my $i = 0;
        for (reverse $ref_p->element_types->to_list) {
          $i--;
          last if $_ eq $ref2;
        }
        unshift @ref, $i;
      } else {
        unshift @ref, -1;
      }
    } else {
      unshift @ref, -1;
    }
  }
  while ($ref_p and my $pn = $ref_p->parent_node) {
    my $i = 0;
    for ($pn->child_nodes->to_list) {
      last if $_ eq $ref_p;
      $i++;
    }
    unshift @ref, $i;
    $ref_p = $pn;
  }
  unshift @ref, 0;
  my @other = ();
  my $other_p = $other;
  if ($other_nt == ATTRIBUTE_NODE) {
    $other_p = $other_p->owner_element;
    unshift @other, -1;
  } elsif ($other_nt == ELEMENT_TYPE_DEFINITION_NODE or
           $other_nt == ENTITY_NODE or
           $other_nt == NOTATION_NODE) {
    $other_p = $other_p->owner_document_type_definition;
    if ($other_p) {
      my $i = 0;
      for (reverse ($other_p->general_entities->to_list,
                    $other_p->notations->to_list,
                    $other_p->element_types->to_list)) {
        $i--;
        last if $_ eq $other;
      }
      unshift @other, $i;
    } else {
      unshift @other, -1;
    }
  } elsif ($other_nt == ATTRIBUTE_DEFINITION_NODE) {
    $other_p = $other_p->owner_element_type_definition;
    if ($other_p) {
      my $i = 0;
      for (reverse $other_p->attribute_definitions->to_list) {
        $i--;
        last if $_ eq $other;
      }
      unshift @other, $i;
      my $other2 = $other_p;
      $other_p = $other_p->owner_document_type_definition;
      if ($other_p) {
        my $i = 0;
        for (reverse $other_p->element_types->to_list) {
          $i--;
          last if $_ eq $other2;
        }
        unshift @other, $i;
      } else {
        unshift @other, -1;
      }
    } else {
      unshift @other, -1;
    }
  }
  while ($other_p and my $pn = $other_p->parent_node) {
    my $i = 0;
    for ($pn->child_nodes->to_list) {
      last if $_ eq $other_p;
      $i++;
    }
    unshift @other, $i;
    $other_p = $pn;
  }
  unshift @other, 0;

  while (@other) {
    if ($other[0] < $ref[0]) {
      return DOCUMENT_POSITION_PRECEDING;
    } elsif ($ref[0] < $other[0]) {
      return DOCUMENT_POSITION_FOLLOWING;
    } else {
      shift @other;
      shift @ref;
      return DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS
          unless @other;
      return DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY
          unless @ref;
    }
  }

  die "Unknown document position";
} # compare_document_position

sub contains ($$) {
  return 0 if not defined $_[1];

  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The argument is not a Node';
  }

  my $node = $_[0];
  my $other = $_[1];
  while ($other) {
    if ($node eq $other) {
      return 1;
    }
    $other = $other->parent_node;
  }
  return 0;
} # contains

sub lookup_prefix ($$) {
  my $self = $_[0];

  # 1.
  my $prefix = defined $_[1] ? ''.$_[1] : undef;
  if (not defined $prefix or not length $prefix) {
    return undef;
  }

  # 2.
  my $nt = $self->node_type;
  if ($nt == ELEMENT_NODE) {
    return $self->_locate_prefix ($prefix);
  } elsif ($nt == DOCUMENT_NODE) {
    my $de = $self->document_element;
    if ($de) {
      return $de->_locate_prefix ($prefix);
    } else {
      return undef;
    }
  } elsif ($nt == DOCUMENT_TYPE_NODE or $nt == DOCUMENT_FRAGMENT_NODE) {
    return undef;
  } elsif ($nt == ATTRIBUTE_NODE) {
    my $oe = $self->owner_element;
    if ($oe) {
      return $oe->_locate_prefix ($prefix);
    } else {
      return undef;
    }
  } else {
    my $pe = $self->parent_element;
    if ($pe) {
      return $pe->_locate_prefix ($prefix);
    } else {
      return undef;
    }
  }
} # lookup_prefix

sub _locate_prefix ($$) {
  my $self = $_[0];
  my $nsurl = $_[1];

  # Locate a namespace prefix

  # 1.
  my $node_nsurl = $self->namespace_uri;
  $node_nsurl = '' if not defined $node_nsurl;
  if ($node_nsurl eq $nsurl) {
    my $prefix = $self->prefix;
    if (defined $prefix) {
      return $prefix;
    }
  }

  # 2.
  for my $attr ($self->attributes->to_list) {
    if (($attr->prefix || '') eq 'xmlns' and
        $attr->value eq $nsurl) {
      my $ln = $attr->local_name;
      my $lookup_url = $self->lookup_namespace_uri ($ln);
      $lookup_url = '' unless defined $lookup_url;
      if ($lookup_url eq $nsurl) { # DOM3 vs DOM4
        return $ln;
      }
    }
  }
  
  # 3.
  my $pe = $self->parent_element;
  if ($pe) {
    return $pe->_locate_prefix ($nsurl);
  } else {
    return undef;
  }
} # _locate_prefix

sub lookup_namespace_uri ($$) {
  my $self = $_[0];
  my $prefix = defined $_[1] ? ''.$_[1] : '';

  # Locate a namespace
  my $nt = $self->node_type;
  if ($nt == ELEMENT_NODE) {
    # 1.
    my $nsurl = $self->namespace_uri;
    my $node_prefix = $self->prefix;
    $node_prefix = '' unless defined $node_prefix;
    if (defined $nsurl and $prefix eq $node_prefix) {
      return $nsurl;
    }

    # 2.
    if ($prefix eq '') {
      my $attr = $self->get_attribute_node_ns (XMLNS_NS, 'xmlns');
      if ($attr and not defined $attr->prefix) {
        # 1.-2.
        my $value = $attr->value;
        return length $value ? $value : undef;
      }
    } else {
      my $attr = $self->get_attribute_node_ns (XMLNS_NS, $prefix);
      if ($attr and ($attr->prefix || '') eq 'xmlns') {
        # 1.-2.
        my $value = $attr->value;
        return length $value ? $value : undef;
      }
    }

    # 3.-4.
    my $pe = $self->parent_element;
    if ($pe) {
      return $pe->lookup_namespace_uri ($prefix);
    } else {
      return undef;
    }
  } elsif ($nt == DOCUMENT_NODE) {
    # 1.-2.
    my $de = $self->document_element;
    if (defined $de) {
      return $de->lookup_namespace_uri ($prefix);
    } else {
      return undef;
    }
  } elsif ($nt == DOCUMENT_TYPE_NODE or $nt == DOCUMENT_FRAGMENT_NODE) {
    return undef;
  } elsif ($nt == ATTRIBUTE_NODE) {
    # 1.-2.
    my $oe = $self->owner_element;
    if (defined $oe) {
      return $oe->lookup_namespace_uri ($prefix);
    } else {
      return undef;
    }
  } else {
    # 1.-2.
    my $pe = $self->parent_element;
    if (defined $pe) {
      return $pe->lookup_namespace_uri ($prefix);
    } else {
      return undef;
    }
  }
} # lookup_namespace_uri

sub is_default_namespace ($$) {
  # 2.
  my $default = $_[0]->lookup_namespace_uri (undef);

  # 1., 3.
  my $nsurl = defined $_[1] ? ''.$_[1] : '';
  if (defined $default and length $nsurl and $default eq $nsurl) {
    return 1;
  } elsif (not defined $default and $nsurl eq '') {
    return 1;
  } else {
    return 0;
  }
} # is_default_namespace

sub manakai_get_child_namespace_uri ($) {
  my $self = $_[0];
  if ($$self->[0]->{data}->[0]->{is_html}) {
    my $tag_name = defined $_[1] ? $_[1] : '';
    $tag_name =~ tr/A-Z/a-z/; ## ASCII case-insensitive.

    require Web::HTML::ParserData;
    my $ns = $self->namespace_uri;
    my $ln = $self->local_name;
    if (not defined $ln or not defined $ns) {
      #
    } elsif ($ns eq SVG_NS) {
      if ($Web::HTML::ParserData::SVGHTMLIntegrationPoints->{$ln}) {
        #
      } else {
        return $ns;
      }
    } elsif ($ns eq MML_NS) {
      if ($Web::HTML::ParserData::MathMLTextIntegrationPoints->{$ln}) {
        return MML_NS if $tag_name eq 'mglyph' or $tag_name eq 'malignmark';
      } elsif ($ln eq 'annotation-xml') {
        return SVG_NS if $tag_name eq 'svg';
        my $encoding = $self->get_attribute_ns (undef, 'encoding') || '';
        $encoding =~ tr/A-Z/a-z/; ## ASCII case-insensitive.
        unless ($encoding eq 'text/html' or $encoding eq 'application/xhtml+xml') {
          return $ns;
        }
      } elsif ($Web::HTML::ParserData::MathMLHTMLIntegrationPoints->{$ln}) {
        #
      } else {
        return $ns;
      }
    } # $ns

    if ($tag_name eq 'svg') {
      return SVG_NS;
    } elsif ($tag_name eq 'math') {
      return MML_NS;
    } else {
      return HTML_NS;
    }
  } else {
    my $prefix = defined $_[1] ? ''.$_[1] : undef;
    if (defined $_[1] and $prefix =~ /:/) {
      $prefix =~ s/:.*//gs;
      if ($prefix eq '') {
        return undef;
      } else {
        return $self->lookup_namespace_uri ($prefix);
      }
    } else {
      return $self->lookup_namespace_uri (undef);
    }
  }
} # manakai_get_child_namespace_uri

sub is_supported ($$;$) {
  return 1;
} # is_supported

sub get_user_data ($$) {
  return ${$_[0]}->[2]->{user_data}->{$_[1]};
} # get_user_data

sub set_user_data ($$;$$) {
  if (defined $_[3]) {
    _throw Web::DOM::Exception 'NotSupportedError',
        'UserDataHandler is not supported';
  }
  if (defined $_[2]) {
    ${$_[0]}->[2]->{user_data}->{$_[1]} = $_[2];
  } else {
    delete ${$_[0]}->[2]->{user_data}->{$_[1]};
  }
  return;
} # set_user_data

## "iterator collection" used to implement Web::DOM::NodeIterator.
sub _iterator ($) {
  my $self = shift;
  return $$self->[0]->collection ('iterator', $self, sub {
    my $node = $_[0];
    my $data = $$node->[0]->{data};
    my @node_id = @{$data->[$$node->[1]]->{child_nodes} or []};
    my @id;
    while (@node_id) {
      my $id = shift @node_id;
      unshift @node_id, @{$data->[$id]->{child_nodes} or []};
      push @id, $id;
    }
    return ($$node->[1], @id);
  });
} # _iterator

# XXX manakai_language manakai_html_language

sub DESTROY ($) {
  ${$_[0]}->[0]->gc (${$_[0]}->[1]);
} # DESTROY

1;

=head1 LICENSE

Copyright 2007-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
