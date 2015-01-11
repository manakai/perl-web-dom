package Web::DOM::ElementTypeDefinition;
use strict;
use warnings;
our $VERSION = '3.0';
use Web::DOM::Node;
push our @ISA, qw(Web::DOM::Node);
use Web::DOM::DocumentType;
push our @CARP_NOT, qw(Web::DOM::DocumentType);
use Web::DOM::Exception;

sub node_name ($) {
  return ${${$_[0]}->[2]->{node_name}};
} # node_name

sub owner_document_type_definition ($) {
  if (my $id = ${$_[0]}->[2]->{owner}) {
    return ${$_[0]}->[0]->node ($id);
  } else {
    return undef;
  }
} # owner_document_type_definition

sub attribute_definitions ($) {
  return ${$_[0]}->[0]->collection ('attribute_definitions', $_[0], sub {
    my $int = ${$_[0]}->[0];
    return sort { ${$int->{data}->[$a]->{node_name}} cmp ${$int->{data}->[$b]->{node_name}} }
           grep { defined $_ }
           values %{${$_[0]}->[2]->{attribute_definitions} or {}};
  });
} # attribute_definitions

sub get_attribute_definition_node ($$) {
  my $id = ${$_[0]}->[2]->{attribute_definitions}->{''.$_[1]};
  return defined $id ? ${$_[0]}->[0]->node ($id) : undef;
} # get_attribute_definition_node

sub set_attribute_definition_node ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::AttributeDefinition')) {
    _throw Web::DOM::TypeError 'The argument is not an AttributeDefinition';
  }
  return $_[0]->Web::DOM::DocumentType::_set_node
      ('attribute_definitions', $_[1]);
} # set_attribute_definition_node

sub remove_attribute_definition_node ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::AttributeDefinition')) {
    _throw Web::DOM::TypeError 'The argument is not an AttributeDefinition';
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
  delete $$node->[2]->{attribute_definitions}->{${$$obj->[2]->{node_name}}};
  delete $$obj->[2]->{owner};
  $$node->[0]->disconnect ($$obj->[1]);
  $$node->[0]->{revision}++;

  # 4.
  return $obj;
} # remove_attribute_definition_node

my $XMLS = qr/[\x09\x0A\x0D\x20]/;
my $GITEM; {
  use re 'eval';
  $GITEM = qr/(?>[^()*+?|,\x09\x0A\x0D\x20]+|\($XMLS*(??{$GITEM})$XMLS*(?>[|,]$XMLS*(??{$GITEM})$XMLS*)*\))(?>[*+?]|)/;
}

sub content_model_text ($;$) {
  if (@_ > 1) {
    if (defined $_[1]) {
      my $text = ''.$_[1];
      $text =~ s/\A$XMLS+//o;
      $text =~ s/$XMLS+\z//o;
      if (not $text =~ /\A$GITEM\z/o or
          not $text =~ /\A(?>EMPTY\z|ANY\z|\()/o) {
        _throw Web::DOM::Exception 'SyntaxError',
            'The specified text is not a valid content model';
      }
      $text =~ s/\($XMLS+/(/go;
      $text =~ s/$XMLS+\)/)/go;
      $text =~ s/$XMLS*,$XMLS*/, /g;
      $text =~ s/$XMLS*\|$XMLS*/ | /g;
      ${$_[0]}->[2]->{content_model_text} = $text;
    } else {
      delete ${$_[0]}->[2]->{content_model_text};
    }
  }
  return ${$_[0]}->[2]->{content_model_text};
} # content_model_text

1;

=head1 LICENSE

Copyright 2012-2015 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
