use strict;
use warnings;
no warnings 'utf8';
use Path::Tiny;
use lib glob path (__FILE__)->parent->parent->parent->child ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob path (__FILE__)->parent->parent->parent->child ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::Differences;
use Test::DOM::Exception;
use Web::DOM::Document;

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc,
    $doc->create_element ('a'),
    $doc->create_attribute ('b'),
    $doc->create_text_node ('c'),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      eq_or_diff $node->manakai_get_source_location, ['', -1, 0];
      done $c;
    } n => 1, name => ['manakai_get_source_location', $node->node_type, 'no data'];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc,
    $doc->create_element ('a'),
    $doc->create_attribute ('b'),
    $doc->create_text_node ('c'),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      is $node->manakai_set_source_location (['', 42, 5]), undef;
      eq_or_diff $node->manakai_get_source_location, ['', 42, 5];
      $node->manakai_set_source_location (['abc', -1, 44]);
      eq_or_diff $node->manakai_get_source_location, ['', -1, 44];
      $node->manakai_set_source_location;
      eq_or_diff $node->manakai_get_source_location, ['', -1, 0];
      done $c;
    } n => 4, name => ['manakai_get_source_location, manakai_set_source_location', $node->node_type];
  }
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');

  my $x = ['', 463, 402];
  $node->manakai_set_source_location ($x);

  $x->[1] = 10;
  $x->[2] = 5;

  eq_or_diff $node->manakai_get_source_location, ['', 463, 402];

  done $c;
} n => 1, name => 'manakai_get_source_location copied';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  $node->manakai_set_source_location (['', -1, 44]);

  dies_here_ok {
    $node->manakai_set_source_location ('42.44');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The argument is not an IndexedStringSegment';

  eq_or_diff $node->manakai_get_source_location, ['', -1, 44];

  done $c;
} n => 4, name => 'manakai_get_source_location bad type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute (foo => 'bar');
  my $attr = $el->get_attribute_node ('foo');

  eq_or_diff $attr->manakai_get_source_location, ['', -1, 0];

  done $c;
} n => 1, name => 'manakai_get_source_location attr no data';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->manakai_set_attribute_indexed_string_ns
      (undef, foo => []);
  my $attr = $el->get_attribute_node ('foo');

  eq_or_diff $attr->manakai_get_source_location, ['', -1, 0];

  done $c;
} n => 1, name => 'manakai_get_source_location attr with empty data';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->manakai_set_attribute_indexed_string_ns
      (undef, foo => [['bar', 12, 445], ['baz', 5, 42]]);
  my $attr = $el->get_attribute_node ('foo');

  eq_or_diff $attr->manakai_get_source_location, ['', 12, 445];

  done $c;
} n => 1, name => 'manakai_get_source_location attr with data';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->manakai_set_attribute_indexed_string_ns
      (undef, foo => [['bar', 12, 445], ['baz', 5, 42]]);
  my $attr = $el->get_attribute_node ('foo');
  $attr->manakai_set_source_location (['', 45, 3]);

  eq_or_diff $attr->manakai_get_source_location, ['', 45, 3];

  done $c;
} n => 1, name => 'manakai_get_source_location attr with two data';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $text = $doc->create_text_node ('foo');

  eq_or_diff $text->manakai_get_source_location, ['', -1, 0];

  done $c;
} n => 1, name => 'manakai_get_source_location text no data';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $text = $doc->create_text_node ('');
  $text->manakai_append_indexed_string ([['abc', 3, 55]]);

  eq_or_diff $text->manakai_get_source_location, ['', 3, 55];

  done $c;
} n => 1, name => 'manakai_get_source_location text with data';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $text = $doc->create_comment ('');
  $text->manakai_append_indexed_string ([['abc', 3, 55]]);

  eq_or_diff $text->manakai_get_source_location, ['', 3, 55];

  done $c;
} n => 1, name => 'manakai_get_source_location comment with data';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $text = $doc->create_processing_instruction ('aa', '');
  $text->manakai_append_indexed_string ([['abc', 3, 55]]);

  eq_or_diff $text->manakai_get_source_location, ['', 3, 55];

  done $c;
} n => 1, name => 'manakai_get_source_location PI with data';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $text = $doc->create_processing_instruction ('aa', '');
  $text->manakai_append_indexed_string ([['abc', 3, 55]]);
  $text->manakai_set_source_location (['e', 4, 454]);

  eq_or_diff $text->manakai_get_source_location, ['', 4, 454];

  done $c;
} n => 1, name => 'manakai_get_source_location PI with two data';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  eq_or_diff $node->manakai_get_indexed_string, [['', -1, 0]];
  done $c;
} n => 1, name => ['manakai_get_indexed_string', 'element empty'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_fragment;
  eq_or_diff $node->manakai_get_indexed_string, [['', -1, 0]];
  done $c;
} n => 1, name => ['manakai_get_indexed_string', 'df empty'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;
  eq_or_diff $doc->manakai_get_indexed_string, [['', -1, 0]];
  done $c;
} n => 1, name => ['manakai_get_indexed_string', 'doc non-strict empty'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  $node->manakai_set_source_location (['', 4, 55]);
  eq_or_diff $node->manakai_get_indexed_string, [['', 4, 55]];
  done $c;
} n => 1, name => ['manakai_get_indexed_string', 'element empty / from loc'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_fragment;
  $node->manakai_set_source_location (['', 4, 55]);
  eq_or_diff $node->manakai_get_indexed_string, [['', 4, 55]];
  done $c;
} n => 1, name => ['manakai_get_indexed_string', 'df empty / from loc'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  $node->manakai_append_indexed_string ([['ab', 42, 555]]);
  $node->manakai_append_indexed_string ([['cd', 40, 5]]);
  eq_or_diff $node->manakai_get_indexed_string,
      [['', -1, 0], ['ab', 42, 555], ['cd', 40, 5]];
  done $c;
} n => 1, name => ['manakai_get_indexed_string', 'element'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_fragment;
  $node->manakai_append_indexed_string ([['ab', 42, 555]]);
  $node->manakai_append_indexed_string ([['cd', 40, 5]]);
  eq_or_diff $node->manakai_get_indexed_string,
      [['', -1, 0], ['ab', 42, 555], ['cd', 40, 5]];
  done $c;
} n => 1, name => ['manakai_get_indexed_string', 'df'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_fragment;
  $node->manakai_append_indexed_string ([['ab', 42, 555]]);
  my $el = $doc->create_element ('a');
  $el->manakai_append_indexed_string ([['x', 4, 55]]);
  my $el2 = $doc->create_element ('b');
  $el2->manakai_append_indexed_string ([['y', 5, -1]]);
  $el->append_child ($el2);
  $node->append_child ($el);
  $node->append_child ($doc->create_comment ('aa'));
  $node->manakai_append_indexed_string ([['cd', 40, 5]]);
  eq_or_diff $node->manakai_get_indexed_string,
      [['', -1, 0], ['ab', 42, 555],
       ['x', 4, 55], ['y', 5, -1],
       ['cd', 40, 5]];
  done $c;
} n => 1, name => ['manakai_get_indexed_string', 'descendant'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  is $node->manakai_append_indexed_string ([['a', 3, 4], ['b', 4, 1]]), undef;
  is $node->text_content, 'ab';
  eq_or_diff $node->first_child->manakai_get_indexed_string,
      [['a', 3, 4], ['b', 4, 1]];
  done $c;
} n => 3, name => 'manakai_append_indexed_string element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_fragment;
  is $node->manakai_append_indexed_string ([['a', 3, 4], ['b', 4, 1]]), undef;
  is $node->text_content, 'ab';
  eq_or_diff $node->first_child->manakai_get_indexed_string,
      [['a', 3, 4], ['b', 4, 1]];
  done $c;
} n => 3, name => 'manakai_append_indexed_string df';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;
  my $node = $doc;
  is $node->manakai_append_indexed_string ([['a', 3, 4], ['b', 4, 1]]), undef;
  is $node->text_content, 'ab';
  eq_or_diff $node->first_child->manakai_get_indexed_string,
      [['a', 3, 4], ['b', 4, 1]];
  done $c;
} n => 3, name => 'manakai_append_indexed_string doc not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc;
  is $node->manakai_append_indexed_string ([['a', 3, 4], ['b', 4, 1]]), undef;
  is $node->text_content, undef;
  is $node->first_child, undef;
  done $c;
} n => 3, name => 'manakai_append_indexed_string doc strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $is = [['a', 5, 6]];
  $el->manakai_append_indexed_string ($is);
  $is->[0]->[0] = 'abc';
  is $el->text_content, 'a';
  done $c;
} n => 1, name => 'manakai_append_indexed_string modified';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  dies_here_ok {
    $node->manakai_append_indexed_string ('abc');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The argument is not an IndexedString';
  is $node->first_child, undef;
  done $c;
} n => 4, name => 'manakai_append_indexed_string TypeError';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  dies_here_ok {
    $node->manakai_append_indexed_string (['abc']);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The argument is not an IndexedString';
  is $node->first_child, undef;
  done $c;
} n => 4, name => 'manakai_append_indexed_string TypeError';

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->create_document_type_definition ('x'),
    $doc->create_general_entity ('aa'),
    $doc->create_notation ('aa'),
    $doc->create_element_type_definition ('aa'),
    $doc->create_attribute_definition ('bb'),
  ) {
    test {
      my $c = shift;
      eq_or_diff $node->manakai_get_indexed_string, undef;
      is $node->manakai_append_indexed_string ([['', 5, 5]]), undef;
      eq_or_diff $node->manakai_get_indexed_string, undef;
      done $c;
    } n => 3, name => ['manakai_get_indexed_string', $node->node_type];

    test {
      my $c = shift;
      dies_here_ok {
        $node->manakai_append_indexed_string ('abc');
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->message, 'The argument is not an IndexedString';
      is $node->first_child, undef;
      done $c;
    } n => 4, name => ['manakai_append_indexed_string TypeError', $node->node_type];

    test {
      my $c = shift;
      dies_here_ok {
        $node->manakai_append_indexed_string (['abc']);
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->message, 'The argument is not an IndexedString';
      is $node->first_child, undef;
      done $c;
    } n => 4, name => ['manakai_append_indexed_string TypeError', $node->node_type];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->create_text_node ('aa'),
    $doc->create_comment ('aa'),
    $doc->create_processing_instruction ('b', 'aa'),
    do { $_ = $doc->create_attribute ('b'); $_->value ('aa'); $_ },
  ) {
    test {
      my $c = shift;

      eq_or_diff $node->manakai_get_indexed_string, [['aa', -1, 0]];

      is $node->manakai_append_indexed_string ([['n', 5, 5]]), undef;
      eq_or_diff $node->manakai_get_indexed_string,
          [['aa', -1, 0], ['n', 5, 5]];

      dies_here_ok {
        $node->manakai_append_indexed_string (undef);
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->message, 'The argument is not an IndexedString';

      dies_here_ok {
        $node->manakai_append_indexed_string ([{}]);
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->message, 'The argument is not an IndexedString';

      eq_or_diff $node->manakai_get_indexed_string,
          [['aa', -1, 0], ['n', 5, 5]];

      done $c;
    } n => 10, name => ['manakai_get_indexed_string', $node->node_type];
  }
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->manakai_append_indexed_string ([['', 3, 12]]);
  is $el->first_child, undef;
  done $c;
} n => 1, name => 'manakai_append_indexed_string empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->manakai_append_indexed_string ([['', 3, 12], ['', 4, 12]]);
  is $el->first_child, undef;
  done $c;
} n => 1, name => 'manakai_append_indexed_string empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->manakai_append_indexed_string ([['', 3, 12], ['aa', 4, 5], ['', 4, 12]]);
  ok $el->first_child;
  done $c;
} n => 1, name => 'manakai_append_indexed_string not empty';

run_tests;

=head1 LICENSE

Copyright 2014 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
