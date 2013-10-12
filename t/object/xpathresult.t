use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::Differences;
use Test::DOM::Exception;
use Web::DOM::Document;
use Web::DOM::XPathResult;

test {
  my $c = shift;
  is ANY_TYPE, 0;
  ok NUMBER_TYPE;
  ok STRING_TYPE;
  ok BOOLEAN_TYPE;
  ok UNORDERED_NODE_ITERATOR_TYPE;
  ok ORDERED_NODE_ITERATOR_TYPE;
  ok UNORDERED_NODE_SNAPSHOT_TYPE;
  ok ORDERED_NODE_SNAPSHOT_TYPE;
  ok ANY_UNORDERED_NODE_TYPE;
  ok FIRST_ORDERED_NODE_TYPE;
  done $c;
} n => 10, name => 'constants';

test {
  my $c = shift;
  is +Web::DOM::XPathResult->ANY_TYPE, 0;
  ok +Web::DOM::XPathResult->NUMBER_TYPE;
  ok +Web::DOM::XPathResult->STRING_TYPE;
  ok +Web::DOM::XPathResult->BOOLEAN_TYPE;
  ok +Web::DOM::XPathResult->UNORDERED_NODE_ITERATOR_TYPE;
  ok +Web::DOM::XPathResult->ORDERED_NODE_ITERATOR_TYPE;
  ok +Web::DOM::XPathResult->UNORDERED_NODE_SNAPSHOT_TYPE;
  ok +Web::DOM::XPathResult->ORDERED_NODE_SNAPSHOT_TYPE;
  ok +Web::DOM::XPathResult->ANY_UNORDERED_NODE_TYPE;
  ok +Web::DOM::XPathResult->FIRST_ORDERED_NODE_TYPE;
  done $c;
} n => 10, name => 'constants';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $result = $doc->evaluate ('/', $doc);
  is $result->ANY_TYPE, 0;
  ok $result->NUMBER_TYPE;
  ok $result->STRING_TYPE;
  ok $result->BOOLEAN_TYPE;
  ok $result->UNORDERED_NODE_ITERATOR_TYPE;
  ok $result->ORDERED_NODE_ITERATOR_TYPE;
  ok $result->UNORDERED_NODE_SNAPSHOT_TYPE;
  ok $result->ORDERED_NODE_SNAPSHOT_TYPE;
  ok $result->ANY_UNORDERED_NODE_TYPE;
  ok $result->FIRST_ORDERED_NODE_TYPE;
  done $c;
} n => 10, name => 'constants';

for my $result_type (undef, ANY_TYPE, BOOLEAN_TYPE) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $result = $doc->evaluate ('1 = 1', $doc, undef, $result_type);
    is $result->result_type, BOOLEAN_TYPE;
    ok $result->boolean_value;
    for my $method (qw(number_value string_value single_node_value
                       snapshot_length iterate_next)) {
      dies_here_ok {
        $result->$method;
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->message, 'The result is not compatible with the specified type';
    }
    dies_here_ok {
      $result->snapshot_item (0);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->message, 'The result is not compatible with the specified type';
    ok not $result->invalid_iterator_state;
    done $c;
  } n => 2 + 6*3 + 1, name => ['boolean_value', $result_type];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $result = $doc->evaluate ('1 = 0', $doc, undef, $result_type);
    is $result->result_type, BOOLEAN_TYPE;
    ok not $result->boolean_value;
    $doc->append_child ($doc->create_element_ns (undef, 'fuga'));
    ok not $result->invalid_iterator_state;
    done $c;
  } n => 3, name => ['boolean_value', $result_type];
}

for my $result_type (undef, ANY_TYPE, NUMBER_TYPE) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $result = $doc->evaluate ('4.3331', $doc, undef, $result_type);
    is $result->result_type, NUMBER_TYPE;
    is $result->number_value, 4.3331;
    for my $method (qw(boolean_value string_value single_node_value
                       snapshot_length iterate_next)) {
      dies_here_ok {
        $result->$method;
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->message, 'The result is not compatible with the specified type';
    }
    dies_here_ok {
      $result->snapshot_item (0);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->message, 'The result is not compatible with the specified type';
    ok not $result->invalid_iterator_state;
    done $c;
  } n => 2 + 6*3 + 1, name => ['number_value', $result_type];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $result = $doc->evaluate ('"abc" * 4', $doc, undef, $result_type);
    is $result->result_type, NUMBER_TYPE;
    is $result->number_value, 'nan';
    $doc->append_child ($doc->create_element_ns (undef, 'fuga'));
    ok not $result->invalid_iterator_state;
    done $c;
  } n => 3, name => ['number_value', $result_type];
}

