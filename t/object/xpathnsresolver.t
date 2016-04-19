use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $el2 = $doc2->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $node2 = $doc2->create_comment ('foo');
  $el2->append_child ($node2);
  my $resolver = $doc1->create_ns_resolver ($node2);
  isa_ok $resolver, 'Web::DOM::XPathNSResolver';
  is $resolver->lookup_namespace_uri ('aaa'), undef;
  $el2->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:aaa', 'foo bar');
  $el2->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:bbb', '');
  is $resolver->lookup_namespace_uri ('aaa'), 'foo bar';
  is $resolver->lookup_namespace_uri ('bbb'), undef;
  is $resolver->lookup_namespace_uri ('xml'), undef;
  is $resolver->lookup_namespace_uri ('xmlns'), undef;
  is $resolver->lookup_namespace_uri (''), 'http://www.w3.org/1999/xhtml';
  is $resolver->lookup_namespace_uri (undef), 'http://www.w3.org/1999/xhtml';
  done $c;
} n => 8, name => 'lookup_namespace_uri';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
