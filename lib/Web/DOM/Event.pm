package Web::DOM::Event;
use strict;
use warnings;
our $VERSION = '3.0';
use Web::DOM::Internal;
use Web::DOM::TypeError;

our @EXPORT;
*import = \&Web::DOM::Internal::import;

push our @CARP_NOT, qw(Web::DOM::TypeError);

sub _new ($) {
  return bless {
    type => '',
    timestamp => time, # XXX provide an option to enable Time::HiRes::time ?
  }, $_[0];
} # _new

sub _init_members ($) { [bubbles => 'boolean'], [cancelable => 'boolean'] }

sub new ($$;$) {
  _throw Web::DOM::TypeError 'The second argument is not a hash reference'
      if defined $_[2] and not ref $_[2] eq 'HASH';
  my $self = $_[0]->_new;
  $self->{initialized} = 1;
  $self->{type} = ''.$_[1];
  for ($self->_init_members) {
    my ($key, $type, $if) = @$_;
    if (defined $_[2]->{$key}) {
      if ($type eq 'boolean') {
        $self->{$key} = !!$_[2]->{$key};
      } elsif ($type eq 'any') {
        $self->{$key} = $_[2]->{$key};
      } elsif ($type eq 'long') {
        $self->{$key} = _idl_long $_[2]->{$key};
      } elsif ($type eq 'unsigned long') {
        $self->{$key} = _idl_unsigned_long $_[2]->{$key};
      } elsif ($type eq 'unsigned short') {
        $self->{$key} = _idl_unsigned_short $_[2]->{$key};
      } elsif ($type eq 'double') { # WebIDL double
        my $value = 0+$_[2]->{$key};
        if ($value =~ /\A-?(?:[Nn]a[Nn]|[Ii]nf)\z/) {
          _throw Web::DOM::TypeError "The |$key| value is out of range";
        }
        $self->{$key} = $value;
      } elsif ($type eq 'string') {
        $self->{$key} = ''.$_[2]->{$key};
      } elsif ($type eq 'string?') {
        $self->{$key} = defined $_[2]->{$key} ? ''.$_[2]->{$key} : undef;
      } elsif ($type eq 'object?') {
        if (defined $_[2]->{$key}) {
          _throw Web::DOM::TypeError
              "The |$key| value is not an object of interface |$if|"
              unless UNIVERSAL::isa ($_[2]->{$key}, "Web::DOM::$if");
          $self->{$key} = $_[2]->{$key};
        } else {
          delete $self->{$key};
        }
      } else {
        die "Value type |$type| is not defined";
      }
    }
  }
  return $self;
} # new

sub type ($) { $_[0]->{type} }
sub target ($) { $_[0]->{target} } # or undef
*src_element = \&target;
sub current_target ($) { $_[0]->{current_target} } # or undef

push @EXPORT, qw(NONE CAPTURING_PHASE AT_TARGET BUBBLING_PHASE);
sub NONE () { 0 }
sub CAPTURING_PHASE () { 1 }
sub AT_TARGET () { 2 }
sub BUBBLING_PHASE () { 3 }
sub event_phase ($) { $_[0]->{event_phase} || 0 }
sub manakai_dispatched ($) { $_[0]->{dispatch} }

sub stop_propagation ($) { $_[0]->{stop_propagation} = 1; undef }
sub manakai_propagation_stopped ($) { $_[0]->{stop_propagation} }

sub cancel_bubble ($;$) {
  if (@_ > 1) {
    $_[0]->{stop_propagation} = 1 if $_[1];
  }
  return $_[0]->{stop_propagation};
} # cancel_bubble

sub stop_immediate_propagation ($) {
  $_[0]->{stop_propagation} = 1;
  $_[0]->{stop_immediate_propagation} = 1;
  return undef;
} # stop_immediate_propagation

sub manakai_immediate_propagation_stopped ($) {
  return $_[0]->{stop_immediate_propagation};
} # manakai_immediate_propagation_stopped

