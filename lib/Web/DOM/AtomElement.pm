package Web::DOM::AtomElement;
use strict;
use warnings;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::Element);
use Web::DOM::Element;
use Web::DOM::Internal;
use Web::DOM::Node;

sub _define_atom_child_element ($$) {
  eval sprintf q{
    sub %s ($) {
      my $self = $_[0];
      for ($self->child_nodes->to_list) {
        if ($_->node_type == ELEMENT_NODE and
            $_->local_name eq '%s' and
            ($_->namespace_uri || '') eq ATOM_NS) {
          return $_;
        }
      }
      if (${$_[0]}->[0]->{config}->{manakai_create_child_element}) {
        my $el = $self->owner_document->create_element_ns (ATOM_NS, '%s');
        return $self->append_child ($el);
      } else {
        return undef;
      }
    }
    1;
  }, $_[0], $_[1], $_[1] or die $@;
} # _define_atom_child_element

sub _define_atom_child_element_list ($$) {
  eval sprintf q{
    sub %s ($) {
      my $self = shift;
      return $$self->[0]->collection ('%s', $self, sub {
        my $node = $_[0];
        return grep {
          $$node->[0]->{data}->[$_]->{node_type} == ELEMENT_NODE and
          ${$$node->[0]->{data}->[$_]->{namespace_uri} || \''} eq ATOM_NS and
          ${$$node->[0]->{data}->[$_]->{local_name}} eq '%s';
        } @{$$node->[0]->{data}->[$$node->[1]]->{child_nodes} or []};
      });
    }
    1;
  }, $_[0], $_[0], $_[1] or die $@;
} # _define_atom_child_element_list

sub xmlbase ($;$) {
  $_[0]->set_attribute_ns (XML_NS, ['xml', 'base'] => $_[1]) if @_ > 1;
  my $value = $_[0]->get_attribute_ns (XML_NS, 'base');
  return defined $value ? $value : '';
} # xmlbase

sub xmllang ($;$) {
  $_[0]->set_attribute_ns (XML_NS, ['xml', 'lang'] => $_[1]) if @_ > 1;
  my $value = $_[0]->get_attribute_ns (XML_NS, 'lang');
  return defined $value ? $value : '';
} # xmllang

package Web::DOM::AtomIdElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
package Web::DOM::AtomIconElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
package Web::DOM::AtomNameElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
package Web::DOM::AtomUriElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
package Web::DOM::AtomEmailElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
package Web::DOM::AtomLogoElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);

package Web::DOM::AtomTextConstruct;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
use Web::DOM::Internal;
use Web::DOM::Node;
use Web::DOM::Element;

_define_reflect_string type => 'type', 'text';

sub container ($) {
  my $self = $_[0];
  my $type = $self->get_attribute_ns (undef, 'type');
  if (defined $type and $type eq 'xhtml') {
    for ($self->child_nodes->to_list) {
      if ($_->node_type == ELEMENT_NODE and
          $_->local_name eq 'div' and
          ($_->namespace_uri || '') eq HTML_NS) {
        return $_;
      }
    }
    if (${$_[0]}->[0]->{config}->{manakai_create_child_element}) {
      my $el = $self->owner_document->create_element ('div');
      return $self->append_child ($el);
    } else {
      return undef;
    }
  } else {
    return $self;
  }
} # container

package Web::DOM::AtomRightsElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomTextConstruct);
package Web::DOM::AtomSubtitleElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomTextConstruct);
package Web::DOM::AtomSummaryElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomTextConstruct);
package Web::DOM::AtomTitleElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomTextConstruct);

package Web::DOM::AtomPersonConstruct;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
use Web::DOM::Internal;
use Web::DOM::Element;

_define_reflect_child_string name => ATOM_NS, 'name';
_define_reflect_child_url uri => ATOM_NS, 'uri';
_define_reflect_child_string email => ATOM_NS, 'email';

Web::DOM::AtomElement::_define_atom_child_element name_element => 'name';

