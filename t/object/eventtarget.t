use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->parent->parent->child ('t_deps/modules/*/lib');
use lib glob path (__FILE__)->parent->parent->parent->child ('t_deps/lib');
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Event;
use Web::DOM::EventTarget;
use Web::DOM::Document;

sub create_event_target (;%) {
  return bless {}, 'Web::DOM::EventTarget';
} # create_event_target

test {
  my $c = shift;
  my $et = create_event_target;
  my $ev = new Web::DOM::Event 'hoge';

  my $invoked;
  $et->add_event_listener ('hoge', sub {
    my ($self, $event) = @_;
    $invoked++;
    is $event, $ev;
    is $event->type, 'hoge';
    is $event->target, $et;
    is $event->src_element, $event->target;
    is $event->current_target, $et;
    is $event->event_phase, $ev->AT_TARGET;
    ok not $event->default_prevented;
  });

  ok $et->dispatch_event ($ev);
  is $invoked, 1;
  is $ev->type, 'hoge';
  is $ev->event_phase, $ev->NONE;
  is $ev->target, $et;
  is $ev->src_element, $ev->target;
  is $ev->current_target, undef;
  ok not $ev->default_prevented;

  done $c;
} n => 15;

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  ok $et->dispatch_event ($ev);

  ok $ev->{initialized};
  ok not $ev->manakai_dispatched;
  ok not $ev->{canceled};
  done $c;
} n => 4, name => 'dispatched but no event listener';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  my $invoked;
  $et->add_event_listener (hoge => sub {
    $invoked++;
  });

  ok $et->dispatch_event ($ev);
  ok not $invoked;

  ok $ev->{initialized};
  ok not $ev->manakai_dispatched;
  ok not $ev->{canceled};
  done $c;
} n => 5, name => 'dispatched but no event listener';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  my $invoked = 0;

  $et->add_event_listener (hoe => sub {
    my ($self, $event) = @_;
    is $self, $et;
    is $event, $ev;
    $invoked++;
    is $invoked, 1;
  });

  $et->add_event_listener (hoe => sub {
    my ($self, $event) = @_;
    is $self, $et;
    is $event, $ev;
    $invoked++;
    is $invoked, 2;
  });

  ok $et->dispatch_event ($ev);

  is $invoked, 2;

  done $c;
} n => 8, name => 'dispatched, multiple event listeners';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  my $invoked = 0;

  $et->add_event_listener (hoe => sub {
    my ($self, $event) = @_;
    is $self, $et;
    is $event, $ev;
    $invoked++;
    is $invoked, 1;
  }, 0);

  $et->add_event_listener (hoe => sub {
    my ($self, $event) = @_;
    is $self, $et;
    is $event, $ev;
    $invoked++;
    is $invoked, 2;
  }, 1);

  ok $et->dispatch_event ($ev);

  is $invoked, 2;

  done $c;
} n => 8, name => 'dispatched, multiple event listeners, capture and non-capture';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  my $invoked = 0;
  my $code = sub {
    my ($self, $event) = @_;
    $invoked++;
  };

  $et->add_event_listener (hoe => $code, 0);
  $et->add_event_listener (hoe => $code, 1);

  ok $et->dispatch_event ($ev);

  is $invoked, 2;

  done $c;
} n => 2, name => 'dispatched, same event listeners, capture and non-capture';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  my $invoked = 0;
  my $code = sub {
    my ($self, $event) = @_;
    $invoked++;
  };

  $et->add_event_listener (hoe => $code, 1);
  $et->add_event_listener (hoe => $code, 1);

  ok $et->dispatch_event ($ev);

  is $invoked, 1;

  done $c;
} n => 2, name => 'dispatched, same event listeners, capture and capture';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  my $invoked = 0;
  my $code = sub {
    my ($self, $event) = @_;
    $invoked++;
  };

  $et->add_event_listener (hoe => $code, 1);
  $et->add_event_listener (hoe => $code, 1);
  $et->remove_event_listener (hoe => $code, 1);

  ok $et->dispatch_event ($ev);

  is $invoked, 0;

  done $c;
} n => 2, name => 'dispatched, same event listeners but removed';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  my $invoked = 0;
  my $code = sub {
    my ($self, $event) = @_;
    $invoked++;
  };

  $et->add_event_listener (hoe => $code, 1);
  $et->add_event_listener (hoe => $code, 1);
  $et->remove_event_listener (hoe => $code, 0);

  ok $et->dispatch_event ($ev);

  is $invoked, 1;

  done $c;
} n => 2, name => 'dispatched, same event listeners but not removed';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  my $invoked = 0;
  my $code = sub {
    my ($self, $event) = @_;
    $invoked++;
  };

  $et->add_event_listener (hoe => $code, 1);
  $et->add_event_listener (hoe => $code, 0);
  $et->remove_event_listener (hoe => $code, 0);

  ok $et->dispatch_event ($ev);

  is $invoked, 1;

  done $c;
} n => 2, name => 'dispatched, same event listeners but one removed';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  my $invoked1 = 0;
  my $invoked2 = 0;
  $et->add_event_listener (hoe => my $code1 = sub { $invoked1++ });
  $et->add_event_listener (hoe => my $code2 = sub { $invoked2++ });
  $et->remove_event_listener (hoe => $code1);

  ok $et->dispatch_event ($ev);

  is $invoked1, 0;
  is $invoked2, 1;

  done $c;
} n => 3, name => 'dispatched, multiple event listeners but one removed';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  my $invoked1 = 0;
  my $invoked2 = 0;
  $et->add_event_listener (hoe => my $code1 = sub { $invoked1++ });
  $et->add_event_listener (hoe => my $code2 = sub {
    $invoked2++;
    $_[0]->remove_event_listener (hoe => $code1);
  });

  ok $et->dispatch_event ($ev);

  is $invoked1, 1;
  is $invoked2, 1;

  ok $et->dispatch_event ($ev);

  is $invoked1, 1;
  is $invoked2, 2;

  done $c;
} n => 6, name => 'dispatched, multiple event listeners but one removed in listener';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  my $invoked1 = 0;
  my $invoked2 = 0;
  $et->add_event_listener (hoe => sub {
    $invoked1++;
    $_[0]->add_event_listener (hoe => sub { $invoked2++ });
  });

  ok $et->dispatch_event ($ev);

  is $invoked1, 1;
  is $invoked2, 0;

  ok $et->dispatch_event ($ev);

  is $invoked1, 2;
  is $invoked2, 1;

  done $c;
} n => 6, name => 'dispatched, added in event listener';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  $et->add_event_listener (hoe => undef);

  ok $et->dispatch_event ($ev);

  done $c;
} n => 1, name => 'add_event_listener undef';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  $et->add_event_listener (hoe => undef);
  $et->remove_event_listener (hoe => undef);

  ok $et->dispatch_event ($ev);

  done $c;
} n => 1, name => 'remove_event_listener undef';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  dies_here_ok {
    $et->add_event_listener (hoe => 'hoge');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a code reference';

  ok $et->dispatch_event ($ev);

  done $c;
} n => 4, name => 'add_event_listener not code';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  dies_here_ok {
    $et->remove_event_listener (hoe => 'hoge');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a code reference';

  ok $et->dispatch_event ($ev);

  done $c;
} n => 4, name => 'remove_event_listener not code';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoe';
  my $et = create_event_target;

  $et->remove_event_listener (hoe => sub { });

  ok $et->dispatch_event ($ev);

  done $c;
} n => 1, name => 'remove_event_listener not found';