sub bubbles ($) { $_[0]->{bubbles} }
sub cancelable ($) { $_[0]->{cancelable} }

sub prevent_default ($) {
  ## Set the canceled flag
  $_[0]->{canceled} = 1 if $_[0]->{cancelable} and
                           not $_[0]->{in_passive_listener};
  return undef;
} # prevent_default
sub default_prevented ($) { $_[0]->{canceled} }
sub return_value ($;$) {
  if (@_ > 1) {
    if (not $_[1]) {
      ## Set the canceled flag
      $_[0]->{canceled} = 1 if $_[0]->{cancelable} and
                               not $_[0]->{in_passive_listener};
    }
  }
  return not $_[0]->{canceled};
} # return_value

sub is_trusted ($) { $_[0]->{is_trusted} }
sub timestamp ($) { $_[0]->{timestamp} }

sub _initialize ($;$$$) {
  my $self = $_[0];
  return 0 if $self->{dispatch};

  ## Initialize
  ## <https://dom.spec.whatwg.org/#concept-event-initialize>.

  $self->{initialized} = 1;
  delete $self->{stop_propagation};
  delete $self->{stop_immediate_propagation};
  delete $self->{canceled};
  delete $self->{is_trusted};
  delete $self->{target};
  
  $self->{type} = $_[1];
  $self->{bubbles} = $_[2];
  $self->{cancelable} = $_[3];
  return 1;
} # _initialize

sub init_event ($$;$$) {
  $_[0]->_initialize (''.$_[1], !!$_[2], !!$_[3]) or return undef;
  return undef;
} # init_event

package Web::DOM::CustomEvent;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::Event);

sub _init_members ($) { $_[0]->SUPER::_init_members, [detail => 'any'] }

sub detail ($) { $_[0]->{detail} } # or undef

sub init_custom_event ($$;$$$) {
  $_[0]->_initialize (''.$_[1], !!$_[2], !!$_[3]) or return undef;
  $_[0]->{detail} = $_[4];
  return undef;
} # init_custom_event

package Web::DOM::UIEvent;
our $VERSION = '2.0';
push our @ISA, qw(Web::DOM::Event);
use Web::DOM::Internal;

sub _init_members ($) { $_[0]->SUPER::_init_members,
                        [view => 'object?', 'WindowProxy'], # willful violation
                        [detail => 'long'] }

sub detail ($) { $_[0]->{detail} || 0 }
sub view ($) { $_[0]->{view} } # or undef

sub init_ui_event ($$$$$$) {
  my ($type, $bubbles, $cancelable) = (''.$_[1], !!$_[2], !!$_[3]);
  _throw Web::DOM::TypeError 'The fourth argument is not a WindowProxy'
      if defined $_[4] and not UNIVERSAL::isa ($_[4], 'Web::DOM::WindowProxy');
  ## s/AbstractView/WindowProxy/, this is a willful violation to DOM3Events
  my $detail = _idl_long ($_[5]);
  $_[0]->_initialize ($type, $bubbles, $cancelable) or return undef;
  $_[0]->{view} = $_[4];
  $_[0]->{detail} = $detail;
  return undef;
} # init_ui_event

package Web::DOM::FocusEvent;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::UIEvent);

sub _init_members ($) { $_[0]->SUPER::_init_members,
                        [related_target => 'object?', 'EventTarget'] }

sub related_target ($) { $_[0]->{related_target} } # or undef

# initFocusEvent not implemented by Chrome

package Web::DOM::MouseEvent;
our $VERSION = '2.0';
push our @ISA, qw(Web::DOM::UIEvent);
use Web::DOM::Internal;

sub _init_members ($) { $_[0]->SUPER::_init_members,
                        [screen_x => 'long'],
                        [screen_y => 'long'],
                        [client_x => 'long'],
                        [client_y => 'long'],
                        [ctrl_key => 'boolean'],
                        [shift_key => 'boolean'],
                        [alt_key => 'boolean'],
                        [meta_key => 'boolean'],
                        [button => 'unsigned short'],
                        [buttons => 'unsigned short'],
                        [related_target => 'object?', 'EventTarget'],
                        [region => 'string?'] }

