use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_event;
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotSupportedError';
  is $@->message, 'Unknown event interface';
  done $c;
} n => 4, name => 'create_event no interface';

for my $if (
  undef, 'HogeEvent', 'Document', 'CustomEvents', 'CloseEvent', 'HTMLEvent',
  'MutationEvent', 'Mutationevents', 'MutationNameEvent', 'TextEvent',
  'CompositionEvent', 'Keyevent', 'keyevents', 'ProgRESSevent', 'FocusEvent',
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    dies_here_ok {
      $doc->create_event ($if);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'NotSupportedError';
    is $@->message, 'Unknown event interface';
    done $c;
  } n => 4, name => ['create_event unknown interface', $if];
}

for my $test (
  [customevent => 'Web::DOM::CustomEvent'],
  [CustomEvent => 'Web::DOM::CustomEvent'],
  [Event => 'Web::DOM::Event'],
  [EventS => 'Web::DOM::Event'],
  [HTMLEvents => 'Web::DOM::Event'],
  [MouseEvent => 'Web::DOM::MouseEvent'],
  [mouseevents => 'Web::DOM::MouseEvent'],
  [uiEvent => 'Web::DOM::UIEvent'],
  [UiEvents => 'Web::DOM::UIEvent'],
  [Keyboardevent => 'Web::DOM::KeyboardEvent'],
  [MessageEvent => 'Web::DOM::MessageEvent'],
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $ev = $doc->create_event ($test->[0]);
    isa_ok $ev, 'Web::DOM::Event';
    isa_ok $ev, $test->[1];
    is $ev->type, '';
    ok not $ev->bubbles;
    ok not $ev->cancelable;
    ok not $ev->{initialized};
    done $c;
  } n => 6, name => ['create_event', $test->[0]];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = $doc->create_event ('Event');
  $ev->init_event ('abc');
  is $ev->type, 'abc';
  ok not $ev->{stop_propagation};
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  done $c;
} n => 8, name => 'create_event then init_event';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = $doc->create_event ('Event');
  $ev->prevent_default;
  $ev->stop_propagation;
  $ev->stop_immediate_propagation;
  $ev->init_event ('abc', 1, 0);
  is $ev->type, 'abc';
  ok not $ev->{stop_propagation};
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok $ev->bubbles;
  ok not $ev->cancelable;
  done $c;
} n => 8, name => 'create_event then init_event';

run_tests;

=head1 LICENSE

Copyright 2013-2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
