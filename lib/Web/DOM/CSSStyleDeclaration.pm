package Web::DOM::CSSStyleDeclaration;
use strict;
use warnings;
our $VERSION = '2.0';

# XXX css_text

# XXX length

# XXX item @{}

# XXX get_property_value

# XXX get_property_priority

# XXX set_property

# XXX remove_property

sub parent_rule ($) {
  if ($_[0]->[0] eq 'rule') {
    return $_[0]->[1];
  } else {
    return undef;
  }
} # parent_rule

# XXX add manakaiBaseURI ?

# XXX property methods

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
