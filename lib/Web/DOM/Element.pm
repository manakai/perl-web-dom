package Web::DOM::Element;
use strict;
use warnings;
no warnings 'utf8';
use warnings FATAL => 'recursion';
our $VERSION = '5.0';
use Web::DOM::Internal;
use Web::DOM::Node;
use Web::DOM::ParentNode;
use Web::DOM::ChildNode;
push our @ISA, qw(Web::DOM::ParentNode Web::DOM::ChildNode Web::DOM::Node);
use Web::DOM::Exception;
use Char::Class::XML qw(
  InXMLNameChar InXMLNameStartChar
  InXMLNCNameChar InXMLNCNameStartChar
);

our @EXPORT;

*node_name = \&tag_name;

sub tag_name ($) {
  my $data = ${$_[0]}->[2];
  my $qname;
  if (defined $data->{prefix}) {
    $qname = ${$data->{prefix}} . ':' . ${$data->{local_name}};
  } else {
    $qname = ${$data->{local_name}};
  }
  if (defined $data->{namespace_uri} and 
      ${$data->{namespace_uri}} eq 'http://www.w3.org/1999/xhtml' and
      ${$_[0]}->[0]->{data}->[0]->{is_html}) {
    $qname =~ tr/a-z/A-Z/; # ASCII uppercase
  }
  return $qname;
} # tag_name

sub manakai_tag_name ($) {
  my $data = ${$_[0]}->[2];
  my $qname;
  if (defined $data->{prefix}) {
    $qname = ${$data->{prefix}} . ':' . ${$data->{local_name}};
  } else {
    $qname = ${$data->{local_name}};
  }
  return $qname;
} # manakai_tag_name

sub manakai_element_type_match ($$$) {
  my ($self, $nsuri, $ln) = @_;
  $nsuri = ''.$nsuri if defined $nsuri;
  if (defined $nsuri and length $nsuri) {
    my $self_nsurl = $self->namespace_uri;
    if (defined $self_nsurl and $nsuri eq $self_nsurl) {
      return $ln eq $self->local_name;
    } else {
      return 0;
    }
  } else {
    if (not defined $self->namespace_uri) {
      return $ln eq $self->local_name;
    } else {
      return 0;
    }
  }
} # manakai_element_type_match


## Content attributes
##
## A content attribute is represented as either:
##
##   - A pair of attribute name and value, or
##   - An |Attr| node.
##
## An attribute can be represented as a pair when it does not have any
## additional data (e.g. namespace, user data, or attribute type) and
## there is no reference to the |Attr| object.  The |$InflateAttr|
## operation below converts an attribute represented as a pair into
## |Attr|-object form.
##
## Any content attribute of an element is stored in the node data of
## the element in BOTH of following forms:
##
##   $$node->[2]->{attrs}->{$ns // ''}->{$ln} = AttrValueRef
##   $$node->[2]->{attributes} = [array of AttrNameRef]
##
## Note that the |attributes| hash reference is used to preserve the
## order of the attributes in the element.
##
## An AttrNameRef is either a scalar reference to a string
## representing the attribute name (a character string) or the node ID
## of an |Attr| object.
##
## An AttrValueRef is either an IndexedString (i.e. an array
## reference) representing the attribute value or the node ID of an
## |Attr| object.
##
## If an attribute is represented as an |Attr| node, both AttrNameRef
## and AttrValueRef for the attribute are the same node ID.
## Otherwise, AttrNameRef must be a scalar reference and AttrValueRef
## must be an IndexedString.

my $InflateAttr = sub ($$) {
  my ($node, $nameref) = @_; # AttrNameRef
  my $data = {node_type => ATTRIBUTE_NODE,
              local_name => Web::DOM::Internal->text ($$nameref),
              data => $$node->[2]->{attrs}->{''}->{$$nameref}, # AttrValueRef/IndexedString
              owner => $$node->[1]};
  my $attr_id = $$node->[0]->add_data ($data);
  $$node->[2]->{attrs}->{''}->{$$nameref} = $attr_id; # AttrValueRef
  $$node->[0]->connect ($attr_id => $$node->[1]);
  return $attr_id; # new AttrNameRef
}; # $InflateAttr

sub attributes ($) {
  return ${$_[0]}->[0]->collection ('attributes', $_[0], sub {
    my $node = $_[0];
    for (@{$$node->[2]->{attributes} or []}) {
      $_ = $InflateAttr->($node, $_) if ref $_; # AttrNameRef
    }
    return @{$$node->[2]->{attributes} or []};
  });
} # attributes

sub has_attributes ($) {
  return !!@{${$_[0]}->[2]->{attributes} or []};
} # has_attributes

sub get_attribute_names ($) {
  return [map {
    if (ref $_) { # AttrNameRef
      $$_;
    } else {
      ${$_[0]}->[0]->node ($_)->name;
    }
  } @{${$_[0]}->[2]->{attributes} or []}];
} # get_attribute_names

sub has_attribute ($$) {
  my $node = $_[0];
  my $name = ''.$_[1];

  # 1.
  if (${$$node->[2]->{namespace_uri} || \''} eq HTML_NS and
      $$node->[0]->{data}->[0]->{is_html}) {
    $name =~ tr/A-Z/a-z/; ## ASCII lowercase
  }

  # 2.
  return 1 if ref ($$node->[2]->{attrs}->{''}->{$name} || ''); # AttrValueRef
  for (@{$$node->[2]->{attributes} or []}) {
    if (ref $_) { # AttrNameRef
      return 1 if $$_ eq $name;
    } else { # node ID
      return 1 if $$node->[0]->node ($_)->name eq $name;
    }
  }
  return 0;
} # has_attribute

