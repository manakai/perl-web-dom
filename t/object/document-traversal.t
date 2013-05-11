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
  dies_here_ok {
    $doc->create_tree_walker;
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The first argument is not a Node';
  done $c;
} n => 3, name => 'craete_tree_walker root is not a Node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  ok $doc->can ('create_tree_walker'), 'Document->create_tw can';

  my $el = $doc->create_element ('e');
  my $tw = $doc->create_tree_walker ($el);

  ok $tw->isa ('Web::DOM::TreeWalker'), 'create_tw [1] if';
  is $tw->what_to_show, 0xFFFFFFFF, 'create_tw [1] what_to_show';
  is $tw->filter, undef, 'create_tw [1] filter';
  ok not ($tw->expand_entity_references), 'create_tw [1] xent';
  is $tw->current_node, $el, 'create_tw [1] current_node';
  is $tw->root, $el, 'create_tw [1] root';
  done $c;
} n => 7, name => 'create_tree_walker and attributes';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $tw = $doc->create_tree_walker ($doc, 0);
  is $tw->what_to_show, 0;
  done $c;
} n => 1, name => 'create_tree_walker what_to_show = 0';

run_tests;

=head1 LICENSE

Copyright 2007-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