for my $result_type (undef, ANY_TYPE, STRING_TYPE) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $result = $doc->evaluate ('"abc"', $doc, undef, $result_type);
    is $result->result_type, STRING_TYPE;
    is $result->string_value, 'abc';
    for my $method (qw(boolean_value number_value single_node_value
                       snapshot_length iterate_next)) {
      dies_here_ok {
        $result->$method;
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->message, 'The result is not compatible with the specified type';
    }
    dies_here_ok {
      $result->snapshot_item (0);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->message, 'The result is not compatible with the specified type';
    ok not $result->invalid_iterator_state;
    $doc->append_child ($doc->create_element_ns (undef, 'fuga'));
    ok not $result->invalid_iterator_state;
    done $c;
  } n => 2 + 6*3 + 2, name => ['string_value', $result_type];
}

for my $result_type (undef, ANY_TYPE, UNORDERED_NODE_ITERATOR_TYPE) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el1 = $doc->create_element_ns (undef, 'hoge');
    $doc->append_child ($el1);
    my $result = $doc->evaluate ('//hoge | /', $doc, undef, $result_type);
    is $result->result_type, UNORDERED_NODE_ITERATOR_TYPE;
    for my $method (qw(boolean_value number_value single_node_value
                       snapshot_length string_value)) {
      dies_here_ok {
        $result->$method;
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->message, 'The result is not compatible with the specified type';
    }
    dies_here_ok {
      $result->snapshot_item (0);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->message, 'The result is not compatible with the specified type';
    ok not $result->invalid_iterator_state;
    my @result;
    push @result, $result->iterate_next;
    push @result, $result->iterate_next;
    is $result->iterate_next, undef;
    is 0+@result, 2;
    ok $result[0] eq $doc || $result[1] eq $doc;
    ok $result[0] eq $el1 || $result[1] eq $el1;
    ok $result[0] eq $doc || $result[0] eq $el1;
    done $c;
  } n => 1 + 6*3 + 6, name => ['iterate_next', $result_type];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $result = $doc->evaluate ('/fuga', $doc, undef, $result_type);
    is $result->iterate_next, undef;
    done $c;
  } n => 1, name => ['iterate_next', $result_type];
}

for my $result_type (ORDERED_NODE_ITERATOR_TYPE) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el1 = $doc->create_element_ns (undef, 'hoge');
    $doc->append_child ($el1);
    my $result = $doc->evaluate ('//hoge | /', $doc, undef, $result_type);
    is $result->result_type, ORDERED_NODE_ITERATOR_TYPE;
    for my $method (qw(boolean_value number_value single_node_value
                       snapshot_length string_value)) {
      dies_here_ok {
        $result->$method;
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->message, 'The result is not compatible with the specified type';
    }
    dies_here_ok {
      $result->snapshot_item (0);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->message, 'The result is not compatible with the specified type';
    ok not $result->invalid_iterator_state;
    my @result;
    push @result, $result->iterate_next;
    push @result, $result->iterate_next;
    is $result->iterate_next, undef;
    eq_or_diff \@result, [$doc, $el1];
    done $c;
  } n => 1 + 6*3 + 3, name => ['iterate_next', $result_type];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $result = $doc->evaluate ('/fuga', $doc, undef, $result_type);
    is $result->result_type, ORDERED_NODE_ITERATOR_TYPE;
    is $result->iterate_next, undef;
    done $c;
  } n => 2, name => ['iterate_next', $result_type];
}

for my $result_type (ANY_UNORDERED_NODE_TYPE) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el1 = $doc->create_element_ns (undef, 'hoge');
    $doc->append_child ($el1);
    my $result = $doc->evaluate ('//hoge | /', $doc, undef, $result_type);
    is $result->result_type, ANY_UNORDERED_NODE_TYPE;
    for my $method (qw(boolean_value number_value iterate_next
                       snapshot_length string_value)) {
      dies_here_ok {
        $result->$method;
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->message, 'The result is not compatible with the specified type';
    }
    dies_here_ok {
      $result->snapshot_item (0);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->message, 'The result is not compatible with the specified type';
    ok not $result->invalid_iterator_state;
    ok $result->single_node_value eq $doc || $result->single_node_value eq $el1;
    done $c;
  } n => 1 + 6*3 + 2, name => ['single_node_value', $result_type];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $result = $doc->evaluate ('/fuga', $doc, undef, $result_type);
    is $result->single_node_value, undef;
    $doc->append_child ($doc->create_element_ns (undef, 'fuga'));
    ok not $result->invalid_iterator_state;
    done $c;
  } n => 2, name => ['single_node_value', $result_type];
}

for my $result_type (FIRST_ORDERED_NODE_TYPE) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el1 = $doc->create_element_ns (undef, 'hoge');
    $doc->append_child ($el1);
    my $result = $doc->evaluate ('//hoge | /', $doc, undef, $result_type);
    is $result->result_type, FIRST_ORDERED_NODE_TYPE;
    for my $method (qw(boolean_value number_value iterate_next
                       snapshot_length string_value)) {
      dies_here_ok {
        $result->$method;
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->message, 'The result is not compatible with the specified type';
    }
    dies_here_ok {
      $result->snapshot_item (0);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->message, 'The result is not compatible with the specified type';
    ok not $result->invalid_iterator_state;
    is $result->single_node_value, $doc;
    done $c;
  } n => 1 + 6*3 + 2, name => ['single_node_value', $result_type];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $result = $doc->evaluate ('/fuga', $doc, undef, $result_type);
    $doc->append_child ($doc->create_element_ns (undef, 'fuga'));
    ok not $result->invalid_iterator_state;
    is $result->single_node_value, undef;
    done $c;
  } n => 2, name => ['single_node_value', $result_type];
}