sub has_attribute_ns ($$$) {
  # WebIDL, 1., 2.
  return defined ${$_[0]}->[2]->{attrs}->{defined $_[1] ? $_[1] : ''}->{''.$_[2]};
} # has_attribute_ns

sub get_attribute ($$) {
  my $node = $_[0];
  my $name = ''.$_[1];

  # 1.
  if (${$$node->[2]->{namespace_uri} || \''} eq HTML_NS and
      $$node->[0]->{data}->[0]->{is_html}) {
    $name =~ tr/A-Z/a-z/; ## ASCII lowercase
  }

  # 2.
  for (@{$$node->[2]->{attributes} or []}) {
    if (ref $_) { # AttrNameRef
      if ($$_ eq $name) {
        return join '', map { $_->[0] } @{$$node->[2]->{attrs}->{''}->{$name}}; # AttrValueRef/IndexedString
      }
    } else { # node ID
      my $attr_node = $$node->[0]->node ($_);
      if ($attr_node->name eq $name) {
        return $attr_node->value;
      }
    }
  }
  return undef;
} # get_attribute

sub get_attribute_ns ($$$) {
  my $node = $_[0];
  my $nsurl = defined $_[1] ? ''.$_[1] : undef; # can be empty
  my $ln = ''.$_[2];

  # 1., 2. / Get an attribute 1., 2.
  my $attr_id = $$node->[2]->{attrs}->{defined $nsurl ? $nsurl : ''}->{$ln}; # AttrValueRef
  if (defined $attr_id) {
    if (ref $attr_id) {
      return join '', map { $_->[0] } @$attr_id; # AttrValueRef/IndexedString
    } else {
      return join '', map { $_->[0] } @{$$node->[0]->{data}->[$attr_id]->{data}}; # IndexedString
    }
  } else {
    return undef;
  }
} # get_attribute_ns

sub manakai_get_attribute_indexed_string_ns ($$$) {
  my $node = $_[0];
  my $nsurl = defined $_[1] ? ''.$_[1] : undef; # can be empty
  my $ln = ''.$_[2];

  # 1., 2. / Get an attribute 1., 2.
  my $attr_id = $$node->[2]->{attrs}->{defined $nsurl ? $nsurl : ''}->{$ln}; # AttrValueRef
  if (defined $attr_id) {
    if (ref $attr_id) {
      return [map { [$_->[0], $_->[1], $_->[2]] } @$attr_id]; # AttrValueRef/IndexedString
    } else {
      return [map { [$_->[0], $_->[1], $_->[2]] } @{$$node->[0]->{data}->[$attr_id]->{data}}]; # IndexedString
    }
  } else {
    return undef;
  }
} # manakai_get_attribute_indexed_string_ns

sub get_attribute_node ($$) {
  my $node = $_[0];
  my $name = ''.$_[1];

  # 1.
  if (${$$node->[2]->{namespace_uri} || \''} eq HTML_NS and
      $$node->[0]->{data}->[0]->{is_html}) {
    $name =~ tr/A-Z/a-z/; ## ASCII lowercase
  }

  # 2.
  for (@{$$node->[2]->{attributes} or []}) {
    if (ref $_) { # AttrNameRef
      if ($$_ eq $name) {
        $_ = $InflateAttr->($node, $_);
        return $$node->[0]->node ($_); # node ID
      }
    } else { # node ID
      my $attr_node = $$node->[0]->node ($_);
      if ($attr_node->name eq $name) {
        return $attr_node;
      }
    }
  }
  return undef;
} # get_attribute_node

sub get_attribute_node_ns ($$$) {
  my $node = $_[0];
  my $nsurl = defined $_[1] ? ''.$_[1] : undef; # can be empty
  my $ln = ''.$_[2];

  # 1., 2. / Get an attribute 1., 2.
  my $attr_id = $$node->[2]->{attrs}->{defined $nsurl ? $nsurl : ''}->{$ln}; # AttrValueRef
  if (defined $attr_id) {
    if (ref $attr_id) {
      $attr_id = $InflateAttr->($node, \$ln);
      @{$$node->[2]->{attributes}} = map {
        ref $_ && $$_ eq $ln ? $attr_id : $_; # AttrNameRef
      } @{$$node->[2]->{attributes}};
      return $$node->[0]->node ($attr_id);
    } else {
      return $$node->[0]->node ($attr_id);
    }
  } else {
    return undef;
  }
} # get_attribute_node_ns

sub set_attribute ($$$) {
  my $node = $_[0];
  my $name = ''.$_[1];
  my $value = ''.$_[2];

  # 1.
  if ($$node->[0]->{data}->[0]->{no_strict_error_checking}) {
    unless (length $name) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The name is not an XML Name';
    }
  } else {
    unless ($name =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The name is not an XML Name';
    }
  }

  # 2.
  if (${$$node->[2]->{namespace_uri} || \''} eq HTML_NS and
      $$node->[0]->{data}->[0]->{is_html}) {
    $name =~ tr/A-Z/a-z/; ## ASCII lowercase
  }

  $$node->[0]->{revision}++;

  # 3.
  for (@{$$node->[2]->{attributes} or []}) {
    if (ref $_) { # AttrNameRef
      if ($$_ eq $name) {
        # 5.
        {
          # Change 1.
          # XXX mutation

          # Change 2.
          $$node->[2]->{attrs}->{''}->{$name} = [[$value, -1, 0]]; # AttrValueRef/IndexedString

          # Change 3.
          $node->_attribute_is (undef, \$name, set => 1, changed => 1);
        }
        return;
      }
    } else { # node ID
      my $attr_node = $$node->[0]->node ($_);
      if ($attr_node->name eq $name) {
        # 5.
        {
          # Change 1.
          # XXX mutation

          # Change 2.
          $$attr_node->[2]->{data} = [[$value, -1, 0]]; # IndexedString

          # Change 3.
          $node->_attribute_is
              ($$attr_node->[2]->{namespace_uri},
               $$attr_node->[2]->{local_name},
               set => 1, changed => 1);
        }
        return;
      }
    }
  }

  # 4.
  {
    # Append 1.
    # XXX mutation

    # Append 2.
    push @{$$node->[2]->{attributes} ||= []},
        Web::DOM::Internal->text ($name); # AttrNameRef
    $$node->[2]->{attrs}->{''}->{$name} = [[$value, -1, 0]]; # AttrValueRef/IndexedString

    # Append 3.
    $node->_attribute_is (undef, \$name, set => 1, added => 1);
  }
  return;
} # set_attribute

