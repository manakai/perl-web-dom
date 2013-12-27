use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Destroy;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('template');

  my $df = $el->content;
  isa_ok $df, 'Web::DOM::DocumentFragment';
  is $df->child_nodes->length, 0;

  is $el->content, $df;

  done $c;
} n => 3, name => 'create_element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo:template');

  my $df = $el->content;
  isa_ok $df, 'Web::DOM::DocumentFragment';
  is $df->child_nodes->length, 0;

  is $el->content, $df;

  done $c;
} n => 3, name => 'create_element_ns';

test {
  my $c = shift;
  my $doc0 = new Web::DOM::Document;
  my $el0 = $doc0->create_element ('template');
  my $doc = $el0->content->owner_document;
  my $el = $doc->create_element ('template');

  my $df = $el->content;
  isa_ok $df, 'Web::DOM::DocumentFragment';
  is $df->child_nodes->length, 0;

  is $el->content, $df;

  is $$el->[0]->{tree_id}->[$$el->[1]], $$df->[0]->{tree_id}->[$$df->[1]];

  done $c;
} n => 4, name => 'create_element nested';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  $doc1->manakai_set_url ('http://test/');
  $doc1->manakai_charset ('utf-16be');
  $doc1->input_encoding ('euc-jp');
  $doc1->manakai_compat_mode ('limited quirks');

  my $el = $doc1->create_element ('template');
  my $doc2 = $el->content->owner_document;

  is $doc2->url, 'about:blank';
  is $doc2->input_encoding, 'utf-8';
  is $doc2->manakai_charset, undef;
  is $doc2->manakai_compat_mode, 'no quirks';

  done $c;
} n => 4, name => 'document props';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('template');

  my $destroyed = 0;
  ondestroy { $destroyed = 1 } $el->content;

  undef $doc;
  ok not $destroyed;

  undef $el;
  ok $destroyed;

  done $c;
} n => 2, name => 'destroy outermost';

test {
  my $c = shift;
  my $doc0 = new Web::DOM::Document;
  my $el0 = $doc0->create_element ('template');
  my $doc = $el0->content->owner_document;
  my $el = $doc->create_element ('template');

  my $destroyed = 0;
  ondestroy { $destroyed = 1 } $el->content;

  undef $doc;
  undef $doc0;
  undef $el0;
  ok not $destroyed;

  undef $el;
  ok $destroyed;

  done $c;
} n => 2, name => 'destroy in template';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('template');

  my $destroyed = 0;
  ondestroy { $destroyed = 1 } $el->content->owner_document;

  undef $el;
  ok not $destroyed;

  undef $doc;
  ok $destroyed;

  done $c;
} n => 2, name => 'destroy';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('template');
  my $df = $el->content;

  my $destroyed = 0;
  ondestroy { $destroyed = 1 } $doc;

  undef $el;
  undef $doc;
  ok $destroyed;

  done $c;
} n => 1, name => 'destroy outermost document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('template');
  my $df = $el->content;
  isnt $df->owner_document, $el->owner_document, 'outermost';

  my $el5 = $doc->create_element ('template');
  my $df5 = $el5->content;
  is $df5->owner_document, $df->owner_document, 'outermost';

  my $el2 = $df->owner_document->create_element ('template');
  my $df2 = $el2->content;
  is $df2->owner_document, $df->owner_document, 'template level 1';

  my $el3 = $df2->owner_document->create_element ('template');
  my $df3 = $el3->content;
  is $df3->owner_document, $df->owner_document, 'template level 2';

  my $el4 = $df2->owner_document->create_element ('template');
  my $df4 = $el4->content;
  is $df4->owner_document, $df->owner_document, 'template level 2';

  done $c;
} n => 5, name => 'owner_document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('template');

  ok not $el->content->owner_document->manakai_is_html;

  done $c;
} n => 1, name => 'XML document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('template');

  ok $el->content->owner_document->manakai_is_html;

  done $c;
} n => 1, name => 'HTML document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('template');
  my $df = $el->content;

  my $el2 = $doc->create_element ('div');
  $el2->append_child ($el);

  is $$el->[0]->{tree_id}->[$$el->[1]], $$el2->[0]->{tree_id}->[$$el2->[1]];

  $el2->remove_child ($el);

  isnt $$el->[0]->{tree_id}->[$$el->[1]], $$el2->[0]->{tree_id}->[$$el2->[1]];

  done $c;
} n => 2, name => 'append template';

