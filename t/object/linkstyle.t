use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::Differences;
use Web::DOM::Document;
use Web::CSS::Parser;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'style');

  is $el->sheet, undef;

  done $c;
} n => 1, name => '<style> no style sheet';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'style');

  my $parser = Web::CSS::Parser->new;
  $parser->parse_style_element ($el);

  my $sheet = $el->sheet;
  isa_ok $sheet, 'Web::DOM::CSSStyleSheet';
  
  my $owner = $sheet->owner_node;
  is $owner, $el;

  is $el->sheet, $sheet;

  undef $owner;
  undef $el;
  undef $doc;

  isa_ok $sheet->owner_node, 'Web::DOM::Element';
  is $sheet->owner_node->sheet, $sheet;

  done $c;
} n => 5, name => '<style> sheet';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'style');

  my $parser = Web::CSS::Parser->new;
  $parser->parse_style_element ($el);

  my $sheet1 = $el->sheet;

  $parser->parse_style_element ($el);

  my $sheet2 = $el->sheet;

  isnt $sheet2, $sheet1;
  isnt $$sheet2->[0]->{tree_id}->[3], $$sheet2->[0]->{tree_id}->[2];

  is $sheet1->owner_node, undef;
  undef $sheet1;

  is $$sheet2->[0]->{data}->[2], undef;

  done $c;
} n => 4, name => '<style> sheet reparsed';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