sub set_attribute_ns ($$$$) {
  return $_[0]->manakai_set_attribute_indexed_string_ns
      ($_[1], $_[2], [[$_[3], -1, 0]]);
} # set_attribute_ns

sub manakai_set_attribute_indexed_string_ns ($$$$) {
  my $node = $_[0];
  my $qname;
  my $prefix;
  my $ln;
  my $not_strict = $$node->[0]->{data}->[0]->{no_strict_error_checking};

  # WebIDL / 1.
  my $nsurl = defined $_[1] ? ''.$_[1] : undef;
  $nsurl = undef if defined $nsurl and not length $nsurl;

  # DOMPERL
  if (defined $_[2] and ref $_[2] eq 'ARRAY') {
    $prefix = $_[2]->[0];
    $ln = ''.$_[2]->[1];
    $qname = defined $prefix ? $prefix . ':' . $ln : $ln;
  } else {
    $qname = ''.$_[2];
  }

  # IndexedStringSegment
  _throw Web::DOM::TypeError 'The argument is not an IndexedString'
      if not ref $_[3] eq 'ARRAY' or
         grep { not ref $_ eq 'ARRAY' } @{$_[3]};
  my $value = [map { [''.$_->[0], 0+$_->[1], 0+$_->[2]] } @{$_[3]}];

  if ($not_strict) {
    unless (length $qname) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The qualified name is not an XML Name';
    }
  } else {
    # 2.
    unless ($qname =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
      _throw Web::DOM::Exception 'InvalidCharacterError',
          'The qualified name is not an XML Name';
    }

    # 3.
    if (defined $ln) {
      if (defined $prefix and
          not $prefix =~ /\A\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*\z/) {
        _throw Web::DOM::Exception 'NamespaceError',
            'The prefix is not an XML NCName';
      }
      unless ($ln =~ /\A\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*\z/) {
        _throw Web::DOM::Exception 'NamespaceError',
            'The local name is not an XML NCName';
      }
    }
    unless ($qname =~ /\A\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*(?::\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*)?\z/) {
      _throw Web::DOM::Exception 'NamespaceError',
          'The qualified name is not an XML QName';
    }
  }

  # 4.
  unless (defined $ln) {
    $ln = $qname;
    if ($ln =~ s{\A([^:]+):(?=.)}{}s) {
      $prefix = $1;
    }
  }

  unless ($not_strict) {
    # 5.
    if (defined $prefix and not defined $nsurl) {
      _throw Web::DOM::Exception 'NamespaceError',
          'Namespace prefix cannot be bound to the null namespace';
    }

    # 6.
    if (defined $prefix and $prefix eq 'xml' and
        (not defined $nsurl or $nsurl ne XML_NS)) {
      _throw Web::DOM::Exception 'NamespaceError',
          'Prefix |xml| cannot be bound to anything other than XML namespace';
    }

    # 7.
    if (($qname eq 'xmlns' or (defined $prefix and $prefix eq 'xmlns')) and
        (not defined $nsurl or $nsurl ne XMLNS_NS)) {
      _throw Web::DOM::Exception 'NamespaceError',
          'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
    }

    # 8.
    if (defined $nsurl and $nsurl eq XMLNS_NS and
        not ($qname eq 'xmlns' or (defined $prefix and $prefix eq 'xmlns'))) {
      _throw Web::DOM::Exception 'NamespaceError',
          'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';
    }
  } # strict

  $$node->[0]->{revision}++;

  # 9. Set an attribute
  {
    # Set 1.-4.
    my $attr_id = $$node->[2]->{attrs}->{defined $nsurl ? $nsurl : ''}->{$ln}; # AttrValueRef
    if (defined $attr_id) {
      # 6.
      {
        # Change 1.
        # XXX mutation

        # Change 2.
        if (ref $attr_id) {
          @$attr_id = @$value; # AttrValueRef/IndexedString
        } else {
          $$node->[0]->{data}->[$attr_id]->{data} = $value; # IndexedString
        }

        # Change 3.
        $node->_attribute_is (defined $nsurl ? \$nsurl : undef, \$ln,
                              set => 1, changed => 1);
      }
    } else {
      # 5.
      {
        # Append 1.
        # XXX mutation

        # Append 2.
        if (defined $nsurl or defined $prefix) {
          my $data = {node_type => ATTRIBUTE_NODE,
                      namespace_uri => Web::DOM::Internal->text ($nsurl),
                      prefix => Web::DOM::Internal->text ($prefix),
                      local_name => Web::DOM::Internal->text ($ln),
                      data => $value, # IndexedString
                      owner => $$node->[1]};
          my $attr_id = $$node->[0]->add_data ($data);
          push @{$$node->[2]->{attributes} ||= []}, $attr_id; # AttrNameRef
          $$node->[2]->{attrs}->{defined $nsurl ? $nsurl : ''}->{$ln}
              = $attr_id; # AttrValueRef
          $$node->[0]->connect ($attr_id => $$node->[1]);
        } else {
          push @{$$node->[2]->{attributes} ||= []},
              Web::DOM::Internal->text ($ln); # AttrNameRef
          $$node->[2]->{attrs}->{''}->{$ln} = $value; # AttrValueRef/IndexedString
        }

        # Append 3.
        $node->_attribute_is (defined $nsurl ? \$nsurl : undef, \$ln,
                              set => 1, added => 1);
      }
    }
  }
  return;
} # manakai_set_attribute_indexed_string_ns

