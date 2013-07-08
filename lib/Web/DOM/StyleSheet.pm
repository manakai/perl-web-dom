package Web::DOM::StyleSheet;
use strict;
use warnings;
our $VERSION = '1.0';

sub type ($) {
  return ${$_[0]}->[2]->{type};
} # type

sub href ($) {
  return ${$_[0]}->[2]->{href}; # or undef
} # href

sub manakai_base_uri ($) {
  return ${$_[0]}->[2]->{manakai_base_uri}
      if defined ${$_[0]}->[2]->{manakai_base_uri};
  return ${$_[0]}->[2]->{href} if defined ${$_[0]}->[2]->{href};
  return 'about:blank';
} # manakai_base_uri

sub manakai_input_encoding ($) {
  return ${$_[0]}->[2]->{input_encoding} || 'utf-8';
} # manakai_input_encoding

sub owner_node ($) {
  return ${$_[0]}->[0]->node (${$_[0]}->[2]->{owner_node}); # or undef
} # owner_node

sub parent_style_sheet ($) {
  return ${$_[0]}->[0]->sheet (${$_[0]}->[2]->{parent_style_sheet}); # or undef
} # parent_style_sheet

sub title ($) {
  return ${$_[0]}->[2]->{title}; # or undef
} # title

# XXX media

sub disabled ($;$) {
  if (@_ > 1) {
    $_[0]->{disabled} = !!$_[1];
  }
  return $_[0]->{disabled};
} # disabled

sub DESTROY ($) {
  ${$_[0]}->[0]->destroy_sheet (${$_[0]}->[1]);
} # DESTROY

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
