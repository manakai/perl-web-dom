use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::MouseEvent;

test {
  my $c = shift;
  my $ev = new Web::DOM::MouseEvent 'h';
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
  my $ev = new Web::DOM::MouseEvent 'h', {};
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
    new Web::DOM::MouseEvent 'h', '{}';
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a hash reference';
  done $c;
} n => 3, name => 'constructor not dict';

test {
  my $c = shift;
  my $ev = new Web::DOM::MouseEvent 'h', {bubbles => 1, detail => 128.45 + -2**32};
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
  my $ev = new Web::DOM::MouseEvent 'h', {bubbles => 1, view => $win};
  is $ev->type, 'h';
  isa_ok $ev->view, 'Web::DOM::WindowProxy';
  is $ev->view, $win;
  is $ev->detail, 0;
  is $ev->related_target, undef;
  done $c;
} n => 5, name => 'constructor window';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::Window';
  dies_here_ok {
    new Web::DOM::MouseEvent 'h', {bubbles => 1, view => $win};
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The |view| value is not an object of interface |WindowProxy|';
  done $c;
} n => 3, name => 'constructor bad window';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::WindowProxy';
  my $rt = bless {}, 'Web::DOM::EventTarget';
  my $ev = new Web::DOM::MouseEvent 'h',
      {bubbles => 1, view => $win,
       screen_x => -14.5 + 2**32,
       screen_y => -51.55 + 2**32,
       client_x => -66.40001 + 2**32,
       client_y => -105.44 + 2**32,
       ctrl_key => "abc",
       shift_key => "def",
       meta_key => '0 but true',
       alt_key => 'aa',
       button => -65.55 + 2**32 + 2**16,
       buttons => -66.11 + 2**32 + 2**16,
       related_target => $rt};
  is $ev->type, 'h';
  isa_ok $ev->view, 'Web::DOM::WindowProxy';
  is $ev->view, $win;
  is $ev->detail, 0;
  is $ev->screen_x, -15;
  is $ev->screen_y, -52;
  is $ev->client_x, -67;
  is $ev->client_y, -106;
  is $ev->ctrl_key, 1;
  is $ev->shift_key, 1;
  is $ev->alt_key, 1;
  is $ev->meta_key, 1;
  is $ev->button, 2**16 - 65 - 1;
  is $ev->buttons, 2**16 - 66 - 1;
  is $ev->related_target, $rt;
  is $ev->offset_x, 0;
  is $ev->offset_y, 0;
  is $ev->page_x, 0;
  is $ev->page_y, 0;
  is $ev->x, -67;
  is $ev->y, -106;
  is $ev->region, undef;
  done $c;
} n => 22, name => 'constructor window mouse';

test {
  my $c = shift;
  my $ev = new Web::DOM::MouseEvent 'h', {};
  is $ev->type, 'h';
  is $ev->view, undef;
  is $ev->detail, 0;
  is $ev->screen_x, 0;
  is $ev->screen_y, 0;
  is $ev->client_x, 0;
  is $ev->client_y, 0;
  ok not $ev->ctrl_key;
  ok not $ev->shift_key;
  ok not $ev->alt_key;
  ok not $ev->meta_key;
  is $ev->button, 0;
  is $ev->buttons, 0;
  is $ev->related_target, undef;
  is $ev->offset_x, 0;
  is $ev->offset_y, 0;
  is $ev->page_x, 0;
  is $ev->page_y, 0;
  is $ev->x, 0;
  is $ev->y, 0;
  is $ev->region, undef;
  done $c;
} n => 21, name => 'constructor window mouse';

test {
  my $c = shift;
  my $ev = new Web::DOM::MouseEvent 'h',
      {view => undef, related_target => undef,
       meta_key => 5, shift_key => 1};
  is $ev->type, 'h';
  is $ev->view, undef;
  is $ev->detail, 0;
  is $ev->screen_x, 0;
  is $ev->screen_y, 0;
  is $ev->client_x, 0;
  is $ev->client_y, 0;
  ok not $ev->ctrl_key;
  ok $ev->shift_key;
  ok not $ev->alt_key;
  ok $ev->meta_key;
  is $ev->button, 0;
  is $ev->buttons, 0;
  is $ev->related_target, undef;
  is $ev->offset_x, 0;
  is $ev->offset_y, 0;
  is $ev->page_x, 0;
  is $ev->page_y, 0;
  is $ev->x, 0;
  is $ev->y, 0;
  is $ev->region, undef;
  done $c;
} n => 21, name => 'constructor window mouse';

