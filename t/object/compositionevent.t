use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::CompositionEvent;

test {
  my $c = shift;
  my $ev = new Web::DOM::CompositionEvent 'h';
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
  is $ev->data, undef;
  is $ev->locale, '';
  done $c;
} n => 12, name => 'constructor no dict';

test {
  my $c = shift;
  my $ev = new Web::DOM::CompositionEvent 'h', {};
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
  is $ev->data, undef;
  is $ev->locale, '';
  done $c;
} n => 12, name => 'constructor empty dict';

test {
  my $c = shift;
  dies_here_ok {
    new Web::DOM::CompositionEvent 'h', '{}';
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a hash reference';
  done $c;
} n => 3, name => 'constructor not dict';

test {
  my $c = shift;
  my $ev = new Web::DOM::CompositionEvent 'h', {bubbles => 1, detail => 128.45 + -2**32};
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
  my $ev = new Web::DOM::CompositionEvent 'h', {bubbles => 1, view => $win};
  is $ev->type, 'h';
  isa_ok $ev->view, 'Web::DOM::WindowProxy';
  is $ev->view, $win;
  is $ev->detail, 0;
  is $ev->data, undef;
  is $ev->locale, '';
  done $c;
} n => 6, name => 'constructor window';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::WindowProxy';
  my $ev = new Web::DOM::CompositionEvent 'h', {bubbles => 1, view => undef};
  is $ev->type, 'h';
  is $ev->view, undef;
  is $ev->detail, 0;
  done $c;
} n => 3, name => 'constructor window undef';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::Window';
  dies_here_ok {
    new Web::DOM::CompositionEvent 'h', {bubbles => 1, view => $win};
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The |view| value is not an object of interface |WindowProxy|';
  done $c;
} n => 3, name => 'constructor bad window';

test {
  my $c = shift;
  my $ev = new Web::DOM::CompositionEvent 'h', {data => 'hoge', locale => 'a'};
  is $ev->data, 'hoge';
  is $ev->locale, 'a';
  done $c;
} n => 2, name => 'constructor compositioneventinit';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