sub set_attribute_node ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Attr')) {
    _throw Web::DOM::TypeError 'The argument is not an Attr';
  }

  my ($node, $attr) = @_;

  ## Set an attribute

  ## 1.
  if (defined $$attr->[2]->{owner} and
      not ($$attr->[0] eq $$node->[0] and
           $$attr->[2]->{owner} == $$node->[1])) {
    _throw Web::DOM::Exception 'InUseAttributeError',
        'The specified attribute has already attached to another node';
  }

  ## 2. Get an attribute by namespace and local name
  my $old_attr = $node->get_attribute_node_ns
      ($attr->namespace_uri, $attr->local_name);

  ## 3.
  return $attr if defined $old_attr and $attr eq $old_attr;

  if (defined $old_attr) {
    ## 4. Replace
    {
      ## 1. Mutation
      # XXX

      ## 3.
      delete $$node->[2]->{attrs}->{${$$old_attr->[2]->{namespace_uri} || \''}}->{${$$old_attr->[2]->{local_name}}}; # AttrValueRef
      my $i = 0;
      my $found = 0;
      @{$$node->[2]->{attributes}} = grep {
        if ($_ != $$old_attr->[1]) {
          $i++ unless $found;
          1;
        } else {
          $found = 1;
          0;
        }
      } @{$$node->[2]->{attributes}}; # AttrNameRef
      delete $$old_attr->[2]->{owner};
      $$node->[0]->disconnect ($$old_attr->[1]);

      ## 4.
      $$node->[0]->adopt ($attr);
      my $nsurl = ${$$attr->[2]->{namespace_uri} || \''};
      my $ln = ${$$attr->[2]->{local_name}};
      splice @{$$node->[2]->{attributes}}, $i, 0, ($$attr->[1]); # AttrNameRef
      $$node->[2]->{attrs}->{$nsurl}->{$ln} = $$attr->[1]; # AttrValueRef
      $$attr->[2]->{owner} = $$node->[1];
      $$node->[0]->connect ($$attr->[1] => $$node->[1]);

      ## 5.
      $node->_attribute_is
          ($$attr->[2]->{namespace_uri}, $$attr->[2]->{local_name},
           set => 1, changed => 1);
    }
  } else {
    ## 5. Append
    $$node->[0]->adopt ($attr);
    my $nsurl = ${$$attr->[2]->{namespace_uri} || \''};
    my $ln = ${$$attr->[2]->{local_name}};
    push @{$$node->[2]->{attributes} ||= []}, $$attr->[1]; # AttrNameRef
    $$node->[2]->{attrs}->{$nsurl}->{$ln} = $$attr->[1]; # AttrValueRef
    $$attr->[2]->{owner} = $$node->[1];
    $$node->[0]->connect ($$attr->[1] => $$node->[1]);
    $node->_attribute_is
        ($$attr->[2]->{namespace_uri}, $$attr->[2]->{local_name},
         set => 1, added => 1);
  }

  ## 6.
  return $old_attr; # or undef
} # set_attribute_node
*set_attribute_node_ns = \&set_attribute_node;

sub remove_attribute ($$) {
  my $node = $_[0];
  my $name = ''.$_[1];

  # 1.
  if (${$$node->[2]->{namespace_uri} || \''} eq HTML_NS and
      $$node->[0]->{data}->[0]->{is_html}) {
    $name =~ tr/A-Z/a-z/; ## ASCII lowercase
  }

  # 2. Remove
  {
    # Remove 1.
    # XXX mutation if $found

    # Remove 2.
    my $found;
    my $nsref;
    my $lnref;
    @{$$node->[2]->{attributes} or []} = map { # AttrNameRef
      if ($found) {
        $_;
      } elsif (ref $_) {
        if ($$_ eq $name) {
          $found = 1;
          ($nsref, $lnref) = (undef, $_);
          delete $$node->[2]->{attrs}->{''}->{$name}; # AttrValueRef
          ();
        } else {
          $_;
        }
      } else { # node ID
        my $attr_node = $$node->[0]->node ($_);
        if ($attr_node->name eq $name) {
          $found = 1;
          ($nsref, $lnref) = ($$attr_node->[2]->{namespace_uri},
                              $$attr_node->[2]->{local_name});
          delete $$node->[2]->{attrs}
              ->{defined $nsref ? $$nsref : ''}->{$$lnref}; # AttrValueRef
          $$node->[0]->disconnect ($_);
          ();
        } else {
          $_;
        }
      }
    } @{$$node->[2]->{attributes} or []};

    if ($found) {
      $$node->[0]->{revision}++;

      # Remove 3.
      $node->_attribute_is ($nsref, $lnref, removed => 1);
    }
  }
  return;
} # remove_attribute

sub remove_attribute_ns ($$$) {
  my $node = $_[0];
  my $ln = ''.$_[2];
  
  # 1., 2.
  my $nsurl = defined $_[1] ? ''.$_[1] : undef;
  $nsurl = undef if defined $nsurl and not length $nsurl;
  my $attr_id = $$node->[2]->{attrs}->{defined $nsurl ? $nsurl : ''}->{$ln}; # AttrValueRef
  if (defined $attr_id) {
    # Remove 1.
    # XXX mutation if found

    $$node->[0]->{revision}++;

    # Remove 2.
    if (ref $attr_id) { # AttrValueRef
      @{$$node->[2]->{attributes}} = grep { not ref $_ or $$_ ne $ln } @{$$node->[2]->{attributes}}; # AttrNameRef
    } else { # node ID
      $$node->[0]->disconnect ($attr_id);
      @{$$node->[2]->{attributes}} = grep { $_ ne $attr_id } @{$$node->[2]->{attributes}}; # AttrNameRef
    }
    delete $$node->[2]->{attrs}->{defined $nsurl ? $nsurl : ''}->{$ln}; # AttrValueRef

    # Remove 3.
    $node->_attribute_is
        (defined $nsurl ? \$nsurl : undef, \$ln, removed => 1);
  }
  return;
} # remove_attribute_ns

