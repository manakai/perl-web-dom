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
  ok $Web::DOM::Error::L1ObjectClass->{'Web::DOM::Exception'};
  done $c;
} n => 1, name => 'Perl Error Object Interface Level 1';

test {
  my $c = shift;
  my $e = Web::DOM::Exception->new;
  ok + Web::DOM::Error->is_error ($e);
  my $f = Web::DOM::Error->wrap ($e);
  is $f, $e;
  isa_ok $f, 'Web::DOM::Exception';
  done $c;
} n => 3, name => 'is_error true';

test {
  my $c = shift;

  my $error = new Web::DOM::Exception;
  is $error->name, 'Error';
  is $error->message, '';
  is $error->file_name, __FILE__;
  is $error->line_number, __LINE__-4;
  is $error . '', "Error at ".$error->file_name." line ".$error->line_number.".\n";
  done $c;
} name => 'new without message', n => 5;

test {
  my $c = shift;

  my $error = new Web::DOM::Exception ('Error message');
  isa_ok $error, 'Web::DOM::Exception';
  isa_ok $error, 'Web::DOM::Error';

  is $error->name, 'Error';
  is $error->message, 'Error message';
  is $error->file_name, __FILE__;
  is $error->line_number, __LINE__-7;
  is $error . '', "Error: Error message at ".$error->file_name." line ".$error->line_number.".\n";

  done $c;
} name => 'new with message', n => 7;

test {
  my $c = shift;

  my $error = new Web::DOM::Exception ('Error message', 'Fuga error');
  isa_ok $error, 'Web::DOM::Exception';
  isa_ok $error, 'Web::DOM::Error';

  is $error->name, 'Fuga error';
  is $error->message, 'Error message';
  is $error->file_name, __FILE__;
  is $error->line_number, __LINE__-7;
  is $error . '', "Fuga error: Error message at ".$error->file_name." line ".$error->line_number.".\n";
  is $error->stringify, $error . '';

  done $c;
} name => 'new with message and name', n => 8;

test {
  my $c = shift;

  my $error = new Web::DOM::Exception (undef, 'Fuga error');
  isa_ok $error, 'Web::DOM::Exception';
  isa_ok $error, 'Web::DOM::Error';

  is $error->name, 'Fuga error';
  is $error->message, '';
  is $error->file_name, __FILE__;
  is $error->line_number, __LINE__-7;
  is $error . '', "Fuga error at ".$error->file_name." line ".$error->line_number.".\n";

  done $c;
} name => 'new with name', n => 7;

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
  is $e . '', "TimeoutError: Something timeouted at " . __FILE__ . ' line ' .
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
  is $e . '', "InUseAttributeError: Something timeouted at " . __FILE__ . ' line ' .
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
  is $e . '', "EncodingError: Some encoding error at " . __FILE__ . ' line ' .
      (__LINE__ - 9) . ".\n";
  ok $e;
  is $e->TYPE_MISMATCH_ERR, 17;

  done $c;
} n => 9, name => 'Error name has no corresponding code';

test {
  my $c = shift;
  my $e1 = Web::DOM::Exception->new;
  my $e2 = Web::DOM::Exception->new;
  isnt $e1, $e2;
  is $e1, $e1;
  done $c;
} n => 2, name => 'cmp';

test {
  my $c = shift;
  my $e1 = Web::DOM::Exception->new ('Hoge');
  my $e2 = Web::DOM::Exception->new ('Hoge');
  isnt $e1, $e2;
  is $e1, $e1;
  done $c;
} n => 2, name => 'cmp';

run_tests;

=head1 LICENSE

Copyright 2012-2017 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
