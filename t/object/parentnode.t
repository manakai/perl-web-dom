use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::Differences;
use Test::DOM::Exception;
use Web::DOM::Document;

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc,
    $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a'),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      is $node->first_element_child, undef;
      is $node->last_element_child, undef;
      is $node->child_element_count, 0;
      done $c;
    } n => 3, name => ['element_child', $node->node_type, 'empty'];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc,
    $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a'),
    $doc->create_document_fragment,
  ) {
    my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
    $node->append_child ($el1);
    test {
      my $c = shift;
      is $node->first_element_child, $el1;
      is $node->last_element_child, $el1;
      is $node->child_element_count, 1;
      done $c;
    } n => 3, name => ['element_child', $node->node_type, 'a child'];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a'),
    $doc->create_document_fragment,
  ) {
    my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
    my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
    $node->append_child ($el1);
    $node->append_child ($el2);
    test {
      my $c = shift;
      is $node->first_element_child, $el1;
      is $node->last_element_child, $el2;
      is $node->child_element_count, 2;
      done $c;
    } n => 3, name => ['element_child', $node->node_type, 'two element children'];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a'),
    $doc->create_document_fragment,
  ) {
    my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
    my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
    $node->append_child ($doc->create_text_node ('x'));
    $node->append_child ($el1);
    $node->append_child ($doc->create_text_node ('x'));
    $node->append_child ($el2);
    $node->append_child ($doc->create_comment ('x'));
    test {
      my $c = shift;
      is $node->first_element_child, $el1;
      is $node->last_element_child, $el2;
      is $node->child_element_count, 2;
      done $c;
    } n => 3, name => ['element_child', $node->node_type, 'two element children with garbages'];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc,
    $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a'),
    $doc->create_document_fragment,
  ) {
    my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
    $node->append_child ($doc->create_comment ('x'));
    $node->append_child ($el1);
    $node->append_child ($doc->create_processing_instruction ('x', ''));
    $node->append_child ($doc->create_comment ('x'));
    test {
      my $c = shift;
      is $node->first_element_child, $el1;
      is $node->last_element_child, $el1;
      is $node->child_element_count, 1;
      done $c;
    } n => 3, name => ['element_child', $node->node_type, 'a element child with garbages'];
  }
}