test {
  my $c = shift;
  my $doc0 = new Web::DOM::Document;
  my $el0 = $doc0->create_element ('template');
  my $doc = $el0->content->owner_document;

  my $el = $doc->create_element ('template');
  my $df = $el->content;

  my $el2 = $doc->create_element ('div');
  $el2->append_child ($el);

  is $$el->[0]->{tree_id}->[$$el->[1]], $$el2->[0]->{tree_id}->[$$el2->[1]];
  is $$el->[0]->{tree_id}->[$$el->[1]], $$df->[0]->{tree_id}->[$$df->[1]];

  $el2->remove_child ($el);

  isnt $$el->[0]->{tree_id}->[$$el->[1]], $$el2->[0]->{tree_id}->[$$el2->[1]];
  is $$el->[0]->{tree_id}->[$$el->[1]], $$df->[0]->{tree_id}->[$$df->[1]];

  done $c;
} n => 4, name => 'append template';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el = $doc1->create_element ('template');
  my $df = $el->content;
  my $doc2 = $df->owner_document;
  
  my $doc3 = new Web::DOM::Document;
  $doc3->adopt_node ($el);

  is $el->owner_document, $doc3;
  is $el->content, $df;
  isnt $df->owner_document, $doc2;
  isnt $df->owner_document, $doc3;

  my $el2 = $doc3->create_element ('template');
  is $df->owner_document, $el2->content->owner_document;

  done $c;
} n => 5, name => 'adopt outermost template element';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el = $doc1->create_element ('template');
  my $df = $el->content;
  my $doc2 = $df->owner_document;

  my $el3 = $doc2->create_element ('template');
  $df->append_child ($el3);
  my $df3 = $el3->content;
  my $doc4 = $df3->owner_document;
  is $doc4, $doc2;
  
  my $doc3 = new Web::DOM::Document;
  $doc3->adopt_node ($el);

  is $el3->owner_document, $df->owner_document;
  is $df3->owner_document, $df->owner_document;
  isnt $el3->owner_document, $doc2;

  my $el5 = $doc3->create_element ('template');
  is $el5->content->owner_document, $el3->owner_document;

  done $c;
} n => 5, name => 'adopt outermost template element with template element';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element ('p');
  my $el2 = $doc1->create_element ('template');
  $el1->append_child ($el2);
  my $df1 = $el2->content;
  my $doc2 = $df1->owner_document;

  my $doc3 = new Web::DOM::Document;
  $doc3->adopt_node ($el1);

  is $el2->owner_document, $doc3;
  isnt $df1->owner_document, $doc2;
  is $df1->owner_document, $doc3->create_element ('template')->content->owner_document;

  done $c;
} n => 3, name => 'adopt parent of template element';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element ('p');

  my $el2 = $doc1->create_element ('template');
  $el1->append_child ($el2);
  my $df2 = $el2->content;
  my $doc2 = $df2->owner_document;

  my $el3 = $doc1->create_element ('template');
  $el1->append_child ($el3);
  my $df3 = $el3->content;
  my $doc3 = $df3->owner_document;

  my $doc4 = new Web::DOM::Document;
  $doc4->adopt_node ($el1);

  is $el2->owner_document, $doc4;
  is $el3->owner_document, $doc4;
  is $df2->owner_document, $df3->owner_document;

  done $c;
} n => 3, name => 'adopt parent of multiple template elements';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element ('template');
  my $df1 = $el1->content;
  my $doc2 = $df1->owner_document;

  my $doc3 = new Web::DOM::Document;
  $doc3->adopt_node ($df1);

  is $df1->owner_document, $doc3;
  is $el1->content, $df1;

  my $el2 = $doc1->create_element ('template');
  is $el2->content->owner_document, $doc2;

  done $c;
} n => 3, name => 'adopt template content';

test {
  my $c = shift;

  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element ('template');
  my $df1 = $el1->content;

  my $doc2 = $df1->owner_document;
  my $el2 = $doc2->create_element ('template');
  $df1->append_child ($el2);
  my $df2 = $el2->content;
  my $doc3 = $df2->owner_document;
  is $doc3, $doc2;

  my $doc4 = new Web::DOM::Document;
  $doc4->adopt_node ($el2);

  is $el2->owner_document, $doc4;
  isnt $df2->owner_document, $doc3;

  done $c;
} n => 3, name => 'adopt nested template element';

