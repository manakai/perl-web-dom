package Web::DOM::NamedNodeMap;
use strict;
use warnings;
use Web::DOM::Collection;
push our @ISA, qw(Web::DOM::Collection);
our $VERSION = '2.0';
push our @CARP_NOT, qw(
  Web::DOM::Element Web::DOM::DocumentType Web::DOM::ElementTypeDefinition
);
use Web::DOM::Internal;
use Web::DOM::Node;
use Web::DOM::TypeError;
use Web::DOM::Exception;

use overload
    '%{}' => sub {
      if (defined ${$_[0]}->[4] and
          ${${$_[0]}->[0]}->[0]->{revision} == ${$_[0]}->[5]) {
        return ${$_[0]}->[4];
      } else {
        return ${$_[0]}->[4] = do {
          my %data = map { $_->node_name => $_ } reverse $_[0]->to_list;
          tie my %hash, 'Web::DOM::Internal::ReadOnlyHash', \%data;
          delete ${$_[0]}->[2];
          ${$_[0]}->[5] = ${${$_[0]}->[0]}->[0]->{revision};
          \%hash;
        };
      }
    },
    fallback => 1;

my $GetMethod = {
  attributes => 'get_attribute_node',
  element_types => 'get_element_type_definition_node',
  general_entities => 'get_general_entity_node',
  notations => 'get_notation_node',
  attribute_definitions => 'get_attribute_definition_node',
};

sub get_named_item ($$) {
  my $method = $GetMethod->{${$_[0]}->[3]}
      or _throw Web::DOM::Exception 'NotSupportedError',
             'This operation is not supported';
  return ${$_[0]}->[0]->$method ($_[1]);
} # get_named_item

my $GetMethodNS = {
  attributes => 'get_attribute_node_ns',
};

sub get_named_item_ns ($$$) {
  my $method = $GetMethodNS->{${$_[0]}->[3]}
      or _throw Web::DOM::Exception 'NotSupportedError',
             'This operation is not supported';
  return ${$_[0]}->[0]->$method ($_[1], $_[2]);
} # get_named_item_ns

my $SetMethod = {
  attributes => 'set_attribute_node',
  element_types => 'set_element_type_definition_node',
  general_entities => 'set_general_entity_node',
  notations => 'set_notation_node',
  attribute_definitions => 'set_attribute_definition_node',
};

my $SetNodeType = {
  attributes => ATTRIBUTE_NODE,
  element_types => ELEMENT_TYPE_DEFINITION_NODE,
  general_entities => ENTITY_NODE,
  notations => NOTATION_NODE,
  attribute_definitions => ATTRIBUTE_DEFINITION_NODE,
};

sub set_named_item ($$) {
  my $method = $SetMethod->{${$_[0]}->[3]}
      or _throw Web::DOM::Exception 'NotSupportedError',
             'This operation is not supported';

  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The argument is not a Node';
  }

  unless ($_[1]->node_type == $SetNodeType->{${$_[0]}->[3]}) {
    _throw Web::DOM::Exception 'HierarchyRequestError',
        'Specified type of node cannot be set';
  }
  return ${$_[0]}->[0]->$method ($_[1]);
} # set_named_item

my $SetMethodNS = {
  attributes => 'set_attribute_node_ns',
};

sub set_named_item_ns ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The argument is not a Node';
  }

  my $method = $SetMethodNS->{${$_[0]}->[3]}
      or _throw Web::DOM::Exception 'NotSupportedError',
             'This operation is not supported';

  unless ($_[1]->node_type == $SetNodeType->{${$_[0]}->[3]}) {
    _throw Web::DOM::Exception 'HierarchyRequestError',
        'Specified type of node cannot be set';
  }
  return ${$_[0]}->[0]->$method ($_[1]);
} # set_named_item_ns

my $RemoveMethod = {
  attributes => 'remove_attribute_node',
  element_types => 'remove_element_type_definition_node',
  general_entities => 'remove_general_entity_node',
  notations => 'remove_notation_node',
  attribute_definitions => 'remove_attribute_definition_node',
};

sub remove_named_item ($$) {
  my $node = $_[0]->get_named_item ($_[1]);
  unless ($node) {
    _throw Web::DOM::Exception 'NotFoundError',
        'Specified node not found';
  }
  my $method = $RemoveMethod->{${$_[0]}->[3]}
      or _throw Web::DOM::Exception 'NotSupportedError',
             'This operation is not supported';
  ${$_[0]}->[0]->$method ($node);
  return $node;
} # remove_named_item

sub remove_named_item_ns ($$$) {
  my $node = $_[0]->get_named_item_ns ($_[1], $_[2]);
  unless ($node) {
    _throw Web::DOM::Exception 'NotFoundError',
        'Specified node not found';
  }
  my $method = $RemoveMethod->{${$_[0]}->[3]}
      or _throw Web::DOM::Exception 'NotSupportedError',
             'This operation is not supported';
  ${$_[0]}->[0]->$method ($node);
  return $node;
} # remove_named_item_ns

1;

=head1 LICENSE

Copyright 2012-2014 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
