package Web::DOM::CharacterData;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;
use Web::DOM::ChildNode;
push our @ISA, qw(Web::DOM::Node Web::DOM::ChildNode);

*node_value = \&data;
*text_content = \&data;

sub data ($;$) {
  if (@_ > 1) {
    ## "Replace data" steps (simplified)
    # XXX mutation record
    ${${$_[0]}->[2]->{data}} = defined $_[1] ? ''.$_[1] : ''; # WebIDL
    # XXX range
  }
  return ${${$_[0]}->[2]->{data}} if defined wantarray;
} # data

# XXX length
# XXX data methods

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