{
  package test::DestroyCallback;
  sub DESTROY {
    $_[0]->();
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->implementation->create_document,
    $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a'),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      my $called;
      $node->set_user_data (destroy => bless sub {
                              $called = 1;
                            }, 'test::DestroyCallback');
      
      my $col = $node->children;
      isa_ok $col, 'Web::DOM::HTMLCollection';
      ok not $col->isa ('Web::DOM::NodeList');
      
      is $col->length, 0;
      is scalar @$col, 0;

      undef $node;
      ok not $called;
      
      undef $col;
      ok $called;
      
      done $c;
    } n => 6, name => ['children empty', $node->node_type];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->implementation->create_document,
    $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a'),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      my $doc = new Web::DOM::Document;
      my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
      my $called;
      $node->set_user_data (destroy => bless sub {
                              $called = 1;
                            }, 'test::DestroyCallback');

      my $el1 = $doc->create_comment ('a');
      my $el2 = $doc->create_processing_instruction ('b', '');
      my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
      my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
      $node->append_child ($el1);
      $node->append_child ($el2);
      $node->append_child ($el3);
      $el3->append_child ($el4);

      my $col = $node->children;
      isa_ok $col, 'Web::DOM::HTMLCollection';
      ok not $col->isa ('Web::DOM::NodeList');
      
      is $col->length, 1;
      is scalar @$col, 1;

      is $col->[0], $el3;
      is $col->[1], undef;

      undef $node;
      undef $el1;
      undef $el2;
      undef $el3;
      undef $el4;
      ok not $called;

      is $col->[0]->parent_node->children, $col;
      isnt $col->[0]->parent_node->child_nodes, $col;

      undef $col;
      ok $called;
      
      done $c;
    } n => 10, name => ['children has children', $node->node_type];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a'),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      my $doc = new Web::DOM::Document;
      my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
      my $called;
      $node->set_user_data (destroy => bless sub {
                              $called = 1;
                            }, 'test::DestroyCallback');

      my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
      my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b', '');
      my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
      my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
      $node->append_child ($el1);
      $node->append_child ($el2);
      $node->append_child ($el3);
      $el3->append_child ($el4);

      my $col = $node->children;
      isa_ok $col, 'Web::DOM::HTMLCollection';
      ok not $col->isa ('Web::DOM::NodeList');
      
      is $col->length, 3;
      is scalar @$col, 3;

      is $col->[0], $el1;
      is $col->[1], $el2;
      is $col->[2], $el3;
      is $col->[3], undef;

      undef $node;
      undef $el1;
      undef $el2;
      undef $el3;
      undef $el4;
      ok not $called;

      is $col->[0]->parent_node->children, $col;
      isnt $col->[0]->parent_node->child_nodes, $col;

      undef $col;
      ok $called;
      
      done $c;
    } n => 12, name => ['children has children', $node->node_type];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->implementation->create_document,
    $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a'),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      my $col = $node->get_elements_by_tag_name ('*');
      isa_ok $col, 'Web::DOM::HTMLCollection';
      is scalar @$col, 0;
      is $col->length, 0;
      is $col->[0], undef;
      done $c;
    } n => 4, name => ['get_elements_by_tag_name * empty', $node->node_type];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->implementation->create_document,
    $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a'),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      my $doc = $node->owner_document || $node;
      my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
      $node->append_child ($el1);
      my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b');
      $el1->append_child ($el2);
      my $text1 = $doc->create_text_node ('c');
      $el1->append_child ($text1);
      my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'd');
      $el1->append_child ($el3);
      my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e');
      $el1->append_child ($el4);
      my $col = $node->get_elements_by_tag_name ('*');
      isa_ok $col, 'Web::DOM::HTMLCollection';
      is scalar @$col, 4;
      is $col->length, 4;
      is $col->[0], $el1;
      is $col->[1], $el2;
      is $col->[2], $el3;
      is $col->[3], $el4;
      is $col->[4], undef;
      done $c;
    } n => 8, name => ['get_elements_by_tag_name * not empty', $node->node_type];
  }
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $cl1 = $doc->get_elements_by_tag_name ('*');
  my $cl2 = $doc->get_elements_by_tag_name ('*');

  ok $cl1 eq $cl2;
  ok not $cl1 ne $cl2;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');

  my $cl3 = $node->get_elements_by_tag_name ('*');
  my $cl4 = $node->get_elements_by_tag_name ('*');
  
  ok $cl1 ne $cl3;
  ok not $cl1 eq $cl3;
  ok $cl3 eq $cl4;
  ok not $cl3 ne $cl4;
  
  done $c;
} n => 6, name => 'get_elements_by_tag_name * eq';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $col = $node->get_elements_by_tag_name ('*');

  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  $node->append_child ($el1);

  is $col->length, 1;

  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b');
  $el1->append_child ($el2);

  is $col->length, 2;

  my $el3 = $doc->create_text_node ('c');
  $el2->append_child ($el3);

  is $col->length, 2;

  $node->remove_child ($el1);
  
  is $col->length, 0;

  done $c;
} n => 4, name => 'get_elements_by_tag_name * descendant mutation';

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->implementation->create_document,
    $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a'),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      my $col = $node->get_elements_by_tag_name ('ab');
      isa_ok $col, 'Web::DOM::HTMLCollection';
      is scalar @$col, 0;
      is $col->length, 0;
      is $col->[0], undef;
      done $c;
    } n => 4, name => ['get_elements_by_tag_name ln empty', $node->node_type];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->implementation->create_document,
    $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a'),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      $doc = $node->owner_document || $node;
      my $el0 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'x');
      my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'f');
      my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ab');
      my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ab');
      $node->append_child ($el0);
      $el0->append_child ($el1);
      $el0->append_child ($el2);
      $el1->append_child ($el3);

      my $col = $node->get_elements_by_tag_name ('ab');
      isa_ok $col, 'Web::DOM::HTMLCollection';
      is scalar @$col, 2;
      is $col->length, 2;
      is $col->[0], $el3;
      is $col->[1], $el2;
      done $c;
    } n => 5, name => ['get_elements_by_tag_name ln not empty', $node->node_type];
  }
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aab');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aAb');
  my $el3 = $doc->create_element_ns (undef, 'AAB');
  my $el4 = $doc->create_element_ns ('http://hoge/', 'aab');
  my $el5 = $doc->create_element_ns ('http://hoge/', 'x:aab');

  $doc->append_child ($el1);
  $el1->append_child ($el2);
  $el1->append_child ($el3);
  $el1->append_child ($el4);
  $el1->append_child ($el5);

  my $col1 = $doc->get_elements_by_tag_name ('aab');
  is scalar @$col1, 2;
  is $col1->[0], $el1;
  is $col1->[1], $el4;

  my $col2 = $doc->get_elements_by_tag_name ('aAb');
  is scalar @$col2, 1;
  is $col2->[0], $el2;

  my $col3 = $doc->get_elements_by_tag_name ('AAB');
  is scalar @$col3, 1;
  is $col3->[0], $el3;

  my $col4 = $doc->get_elements_by_tag_name ('AAb');
  is scalar @$col4, 0;

  my $col5 = $doc->get_elements_by_tag_name ('x:aab');
  is scalar @$col5, 1;
  is $col5->[0], $el5;

  done $c;
} n => 10, name => 'get_elements_by_tag_name xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);

  my $el1 = $doc->create_element ('aab');
  my $el2 = $doc->create_element ('aAb');
  my $el3 = $doc->create_element_ns (undef, 'AAB');
  my $el4 = $doc->create_element_ns ('http://hoge/', 'aab');
  my $el5 = $doc->create_element_ns ('http://hoge/', 'x:aab');

  $doc->append_child ($el1);
  $el1->append_child ($el2);
  $el1->append_child ($el3);
  $el1->append_child ($el4);
  $el1->append_child ($el5);

  my $col1 = $doc->get_elements_by_tag_name ('aab');
  is scalar @$col1, 3;
  is $col1->[0], $el1;
  is $col1->[1], $el2;
  is $col1->[2], $el4;

  my $col2 = $doc->get_elements_by_tag_name ('aAb');
  is scalar @$col2, 2;
  is $col2->[0], $el1;
  is $col2->[1], $el2;

  my $col3 = $doc->get_elements_by_tag_name ('AAB');
  is scalar @$col3, 3;
  is $col3->[0], $el1;
  is $col3->[1], $el2;
  is $col3->[2], $el3;

  my $col4 = $doc->get_elements_by_tag_name ('AAb');
  is scalar @$col4, 2;
  is $col4->[0], $el1;
  is $col4->[1], $el2;

  my $col5 = $doc->get_elements_by_tag_name ('x:aab');
  is scalar @$col5, 1;
  is $col5->[0], $el5;

  done $c;
} n => 16, name => 'get_elements_by_tag_name html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el0 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'f');
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'AbC');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'abc');
  my $el3 = $doc->create_element_ns (undef, 'abc');
  my $el4 = $doc->create_element_ns (undef, 'abC');
  $el0->append_child ($el1);
  $el0->append_child ($el2);
  $el0->append_child ($el3);
  $el0->append_child ($el4);

  my $col1 = $el0->get_elements_by_tag_name ('abc');
  is $col1->length, 2;
  is $col1->[0], $el2;
  is $col1->[1], $el3;

  my $col2 = $el0->get_elements_by_tag_name ('AbC');
  is $col2->length, 1;
  is $col2->[0], $el1;

  my $col3 = $el0->get_elements_by_tag_name ('abC');
  is $col3->length, 1;
  is $col3->[0], $el4;

  $doc->manakai_is_html (1);

  is $col1->length, 2;
  is $col1->[0], $el2;
  is $col1->[1], $el3;

  is $col2->length, 1;
  is $col2->[0], $el2;

  is $col3->length, 2;
  is $col3->[0], $el2;
  is $col3->[1], $el4;

  $doc->manakai_is_html (0);

  is $col1->length, 2;
  is $col1->[0], $el2;
  is $col1->[1], $el3;

  is $col2->length, 1;
  is $col2->[0], $el1;

  is $col3->length, 1;
  is $col3->[0], $el4;
  
  done $c;
} n => 22, name => 'get_elements_by_tag_name html vs xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'p');
  $el->append_child ($el2);

  my $col1 = $el->get_elements_by_tag_name ('p');
  my $col2 = $el->get_elements_by_tag_name ('p');
  is $col2, $col1;

  my $doc2 = new Web::DOM::Document;
  $doc2->adopt_node ($el);

  my $col3 = $el->get_elements_by_tag_name ('p');
  my $col4 = $el->get_elements_by_tag_name ('p');
  is $col3, $col2;
  is $col4, $col3;
  is $col1->[0], $el2;
  is $col3->[0], $el2;

  my $el3 = $doc2->create_element_ns ('http://www.w3.org/1999/xhtml', 'p');
  $el->append_child ($el3);
  is $col1->[1], $el3;
  is $col3->[1], $el3;

  $doc->adopt_node ($el);

  my $col5 = $el->get_elements_by_tag_name ('p');
  is $col5, $col2;

  done $c;
} n => 8, name => 'get_elements_by_tag_name reuse';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'p');
  $el->append_child ($el2);

  my $col1 = $el->get_elements_by_tag_name ('p');
  my $col2 = $el->get_elements_by_tag_name ('p');
  is $col2, $col1;

  my $doc2 = new Web::DOM::Document;
  $doc2->manakai_is_html (1);
  $doc2->adopt_node ($el);

  my $col3 = $el->get_elements_by_tag_name ('p');
  my $col4 = $el->get_elements_by_tag_name ('p');
  isnt $col3, $col2;
  is $col4, $col3;
  is $col1->[0], $el2;
  is $col3->[0], $el2;

  my $el3 = $doc2->create_element_ns ('http://www.w3.org/1999/xhtml', 'p');
  $el->append_child ($el3);
  is $col1->[1], $el3;
  is $col3->[1], $el3;

  $doc->adopt_node ($el);

  my $col5 = $el->get_elements_by_tag_name ('p');
  is $col5, $col2;

  done $c;
} n => 8, name => 'get_elements_by_tag_name reuse';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $col1 = $node->get_elements_by_tag_name_ns ('*', '*');
  isa_ok $col1, 'Web::DOM::HTMLCollection';

  is $col1->length, 0;
  
  done $c;
} n => 2, name => 'get_elements_by_tag_name_ns * * empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b');
  my $text1 = $doc->create_text_node ('c');
  my $el2 = $doc->create_element_ns (undef, 'f');
  my $el3 = $doc->create_element_ns ('hoge', 'a:f');
  $node->append_child ($el1);
  $el1->append_child ($text1);
  $el1->append_child ($el2);
  $el1->append_child ($el3);

  my $col1 = $node->get_elements_by_tag_name_ns ('*', '*');
  isa_ok $col1, 'Web::DOM::HTMLCollection';

  is $col1->length, 3;
  is $col1->[0], $el1;
  is $col1->[1], $el2;
  is $col1->[2], $el3;
  
  done $c;
} n => 5, name => 'get_elements_by_tag_name_ns * * not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b');
  my $text1 = $doc->create_text_node ('c');
  my $el2 = $doc->create_element_ns (undef, 'f');
  my $el3 = $doc->create_element_ns ('hoge', 'a:f');
  $node->append_child ($el1);
  $el1->append_child ($text1);
  $el1->append_child ($el2);
  $el1->append_child ($el3);

  my $col1 = $node->get_elements_by_tag_name_ns ('*', 'f');
  isa_ok $col1, 'Web::DOM::HTMLCollection';

  is $col1->length, 2;
  is $col1->[0], $el2;
  is $col1->[1], $el3;
  
  done $c;
} n => 4, name => 'get_elements_by_tag_name_ns * ln not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b');
  my $text1 = $doc->create_text_node ('c');
  my $el2 = $doc->create_element_ns (undef, 'f');
  my $el3 = $doc->create_element_ns ('hoge', 'a:f');
  my $el4 = $doc->create_element_ns ('hoge', 'ga');
  $node->append_child ($el1);
  $el1->append_child ($text1);
  $el1->append_child ($el2);
  $el1->append_child ($el3);
  $el1->append_child ($el4);

  my $col1 = $node->get_elements_by_tag_name_ns ('hoge', '*');
  isa_ok $col1, 'Web::DOM::HTMLCollection';

  is $col1->length, 2;
  is $col1->[0], $el3;
  is $col1->[1], $el4;
  
  done $c;
} n => 4, name => 'get_elements_by_tag_name_ns ns * not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'cd');
  my $text1 = $doc->create_text_node ('c');
  my $el2 = $doc->create_element_ns (undef, 'c');
  my $el3 = $doc->create_element_ns ('hoge', 'a:c');
  my $el4 = $doc->create_element_ns ('hoge', 'ga');
  $node->append_child ($el1);
  $el1->append_child ($text1);
  $el1->append_child ($el2);
  $el1->append_child ($el3);
  $el1->append_child ($el4);

  my $col1 = $node->get_elements_by_tag_name_ns ('*', 'c');
  isa_ok $col1, 'Web::DOM::HTMLCollection';

  is $col1->length, 2;
  is $col1->[0], $el2;
  is $col1->[1], $el3;
  
  done $c;
} n => 4, name => 'get_elements_by_tag_name_ns ns ln not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'cd');
  my $text1 = $doc->create_text_node ('c');
  my $el2 = $doc->create_element_ns (undef, 'c');
  my $el3 = $doc->create_element_ns ('hoge', 'a:c');
  my $el4 = $doc->create_element_ns ('hoge', 'ga');
  $node->append_child ($el1);
  $el1->append_child ($text1);
  $el1->append_child ($el2);
  $el1->append_child ($el3);
  $el1->append_child ($el4);

  my $col1 = $node->get_elements_by_tag_name_ns (undef, 'c');
  isa_ok $col1, 'Web::DOM::HTMLCollection';

  is $col1->length, 1;
  is $col1->[0], $el2;
  
  done $c;
} n => 3, name => 'get_elements_by_tag_name_ns null ln not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'cd');
  my $text1 = $doc->create_text_node ('c');
  my $el2 = $doc->create_element_ns (undef, 'c');
  my $el3 = $doc->create_element_ns ('hoge', 'a:c');
  my $el4 = $doc->create_element_ns ('hoge', 'ga');
  $node->append_child ($el1);
  $el1->append_child ($text1);
  $el1->append_child ($el2);
  $el1->append_child ($el3);
  $el1->append_child ($el4);

  my $col1 = $node->get_elements_by_tag_name_ns ('', 'c');
  isa_ok $col1, 'Web::DOM::HTMLCollection';

  is $col1->length, 1;
  is $col1->[0], $el2;
  
  done $c;
} n => 3, name => 'get_elements_by_tag_name_ns empty ln not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'A');
  $node->append_child ($el1);
  $node->append_child ($el2);

  my $col1 = $node->get_elements_by_tag_name_ns ('*', 'A');
  is $col1->length, 1;
  is $col1->[0], $el2;

  $doc->manakai_is_html (1);

  is $col1->length, 1;
  is $col1->[0], $el2;

  done $c;
} n => 4, name => 'get_elements_by_tag_name case sensitivity';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $col1 = $doc->get_elements_by_tag_name_ns ('*', '*');
  my $col2 = $doc->get_elements_by_tag_name ('*');
  my $col3 = $doc->get_elements_by_tag_name_ns ('*', '*');
  my $col4 = $doc->get_elements_by_tag_name_ns ('', 'abc');
  my $col5 = $doc->get_elements_by_tag_name_ns (undef, 'abc');
  my $col6 = $doc->get_elements_by_tag_name_ns (undef, 'ABC');
  my $col7 = $doc->get_elements_by_tag_name_ns ('def', 'ABC');
  is $col1, $col1;
  isnt $col1, $col2;
  is $col1, $col3;
  isnt $col3, $col4;
  is $col4, $col5;
  isnt $col5, $col6;
  isnt $col6, $col7;
  done $c;
} n => 7, name => 'get_elements_by_tag_name_ns equality';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $col1 = $doc->get_elements_by_tag_name_ns (undef, 'a');
  is $col1->length, 0;

  my $node1 = $doc->create_element_ns (undef, 'a');
  $doc->append_child ($node1);

  is $col1->length, 1;

  done $c;
} n => 2, name => 'get_elements_by_tag_name_ns mutation';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');

  my $col1 = $el1->get_elements_by_class_name ('fuga');
  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 0;

  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fyuga');
  $el2->class_name ('fuga abc');
  $el1->append_child ($el2);

  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fyuga');
  $el3->class_name ('Fuga abc');
  $el1->append_child ($el3);

  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fyuga');
  $el4->class_name ('fuga abc');
  $el3->append_child ($el4);

  is $col1->length, 2;
  is $col1->[0], $el2;
  is $col1->[1], $el4;

  $el1->remove_child ($el2);

  is $col1->length, 1;
  is $col1->[0], $el4;

  done $c;
} n => 7, name => 'get_elements_by_class_name a class';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');

  my $col1 = $el1->get_elements_by_class_name ('fuga fuga  ');
  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 0;

  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fyuga');
  $el2->class_name ('fuga abc');
  $el1->append_child ($el2);

  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fyuga');
  $el3->class_name ('Fuga abc');
  $el1->append_child ($el3);

  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fyuga');
  $el4->class_name ('fuga abc');
  $el3->append_child ($el4);

  is $col1->length, 2;
  is $col1->[0], $el2;
  is $col1->[1], $el4;

  $el1->remove_child ($el2);

  is $col1->length, 1;
  is $col1->[0], $el4;

  done $c;
} n => 7, name => 'get_elements_by_class_name a class';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');

  my $col1 = $el1->get_elements_by_class_name ('fuga abc ');
  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 0;

  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fyuga');
  $el2->class_name ('fuga abc');
  $el1->append_child ($el2);

  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fyuga');
  $el3->class_name ('Fuga abc');
  $el1->append_child ($el3);

  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fyuga');
  $el4->class_name ('fuga abcd');
  $el3->append_child ($el4);

  is $col1->length, 1;
  is $col1->[0], $el2;

  $el1->remove_child ($el2);

  is $col1->length, 0;

  $el4->class_list->add ('abc');

  is $col1->length, 1;
  is $col1->[0], $el4;

  done $c;
} n => 7, name => 'get_elements_by_class_name two classes';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  
  my $col1 = $el->get_elements_by_class_name ('  ');
  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 0;

  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ff');
  $el2->set_attribute (class => '  ');
  $el->append_child ($el2);

  is $col1->length, 0;

  done $c;
} n => 3, name => 'get_elements_by_class_name empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $doc->append_child ($el1);

  my $col1 = $doc->get_elements_by_class_name ('fuga abc ');
  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 0;

  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fyuga');
  $el2->class_name ('fuga abc');
  $el1->append_child ($el2);

  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fyuga');
  $el3->class_name ('Fuga abc');
  $el1->append_child ($el3);

  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fyuga');
  $el4->class_name ('fuga abcd');
  $el3->append_child ($el4);

  is $col1->length, 1;
  is $col1->[0], $el2;

  $el1->remove_child ($el2);

  is $col1->length, 0;

  $el4->class_list->add ('abc');

  is $col1->length, 1;
  is $col1->[0], $el4;

  done $c;
} n => 7, name => 'get_elements_by_class_name two classes document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_document_fragment;

  my $col1 = $el1->get_elements_by_class_name ('fuga abc ');
  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 0;

  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fyuga');
  $el2->class_name ('fuga abc');
  $el1->append_child ($el2);

  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fyuga');
  $el3->class_name ('Fuga abc');
  $el1->append_child ($el3);

  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fyuga');
  $el4->class_name ('fuga abcd');
  $el3->append_child ($el4);

  is $col1->length, 1;
  is $col1->[0], $el2;

  $el1->remove_child ($el2);

  is $col1->length, 0;

  $el4->class_list->add ('abc');

  is $col1->length, 1;
  is $col1->[0], $el4;

  done $c;
} n => 7, name => 'get_elements_by_class_name two classes df';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  $doc->manakai_compat_mode ('quirks');

  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'bar');
  $el1->append_child ($el2);
  $el2->class_name ('hOGe');

  my $col1 = $el1->get_elements_by_class_name ('HoGe');
  is $col1->length, 1;

  $doc->manakai_compat_mode ('limited quirks');

  is $col1->length, 0;

  done $c;
} n => 2, name => 'get_elements_by_class_name quirksness';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  $doc->manakai_compat_mode ('quirks');

  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'bar');
  $doc->append_child ($el1);
  $el1->append_child ($el2);
  $el2->class_name ('hOGe');

  my $col1 = $doc->get_elements_by_class_name ('HoGe');
  is $col1->length, 1;

  $doc->manakai_compat_mode ('no quirks');

  is $col1->length, 0;

  done $c;
} n => 2, name => 'get_elements_by_class_name quirksness document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  $doc->manakai_compat_mode ('quirks');

  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'bar');
  $doc->append_child ($el1);
  $el1->append_child ($el2);
  $el2->class_name ('hOGe');

  my $col1 = $doc->get_elements_by_class_name ('HoGe');
  is $col1->length, 1;

  $doc->manakai_is_html (0);

  is $col1->length, 0;

  done $c;
} n => 2, name => 'get_elements_by_class_name quirksness df';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $col1 = $doc->get_elements_by_class_name ('hoge');
  my $col2 = $doc->get_elements_by_class_name ('hoge');
  is $col2, $col1;

  my $col3 = $doc->get_elements_by_class_name ('HOGE');
  isnt $col3, $col1;

  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  my $col4 = $el->get_elements_by_class_name ('hoge');
  isnt $col4, $col1;

  done $c;
} n => 3, name => 'get_elements_by_class_name equality';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  is $el->query_selector ('hoge'), undef;
  my $list = $el->query_selector_all ('hoge');
  isa_ok $list, 'Web::DOM::NodeList';
  is $list->length, 0;
  is_deeply [$list->to_list], [];
  is_deeply $list->to_a, [];
  done $c;
} n => 5, name => 'query_selector, query_selector_all empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 't');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  $el->append_child ($el2);
  $el->append_child ($el3);
  $el3->append_child ($el4);
  is $el->query_selector ('hoge'), undef;
  is $el->query_selector ('ss'), $el2;
  my $list = $el->query_selector_all ('ss');
  isa_ok $list, 'Web::DOM::NodeList';
  is $list->length, 2;
  is_deeply [$list->to_list], [$el2, $el4];
  is_deeply $list->to_a, [$el2, $el4];
  is $el->query_selector (':nth-child(2) ss'), $el4;
  is $el->query_selector (':nth-child(2) ss hoge'), undef;
  done $c;
} n => 8, name => 'query_selector, query_selector_all not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_document_fragment;
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 't');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  $el->append_child ($el2);
  $el->append_child ($el3);
  $el3->append_child ($el4);
  is $el->query_selector ('hoge'), undef;
  is $el->query_selector ('ss'), $el2;
  my $list = $el->query_selector_all ('ss');
  isa_ok $list, 'Web::DOM::NodeList';
  is $list->length, 2;
  is_deeply [$list->to_list], [$el2, $el4];
  is_deeply $list->to_a, [$el2, $el4];
  is $el->query_selector (':nth-child(2) ss'), $el4;
  is $el->query_selector (':nth-child(2) ss hoge'), undef;
  done $c;
} n => 8, name => 'query_selector, query_selector_all document_fragment';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hge');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 't');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  $doc->append_child ($el);
  $el->append_child ($el2);
  $el->append_child ($el3);
  $el3->append_child ($el4);
  is $doc->query_selector ('hoge'), undef;
  is $doc->query_selector ('ss'), $el2;
  my $list = $doc->query_selector_all ('ss');
  isa_ok $list, 'Web::DOM::NodeList';
  is $list->length, 2;
  is_deeply [$list->to_list], [$el2, $el4];
  is_deeply $list->to_a, [$el2, $el4];
  is $doc->query_selector (':nth-child(2) ss'), $el4;
  is $doc->query_selector (':nth-child(2) ss hoge'), undef;
  done $c;
} n => 8, name => 'query_selector, query_selector_all document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 't');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  $el->append_child ($el2);
  $el->append_child ($el3);
  $el3->append_child ($el4);
  dies_here_ok {
    $el->query_selector ('hoge,');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The specified selectors has syntax error';
  dies_here_ok {
    $el->query_selector_all ('hoge,');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The specified selectors has syntax error';
  done $c;
} n => 8, name => 'query_selector, query_selector_all syntax error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 't');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  $el->append_child ($el2);
  $el->append_child ($el3);
  $el3->append_child ($el4);
  dies_here_ok {
    $el->query_selector ('fuga|hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The specified selectors has unresolvable namespace prefix |fuga|';
  dies_here_ok {
    $el->query_selector_all ('fuga|hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The specified selectors has unresolvable namespace prefix |fuga|';
  done $c;
} n => 8, name => 'query_selector, query_selector_all namespace error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 't');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  $el->append_child ($el2);
  $el->append_child ($el3);
  $el3->append_child ($el4);
  my $resolver = sub {
    my $prefix = $_[1] || '';
    if ($prefix eq 'html') {
      return 'http://www.w3.org/1999/xhtml';
    } elsif ($prefix eq 'svg') {
      return 'http://www.w3.org/2000/svg';
    } else {
      return undef;
    }
  };
  is $el->query_selector ('html|ss', $resolver), $el2;
  dies_here_ok {
    $el->query_selector ('HTML|ss', $resolver);
  };
  is $@->name, 'NamespaceError';
  is $el->query_selector ('svg|ss', $resolver), undef;
  my $list = $el->query_selector_all ('html|ss', $resolver);
  isa_ok $list, 'Web::DOM::NodeList';
  is $list->length, 2;
  is $list->item (0), $el2;
  is $list->[1], $el4;
  my $list2 = $el->query_selector_all ('svg|ss', $resolver);
  is $list2->length, 0;
  done $c;
} n => 9, name => 'query_selector, query_selector_all ns resolver';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 't');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ss');
  $el->append_child ($el2);
  $el->append_child ($el3);
  $el3->append_child ($el4);
  my $resolver = sub {
    return 'http://www.w3.org/1999/xhtml';
  };
  is $el->query_selector ('ss', $resolver), $el2;
  is $el->query_selector ('ss', sub { 'http://hoge/' }), undef;
  is $el->query_selector ('ss', sub { '' }), $el2;
  is $el->query_selector ('ss', sub { undef }), $el2;
  is $el->query_selector_all ('ss', $resolver)->length, 2;
  is $el->query_selector_all ('ss', sub { 'http://foo/' })->length, 0;
  is $el->query_selector_all ('ss', sub { '' })->length, 2;
  is $el->query_selector_all ('ss', sub { undef })->length, 2;
  done $c;
} n => 8, name => 'query_selector, query_selector_all ns resolver default';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->query_selector ('\30|abc');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The specified selectors has unresolvable namespace prefix |0|';
  done $c;
} n => 4, name => 'query_selector ns 0';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->query_selector_all ('\000030|abc');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The specified selectors has unresolvable namespace prefix |0|';
  done $c;
} n => 4, name => 'query_selector_all ns 0';