test {
  my $c = shift;
  my $ev = new Web::DOM::MouseEvent 'h', {buttons => 5};
  my $v = bless {}, 'Web::DOM::WindowProxy';
  my $rt = bless {}, 'Web::DOM::EventTarget';
  $ev->init_mouse_event ('hoge', 1, 0, $v, -51 + 2**32,
                         -42 + 2**32, -66.1 + 2**32,
                         -10.0 + 2**32, -77.1 + 2**32,
                         0, 1, 0, 1,
                         -120, $rt);
  is $ev->type, 'hoge';
  ok $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->view, $v;
  is $ev->detail, -51;
  is $ev->screen_x, -42;
  is $ev->screen_y, -67;
  is $ev->client_x, -10;
  is $ev->client_y, -78;
  ok not $ev->ctrl_key;
  ok $ev->alt_key;
  ok not $ev->shift_key;
  ok $ev->meta_key;
  ok not $ev->alt_graph_key;
  ok not $ev->get_modifier_state ('Control');
  ok $ev->get_modifier_state ('Alt');
  ok not $ev->get_modifier_state ('Shift');
  ok $ev->get_modifier_state ('Meta');
  ok not $ev->get_modifier_state ('AltGraph');
  ok not $ev->get_modifier_state ('HogeFuga');
  ok not $ev->get_modifier_state ('SymbolLock');
  is $ev->button, -120 + 2**16;
  is $ev->buttons, 5;
  is $ev->related_target, $rt;
  is $ev->offset_x, 0;
  is $ev->offset_y, 0;
  is $ev->page_x, 0;
  is $ev->page_y, 0;
  is $ev->x, -10;
  is $ev->y, -78;
  is $ev->region, undef;
  done $c;
} n => 31, name => 'init_mouse_event';

test {
  my $c = shift;
  my $ev = new Web::DOM::MouseEvent 'h', {buttons => 5};
  $ev->init_mouse_event ('hoge', 1, 0, undef, -51 + 2**32,
                         -42 + 2**32, -66.1 + 2**32,
                         -10.0 + 2**32, -77.1 + 2**32,
                         0, 1, 0, 1,
                         -120, undef);
  is $ev->type, 'hoge';
  ok $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->view, undef;
  is $ev->detail, -51;
  is $ev->screen_x, -42;
  is $ev->screen_y, -67;
  is $ev->client_x, -10;
  is $ev->client_y, -78;
  ok not $ev->ctrl_key;
  ok $ev->alt_key;
  ok not $ev->shift_key;
  ok $ev->meta_key;
  is $ev->button, -120 + 2**16;
  is $ev->buttons, 5;
  is $ev->related_target, undef;
  is $ev->offset_x, 0;
  is $ev->offset_y, 0;
  is $ev->page_x, 0;
  is $ev->page_y, 0;
  is $ev->x, -10;
  is $ev->y, -78;
  is $ev->region, undef;
  done $c;
} n => 23, name => 'init_mouse_event undef';

test {
  my $c = shift;
  my $ev = new Web::DOM::MouseEvent 'h', {buttons => 5};
  dies_here_ok {
    $ev->init_mouse_event ('hoge', 1, 0, 'abc', -51 + 2**32,
                           -42 + 2**32, -66.1 + 2**32,
                           -10.0 + 2**32, -77.1 + 2**32,
                           0, 1, 0, 1,
                           -120, undef);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The fourth argument is not a WindowProxy';
  is $ev->type, 'h';
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->view, undef;
  is $ev->detail, 0;
  is $ev->screen_x, 0;
  is $ev->screen_y, 0;
  is $ev->client_x, 0;
  is $ev->client_y, 0;
  ok not $ev->ctrl_key;
  ok not $ev->alt_key;
  ok not $ev->shift_key;
  ok not $ev->meta_key;
  is $ev->button, 0;
  is $ev->buttons, 5;
  is $ev->related_target, undef;
  is $ev->offset_x, 0;
  is $ev->offset_y, 0;
  is $ev->page_x, 0;
  is $ev->page_y, 0;
  is $ev->x, 0;
  is $ev->y, 0;
  is $ev->region, undef;
  done $c;
} n => 26, name => 'init_mouse_event error';

test {
  my $c = shift;
  my $ev = new Web::DOM::MouseEvent 'h', {buttons => 5};
  dies_here_ok {
    $ev->init_mouse_event ('hoge', 1, 0, undef, -51 + 2**32,
                           -42 + 2**32, -66.1 + 2**32,
                           -10.0 + 2**32, -77.1 + 2**32,
                           0, 1, 0, 1,
                           -120, {});
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The 16th argument is not an EventTarget';
  is $ev->type, 'h';
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->view, undef;
  is $ev->detail, 0;
  is $ev->screen_x, 0;
  is $ev->screen_y, 0;
  is $ev->client_x, 0;
  is $ev->client_y, 0;
  ok not $ev->ctrl_key;
  ok not $ev->alt_key;
  ok not $ev->shift_key;
  ok not $ev->meta_key;
  is $ev->button, 0;
  is $ev->buttons, 5;
  is $ev->related_target, undef;
  is $ev->offset_x, 0;
  is $ev->offset_y, 0;
  is $ev->page_x, 0;
  is $ev->page_y, 0;
  is $ev->x, 0;
  is $ev->y, 0;
  is $ev->region, undef;
  done $c;
} n => 26, name => 'init_mouse_event error';

test {
  my $c = shift;
  my $ev = new Web::DOM::MouseEvent 'h', {buttons => 5,
                                          region => undef};
  is $ev->region, undef;
  done $c;
} n => 1, name => 'region undef';

test {
  my $c = shift;
  my $ev = new Web::DOM::MouseEvent 'h', {buttons => 5,
                                          region => 'goge fuga'};
  is $ev->region, 'goge fuga';
  done $c;
} n => 1, name => 'region string';

test {
  my $c = shift;
  my $ev = new Web::DOM::MouseEvent 'h', {buttons => -5 + 2**32};
  is $ev->buttons, 2**16 - 5;
  done $c;
} n => 1, name => 'buttons';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
