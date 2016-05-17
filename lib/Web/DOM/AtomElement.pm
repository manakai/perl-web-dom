package Web::DOM::AtomElement;
use strict;
use warnings;
our $VERSION = '2.0';
push our @ISA, qw(Web::DOM::Element);
use Web::DOM::Element;
use Web::DOM::Internal;
use Web::DOM::Node;

sub _define_atom_child_element ($$) {
  eval sprintf q{
    sub %s::%s ($) {
      my $self = $_[0];
      for ($self->child_nodes->to_list) {
        if ($_->node_type == ELEMENT_NODE and
            $_->local_name eq '%s' and
            ($_->namespace_uri || '') eq ATOM_NS) {
          return $_;
        }
      }
      if (${$_[0]}->[0]->{config}->{manakai_create_child_element}) {
        my $el = $self->owner_document->create_element_ns (ATOM_NS, '%s');
        if ($self->local_name eq 'feed') {
          return $self->insert_before ($el, $self->entry_elements->[0]);
        } else {
          return $self->append_child ($el);
        }
      } else {
        return undef;
      }
    }
    1;
  }, scalar caller, $_[0], $_[1], $_[1] or die $@;
} # _define_atom_child_element

sub _define_atom_child_element_list ($$;$) {
  eval sprintf q{
    sub %s::%s ($) {
      my $self = shift;
      return $$self->[0]->collection ('%s', $self, sub {
        my $node = $_[0];
        return grep {
          $$node->[0]->{data}->[$_]->{node_type} == ELEMENT_NODE and
          ${$$node->[0]->{data}->[$_]->{namespace_uri} || \''} eq '%s' and
          ${$$node->[0]->{data}->[$_]->{local_name}} eq '%s';
        } @{$$node->[0]->{data}->[$$node->[1]]->{child_nodes} or []};
      });
    }
    1;
  }, scalar caller, $_[0], $_[0], $_[2] || ATOM_NS, $_[1] or die $@;
} # _define_atom_child_element_list

sub xmlbase ($;$) {
  $_[0]->set_attribute_ns (XML_NS, ['xml', 'base'] => $_[1]) if @_ > 1;
  my $value = $_[0]->get_attribute_ns (XML_NS, 'base');
  return defined $value ? $value : '';
} # xmlbase

sub xmllang ($;$) {
  $_[0]->set_attribute_ns (XML_NS, ['xml', 'lang'] => $_[1]) if @_ > 1;
  my $value = $_[0]->get_attribute_ns (XML_NS, 'lang');
  return defined $value ? $value : '';
} # xmllang

package Web::DOM::AtomIdElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
package Web::DOM::AtomIconElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
package Web::DOM::AtomNameElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
package Web::DOM::AtomUriElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
package Web::DOM::AtomEmailElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
package Web::DOM::AtomLogoElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);

package Web::DOM::AtomTextConstruct;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
use Web::DOM::Internal;
use Web::DOM::Node;
use Web::DOM::Element;

_define_reflect_string type => 'type', 'text';

sub container ($) {
  my $self = $_[0];
  my $type = $self->get_attribute_ns (undef, 'type');
  if (defined $type and $type eq 'xhtml') {
    for ($self->child_nodes->to_list) {
      if ($_->node_type == ELEMENT_NODE and
          $_->local_name eq 'div' and
          ($_->namespace_uri || '') eq HTML_NS) {
        return $_;
      }
    }
    if (${$_[0]}->[0]->{config}->{manakai_create_child_element}) {
      my $el = $self->owner_document->create_element_ns (HTML_NS, 'div');
      return $self->append_child ($el);
    } else {
      return undef;
    }
  } else {
    return $self;
  }
} # container

package Web::DOM::AtomRightsElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomTextConstruct);
package Web::DOM::AtomSubtitleElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomTextConstruct);
package Web::DOM::AtomSummaryElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomTextConstruct);
package Web::DOM::AtomTitleElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomTextConstruct);

package Web::DOM::AtomPersonConstruct;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
use Web::DOM::Internal;
use Web::DOM::Element;