sub remove_attribute_node ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Attr')) {
    _throw Web::DOM::TypeError 'The argument is not an Attr';
  }

  my ($node, $attr) = @_;
  
  if ($$node->[0] eq $$attr->[0] and
      defined $$attr->[2]->{owner} and
      $$node->[1] == $$attr->[2]->{owner}) {
    #
  } else {
    _throw Web::DOM::Exception 'NotFoundError',
        'The specified attribute is not an attribute of the element';
  }

  $$node->[0]->{revision}++;
  
  delete $$node->[2]->{attrs}->{${$$attr->[2]->{namespace_uri} || \''}}->{${$$attr->[2]->{local_name}}}; # AttrValueRef
  @{$$node->[2]->{attributes}} = grep {
    $_ != $$attr->[1];
  } @{$$node->[2]->{attributes}}; # AttrNameRef
  delete $$attr->[2]->{owner};
  $$node->[0]->disconnect ($$attr->[1]);

  $node->_attribute_is ($$attr->[2]->{namespace_uri},
                        $$attr->[2]->{local_name},
                        removed => 1);

  return $attr;
} # remove_attribute_node

my $DOMTokenListAttributeMapping = {
  class => 'class_list',
  rel => 'rel_list',
};

sub _attribute_is ($$$%) {
  my ($self, $nsref, $lnref, %args) = @_;
  ## - attribute is set
  ## - attribute is added
  ## - attribute is changed
  ## - attribute is removed

  if (not defined $nsref and defined $lnref) {
    my $key = $DOMTokenListAttributeMapping->{$$lnref};
    if (defined $key) {
      my $value = $self->get_attribute_ns (undef, $$lnref);
      my %found;
      @{$$self->[2]->{$key} ||= []}
          = grep { length $_ and not $found{$_}++ }
            split /[\x09\x0A\x0C\x0D\x20]+/,
            (defined $value ? $value : '');
    }

    if ($$lnref eq 'style') {
      ## See |Web::DOM::Internal::source_style| and
      ## |Web::DOM::CSSStyleDeclaration::_modified|.
      my $style = $$self->[0]->{source_style}->[$$self->[1]];
      if (defined $style and not $$style->[2]) { # updating flag
        my $value = $self->get_attribute_ns (undef, $$lnref);
        local $$style->[2] = 1; # updating flag
        $style->css_text (defined $value ? $value : '');
      }
    }
  }

  $$self->[0]->{revision}++;
} # _attribute_is

push @EXPORT, qw(_define_reflect_string);
sub _define_reflect_string ($$;$) {
  my ($perl_name, $content_name, $default) = @_;
  my $class = caller;
  $default = '' if not defined $default;
  eval sprintf q{
    *%s::%s = sub ($;$) {
      if (@_ > 1) {
        $_[0]->set_attribute_ns (undef, '%s', $_[1]);
        return unless defined wantarray;
      }

      my $v = $_[0]->get_attribute_ns (undef, '%s');
      return defined $v ? $v : $default;
    };
    1;
  }, $class, $perl_name, $content_name, $content_name or die $@;
} # _define_reflect_string

push @EXPORT, qw(_define_reflect_url);
sub _define_reflect_url ($$) {
  my ($perl_name, $content_name) = @_;
  my $class = caller;
  eval sprintf q{
    *%s::%s = sub ($;$) {
      if (@_ > 1) {
        $_[0]->set_attribute_ns (undef, '%s', $_[1]);
        return unless defined wantarray;
      }

      my $v = $_[0]->get_attribute_ns (undef, '%s');
      if (defined $v) {
        my $w = _resolve_url $v, $_[0]->base_uri;
        return defined $w ? $w : $v;
      } else {
        return '';
      }
    };
    1;
  }, $class, $perl_name, $content_name, $content_name or die $@;
} # _define_reflect_url

push @EXPORT, qw(_define_reflect_neurl);
sub _define_reflect_neurl ($$) {
  my ($perl_name, $content_name) = @_;
  my $class = caller;
  eval sprintf q{
    *%s::%s = sub ($;$) {
      if (@_ > 1) {
        $_[0]->set_attribute_ns (undef, '%s', $_[1]);
        return unless defined wantarray;
      }

      my $v = $_[0]->get_attribute_ns (undef, '%s');
      if (defined $v and length $v) {
        my $w = _resolve_url $v, $_[0]->base_uri;
        return defined $w ? $w : $v;
      } else {
        return '';
      }
    };
    1;
  }, $class, $perl_name, $content_name, $content_name or die $@;
} # _define_reflect_neurl

push @EXPORT, qw(_define_reflect_string_undef);
sub _define_reflect_string_undef ($$) {
  my ($perl_name, $content_name) = @_;
  my $class = caller;
  eval sprintf q{
    *%s::%s = sub ($;$) {
      if (@_ > 1) {
        $_[0]->set_attribute_ns (undef, '%s', defined $_[1] ? $_[1] : '');
        return unless defined wantarray;
      }

      my $v = $_[0]->get_attribute_ns (undef, '%s');
      return defined $v ? $v : '';
    };
    1;
  }, $class, $perl_name, $content_name, $content_name or die $@;
} # _define_reflect_string_undef