test {
  my $c = shift;
  my $et = create_event_target;
  
  dies_here_ok {
    $et->dispatch_event;
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The argument is not an Event';

  done $c;
} n => 3, name => 'dispatch_event not event';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = $doc->create_event ('Event');
  my $et = create_event_target;
  
  dies_here_ok {
    $et->dispatch_event ($ev);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidStateError';
  is $@->message, 'The specified event is not dispatchable';

  done $c;
} n => 4, name => 'dispatch_event not initialized';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoge';
  my $et = create_event_target;

  $et->add_event_listener (hoge => sub {
    my $event = $_[1];
    dies_here_ok {
      $et->dispatch_event ($event);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'InvalidStateError';
    is $@->message, 'The specified event is not dispatchable';
  });
  $et->dispatch_event ($ev);
  done $c;
} n => 4, name => 'dispatch_event already dispatched';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'hoge';
  my $et = create_event_target;
  $et->dispatch_event ($ev);

  ok $et->dispatch_event ($ev);
  done $c;
} n => 1, name => 'dispatch_event after dispatch';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'ff';
  $ev->{is_trusted} = 1;
  my $et = create_event_target;
  $et->dispatch_event ($ev);
  ok not $ev->is_trusted;
  done $c;
} n => 1, name => 'dispatch_event reset is_trusted';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'ff';
  $ev->{is_trusted} = 1;
  my $et = create_event_target;
  $et->add_event_listener (ff => sub {
    ok not $_[1]->is_trusted;
  });
  $et->dispatch_event ($ev);
  ok not $ev->is_trusted;
  done $c;
} n => 2, name => 'dispatch_event reset is_trusted';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'aa';
  my $et = create_event_target;
  $et->add_event_listener (aa => sub {
    $_[1]->prevent_default;
  });
  ok $et->dispatch_event ($ev);
  done $c;
} n => 1, name => 'dispatch_event return not cancelable';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'aa', {cancelable => 1};
  my $et = create_event_target;
  $et->add_event_listener (aa => sub {
    $_[1]->prevent_default;
  });
  ok not $et->dispatch_event ($ev);
  done $c;
} n => 1, name => 'dispatch_event return cancelable canceled';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'aa', {cancelable => 1};
  my $et = create_event_target;
  $et->add_event_listener (aa => sub {
    $_[1]->prevent_default;
  }, 1);
  my $called;
  $et->add_event_listener (aa => sub {
    $called = 1;
  }, 0);
  ok not $et->dispatch_event ($ev);
  ok $ev->default_prevented;
  ok $called;
  done $c;
} n => 3, name => 'prevent_default does not affect invocation';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'aa', {cancelable => 1};
  my $et = create_event_target;
  $et->add_event_listener (aa => sub {
    $_[1]->stop_propagation;
  }, 1);
  my $called;
  $et->add_event_listener (aa => sub {
    $called = 1;
  }, 0);
  ok $et->dispatch_event ($ev);
  ok $called;
  done $c;
} n => 2, name => 'stop_propagation does not affect invocation';

