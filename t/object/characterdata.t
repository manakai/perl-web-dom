use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

{
  my $doc = new Web::DOM::Document;

  for my $node (
    $doc->create_text_node (''),
    $doc->create_comment (''),
    $doc->create_processing_instruction ('hoge', ''),
  ) {
    test {
      my $c = shift;
      is $node->length, 0;
      done $c;
    } n => 1, name => 'length empty';
  }

  for my $node (
    $doc->create_text_node ('fugahoge'),
    $doc->create_comment ('fugahoge'),
    $doc->create_processing_instruction ('hoge', 'fugahoge'),
  ) {
    test {
      my $c = shift;
      is $node->length, 8;
      done $c;
    } n => 1, name => 'length ascii';
  }

  for my $node (
    $doc->create_text_node ("\x{5000}\x{6000}ab"),
    $doc->create_comment ("\x{5000}\x{6000}ab"),
    $doc->create_processing_instruction ('hoge', "\x{5000}\x{6000}ab"),
  ) {
    test {
      my $c = shift;
      is $node->length, 4;
      done $c;
    } n => 1, name => 'length non-ascii';
  }

  for my $node (
    $doc->create_text_node ("\x{5000}\x{6000}ab\x{40000}\x{10FFFF}"),
    $doc->create_comment ("\x{5000}\x{6000}ab\x{40000}\x{10FFFF}"),
    $doc->create_processing_instruction ('hoge', "\x{5000}\x{6000}ab\x{40000}\x{10FFFF}"),
  ) {
    test {
      my $c = shift;
      is $node->length, 4 + 2 * 2;
      done $c;
    } n => 1, name => 'length non-bmp';
  }

  for my $node (
    $doc->create_text_node ("\x{5000}\x{D805}\x{DE12}\x{6000}ab"),
    $doc->create_comment ("\x{5000}\x{D805}\x{DE12}\x{6000}ab"),
    $doc->create_processing_instruction ('hoge', "\x{5000}\x{D805}\x{DE12}\x{6000}ab"),
  ) {
    test {
      my $c = shift;
      is $node->length, 6;
      done $c;
    } n => 1, name => 'length bare surrogate';
  }

  for my $node (
    $doc->create_text_node ("\x{5000}\x{DE12}\x{D805}\x{6000}ab"),
    $doc->create_comment ("\x{5000}\x{DE12}\x{D805}\x{6000}ab"),
    $doc->create_processing_instruction ('hoge', "\x{5000}\x{DE12}\x{D805}\x{6000}ab"),
  ) {
    test {
      my $c = shift;
      is $node->length, 6;
      done $c;
    } n => 1, name => 'length broken surrogate';
  }

  for my $node (
    $doc->create_text_node ("\x{5000}\x{DE12}\x{D805}\x{6000}\x{110000}ab"),
    $doc->create_comment ("\x{5000}\x{DE12}\x{D805}\x{6000}\x{110000}ab"),
    $doc->create_processing_instruction ('hoge', "\x{5000}\x{DE12}\x{D805}\x{6000}\x{110000}ab"),
  ) {
    test {
      my $c = shift;
      is $node->length, 7;
      done $c;
    } n => 1, name => 'length non-Unicode';
  }

  for my $node (
    $doc->create_text_node ("abc"),
    $doc->create_comment ("abc"),
    $doc->create_processing_instruction ('hoge', "abc"),
  ) {
    test {
      my $c = shift;

      $node->append_data ('hoge');
      is $node->data, 'abchoge';
      is $node->length, 7;

      $node->append_data ('');
      is $node->data, 'abchoge';

      $node->append_data ("\x{4000}\x{425}a");
      is $node->data, "abchoge\x{4000}\x{425}a";

      done $c;
    } n => 4, name => 'append_data';
  }

  for my $node (
    $doc->create_text_node ("abc"),
    $doc->create_comment ("abc"),
    $doc->create_processing_instruction ('hoge', "abc"),
  ) {
    test {
      my $c = shift;

      $node->append_data ("h\xFEoge");
      is $node->data, "abch\x{00FE}oge";

      $node->append_data ("\x{100}");
      is $node->data, "abch\xFEoge\x{100}";

      done $c;
    } n => 2, name => 'append_data';
  }

  for my $node (
    $doc->create_text_node ("\x{11FFFF}abc\x{D8C5}"),
    $doc->create_comment ("\x{11FFFF}abc\x{D8C5}"),
    $doc->create_processing_instruction ('hoge', "\x{11FFFF}abc\x{D8C5}"),
  ) {
    test {
      my $c = shift;

      $node->append_data ("\x{DC04}h\xFEo\x{D8C5}\x{DC91}ge");
      #is $node->data, "\x{11FFFF}abc\x{41404}h\x{00FE}o\x{D8C5}\x{DC91}ge";
      is $node->data, "\x{11FFFF}abc\x{D8C5}\x{DC04}h\x{00FE}o\x{D8C5}\x{DC91}ge";

      done $c;
    } n => 1, name => 'append_data surrogate boundary';
  }

  for my $data ('') {
    for my $node (
      $doc->create_text_node ($data),
      $doc->create_comment ($data),
      $doc->create_processing_instruction ('hoge', $data),
    ) {
      test {
        my $c = shift;
        is $node->substring_data (0, 0), '';
        is $node->substring_data (0.20, 0), '';
        is $node->substring_data (0, 20), '';
        is $node->substring_data (0, 0.7), '';
        is $node->substring_data (0, 20.5), '';
        is $node->substring_data (0, -1), '';
        is $node->substring_data (0, 2**32), '';
        is $node->substring_data (0+"inf", 2**32), '';
        is $node->substring_data (0+"-inf", 2**32), '';
        is $node->substring_data (0+"nan", 2**32), '';
        is $node->substring_data (2**32, 20), '';
        for (
          [1, 40],
          [1, -1],
          [-1, 0],
          [-1, 1],
          [2**32-1, 1],
          [2**32+1, 1],
          [1, 2**32],
          [1.6, 0],
          [6, 0.5],
        ) {
          dies_here_ok {
            $node->substring_data (@$_);
          };
          isa_ok $@, 'Web::DOM::Exception';
          is $@->name, 'IndexSizeError';
          is $@->message, 'Offset is greater than the length';
        }
        done $c;
      } n => 11 + 4*9, name => 'substring_data empty';
    }
  }

  for my $data ("ho\x{4e00}foodfaazaaa") {
    for my $node (
      $doc->create_text_node ($data),
      $doc->create_comment ($data),
      $doc->create_processing_instruction ('hoge', $data),
    ) {
      test {
        my $c = shift;
        is $node->substring_data (0, -1), $data;
        is $node->substring_data (1, 0), "";
        is $node->substring_data (1, 1), "o";
        is $node->substring_data (1, 5), "o\x{4e00}foo";
        is $node->substring_data (2, 5), "\x{4e00}food";
        is $node->substring_data (2, 6), "\x{4e00}foodf";
        is $node->substring_data (3, 8), "foodfaaz";
        is $node->substring_data (3, 9), "foodfaaza";
        is $node->substring_data (6, 8), "dfaazaaa";
        is $node->substring_data (6, 9), "dfaazaaa";
        is $node->substring_data (7, 7), "faazaaa";
        is $node->substring_data (7, 5), "faaza";
        is $node->substring_data (7, 4), "faaz";
        is $node->substring_data (7, 1), "f";
        is $node->substring_data (7, 2), "fa";
        is $node->substring_data (6, 1), "d";
        is $node->substring_data (6, 2), "df";
        is $node->substring_data (6, 3), "dfa";
        is $node->substring_data (13, 1), "a";
        is $node->substring_data (13, 2), "a";
        is $node->substring_data (2**32+13, 2), "a";
        is $node->substring_data (13, 2+2**32), "a";
        is $node->substring_data (13, -1), "a";
        is $node->substring_data (13, 2**31-1), "a";
        is $node->substring_data (13, 0), "";
        is $node->substring_data (13, 0+"inf"), "";
        is $node->substring_data (13, 0+"-inf"), "";
        is $node->substring_data (13, 0+"nan"), "";
        is $node->substring_data (14, 0), "";
        is $node->substring_data (14, 1), "";
        is $node->substring_data (14, 10), "";
        for (
          [15, 0],
          [15, 1],
          [20, 1],
          [-1, 1],
          [2**32-1, 1],
        ) {
          dies_here_ok {
            $node->substring_data (@$_);
          };
          isa_ok $@, 'Web::DOM::Exception';
          is $@->name, 'IndexSizeError';
          is $@->message, 'Offset is greater than the length';
        }
        done $c;
      } n => 31 + 4*5, name => 'substring_data not empty';
    }
  }

  for my $data ("ho\x{4e00}\x{551201}oodfaazaaa") {
    for my $node (
      $doc->create_text_node ($data),
      $doc->create_comment ($data),
      $doc->create_processing_instruction ('hoge', $data),
    ) {
      test {
        my $c = shift;
        is $node->substring_data (0, -1), $data;
        is $node->substring_data (1, 0), "";
        is $node->substring_data (1, 1), "o";
        is $node->substring_data (1, 5), "o\x{4e00}\x{551201}oo";
        is $node->substring_data (2, 5), "\x{4e00}\x{551201}ood";
        is $node->substring_data (2, 6), "\x{4e00}\x{551201}oodf";
        is $node->substring_data (3, 8), "\x{551201}oodfaaz";
        is $node->substring_data (3, 9), "\x{551201}oodfaaza";
        is $node->substring_data (6, 8), "dfaazaaa";
        is $node->substring_data (6, 9), "dfaazaaa";
        is $node->substring_data (7, 7), "faazaaa";
        is $node->substring_data (7, 5), "faaza";
        is $node->substring_data (7, 4), "faaz";
        is $node->substring_data (7, 1), "f";
        is $node->substring_data (7, 2), "fa";
        is $node->substring_data (6, 1), "d";
        is $node->substring_data (6, 2), "df";
        is $node->substring_data (6, 3), "dfa";
        is $node->substring_data (13, 1), "a";
        is $node->substring_data (13, 2), "a";
        is $node->substring_data (2**32+13, 2), "a";
        is $node->substring_data (13, 2+2**32), "a";
        is $node->substring_data (13, -1), "a";
        is $node->substring_data (13, 2**31-1), "a";
        is $node->substring_data (13, 0), "";
        is $node->substring_data (14, 0), "";
        is $node->substring_data (14, 1), "";
        is $node->substring_data (14, 10), "";
        for (
          [15, 0],
          [15, 1],
          [20, 1],
          [-1, 1],
          [2**32-1, 1],
        ) {
          dies_here_ok {
            $node->substring_data (@$_);
          };
          isa_ok $@, 'Web::DOM::Exception';
          is $@->name, 'IndexSizeError';
          is $@->message, 'Offset is greater than the length';
        }
        done $c;
      } n => 28 + 4*5, name => 'substring_data not empty';
    }
  }

  for my $data ("ho\x{4e00}foo\x{10003}aa\x{54212}aa") {
    for my $node (
      $doc->create_text_node ($data),
      $doc->create_comment ($data),
      $doc->create_processing_instruction ('hoge', $data),
    ) {
      test {
        my $c = shift;
        is $node->substring_data (1, 0), "";
        is $node->substring_data (1, 1), "o";
        is $node->substring_data (1, 5), "o\x{4e00}foo";
        is $node->substring_data (2, 5), "\x{4e00}foo\x{D800}";
        is $node->substring_data (2, 6), "\x{4e00}foo\x{10003}";
        is $node->substring_data (3, 8), "foo\x{10003}aa\x{D910}";
        is $node->substring_data (3, 9), "foo\x{10003}aa\x{54212}";
        is $node->substring_data (6, 8), "\x{10003}aa\x{54212}aa";
        is $node->substring_data (6, 9), "\x{10003}aa\x{54212}aa";
        is $node->substring_data (7, 7), "\x{DC03}aa\x{54212}aa";
        is $node->substring_data (7, 5), "\x{DC03}aa\x{54212}";
        is $node->substring_data (7, 4), "\x{DC03}aa\x{D910}";
        is $node->substring_data (7, 1), "\x{DC03}";
        is $node->substring_data (7, 2), "\x{DC03}a";
        is $node->substring_data (6, 1), "\x{D800}";
        is $node->substring_data (6, 2), "\x{10003}";
        is $node->substring_data (6, 3), "\x{10003}a";
        is $node->substring_data (13, 1), "a";
        is $node->substring_data (13, 2), "a";
        is $node->substring_data (2**32+13, 2), "a";
        is $node->substring_data (13, 2+2**32), "a";
        is $node->substring_data (13, -1), "a";
        is $node->substring_data (14, 0), "";
        is $node->substring_data (14, 1), "";
        is $node->substring_data (14, 10), "";
        for (
          [15, 0],
          [15, 1],
          [20, 1],
          [-1, 1],
          [2**32-1, 1],
        ) {
          dies_here_ok {
            $node->substring_data (@$_);
          };
          isa_ok $@, 'Web::DOM::Exception';
          is $@->name, 'IndexSizeError';
          is $@->message, 'Offset is greater than the length';
        }
        done $c;
      } n => 25 + 4*5, name => 'substring_data surrogate';
    }
  }

  for my $data ("ho\x{4e00}foo\x{10003}a\x{FEFF00}\x{54212}aa") {
    for my $node (
      $doc->create_text_node ($data),
      $doc->create_comment ($data),
      $doc->create_processing_instruction ('hoge', $data),
    ) {
      test {
        my $c = shift;
        is $node->substring_data (1, 0), "";
        is $node->substring_data (1, 1), "o";
        is $node->substring_data (1, 5), "o\x{4e00}foo";
        is $node->substring_data (2, 5), "\x{4e00}foo\x{D800}";
        is $node->substring_data (2, 6), "\x{4e00}foo\x{10003}";
        is $node->substring_data (3, 8), "foo\x{10003}a\x{FEFF00}\x{D910}";
        is $node->substring_data (3, 9), "foo\x{10003}a\x{FEFF00}\x{54212}";
        is $node->substring_data (6, 8), "\x{10003}a\x{FEFF00}\x{54212}aa";
        is $node->substring_data (6, 9), "\x{10003}a\x{FEFF00}\x{54212}aa";
        is $node->substring_data (7, 7), "\x{DC03}a\x{FEFF00}\x{54212}aa";
        is $node->substring_data (7, 5), "\x{DC03}a\x{FEFF00}\x{54212}";
        is $node->substring_data (7, 4), "\x{DC03}a\x{FEFF00}\x{D910}";
        is $node->substring_data (7, 1), "\x{DC03}";
        is $node->substring_data (7, 2), "\x{DC03}a";
        is $node->substring_data (7, 3), "\x{DC03}a\x{FEFF00}";
        is $node->substring_data (6, 1), "\x{D800}";
        is $node->substring_data (6, 2), "\x{10003}";
        is $node->substring_data (6, 3), "\x{10003}a";
        is $node->substring_data (13, 1), "a";
        is $node->substring_data (13, 2), "a";
        is $node->substring_data (2**32+13, 2), "a";
        is $node->substring_data (13, 2+2**32), "a";
        is $node->substring_data (13, -1), "a";
        is $node->substring_data (14, 0), "";
        is $node->substring_data (14, 1), "";
        is $node->substring_data (14, 10), "";
        for (
          [15, 0],
          [15, 1],
          [20, 1],
          [-1, 1],
          [2**32-1, 1],
        ) {
          dies_here_ok {
            $node->substring_data (@$_);
          };
          isa_ok $@, 'Web::DOM::Exception';
          is $@->name, 'IndexSizeError';
          is $@->message, 'Offset is greater than the length';
        }
        done $c;
      } n => 26 + 4*5, name => 'substring_data surrogate, non Unicode';
    }
  }

  for my $data ("ho\x{4e00}foo\x{10003}a\x{FEFF00}\x{54212}aa") {
    for my $test (
      [[0, 0, 'aa'] => "aaho\x{4e00}foo\x{10003}a\x{FEFF00}\x{54212}aa"],
      [[13, 0, 'aa'] => "ho\x{4e00}foo\x{10003}a\x{FEFF00}\x{54212}aaaa"],
      [[5, 0, ''] => "ho\x{4e00}foo\x{10003}a\x{FEFF00}\x{54212}aa"],
      [[5, 0, 'fuga'] => "ho\x{4e00}fofugao\x{10003}a\x{FEFF00}\x{54212}aa"],
      [[5, 6, ''] => "ho\x{4e00}fo\x{DE12}aa"],
      [[5, 5, 'hoge'] => "ho\x{4e00}fohoge\x{54212}aa"],
      [[5, 6, 'hoge'] => "ho\x{4e00}fohoge\x{DE12}aa"],
      [[5.1, 6.4, 'hoge'] => "ho\x{4e00}fohoge\x{DE12}aa"],
      [[6, 5, 'hoge'] => "ho\x{4e00}foohoge\x{DE12}aa"],
      [[7, 4, 'hoge'] => "ho\x{4e00}foo\x{D800}hoge\x{DE12}aa"],
      [[8, 3, 'hoge'] => "ho\x{4e00}foo\x{10003}hoge\x{DE12}aa"],
      [[8+2**32, 3+2**32, 'hoge'] => "ho\x{4e00}foo\x{10003}hoge\x{DE12}aa"],
      [[8, -1, 'hoge'] => "ho\x{4e00}foo\x{10003}hoge"],
      [[6, 1, 'aa'] => "ho\x{4e00}fooaa\x{DC03}a\x{FEFF00}\x{54212}aa"],
      [[7, 1, 'aa'] => "ho\x{4e00}foo\x{D800}aaa\x{FEFF00}\x{54212}aa"],
    ) {
      for my $node (
        $doc->create_text_node ($data),
        $doc->create_comment ($data),
        $doc->create_processing_instruction ('hoge', $data),
      ) {
        test {
          my $c = shift;
          $node->replace_data (@{$test->[0]});
          is $node->data, $test->[1];
          done $c;
        } n => 1, name => ['replace_data', @{$test->[0]}];
      }
      if ($test->[0]->[1] == 0) {
        for my $node (
          $doc->create_text_node ($data),
          $doc->create_comment ($data),
          $doc->create_processing_instruction ('hoge', $data),
        ) {
          test {
            my $c = shift;
            $node->insert_data ($test->[0]->[0], $test->[0]->[2]);
            is $node->data, $test->[1];
            done $c;
          } n => 1, name => ['insert_data', @{$test->[0]}];
        }
      }
      if ($test->[0]->[2] eq '') {
        for my $node (
          $doc->create_text_node ($data),
          $doc->create_comment ($data),
          $doc->create_processing_instruction ('hoge', $data),
        ) {
          test {
            my $c = shift;
            $node->delete_data ($test->[0]->[0], $test->[0]->[1]);
            is $node->data, $test->[1];
            done $c;
          } n => 1, name => ['delete_data', @{$test->[0]}];
        }
      }
    }
  }

  for my $data ("ho\x{4e00}foo\x{10003}a\x{FEFF00}\x{54212}aa") {
    for my $node (
      $doc->create_text_node ($data),
      $doc->create_comment ($data),
      $doc->create_processing_instruction ('hoge', $data),
    ) {
      test {
        my $c = shift;
        for (
          [15, 0, ''],
          [15, 1, ''],
          [20, 1, 'aa'],
          [-1, 1, 'ba'],
          [2**32-1, 2**32, 'aaa'],
          [2**32-1, 1, 'aaa'],
        ) {
          dies_here_ok {
            $node->replace_data (@$_);
          };
          isa_ok $@, 'Web::DOM::Exception';
          is $@->name, 'IndexSizeError';
          is $@->message, 'Offset is greater than the length';
          is $node->data, $data;

          dies_here_ok {
            $node->delete_data ($_->[0], $_->[1]);
          };
          isa_ok $@, 'Web::DOM::Exception';
          is $@->name, 'IndexSizeError';
          is $@->message, 'Offset is greater than the length';
          is $node->data, $data;

          dies_here_ok {
            $node->insert_data ($_->[0], $_->[2]);
          };
          isa_ok $@, 'Web::DOM::Exception';
          is $@->name, 'IndexSizeError';
          is $@->message, 'Offset is greater than the length';
          is $node->data, $data;
        }
        done $c;
      } n => 5*6*3, name => 'replace_data, delete_data, insert_data';
    }
  }
}

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
