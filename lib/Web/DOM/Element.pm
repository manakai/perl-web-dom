package Web::DOM::Element;
use strict;
use warnings;
no warnings 'utf8';
our $VERSION = '1.0';
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


## Attributes
##
## An attribute is represented as either:
##
##   - The reference to a string, or
##   - An |Attr| object.
##
## The string reference represents an attribute whose value is the
## referenced string.  It can only be used to represent a
## null-namespace attribute.
## 
## $$node->[2]->{attrs}->{$ns // ''}->{$ln} = (\value or attribute node ID)
## $$node->[2]->{attributes} = [array of (\name or attribute node ID)]
##
## The |attrs| hashref contains the attributes of the node.  The
## |attributes| arrayref, which is used to preserve the order of
## attributes, contains strings and/or |Attr| objects.  Strings refer
## null-namespace attributes in the |attrs| hashref by its local name.

my $InflateAttr = sub ($) {
  my $node = $_[0];
  my $data = {node_type => ATTRIBUTE_NODE,
              local_name => Web::DOM::Internal->text ($$_),
              value => ${$$node->[2]->{attrs}->{''}->{$$_}},
              owner => $$node->[1]};
  my $attr_id = $$node->[0]->add_data ($data);
  $$node->[2]->{attrs}->{''}->{$$_} = $attr_id;
  $$node->[0]->connect ($attr_id => $$node->[1]);
  $_ = $attr_id;
}; # $InflateAttr

sub attributes ($) {
  return ${$_[0]}->[0]->collection ('attributes', $_[0], sub {
    my $node = $_[0];
    for (@{$$node->[2]->{attributes} or []}) {
      $InflateAttr->($node) if ref $_; # $_
    }
    return @{$$node->[2]->{attributes} or []};
  });
} # attributes

sub has_attributes ($) {
  return !!@{${$_[0]}->[2]->{attributes} or []};
} # has_attributes