test {
  my $c = shift;
  my $ev = new Web::DOM::Event 'aa', {cancelable => 1};
  my $et = create_event_target;
  $et->add_event_listener (aa => sub {
    $_[1]->stop_immediate_propagation;
  }, 1);
  my $called = 0;
  $et->add_event_listener (aa => sub {
    $called++;
  }, 1);
  $et->add_event_listener (aa => sub {
    $called++;
  }, 0);
  ok $et->dispatch_event ($ev);
  ok not $called;
  done $c;
} n => 2, name => 'stop_immediate_propagation does affect invocation';

test {
  my $c = shift;
  my $et = create_event_target;
  my $ev = new Web::DOM::Event 'aa';
  $et->add_event_listener (aa => sub {
    my $event = $_[1];
    $event->init_event ('bb', 1, 1);
    is $event->type, 'aa';
    ok not $event->bubbles;
    ok not $event->cancelable;
  });
  ok $et->dispatch_event ($ev);
  is $ev->type, 'aa';
  ok not $ev->bubbles;
  ok not $ev->cancelable;
  done $c;
} n => 7, name => 'init_event in dispatch_event';

test {
  my $c = shift;
  my $et = create_event_target;
  my $ev = new Web::DOM::Event 'aa';
  ok $et->dispatch_event ($ev);
  $ev->init_event ('bb', 1, 1);
  is $ev->type, 'bb';
  ok $ev->bubbles;
  ok $ev->cancelable;
  done $c;
} n => 4, name => 'init_event after dispatch_event';