push @EXPORT, qw(_define_reflect_enumerated);
sub _define_reflect_enumerated ($$$) {
  my ($perl_name, $content_name, $values) = @_;
  my $class = caller;
  eval sprintf q{
    *%s::%s = sub ($;$) {
      if (@_ > 1) {
        $_[0]->set_attribute_ns (undef, '%s', $_[1]);
        return unless defined wantarray;
      }

      my $v = $_[0]->get_attribute_ns (undef, '%s');
      if (defined $v) {
        $v =~ tr/A-Z/a-z/; ## ASCII case-insensitive.
        if (defined $values->{$v} and not $v =~ /^\#/) {
          return $values->{$v};
        } else {
          return defined $values->{'#invalid'} ? $values->{'#invalid'} :
                 defined $values->{'#missing'} ? $values->{'#missing'} : '';
        }
      } else {
        return defined $values->{'#missing'} ? $values->{'#missing'} : '';
      }
    };
    1;
  }, $class, $perl_name, $content_name, $content_name or die $@;
} # _define_reflect_enumerated

push @EXPORT, qw(_define_reflect_nullable_enumerated);
sub _define_reflect_nullable_enumerated ($$$) {
  my ($perl_name, $content_name, $values) = @_;
  my $class = caller;
  eval sprintf q{
    *%s::%s = sub ($;$) {
      if (@_ > 1) {
        if (defined $_[1]) {
          $_[0]->set_attribute_ns (undef, '%s', $_[1]);
        } else {
          $_[0]->remove_attribute_ns (undef, '%s');
        }
        return unless defined wantarray;
      }

      my $v = $_[0]->get_attribute_ns (undef, '%s');
      if (defined $v) {
        $v =~ tr/A-Z/a-z/; ## ASCII case-insensitive.
        if (defined $values->{$v} and not $v =~ /^\#/) {
          return $values->{$v};
        } else {
          return defined $values->{'#invalid'} ? $values->{'#invalid'} : undef;
        }
      } else {
        return undef;
      }
    };
    1;
  }, $class, $perl_name, $content_name, $content_name, $content_name or die $@;
} # _define_reflect_enumerated

push @EXPORT, qw(_define_reflect_boolean);
sub _define_reflect_boolean ($$) {
  my ($perl_name, $content_name) = @_;
  my $class = caller;
  eval sprintf q{
    *%s::%s = sub ($;$) {
      if (@_ > 1) {
        if ($_[1]) {
          $_[0]->set_attribute_ns (undef, '%s', '');
        } else {
          $_[0]->remove_attribute_ns (undef, '%s');
        }
        return unless defined wantarray;
      }

      return $_[0]->has_attribute_ns (undef, '%s');
    };
    1;
  }, $class, $perl_name, $content_name, $content_name, $content_name or die $@;
} # _define_reflect_boolean

push @EXPORT, qw(_define_reflect_long);
sub _define_reflect_long ($$$) {
  my ($perl_name, $content_name, $get_default) = @_;
  my $class = caller;
  eval sprintf q{
    *%s::%s = sub ($;$) {
      if (@_ > 1) {
        # WebIDL: long
        $_[0]->set_attribute_ns
            (undef, '%s', unpack 'l', pack 'L', $_[1] %% 2**32);
        return unless defined wantarray;
      }

      my $v = $_[0]->get_attribute_ns (undef, '%s');
      if (defined $v and $v =~ /\A[\x09\x0A\x0C\x0D\x20]*([+-]?[0-9]+)/) {
        my $v = $1;
        return 0+$v if -2**31 <= $v and $v <= 2**31-1;
      }
      return $get_default->($_[0]);
    };
    1;
  }, $class, $perl_name, $content_name, $content_name or die $@;
} # _define_reflect_long

push @EXPORT, qw(_define_reflect_long_nn);
sub _define_reflect_long_nn ($$$) {
  my ($perl_name, $content_name, $get_default) = @_;
  my $class = caller;
  eval sprintf q{
    *%s::%s = sub ($;$) {
      if (@_ > 1) {
        # WebIDL: long
        my $v = unpack 'l', pack 'L', $_[1] %% 2**32;
        if ($v < 0) {
          _throw Web::DOM::Exception 'IndexSizeError',
              'The value cannot be set to a negative value';
        }
        $_[0]->set_attribute_ns (undef, '%s', $v);
        return unless defined wantarray;
      }

      my $v = $_[0]->get_attribute_ns (undef, '%s');
      if (defined $v and $v =~ /\A[\x09\x0A\x0C\x0D\x20]*([+-]?[0-9]+)/) {
        my $v = $1;
        return 0+$v if 0 <= $v and $v <= 2**31-1;
      }
      return $get_default->($_[0]);
    };
    1;
  }, $class, $perl_name, $content_name, $content_name or die $@;
} # _define_reflect_long_nn

push @EXPORT, qw(_define_reflect_unsigned_long);
sub _define_reflect_unsigned_long ($$$) {
  my ($perl_name, $content_name, $get_default) = @_;
  my $class = caller;
  eval sprintf q{
    *%s::%s = sub ($;$) {
      if (@_ > 1) {
        # WebIDL: unsigned long
        $_[0]->set_attribute_ns
            (undef, '%s', unpack 'L', pack 'L', $_[1] %% 2**32);
        return unless defined wantarray;
      }

      my $v = $_[0]->get_attribute_ns (undef, '%s');
      if (defined $v and $v =~ /\A[\x09\x0A\x0C\x0D\x20]*([+-]?[0-9]+)/) {
        my $v = $1;
        return 0+$v if 0 <= $v and $v <= 2**31-1;
      }
      return $get_default->($_[0]);
    };
    1;
  }, $class, $perl_name, $content_name, $content_name or die $@;
} # _define_reflect_unsigned_long

