package Web::DOM::StyleSheet;
use strict;
use warnings;
our $VERSION = '2.0';

sub type ($) {
  die "Not implemented";
} # type

sub href ($) {
  #XXX
  return ${$_[0]}->[2]->{href}; # or undef
} # href

sub manakai_base_uri ($) {
  #XXX
  return ${$_[0]}->[2]->{manakai_base_uri}
      if defined ${$_[0]}->[2]->{manakai_base_uri};
  return ${$_[0]}->[2]->{href} if defined ${$_[0]}->[2]->{href};
  return 'about:blank';
} # manakai_base_uri

sub manakai_input_encoding ($) {
  #XXX
  return ${$_[0]}->[2]->{input_encoding} || 'utf-8';
} # manakai_input_encoding

sub owner_node ($) {
  my $id = ${$_[0]}->[2]->{owner};
  return defined $id && defined ${$_[0]}->[0]->{data}->[$id]->{node_type} # XXXtest
      ? ${$_[0]}->[0]->node ($id) : undef;
} # owner_node

sub parent_style_sheet ($) {
  my $id = ${$_[0]}->[2]->{XXX};
  return defined $id ? ${$_[0]}->[0]->node ($id) : undef;
} # parent_style_sheet

sub title ($) {
  my $owner = $_[0]->owner_node;
  if (defined $owner) { # XXX HTML <style> or <link>
    # XXX Chrome.  Should we really do this?
    my $title = $owner->title;
    return length $title ? $title : undef;
  }

  #XXX
  return ${$_[0]}->[2]->{title}; # or undef
} # title

sub media ($;$) {
  my $list = ${$_[0]}->[0]->media ($_[0]);
  if (@_ > 1) {
    $list->media_text ($_[1]);
  }
  return $list;
} # media

sub disabled ($;$) {
  if (@_ > 1) {
    # XXX side effect??
    ${$_[0]}->[2]->{disabled} = !!$_[1];
  }
  return ${$_[0]}->[2]->{disabled};
} # disabled

sub DESTROY ($) {
  ${$_[0]}->[0]->gc (${$_[0]}->[1]);
} # DESTROY

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