for my $method (qw(query_selector query_selector_all)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
    dies_here_ok {
      $el->$method ('aa', 'hoge');
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->message, 'The second argument is not an XPathNSResolver';
    done $c;
  } n => 3, name => [$method, 'nsresolver is not object'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
    dies_here_ok {
      $el->$method ('aa', $doc);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->message, 'The second argument is not an XPathNSResolver';
    done $c;
  } n => 3, name => [$method, 'nsresolver is not NSResolver'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aax');
    my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
    my $el3 = $doc->create_element_ns (undef, 'aa');
    $el->append_child ($el2);
    $el->append_child ($el3);
    my $el5 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
    $el5->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:foo' => $el2->namespace_uri);
    my $resolver = $doc->create_ns_resolver ($el5);
    my $el4 = $el->$method ('foo|aa', $resolver);
    if ($method eq 'query_selector') {
      is $el4, $el2;
    } else {
      is $el4->[0], $el2;
    }
    done $c;
  } n => 1, name => [$method, 'nsresolver is XPathNSResolver'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aax');
    my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
    my $el3 = $doc->create_element_ns (undef, 'aa');
    $el->append_child ($el2);
    $el->append_child ($el3);
    my $invoked = 0;
    my @self;
    my @prefix;
    my $resolver = sub {
      push @self, $_[0];
      push @prefix, $_[1];
      $invoked++;
      return 'http://www.w3.org/1999/xhtml';
    };
    my $el4 = $el->$method ('foo|aa, bar|aa', $resolver);
    if ($method eq 'query_selector') {
      is $el4, $el2;
    } else {
      is $el4->[0], $el2;
    }
    is $invoked, 3;
    eq_or_diff \@self, [$resolver, $resolver, $resolver];
    eq_or_diff \@prefix, ['', 'foo', 'bar'];
    done $c;
  } n => 4, name => [$method, 'nsresolver is code'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aax');
    my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
    my $el3 = $doc->create_element_ns (undef, 'aa');
    $el->append_child ($el2);
    $el->append_child ($el3);
    my $invoked = 0;
    my $resolver = sub {
      $invoked++;
      return $_[1] eq 'foo' ? 'http://www.w3.org/1999/xhtml' : undef;
    };
    dies_here_ok {
      $el->$method ('foo|aa, bar|aa', $resolver);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'NamespaceError';
    is $@->message, 'The specified selectors has unresolvable namespace prefix |bar|';
    is $invoked, 3;
    done $c;
  } n => 5, name => [$method, 'nsresolver is code nserror'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aax');
    my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
    my $el3 = $doc->create_element_ns (undef, 'aa');
    $el->append_child ($el2);
    $el->append_child ($el3);
    my $invoked = 0;
    my $resolver = sub {
      $invoked++;
      die "hoge";
    };
    dies_here_ok {
      $el->$method ('foo|aa, bar|aa', $resolver);
    };
    ok not ref $@;
    like $@, qr{^hoge at };
    is $invoked, 1;
    done $c;
  } n => 4, name => [$method, 'nsresolver is code exception'];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ff');
  my $nl1 = $el->query_selector_all ('hoge');
  is $nl1->length, 0;
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->append_child ($el2);
  my $nl2 = $el->query_selector_all ('hoge');
  is $nl1->length, 0;
  is $nl2->length, 1;
  isnt $nl2, $nl1;
  done $c;
} n => 4, name => 'query_selector_all nodelist equality';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b');
  $el->append_child ($el1);
  $el->append_child ($el2);

  is $el->query_selector ('b, a'), $el1;
  is $el->query_selector_all ('b, a')->[0], $el1;
  is $el->query_selector_all ('b, a')->[1], $el2;

  done $c;
} n => 3, name => 'query_selector, query_selector_all';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');

  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'p');
  $el->content->append_child ($el2);
  is $el->query_selector ('p'), undef;
  eq_or_diff $el->query_selector_all ('p')->to_a, [];

  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'p');
  $el->append_child ($el3);
  is $el->query_selector ('p'), $el3;
  eq_or_diff $el->query_selector_all ('p')->to_a, [$el3];

  done $c;
} n => 4, name => 'template content';

run_tests;

=head1 LICENSE

Copyright 2012-2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
