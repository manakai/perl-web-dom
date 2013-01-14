use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('td');
  my $list = $el->headers;
  is $list->value, '';
  
  $list->value (' ');
  is $list->value, '';
  is scalar @$list, 0;
  
  $list->value ("\x0c\x0D\x0a\x20\x09def abc abc def");
  is $list->value, 'def abc';
  is scalar @$list, 2;
  is $el->get_attribute ('headers'), 'def abc';

  $list->value ("bbb cddd");
  is $list->value, 'bbb cddd';
  is scalar @$list, 2;
  is $el->get_attribute ('headers'), 'bbb cddd';

  $list->value ("");
  is $list->value, '';
  is scalar @$list, 0;
  is $el->get_attribute ('headers'), '';

  done $c;
} n => 12, name => 'value';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
