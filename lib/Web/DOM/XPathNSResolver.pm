package Web::DOM::XPathNSResolver;
use strict;
use warnings;
our $VERSION = '1.0';

sub lookup_namespace_uri ($$) {
  return ${$_[0]}->lookup_namespace_uri ($_[1]);
} # lookup_namespace_uri

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
