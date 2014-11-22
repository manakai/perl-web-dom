use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::CustomEvent;
use Web::DOM::Document;

test {
  my $c = shift;
  my $ev = new Web::DOM::CustomEvent 'h';
  is $ev->type, 'h';
  ok not $ev->{stop_propagation};
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->detail, undef;
  done $c;
} n => 9, name => 'constructor no dict';

test {
  my $c = shift;
  my $ev = new Web::DOM::CustomEvent 'h', {};
  is $ev->type, 'h';
  ok not $ev->{stop_propagation};
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->detail, undef;
  done $c;
} n => 9, name => 'constructor empty dict';

test {
  my $c = shift;
  dies_here_ok {
    new Web::DOM::CustomEvent 'h', '{}';
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a hash reference';
  done $c;
} n => 3, name => 'constructor not dict';

test {
  my $c = shift;
  my $hoge = [];
  my $ev = new Web::DOM::CustomEvent 'h', {bubbles => 1, detail => $hoge};
  is $ev->type, 'h';
  ok not $ev->{stop_propagation};
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->detail, $hoge;
  done $c;
} n => 9, name => 'constructor non empty dict';

test {
  my $c = shift;
  my $ev = new Web::DOM::CustomEvent 'h';
  $ev->init_custom_event ('abc', 0, 0, 12);
  $ev->init_event ('abcd', 0, 0, 31);
  is $ev->type, 'abcd';
  ok not $ev->{stop_propagation};
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->detail, 12;
  done $c;
} n => 9, name => 'constructor then init_event';

test {
  my $c = shift;
  my $ev = new Web::DOM::CustomEvent 'h';
  $ev->init_custom_event ('abc', 0, 0, 12);
  is $ev->type, 'abc';
  ok not $ev->{stop_propagation};
  ok not $ev->{stop_immediate_propagation};
  ok not $ev->default_prevented;
  ok not $ev->is_trusted;
  is $ev->target, undef;
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->detail, 12;
  done $c;
} n => 9, name => 'constructor then init_custom_event';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = $doc->create_event ('customevent');
  $ev->init_custom_event ('foo', 1, 1, 55);
  $doc->add_event_listener ('foo', sub {
    $ev->init_custom_event ('bar', 0, -0, 146);
    is $ev->type, 'foo';
    is !!$ev->cancelable, !!1;
    is !!$ev->bubbles, !!1;
    is $ev->detail, 55;
  });
  $doc->dispatch_event ($ev);
  is $ev->type, 'foo';
  is !!$ev->cancelable, !!1;
  is !!$ev->bubbles, !!1;
  is $ev->detail, 55;
  undef $ev;
  done $c;
} n => 8, name => 'init while dispatched';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = $doc->create_event ('customevent');
  $ev->init_custom_event ('foo', 1, 1, 55);
  $doc->dispatch_event ($ev);
  $ev->init_custom_event ('bar', 0, -0, 146);
  is $ev->type, 'bar';
  is !!$ev->cancelable, !!0;
  is !!$ev->bubbles, !!0;
  is $ev->detail, 146;
  undef $ev;
  done $c;
} n => 4, name => 'init after dispatched';

run_tests;

=head1 LICENSE

Copyright 2013-2014 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