_define_reflect_child_string name => ATOM_NS, 'name';
_define_reflect_child_url uri => ATOM_NS, 'uri';
_define_reflect_child_string email => ATOM_NS, 'email';

Web::DOM::AtomElement::_define_atom_child_element name_element => 'name';

package Web::DOM::AtomAuthorElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomPersonConstruct);
package Web::DOM::AtomContributorElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomPersonConstruct);

package Web::DOM::AtomDateConstruct;
our $VERSION = '2.0';
push our @ISA, qw(Web::DOM::AtomElement);
use Web::DOM::TypeError;

sub value ($;$) {
  if (@_ > 1) {
    # WebIDL DOMTimeStamp (= WebIDL double in DOMPERL)
    my $value = 0+$_[1];
    if ($value =~ /\A-?(?:[Nn]a[Nn]|[Ii]nf)\z/) {
      _throw Web::DOM::TypeError "The value is out of range";
    }

    require Web::DateTime;
    my $dt = Web::DateTime->new_from_unix_time ($value);
    if ($dt->year >= 0) {
      $_[0]->text_content ($dt->to_global_date_and_time_string);
    }
    return unless defined wantarray;
  }

  require Web::DateTime::Parser;
  my $parser = Web::DateTime::Parser->new;
  $parser->onerror (sub { }); # XXX console
  my $dt = $parser->parse_rfc3339_date_time_string ($_[0]->text_content);
  if (defined $dt) {
    return $dt->to_unix_number;
  } else {
    return 0;
  }
} # value

package Web::DOM::AtomPublishedElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomDateConstruct);
package Web::DOM::AtomUpdatedElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomDateConstruct);

package Web::DOM::AtomFeedElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
use Web::DOM::Internal;
use Web::DOM::Element;

_define_reflect_child_string atom_id => ATOM_NS, 'id';

_define_reflect_child_url icon => ATOM_NS, 'icon';
_define_reflect_child_url logo => ATOM_NS, 'logo';

Web::DOM::AtomElement::_define_atom_child_element
    generator_element => 'generator';
Web::DOM::AtomElement::_define_atom_child_element
    subtitle_element => 'subtitle';
Web::DOM::AtomElement::_define_atom_child_element
    title_element => 'title';
Web::DOM::AtomElement::_define_atom_child_element
    updated_element => 'updated';
Web::DOM::AtomElement::_define_atom_child_element
    rights_element => 'rights';
Web::DOM::AtomElement::_define_atom_child_element_list
    author_elements => 'author';
Web::DOM::AtomElement::_define_atom_child_element_list
    category_elements => 'category';
Web::DOM::AtomElement::_define_atom_child_element_list
    contributor_elements => 'contributor';
Web::DOM::AtomElement::_define_atom_child_element_list
    link_elements => 'link';
Web::DOM::AtomElement::_define_atom_child_element_list
    entry_elements => 'entry';

sub get_entry_element_by_id {
  my $id = ''.$_[1];
  return undef unless length $id;

  for (@{$_[0]->entry_elements}) {
    if ($_->atom_id eq $id) {
      return $_;
    }
  }

  return undef;
} # get_entry_element_by_id

sub add_new_entry ($$;$$) {
  my $doc = $_[0]->owner_document;

  # 1.
  my $entry = $doc->create_element_ns (ATOM_NS, 'entry');

  # 3.
  my $id = $doc->create_element_ns (ATOM_NS, 'id');
  $id->text_content ($_[1]);
  $entry->append_child ($id);

  # 4.
  my $title = $doc->create_element_ns (ATOM_NS, 'title');
  $title->text_content (defined $_[2] ? $_[2] : '');
  $entry->append_child ($title);

  # 2.
  $entry->set_attribute_ns
      (XML_NS, ['xml', 'lang'] => defined $_[3] ? $_[3] : '');

  # 5.
  my $updated = $doc->create_element_ns (ATOM_NS, 'updated');
  $updated->value (time);
  $entry->append_child ($updated);

  # 6.-7.
  return $_[0]->append_child ($entry);
} # add_new_entry

package Web::DOM::AtomEntryElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
use Web::DOM::Internal;
use Web::DOM::Element;

