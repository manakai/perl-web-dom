use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::MessageEvent;

test {
  my $c = shift;
  my $ev = new Web::DOM::MessageEvent 'h';
  is $ev->type, 'h';
  ok not $ev->{stop_propagation};
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->source, undef;
  is $ev->data, undef;
  done $c;
} n => 10, name => 'constructor no dict';

test {
  my $c = shift;
  my $ev = new Web::DOM::MessageEvent 'h', {};
  is $ev->type, 'h';
  ok not $ev->{stop_propagation};
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->source, undef;
  is $ev->data, undef;
  done $c;
} n => 10, name => 'constructor empty dict';

test {
  my $c = shift;
  dies_here_ok {
    new Web::DOM::MessageEvent 'h', '{}';
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a hash reference';
  done $c;
} n => 3, name => 'constructor not dict';

test {
  my $c = shift;
  my $ev = new Web::DOM::MessageEvent 'h', {bubbles => 1, data => 128.45 + -2**32};
  is $ev->type, 'h';
  ok not $ev->{stop_propagation};
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->source, undef;
  is $ev->data, -4294967167.55;
  done $c;
} n => 10, name => 'constructor non empty dict';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::WindowProxy';
  my $ev = new Web::DOM::MessageEvent 'h', {bubbles => 1, source => $win};
  is $ev->type, 'h';
  isa_ok $ev->source, 'Web::DOM::WindowProxy';
  is $ev->source, $win;
  is $ev->data, undef;
  is $ev->ports, undef;
  done $c;
} n => 5, name => 'constructor window';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::WindowProxy';
  my $ev = new Web::DOM::MessageEvent 'h', {bubbles => 1, source => undef};
  is $ev->type, 'h';
  is $ev->source, undef;
  is $ev->origin, '';
  is $ev->last_event_id, '';
  is $ev->data, undef;
  is $ev->ports, undef;
  done $c;
} n => 6, name => 'constructor window undef';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::WindowProxy';
  my $ev = new Web::DOM::MessageEvent 'h', {bubbles => 1, source => undef,
                                            last_event_id => 'abc',
                                            origin => 'foo bar'};
  is $ev->type, 'h';
  is $ev->source, undef;
  is $ev->origin, 'foo bar';
  is $ev->last_event_id, 'abc';
  is $ev->data, undef;
  is $ev->ports, undef;
  done $c;
} n => 6, name => 'constructor window undef';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::Window';
  dies_here_ok {
    new Web::DOM::MessageEvent 'h', {bubbles => 1, source => $win};
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The |source| value is not an object of interface |WindowProxy|';
  done $c;
} n => 3, name => 'constructor bad window';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::WindowProxy';
  my $target = bless {}, 'Web::DOM::EventTarget';
  my $ev = new Web::DOM::MessageEvent 'h', {bubbles => 1, source => $win,
                                          ports => undef};
  is $ev->type, 'h';
  isa_ok $ev->source, 'Web::DOM::WindowProxy';
  is $ev->source, $win;
  is $ev->data, undef;
  is $ev->ports, undef;
  done $c;
} n => 5, name => 'constructor window related';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::Window';
  dies_here_ok {
    new Web::DOM::MessageEvent 'h', {bubbles => 1, ports => $win};
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The |ports| value is not an object of interface |XXX sequence<MessagePort>|';
  done $c;
} n => 3, name => 'constructor bad ports';

test {
  my $c = shift;
  dies_here_ok {
    new Web::DOM::MessageEvent 'h', {bubbles => 1, ports => 5122};
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The |ports| value is not an object of interface |XXX sequence<MessagePort>|';
  done $c;
} n => 3, name => 'constructor bad ports';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::WindowProxy';
  my $target = bless {}, 'Web::DOM::EventTarget';
  my $ev = new Web::DOM::MessageEvent 'h', {bubbles => 1, data => $win};
  is $ev->type, 'h';
  isa_ok $ev->data, 'Web::DOM::WindowProxy';
  done $c;
} n => 2, name => 'constructor data window';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
