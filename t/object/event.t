use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Event;

test {
  my $c = shift;
  is NONE, 0;
  is CAPTURING_PHASE, 1;
  is AT_TARGET, 2;
  is BUBBLING_PHASE, 3;
  done $c;
} n => 4, name => 'exported constants';

test {
  my $c = shift;
  is +Web::DOM::Event::NONE, 0;
  is +Web::DOM::Event::CAPTURING_PHASE, 1;
  is +Web::DOM::Event::AT_TARGET, 2;
  is +Web::DOM::Event::BUBBLING_PHASE, 3;
  done $c;
} n => 4, name => 'class constants';

test {
  my $c = shift;

  my $ev = new Web::DOM::Event;
  isa_ok $ev, 'Web::DOM::Event';
  is $ev->type, '';
  is $ev->target, undef;
  is $ev->current_target, undef;
  is $ev->event_phase, 0;
  is $ev->NONE, 0;
  is $ev->CAPTURING_PHASE, 1;
  is $ev->AT_TARGET, 2;
  is $ev->BUBBLING_PHASE, 3;
  ok not $ev->manakai_propagation_stopped;
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->timestamp, time;
  ok $ev->{initialized};
  ok not $ev->manakai_dispatched;
  done $c;
} n => 18, name => 'constructor with no args';

test {
  my $c = shift;

  my $ev = new Web::DOM::Event 'Hoge fuga';
  isa_ok $ev, 'Web::DOM::Event';
  is $ev->type, 'Hoge fuga';
  is $ev->target, undef;
  is $ev->current_target, undef;
  is $ev->event_phase, 0;
  is $ev->NONE, 0;
  is $ev->CAPTURING_PHASE, 1;
  is $ev->AT_TARGET, 2;
  is $ev->BUBBLING_PHASE, 3;
  ok not $ev->manakai_propagation_stopped;
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->timestamp, time;
  ok $ev->{initialized};
  ok not $ev->manakai_dispatched;
  done $c;
} n => 18, name => 'constructor with type';

test {
  my $c = shift;

  my $ev = new Web::DOM::Event 'Hoge fuga', {};
  isa_ok $ev, 'Web::DOM::Event';
  is $ev->type, 'Hoge fuga';
  is $ev->target, undef;
  is $ev->current_target, undef;
  is $ev->event_phase, 0;
  is $ev->NONE, 0;
  is $ev->CAPTURING_PHASE, 1;
  is $ev->AT_TARGET, 2;
  is $ev->BUBBLING_PHASE, 3;
  ok not $ev->manakai_propagation_stopped;
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->timestamp, time;
  ok $ev->{initialized};
  ok not $ev->manakai_dispatched;
  done $c;
} n => 18, name => 'constructor with type and empty dict';

test {
  my $c = shift;

  my $ev = new Web::DOM::Event 'Hoge fuga', {bubbles => 'ab c',
                                             cancelable => 0,
                                             target => 'abc'};
  isa_ok $ev, 'Web::DOM::Event';
  is $ev->type, 'Hoge fuga';
  is $ev->target, undef;
  is $ev->current_target, undef;
  is $ev->event_phase, 0;
  is $ev->NONE, 0;
  is $ev->CAPTURING_PHASE, 1;
  is $ev->AT_TARGET, 2;
  is $ev->BUBBLING_PHASE, 3;
  ok not $ev->manakai_propagation_stopped;
  ok not $ev->{stop_immediate_propagation};
  ok $ev->bubbles;
  isnt $ev->bubbles, 'ab c';
  ok not $ev->cancelable;
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->timestamp, time;
  ok $ev->{initialized};
  ok not $ev->manakai_dispatched;
  done $c;
} n => 19, name => 'constructor with type and non empty dict';

test {
  my $c = shift;
  dies_here_ok {
    new Web::DOM::Event 'hoge', 'abc';
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a hash reference';
  done $c;
} n => 3, name => 'constructor not dict';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event '';
  $ev->stop_propagation;
  ok $ev->manakai_propagation_stopped;
  ok not $ev->manakai_immediate_propagation_stopped;
  $ev->stop_propagation;
  ok $ev->manakai_propagation_stopped;
  ok not $ev->manakai_immediate_propagation_stopped;
  $ev->stop_immediate_propagation;
  ok $ev->manakai_propagation_stopped;
  ok $ev->manakai_immediate_propagation_stopped;
  done $c;
} n => 6, name => 'stop_propagation';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event '';
  $ev->stop_immediate_propagation;
  ok $ev->manakai_propagation_stopped;
  ok $ev->manakai_immediate_propagation_stopped;
  $ev->stop_immediate_propagation;
  ok $ev->manakai_propagation_stopped;
  ok $ev->manakai_immediate_propagation_stopped;
  $ev->stop_propagation;
  ok $ev->manakai_propagation_stopped;
  ok $ev->manakai_immediate_propagation_stopped;
  done $c;
} n => 6, name => 'stop_immediate_propagation';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'h';
  $ev->prevent_default;
  ok not $ev->default_prevented;
  $ev->prevent_default;
  ok not $ev->default_prevented;
  done $c;  
} n => 2, name => 'prevent_default not cancelable';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'h', {cancelable => 1};
  $ev->prevent_default;
  ok $ev->default_prevented;
  $ev->prevent_default;
  ok $ev->default_prevented;
  done $c;  
} n => 2, name => 'prevent_default cancelable';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'h';
  $ev->init_event ('abc');
  is $ev->type, 'abc';
  ok not $ev->manakai_propagation_stopped;
  ok not $ev->manakai_immediate_propagation_stopped;
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  done $c;
} n => 8, name => 'constructor then init_event';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'h', {cancelable => 1, bubbles => 1};
  $ev->prevent_default;
  $ev->stop_propagation;
  $ev->stop_immediate_propagation;
  $ev->init_event ('abc');
  is $ev->type, 'abc';
  ok not $ev->manakai_propagation_stopped;
  ok not $ev->manakai_immediate_propagation_stopped;
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  done $c;
} n => 8, name => 'constructor then init_event';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'h';
  $ev->prevent_default;
  $ev->stop_propagation;
  $ev->stop_immediate_propagation;
  $ev->init_event ('abc', 1, 0);
  is $ev->type, 'abc';
  ok not $ev->manakai_propagation_stopped;
  ok not $ev->manakai_immediate_propagation_stopped;
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok $ev->bubbles;
  ok not $ev->cancelable;
  done $c;
} n => 8, name => 'constructor then init_event, bubbles';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'h';
  $ev->prevent_default;
  $ev->stop_propagation;
  $ev->stop_immediate_propagation;
  $ev->init_event ('abc', 0, 1);
  is $ev->type, 'abc';
  ok not $ev->manakai_propagation_stopped;
  ok not $ev->manakai_immediate_propagation_stopped;
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok not $ev->bubbles;
  ok $ev->cancelable;
  done $c;
} n => 8, name => 'constructor then init_event, cancelable';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'h';
  $ev->init_event ('abc', 1, 1);
  $ev->prevent_default;
  $ev->stop_propagation;
  $ev->stop_immediate_propagation;
  $ev->init_event ('def');
  is $ev->type, 'def';
  ok not $ev->manakai_propagation_stopped;
  ok not $ev->manakai_immediate_propagation_stopped;
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  done $c;
} n => 8, name => 'constructor then init_event';

## init_event after create_event tests found in document-events.t.
## init_event after dispatch tests found in eventtarget.t.

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