Web::DOM::AtomElement::_define_atom_child_element_list
    author_elements => 'author';
Web::DOM::AtomElement::_define_atom_child_element_list
    category_elements => 'category';
Web::DOM::AtomElement::_define_atom_child_element
    content_element => 'content';
Web::DOM::AtomElement::_define_atom_child_element_list
    contributor_elements => 'contributor';
_define_reflect_child_string atom_id => ATOM_NS, 'id';
Web::DOM::AtomElement::_define_atom_child_element_list
    link_elements => 'link';
Web::DOM::AtomElement::_define_atom_child_element
    published_element => 'published';
Web::DOM::AtomElement::_define_atom_child_element
    rights_element => 'rights';
Web::DOM::AtomElement::_define_atom_child_element
    source_element => 'source';
Web::DOM::AtomElement::_define_atom_child_element
    summary_element => 'summary';
Web::DOM::AtomElement::_define_atom_child_element
    title_element => 'title';
Web::DOM::AtomElement::_define_atom_child_element
    updated_element => 'updated';
Web::DOM::AtomElement::_define_atom_child_element_list
    thread_in_reply_to_elements => 'in-reply-to', ATOM_THREAD_NS;

sub entry_author_elements ($) {
  # 1.
  my $list = $_[0]->author_elements;
  return $list if @$list;

  # 2.
  my $source = $_[0]->source_element;
  if ($source) {
    return $source->author_elements;
  }

  # 3.
  my $parent = $_[0]->parent_node;
  if ($parent and $parent->manakai_element_type_match (ATOM_NS, 'feed')) {
    return $parent->author_elements;
  }

  # 4.
  return $list;
} # entry_author_elements

sub entry_rights_element ($) {
  # 1.
  for (@{$_[0]->children}) {
    return $_ if $_->manakai_element_type_match (ATOM_NS, 'rights');
  }

  # 2.
  my $parent = $_[0]->parent_node;
  if ($parent and $parent->manakai_element_type_match (ATOM_NS, 'feed')) {
    for (@{$parent->children}) {
      return $_ if $_->manakai_element_type_match (ATOM_NS, 'rights');
    }
  }

  # 3.
  return $_[0]->rights_element; # or undef
} # entry_rights_element

package Web::DOM::AtomSourceElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
use Web::DOM::Internal;
use Web::DOM::Element;

Web::DOM::AtomElement::_define_atom_child_element_list
    author_elements => 'author';
Web::DOM::AtomElement::_define_atom_child_element_list
    category_elements => 'category';
Web::DOM::AtomElement::_define_atom_child_element_list
    contributor_elements => 'contributor';
Web::DOM::AtomElement::_define_atom_child_element
    generator_element => 'generator';
_define_reflect_child_string atom_id => ATOM_NS, 'id';
_define_reflect_child_url icon => ATOM_NS, 'icon';
_define_reflect_child_url logo => ATOM_NS, 'logo';
Web::DOM::AtomElement::_define_atom_child_element_list
    link_elements => 'link';
Web::DOM::AtomElement::_define_atom_child_element
    rights_element => 'rights';
Web::DOM::AtomElement::_define_atom_child_element
    subtitle_element => 'subtitle';
Web::DOM::AtomElement::_define_atom_child_element
    title_element => 'title';
Web::DOM::AtomElement::_define_atom_child_element
    updated_element => 'updated';

package Web::DOM::AtomContentElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
use Web::DOM::Internal;
use Web::DOM::Node;
use Web::DOM::Element;

_define_reflect_string type => 'type', 'text';
_define_reflect_url src => 'src';

sub container ($) {
  my $self = $_[0];
  my $type = $self->get_attribute_ns (undef, 'type');
  if (defined $type and $type eq 'xhtml') {
    for ($self->child_nodes->to_list) {
      if ($_->node_type == ELEMENT_NODE and
          $_->local_name eq 'div' and
          ($_->namespace_uri || '') eq HTML_NS) {
        return $_;
      }
    }
    if (${$_[0]}->[0]->{config}->{manakai_create_child_element}) {
      my $el = $self->owner_document->create_element_ns (HTML_NS, 'div');
      return $self->append_child ($el);
    } else {
      return undef;
    }
  } elsif ($_[0]->has_attribute_ns (undef, 'src')) {
    return undef;
  } else {
    return $self;
  }
} # container

