use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::Differences;
use Test::DOM::Exception;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $list = $doc->create_touch_list;
  is $list->length, 0;
  is scalar @$list, 0;
  is $list->item (0), undef;
  is $list->item (1), undef;
  is $list->item (0 + 2**32 * 2), undef;
  is $list->item (-1), undef;
  done $c;
} n => 6, name => 'list items empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $view = bless {}, 'Web::DOM::WindowProxy';
  my $target = $doc->create_text_node ('');
  my $touch = $doc->create_touch
      ($view, $target, 1+2**32, 2+2**32, 3+2**32, 4+2**32, 5-2**32);
  my $list = $doc->create_touch_list ($touch);
  is $list->length, 1;
  is scalar @$list, 1;
  is $list->item (0), $touch;
  is $list->item (1), undef;
  is $list->item (0 + 2**32 * 2), $touch;
  is $list->item (-1), undef;
  eq_or_diff $list->as_list, [$touch];
  push @{$list->to_a}, 42;
  eq_or_diff $list->to_a, [$touch];
  eq_or_diff [$list->to_list], [$touch];
  ok $list;
  ok $list eq $list;
  done $c;
} n => 11, name => 'list items';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $view = bless {}, 'Web::DOM::WindowProxy';
  my $target = $doc->create_text_node ('');
  my $touch = $doc->create_touch
      ($view, $target, 1+2**32, 2+2**32, 3+2**32, 4+2**32, 5-2**32);
  my $list1 = $doc->create_touch_list ($touch);
  my $list2 = $doc->create_touch_list ($touch);
  ok not $list1 eq $list2;
  ok $list1 ne $list2;
  done $c;
} n => 2, name => 'eq ne';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $view = bless {}, 'Web::DOM::WindowProxy';
  my $target = $doc->create_text_node ('');
  my $touch1 = $doc->create_touch
      ($view, $target, 1+2**32, 2+2**32, 3+2**32, 4+2**32, 5-2**32);
  my $touch2 = $doc->create_touch
      ($view, $target, 1+2**32, 2+2**32, 3+2**32, 4+2**32, 5-2**32);
  my $list1 = $doc->create_touch_list ($touch1, $touch2);
  {
    dies_here_ok {
      $list1->[0] = $touch1;
    };
    like $@, qr{^Modification of a read-only value attempted};
  }
  {
    dies_here_ok {
      push @$list1, 'abc';
    };
    like $@, qr{^Modification of a read-only value attempted};
  }
  eq_or_diff [@$list1], [$touch1, $touch2];
  done $c;
} n => 2*2 + 1, name => 'read-onlyness';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