test {
  my $c = shift;

  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element ('template');
  my $df1 = $el1->content;

  my $doc2 = $df1->owner_document;
  my $el2 = $doc2->create_element ('template');
  $df1->append_child ($el2);
  my $df2 = $el2->content;
  my $doc3 = $df2->owner_document;
  is $doc3, $doc2;

  my $doc4 = new Web::DOM::Document;
  $doc4->adopt_node ($df2);

  is $el2->content, $df2;
  is $df2->owner_document, $doc4;
  is $doc2->create_element ('template')->content->owner_document, $doc3;

  done $c;
} n => 4, name => 'adopt nested template content';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element ('template');
  my $df1 = $el1->content;
  my $doc2 = $df1->owner_document;

  $doc1->adopt_node ($df1);

  is $df1->owner_document, $doc1;
  is $el1->content, $df1;

  is $doc1->create_element ('template')->content->owner_document, $doc2;

  done $c;
} n => 3, name => 'adopt template content to document of host';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element ('template');
  my $df1 = $el1->content;
  my $doc2 = $df1->owner_document;
  my $el2 = $doc2->create_element ('template');
  $df1->append_child ($el2);
  my $df2 = $el2->content;
  my $doc3 = $df2->owner_document;
  is $doc3, $doc2;

  $doc1->adopt_node ($df1);

  is $df1->owner_document, $doc1;
  is $el1->content, $df1;
  is $el2->owner_document, $doc1;
  is $el2->content, $df2;
  is $df2->owner_document, $doc2;

  done $c;
} n => 6, name => 'adopt template content with nested template element to document of host';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element ('template');
  my $df1 = $el1->content;
  my $doc2 = $df1->owner_document;
  isnt $doc2, $doc1;

  $doc2->adopt_node ($el1);

  is $el1->owner_document, $doc2;
  is $el1->content, $df1;

  is $doc1->create_element ('template')->content->owner_document, $doc2;

  done $c;
} n => 4, name => 'adopt host element to template content document';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element ('template');
  my $df1 = $el1->content;
  my $doc2 = $df1->owner_document;
  my $el2 = $df1->owner_document->create_element ('template');
  $df1->append_child ($el2);
  my $df2 = $el2->content;
  my $el3 = $df2->owner_document->create_element ('template');
  $df2->append_child ($el3);
  my $df3 = $el3->content;

  my $doc4 = new Web::DOM::Document;
  $doc4->adopt_node ($el1);

  is $el1->owner_document, $doc4;
  my $doc5 = $el1->content->owner_document;
  is $df1->owner_document, $doc5;
  is $el2->owner_document, $doc5;
  is $df2->owner_document, $doc5;
  is $el3->owner_document, $doc5;
  is $df3->owner_document, $doc5;
  isnt $doc5, $doc1;
  isnt $doc5, $doc2;
  isnt $doc5, $doc4;

  done $c;
} n => 9, name => 'adopt multiple nested templates';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element ('template');
  my $df1 = $el1->content;
  my $doc2 = $df1->owner_document;
  my $el2 = $df1->owner_document->create_element ('template');
  $df1->append_child ($el2);
  my $df2 = $el2->content;
  my $el3 = $df2->owner_document->create_element ('template');
  $df2->append_child ($el3);
  my $df3 = $el3->content;
  my $doc6 = new Web::DOM::Document;
  $doc6->adopt_node ($df2);
  $doc1->adopt_node ($df3);

  my $doc4 = new Web::DOM::Document;
  $doc4->adopt_node ($el1);

  is $el1->owner_document, $doc4;
  my $doc5 = $el1->content->owner_document;
  is $df1->owner_document, $doc5;
  is $el2->owner_document, $doc5;
  is $df2->owner_document, $doc5;
  is $el3->owner_document, $doc5;
  is $df3->owner_document, $doc5;
  isnt $doc5, $doc1;
  isnt $doc5, $doc2;
  isnt $doc5, $doc4;

  done $c;
} n => 9, name => 'adopt multiple nested templates with multiple docs';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