sub alt_key ($) { $_[0]->{alt_key} }
sub alt_graph_key ($) { $_[0]->{alt_graph_key} }
sub button ($) { $_[0]->{button} || 0 }
sub buttons ($) { $_[0]->{buttons} || 0 }
sub client_x ($) { $_[0]->{client_x} || 0 }
sub client_y ($) { $_[0]->{client_y} || 0 }
sub ctrl_key ($) { $_[0]->{ctrl_key} }
sub meta_key ($) { $_[0]->{meta_key} }
sub related_target ($) { $_[0]->{related_target} } # or undef
sub screen_x ($) { $_[0]->{screen_x} || 0 }
sub screen_y ($) { $_[0]->{screen_y} || 0 }
sub shift_key ($) { $_[0]->{shift_key} }
sub offset_x ($) { $_[0]->{offset_x} || 0 }
sub offset_y ($) { $_[0]->{offset_y} || 0 }
sub page_x ($) { $_[0]->{page_x} || 0 }
sub page_y ($) { $_[0]->{page_y} || 0 }
sub x ($) { $_[0]->client_x }
sub y ($) { $_[0]->client_y }
sub region ($) { $_[0]->{region} } # or undef

# XXX layer_x layer_y

*get_modifier_state = \&Web::DOM::KeyboardEvent::get_modifier_state;

sub init_mouse_event ($$$$$$$$$$$$$$$$) {
  my ($type, $bubbles, $cancelable) = (''.$_[1], !!$_[2], !!$_[3]);
  _throw Web::DOM::TypeError 'The fourth argument is not a WindowProxy'
      if defined $_[4] and not UNIVERSAL::isa ($_[4], 'Web::DOM::WindowProxy');
      ## A willful violation
  my $detail = _idl_long $_[5];
  my $sx = _idl_long $_[6];
  my $sy = _idl_long $_[7];
  my $cx = _idl_long $_[8];
  my $cy = _idl_long $_[9];
  my ($ctrl, $alt, $shift, $meta) = (!!$_[10], !!$_[11], !!$_[12], !!$_[13]);
  my $button = _idl_unsigned_short $_[14];
  _throw Web::DOM::TypeError 'The 16th argument is not an EventTarget'
      if defined $_[15] and
         not UNIVERSAL::isa ($_[15], 'Web::DOM::EventTarget');
  $_[0]->_initialize ($type, $bubbles, $cancelable) or return undef;
  $_[0]->{view} = $_[4];
  $_[0]->{detail} = $detail;
  $_[0]->{screen_x} = $sx;
  $_[0]->{screen_y} = $sy;
  $_[0]->{client_x} = $cx;
  $_[0]->{client_y} = $cy;
  $_[0]->{ctrl_key} = $ctrl;
  $_[0]->{alt_key} = $alt;
  $_[0]->{shift_key} = $shift;
  $_[0]->{meta_key} = $meta;
  $_[0]->{button} = $button;
  $_[0]->{related_target} = $_[15];
  return undef;
} # init_mouse_event

package Web::DOM::WheelEvent;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::MouseEvent);

our @EXPORT;
*import = \&Web::DOM::Internal::import;

sub _init_members ($) { $_[0]->SUPER::_init_members,
                        [delta_x => 'double'],
                        [delta_y => 'double'],
                        [delta_z => 'double'],
                        [delta_mode => 'unsigned long'] }

push @EXPORT, qw(DOM_DELTA_PIXEL DOM_DELTA_LINE DOM_DELTA_PAGE);

sub DOM_DELTA_PIXEL () { 0x00 }
sub DOM_DELTA_LINE () { 0x01 }
sub DOM_DELTA_PAGE () { 0x02 }

sub delta_x ($) { $_[0]->{delta_x} || 0 }
sub delta_y ($) { $_[0]->{delta_y} || 0 }
sub delta_z ($) { $_[0]->{delta_z} || 0 }
sub delta_mode ($) { $_[0]->{delta_mode} || 0 }