package Web::DOM::AtomCategoryElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
use Web::DOM::Element;

_define_reflect_string term => 'term';
_define_reflect_string label => 'label';
_define_reflect_url scheme => 'scheme';

package Web::DOM::AtomGeneratorElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
use Web::DOM::Element;

_define_reflect_string version => 'version';
_define_reflect_url uri => 'uri';

package Web::DOM::AtomLinkElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
use Web::DOM::Internal;
use Web::DOM::Element;

_define_reflect_url href => 'href';
_define_reflect_string hreflang => 'hreflang';
_define_reflect_string title => 'title';
_define_reflect_string length => 'length';

sub rel ($;$) {
  if (@_ > 1) {
    my $value = ''.$_[1];
    if ($value =~ m{\Ahttp://www.iana.org/assignments/relation/([^:\#/?]+)\z}) {
      $_[0]->set_attribute_ns (undef, rel => $1);
    } else {
      $_[0]->set_attribute_ns (undef, rel => $value);
    }
  }

  my $value = $_[0]->get_attribute_ns (undef, 'rel');
  return '' unless defined $value;
  return $value if $value =~ /:/;
  return q<http://www.iana.org/assignments/relation/> . $value;
} # rel

sub type ($;$) {
  if (@_ > 1) {
    $_[0]->set_attribute_ns (undef, type => $_[1]);
    return unless defined wantarray;
  }

  my $type = $_[0]->get_attribute_ns (undef, 'type');
  return $type if defined $type;
  if ($_[0]->rel eq q<http://www.iana.org/assignments/relation/replies>) {
    return q<application/atom+xml>;
  } else {
    return '';
  }
} # type

sub thread_count ($;$) {
  if (@_ > 1) {
    # WebIDL: unsigned long
    $_[0]->set_attribute_ns
        (ATOM_THREAD_NS, 'thr:count', unpack 'L', pack 'L', $_[1] % 2**32);
    return unless defined wantarray;
  }

  my $v = $_[0]->get_attribute_ns (ATOM_THREAD_NS, 'count');
  if (defined $v and $v =~ /\A[\x09\x0A\x0C\x0D\x20]*([+-]?[0-9]+)/) {
    my $v = $1;
    return 0+$v if 0 <= $v and $v <= 2**31-1;
  }
  return 0;
} # thread_count

push our @CARP_NOT, qw(Web::DOM::AtomUpdatedElement);
sub thread_updated ($;$) {
  my $el = $_[0]->owner_document->create_element_ns (ATOM_NS, 'updated');
  if (@_ > 1) {
    $el->value ($_[1]);
    $_[0]->set_attribute_ns
        (ATOM_THREAD_NS, 'thr:updated' => $el->text_content)
        if $el->first_child;
    return unless defined wantarray;
  }

  my $value = $_[0]->get_attribute_ns (ATOM_THREAD_NS, 'updated');
  $el->text_content (defined $value ? $value : '');
  return $el->value;
} # thread_updated

package Web::DOM::AtomThreadInReplyToElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
use Web::DOM::Element;

_define_reflect_url href => 'href';
_define_reflect_url ref => 'ref';
_define_reflect_url source => 'source';
_define_reflect_string type => 'type';

package Web::DOM::AtomThreadTotalElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);

sub value ($;$) {
  if (@_ > 1) {
    # WebIDL: unsigned long
    $_[0]->text_content (unpack 'L', pack 'L', $_[1] % 2**32);
    return unless defined wantarray;
  }

  my $v = $_[0]->text_content;
  if (defined $v and $v =~ /\A[\x09\x0A\x0C\x0D\x20]*([+-]?[0-9]+)/) {
    my $v = $1;
    return 0+$v if 0 <= $v and $v <= 2**31-1;
  }
  return 0;
} # value

1;

=head1 LICENSE

Copyright 2013-2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
