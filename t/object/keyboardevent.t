use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::KeyboardEvent;

test {
  my $c = shift;
  is DOM_KEY_LOCATION_STANDARD, 0;
  ok DOM_KEY_LOCATION_LEFT;
  ok DOM_KEY_LOCATION_RIGHT;
  ok DOM_KEY_LOCATION_NUMPAD;
  ok DOM_KEY_LOCATION_MOBILE;
  ok DOM_KEY_LOCATION_JOYSTICK;
  done $c;
} n => 6, name => 'constants exported';

test {
  my $c = shift;
  is +Web::DOM::KeyboardEvent->DOM_KEY_LOCATION_STANDARD, 0;
  ok +Web::DOM::KeyboardEvent->DOM_KEY_LOCATION_LEFT;
  ok +Web::DOM::KeyboardEvent->DOM_KEY_LOCATION_RIGHT;
  ok +Web::DOM::KeyboardEvent->DOM_KEY_LOCATION_NUMPAD;
  ok +Web::DOM::KeyboardEvent->DOM_KEY_LOCATION_MOBILE;
  ok +Web::DOM::KeyboardEvent->DOM_KEY_LOCATION_JOYSTICK;
  done $c;
} n => 6, name => 'constants class';

test {
  my $c = shift;
  my $ev = new Web::DOM::KeyboardEvent 'a';
  is $ev->DOM_KEY_LOCATION_STANDARD, 0;
  ok $ev->DOM_KEY_LOCATION_LEFT;
  ok $ev->DOM_KEY_LOCATION_RIGHT;
  ok $ev->DOM_KEY_LOCATION_NUMPAD;
  ok $ev->DOM_KEY_LOCATION_MOBILE;
  ok $ev->DOM_KEY_LOCATION_JOYSTICK;
  done $c;
} n => 6, name => 'constants instance';

test {
  my $c = shift;
  my $ev = new Web::DOM::KeyboardEvent 'h';
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
  my $ev = new Web::DOM::KeyboardEvent 'h', {};
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
    new Web::DOM::KeyboardEvent 'h', '{}';
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a hash reference';
  done $c;
} n => 3, name => 'constructor not dict';

test {
  my $c = shift;
  my $ev = new Web::DOM::KeyboardEvent 'h', {bubbles => 1, detail => 128.45 + -2**32};
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
  my $ev = new Web::DOM::KeyboardEvent 'h', {bubbles => 1, view => $win};
  is $ev->type, 'h';
  isa_ok $ev->view, 'Web::DOM::WindowProxy';
  is $ev->view, $win;
  is $ev->detail, 0;
  done $c;
} n => 4, name => 'constructor window';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::Window';
  dies_here_ok {
    new Web::DOM::KeyboardEvent 'h', {bubbles => 1, view => $win};
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The |view| value is not an object of interface |WindowProxy|';
  done $c;
} n => 3, name => 'constructor bad window';

test {
  my $c = shift;
  my $win = bless {}, 'Web::DOM::WindowProxy';
  my $rt = bless {}, 'Web::DOM::EventTarget';
  my $ev = new Web::DOM::KeyboardEvent 'h',
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
  is $ev->ctrl_key, 1;
  is $ev->shift_key, 1;
  is $ev->alt_key, 1;
  is $ev->meta_key, 1;
  is $ev->char, '';
  is $ev->key, '';
  is $ev->location, 0;
  ok not $ev->repeat;
  is $ev->locale, '';
  is $ev->char_code, 0;
  is $ev->key_code, 0;
  is $ev->which, 0;
  is $ev->code, '';
  done $c;
} n => 17, name => 'constructor window keyboard';

test {
  my $c = shift;
  my $ev = new Web::DOM::KeyboardEvent 'h', {};
  is $ev->type, 'h';
  is $ev->view, undef;
  is $ev->detail, 0;
  ok not $ev->ctrl_key;
  ok not $ev->shift_key;
  ok not $ev->alt_key;
  ok not $ev->meta_key;
  is $ev->char, '';
  is $ev->key, '';
  is $ev->location, 0;
  ok not $ev->repeat;
  is $ev->locale, '';
  is $ev->char_code, 0;
  is $ev->key_code, 0;
  is $ev->which, 0;
  is $ev->code, '';
  done $c;
} n => 16, name => 'constructor window keyboard';

test {
  my $c = shift;
  my $ev = new Web::DOM::KeyboardEvent 'h', {repeat => "abc",
                                             locale => 'ab ',
                                             ctrl_key => 1,
                                             meta_key => 4,
                                             code => '12.0',
                                             char_code => 12.5 + 2**32,
                                             key_code => -55 + 2**32,
                                             which => -50.1 + 2**32,
                                             detail => 51.6};
  is $ev->type, 'h';
  is $ev->view, undef;
  is $ev->detail, 51;
  is $ev->ctrl_key, 1;
  ok not $ev->shift_key;
  ok not $ev->alt_key;
  is $ev->meta_key, 1;
  is $ev->char, '';
  is $ev->key, '';
  is $ev->location, 0;
  is $ev->repeat, 1;
  is $ev->locale, 'ab ';
  is $ev->char_code, 12;
  is $ev->key_code, 2**32 - 55;
  is $ev->which, 2**32 - 51;
  is $ev->code, '12.0';
  done $c;
} n => 16, name => 'constructor window keyboard';

