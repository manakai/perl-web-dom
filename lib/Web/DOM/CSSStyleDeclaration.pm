package Web::DOM::CSSStyleDeclaration;
use strict;
use warnings;
our $VERSION = '1.0';

# XXX css_text

# XXX length

# XXX item @{}

# XXX get_property_value

# XXX get_property_priority

# XXX set_property

# XXX remove_property

sub parent_rule ($) {
  return ${$_[0]}->[0]->rule (${$_[0]}->[2]->{parent_rule});
} # parent_rule

# XXX add manakaiBaseURI ?

# XXX property methods

sub DESTROY ($) {
  ${$_[0]}->[0]->destroy_style (${$_[0]}->[1]);
} # DESTROY

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