test {
  my $c = shift;
  my $et = create_event_target;

  ok $et->_fire_simple_event ('hoge', {cancelable => 1});

  done $c;
} n => 1, name => '_fire_simple_event with no event listener';

test {
  my $c = shift;
  my $et = create_event_target;

  my $invoked = 0;
  $et->add_event_listener (hoge => sub {
    $invoked++;
    is ref $_[1], 'Web::DOM::Event';
    is $_[0], $_[1]->target;
    is $_[1]->target, $_[1]->current_target;
    is $_[1]->src_element, $_[1]->target;
    is $_[1]->type, 'hoge';
    ok not $_[1]->bubbles;
    ok $_[1]->cancelable;
    is $_[1]->timestamp, time;
    ok $_[1]->is_trusted;
  });

  ok $et->_fire_simple_event ('hoge', {cancelable => 1});
  is $invoked, 1;

  done $c;
} n => 11, name => '_fire_simple_event with event listener';

test {
  my $c = shift;
  my $et = create_event_target;

  $et->add_event_listener (hoge => sub {
    $_[1]->prevent_default;
  });

  ok not $et->_fire_simple_event ('hoge', {cancelable => 1});

  done $c;
} n => 1, name => '_fire_simple_event default prevented';

test {
  my $c = shift;
  my $et = create_event_target;
  my $ev = new Web::DOM::Event 'aa';
  ok not $ev->manakai_dispatched;

  $et->add_event_listener (aa => sub {
    ok $_[1]->manakai_dispatched;
  });
  $et->dispatch_event ($ev);

  ok not $ev->manakai_dispatched;
  done $c;
} n => 3, name => 'manakai_dispatched';

test {
  my $c = shift;
  my $et = create_event_target;

  my @r;
  my $code;
  $et->add_event_listener (foo => sub {
    push @r, 1;
    $_[0]->remove_event_listener ('foo', $code);
  });
  $et->add_event_listener (foo => $code = sub {
    push @r, 2;
  });

  my $ev = new Web::DOM::Event 'foo';
  $et->dispatch_event ($ev);

  is 0+@r, 1;
  is $r[0], 1;

  done $c;
} n => 2, name => 'remove_event_listener in dispatch_event';

test {
  my $c = shift;
  my $et = create_event_target;
  my $ev = new Web::DOM::Event 'aa', {cancelable => 1};

  $et->add_event_listener (aa => sub {
    $_[1]->prevent_default;
    ok 1;
  }, {passive => 0});
  $et->dispatch_event ($ev);

  ok $ev->default_prevented;
  done $c;
} n => 2, name => 'prevent_default in non-passive listener';

test {
  my $c = shift;
  my $et = create_event_target;
  my $ev = new Web::DOM::Event 'aa', {cancelable => 1};

  $et->add_event_listener (aa => sub {
    $_[1]->return_value (0);
    ok 1;
  }, {passive => 0});
  $et->dispatch_event ($ev);

  ok $ev->default_prevented;
  done $c;
} n => 2, name => 'return_value in non-passive listener';

test {
  my $c = shift;
  my $et = create_event_target;
  my $ev = new Web::DOM::Event 'aa', {cancelable => 1};

  $et->add_event_listener (aa => sub {
    $_[1]->prevent_default;
    ok 1;
  }, {passive => 1});
  $et->dispatch_event ($ev);

  ok !$ev->default_prevented;
  done $c;
} n => 2, name => 'prevent_default in passive listener';

test {
  my $c = shift;
  my $et = create_event_target;
  my $ev = new Web::DOM::Event 'aa', {cancelable => 1};

  $et->add_event_listener (aa => sub {
    $_[1]->return_value (0);
    ok 1;
  }, {passive => 1});
  $et->dispatch_event ($ev);

  ok !$ev->default_prevented;
  done $c;
} n => 2, name => 'return_value in passive listener';

