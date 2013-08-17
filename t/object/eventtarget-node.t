use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Event;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge';
  
  my $node = $doc->create_element ('fuga');
  ok $node->dispatch_event ($ev);

  done $c;
} n => 1, name => 'dispatch_event no event listener';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge';

  my $node = $doc->create_element ('fuga');

  my $invoked = 0;
  my $node2 = $node;
  $node->add_event_listener (hoge => sub {
    $invoked++;
    is $_[0], $node2;
    is $_[1], $ev;
    is $_[1]->event_phase, $_[1]->AT_TARGET;
  });

  ok $node->dispatch_event ($ev);
  is $invoked, 1;

  undef $node2;
  undef $ev;
  done $c;
} n => 5, name => 'dispatch_event with event listener';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge', {bubbles => 1};

  my $node = $doc->create_element ('fuga');
  my $node2 = $doc->create_element ('aa');
  $node2->append_child ($node);

  my $invoked = 0;
  $node2->add_event_listener (hoge => sub {
    $invoked++;
    is $_[0], $node2;
    is $_[1]->current_target, $node2;
    is $_[1]->target, $node;
    is $_[1]->event_phase, $_[1]->BUBBLING_PHASE;
  });

  ok $node->dispatch_event ($ev);
  is $invoked, 1;

  undef $node;
  undef $node2;
  done $c;
} n => 6, name => 'dispatch_event has parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge', {bubbles => 1};

  my $node = $doc->create_element ('fuga');
  my $node2 = $doc->create_element ('aa');
  $node2->append_child ($node);
  my $node3 = $doc->create_element ('aa');
  $node3->append_child ($node2);

  my $invoked = 0;
  $node3->add_event_listener (hoge => sub {
    $invoked++;
    is $_[0], $node3;
    is $_[1]->current_target, $node3;
    is $_[1]->target, $node;
    is $_[1]->event_phase, $_[1]->BUBBLING_PHASE;
  });

  ok $node->dispatch_event ($ev);
  is $invoked, 1;

  undef $node;
  undef $node2;
  undef $node3;
  done $c;
} n => 6, name => 'dispatch_event has ancestor';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge', {bubbles => 0};

  my $node = $doc->create_element ('fuga');
  my $node2 = $doc->create_element ('aa');
  $node2->append_child ($node);
  my $node3 = $doc->create_element ('aa');
  $node3->append_child ($node2);

  my $invoked = 0;
  $node3->add_event_listener (hoge => sub {
    $invoked++;
  });

  ok $node->dispatch_event ($ev);
  is $invoked, 0;

  done $c;
} n => 2, name => 'dispatch_event has ancestor but not bubbles';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge', {bubbles => 0};

  my $node = $doc->create_element ('fuga');
  my $node2 = $doc->create_element ('aa');
  $node2->append_child ($node);
  my $node3 = $doc->create_element ('aa');
  $node3->append_child ($node2);

  my $invoked = 0;
  $node3->add_event_listener (hoge => sub {
    $invoked++;
    is $_[0], $node3;
    is $_[1]->current_target, $node3;
    is $_[1]->target, $node;
    is $_[1]->event_phase, $_[1]->CAPTURING_PHASE;
  }, 1);

  ok $node->dispatch_event ($ev);
  is $invoked, 1;

  undef $node;
  undef $node2;
  undef $node3;
  done $c;
} n => 6, name => 'dispatch_event has ancestor, capturing';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge', {bubbles => 1};

  my $node = $doc->create_element ('fuga');
  my $node2 = $doc->create_element ('aa');
  $node2->append_child ($node);
  my $node3 = $doc->create_element ('aa');
  $node3->append_child ($node2);

  my $invoked = 0;
  $node3->add_event_listener (hoge => sub {
    $invoked++;
    is $_[1]->event_phase, $_[1]->BUBBLING_PHASE;
    is $invoked, 2;
  }, 0);
  $node3->add_event_listener (hoge => sub {
    $invoked++;
    is $_[1]->event_phase, $_[1]->CAPTURING_PHASE;
    is $invoked, 1;
  }, 1);

  ok $node->dispatch_event ($ev);
  is $invoked, 2;

  undef $node;
  undef $node2;
  undef $node3;
  done $c;
} n => 6, name => 'dispatch_event has ancestor, bubbles and capture';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge', {bubbles => 1};

  my $node = $doc->create_element ('fuga');
  my $node2 = $doc->create_element ('aa');
  $node2->append_child ($node);
  my $node3 = $doc->create_element ('aa');
  $node3->append_child ($node2);

  my $invoked = 0;
  $node3->add_event_listener (hoge => sub {
    $invoked++;
    is $_[1]->event_phase, $_[1]->BUBBLING_PHASE;
    is $invoked, 3;
  }, 0);
  $node2->add_event_listener (hoge => sub {
    $invoked++;
    is $_[1]->event_phase, $_[1]->BUBBLING_PHASE;
    is $invoked, 2;
  }, 0);
  $node->add_event_listener (hoge => sub {
    $invoked++;
    is $_[1]->event_phase, $_[1]->AT_TARGET;
    is $invoked, 1;
  }, 0);

  ok $node->dispatch_event ($ev);
  is $invoked, 3;

  undef $node;
  undef $node2;
  undef $node3;
  done $c;
} n => 8, name => 'dispatch_event has ancestor, bubbles multi';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge', {bubbles => 1};

  my $node = $doc->create_element ('fuga');
  my $node2 = $doc->create_element ('aa');
  $node2->append_child ($node);
  my $node3 = $doc->create_element ('aa');
  $node3->append_child ($node2);

  my $invoked = 0;
  $node3->add_event_listener (hoge => sub {
    $invoked++;
    is $_[1]->event_phase, $_[1]->CAPTURING_PHASE;
    is $invoked, 1;
  }, 1);
  $node2->add_event_listener (hoge => sub {
    $invoked++;
    is $_[1]->event_phase, $_[1]->CAPTURING_PHASE;
    is $invoked, 2;
  }, 1);
  $node->add_event_listener (hoge => sub {
    $invoked++;
    is $_[1]->event_phase, $_[1]->AT_TARGET;
    is $invoked, 3;
  }, 0);

  ok $node->dispatch_event ($ev);
  is $invoked, 3;

  undef $node;
  undef $node2;
  undef $node3;
  done $c;
} n => 8, name => 'dispatch_event has ancestor, captures multi';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge', {bubbles => 1};

  my $node = $doc->create_element ('fuga');
  my $node2 = $doc->create_element ('aa');
  $node2->append_child ($node);
  my $node3 = $doc->create_element ('aa');
  $node3->append_child ($node2);

  my $invoked = 0;
  $node3->add_event_listener (hoge => sub {
    $invoked++;
  });

  $ev->stop_propagation;
  $node->dispatch_event ($ev);

  is $invoked, 0;
  done $c;
} n => 1, name => 'stop_propagation then dipatch';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge', {bubbles => 1};

  my $node = $doc->create_element ('fuga');
  my $node2 = $doc->create_element ('aa');
  $node2->append_child ($node);
  my $node3 = $doc->create_element ('aa');
  $node3->append_child ($node2);

  my $invoked = 0;
  $node3->add_event_listener (hoge => sub {
    $invoked++;
    $_[1]->stop_propagation;
  }, 1);
  $node3->add_event_listener (hoge => sub {
    $invoked++;
  }, 1);
  $node2->add_event_listener (hoge => sub {
    $invoked++;
  }, 1);
  $node->add_event_listener (hoge => sub {
    $invoked++;
  }, 1);
  $node2->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);

  $node->dispatch_event ($ev);

  is $invoked, 2;
  done $c;
} n => 1, name => 'stop_propagation in capture';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge', {bubbles => 1};

  my $node = $doc->create_element ('fuga');
  my $node2 = $doc->create_element ('aa');
  $node2->append_child ($node);
  my $node3 = $doc->create_element ('aa');
  $node3->append_child ($node2);

  my $invoked = 0;
  $node3->add_event_listener (hoge => sub {
    $invoked++;
    $_[1]->stop_immediate_propagation;
  }, 1);
  $node3->add_event_listener (hoge => sub {
    $invoked++;
  }, 1);
  $node2->add_event_listener (hoge => sub {
    $invoked++;
  }, 1);
  $node->add_event_listener (hoge => sub {
    $invoked++;
  }, 1);
  $node2->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);

  $node->dispatch_event ($ev);

  is $invoked, 1;
  done $c;
} n => 1, name => 'stop_immediate_propagation in capture';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge', {bubbles => 1};

  my $node = $doc->create_element ('fuga');
  my $node2 = $doc->create_element ('aa');
  $node2->append_child ($node);
  my $node3 = $doc->create_element ('aa');
  $node3->append_child ($node2);

  my $invoked = 0;
  $node->add_event_listener (hoge => sub {
    $invoked++;
    $_[1]->stop_propagation;
  }, 1);
  $node2->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);
  $node2->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);
  $node3->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);
  $node3->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);

  $node->dispatch_event ($ev);

  is $invoked, 1;
  done $c;
} n => 1, name => 'stop_propagation at target';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge', {bubbles => 1};

  my $node = $doc->create_element ('fuga');
  my $node2 = $doc->create_element ('aa');
  $node2->append_child ($node);
  my $node3 = $doc->create_element ('aa');
  $node3->append_child ($node2);

  my $invoked = 0;
  $node->add_event_listener (hoge => sub {
    $invoked++;
    $_[1]->stop_immediate_propagation;
  }, 1);
  $node2->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);
  $node2->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);
  $node3->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);
  $node3->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);

  $node->dispatch_event ($ev);

  is $invoked, 1;
  done $c;
} n => 1, name => 'stop_immediate_propagation at target';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge', {bubbles => 1};

  my $node = $doc->create_element ('fuga');
  my $node2 = $doc->create_element ('aa');
  $node2->append_child ($node);
  my $node3 = $doc->create_element ('aa');
  $node3->append_child ($node2);

  my $invoked = 0;
  $node2->add_event_listener (hoge => sub {
    $invoked++;
    $_[1]->stop_propagation;
  }, 0);
  $node2->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);
  $node3->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);
  $node3->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);

  $node->dispatch_event ($ev);

  is $invoked, 2;
  done $c;
} n => 1, name => 'stop_propagation in capture';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge', {bubbles => 1};

  my $node = $doc->create_element ('fuga');
  my $node2 = $doc->create_element ('aa');
  $node2->append_child ($node);
  my $node3 = $doc->create_element ('aa');
  $node3->append_child ($node2);

  my $invoked = 0;
  $node2->add_event_listener (hoge => sub {
    $invoked++;
    $_[1]->stop_immediate_propagation;
  }, 0);
  $node2->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);
  $node3->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);
  $node3->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);

  $node->dispatch_event ($ev);

  is $invoked, 1;
  done $c;
} n => 1, name => 'stop_immediate_propagation in capture';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ev = new Web::DOM::Event 'hoge', {bubbles => 1, cancelable => 1};

  my $node = $doc->create_element ('fuga');
  my $node2 = $doc->create_element ('aa');
  $node2->append_child ($node);
  my $node3 = $doc->create_element ('aa');
  $node3->append_child ($node2);

  my $invoked = 0;
  $node2->add_event_listener (hoge => sub {
    $invoked++;
    $_[1]->prevent_default;
  }, 0);
  $node2->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);
  $node3->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);
  $node3->add_event_listener (hoge => sub {
    $invoked++;
  }, 0);

  ok not $node->dispatch_event ($ev);

  is $invoked, 4;
  done $c;
} n => 2, name => 'prevent_default in capture';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('fuga');
  $doc->append_child ($el);

  my $invoked = 0;
  $doc->add_event_listener (abc => sub {
    $invoked++;
  });

  ok $el->_fire_simple_event ('abc');
  is $invoked, 0;

  done $c;
  undef $doc;
  undef $el;
} n => 2, name => '_fire_simple_event not bubbles';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('fuga');
  $doc->append_child ($el);

  my $invoked = 0;
  $doc->add_event_listener (abc => sub {
    $invoked++;
    ok $_[1]->is_trusted;
    ok $_[1]->bubbles;
    is $_[1]->current_target, $doc;
    is $_[1]->target, $el;
    is $_[1]->event_phase, $_[1]->BUBBLING_PHASE;
  });

  ok $el->_fire_simple_event ('abc', {bubbles => 1});
  is $invoked, 1;

  done $c;
  undef $doc;
  undef $el;
} n => 7, name => '_fire_simple_event bubbles';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('fuga');
  $doc->append_child ($el);

  my $invoked = 0;
  $doc->add_event_listener (abc => sub {
    $invoked++;
    ok $_[1]->is_trusted;
    ok $_[1]->bubbles;
    is $_[1]->current_target, $doc;
    is $_[1]->target, $el;
    is $_[1]->event_phase, $_[1]->BUBBLING_PHASE;
  });
  $el->add_event_listener (abc => sub { $invoked++ });

  ok $el->_fire_simple_event ('abc', {bubbles => 1});
  is $invoked, 2;

  done $c;
  undef $doc;
  undef $el;
} n => 7, name => '_fire_simple_event bubbles, target';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('fuga');
  $doc->append_child ($el);
  my $ev = new Web::DOM::Event 'aa', {bubbles => 1};
  ok not $ev->manakai_dispatched;

  $doc->add_event_listener (aa => sub {
    ok $_[1]->manakai_dispatched;
  });
  $el->add_event_listener (aa => sub {
    ok $_[1]->manakai_dispatched;
  });
  $el->dispatch_event ($ev);

  ok not $ev->manakai_dispatched;
  done $c;
} n => 4, name => 'manakai_dispatched';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut