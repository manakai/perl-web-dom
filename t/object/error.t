use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::Error;

test {
  my $c = shift;
  ok $Web::DOM::Error::L1ObjectClass->{'Web::DOM::Error'};
  done $c;
} n => 1, name => 'Perl Error Object Interface Level 1';

test {
  my $c = shift;
  my $e = Web::DOM::Error->new;
  ok + Web::DOM::Error->is_error ($e);
  my $f = Web::DOM::Error->wrap ($e);
  is $f, $e;
  isa_ok $f, 'Web::DOM::Error';
  done $c;
} n => 3, name => 'is_error true';

test {
  my $c = shift;
  my $e = bless {}, 'test::customexception1';
  local $Web::DOM::Error::L1ObjectClass->{'test::customexception1'} = 1;
  ok + Web::DOM::Error->is_error ($e);
  my $f = Web::DOM::Error->wrap ($e);
  is $f, $e;
  isa_ok $f, 'test::customexception1';
  done $c;
} n => 3, name => 'is_error true custom class';

for my $value (
  undef, '',
) {
  test {
    my $c = shift;
    ok ! Web::DOM::Error->is_error ($value);
    done $c;
  } n => 1, name => 'is_error false';

  test {
    my $c = shift;
    my $e = Web::DOM::Error->wrap ($value);
    isa_ok $e, 'Web::DOM::Error';
    is $e->name, 'Error';
    is $e->message, "Something's wrong";
    is $e->file_name, __FILE__;
    is $e->line_number, __LINE__-5;
    is $e . '', "Error: ".$e->message." at ".$e->file_name." line ".$e->line_number.".\n";
    done $c;
  } n => 6, name => 'is_error false';
}

for my $value (
  'aava', 0, 532, -3141, 44.4, 0+'nan',
  [], {}, \"abc", (bless {}, 'test::foo'),
) {
  test {
    my $c = shift;
    ok ! Web::DOM::Error->is_error ($value);
    done $c;
  } n => 1, name => 'is_error false';

  test {
    my $c = shift;
    my $e = Web::DOM::Error->wrap ($value);
    isa_ok $e, 'Web::DOM::Error';
    is $e->name, 'Error';
    is $e->message, $value . '';
    ok ! ref $e->message;
    is $e->file_name, __FILE__;
    is $e->line_number, __LINE__-6;
    is $e . '', "Error: ".$e->message." at ".$e->file_name." line ".$e->line_number.".\n";
    done $c;
  } n => 7, name => 'is_error false';
}

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
  is $error . '', "Error: Error message at path/to file line 120.\n";
  is $error->stringify, $error . '';
  done $c;
} name => 'with message', n => 6;

test {
  my $c = shift;
  my $error = Web::DOM::Error->new ('Error message');
  isa_ok $error, 'Web::DOM::Error';
  is $error->name, 'Error';
  is $error->message, 'Error message';
  is $error->file_name, __FILE__;
  is $error->line_number, __LINE__-5;
  is $error . '', "Error: Error message at ".$error->file_name." line ".$error->line_number.".\n";
  is $error->stringify, $error . '';
  done $c;
} name => 'new with message', n => 7;

test {
  my $c = shift;
  my $error = Web::DOM::Error->new ('');
  isa_ok $error, 'Web::DOM::Error';
  is $error->name, 'Error';
  is $error->message, '';
  is $error->file_name, __FILE__;
  is $error->line_number, __LINE__-5;
  is $error . '', "Error at ".$error->file_name." line ".$error->line_number.".\n";
  done $c;
} name => 'new with empty message', n => 6;

test {
  my $c = shift;
  my $error = Web::DOM::Error->new;
  isa_ok $error, 'Web::DOM::Error';
  is $error->name, 'Error';
  is $error->message, '';
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