test {
  my $c = shift;
  my $ev = new Web::DOM::KeyboardEvent 'h',
      {view => undef, related_target => undef,
       meta_key => 5, shift_key => 1};
  is $ev->type, 'h';
  is $ev->view, undef;
  is $ev->detail, 0;
  ok not $ev->ctrl_key;
  ok $ev->shift_key;
  ok not $ev->alt_key;
  ok $ev->meta_key;
  is $ev->char, '';
  is $ev->key, '';
  is $ev->location, 0;
  ok not $ev->repeat;
  is $ev->locale, '';
  is $ev->char_code, 0;
  is $ev->key_code, 0;
  is $ev->which, 0;
  is $ev->code, '';
  done $c;
} n => 16, name => 'constructor window keyboard';

test {
  my $c = shift;
  my $ev = new Web::DOM::KeyboardEvent 'h', {buttons => 5};
  my $v = bless {}, 'Web::DOM::WindowProxy';
  $ev->init_keyboard_event ('hoge', 1, 0, $v,
                            'abc', 'aa',
                            -42 + 2**32 + 2**32,
                            'Shift Alt',
                            -10.0 + 2**32,
                            'abcd');
  is $ev->type, 'hoge';
  ok $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->view, $v;
  ok not $ev->ctrl_key;
  ok $ev->alt_key;
  ok $ev->shift_key;
  ok not $ev->meta_key;
  is $ev->char, 'abc';
  is $ev->key, 'aa';
  is $ev->location, 2**32 - 42;
  ok $ev->repeat;
  is $ev->locale, 'abcd';
  is $ev->char_code, 0;
  is $ev->key_code, 0;
  is $ev->which, 0;
  is $ev->code, '';
  done $c;
} n => 17, name => 'init_keyboard_event';

test {
  my $c = shift;
  my $ev = new Web::DOM::KeyboardEvent 'h', {buttons => 5};
  $ev->init_keyboard_event ('hoge', 1, 0, undef,
                            'abc', 'aa',
                            -42 + 2**32 + 2**32,
                            'Shift Alt',
                            -10.0 + 2**32,
                            'abcd');
  is $ev->type, 'hoge';
  ok $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->view, undef;
  ok not $ev->ctrl_key;
  ok $ev->alt_key;
  ok $ev->shift_key;
  ok not $ev->meta_key;
  is $ev->char, 'abc';
  is $ev->key, 'aa';
  is $ev->location, 2**32 - 42;
  ok $ev->repeat;
  is $ev->locale, 'abcd';
  is $ev->char_code, 0;
  is $ev->key_code, 0;
  is $ev->which, 0;
  is $ev->code, '';
  done $c;
} n => 17, name => 'init_keyboard_event undef';

test {
  my $c = shift;
  my $ev = new Web::DOM::KeyboardEvent 'h', {buttons => 5};
  dies_here_ok {
    $ev->init_keyboard_event ('hoge', 1, 0, 'ab',
                              'abc', 'aa',
                              -42 + 2**32 + 2**32,
                              'Shift Alt',
                              -10.0 + 2**32,
                              'abcd');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The fourth argument is not a WindowProxy';
  is $ev->type, 'h';
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  is $ev->view, undef;
  ok not $ev->ctrl_key;
  ok not $ev->alt_key;
  ok not $ev->shift_key;
  ok not $ev->meta_key;
  is $ev->char, '';
  is $ev->key, '';
  is $ev->location, 0;
  ok not $ev->repeat;
  is $ev->locale, '';
  is $ev->char_code, 0;
  is $ev->key_code, 0;
  is $ev->which, 0;
  is $ev->code, '';
  done $c;
} n => 20, name => 'init_keyboard_event error';

test {
  my $c = shift;
  my $ev = new Web::DOM::KeyboardEvent 'h', {buttons => 5};
  $ev->init_keyboard_event ('hoge', 1, 0, undef,
                            'abc', 'aa',
                            -42 + 2**32 + 2**32,
                            'Control AltGraph Meta',
                            -10.0 + 2**32,
                            'abcd');
  ok $ev->ctrl_key;
  ok $ev->alt_graph_key;
  ok $ev->meta_key;
  ok not $ev->shift_key;
  ok not $ev->alt_key;
  ok $ev->get_modifier_state ('Control');
  ok $ev->get_modifier_state ('AltGraph');
  ok $ev->get_modifier_state ('Meta');
  ok not $ev->get_modifier_state ('Shift');
  ok not $ev->get_modifier_state ('Alt');
  ok not $ev->get_modifier_state ('Fn');
  ok not $ev->get_modifier_state ('Unknown__');
  done $c;
} n => 12, name => 'init_keyboad_event modifiers_list';
  
run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
