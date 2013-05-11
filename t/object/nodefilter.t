use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::NodeFilter;

test {
  my $c = shift;
  ok FILTER_ACCEPT;
  ok FILTER_REJECT;
  ok FILTER_SKIP;
  ok SHOW_ALL;
  ok SHOW_ELEMENT;
  ok SHOW_ATTRIBUTE;
  ok SHOW_TEXT;
  ok SHOW_CDATA_SECTION;
  ok SHOW_ENTITY_REFERENCE;
  ok SHOW_ENTITY;
  ok SHOW_PROCESSING_INSTRUCTION;
  ok SHOW_COMMENT;
  ok SHOW_DOCUMENT;
  ok SHOW_DOCUMENT_TYPE;
  ok SHOW_DOCUMENT_FRAGMENT;
  ok SHOW_NOTATION;
  done $c;
} n => 16, name => 'constants exported';

test {
  my $c = shift;
  ok +Web::DOM::NodeFilter->FILTER_ACCEPT;
  ok +Web::DOM::NodeFilter->FILTER_REJECT;
  ok +Web::DOM::NodeFilter->FILTER_SKIP;
  ok +Web::DOM::NodeFilter->SHOW_ALL;
  ok +Web::DOM::NodeFilter->SHOW_ELEMENT;
  ok +Web::DOM::NodeFilter->SHOW_ATTRIBUTE;
  ok +Web::DOM::NodeFilter->SHOW_TEXT;
  ok +Web::DOM::NodeFilter->SHOW_CDATA_SECTION;
  ok +Web::DOM::NodeFilter->SHOW_ENTITY_REFERENCE;
  ok +Web::DOM::NodeFilter->SHOW_ENTITY;
  ok +Web::DOM::NodeFilter->SHOW_PROCESSING_INSTRUCTION;
  ok +Web::DOM::NodeFilter->SHOW_COMMENT;
  ok +Web::DOM::NodeFilter->SHOW_DOCUMENT;
  ok +Web::DOM::NodeFilter->SHOW_DOCUMENT_TYPE;
  ok +Web::DOM::NodeFilter->SHOW_DOCUMENT_FRAGMENT;
  ok +Web::DOM::NodeFilter->SHOW_NOTATION;
  done $c;
} n => 16, name => 'constants class';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