package Web::DOM::AtomAuthorElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomPersonConstruct);
package Web::DOM::AtomContributorElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomPersonConstruct);

package Web::DOM::AtomDateConstruct;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
use Web::DOM::TypeError;

# XXX maybe this function should be moved to separate module...
sub _is_leap_year ($) {
  return ($_[0] % 400 == 0 or ($_[0] % 4 == 0 and $_[0] % 100 != 0));
} # _is_leap_year
sub parse_global_date_and_time_string ($$) {
  my ($self, $value) = @_;
  
  if ($value =~ /\A([0-9]{4,})-([0-9]{2})-([0-9]{2})T
                 ([0-9]{2}):([0-9]{2})(?>:([0-9]{2})(?>(\.[0-9]+))?)?
                 (?>Z|([+-][0-9]{2}):([0-9]{2}))\z/x) {
    my ($y, $M, $d, $h, $m, $s, $sf, $zh, $zm)
        = ($1, $2, $3, $4, $5, $6, $7, $8, $9);
    if (0 < $M and $M < 13) {
      $self->{onerror}->(type => 'datetime:bad day',
                         level => $self->{level}->{must}), return undef
          if $d < 1 or
              $d > [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]->[$M];
      $self->{onerror}->(type => 'datetime:bad day',
                         level => $self->{level}->{must}), return undef
          if $M == 2 and $d == 29 and not _is_leap_year ($y);
    } else {
      $self->{onerror}->(type => 'datetime:bad month',
                         level => $self->{level}->{must});
      return undef;
    }
    $self->{onerror}->(type => 'datetime:bad year',
                       level => $self->{level}->{must}), return undef if $y == 0;
    $self->{onerror}->(type => 'datetime:bad hour',
                       level => $self->{level}->{must}), return undef if $h > 23;
    $self->{onerror}->(type => 'datetime:bad minute',
                       level => $self->{level}->{must}), return undef if $m > 59;
    $s ||= 0;
    $self->{onerror}->(type => 'datetime:bad second',
                       level => $self->{level}->{must}), return undef if $s > 59;
    $sf = defined $sf ? $sf : '';
    if (defined $zh) {
      $self->{onerror}->(type => 'datetime:bad timezone hour',
                         level => $self->{level}->{must}), return undef
          if $zh > 23 or $zh < -23;
      $self->{onerror}->(type => 'datetime:bad timezone minute',
                         level => $self->{level}->{must}), return undef
          if $zm > 59;
    } else {
      $zh = 0;
      $zm = 0;
    }
    if ($zh eq '-00' and $zm eq '00') {
      $self->{onerror}->(type => 'datetime:-00:00', # XXXtype
                         level => $self->{level}->{must}); # don't return
    }

    if (defined wantarray) {
      return $self->{create}->($y, $M, $d, $h, $m, $s, $sf, $zh, $zm);
    }
  } else {
    $self->{onerror}->(type => 'datetime:syntax error',
                       level => $self->{level}->{must});
    return undef;
  }
} # parse_global_date_and_time_string

{
  ## From Time::Local
  use integer;

  use constant SECS_PER_MINUTE => 60;
  use constant SECS_PER_HOUR   => 3600;
  use constant SECS_PER_DAY    => 86400;

  # Determine the EPOC day for this machine
  my $Epoc = _daygm( gmtime(0) );
  my %Cheat = ();

  sub _daygm {
    # This is written in such a byzantine way in order to avoid
    # lexical variables and sub calls, for speed
    return $_[3] + (
        $Cheat{ pack( 'ss', @_[ 4, 5 ] ) } ||= do {
            my $month = ( $_[4] + 10 ) % 12;
            my $year  = ( $_[5] + 1900 ) - ( $month / 10 );

            ( ( 365 * $year )
              + ( $year / 4 )
              - ( $year / 100 )
              + ( $year / 400 )
              + ( ( ( $month * 306 ) + 5 ) / 10 )
            )
            - $Epoc;
        }
    );
  }

  sub timegm_nocheck {
    my ( $sec, $min, $hour, $mday, $month, $year ) = @_;

    my $days = _daygm( undef, undef, undef, $mday, $month, $year - 1900 );

    return $sec
           + ( SECS_PER_MINUTE * $min )
           + ( SECS_PER_HOUR * $hour )
           + ( SECS_PER_DAY * $days );
  }
}