# Chrome implements initWebkitWheelEvent, not initWheelEvent

package Web::DOM::KeyboardEvent;
our $VERSION = '2.0';
push our @ISA, qw(Web::DOM::UIEvent);
use Web::DOM::Internal;

sub _init_members ($) { $_[0]->SUPER::_init_members,
                        [char => 'string'],
                        [key => 'string'],
                        [code => 'string'],
                        [location => 'unsigned long'],
                        [ctrl_key => 'boolean'],
                        [shift_key => 'boolean'],
                        [alt_key => 'boolean'],
                        [meta_key => 'boolean'],
                        [repeat => 'boolean'],
                        [locale => 'string'],
                        [char_code => 'unsigned long'],
                        [key_code => 'unsigned long'],
                        [which => 'unsigned long'] }

our @EXPORT = qw(DOM_KEY_LOCATION_STANDARD DOM_KEY_LOCATION_LEFT
                 DOM_KEY_LOCATION_RIGHT DOM_KEY_LOCATION_NUMPAD
                 DOM_KEY_LOCATION_MOBILE DOM_KEY_LOCATION_JOYSTICK);
*import = \&Web::DOM::Internal::import;

sub DOM_KEY_LOCATION_STANDARD () { 0x00 }
sub DOM_KEY_LOCATION_LEFT     () { 0x01 }
sub DOM_KEY_LOCATION_RIGHT    () { 0x02 }
sub DOM_KEY_LOCATION_NUMPAD   () { 0x03 }
sub DOM_KEY_LOCATION_MOBILE   () { 0x04 }
sub DOM_KEY_LOCATION_JOYSTICK () { 0x05 }

sub char ($) { defined $_[0]->{char} ? $_[0]->{char} : '' }
sub key ($) { defined $_[0]->{key} ? $_[0]->{key} : '' }
sub location ($) { $_[0]->{location} || 0 }
sub ctrl_key ($) { $_[0]->{ctrl_key} }
sub shift_key ($) { $_[0]->{shift_key} }
sub alt_key ($) { $_[0]->{alt_key} }
sub alt_graph_key ($) { $_[0]->{alt_graph_key} }
sub meta_key ($) { $_[0]->{meta_key} }
sub repeat ($) { $_[0]->{repeat} }
sub locale ($) { defined $_[0]->{locale} ? $_[0]->{locale} : '' }
sub char_code ($) { $_[0]->{char_code} || 0 }
sub key_code ($) { $_[0]->{key_code} || 0 }
sub which ($) { $_[0]->{which} || 0 }
sub code ($) { defined $_[0]->{code} ? $_[0]->{code} : '' }

sub get_modifier_state ($$) {
  return $_[0]->{{
    Alt => 'alt_key',
    AltGraph => 'alt_graph_key',
    CapsLock => '_caps_lock_key',
    Control => 'ctrl_key',
    Fn => '_fn_key',
    Meta => 'meta_key',
    NumLock => '_num_lock_key',
    ScrollLock => '_scroll_lock_key',
    Shift => 'shift_key',
    SymbolLock => '_symbol_lock_key',
    OS => '_os_key',
  }->{''.$_[1]} || ''};
} # get_modifier_state

# XXX queryKeyCap queryLocale

