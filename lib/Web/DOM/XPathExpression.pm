package Web::DOM::XPathExpression;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::TypeError;
use Web::DOM::Exception;
use Web::DOM::XPathResult;
push our @CARP_NOT, qw(Web::DOM::XPathEvaluator);

sub evaluate ($$;$$) {
  my $node = $_[1];
  unless (UNIVERSAL::isa ($node, 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The first argument is not a Node';
  }
  my $type = unpack 'S', pack 'S', ($_[2] || 0) % 2**16; # WebIDL unsigned short
  if (defined $_[3] and (not ref $_[3] or not UNIVERSAL::can ($_[3], 'isa'))) { # WebIDL object?
    _throw Web::DOM::TypeError 'The third argument is not an object';
  }

  require Web::XPath::Evaluator;
  my $eval = Web::XPath::Evaluator->new;
  my $r = $eval->evaluate (${$_[0]}, $node);
  _throw Web::DOM::Exception 'SyntaxError',
      'XPath evaluation failed' unless defined $r;

  my $expected = {
    #ANY_TYPE
    NUMBER_TYPE, 'number',
    STRING_TYPE, 'string',
    BOOLEAN_TYPE, 'boolean',
    UNORDERED_NODE_ITERATOR_TYPE, 'node-set',
    ORDERED_NODE_ITERATOR_TYPE, 'node-set',
    UNORDERED_NODE_SNAPSHOT_TYPE, 'node-set',
    ORDERED_NODE_SNAPSHOT_TYPE, 'node-set',
    ANY_UNORDERED_NODE_TYPE, 'node-set',
    FIRST_ORDERED_NODE_TYPE, 'node-set',
  }->{$type};
  if ($type == ANY_TYPE) {
    if ($r->{type} eq 'node-set') {
      $type = UNORDERED_NODE_ITERATOR_TYPE;
    } elsif ($r->{type} eq 'boolean') {
      $type = BOOLEAN_TYPE;
    } elsif ($r->{type} eq 'number') {
      $type = NUMBER_TYPE;
    } elsif ($r->{type} eq 'string') {
      $type = STRING_TYPE;
    } else {
      _throw Web::DOM::TypeError
          'The result is not compatible with the specified type';
    }
  } elsif (not defined $expected or not $expected eq $r->{type}) {
    _throw Web::DOM::TypeError
        'The result is not compatible with the specified type';
  }

  if ($type == ORDERED_NODE_ITERATOR_TYPE or
      $type == ORDERED_NODE_SNAPSHOT_TYPE or
      $type == FIRST_ORDERED_NODE_TYPE) {
    $eval->sort_node_set ($r);
  }

  return $$node->[0]->xpath_result
      ({result => $r, result_type => $type, index => 0});
} # evaluate

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
