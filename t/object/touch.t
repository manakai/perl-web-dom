use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $view = bless {}, 'Web::DOM::WindowProxy';
  my $target = $doc->create_text_node ('');
  my $touch = $doc->create_touch
      ($view, $target, 1+2**32, 2+2**32, 3+2**32, 4+2**32, 5-2**32);
  isa_ok $touch, 'Web::DOM::Touch';
  is $touch->target, $target;
  is $touch->identifier, 1;
  is $touch->page_x, 2;
  is $touch->page_y, 3;
  is $touch->screen_x, 4;
  is $touch->screen_y, 5;
  is $touch->client_x, 0;
  is $touch->client_y, 0;
  done $c;
} n => 9, name => 'touch attributes';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $view = bless {}, 'Web::DOM::WindowProxy';
  my $target = $doc->create_text_node ('');
  my $touch1 = $doc->create_touch
      ($view, $target, 1+2**32, 2+2**32, 3+2**32, 4+2**32, 5-2**32);
  my $touch2 = $doc->create_touch
      ($view, $target, 1+2**32, 2+2**32, 3+2**32, 4+2**32, 5-2**32);
  ok not $touch1 eq $touch2;
  ok $touch1 ne $touch2;
  done $c;
} n => 2, name => 'eq and ne';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