for my $result_type (UNORDERED_NODE_SNAPSHOT_TYPE) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el1 = $doc->create_element_ns (undef, 'hoge');
    $doc->append_child ($el1);
    my $result = $doc->evaluate ('//hoge | /', $doc, undef, $result_type);
    is $result->result_type, UNORDERED_NODE_SNAPSHOT_TYPE;
    for my $method (qw(boolean_value number_value iterate_next
                       string_value single_node_value)) {
      dies_here_ok {
        $result->$method;
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->message, 'The result is not compatible with the specified type';
    }
    ok not $result->invalid_iterator_state;
    is $result->snapshot_length, 2;
    ok $result->snapshot_item (0) eq $doc || $result->snapshot_item (0) eq $el1;
    ok $result->snapshot_item (1) eq $doc || $result->snapshot_item (1) eq $el1;
    ok $result->snapshot_item (0) eq $doc || $result->snapshot_item (1) eq $doc;
    is $result->snapshot_item (2), undef;
    is $result->snapshot_item (-1), undef;
    is $result->snapshot_item (2**32), $result->snapshot_item (0);
    done $c;
  } n => 1 + 5*3 + 8, name => ['snapshot', $result_type];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $result = $doc->evaluate ('/fuga', $doc, undef, $result_type);
    is $result->snapshot_length, 0;
    is $result->snapshot_item (0), undef;
    is $result->snapshot_item (1), undef;
    is $result->snapshot_item (-1), undef;
    $doc->append_child ($doc->create_element_ns (undef, 'fuga'));
    ok not $result->invalid_iterator_state;
    done $c;
  } n => 5, name => ['snapshot', $result_type];
}

for my $result_type (ORDERED_NODE_SNAPSHOT_TYPE) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el1 = $doc->create_element_ns (undef, 'hoge');
    $doc->append_child ($el1);
    my $result = $doc->evaluate ('//hoge | /', $doc, undef, $result_type);
    is $result->result_type, ORDERED_NODE_SNAPSHOT_TYPE;
    for my $method (qw(boolean_value number_value iterate_next
                       string_value single_node_value)) {
      dies_here_ok {
        $result->$method;
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->message, 'The result is not compatible with the specified type';
    }
    ok not $result->invalid_iterator_state;
    is $result->snapshot_length, 2;
    is $result->snapshot_item (0), $doc;
    is $result->snapshot_item (1), $el1;
    is $result->snapshot_item (2), undef;
    is $result->snapshot_item (-1), undef;
    is $result->snapshot_item (2**32), $doc;
    done $c;
  } n => 1 + 5*3 + 7, name => ['snapshot', $result_type];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $result = $doc->evaluate ('/fuga', $doc, undef, $result_type);
    is $result->snapshot_length, 0;
    is $result->snapshot_item (0), undef;
    is $result->snapshot_item (1), undef;
    is $result->snapshot_item (-1), undef;
    $doc->append_child ($doc->create_element_ns (undef, 'fuga'));
    ok not $result->invalid_iterator_state;
    done $c;
  } n => 5, name => ['snapshot', $result_type];
}

for my $result_type (UNORDERED_NODE_ITERATOR_TYPE,
                     ORDERED_NODE_ITERATOR_TYPE) {
  for my $code (
    sub {
      my ($doc, $el1) = @_;
      $el1->text_content ('aaa');
    },
    sub {
      my ($doc, $el1) = @_;
      $el1->set_attribute (hoge => 33);
    },
    sub {
      my ($doc, $el1) = @_;
      $el1->append_child ($doc->create_element ('aaaa'));
    },
    sub {
      my ($doc, $el1) = @_;
      $doc->remove_child ($doc->first_child);
    },
  ) {
    test {
      my $c = shift;
      my $doc0 = new Web::DOM::Document;
      my $doc = new Web::DOM::Document;
      $doc->append_child ($doc->create_comment (''));
      my $result = $doc0->evaluate ('/fuga', $doc, undef, $result_type);
      ok not $result->invalid_iterator_state;
      my $el1 = $doc->create_element ('aaa');
      ok not $result->invalid_iterator_state;
      $code->($doc, $el1);
      ok $result->invalid_iterator_state;
      dies_here_ok {
        $result->iterate_next;
      };
      isa_ok $@, 'Web::DOM::Exception';
      is $@->name, 'InvalidStateError';
      is $@->message, 'This object is invalid';
      done $c;
    } n => 7, name => ['snapshot', $result_type];
  }
}

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
