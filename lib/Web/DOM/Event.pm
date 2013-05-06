package Web::DOM::Event;
use strict;
use warnings;
our $VERSION = '1.0';
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
    my ($key, $type) = @$_;
    if (defined $_[2]->{$key}) {
      if ($type eq 'boolean') {
        $self->{$key} = !!$_[2]->{$key};
      } elsif ($type eq 'any') {
        $self->{$key} = $_[2]->{$key};
      } else {
        die "Value type |$type| is not defined";
      }
    }
  }
  return $self;
} # new

sub type ($) { $_[0]->{type} }
sub target ($) { $_[0]->{target} } # or undef
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

sub prevent_default ($) { $_[0]->{canceled} = 1 if $_[0]->{cancelable}; undef }
sub default_prevented ($) { $_[0]->{canceled} }

sub is_trusted ($) { $_[0]->{is_trusted} }
sub timestamp ($) { $_[0]->{timestamp} }

sub _initialize ($;$$$) {
  my $self = $_[0];

  ## Initialize
  ## <http://dom.spec.whatwg.org/#concept-event-initialize>.

  $self->{initialized} = 1;
  return 0 if $self->{dispatch};
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
  $_[0]->_initialize (''.$_[1], !!$_[2], !!$_[3]);
  return undef;
} # init_event

package Web::DOM::CustomEvent;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::Event);

sub _init_members ($) { $_[0]->SUPER::_init_members, [detail => 'any'] }

sub detail ($) { $_[0]->{detail} } # or undef

sub init_custom_event ($$;$$$) {
  $_[0]->_initialize (''.$_[1], !!$_[2], !!$_[3])
      or return; ## Willful violation to match browsers...
  $_[0]->{detail} = $_[4];
  return undef;
} # init_custom_event

package Web::DOM::UIEvent;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::Event);

# XXX

package Web::DOM::MouseEvent;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::UIEvent);

# XXX

1;