sub has_attribute ($$) {
  my $node = $_[0];
  my $name = ''.$_[1];

  # 1.
  if (${$$node->[2]->{namespace_uri} || \''} eq HTML_NS and
      $$node->[0]->{data}->[0]->{is_html}) {
    $name =~ tr/A-Z/a-z/; ## ASCII lowercase
  }

  # 2.
  return 1 if ref ($$node->[2]->{attrs}->{''}->{$name} || '');
  for (@{$$node->[2]->{attributes} or []}) {
    if (ref $_) {
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
    if (ref $_) {
      if ($$_ eq $name) {
        return ${$$node->[2]->{attrs}->{''}->{$name}};
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
  my $attr_id = $$node->[2]->{attrs}->{defined $nsurl ? $nsurl : ''}->{$ln};
  if (defined $attr_id) {
    if (ref $attr_id) {
      return $$attr_id;
    } else {
      return $$node->[0]->{data}->[$attr_id]->{value};
    }
  } else {
    return undef;
  }
} # get_attribute_ns

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
    if (ref $_) {
      if ($$_ eq $name) {
        $InflateAttr->($node);
        return $$node->[0]->node ($_);
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
  my $attr_id = $$node->[2]->{attrs}->{defined $nsurl ? $nsurl : ''}->{$ln};
  if (defined $attr_id) {
    if (ref $attr_id) {
      local $_ = \$ln;
      $InflateAttr->($node);
      $attr_id = $_;
      @{$$node->[2]->{attributes}} = map {
        ref $_ && $$_ eq $ln ? $attr_id : $_;
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

  $$node->[0]->children_changed ($$node->[1], ATTRIBUTE_NODE);

  # 3.
  for (@{$$node->[2]->{attributes} or []}) {
    if (ref $_) {
      if ($$_ eq $name) {
        # 5.
        {
          # Change 1.
          # XXX mutation

          # Change 2.
          $$node->[2]->{attrs}->{''}->{$name} = \$value;

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
          $$attr_node->[2]->{value} = $value;

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
        Web::DOM::Internal->text ($name);
    $$node->[2]->{attrs}->{''}->{$name} = \$value;

    # Append 3.
    $node->_attribute_is (undef, \$name, set => 1, added => 1);
  }
  return;
} # set_attribute

sub set_attribute_ns ($$$$) {
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

  my $value = ''.$_[3];

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

  $$node->[0]->children_changed ($$node->[1], ATTRIBUTE_NODE);

  # 9. Set an attribute
  {
    # Set 1.-4.
    my $attr_id = $$node->[2]->{attrs}->{defined $nsurl ? $nsurl : ''}->{$ln};
    if (defined $attr_id) {
      # 6.
      {
        # Change 1.
        # XXX mutation

        # Change 2.
        if (ref $attr_id) {
          $$attr_id = $value;
        } else {
          $$node->[0]->{data}->[$attr_id]->{value} = $value;
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
                      value => $value,
                      owner => $$node->[1]};
          my $attr_id = $$node->[0]->add_data ($data);
          push @{$$node->[2]->{attributes} ||= []}, $attr_id;
          $$node->[2]->{attrs}->{$nsurl}->{$ln} = $attr_id;
          $$node->[0]->connect ($attr_id => $$node->[1]);
        } else {
          push @{$$node->[2]->{attributes} ||= []},
              Web::DOM::Internal->text ($ln);
          $$node->[2]->{attrs}->{''}->{$ln} = \$value;
        }

        # Append 3.
        $node->_attribute_is (defined $nsurl ? \$nsurl : undef, \$ln,
                              set => 1, added => 1);
      }
    }
  }
  return;
} # set_attribute_ns

sub set_attribute_node ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Attr')) {
    _throw Web::DOM::TypeError 'The argument is not an Attr';
  }

  # 1.
  my ($node, $attr) = @_;

  # 2.
  if (defined $$attr->[2]->{owner} and
      not ($$attr->[0] eq $$node->[0] and
           $$attr->[2]->{owner} == $$node->[1])) {
    _throw Web::DOM::Exception 'InUseAttributeError',
        'The specified attribute has already attached to another node';
  }

  # XXX MutationObserver

  # 3. Adopt (simplified)
  $$node->[0]->adopt ($attr);

  $$node->[0]->children_changed ($$node->[1], ATTRIBUTE_NODE);

  # 4.
  my $nsurl = ${$$attr->[2]->{namespace_uri} || \''};
  my $ln = ${$$attr->[2]->{local_name}};
  my $old_attr_id = $$node->[2]->{attrs}->{$nsurl}->{$ln};
  my $old_attr_id_ref = (defined $old_attr_id and ref $old_attr_id);
  if ($old_attr_id_ref and defined wantarray) {
    local $_ = \$ln;
    $InflateAttr->($node);
    $old_attr_id = $_;
  }
  if (defined $old_attr_id and not ref $old_attr_id) {
    delete $$node->[0]->{data}->[$old_attr_id]->{owner};
    $$node->[0]->disconnect ($old_attr_id);
  }

  if (defined $old_attr_id) {
    # 6.
    if ($old_attr_id_ref) {
      @{$$node->[2]->{attributes}} = map {
        (ref $_ && $$_ eq $ln) ? $$attr->[1] : $_;
      } @{$$node->[2]->{attributes}};
    } else {
      @{$$node->[2]->{attributes}} = map {
        (not ref $_ && $_ == $old_attr_id) ? $$attr->[1] : $_;
      } @{$$node->[2]->{attributes}};
    }
  } else {
    # 5.
    push @{$$node->[2]->{attributes} ||= []}, $$attr->[1];
  }
  $$node->[2]->{attrs}->{$nsurl}->{$ln} = $$attr->[1];

  # 7.
  $$attr->[2]->{owner} = $$node->[1];
  $$node->[0]->connect ($$attr->[1] => $$node->[1]);

  if (defined $old_attr_id) {
    # 9.
    $node->_attribute_is
        ($$attr->[2]->{namespace_uri}, $$attr->[2]->{local_name},
         set => 1, changed => 1);
  } else {
    # 8.
    $node->_attribute_is
        ($$attr->[2]->{namespace_uri}, $$attr->[2]->{local_name},
         set => 1, added => 1);
  }
  
  return $$node->[0]->node ($old_attr_id)
      if defined $old_attr_id and not ref $old_attr_id;
  return undef;
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
    @{$$node->[2]->{attributes} or []} = map {
      if ($found) {
        $_;
      } elsif (ref $_) {
        if ($$_ eq $name) {
          $found = 1;
          ($nsref, $lnref) = (undef, $_);
          delete $$node->[2]->{attrs}->{''}->{$name};
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
              ->{defined $nsref ? $$nsref : ''}->{$$lnref};
          $$node->[0]->disconnect ($_);
          ();
        } else {
          $_;
        }
      }
    } @{$$node->[2]->{attributes} or []};

    if ($found) {
      $$node->[0]->children_changed ($$node->[1], ATTRIBUTE_NODE);

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
  my $attr_id = $$node->[2]->{attrs}->{defined $nsurl ? $nsurl : ''}->{$ln};
  if (defined $attr_id) {
    # Remove 1.
    # XXX mutation if found

    $$node->[0]->children_changed ($$node->[1], ATTRIBUTE_NODE);

    # Remove 2.
    if (ref $attr_id) {
      @{$$node->[2]->{attributes}} = grep { not ref $_ or $$_ ne $ln } @{$$node->[2]->{attributes}};
    } else {
      $$node->[0]->disconnect ($attr_id);
      @{$$node->[2]->{attributes}} = grep { $_ ne $attr_id } @{$$node->[2]->{attributes}};
    }
    delete $$node->[2]->{attrs}->{defined $nsurl ? $nsurl : ''}->{$ln};

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

  $$node->[0]->children_changed ($$node->[1], ATTRIBUTE_NODE);
  
  delete $$node->[2]->{attrs}->{${$$attr->[2]->{namespace_uri} || \''}}->{${$$attr->[2]->{local_name}}};
  @{$$node->[2]->{attributes}} = grep {
    $_ != $$attr->[1];
  } @{$$node->[2]->{attributes}};
  delete $$attr->[2]->{owner};
  $$node->[0]->disconnect ($$attr->[1]);

  $node->_attribute_is ($$attr->[2]->{namespace_uri},
                        $$attr->[2]->{local_name},
                        removed => 1);

  return $attr;
} # remove_attribute_node

sub _attribute_is ($$$%) {
  my ($self, $nsref, $lnref, %args) = @_;
  ## - attribute is set
  ## - attribute is added
  ## - attribute is changed
  ## - attribute is removed

  if (not defined $nsref and defined $lnref and $$lnref eq 'class') {
    my $value = $self->get_attribute_ns (undef, $$lnref);
    my %found;
    @{$$self->[2]->{class_list} ||= []}
        = grep { length $_ and not $found{$_}++ }
          split /[\x09\x0A\x0C\x0D\x20]+/,
          (defined $value ? $value : '');
  }

  $$self->[0]->children_changed ($$self->[1], ATTRIBUTE_NODE);
} # _attribute_is

push @EXPORT, qw(_define_reflect_string);
sub _define_reflect_string ($$) {
  my ($perl_name, $content_name) = @_;
  my $class = caller;
  eval sprintf q{
    sub %s::%s ($;$) {
      if (@_ > 1) {
        $_[0]->set_attribute_ns (undef, '%s', $_[1]);
        return unless defined wantarray;
      }

      my $v = $_[0]->get_attribute_ns (undef, '%s');
      return defined $v ? $v : '';
    }
    1;
  }, $class, $perl_name, $content_name, $content_name or die $@;
} # _define_reflect_string

push @EXPORT, qw(_define_reflect_string_undef);
sub _define_reflect_string_undef ($$) {
  my ($perl_name, $content_name) = @_;
  my $class = caller;
  eval sprintf q{
    sub %s::%s ($;$) {
      if (@_ > 1) {
        $_[0]->set_attribute_ns (undef, '%s', defined $_[1] ? $_[1] : '');
        return unless defined wantarray;
      }

      my $v = $_[0]->get_attribute_ns (undef, '%s');
      return defined $v ? $v : '';
    }
    1;
  }, $class, $perl_name, $content_name, $content_name or die $@;
} # _define_reflect_string_undef

push @EXPORT, qw(_define_reflect_enumerated);
sub _define_reflect_enumerated ($$$) {
  my ($perl_name, $content_name, $values) = @_;
  my $class = caller;
  eval sprintf q{
    sub %s::%s ($;$) {
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
    }
    1;
  }, $class, $perl_name, $content_name, $content_name or die $@;
} # _define_reflect_enumerated

push @EXPORT, qw(_define_reflect_boolean);
sub _define_reflect_boolean ($$) {
  my ($perl_name, $content_name) = @_;
  my $class = caller;
  eval sprintf q{
    sub %s::%s ($;$) {
      if (@_ > 1) {
        if ($_[1]) {
          $_[0]->set_attribute_ns (undef, '%s', '');
        } else {
          $_[0]->remove_attribute_ns (undef, '%s');
        }
        return unless defined wantarray;
      }

      return $_[0]->has_attribute_ns (undef, '%s');
    }
    1;
  }, $class, $perl_name, $content_name, $content_name, $content_name or die $@;
} # _define_reflect_boolean

push @EXPORT, qw(_define_reflect_long);
sub _define_reflect_long ($$$) {
  my ($perl_name, $content_name, $get_default) = @_;
  my $class = caller;
  eval sprintf q{
    sub %s::%s ($;$) {
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
    }
    1;
  }, $class, $perl_name, $content_name, $content_name or die $@;
} # _define_reflect_long

push @EXPORT, qw(_define_reflect_long_nn);
sub _define_reflect_long_nn ($$$) {
  my ($perl_name, $content_name, $get_default) = @_;
  my $class = caller;
  eval sprintf q{
    sub %s::%s ($;$) {
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
    }
    1;
  }, $class, $perl_name, $content_name, $content_name or die $@;
} # _define_reflect_long_nn

push @EXPORT, qw(_define_reflect_unsigned_long);
sub _define_reflect_unsigned_long ($$$) {
  my ($perl_name, $content_name, $get_default) = @_;
  my $class = caller;
  eval sprintf q{
    sub %s::%s ($;$) {
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
    }
    1;
  }, $class, $perl_name, $content_name, $content_name or die $@;
} # _define_reflect_unsigned_long

push @EXPORT, qw(_define_reflect_unsigned_long_positive);
sub _define_reflect_unsigned_long_positive ($$$) {
  my ($perl_name, $content_name, $get_default) = @_;
  my $class = caller;
  eval sprintf q{
    sub %s::%s ($;$) {
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
    }
    1;
  }, $class, $perl_name, $content_name, $content_name or die $@;
} # _define_reflect_unsigned_long_positive

push @EXPORT, qw(_define_reflect_idref);
sub _define_reflect_idref ($$$) {
  my ($perl_name, $content_name, $el_class) = @_;
  my $class = caller;
  eval sprintf q{
    sub %s::%s ($;$) {
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
    }
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
  return $$self->[0]->tokens ('class_list', $self, sub {
    $self->set_attribute_ns
        (undef, class => join ' ', @{$$self->[2]->{class_list} ||= []});
  });
} # class_list

sub manakai_base_uri ($;$) {
  if (@_ > 1) {
    if (defined $_[1]) {
      ${$_[0]}->[2]->{manakai_base_uri} = ''.$_[1];
    } else {
      delete ${$_[0]}->[2]->{manakai_base_uri}
    }
  }
  return ${$_[0]}->[2]->{manakai_base_uri};
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
  ## See also: ParentNode->inner_html, Element->outer_html
  my $self = $_[0];

  # 1.
  my $position = ''.$_[1];
  $position =~ tr/A-Z/a-z/;
  my $context;
  if ($position eq 'beforebegin' or $position eq 'afterend') {
    $context = $self->parent_node;
    if (not defined $context or $context->node_type == DOCUMENT_NODE) {
      my $v = ''.$_[2];
      _throw Web::DOM::Exception 'NoModificationAllowedError',
          'Cannot insert before or after the root element';
    }
  } elsif ($position eq 'afterbegin' or $position eq 'beforeend') {
    $context = $self;
  } else {
    my $v = ''.$_[2];
    _throw Web::DOM::Exception 'SyntaxError',
        'Unknown position is specified';
  }

  # 2.
  if (not $context->node_type == ELEMENT_NODE or
      ($$self->[0]->{data}->[0]->{is_html} and
       $context->manakai_element_type_match (HTML_NS, 'html'))) {
    $context = $self->owner_document->create_element ('body');
  }

  # 3.
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
          _throw Web::DOM::Exception 'SyntaxError',
              'The given string is ill-formed as XML';
        });
      }
    });
  }
  # XXX errors should be redirected to the Console object.
  my $new_children = $parser->parse_char_string_with_context
      (defined $_[2] ? ''.$_[2] : '', $context, new Web::DOM::Document);
  my $fragment = $self->owner_document->create_document_fragment;
  $fragment->append_child ($_) for $new_children->to_list;

  # 4.
  if ($position eq 'beforebegin') {
    $self->parent_node->insert_before ($fragment, $self);
  } elsif ($position eq 'afterbegin') {
    $self->insert_before ($fragment, $self->first_child);
  } elsif ($position eq 'beforeend') {
    $self->append_child ($fragment);
  } elsif ($position eq 'afterend') {
    $self->parent_node->insert_before ($fragment, $self->next_sibling);
  }
  return;
} # insert_adjacent_html

# XXX scripting enabled flag consideration...

1;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
