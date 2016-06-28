package Web::DOM::EventTarget;
use strict;
use warnings;
our $VERSION = '4.0';
use Web::DOM::TypeError;
use Web::DOM::Exception;
use Web::DOM::Event;
use Web::DOM::_Defs;

push our @CARP_NOT, qw(Web::DOM::TypeError Web::DOM::Exception);

## event listener
##   0 - CODE
##   1 - capture flag
##   2 - removed flag
##   3 - Other options

sub add_event_listener ($$;$$) {
  # WebIDL
  my $type = ''.$_[1];
  _throw Web::DOM::TypeError 'The second argument is not a code reference'
      if defined $_[2] and not ref $_[2] eq 'CODE';

  ## Flatten
  my $capture = 0;
  my $options = {};
  if (defined $_[3] and ref $_[3] eq 'HASH') {
    $capture = $_[3]->{capture} ? 1 : 0;
    $options->{passive} = 1 if $_[3]->{passive};
    $options->{once} = 1 if $_[3]->{once};
  } elsif ($_[3]) {
    $capture = 1;
  }

  # 1.
  return undef unless defined $_[2];

  # 2.
  my $obj = $_[0]->isa ('Web::DOM::Node') ? ${$_[0]}->[2] : $_[0];
  my $list = $obj->{event_listeners}->{$type} ||= [];
  for (@$list) {
    return undef if $_->[0] eq $_[2] and
                    $_->[1] == $capture;
  }
  push @$list, [$_[2], $capture, 0, $options];
  return undef;
} # add_event_listener

sub remove_event_listener ($$;$$) {
  # WebIDL
  my $type = ''.$_[1];
  _throw Web::DOM::TypeError 'The second argument is not a code reference'
      if defined $_[2] and not ref $_[2] eq 'CODE';

  ## Flatten
  my $capture = 0;
  if (defined $_[3] and ref $_[3] eq 'HASH') {
    $capture = $_[3]->{capture} ? 1 : 0;
  } elsif ($_[3]) {
    $capture = 1;
  }

  return undef unless defined $_[2];
  my $obj = $_[0]->isa ('Web::DOM::Node') ? ${$_[0]}->[2] : $_[0];
  my $list = $obj->{event_listeners}->{$type} ||= [];
  $obj->{event_listeners}->{$type} = [grep {
    if ($_->[0] eq $_[2] and $_->[1] == $capture) {
      $_->[2] = 1; # removed
      ();
    } else {
      $_;
    }
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
  ## Dispatch <https://dom.spec.whatwg.org/#concept-event-dispatch>.
  
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
  my $orig_type = $event->type;
  my $legacy_type = $Web::DOM::_Defs->{legacy_event}->{$orig_type};
  
  # 2.
  my $obj = $_[2]->isa ('Web::DOM::Node') ? ${$_[2]}->[2] : $_[2];
  my $orig_listeners = $obj->{event_listeners}->{$orig_type} || [];
  my $legacy_listeners = defined $legacy_type
      ? $obj->{event_listeners}->{$legacy_type} || [] : [];

  # 3.
  $event->{current_target} = $_[2];

  # 4.
  my $inner = sub {
    my $found = 0;
    my @listener = @{$_[0]};
    for my $listener (@listener) {
      return if $event->{stop_immediate_propagation};
      next if $listener->[2]; # removed
      $found = 1;
      next if not $listener->[1] and $event->event_phase == CAPTURING_PHASE;
      next if $listener->[1] and $event->event_phase == BUBBLING_PHASE;

      @{$_[0]} = grep { $_ ne $listener } @{$_[0]} if $listener->[3]->{once};

      # XXX exception handling
      local $event->{in_passive_listener} = $listener->[3]->{passive};
      $listener->[0]->($event->current_target, $event);
    }
    return $found;
  }; # $inner
  my $found = $inner->($orig_listeners);
  if (not $found and @$legacy_listeners) {
    local $event->{type} = $legacy_type;
    $inner->($legacy_listeners);
  }
} # _invoke_event_listeners

sub _fire_simple_event ($$$) {
  ## Fire an event named e
  ## <https://dom.spec.whatwg.org/#concept-event-fire>.
  ## Fire a simple event named e
  ## <https://www.whatwg.org/specs/web-apps/current-work/#fire-a-simple-event>.

  require Web::DOM::Event;
  my $ev = Web::DOM::Event->new ($_[1], $_[2]);
  $ev->{is_trusted} = 1;
  return $_[0]->_dispatch_event ($ev);
} # _fire_simple_event

1;

=head1 LICENSE

Copyright 2013-2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
