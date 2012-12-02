use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $comment = $doc->create_comment ('hoge');
  isa_ok $comment, 'Web::DOM::Comment';
  isa_ok $comment, 'Web::DOM::CharacterData';
  isa_ok $comment, 'Web::DOM::Node';

  is $comment->node_type, $comment->COMMENT_NODE;
  is $comment->node_name, '#comment';
  is $comment->first_child, undef;
  is $comment->namespace_uri, undef;
  is $comment->prefix, undef;
  is $comment->manakai_local_name, undef;
  is $comment->local_name, undef;

  is $comment->data, 'hoge';
  is $comment->node_value, 'hoge';
  $comment->node_value ('fuga');
  is $comment->node_value, 'fuga';
  is $comment->data, 'fuga';
  $comment->data ('abc');
  is $comment->node_value, 'abc';
  is $comment->data, 'abc';

  done $c;
} n => 16, name => 'create_comment';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