test {
  my $c = shift;
  my $et = create_event_target;

  my $invoked = 0;
  $et->add_event_listener (webkitAnimationEnd => sub {
    $invoked++;
  });

  $et->_fire_simple_event ('animationend', {});

  is $invoked, 1;
  done $c;
} n => 1, name => 'legacy event type';

test {
  my $c = shift;
  my $et = create_event_target;

  my $invoked1 = 0;
  my $invoked2 = 0;
  $et->add_event_listener (webkitAnimationEnd => sub {
    $invoked1++;
  });
  $et->add_event_listener (animationend => sub {
    $invoked2++;
  });

  $et->_fire_simple_event ('animationend', {});

  is $invoked1, 0;
  is $invoked2, 1;
  done $c;
} n => 2, name => 'legacy event type';

test {
  my $c = shift;
  my $et = create_event_target;
  my $ev = new Web::DOM::Event 'animationend';

  my $invoked = 0;
  $et->add_event_listener (webkitAnimationEnd => sub {
    $invoked++;
  });
  $et->dispatch_event ($ev);

  is $invoked, 0;
  done $c;
} n => 1, name => 'legacy event type';

test {
  my $c = shift;
  my $et = create_event_target;
  my $ev = new Web::DOM::Event 'animationend';

  my $invoked1 = 0;
  my $invoked2 = 0;
  $et->add_event_listener (webkitAnimationEnd => sub {
    $invoked1++;
  });
  $et->add_event_listener (animationend => sub {
    $invoked2++;
  });
  $et->dispatch_event ($ev);

  is $invoked1, 0;
  is $invoked2, 1;
  done $c;
} n => 2, name => 'legacy event type';

test {
  my $c = shift;
  my $et = create_event_target;
  my $ev = new Web::DOM::Event 'aa', {cancelable => 1};

  my $invoked = 0;
  $et->add_event_listener (aa => sub {
    $invoked++;
  }, {once => 0});
  $et->dispatch_event ($ev);
  $et->dispatch_event ($ev);

  is $invoked, 2;
  done $c;
} n => 1, name => 'once => 0';

test {
  my $c = shift;
  my $et = create_event_target;
  my $ev = new Web::DOM::Event 'aa', {cancelable => 1};

  my $invoked = 0;
  $et->add_event_listener (aa => sub {
    $invoked++;
  }, {once => 1});
  $et->dispatch_event ($ev);
  $et->dispatch_event ($ev);

  is $invoked, 1;
  done $c;
} n => 1, name => 'once => 1';

test {
  my $c = shift;
  my $et = create_event_target;

  ## c.f. <https://github.com/whatwg/dom/issues/265>

  my $invoked = 0;
  $et->add_event_listener (aa => sub {
    $invoked++;
    if ($invoked == 1) {
      $_[0]->dispatch_event (new Web::DOM::Event 'aa', {});
    }
  }, {once => 1});
  $et->dispatch_event (new Web::DOM::Event 'aa', {});

  is $invoked, 1;
  done $c;
} n => 1, name => 'once reentrance';

test {
  my $c = shift;
  my $et = create_event_target;

  $et->add_event_listener (aa => sub {
    my $ev = $_[1];
    $ev->stop_propagation;
    test {
      ok $ev->manakai_propagation_stopped;
    } $c;
  });

  my $ev = new Web::DOM::Event 'aa', {};
  $et->dispatch_event ($ev);

  ok ! $ev->manakai_propagation_stopped;
  done $c;
} n => 2, name => 'stop propagation flag after dispatch';

test {
  my $c = shift;
  my $et = create_event_target;

  $et->add_event_listener (aa => sub {
    my $ev = $_[1];
    $ev->stop_immediate_propagation;
    test {
      ok $ev->manakai_immediate_propagation_stopped;
    } $c;
  });

  my $ev = new Web::DOM::Event 'aa', {};
  $et->dispatch_event ($ev);

  ok ! $ev->manakai_immediate_propagation_stopped;
  done $c;
} n => 2, name => 'stop immediate propagation flag after dispatch';

run_tests;

=head1 LICENSE

Copyright 2013-2018 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
