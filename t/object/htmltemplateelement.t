use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Destroy;
use Test::DOM::Exception;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');

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
  my $el0 = $doc0->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $doc = $el0->content->owner_document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');

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

  my $el = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $doc2 = $el->content->owner_document;

  is $doc2->url, 'about:blank';
  is $doc2->input_encoding, 'UTF-8';
  is $doc2->manakai_charset, undef;
  is $doc2->manakai_compat_mode, 'no quirks';

  done $c;
} n => 4, name => 'document props';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');

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
  my $el0 = $doc0->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $doc = $el0->content->owner_document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');

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
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');

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
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
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

  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df = $el->content;
  isnt $df->owner_document, $el->owner_document, 'outermost';

  my $el5 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df5 = $el5->content;
  is $df5->owner_document, $df->owner_document, 'outermost';

  my $el2 = $df->owner_document->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df2 = $el2->content;
  is $df2->owner_document, $df->owner_document, 'template level 1';

  my $el3 = $df2->owner_document->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df3 = $el3->content;
  is $df3->owner_document, $df->owner_document, 'template level 2';

  my $el4 = $df2->owner_document->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df4 = $el4->content;
  is $df4->owner_document, $df->owner_document, 'template level 2';

  done $c;
} n => 5, name => 'owner_document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');

  ok not $el->content->owner_document->manakai_is_html;

  done $c;
} n => 1, name => 'XML document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');

  ok $el->content->owner_document->manakai_is_html;

  done $c;
} n => 1, name => 'HTML document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df = $el->content;

  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'div');
  $el2->append_child ($el);

  is $$el->[0]->{tree_id}->[$$el->[1]], $$el2->[0]->{tree_id}->[$$el2->[1]];

  $el2->remove_child ($el);

  isnt $$el->[0]->{tree_id}->[$$el->[1]], $$el2->[0]->{tree_id}->[$$el2->[1]];

  done $c;
} n => 2, name => 'append template';

test {
  my $c = shift;
  my $doc0 = new Web::DOM::Document;
  my $el0 = $doc0->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $doc = $el0->content->owner_document;

  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df = $el->content;

  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'div');
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
  my $el = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df = $el->content;
  my $doc2 = $df->owner_document;
  
  my $doc3 = new Web::DOM::Document;
  $doc3->adopt_node ($el);

  is $el->owner_document, $doc3;
  is $el->content, $df;
  isnt $df->owner_document, $doc2;
  isnt $df->owner_document, $doc3;

  my $el2 = $doc3->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  is $df->owner_document, $el2->content->owner_document;

  done $c;
} n => 5, name => 'adopt outermost template element';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df = $el->content;
  my $doc2 = $df->owner_document;

  my $el3 = $doc2->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  $df->append_child ($el3);
  my $df3 = $el3->content;
  my $doc4 = $df3->owner_document;
  is $doc4, $doc2;
  
  my $doc3 = new Web::DOM::Document;
  $doc3->adopt_node ($el);

  is $el3->owner_document, $df->owner_document;
  is $df3->owner_document, $df->owner_document;
  isnt $el3->owner_document, $doc2;

  my $el5 = $doc3->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  is $el5->content->owner_document, $el3->owner_document;

  done $c;
} n => 5, name => 'adopt outermost template element with template element';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'p');
  my $el2 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  $el1->append_child ($el2);
  my $df1 = $el2->content;
  my $doc2 = $df1->owner_document;

  my $doc3 = new Web::DOM::Document;
  $doc3->adopt_node ($el1);

  is $el2->owner_document, $doc3;
  isnt $df1->owner_document, $doc2;
  is $df1->owner_document, $doc3->create_element_ns ('http://www.w3.org/1999/xhtml', 'template')->content->owner_document;

  done $c;
} n => 3, name => 'adopt parent of template element';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'p');

  my $el2 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  $el1->append_child ($el2);
  my $df2 = $el2->content;
  my $doc2 = $df2->owner_document;

  my $el3 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
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
  my $el1 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df1 = $el1->content;
  my $doc2 = $df1->owner_document;

  my $doc3 = new Web::DOM::Document;
  is $doc3->adopt_node ($df1), $df1;

  is $df1->owner_document, $doc2, "unchanged";
  is $el1->content, $df1;

  my $el2 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  is $el2->content->owner_document, $doc2;

  done $c;
} n => 4, name => 'adopt template content';