push @EXPORT, qw(_define_reflect_unsigned_long_positive);
sub _define_reflect_unsigned_long_positive ($$$) {
  my ($perl_name, $content_name, $get_default) = @_;
  my $class = caller;
  eval sprintf q{
    *%s::%s = sub ($;$) {
      if (@_ > 1) {
        # WebIDL: unsigned long
        my $v = unpack 'L', pack 'L', $_[1] %% 2**32;
        if ($v == 0) {
          _throw Web::DOM::Exception 'IndexSizeError',
              'The value cannot be set to zero';
        }
        $_[0]->set_attribute_ns (undef, '%s', $v);
        return unless defined wantarray;
      }

      my $v = $_[0]->get_attribute_ns (undef, '%s');
      if (defined $v and $v =~ /\A[\x09\x0A\x0C\x0D\x20]*([+-]?[0-9]+)/) {
        my $v = $1;
        return 0+$v if 1 <= $v and $v <= 2**31-1;
      }
      return $get_default->($_[0]);
    };
    1;
  }, $class, $perl_name, $content_name, $content_name or die $@;
} # _define_reflect_unsigned_long_positive

my $SupportedTokensList = {rel => {}, sandbox => {}, dropzone => {}}; # XXX

push @EXPORT, qw(_define_reflect_settable_token_list);
sub _define_reflect_settable_token_list ($$) {
  my ($perl_name, $content_name) = @_;
  my $class = caller;
  my $supported = $SupportedTokensList->{$content_name};
  eval sprintf q{
    *%s::%s = sub ($;$) {
      my $self = $_[0];
      if (@_ > 1) {
        $self->%s->value ($_[1]); # recursive!
        return unless defined wantarray;
      }

      return $$self->[0]->tokens ('%s', $self, sub {
        my $new = $$self->[2]->{%s} || [];
        $self->set_attribute_ns (undef, '%s' => join ' ', @$new)
            if @$new or $self->has_attribute_ns (undef, '%s');
      }, '%s', $supported);
    };
    1;
  }, $class, $perl_name, $perl_name,
     $perl_name, $perl_name, $content_name, $content_name, $content_name
     or die $@;
  $DOMTokenListAttributeMapping->{$content_name} = $perl_name;
} # _define_reflect_settable_token_list

push @EXPORT, qw(_define_reflect_idref);
sub _define_reflect_idref ($$$) {
  my ($perl_name, $content_name, $el_class) = @_;
  my $class = caller;
  eval sprintf q{
    *%s::%s = sub ($;$) {
      if (@_ > 1) {
        # WebIDL: object
        _throw Web::DOM::TypeError 'The argument is not a ' . $el_class
            unless UNIVERSAL::isa ($_[1], $el_class);

        my $id = $_[1]->get_attribute_ns (undef, 'id');
        my $el = defined $id
            ? $_[0]->owner_document->get_element_by_id ($id) : undef;
        if (defined $el and $el eq $_[1]) {
          $_[0]->set_attribute_ns (undef, '%s', $id);
        } else {
          $_[0]->set_attribute_ns (undef, '%s', '');
        }
        return unless defined wantarray;
      }

      my $v = $_[0]->get_attribute_ns (undef, '%s');

      # 1.
      return undef unless defined $v;

      # 2.
      my $cand = $_[0]->owner_document->get_element_by_id ($v);

      # 3.
      return undef unless defined $cand;
      return undef unless $cand->isa ($el_class);

      # 4.
      return $cand;
    };
    1;
  }, $class, $perl_name, $content_name, $content_name, $content_name or die $@;
} # _define_reflect_idref

_define_reflect_string id => 'id';

sub manakai_ids ($) {
  my $id = $_[0]->get_attribute ('id');
  return defined $id ? [$id] : [];
} # manakai_ids

_define_reflect_string class_name => 'class';

sub class_list ($) {
  my $self = $_[0];
  if (@_ > 1) {
    $self->class_name ($_[1]);
    return unless defined wantarray;
  }
  return $$self->[0]->tokens ('class_list', $self, sub {
    $self->set_attribute_ns
        (undef, class => join ' ', @{$$self->[2]->{class_list} ||= []});
  }, 'class');
} # class_list

sub manakai_base_uri ($;$) {
  return undef;
} # manakai_base_uri

sub outer_html ($;$) {
  ## See also: ParentNode->inner_html, Element->insert_adjacent_html
  my $self = $_[0];
  if (@_ > 1) {
    # 1.-2.
    my $parent = $self->parent_node or do { my $v = ''.$_[1]; return };
    my $parent_nt = $parent->node_type;
    my $context = $parent;

    if ($parent_nt == DOCUMENT_NODE) {
      # 3.
      _throw Web::DOM::Exception 'NoModificationAllowedError',
          'Cannot set outer_html of the document element';
    } elsif ($parent_nt == DOCUMENT_FRAGMENT_NODE) {
      # 4.
      $context = $parent->owner_document->create_element ('body');
    }

    # 5.
    my $parser;
    if ($$self->[0]->{data}->[0]->{is_html}) {
      require Web::HTML::Parser;
      $parser = Web::HTML::Parser->new;
    } else {
      require Web::XML::Parser;
      $parser = Web::XML::Parser->new;
      my $orig_onerror = $parser->onerror;
      $parser->onerror (sub {
        my %args = @_;
        $orig_onerror->(@_);
        if (($args{level} || 'm') eq 'm') {
          $parser->throw (sub {
            $parser->onerror (undef);
            undef $parser;
            _throw Web::DOM::Exception 'SyntaxError',
                'The given string is ill-formed as XML';
          });
        }
      });
    }
    # XXX errors should be redirected to the Console object.
    my $new_children = $parser->parse_char_string_with_context
        (defined $_[1] ? ''.$_[1] : '', $context, new Web::DOM::Document);
    my $fragment = $self->owner_document->create_document_fragment;
    $fragment->append_child ($_) for $new_children->to_list;

    # 6.
    $parent->replace_child ($fragment, $self);
    
    return undef unless defined wantarray;
  }

  if ($$self->[0]->{data}->[0]->{is_html}) {
    require Web::HTML::Serializer;
    return ${ Web::HTML::Serializer->new->get_inner_html ([$self]) };
  } else {
    require Web::XML::Serializer;
    return ${ Web::XML::Serializer->new->get_inner_html ([$self]) };
  }
} # outer_html

