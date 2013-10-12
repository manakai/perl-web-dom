use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::TouchEvent;
use Web::DOM::Document;

test {
  my $c = shift;
  my $ev = new Web::DOM::TouchEvent 'h';
  is $ev->type, 'h';
  ok not $ev->{stop_propagation};
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->view, undef;
  is $ev->detail, 0;
  ok not $ev->meta_key;
  isa_ok $ev->touches, 'Web::DOM::TouchList';
  isa_ok $ev->target_touches, 'Web::DOM::TouchList';
  isa_ok $ev->changed_touches, 'Web::DOM::TouchList';
  dies_here_ok {
    push @{$ev->touches}, 'aa';
  };
  like $@, qr{^Modification of a read-only value attempted};
  is $ev->touches->length, 0;
  done $c;
} n => 17, name => 'constructor no dict';

test {
  my $c = shift;
  my $ev = new Web::DOM::TouchEvent 'h', {};
  is $ev->type, 'h';
  ok not $ev->{stop_propagation};
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->view, undef;
  is $ev->detail, 0;
  ok not $ev->meta_key;
  isa_ok $ev->touches, 'Web::DOM::TouchList';
  isa_ok $ev->target_touches, 'Web::DOM::TouchList';
  isa_ok $ev->changed_touches, 'Web::DOM::TouchList';
  done $c;
} n => 14, name => 'constructor empty dict';

test {
  my $c = shift;
  dies_here_ok {
    new Web::DOM::TouchEvent 'h', '{}';
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a hash reference';
  done $c;
} n => 3, name => 'constructor not dict';

test {
  my $c = shift;
  my $ev = new Web::DOM::TouchEvent 'h',
      {bubbles => 1, detail => 128.45 + -2**32, meta_key => 1};
  is $ev->type, 'h';
  ok not $ev->{stop_propagation};
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->view, undef;
  is $ev->detail, 129;
  ok $ev->meta_key;
  done $c;
} n => 11, name => 'constructor non empty dict';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::WindowProxy';
  my $ev = new Web::DOM::TouchEvent 'h', {bubbles => 1, view => $win};
  is $ev->type, 'h';
  isa_ok $ev->view, 'Web::DOM::WindowProxy';
  is $ev->view, $win;
  is $ev->detail, 0;
  done $c;
} n => 4, name => 'constructor window';

test {
  my $c = shift;
  my $ev = new Web::DOM::TouchEvent 'h', {bubbles => 1, view => undef};
  is $ev->type, 'h';
  is $ev->view, undef;
  is $ev->detail, 0;
  done $c;
} n => 3, name => 'constructor window';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::Window';
  dies_here_ok {
    new Web::DOM::TouchEvent 'h', {bubbles => 1, view => $win};
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The |view| value is not an object of interface |WindowProxy|';
  done $c;
} n => 3, name => 'constructor bad window';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $touches = $doc->create_touch_list;
  my $ev = new Web::DOM::TouchEvent 'h',
      {bubbles => 1, detail => 128.45 + -2**32, meta_key => 1,
       touches => $touches};
  is $ev->type, 'h';
  ok not $ev->{stop_propagation};
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->view, undef;
  is $ev->detail, 129;
  ok $ev->meta_key;
  is $ev->touches, $touches;
  isnt $ev->target_touches, $touches;
  done $c;
} n => 13, name => 'constructor touchlist';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