sub init_keyboard_event ($$$$$$$$$$$) {
  my ($type, $bubbles, $cancelable) = (''.$_[1], !!$_[2], !!$_[3]);
  _throw Web::DOM::TypeError 'The fourth argument is not a WindowProxy'
      if defined $_[4] and not UNIVERSAL::isa ($_[4], 'Web::DOM::WindowProxy');
  my $char = ''.$_[5];
  my $key = ''.$_[6];
  my $location = _idl_unsigned_long $_[7];
  my $modifiers_list = ''.$_[8];
  my $repeat = !!$_[9];
  my $locale = ''.$_[10];
  $_[0]->_initialize ($type, $bubbles, $cancelable) or return undef;
  $_[0]->{view} = $_[4];
  $_[0]->{char} = $char;
  $_[0]->{key} = $key;
  $_[0]->{location} = $location;
  delete $_[0]->{ctrl_key};
  delete $_[0]->{meta_key};
  delete $_[0]->{alt_key};
  delete $_[0]->{alt_graph_key};
  delete $_[0]->{shift_key};
  for (split /[\x09\x0A\x0D\x20]/, $modifiers_list) { # XML S
    if ($_ eq 'Control') {
      $_[0]->{ctrl_key} = 1;
    } elsif ($_ eq 'Shift') {
      $_[0]->{shift_key} = 1;
    } elsif ($_ eq 'Alt') {
      $_[0]->{alt_key} = 1;
    } elsif ($_ eq 'Meta') {
      $_[0]->{meta_key} = 1;
    } elsif ($_ eq 'AltGraph') {
      $_[0]->{alt_graph_key} = 1;
    }
  }
  $_[0]->{repeat} = $repeat;
  $_[0]->{locale} = $locale;
  return undef;
} # init_keyboard_event

package Web::DOM::CompositionEvent;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::UIEvent);

sub _init_members ($) { $_[0]->SUPER::_init_members,
                        [data => 'string?'],
                        [locale => 'string'] }

sub data ($) { $_[0]->{data} } # or undef
sub locale ($) { defined $_[0]->{locale} ? $_[0]->{locale} : '' }

sub init_composition_event ($$$$$$$) {
  my ($type, $bubbles, $cancelable) = (''.$_[1], !!$_[2], !!$_[3]);
  _throw Web::DOM::TypeError 'The fourth argument is not a Window'
      if defined $_[4] and not UNIVERSAL::isa ($_[4], 'Web::DOM::Window');
  my $data = defined $_[5] ? ''.$_[5] : undef;
  my $locale = $_[6];
  $_[0]->_initialize ($type, $bubbles, $cancelable) or return undef;
  $_[0]->{view} = $_[4];
  $_[0]->{data} = $data;
  $_[0]->{locale} = $locale;
  return undef;
}

package Web::DOM::TouchEvent;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::UIEvent);

sub _init_members ($) { $_[0]->SUPER::_init_members,
                        [touches => 'object?', 'TouchList'],
                        [target_touches => 'object?', 'TouchList'],
                        [changed_touches => 'object?', 'TouchList'],
                        [alt_key => 'boolean'],
                        [meta_key => 'boolean'],
                        [ctrl_key => 'boolean'],
                        [shift_key => 'boolean'] }

sub _touch () {
  require Web::DOM::TouchList;
  my $list = bless [], 'Web::DOM::TouchList';
  Internals::SvREADONLY (@$list, 1);
  return $list;
} # _touch

sub touches ($) { $_[0]->{touches} ||= _touch }
sub target_touches ($) { $_[0]->{target_touches} ||= _touch }
sub changed_touches ($) { $_[0]->{changed_touches} ||= _touch }
sub ctrl_key ($) { $_[0]->{ctrl_key} }
sub shift_key ($) { $_[0]->{shift_key} }
sub alt_key ($) { $_[0]->{alt_key} }
sub meta_key ($) { $_[0]->{meta_key} }

package Web::DOM::MessageEvent;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::Event);

sub _init_members ($) { $_[0]->SUPER::_init_members,
                        [data => 'any'],
                        [origin => 'string'],
                        [last_event_id => 'string'],
                        [source => 'object?', 'WindowProxy'], # XXX or MessagePort
                        [ports => 'object?', 'XXX sequence<MessagePort>'] }

sub data ($) { $_[0]->{data} }
sub origin ($) { defined $_[0]->{origin} ? $_[0]->{origin} : '' }
sub last_event_id ($) { defined $_[0]->{last_event_id} ? $_[0]->{last_event_id} : '' }
sub source ($) { $_[0]->{source} }
sub ports ($) { $_[0]->{ports} }

1;

=head1 LICENSE

Copyright 2013-2018 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