test {
  my $c = shift;

  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df1 = $el1->content;

  my $doc2 = $df1->owner_document;
  my $el2 = $doc2->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  $df1->append_child ($el2);
  my $df2 = $el2->content;
  my $doc3 = $df2->owner_document;
  is $doc3, $doc2;

  my $doc4 = new Web::DOM::Document;
  is $doc4->adopt_node ($el2), $el2;

  is $el2->owner_document, $doc4;
  isnt $df2->owner_document, $doc3;

  done $c;
} n => 4, name => 'adopt nested template element';

test {
  my $c = shift;

  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df1 = $el1->content;

  my $doc2 = $df1->owner_document;
  my $el2 = $doc2->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  $df1->append_child ($el2);
  my $df2 = $el2->content;
  my $doc3 = $df2->owner_document;
  is $doc3, $doc2;

  my $doc4 = new Web::DOM::Document;
  is $doc4->adopt_node ($df2), $df2;

  is $el2->content, $df2;
  is $df2->owner_document, $doc3, "unchanged";
  is $doc2->create_element_ns ('http://www.w3.org/1999/xhtml', 'template')->content->owner_document, $doc3;

  done $c;
} n => 5, name => 'adopt nested template content';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df1 = $el1->content;
  my $doc2 = $df1->owner_document;

  is $doc1->adopt_node ($df1), $df1;

  is $df1->owner_document, $doc2, "unchanged";
  is $el1->content, $df1;

  is $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template')->content->owner_document, $doc2;

  done $c;
} n => 4, name => 'adopt template content to document of host';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df1 = $el1->content;
  my $doc2 = $df1->owner_document;
  my $el2 = $doc2->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  $df1->append_child ($el2);
  my $df2 = $el2->content;
  my $doc3 = $df2->owner_document;
  is $doc3, $doc2;

  is $doc1->adopt_node ($df1), $df1;

  is $df1->owner_document, $doc2;
  is $el1->content, $df1;
  is $el2->owner_document, $doc2;
  is $el2->content, $df2;
  is $df2->owner_document, $doc2;

  done $c;
} n => 7, name => 'adopt template content with nested template element to document of host';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df1 = $el1->content;
  my $doc2 = $df1->owner_document;
  isnt $doc2, $doc1;

  is $doc2->adopt_node ($el1), $el1;

  is $el1->owner_document, $doc2;
  is $el1->content, $df1;

  is $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template')->content->owner_document, $doc2;

  done $c;
} n => 5, name => 'adopt host element to template content document';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df1 = $el1->content;
  my $doc2 = $df1->owner_document;
  my $el2 = $df1->owner_document->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  $df1->append_child ($el2);
  my $df2 = $el2->content;
  my $el3 = $df2->owner_document->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  $df2->append_child ($el3);
  my $df3 = $el3->content;

  my $doc4 = new Web::DOM::Document;
  is $doc4->adopt_node ($el1), $el1;

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
} n => 10, name => 'adopt multiple nested templates';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $el1 = $doc1->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $df1 = $el1->content;
  my $doc2 = $df1->owner_document;
  my $el2 = $df1->owner_document->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  $df1->append_child ($el2);
  my $df2 = $el2->content;
  my $el3 = $df2->owner_document->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  $df2->append_child ($el3);
  my $df3 = $el3->content;
  my $doc6 = new Web::DOM::Document;
  $doc6->adopt_node ($df2);
  $doc1->adopt_node ($df3);

  my $doc4 = new Web::DOM::Document;
  is $doc4->adopt_node ($el1), $el1;

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
} n => 10, name => 'adopt multiple nested templates with multiple docs';