sub insert_adjacent_html ($$$) {
  my $self = $_[0];
  my $position = ''.$_[1];
  my $v = defined $_[2] ? ''.$_[2] : '';

  my $code = sub {
    ## See also: ParentNode->inner_html, Element->outer_html

    my $context = $_[0];

    if (not $context->node_type == ELEMENT_NODE or
        ($$self->[0]->{data}->[0]->{is_html} and
         $context->manakai_element_type_match (HTML_NS, 'html'))) {
      $context = $self->owner_document->create_element ('body');
    }

    my $parser;
    if ($$self->[0]->{data}->[0]->{is_html}) {
      require Web::HTML::Parser;
      $parser = Web::HTML::Parser->new;
    } else {
      require Web::XML::Parser;
      $parser = Web::XML::Parser->new;
      my $orig_onerror = $parser->onerror;
      $parser->onerror (sub {
        my %args = @_;
        $orig_onerror->(@_);
        if (($args{level} || 'm') eq 'm') {
          $parser->throw (sub {
            $parser->onerror (undef);
            undef $parser;
            _throw Web::DOM::Exception 'SyntaxError',
                'The given string is ill-formed as XML';
          });
        }
      });
    }
    # XXX errors should be redirected to the Console object.
    my $new_children = $parser->parse_char_string_with_context
        ($v, $context, new Web::DOM::Document);
    $parser->onerror (undef);
    undef $parser;

    my $fragment = $self->owner_document->create_document_fragment;
    $fragment->append_child ($_) for $new_children->to_list;

    return $fragment;

  }; # $code

  $self->_insert_adjacent ($position, $code, 'html');
  return;
} # insert_adjacent_html

sub _insert_adjacent ($$$$) {
  my ($self, $position, $code, $html) = @_;
  $position =~ tr/A-Z/a-z/;
  my $context;
  if ($position eq 'beforebegin' or $position eq 'afterend') {
    $context = $self->parent_node;
    if ($html) {
      if (not defined $context or $context->node_type == DOCUMENT_NODE) {
        _throw Web::DOM::Exception 'NoModificationAllowedError',
            'Cannot insert before or after the root element';
      }
    } else {
      return 0 if not defined $context;
    }
  } elsif ($position eq 'afterbegin' or $position eq 'beforeend') {
    $context = $self;
  } else {
    _throw Web::DOM::Exception 'SyntaxError',
        'Unknown position is specified';
  }

  my $node = $code->($context);

  if ($position eq 'beforebegin') {
    $self->parent_node->insert_before ($node, $self);
  } elsif ($position eq 'afterbegin') {
    $self->insert_before ($node, $self->first_child);
  } elsif ($position eq 'beforeend') {
    $self->append_child ($node);
  } elsif ($position eq 'afterend') {
    $self->parent_node->insert_before ($node, $self->next_sibling);
  }
  return 1;
} # _insert_adjacent

push @EXPORT, qw(_define_reflect_child_string);
sub _define_reflect_child_string ($$$) {
  my ($perl_name, $nsurl, $ln) = @_;
  my $class = caller;
  eval sprintf q{
    sub %s::%s ($;$) {
      my $self = $_[0];

      my $el;
      for ($self->child_nodes->to_list) {
        if ($_->node_type == ELEMENT_NODE and
            $_->local_name eq '%s' and
            ($_->namespace_uri || '') eq '%s') {
          $el = $_;
          last;
        }
      }

      if (@_ > 1) {
        if ($el) {
          $el->text_content ($_[1]);
        } else {
          $el = $self->owner_document->create_element_ns ('%s', '%s');
          $el->text_content ($_[1]);
          $self->append_child ($el);
        }
        return unless defined wantarray;
      }

      return $el ? $el->text_content : '';
    }
    1;
  }, $class, $perl_name, $ln, $nsurl, $nsurl, $ln or die $@;
} # _define_reflect_child_string

push @EXPORT, qw(_define_reflect_child_url);
sub _define_reflect_child_url ($$$) {
  my ($perl_name, $nsurl, $ln) = @_;
  my $class = caller;
  eval sprintf q{
    sub %s::%s ($;$) {
      my $self = $_[0];

      my $el;
      for ($self->child_nodes->to_list) {
        if ($_->node_type == ELEMENT_NODE and
            $_->local_name eq '%s' and
            ($_->namespace_uri || '') eq '%s') {
          $el = $_;
          last;
        }
      }

      if (@_ > 1) {
        if ($el) {
          $el->text_content ($_[1]);
        } else {
          $el = $self->owner_document->create_element_ns ('%s', '%s');
          $el->text_content ($_[1]);
          $self->append_child ($el);
        }
        return unless defined wantarray;
      }

      if ($el) {
        my $v = _resolve_url $el->text_content, $el->base_uri;
        return defined $v ? $v : '';
      } else {
        return '';
      }
    }
    1;
  }, $class, $perl_name, $ln, $nsurl, $nsurl, $ln or die $@;
} # _define_reflect_child_url

# XXX scripting enabled flag consideration...

1;

=head1 LICENSE

Copyright 2012-2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
