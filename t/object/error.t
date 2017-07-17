use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::Error;

sub create_error (;%) {
  return bless {name => 'Error', @_}, 'Web::DOM::Error';
} # create_error

test {
  my $c = shift;

  my $error = create_error message => 'Error message',
      file_name => 'path/to file', line_number => 120;
  is $error->name, 'Error';
  is $error->message, 'Error message';
  is $error->file_name, 'path/to file';
  is $error->line_number, 120;
  is $error . '', "Error message at path/to file line 120.\n";
  done $c;
} name => 'with message', n => 5;

test {
  my $c = shift;
  my $error = Web::DOM::Error->new ('Error message');
  isa_ok $error, 'Web::DOM::Error';
  is $error->name, 'Error';
  is $error->message, 'Error message';
  is $error->file_name, __FILE__;
  is $error->line_number, __LINE__-5;
  is $error . '', "Error message at ".$error->file_name." line ".$error->line_number.".\n";
  done $c;
} name => 'new with message', n => 6;

test {
  my $c = shift;
  my $error = Web::DOM::Error->new;
  isa_ok $error, 'Web::DOM::Error';
  is $error->name, 'Error';
  is $error->message, 'Error';
  is $error->file_name, __FILE__;
  is $error->line_number, __LINE__-5;
  is $error . '', "Error at ".$error->file_name." line ".$error->line_number.".\n";
  done $c;
} name => 'new without message', n => 6;

test {
  my $c = shift;
  my $error1 = create_error message => 'hoge',
      file_name => 'path/to file', line_number => 120;
  my $error2 = create_error message => 'hoge',
      file_name => 'path/to file', line_number => 120;

  ok $error1 eq $error1;
  ok not $error1 ne $error1;
  ok not $error2 eq $error1;
  ok $error2 ne $error1;
  ok $error1 ne undef;
  ok not $error1 eq undef;
  is $error1 cmp $error1, 0;
  isnt $error1 cmp $error2, 0;
  isnt $error1 . '', $error1;

  # XXX test unitinialized warning by eq/ne/cmp-ing with undef
  
  done $c;
} name => 'eq', n => 9;

run_tests;

=head1 LICENSE

Copyright 2012-2017 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
