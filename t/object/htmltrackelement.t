use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::HTMLTrackElement;

test {
  my $c = shift;
  is NONE, 0;
  is LOADING, 1;
  is LOADED, 2;
  is ERROR, 3;
  done $c;
} n => 4, name => 'consts';

test {
  my $c = shift;
  is +Web::DOM::HTMLTrackElement->NONE, 0;
  is +Web::DOM::HTMLTrackElement->LOADING, 1;
  is +Web::DOM::HTMLTrackElement->LOADED, 2;
  is +Web::DOM::HTMLTrackElement->ERROR, 3;
  done $c;
} n => 4, name => 'consts';

test {
  my $c = shift;
  require Web::DOM::Document;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('track');
  is $el->NONE, 0;
  is $el->LOADING, 1;
  is $el->LOADED, 2;
  is $el->ERROR, 3;
  done $c;
} n => 4, name => 'consts';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
