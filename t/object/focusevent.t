use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::FocusEvent;

test {
  my $c = shift;
  my $ev = new Web::DOM::FocusEvent 'h';
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
  my $ev = new Web::DOM::FocusEvent 'h', {};
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
    new Web::DOM::FocusEvent 'h', '{}';
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a hash reference';
  done $c;
} n => 3, name => 'constructor not dict';

test {
  my $c = shift;
  my $ev = new Web::DOM::FocusEvent 'h', {bubbles => 1, detail => 128.45 + -2**32};
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
  my $ev = new Web::DOM::FocusEvent 'h', {bubbles => 1, view => $win};
  is $ev->type, 'h';
  isa_ok $ev->view, 'Web::DOM::WindowProxy';
  is $ev->view, $win;
  is $ev->detail, 0;
  is $ev->related_target, undef;
  done $c;
} n => 5, name => 'constructor window';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::WindowProxy';
  my $ev = new Web::DOM::FocusEvent 'h', {bubbles => 1, view => undef};
  is $ev->type, 'h';
  is $ev->view, undef;
  is $ev->detail, 0;
  is $ev->related_target, undef;
  done $c;
} n => 4, name => 'constructor window undef';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::Window';
  dies_here_ok {
    new Web::DOM::FocusEvent 'h', {bubbles => 1, view => $win};
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The |view| value is not an object of interface |WindowProxy|';
  done $c;
} n => 3, name => 'constructor bad window';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::WindowProxy';
  my $target = bless {}, 'Web::DOM::EventTarget';
  my $ev = new Web::DOM::FocusEvent 'h', {bubbles => 1, view => $win,
                                          related_target => $target};
  is $ev->type, 'h';
  isa_ok $ev->view, 'Web::DOM::WindowProxy';
  is $ev->view, $win;
  is $ev->detail, 0;
  isa_ok $ev->related_target, 'Web::DOM::EventTarget';
  is $ev->related_target, $target;
  done $c;
} n => 6, name => 'constructor window related';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::WindowProxy';
  my $target = bless {}, 'Web::DOM::EventTarget';
  my $ev = new Web::DOM::FocusEvent 'h', {bubbles => 1, view => $win,
                                          related_target => undef};
  is $ev->type, 'h';
  isa_ok $ev->view, 'Web::DOM::WindowProxy';
  is $ev->view, $win;
  is $ev->detail, 0;
  is $ev->related_target, undef;
  done $c;
} n => 5, name => 'constructor window related';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::Window';
  dies_here_ok {
    new Web::DOM::FocusEvent 'h', {bubbles => 1, related_target => $win};
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The |related_target| value is not an object of interface |EventTarget|';
  done $c;
} n => 3, name => 'constructor bad related target';

test {
  my $c = shift;
  dies_here_ok {
    new Web::DOM::FocusEvent 'h', {bubbles => 1, related_target => 5122};
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The |related_target| value is not an object of interface |EventTarget|';
  done $c;
} n => 3, name => 'constructor bad related target';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
