package Web::DOM::DocumentType;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;
use Web::DOM::ChildNode;
push our @ISA, qw(Web::DOM::Node Web::DOM::ChildNode);
use Web::DOM::Internal;

*node_name = \&name;

sub name ($) {
  return ${${$_[0]}->[2]->{name}};
} # name

sub public_id ($) {
  if (@_ > 1) {
    ${$_[0]}->[2]->{public_id} = Web::DOM::Internal->text
        (defined $_[1] ? ''.$_[1] : '');
  }
  return ${${$_[0]}->[2]->{public_id}};
} # public_id

sub system_id ($) {
  if (@_ > 1) {
    ${$_[0]}->[2]->{system_id} = Web::DOM::Internal->text
        (defined $_[1] ? ''.$_[1] : '');
  }
  return ${${$_[0]}->[2]->{system_id}};
} # system_id

sub declaration_base_uri ($;$) {
  return $_[0]->base_uri;
} # declaration_base_uri

*manakai_declaration_base_uri = \&declaration_base_uri;

sub element_types ($) {
  return ${$_[0]}->[0]->collection ('element_types', $_[0], sub {
    my $int = ${$_[0]}->[0];
    return sort {
      ${$int->{data}->[$a]->{node_name}} cmp ${$int->{data}->[$b]->{node_name}};
    } grep { defined $_ } values %{${$_[0]}->[2]->{element_types} or {}};
  });
} # element_types

sub general_entities ($) {
  return ${$_[0]}->[0]->collection ('general_entities', $_[0], sub {
    my $int = ${$_[0]}->[0];
    return sort {
      ${$int->{data}->[$a]->{name}} cmp ${$int->{data}->[$b]->{name}};
    } grep { defined $_ } values %{${$_[0]}->[2]->{general_entities} or {}};
  });
} # general_entities

*entities = \&general_entities;

sub notations ($) {
  return ${$_[0]}->[0]->collection ('notations', $_[0], sub {
    my $int = ${$_[0]}->[0];
    return sort {
      ${$int->{data}->[$a]->{name}} cmp ${$int->{data}->[$b]->{name}};
    } grep { defined $_ } values %{${$_[0]}->[2]->{notations} or {}};
  });
} # notations

sub get_element_type_definition_node ($$) {
  my $id = ${$_[0]}->[2]->{element_types}->{''.$_[1]};
  return defined $id ? ${$_[0]}->[0]->node ($id) : undef;
} # get_element_type_definition_node

sub get_general_entity_node ($$) {
  my $id = ${$_[0]}->[2]->{general_entities}->{''.$_[1]};
  return defined $id ? ${$_[0]}->[0]->node ($id) : undef;
} # get_general_entity_node

sub get_notation_node ($$) {
  my $id = ${$_[0]}->[2]->{notations}->{''.$_[1]};
  return defined $id ? ${$_[0]}->[0]->node ($id) : undef;
} # get_notation_node

sub set_element_type_definition_node ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::ElementTypeDefinition')) {
    _throw Web::DOM::TypeError 'The argument is not an ElementTypeDefinition';
  }
  return $_[0]->_set_node ('element_types', $_[1]);
} # set_element_type_definition_node

sub set_general_entity_node ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Entity')) {
    _throw Web::DOM::TypeError 'The argument is not an Entity';
  }
  return $_[0]->_set_node ('general_entities', $_[1]);
} # set_general_entity_node

sub set_notation_node ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Notation')) {
    _throw Web::DOM::TypeError 'The argument is not a Notation';
  }
  return $_[0]->_set_node ('notations', $_[1]);
} # set_notation_node

sub _set_node ($$$) {
  my ($node, $key, $obj) = @_;

  # 1.
  if (defined $$obj->[2]->{owner} and
      not ($$obj->[0] eq $$node->[0] and
           $$obj->[2]->{owner} == $$node->[1])) {
    _throw Web::DOM::Exception 'HierarchyRequestError',
        'The specified node has already attached to another node';
  }

  # 2. Adopt (simplified)
  $$node->[0]->adopt ($obj);
  # XXX Adopting steps??

  # 3.-4.
  my $obj_name = $obj->node_name;
  my $old_node_id = $$node->[2]->{$key}->{$obj_name};
  if (defined $old_node_id) {
    # Remove 1.
    #

    # 2.-3.
    #delete $$node->[2]->{$key}->{$obj_name};
    delete $$node->[0]->{data}->[$old_node_id]->{owner};
    $$node->[0]->disconnect ($old_node_id);

    # 4.
    #
  }

  # 5.-6.
  $$node->[2]->{$key}->{$obj_name} = $$obj->[1];
  $$obj->[2]->{owner} = $$node->[1];
  $$node->[0]->connect ($$obj->[1] => $$node->[1]);
  $$node->[0]->{revision}++;

  # 7.
  if (defined $old_node_id) {
    return $$node->[0]->node ($old_node_id);
  } else {
    return undef;
  }
} # _set_node

sub remove_element_type_definition_node ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::ElementTypeDefinition')) {
    _throw Web::DOM::TypeError 'The argument is not an ElementTypeDefinition';
  }
  my ($node, $obj) = @_;

  # 1.
  if ($$node->[0] eq $$obj->[0] and
      defined $$obj->[2]->{owner} and
      $$node->[1] == $$obj->[2]->{owner}) {
    #
  } else {
    _throw Web::DOM::Exception 'NotFoundError',
        'The specified node is not attached to the context object';
  }

  # 2.-3.
  delete $$node->[2]->{element_types}->{${$$obj->[2]->{node_name}}};
  delete $$obj->[2]->{owner};
  $$node->[0]->disconnect ($$obj->[1]);
  $$node->[0]->{revision}++;

  # 4.
  return $obj;
} # remove_element_type_definition_node

sub remove_general_entity_node ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Entity')) {
    _throw Web::DOM::TypeError 'The argument is not an Entity';
  }
  my ($node, $obj) = @_;

  # 1.
  if ($$node->[0] eq $$obj->[0] and
      defined $$obj->[2]->{owner} and
      $$node->[1] == $$obj->[2]->{owner}) {
    #
  } else {
    _throw Web::DOM::Exception 'NotFoundError',
        'The specified node is not attached to the context object';
  }

  # 2.-3.
  delete $$node->[2]->{general_entities}->{${$$obj->[2]->{name}}};
  delete $$obj->[2]->{owner};
  $$node->[0]->disconnect ($$obj->[1]);
  $$node->[0]->{revision}++;

  # 4.
  return $obj;
} # remove_general_entity_node

sub remove_notation_node ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Notation')) {
    _throw Web::DOM::TypeError 'The argument is not a Notation';
  }
  my ($node, $obj) = @_;

  # 1.
  if ($$node->[0] eq $$obj->[0] and
      defined $$obj->[2]->{owner} and
      $$node->[1] == $$obj->[2]->{owner}) {
    #
  } else {
    _throw Web::DOM::Exception 'NotFoundError',
        'The specified node is not attached to the context object';
  }

  # 2.-3.
  delete $$node->[2]->{notations}->{${$$obj->[2]->{name}}};
  delete $$obj->[2]->{owner};
  $$node->[0]->disconnect ($$obj->[1]);
  $$node->[0]->{revision}++;

  # 4.
  return $obj;
} # remove_notations_node

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