sub value ($;$) {
  if (@_ > 1) {
    # WebIDL DOMTimeStamp (= WebIDL double in DOMPERL)
    my $value = 0+$_[1];
    if ($value eq 'nan' or $value eq 'inf' or $value eq '-inf') {
      _throw Web::DOM::TypeError "The value is out of range";
    }

    # DOMPERL DOMTimeStamp
    my $frac = '';
    if ($value != int $value) {
      my $mod = $value > 0 ? $value - int ($value)
                           : $value - int ($value - 1);
      $frac = sprintf '%f', $mod;
      $frac =~ s/^0//;
      $frac =~ s/0+$//;
      $value -= $mod;
      ## Handling of fraction is architecture dependent, although it
      ## should support at least three figures.
    }
    my @t = gmtime $value; # The perl in use must support 64-bit time_t.
    $t[4]++;
    $t[5] += 1900;
    if ($t[5] <= 0) {
      #
    } else {
      $_[0]->text_content (sprintf '%04d-%02d-%02dT%02d:%02d:%02d%sZ',
                               $t[5], $t[4], $t[3],
                               $t[2], $t[1], $t[0], $frac);
    }
    return unless defined wantarray;
  }
  
  my $value = parse_global_date_and_time_string {
    onerror => sub { },
    create => sub {
      return timegm_nocheck ($_[5], $_[4]-$_[8], $_[3]-$_[7], $_[2], $_[1]-1, $_[0])
          + (defined $_[6] ? '0'.$_[6] : 0);
    },
  }, $_[0]->text_content;
  return $value || 0;
} # value

package Web::DOM::AtomPublishedElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomDateConstruct);
package Web::DOM::AtomUpdatedElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomDateConstruct);

package Web::DOM::AtomFeedElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
use Web::DOM::Internal;
use Web::DOM::Element;

_define_reflect_child_string atom_id => ATOM_NS, 'id';

_define_reflect_child_url icon => ATOM_NS, 'icon';
_define_reflect_child_url logo => ATOM_NS, 'logo';

Web::DOM::AtomElement::_define_atom_child_element
    generator_element => 'generator';
Web::DOM::AtomElement::_define_atom_child_element
    subtitle_element => 'subtitle';
Web::DOM::AtomElement::_define_atom_child_element
    title_element => 'title';
Web::DOM::AtomElement::_define_atom_child_element
    updated_element => 'updated';

# XXX These four methods should insert the element before any
# atom:entry child

Web::DOM::AtomElement::_define_atom_child_element_list
    author_elements => 'author';
Web::DOM::AtomElement::_define_atom_child_element_list
    category_elements => 'category';
Web::DOM::AtomElement::_define_atom_child_element_list
    contributor_elements => 'contributor';
Web::DOM::AtomElement::_define_atom_child_element_list
    link_elements => 'link';
Web::DOM::AtomElement::_define_atom_child_element_list
    rights_elements => 'rights';
Web::DOM::AtomElement::_define_atom_child_element_list
    entry_elements => 'entry';

sub get_entry_element_by_id {
  my $id = ''.$_[1];
  return undef unless length $id;

  for (@{$_[0]->entry_elements}) {
    if ($_->atom_id eq $id) {
      return $_;
    }
  }

  return undef;
} # get_entry_element_by_id

# XXX add_new_entry

package Web::DOM::AtomEntryElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::AtomElement);
use Web::DOM::Internal;
use Web::DOM::Element;

_define_reflect_child_string atom_id => ATOM_NS, 'id';

# XXX

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
