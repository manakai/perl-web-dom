use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::UIEvent;

test {
  my $c = shift;
  my $ev = new Web::DOM::UIEvent 'h';
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
  done $c;
} n => 10, name => 'constructor no dict';

test {
  my $c = shift;
  my $ev = new Web::DOM::UIEvent 'h', {};
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
  done $c;
} n => 10, name => 'constructor empty dict';

test {
  my $c = shift;
  dies_here_ok {
    new Web::DOM::UIEvent 'h', '{}';
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a hash reference';
  done $c;
} n => 3, name => 'constructor not dict';

test {
  my $c = shift;
  my $ev = new Web::DOM::UIEvent 'h', {bubbles => 1, detail => 128.45 + -2**32};
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
  done $c;
} n => 10, name => 'constructor non empty dict';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::WindowProxy';
  my $ev = new Web::DOM::UIEvent 'h', {bubbles => 1, view => $win};
  is $ev->type, 'h';
  isa_ok $ev->view, 'Web::DOM::WindowProxy';
  is $ev->view, $win;
  is $ev->detail, 0;
  done $c;
} n => 4, name => 'constructor window';

test {
  my $c = shift;
  my $ev = new Web::DOM::UIEvent 'h', {bubbles => 1, view => undef};
  is $ev->type, 'h';
  is $ev->view, undef;
  is $ev->detail, 0;
  done $c;
} n => 3, name => 'constructor window';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::Window';
  dies_here_ok {
    new Web::DOM::UIEvent 'h', {bubbles => 1, view => $win};
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The |view| value is not an object of interface |WindowProxy|';
  done $c;
} n => 3, name => 'constructor bad window';

test {
  my $c = shift;
  my $ev = new Web::DOM::UIEvent 'h';
  $ev->init_ui_event ('abc', 0, 0, undef, -12);
  $ev->init_event ('abcd', 0, 0, 31);
  is $ev->type, 'abcd';
  ok not $ev->{stop_propagation};
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->view, undef;
  is $ev->detail, -12;
  done $c;
} n => 10, name => 'constructor then init_event';

test {
  my $c = shift;
  my $ev = new Web::DOM::UIEvent 'h';
  $ev->init_ui_event ('abc', 0, 0, undef, 12.55 + 2**16 + 2**32);
  is $ev->type, 'abc';
  ok not $ev->{stop_propagation};
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->view, undef;
  is $ev->detail, 12 + 2**16;
  done $c;
} n => 10, name => 'constructor then init_ui_event';

test {
  my $c = shift;
  my $ev = new Web::DOM::UIEvent 'h';
  my $win = bless {}, 'Web::DOM::WindowProxy';
  $ev->init_ui_event ('abc', 0, 0, $win, 12.55 + 2**16);
  is $ev->type, 'abc';
  is $ev->view, $win;
  isa_ok $ev->view, 'Web::DOM::WindowProxy';
  is $ev->detail, 12 + 2**16;
  done $c;
} n => 4, name => 'init_ui_event window';

test {
  my $c = shift;
  my $ev = new Web::DOM::UIEvent 'h';
  my $win = bless {}, 'Web::DOM::WindowProxy2';
  dies_here_ok {
    $ev->init_ui_event ('abc', 0, 0, $win, 12.55 + 2**16);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The fourth argument is not a WindowProxy';
  is $ev->type, 'h';
  is $ev->view, undef;
  is $ev->detail, 0;
  done $c;
} n => 6, name => 'init_ui_event window';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
