use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::DOMError;

test {
  my $c = shift;
  my $error = new Web::DOM::DOMError;
  isa_ok $error, 'Web::DOM::DOMError';
  is $error->name, '';
  is $error->message, '';
  done $c;
} n => 3, name => 'constructor without name';

test {
  my $c = shift;
  my $error = new Web::DOM::DOMError 'hoge';
  isa_ok $error, 'Web::DOM::DOMError';
  is $error->name, 'hoge';
  is $error->message, '';
  done $c;
} n => 3, name => 'constructor with name';

test {
  my $c = shift;
  my $error = new Web::DOM::DOMError 'hoge', 'aa v';
  isa_ok $error, 'Web::DOM::DOMError';
  is $error->name, 'hoge';
  is $error->message, 'aa v';
  done $c;
} n => 3, name => 'constructor with name and message';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
