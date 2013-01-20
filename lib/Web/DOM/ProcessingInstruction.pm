package Web::DOM::ProcessingInstruction;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::CharacterData;
push our @ISA, qw(Web::DOM::CharacterData);

*node_name = \&target;

sub target ($) {
  return ${${$_[0]}->[2]->{target}};
} # target

sub manakai_base_uri ($;$) {
  return undef;
} # manakai_base_uri

1;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