for my $method (qw(append_child insert_before replace_child)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
    my $df = $el->content;
    my $el2 = $df->owner_document->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
    $df->append_child ($el2);
    my @ref = $method eq 'append_child' ? () : ($el2);

    dies_here_ok {
      $df->$method ($el, @ref);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'The child is a host-including inclusive ancestor of the parent';

    is $df->first_child, $el2;
    is $df->last_child, $el2;
    is $el2->parent_node, $df;
    is $el->parent_node, undef;
    isnt $el->owner_document, $df->owner_document;

    done $c;
  } n => 9, name => ['template content # template element', $method];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el0 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'p');
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
    $el0->append_child ($el);
    my $df = $el->content;
    my $el2 = $df->owner_document->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
    $df->append_child ($el2);
    my @ref = $method eq 'append_child' ? () : ($el2);

    dies_here_ok {
      $df->$method ($el0, @ref);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'The child is a host-including inclusive ancestor of the parent';

    is $df->first_child, $el2;
    is $df->last_child, $el2;
    is $el2->parent_node, $df;
    is $el->parent_node, $el0;
    is $el0->parent_node, undef;
    isnt $el0->owner_document, $df->owner_document;

    done $c;
  } n => 10, name => ['template content # parent of template element', $method];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el0 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'p');
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
    $el0->append_child ($el);
    my $df = $el->content;
    my $el2 = $df->owner_document->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
    $df->append_child ($el2);
    my $el3 = $df->owner_document->create_element_ns ('http://www.w3.org/1999/xhtml', 'fuga');
    $el2->append_child ($el3);
    my @ref = $method eq 'append_child' ? () : ($el3);

    dies_here_ok {
      $el2->$method ($el0, @ref);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'The child is a host-including inclusive ancestor of the parent';

    is $el2->first_child, $el3;
    is $el2->last_child, $el3;
    is $el2->parent_node, $df;
    is $el3->parent_node, $el2;
    is $el->parent_node, $el0;
    is $el0->parent_node, undef;
    isnt $el0->owner_document, $df->owner_document;

    done $c;
  } n => 11, name => ['child of template content # parent of template element', $method];

  test {
    my $c = shift;
    my $doc0 = new Web::DOM::Document;
    my $el0 = $doc0->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
    my $doc = $el0->content->owner_document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
    my $df = $el->content;
    my $el2 = $df->owner_document->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
    $df->append_child ($el2);
    my @ref = $method eq 'append_child' ? () : ($el2);

    dies_here_ok {
      $df->$method ($el, @ref);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'The child is a host-including inclusive ancestor of the parent';

    is $df->first_child, $el2;
    is $df->last_child, $el2;
    is $el2->parent_node, $df;
    is $el->parent_node, undef;
    is $el->owner_document, $df->owner_document;

    done $c;
  } n => 9, name => ['template content # template element, in template document', $method];

  test {
    my $c = shift;
    my $doc0 = new Web::DOM::Document;
    my $el0 = $doc0->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
    my $doc = $el0->content->owner_document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
    $el0->content->append_child ($el);
    my $df = $el->content;
    my $el2 = $df->owner_document->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
    $df->append_child ($el2);
    my @ref = $method eq 'append_child' ? () : ($el2);

    dies_here_ok {
      $df->$method ($el0, @ref);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'The child is a host-including inclusive ancestor of the parent';

    is $df->first_child, $el2;
    is $df->last_child, $el2;
    is $el2->parent_node, $df;
    is $el0->parent_node, undef;
    isnt $el0->owner_document, $df->owner_document;

    done $c;
  } n => 9, name => ['template content # template element, indirect', $method];
}

for my $method (qw(clone_node import_node)) {
  for my $deep (0, 1) {
    test {
      my $c = shift;
      my $doc = new Web::DOM::Document;
      my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
      my $df = $el->content;
      my $doc2 = new Web::DOM::Document;
      my $doc3 = $method eq 'clone_node' ? $df->owner_document : $doc2->create_element_ns ('http://www.w3.org/1999/xhtml', 'template')->content->owner_document;
      my $clone = $method eq 'clone_node' ? $el->clone_node ($deep) : $doc2->import_node ($el, $deep);
      isnt $clone, $el;
      isa_ok $clone, 'Web::DOM::Element';
      is $clone->namespace_uri, $el->namespace_uri;
      is $clone->local_name, $el->local_name;
      is $clone->first_child, undef;
      isnt $clone->content, $df;
      isa_ok $clone->content, 'Web::DOM::DocumentFragment';
      is $clone->content->owner_document, $doc3;
      is $clone->content->first_child, undef;
      done $c;
    } n => 9, name => ['empty template content', $method, $deep];
  }

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
    my $df = $el->content;
    my $el2 = $df->owner_document->create_element_ns ('http://www.w3.org/1999/xhtml', 'p');
    $df->append_child ($el2);
    my $doc2 = new Web::DOM::Document;
    my $doc3 = $method eq 'clone_node' ? $df->owner_document : $doc2->create_element_ns ('http://www.w3.org/1999/xhtml', 'template')->content->owner_document;
    my $clone = $method eq 'clone_node' ? $el->clone_node : $doc2->import_node ($el);
    isnt $clone, $el;
    isa_ok $clone, 'Web::DOM::Element';
    is $clone->namespace_uri, $el->namespace_uri;
    is $clone->local_name, $el->local_name;
    is $clone->first_child, undef;
    isnt $clone->content, $df;
    isa_ok $clone->content, 'Web::DOM::DocumentFragment';
    is $clone->content->owner_document, $doc3;
    is $clone->content->first_child, undef;
    done $c;
  } n => 9, name => ['non-empty template content, not deep', $method];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
    my $df = $el->content;
    my $el2 = $df->owner_document->create_element_ns ('http://www.w3.org/1999/xhtml', 'p');
    $df->append_child ($el2);
    $df->owner_document->strict_error_checking (0);
    my $el3 = $df->owner_document->create_element_ns (undef, ['ho:ge', 'aa']);
    $df->owner_document->strict_error_checking (1);
    $el2->append_child ($el3);
    my $doc2 = new Web::DOM::Document;
    my $doc3 = $method eq 'clone_node' ? $df->owner_document : $doc2->create_element_ns ('http://www.w3.org/1999/xhtml', 'template')->content->owner_document;
    my $clone = $method eq 'clone_node' ? $el->clone_node (1) : $doc2->import_node ($el, 1);
    isnt $clone, $el;
    isa_ok $clone, 'Web::DOM::Element';
    is $clone->namespace_uri, $el->namespace_uri;
    is $clone->local_name, $el->local_name;
    is $clone->first_child, undef;
    isnt $clone->content, $df;
    isa_ok $clone->content, 'Web::DOM::DocumentFragment';
    is $clone->content->owner_document, $doc3;
    ok $clone->content->owner_document->strict_error_checking;
    my $clone2 = $clone->content->first_child;
    isa_ok $clone2, 'Web::DOM::Element';
    is $clone2->namespace_uri, $el2->namespace_uri;
    is $clone2->local_name, $el2->local_name;
    is $clone2->child_nodes->length, 1;
    my $clone3 = $clone->content->first_child->first_child;
    isa_ok $clone2, 'Web::DOM::Element';
    is $clone3->namespace_uri, $el3->namespace_uri;
    is $clone3->local_name, $el3->local_name;
    is $clone3->first_child, undef;
    done $c;
  } n => 17, name => ['non-empty template content, deep', $method];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
    my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'p');
    my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'q');
    $el->content->append_child ($el1);
    $el->append_child ($el2);

    my $doc2 = new Web::DOM::Document;
    my $clone = $method eq 'clone_node' ? $el->clone_node (1) : $doc2->import_node ($el, 1);

    is $clone->content->child_nodes->length, 1;
    is $clone->content->first_child->local_name, 'p';

    is $clone->child_nodes->length, 1;
    is $clone->first_child->local_name, 'q';

    done $c;
  } n => 4, name => ['content and template content, deep', $method];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  is $el->manakai_append_content ('hoge'), undef;
  is $el->content->child_nodes->length, 1;
  is $el->content->first_child->node_type, 3;
  is $el->content->first_child->data, 'hoge';
  done $c;
} n => 4, name => 'manakai_append_content text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $obj = {};
  is $el->manakai_append_content ($obj), undef;
  is $el->content->child_nodes->length, 1;
  is $el->content->first_child->node_type, 3;
  is $el->content->first_child->data, ''.$obj;
  done $c;
} n => 4, name => 'manakai_append_content non-node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $child = $doc->create_text_node ('hoge');
  is $el->manakai_append_content ($child), undef;
  is $child->parent_node, $el->content;
  is $el->content->child_nodes->length, 1;
  is $el->content->first_child, $child;
  done $c;
} n => 4, name => 'manakai_append_content text node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $child = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  is $el->manakai_append_content ($child), undef;
  is $child->parent_node, $el->content;
  is $el->content->child_nodes->length, 1;
  is $el->content->first_child, $child;
  done $c;
} n => 4, name => 'manakai_append_content element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');
  my $child = $doc->create_attribute ('hoge');
  dies_here_ok {
    $el->manakai_append_content ($child);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  done $c;
} n => 3, name => 'manakai_append_content bad';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
