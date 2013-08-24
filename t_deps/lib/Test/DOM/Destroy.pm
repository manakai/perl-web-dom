package Test::DOM::Destroy;
use strict;
use warnings;
use Exporter::Lite;

push our @EXPORT, qw(ondestroy);

sub ondestroy (&$) {
  my ($code, $obj) = @_;
  my $watcher = bless $code, 'Test::DOM::Destroy::Watcher';
  if (UNIVERSAL::isa ($obj, 'Web::DOM::Node') or
      UNIVERSAL::isa ($obj, 'Web::DOM::StyleSheet') or
      UNIVERSAL::isa ($obj, 'Web::DOM::CSSRule')) {
    $$obj->[2]->{_test_dom_ondestroy} = $watcher;
  } elsif (UNIVERSAL::isa ($obj, 'Web::DOM::Internal::Objects') or
           ref $obj eq 'HASH') {
    $obj->{_test_dom_ondestroy} = $watcher;
  } else {
    die "Can't install watcher to $obj";
  }
} # ondestroy

package Test::DOM::Destroy::Watcher;

sub DESTROY ($) {
  $_[0]->();
} # DESTROY

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
