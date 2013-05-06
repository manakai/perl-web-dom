package Web::DOM::EventTarget;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::TypeError;
use Web::DOM::Exception;
use Web::DOM::Event;

push our @CARP_NOT, qw(Web::DOM::TypeError Web::DOM::Exception);

sub add_event_listener ($$;$$) {
  # WebIDL
  my $type = ''.$_[1];
  _throw Web::DOM::TypeError 'The second argument is not a code reference'
      if defined $_[2] and not ref $_[2] eq 'CODE';
  my $capture = $_[3] ? 1 : 0;

  # 1.
  return undef unless defined $_[2];

  # 2.
  my $obj = $_[0]->isa ('Web::DOM::Node') ? ${$_[0]}->[2] : $_[0];
  my $list = $obj->{event_listeners}->{$type} ||= [];
  for (@$list) {
    return undef if $_->[0] eq $_[2] and $_->[1] == $capture;
  }
  push @$list, [$_[2], $capture];
  return undef;
} # add_event_listener

sub remove_event_listener ($$;$$) {
  # WebIDL
  my $type = ''.$_[1];
  _throw Web::DOM::TypeError 'The second argument is not a code reference'
      if defined $_[2] and not ref $_[2] eq 'CODE';
  my $capture = $_[3] ? 1 : 0;

  return undef unless defined $_[2];
  my $obj = $_[0]->isa ('Web::DOM::Node') ? ${$_[0]}->[2] : $_[0];
  my $list = $obj->{event_listeners}->{$type} ||= [];
  $obj->{event_listeners}->{$type} = [grep {
    not ($_->[0] eq $_[2] and $_->[1] == $capture);
  } @$list];
  return undef;
} # remove_event_listener

sub dispatch_event ($$) {
  # WebIDL
  _throw Web::DOM::TypeError 'The argument is not an Event'
      unless UNIVERSAL::isa ($_[1], 'Web::DOM::Event');

  # 1.
  if ($_[1]->{dispatch} or not $_[1]->{initialized}) {
    _throw Web::DOM::Exception 'InvalidStateError',
        'The specified event is not dispatchable';
  }

  # 2.
  delete $_[1]->{is_trusted};
  
  # 3.
  return $_[0]->_dispatch_event ($_[1]);
} # dispatch_event

sub _dispatch_event ($$) {
  ## Dispatch <http://dom.spec.whatwg.org/#concept-event-dispatch>.
  
  # 1.-3.
  my $event = $_[1];
  $event->{dispatch} = 1;
  $event->{target} = $_[0];

  # 4.
  my $event_path = [];
  if ($_[0]->isa ('Web::DOM::Node')) {
    ## Ancestors: root .. parent
    my $p = $_[0];
    while ($p = $p->parent_node) {
      unshift @$event_path, $p;
    }
    # XXX
    #if (@$event_path and
    #    $event_path->[0]->node_type == DOCUMENT_NODE and
    #    $event_path->[0]->default_view and
    #    $event->type ne 'load') {
    #  unshift @$event_path, $event_path->[0]->default_view;
    #}
  } # Node

  # 5.-6.
  $event->{event_phase} = CAPTURING_PHASE;
  for my $obj (@$event_path) {
    last if $event->{stop_propagation};
    $_[0]->_invoke_event_listeners ($event => $obj);
  }

  # 6.-8.
  unless ($event->{stop_propagation}) {
    $event->{event_phase} = AT_TARGET;
    $_[0]->_invoke_event_listeners ($event => $_[0]);
  }

  # 9.
  if ($event->bubbles) {
    $event->{event_phase} = BUBBLING_PHASE;
    for my $obj (reverse @$event_path) {
      last if $event->{stop_propagation};
      $_[0]->_invoke_event_listeners ($event => $obj);
    }
  }

  # 10.-13.
  delete $event->{dispatch};
  delete $event->{event_phase};
  delete $event->{current_target};
  return not $event->{canceled};
} # _dispatch_event

sub _invoke_event_listeners ($$$) {
  # 1.
  my $event = $_[1];
  
  # 2.
  my $obj = $_[2]->isa ('Web::DOM::Node') ? ${$_[2]}->[2] : $_[2];
  my $listeners = $obj->{event_listeners}->{$event->type};
  return unless $listeners;
  $listeners = [@$listeners];

  # 3.
  $event->{current_target} = $_[2];

  # 4.
  for my $listener (@$listeners) {
    return if $event->{stop_immediate_propagation};
    next if not $listener->[1] and $event->event_phase == CAPTURING_PHASE;
    next if $listener->[1] and $event->event_phase == BUBBLING_PHASE;

    # XXX exception handling
    $listener->[0]->($event->current_target, $event);
  }
} # _invoke_event_listeners

sub _fire_simple_event ($$$) {
  ## Fire an event named e
  ## <http://dom.spec.whatwg.org/#concept-event-fire>.
  ## Fire a simple event named e
  ## <http://www.whatwg.org/specs/web-apps/current-work/#fire-a-simple-event>.

  require Web::DOM::Event;
  my $ev = Web::DOM::Event->new ($_[1], $_[2]);
  $ev->{is_trusted} = 1;
  return $_[0]->_dispatch_event ($ev);
} # _fire_simple_event

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
