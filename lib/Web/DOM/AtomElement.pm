package Web::DOM::AtomElement;
use strict;
use warnings;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::Element);
use Web::DOM::Element;
use Web::DOM::Internal;

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
push our @ISA, qw(Web::DOM::AtomElement);
package Web::DOM::AtomIconElement;
push our @ISA, qw(Web::DOM::AtomElement);
package Web::DOM::AtomNameElement;
push our @ISA, qw(Web::DOM::AtomElement);
package Web::DOM::AtomUriElement;
push our @ISA, qw(Web::DOM::AtomElement);
package Web::DOM::AtomEmailElement;
push our @ISA, qw(Web::DOM::AtomElement);
package Web::DOM::AtomLogoElement;
push our @ISA, qw(Web::DOM::AtomElement);

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
