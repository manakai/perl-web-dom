use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;
use Web::DOM::NodeFilter;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ni = $doc->create_node_iterator ($doc);
  is $ni->reference_node, $doc;
  ok $ni->pointer_before_reference_node;

  is $ni->next_node, $doc;
  is $ni->reference_node, $doc;
  ok not $ni->pointer_before_reference_node;
  is $ni->next_node, undef;
  is $ni->reference_node, $doc;
  ok not $ni->pointer_before_reference_node;
  is $ni->next_node, undef;
  is $ni->reference_node, $doc;
  ok not $ni->pointer_before_reference_node;
  is $ni->previous_node, $doc;
  is $ni->reference_node, $doc;
  ok $ni->pointer_before_reference_node;
  is $ni->previous_node, undef;
  is $ni->reference_node, $doc;
  ok $ni->pointer_before_reference_node;
  is $ni->previous_node, undef;
  is $ni->reference_node, $doc;
  ok $ni->pointer_before_reference_node;
  is $ni->previous_node, undef;
  is $ni->reference_node, $doc;
  ok $ni->pointer_before_reference_node;
  is $ni->next_node, $doc;
  is $ni->reference_node, $doc;
  ok not $ni->pointer_before_reference_node;

  done $c;
} n => 26, name => 'document node only';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ni = $doc->create_node_iterator ($doc);
  is $ni->reference_node, $doc;

  my $node1 = $doc->create_element ('aa');
  my $node2 = $doc->create_element ('ab');
  my $node3 = $doc->create_comment ('aa');
  $doc->append_child ($node1);
  $node1->append_child ($node2);
  $doc->append_child ($node3);

  is $ni->next_node, $doc;
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->previous_node, $node2;
  is $ni->previous_node, $node1;
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;
  is $ni->next_node, undef;
  is $ni->next_node, undef;
  is $ni->previous_node, $node3;
  is $ni->previous_node, $node2;
  
  done $c;
} n => 13, name => 'nodes';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ni = $doc->create_node_iterator ($doc);
  is $ni->reference_node, $doc;

  is $ni->next_node, $doc;
  is $ni->next_node, undef;

  my $node1 = $doc->create_element ('aa');
  my $node2 = $doc->create_element ('ab');
  my $node3 = $doc->create_comment ('aa');
  $doc->append_child ($node1);
  $node1->append_child ($node2);
  $doc->append_child ($node3);

  is $ni->next_node, $node1;
  is $ni->previous_node, $node1;
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;
  is $ni->next_node, undef;
  is $ni->next_node, undef;
  is $ni->previous_node, $node3;
  is $ni->previous_node, $node2;
  
  done $c;
} n => 12, name => 'append nodes';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $ni = $doc->create_node_iterator ($doc);
  is $ni->reference_node, $doc;

  is $ni->next_node, $doc;
  is $ni->next_node, undef;

  my $node1 = $doc->create_element ('aa');
  my $node2 = $doc->create_element ('ab');
  my $node3 = $doc->create_comment ('aa');
  $doc->append_child ($node1);
  $node1->append_child ($node2);
  $doc->append_child ($node3);

  is $ni->previous_node, $doc;
  is $ni->previous_node, undef;
  is $ni->previous_node, undef;
  is $ni->next_node, $doc;
  is $ni->next_node, $node1;
  
  done $c;
} n => 8, name => 'append nodes';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('hoge');
  my $node3 = $doc->create_element ('hoge');
  my $node4 = $doc->create_element ('hoge');
  my $node5 = $doc->create_element ('hoge');
  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node3->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;
  is $ni->next_node, $node4;
  is $ni->next_node, $node5;
  is $ni->next_node, undef;
  is $ni->previous_node, $node5;
  is $ni->previous_node, $node4;
  is $ni->previous_node, $node3;
  is $ni->previous_node, $node2;
  is $ni->previous_node, $node1;
  is $ni->previous_node, undef;
  is $ni->next_node, $node1;
  is $ni->previous_node, $node1;
  is $ni->reference_node, $node1;

  done $c;
} n => 15;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('hoge');
  my $node3 = $doc->create_element ('hoge');
  my $node4 = $doc->create_element ('hoge');
  my $node5 = $doc->create_element ('hoge');
  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node3->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;
  is $ni->reference_node, $node3;
  ok not $ni->pointer_before_reference_node;

  $node1->remove_child ($node3);
  
  is $ni->reference_node, $node2, 'reference_node after removal';
  is $ni->next_node, $node5, 'next_node after removal';
  is $ni->reference_node, $node5;
  is $ni->previous_node, $node5;
  is $ni->previous_node, $node2;

  done $c;
} n => 10, name => 'reference node is removed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('hoge');
  my $node3 = $doc->create_element ('hoge');
  my $node4 = $doc->create_element ('hoge');
  my $node5 = $doc->create_element ('hoge');
  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node3->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;
  is $ni->next_node, $node4;
  is $ni->reference_node, $node4;
  ok not $ni->pointer_before_reference_node;

  $node1->remove_child ($node3);
  
  is $ni->reference_node, $node2, 'reference_node after removal';
  is $ni->next_node, $node5, 'next_node after removal';
  is $ni->reference_node, $node5;
  is $ni->previous_node, $node5;
  is $ni->previous_node, $node2;

  done $c;
} n => 11, name => 'reference node is removed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('hoge');
  my $node3 = $doc->create_element ('hoge');
  my $node4 = $doc->create_element ('hoge');
  my $node5 = $doc->create_element ('hoge');
  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node3->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;
  is $ni->next_node, $node4;
  is $ni->next_node, $node5;
  is $ni->reference_node, $node5;
  ok not $ni->pointer_before_reference_node;

  $node1->remove_child ($node5);
  
  is $ni->reference_node, $node4, 'reference_node after removal';
  is $ni->next_node, undef, 'next_node after removal';
  is $ni->reference_node, $node4;
  is $ni->previous_node, $node4;
  is $ni->previous_node, $node3;

  done $c;
} n => 12, name => 'reference node is removed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('hoge');
  my $node3 = $doc->create_element ('hoge');
  my $node4 = $doc->create_element ('hoge');
  my $node5 = $doc->create_element ('hoge');
  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node3->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;
  is $ni->next_node, $node4;
  is $ni->next_node, $node5;
  is $ni->previous_node, $node5;
  is $ni->previous_node, $node4;
  is $ni->reference_node, $node4;
  ok $ni->pointer_before_reference_node;

  $node1->remove_child ($node3);
  
  is $ni->reference_node, $node5, 'reference_node after removal';
  is $ni->previous_node, $node2, 'previous_node after removal';
  is $ni->reference_node, $node2;
  is $ni->previous_node, $node1;

  done $c;
} n => 13, name => 'reference node is removed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('hoge');
  my $node3 = $doc->create_element ('hoge');
  my $node4 = $doc->create_element ('hoge');
  my $node5 = $doc->create_element ('hoge');
  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node3->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;
  is $ni->next_node, $node4;
  is $ni->next_node, $node5;
  is $ni->previous_node, $node5;
  is $ni->reference_node, $node5;
  ok $ni->pointer_before_reference_node;

  $node1->remove_child ($node5);
  
  is $ni->reference_node, $node4, 'reference_node after removal';
  ok not $ni->pointer_before_reference_node;
  is $ni->previous_node, $node4, 'previous_node after removal';
  is $ni->reference_node, $node4;
  is $ni->previous_node, $node3;

  done $c;
} n => 13, name => 'reference node is removed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('hoge');
  my $node3 = $doc->create_element ('hoge');
  my $node4 = $doc->create_element ('hoge');
  my $node5 = $doc->create_text_node ('hoge');
  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node3->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;
  is $ni->next_node, $node4;
  is $ni->next_node, $node5;
  is $ni->previous_node, $node5;
  is $ni->reference_node, $node5;
  ok $ni->pointer_before_reference_node;

  $node1->remove_child ($node5);
  
  is $ni->reference_node, $node4, 'reference_node after removal';
  ok not $ni->pointer_before_reference_node;
  is $ni->previous_node, $node4, 'previous_node after removal';
  is $ni->reference_node, $node4;
  is $ni->previous_node, $node3;

  done $c;
} n => 13, name => 'reference node is removed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node0 = $doc->create_element ('foo');
  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('hoge');
  my $node3 = $doc->create_element ('hoge');
  my $node4 = $doc->create_element ('hoge');
  my $node5 = $doc->create_text_node ('hoge');
  $node0->append_child ($node1);
  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node3->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;
  is $ni->next_node, $node4;
  is $ni->next_node, $node5;
  is $ni->previous_node, $node5;
  is $ni->reference_node, $node5;
  ok $ni->pointer_before_reference_node;

  $node0->remove_child ($node1);
  
  is $ni->reference_node, $node5;
  ok $ni->pointer_before_reference_node;
  ok $ni->next_node, undef;
  ok not $ni->pointer_before_reference_node;

  done $c;
} n => 12, name => 'root node is removed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node01 = $doc->create_element ('foo');
  my $node0 = $doc->create_element ('foo');
  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('hoge');
  my $node3 = $doc->create_element ('hoge');
  my $node4 = $doc->create_element ('hoge');
  my $node5 = $doc->create_text_node ('hoge');
  $node01->append_child ($node0);
  $node0->append_child ($node1);
  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node3->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;
  is $ni->next_node, $node4;
  is $ni->next_node, $node5;
  is $ni->previous_node, $node5;
  is $ni->reference_node, $node5;
  ok $ni->pointer_before_reference_node;

  $node01->remove_child ($node0);
  
  is $ni->reference_node, $node5;
  ok $ni->pointer_before_reference_node;
  ok $ni->next_node, undef;
  ok not $ni->pointer_before_reference_node;

  done $c;
} n => 12, name => 'ancestor of root node is removed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_text_node ('foo');
  my $node3 = $doc->create_text_node ('foo');
  my $node4 = $doc->create_text_node ('foo');
  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node1->append_child ($node4);

  my $ni = $doc->create_node_iterator ($node1);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;

  $node1->text_content ('abc');

  is $ni->reference_node, $node1;
  ok not $ni->pointer_before_reference_node;

  done $c;
} n => 5, name => 'reference node removed (remove_children)';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_text_node ('foo');
  my $node3 = $doc->create_text_node ('foo');
  my $node4 = $doc->create_text_node ('foo');
  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node1->append_child ($node4);

  my $ni = $doc->create_node_iterator ($node1);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;
  is $ni->next_node, $node4;

  $node1->text_content ('abc');

  is $ni->reference_node, $node1;
  ok not $ni->pointer_before_reference_node;

  done $c;
} n => 6, name => 'reference node removed (remove_children)';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('foo');
  my $node3 = $doc->create_text_node ('foo');
  my $node4 = $doc->create_text_node ('foo');
  my $node5 = $doc->create_text_node ('foo');
  $node1->append_child ($node2);
  $node2->append_child ($node3);
  $node2->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;

  $node2->text_content ('abc');

  is $ni->reference_node, $node2;
  ok not $ni->pointer_before_reference_node;

  done $c;
} n => 5, name => 'reference node removed (remove_children)';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('foo');
  my $node3 = $doc->create_text_node ('foo');
  my $node4 = $doc->create_text_node ('foo');
  my $node5 = $doc->create_text_node ('foo');
  $node1->append_child ($node2);
  $node2->append_child ($node3);
  $node2->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;
  is $ni->next_node, $node4;
  is $ni->next_node, $node5;
  is $ni->previous_node, $node5;
  is $ni->previous_node, $node4;

  $node2->text_content ('abc');

  is $ni->reference_node, $node5;
  ok $ni->pointer_before_reference_node;

  done $c;
} n => 9, name => 'reference node removed (remove_children)';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('foo');
  my $node3 = $doc->create_text_node ('foo');
  my $node4 = $doc->create_text_node ('foo');
  my $node5 = $doc->create_text_node ('foo');
  $node1->append_child ($node2);
  $node2->append_child ($node3);
  $node2->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;
  is $ni->next_node, $node4;
  is $ni->next_node, $node5;
  is $ni->previous_node, $node5;
  is $ni->previous_node, $node4;

  $node1->text_content ('abc');

  is $ni->reference_node, $node1;
  ok not $ni->pointer_before_reference_node;

  done $c;
} n => 9, name => 'reference node removed (remove_children)';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('hoge');
  my $node3 = $doc->create_element ('hoge');
  my $node4 = $doc->create_element ('hoge');
  my $node5 = $doc->create_text_node ('hoge');
  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node3->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;
  is $ni->next_node, $node4;
  is $ni->next_node, $node5;
  is $ni->previous_node, $node5;
  is $ni->reference_node, $node5;
  ok $ni->pointer_before_reference_node;

  my $doc2 = new Web::DOM::Document;
  $doc2->adopt_node ($node5);
  
  is $ni->reference_node, $node4, 'reference_node after removal';
  ok not $ni->pointer_before_reference_node;
  is $ni->previous_node, $node4, 'previous_node after removal';
  is $ni->reference_node, $node4;
  is $ni->previous_node, $node3;

  done $c;
} n => 13, name => 'reference node is removed by adopt';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('hoge');
  my $node3 = $doc->create_element ('hoge');
  my $node4 = $doc->create_element ('hoge');
  my $node5 = $doc->create_text_node ('hoge');
  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node3->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;

  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('AA') for 1..rand 10;

  $doc2->adopt_node ($node1);

  is $ni->next_node, $node3;
  is $ni->previous_node, $node3;

  $node1->remove_child ($node3);

  is $ni->next_node, $node5;
  is $ni->previous_node, $node5;
  is $ni->previous_node, $node2;

  done $c;
} n => 7, name => 'root node adopted';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('hoge');
  my $node3 = $doc->create_element ('hoge');
  my $node4 = $doc->create_comment ('hoge');
  my $node5 = $doc->create_text_node ('hoge');
  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node3->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1, 0x11);
  is $ni->next_node, $node1;
  is $ni->next_node, $node2;
  is $ni->next_node, $node3;
  is $ni->next_node, undef;
  is $ni->reference_node, $node3;
  is $ni->previous_node, $node3;
  is $ni->previous_node, $node2;
  is $ni->previous_node, $node1;
  is $ni->previous_node, undef;
  is $ni->what_to_show, 0x11;
  is $ni->filter, undef;
  ok not $ni->expand_entity_references;

  done $c;
} n => 12, name => 'what_to_show';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('hoge');
  my $node3 = $doc->create_element ('hoge');
  my $node4 = $doc->create_comment ('hoge');
  my $node5 = $doc->create_text_node ('hoge');
  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node3->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1, undef, my $code = sub {
    return $_[1]->node_name =~ /\#/ ? FILTER_ACCEPT : 521251512;
  });
  is $ni->next_node, $node4;
  is $ni->next_node, $node5;
  is $ni->next_node, undef;
  is $ni->reference_node, $node5;
  is $ni->previous_node, $node5;
  is $ni->previous_node, $node4;
  is $ni->previous_node, undef;
  is $ni->what_to_show, 0xFFFFFFFF;
  is $ni->filter, $code;

  done $c;
} n => 9, name => 'filter';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('hoge');
  my $node2 = $doc->create_element ('hoge');
  my $node3 = $doc->create_element ('hoge');
  my $node4 = $doc->create_comment ('hoge');
  my $node5 = $doc->create_text_node ('hoge');
  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node3->append_child ($node4);
  $node1->append_child ($node5);

  my $ni = $doc->create_node_iterator ($node1, 0x1, my $code = sub {
    return $_[1]->node_name =~ /\#/ ? FILTER_ACCEPT : 521251512;
  });
  is $ni->next_node, undef;
  is $ni->reference_node, $node1;
  is $ni->previous_node, undef;
  is $ni->what_to_show, 0x1;
  is $ni->filter, $code;

  done $c;
} n => 5, name => 'filter empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('nb7a');
  $doc->append_child ($el);
  my $tw = $doc->create_node_iterator ($doc, undef, sub {
    die "hoge";
  });
  dies_ok {
    $tw->next_node;
  };
  like $@, qr{^hoge at };
  is $tw->reference_node, $doc;
  done $c;
} n => 3, name => 'nodefilter exception, next_node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('nb7a');
  $doc->append_child ($el);
  my $flag;
  my $tw = $doc->create_node_iterator ($doc, undef, sub {
    $flag ? die "hoge" : FILTER_ACCEPT;
  });
  $tw->next_node;
  $flag = 1;
  dies_ok {
    $tw->previous_node;
  };
  like $@, qr{^hoge at };
  is $tw->reference_node, $doc;
  done $c;
} n => 3, name => 'nodefilter exception, previous_node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  my $el3 = $doc->create_element ('a');
  my $el4 = $doc->create_element ('a');
  $el1->append_child ($el2);
  $el1->append_child ($el3);
  $el1->append_child ($el4);
  my $tw = $doc->create_node_iterator ($el1, 0, sub { 1 });
  is $tw->next_node, undef;
  is $tw->next_node, undef;
  is $tw->previous_node, undef;
  done $c;
} n => 3, name => 'what_to_show 0';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  my $el3 = $doc->create_element ('a');
  my $el4 = $doc->create_element ('a');
  $el1->append_child ($el2);
  $el1->append_child ($el3);
  $el1->append_child ($el4);
  my $tw; $tw = $doc->create_node_iterator ($el1, undef, sub {
    $tw->next_node;
    ok 0;
  });
  dies_ok {
    $tw->next_node;
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidStateError';
  is $@->message, 'Traversaler is active';
  is $tw->reference_node, $el1;
  done $c;
  undef $tw;
} n => 5, name => 'nodeiterator exception';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  my $el3 = $doc->create_element ('a');
  my $el4 = $doc->create_element ('a');
  $el1->append_child ($el2);
  $el1->append_child ($el3);
  $el1->append_child ($el4);
  my $tw; $tw = $doc->create_node_iterator ($el1, undef, sub {
    dies_here_ok {
      $tw->next_node;
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'InvalidStateError';
    is $@->message, 'Traversaler is active';
    return 1;
  });
  is $tw->next_node, $el1;
  is $tw->reference_node, $el1;
  done $c;
  undef $tw;
} n => 6, name => 'nodeiterator exception';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
