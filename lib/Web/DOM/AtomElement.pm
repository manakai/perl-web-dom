package Web::DOM::AtomElement;
use strict;
use warnings;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::Element);
use Web::DOM::Element;
use Web::DOM::Internal;

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
      my $el = $self->owner_document->create_element ('div');
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

use Web::DOM::Node;
sub name_element ($) {
  my $self = $_[0];
  for ($self->child_nodes->to_list) {
    if ($_->node_type == ELEMENT_NODE and
        $_->local_name eq 'name' and
        ($_->namespace_uri || '') eq ATOM_NS) {
      return $_;
    }
  }
  if (${$_[0]}->[0]->{config}->{manakai_create_child_element}) {
    my $el = $self->owner_document->create_element_ns (ATOM_NS, 'name');
    return $self->append_child ($el);
  } else {
    return undef;
  }
} # name_element

package Web::DOM::AtomAuthorElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomPersonConstruct);
package Web::DOM::AtomContributorElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomPersonConstruct);

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
