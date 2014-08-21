use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Exception;

test {
  my $c = shift;
  is NO_MODIFICATION_ALLOWED_ERR, 7;
  is DATA_CLONE_ERR, 25;
  is +Web::DOM::Exception->NOT_SUPPORTED_ERR, 9;
  done $c;
} name => 'constants', n => 3;

test {
  my $c = shift;

  dies_here_ok { _throw Web::DOM::Exception
             'TimeoutError', 'Something timeouted' };
  my $e = $@;
  isa_ok $e, 'Web::DOM::Exception';
  is $e->name, 'TimeoutError';
  is $e->code, 23;
  is $e->message, 'Something timeouted';
  is $e->file_name, __FILE__;
  is $e->line_number, __LINE__ - 8;
  is $e . '', "Something timeouted at " . __FILE__ . ' line ' .
      (__LINE__ - 10) . ".\n";

  done $c;
} n => 8, name => 'throw and basic attributes';

test {
  my $c = shift;

  dies_here_ok { _throw Web::DOM::Exception
             'InUseAttributeError', 'Something timeouted' };
  my $e = $@;
  isa_ok $e, 'Web::DOM::Exception';
  is $e->name, 'InUseAttributeError';
  is $e->code, 10;
  is $e->message, 'Something timeouted';
  is $e->file_name, __FILE__;
  is $e->line_number, __LINE__ - 8;
  is $e . '', "Something timeouted at " . __FILE__ . ' line ' .
      (__LINE__ - 10) . ".\n";

  done $c;
} n => 8, name => 'throw and basic attributes';

test {
  my $c = shift;

  dies_here_ok { _throw Web::DOM::Exception
             'EncodingError', 'Some encoding error' };
  my $e = $@;
  is $e->name, 'EncodingError';
  is $e->code, 0;
  is $e->message, 'Some encoding error';
  is $e->file_name, __FILE__;
  is $e->line_number, __LINE__ - 7;
  is $e . '', "Some encoding error at " . __FILE__ . ' line ' .
      (__LINE__ - 9) . ".\n";
  ok $e;
  is $e->TYPE_MISMATCH_ERR, 17;

  done $c;
} n => 9, name => 'Error name has no corresponding code';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
