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
  my $node = $doc->create_element ('a');

  dies_here_ok {
    $node->replace_child (undef);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The first argument is not a Node';

  is scalar @{$node->child_nodes}, 0;
  
  done $c;
} n => 4, name => 'replace_child typeerror';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  my $node2 = $doc->create_element ('b');

  dies_here_ok {
    $node->replace_child ($node2, undef);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a Node';

  is scalar @{$node->child_nodes}, 0;
  
  done $c;
} n => 4, name => 'replace_child typeerror';

{
  my $doc = new Web::DOM::Document;
  for my $parent (
    $doc->create_text_node ('a'),
    $doc->create_comment ('b'),
    $doc->create_processing_instruction ('c'),
    $doc->implementation->create_document_type ('a', '', ''),
  ) {
    test {
      my $c = shift;
      my $doc = $parent->owner_document;
      my $node = $doc->create_element ('a');
      my $child = $doc->create_element ('a');
      dies_here_ok {
        $parent->replace_child ($child, $node);
      };
      isa_ok $@, 'Web::DOM::Exception';
      is $@->message, 'The parent node cannot have a child';
      is scalar @{$parent->child_nodes}, 0;
      is $child->parent_node, undef;
      is $node->parent_node, undef;
      done $c;
      undef $parent;
    } n => 6, name => [$parent->node_type, 'wrong parent'];
  }
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_text_node ('');
  my $node2 = $doc->create_element ('a');
  $doc->append_child ($node2);
  dies_here_ok {
    $doc->replace_child ($node1, $node2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document node cannot contain this kind of node';
  is scalar @{$doc->child_nodes}, 1;
  is $doc->first_child, $node2;
  is $node1->parent_node, undef;
  done $c;
  undef $c;
} n => 7, name => 'replace_child doc>text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $parent = $doc->create_element ('b');
  my $node1 = $doc->implementation->create_document_type ('f', '', '');
  my $node2 = $doc->create_element ('a');
  $parent->append_child ($node2);
  dies_here_ok {
    $parent->replace_child ($node1, $node2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document type cannot be contained by this kind of node';
  is scalar @{$parent->child_nodes}, 1;
  is $parent->first_child, $node2;
  is $node1->parent_node, undef;
  done $c;
  undef $c;
} n => 7, name => 'replace_child nondoc>dt';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_processing_instruction ('a', 'b');
  $doc->append_child ($node);
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  $df->append_child ($el1);
  $df->append_child ($el2);
  dies_here_ok {
    $doc->replace_child ($df, $node);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document node cannot have two element children';
  is scalar @{$doc->child_nodes}, 1;
  is $node->parent_node, $doc;
  is scalar @{$df->child_nodes}, 2;
  is $el1->parent_node, $df;
  is $el2->parent_node, $df;
  done $c;
} n => 9, name => 'doc > df > two elements';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_comment ('a');
  $doc->append_child ($node);
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_text_node ('b');
  $df->append_child ($el1);
  $df->append_child ($el2);
  dies_here_ok {
    $doc->replace_child ($df, $node);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document node cannot contain this kind of node';
  is scalar @{$doc->child_nodes}, 1;
  is $node->parent_node, $doc;
  is scalar @{$df->child_nodes}, 2;
  is $el1->parent_node, $df;
  is $el2->parent_node, $df;
  done $c;
} n => 9, name => 'doc > df > text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_comment ('c');
  $doc->append_child ($node);
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  $doc->append_child ($el1);
  $df->append_child ($el2);
  dies_here_ok {
    $doc->replace_child ($df, $node);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document node cannot have two element children';
  is scalar @{$doc->child_nodes}, 2;
  is scalar @{$df->child_nodes}, 1;
  is $node->parent_node, $doc;
  is $el1->parent_node, $doc;
  is $el2->parent_node, $df;
  done $c;
} n => 9, name => 'doc > el + doc > df > el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  $doc->append_child ($el1);
  $df->append_child ($el2);
  $doc->replace_child ($df, $el1);
  is scalar @{$doc->child_nodes}, 1;
  is scalar @{$df->child_nodes}, 0;
  is $el1->parent_node, undef;
  is $el2->parent_node, $doc;
  done $c;
} n => 4, name => 'doc > el replaced by df > el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_comment ('a');
  my $el2 = $doc->create_element ('b');
  my $dt = $doc->implementation->create_document_type ('a', '', '');
  $doc->append_child ($el1);
  $doc->append_child ($dt);
  $df->append_child ($el2);
  dies_here_ok {
    $doc->replace_child ($df, $el1);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Element cannot precede the document type';
  is scalar @{$doc->child_nodes}, 2;
  is scalar @{$df->child_nodes}, 1;
  is $el1->parent_node, $doc;
  is $dt->parent_node, $doc;
  is $el2->parent_node, $df;
  done $c;
} n => 9, name => 'doc > node~dt + doc > df > el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_comment ('a');
  my $el2 = $doc->create_element ('b');
  my $dt = $doc->implementation->create_document_type ('a', '', '');
  $doc->append_child ($dt);
  $doc->append_child ($el1);
  $df->append_child ($el2);
  $doc->replace_child ($df, $el1);
  is scalar @{$doc->child_nodes}, 2;
  is scalar @{$df->child_nodes}, 0;
  is $el1->parent_node, undef;
  is $dt->parent_node, $doc;
  is $el2->parent_node, $doc;
  done $c;
} n => 5, name => 'doc > dt~node + doc > df > el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_comment ('a');
  my $el2 = $doc->create_element ('b');
  my $dt = $doc->implementation->create_document_type ('a', '', '');
  $doc->append_child ($dt);
  $doc->append_child ($el1);
  $df->append_child ($el2);
  $doc->replace_child ($df, $dt);
  is scalar @{$doc->child_nodes}, 2;
  is scalar @{$df->child_nodes}, 0;
  is $el1->parent_node, $doc;
  is $dt->parent_node, undef;
  is $el2->parent_node, $doc;
  done $c;
} n => 5, name => 'doc > dt~node + doc > df > el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->create_element ('b');
  my $dc2 = $doc->create_comment ('c');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  my $node = $doc->create_element ('a');
  dies_here_ok {
    $doc->replace_child ($node, $dc2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document node cannot have two element children';
  is scalar @{$doc->child_nodes}, 2;
  is $dc1->parent_node, $doc;
  is $dc2->parent_node, $doc;
  is $node->parent_node, undef;
  done $c;
} n => 8, name => 'doc > el + el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->create_element ('b');
  my $dc2 = $doc->create_comment ('c');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  my $node = $doc->create_element ('a');
  $doc->replace_child ($node, $dc1);
  is scalar @{$doc->child_nodes}, 2;
  is $dc1->parent_node, undef;
  is $dc2->parent_node, $doc;
  is $node->parent_node, $doc;
  done $c;
} n => 4, name => 'doc > el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->create_comment ('b');
  my $dc2 = $doc->create_comment ('c');
  my $dc3 = $doc->implementation->create_document_type ('f', '', '');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  $doc->append_child ($dc3);
  my $node = $doc->create_element ('a');
  dies_here_ok {
    $doc->replace_child ($node, $dc2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Element cannot precede the document type';
  is scalar @{$doc->child_nodes}, 3;
  is $dc1->parent_node, $doc;
  is $dc2->parent_node, $doc;
  is $dc3->parent_node, $doc;
  is $node->parent_node, undef;
  done $c;
} n => 9, name => 'doc > el + dt';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->implementation->create_document_type ('b', '', '');
  my $dc2 = $doc->create_comment ('c');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  my $node = $doc->create_element ('a');
  $doc->replace_child ($node, $dc2);
  is scalar @{$doc->child_nodes}, 2;
  is $dc1->parent_node, $doc;
  is $dc2->parent_node, undef;
  is $node->parent_node, $doc;
  done $c;
} n => 4, name => 'doc > el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->create_comment ('c');
  my $dc2 = $doc->implementation->create_document_type ('b', '', '');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  my $node = $doc->create_element ('a');
  $doc->replace_child ($node, $dc2);
  is scalar @{$doc->child_nodes}, 2;
  is $dc1->parent_node, $doc;
  is $dc2->parent_node, undef;
  is $node->parent_node, $doc;
  done $c;
} n => 4, name => 'doc > el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->implementation->create_document_type ('b', '', '');
  my $dc2 = $doc->create_comment ('c');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  my $node = $doc->implementation->create_document_type ('a', '', '');
  dies_here_ok {
    $doc->replace_child ($node, $dc2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document node cannot have two doctype children';
  is scalar @{$doc->child_nodes}, 2;
  is $dc1->parent_node, $doc;
  is $dc2->parent_node, $doc;
  is $node->parent_node, undef;
  done $c;
} n => 8, name => 'doc > dt + dt';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->implementation->create_document_type ('b', '', '');
  my $dc2 = $doc->create_comment ('c');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  my $node = $doc->implementation->create_document_type ('a', '', '');
  $doc->replace_child ($node, $dc1);
  is scalar @{$doc->child_nodes}, 2;
  is $dc1->parent_node, undef;
  is $dc2->parent_node, $doc;
  is $node->parent_node, $doc;
  done $c;
} n => 4, name => 'doc > dt';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->create_element ('c');
  my $dc2 = $doc->create_comment ('');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  my $node = $doc->implementation->create_document_type ('a', '', '');
  dies_here_ok {
    $doc->replace_child ($node, $dc2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Element cannot precede the document type';
  is scalar @{$doc->child_nodes}, 2;
  is $dc1->parent_node, $doc;
  is $dc2->parent_node, $doc;
  is $node->parent_node, undef;
  done $c;
} n => 8, name => 'doc > dt + dt';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->create_comment ('c');
  my $dc2 = $doc->create_element ('f');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  my $node = $doc->implementation->create_document_type ('a', '', '');
  $doc->replace_child ($node, $dc1);
  is scalar @{$doc->child_nodes}, 2;
  is $dc1->parent_node, undef;
  is $dc2->parent_node, $doc;
  is $node->parent_node, $doc;
  done $c;
} n => 4, name => 'doc > dt';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('A');
  my $el1 = $doc->create_element ('b');
  my $el2 = $doc->create_element ('c');
  $node->append_child ($el1);
  
  $node->replace_child ($el2, $el1);

  is scalar @{$node->child_nodes}, 1;
  is $el1->parent_node, undef;
  is $el2->parent_node, $node;

  is $$node->[0]->{tree_id}->[$$node->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];
  isnt $$node->[0]->{tree_id}->[$$node->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];

  done $c;
} n => 5, name => 'replace only child';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('A');
  my $el1 = $doc->create_element ('b');
  my $el2 = $doc->create_element ('c');
  my $el3 = $doc->create_element ('c');
  $node->append_child ($el1);
  $node->append_child ($el2);
  
  $node->replace_child ($el3, $el1);

  is scalar @{$node->child_nodes}, 2;
  is $el1->parent_node, undef;
  is $el2->parent_node, $node;
  is $el3->parent_node, $node;
  is $node->first_child, $el3;
  is $node->last_child, $el2;

  is $$node->[0]->{tree_id}->[$$node->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];
  is $$node->[0]->{tree_id}->[$$node->[1]],
      $$el3->[0]->{tree_id}->[$$el3->[1]];
  isnt $$node->[0]->{tree_id}->[$$node->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];

  done $c;
} n => 9, name => 'replace a child';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('A');
  my $el1 = $doc->create_element ('b');
  my $el2 = $doc->create_element ('c');
  my $el3 = $doc->create_element ('c');
  $node->append_child ($el1);
  $node->append_child ($el2);
  
  $node->replace_child ($el3, $el2);

  is scalar @{$node->child_nodes}, 2;
  is $el1->parent_node, $node;
  is $el2->parent_node, undef;
  is $el3->parent_node, $node;
  is $node->first_child, $el1;
  is $node->last_child, $el3;

  is $$node->[0]->{tree_id}->[$$node->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];
  is $$node->[0]->{tree_id}->[$$node->[1]],
      $$el3->[0]->{tree_id}->[$$el3->[1]];
  isnt $$node->[0]->{tree_id}->[$$node->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];

  done $c;
} n => 9, name => 'replace a child';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $node2 = $doc->create_element ('b');
  my $el1 = $doc->create_element ('c');
  my $el2 = $doc->create_element ('d');
  $node1->append_child ($el1);
  $node2->append_child ($el2);

  $node1->replace_child ($el2, $el1);

  is scalar @{$node1->child_nodes}, 1;
  is scalar @{$node2->child_nodes}, 0;

  is $node1->first_child, $el2;
  is $el1->parent_node, undef;
  is $el2->parent_node, $node1;

  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];
  isnt $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];
  isnt $$node2->[0]->{tree_id}->[$$node2->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];

  done $c;
} n => 8, name => 'replace - node moved';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $el1 = $doc->create_element ('f');
  my $el2 = $doc->create_element ('h');
  $node1->append_child ($el1);
  $node1->append_child ($el2);
  
  $node1->replace_child ($el2, $el1);

  is scalar @{$node1->child_nodes}, 1;
  is $node1->first_child, $el2;
  is $el1->parent_node, undef;
  is $el2->parent_node, $node1;

  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];
  isnt $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];

  done $c;
} n => 6, name => 'replace sibling';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $el1 = $doc->create_element ('f');
  my $el2 = $doc->create_element ('h');
  $node1->append_child ($el2);
  $node1->append_child ($el1);
  
  $node1->replace_child ($el2, $el1);

  is scalar @{$node1->child_nodes}, 1;
  is $node1->first_child, $el2;
  is $el1->parent_node, undef;
  is $el2->parent_node, $node1;

  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];
  isnt $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];

  done $c;
} n => 6, name => 'replace sibling';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $el1 = $doc->create_element ('f');
  my $el2 = $doc->create_element ('h');
  my $el3 = $doc->create_element ('h');
  my $el4 = $doc->create_element ('h');
  $node1->append_child ($el3);
  $node1->append_child ($el2);
  $node1->append_child ($el4);
  $node1->append_child ($el1);
  
  $node1->replace_child ($el2, $el1);

  is scalar @{$node1->child_nodes}, 3;
  is $node1->first_child, $el3;
  is $node1->last_child, $el2;
  is $el1->parent_node, undef;
  is $el2->parent_node, $node1;
  is $el3->parent_node, $node1;
  is $el4->parent_node, $node1;

  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];
  isnt $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];

  done $c;
} n => 9, name => 'replace sibling';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('f');
  my $el1 = $doc->create_element ('x');
  $node1->append_child ($el1);

  $node1->replace_child ($el1, $el1);

  is scalar @{$node1->child_nodes}, 1;
  is $node1->first_child, $el1;
  is $el1->parent_node, $node1;

  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];
  
  done $c;
} n => 4, name => 'replace itself';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('f');
  my $el1 = $doc->create_element ('b');
  my $el2 = $doc->create_element ('g');
  $node1->append_child ($el1);
  $el1->append_child ($el2);

  $node1->replace_child ($el2, $el1);
  
  is scalar @{$node1->child_nodes}, 1;
  is $node1->first_child, $el2;
  is $el2->parent_node, $node1;
  is $el1->parent_node, undef;
  done $c;
} n => 4, name => 'replace parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('c');
  my $el3 = $doc->create_element ('d');
  $node1->append_child ($el1);
  $df->append_child ($el2);
  $df->append_child ($el3);
  
  $node1->replace_child ($df, $el1);

  is scalar @{$node1->child_nodes}, 2;
  is $node1->first_child, $el2;
  is $node1->last_child, $el3;
  is scalar @{$df->child_nodes}, 0;

  is $el1->parent_node, undef;
  is $el2->parent_node, $node1;
  is $el3->parent_node, $node1;

  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];
  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el3->[0]->{tree_id}->[$$el3->[1]];
  isnt $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$df->[0]->{tree_id}->[$$df->[1]];
  isnt $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];

  done $c;
} n => 11, name => 'replace by df';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('c');
  my $el3 = $doc->create_element ('d');
  my $el4 = $doc->create_element ('d');
  my $el5 = $doc->create_element ('d');
  $node1->append_child ($el4);
  $node1->append_child ($el1);
  $node1->append_child ($el5);
  $df->append_child ($el2);
  $df->append_child ($el3);
  
  $node1->replace_child ($df, $el1);

  is scalar @{$node1->child_nodes}, 4;
  is $node1->first_child, $el4;
  is $node1->last_child, $el5;
  is scalar @{$df->child_nodes}, 0;

  is $el1->parent_node, undef;
  is $el2->parent_node, $node1;
  is $el3->parent_node, $node1;
  is $el4->parent_node, $node1;
  is $el5->parent_node, $node1;

  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];
  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el3->[0]->{tree_id}->[$$el3->[1]];
  isnt $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$df->[0]->{tree_id}->[$$df->[1]];
  isnt $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];

  done $c;
} n => 13, name => 'replace by df';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('c');
  my $el3 = $doc->create_element ('d');
  $df->append_child ($el1);
  $df->append_child ($el2);
  $df->append_child ($el3);
  
  dies_here_ok {
    $df->replace_child ($df, $el1);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The child is a host-including inclusive ancestor of the parent';

  is scalar @{$df->child_nodes}, 3;
  is $el1->parent_node, $df;
  is $el2->parent_node, $df;
  is $el3->parent_node, $df;

  done $c;
} n => 8, name => 'replace df by df';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $el1 = $doc->create_element ('b');
  my $el2 = $doc->create_element ('b');
  $node1->append_child ($el1);

  my $node2 = $node1->replace_child ($el2, $el1);
  isa_ok $node2, 'Web::DOM::Node';
  is $node2, $el2;

  done $c;
} n => 2, name => 'replace return';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $el1 = $doc->create_element ('b');
  my $el2 = $doc->create_element ('b');
  $node1->append_child ($el1);
  $node1->append_child ($el2);

  my $node2 = $node1->replace_child ($el2, $el2);
  isa_ok $node2, 'Web::DOM::Node';
  is $node2, $el2;

  done $c;
} n => 2, name => 'replace return';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $el1 = $doc->create_element ('b');
  my $el2 = $doc->create_element ('b');
  $node1->append_child ($el1);
  my $df = $doc->create_document_fragment;
  $df->append_child ($el2);

  my $node2 = $node1->replace_child ($df, $el1);
  isa_ok $node2, 'Web::DOM::Node';
  is $node2, $df;

  done $c;
} n => 2, name => 'replace return df';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  my $df = $doc->create_document_fragment;
  my $el3 = $doc->create_element ('a');
  my $el4 = $doc->create_element ('a');
  $el1->append_child ($el2);
  $df->append_child ($el3);
  $df->append_child ($el4);

  my $nl = $el1->child_nodes;
  is scalar @$nl, 1;
  my $cl = $el1->children;
  is scalar @$cl, 1;

  $el1->replace_child ($df, $el2);

  is scalar @$nl, 2;
  is scalar @$cl, 2;

  done $c;
} n => 4, name => 'replace_child parent child_nodes';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  my $el3 = $doc->create_element ('a');
  my $el4 = $doc->create_element ('a');
  $el1->append_child ($el2);
  $el4->append_child ($el3);

  dies_here_ok {
    $el1->replace_child ($el2, $el3);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'The reference child is not a child of the parent node';
  
  is $el1->first_child, $el2;
  is $el1->last_child, $el2;
  is $el2->parent_node, $el1;
  is $el3->parent_node, $el4;
  
  done $c;
} n => 8, name => 'replace_child ref child not found';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  my $el3 = $doc->create_element ('a');

  dies_here_ok {
    $el1->replace_child ($el2, $el3);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'The reference child is not a child of the parent node';
  
  is $el1->first_child, undef;
  is $el2->parent_node, undef;
  is $el3->parent_node, undef;
  
  done $c;
} n => 7, name => 'replace_child ref child no parent';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;

  my $el1 = $doc1->create_element ('b');
  my $el2 = $doc1->create_element ('c');
  my $el3 = $doc2->create_element ('d');
  $el1->append_child ($el2);

  my $el4 = $el1->replace_child ($el3, $el2);
  is $el4, $el3;

  is $el1->first_child, $el3;
  is $el3->parent_node, $el1;
  is $el2->parent_node, undef;

  is $el1->owner_document, $doc1;
  is $el2->owner_document, $doc1;
  is $el3->owner_document, $doc1;

  done $c;
} n => 7, name => 'replace_child diferent document';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;

  my $el1 = $doc1->create_element ('a');
  my $el2 = $doc1->create_element ('a');
  my $el3 = $doc2->create_element ('a');

  dies_here_ok {
    $el1->replace_child ($el2, $el3);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'The reference child is not a child of the parent node';

  is $el1->first_child, undef;
  is $el3->parent_node, undef;
  is $el2->parent_node, undef;

  is $el1->owner_document, $doc1;
  is $el2->owner_document, $doc1;
  is $el3->owner_document, $doc2;

  done $c;
} n => 10, name => 'replace_child ref is diferent document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $pi = $doc->create_processing_instruction ('hoge', 'fyuga');
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  $dt->append_child ($pi);
  $doc->dom_config->{manakai_allow_doctype_children} = 0;

  my $pi2 = $doc->create_processing_instruction ('hoge2', 'fyuga');
  dies_here_ok {
    $dt->replace_child ($pi2, $pi);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The parent node cannot have a child';

  is $dt->child_nodes->length, 1;
  is $dt->first_child, $pi;
  is $pi2->parent_node, undef;
  is $pi->parent_node, $dt;

  done $c;
} n => 8, name => 'dt > pi';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $pi = $doc->create_processing_instruction ('hoge', 'fyuga');
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  $dt->append_child ($pi);

  my $pi2 = $doc->create_processing_instruction ('hoge2', 'fyuga');
  my $pi3 = $dt->replace_child ($pi2, $pi);

  is $dt->child_nodes->length, 1;
  is $dt->first_child, $pi2;
  is $pi2->parent_node, $dt;
  is $pi->parent_node, undef;
  is $pi3, $pi2;

  done $c;
} n => 5, name => 'dt > pi allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $pi = $doc->create_processing_instruction ('hoge2', 'fyuga');
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  $dt->append_child ($pi);

  my $pi2 = $doc->create_text_node ('hoge');
  dies_here_ok {
    $dt->replace_child ($pi2, $pi);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The node cannot be contain this kind of node';

  is $dt->child_nodes->length, 1;
  is $dt->first_child, $pi;
  is $pi2->parent_node, undef;
  is $pi->parent_node, $dt;

  done $c;
} n => 8, name => 'dt > pi allowed / text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $pi = $doc->create_processing_instruction ('hoge', 'fyuga');
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  $dt->append_child ($pi);
  $doc->dom_config->{manakai_allow_doctype_children} = 0;

  my $df = $doc->create_document_fragment;
  my $pi2 = $doc->create_processing_instruction ('hoge2', 'fyuga');
  $df->append_child ($pi2);
  dies_here_ok {
    $dt->replace_child ($df, $pi);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The parent node cannot have a child';

  is $dt->child_nodes->length, 1;
  is $dt->first_child, $pi;
  is $pi2->parent_node, $df;
  is $pi->parent_node, $dt;
  is $df->child_nodes->length, 1;

  done $c;
} n => 9, name => 'dt > fragment > pi';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $pi = $doc->create_processing_instruction ('hoge', 'fyuga');
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  $dt->append_child ($pi);

  my $df = $doc->create_document_fragment;
  my $pi2 = $doc->create_processing_instruction ('hoge2', 'fyuga');
  $df->append_child ($pi2);
  my $pi3 = $dt->replace_child ($df, $pi);

  is $dt->child_nodes->length, 1;
  is $dt->first_child, $pi2;
  is $pi2->parent_node, $dt;
  is $pi->parent_node, undef;
  is $pi3, $df;
  is $df->child_nodes->length, 0;

  done $c;
} n => 6, name => 'dt > fragment > pi allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $pi = $doc->create_processing_instruction ('hoge', 'fyuga');
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  $dt->append_child ($pi);

  my $df = $doc->create_document_fragment;
  my $pi2 = $doc->create_processing_instruction ('hoge2', 'fyuga');
  my $text = $doc->create_text_node ('a');
  $df->append_child ($pi2);
  $df->append_child ($text);
  dies_here_ok {
    $dt->replace_child ($df, $pi);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The node cannot be contain this kind of node';

  is $dt->child_nodes->length, 1;
  is $dt->first_child, $pi;
  is $pi2->parent_node, $df;
  is $pi->parent_node, $dt;
  is $df->child_nodes->length, 2;

  done $c;
} n => 9, name => 'dt > fragment > pi';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $pi = $doc->create_processing_instruction ('hoge', 'fyuga');
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  $dt->append_child ($pi);

  my $df = $doc->create_document_fragment;
  my $pi3 = $dt->replace_child ($df, $pi);

  is $dt->child_nodes->length, 0;
  is $pi->parent_node, undef;
  is $pi3, $df;
  is $df->child_nodes->length, 0;

  done $c;
} n => 4, name => 'dt > fragment > empty allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node0 = $doc->create_element ('a');
  $doc->append_child ($node0);

  my $node = $doc->create_text_node ('a');

  $doc->dom_config->{manakai_strict_document_children} = 0;
  $doc->replace_child ($node, $node0);

  is $doc->child_nodes->length, 1;
  is $doc->first_child, $node;
  is $node->parent_node, $doc;
  is $node0->parent_node, undef;

  done $c;
} n => 4, name => 'doc > text allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node0 = $doc->create_element ('a');
  $doc->append_child ($node0);

  my $df = $doc->create_document_fragment;
  my $node = $doc->create_text_node ('a');
  $df->append_child ($node);

  $doc->dom_config->{manakai_strict_document_children} = 0;
  $doc->replace_child ($df, $node0);

  is $doc->child_nodes->length, 1;
  is $doc->first_child, $node;
  is $node->parent_node, $doc;
  is $node0->parent_node, undef;
  is $df->child_nodes->length, 0;

  done $c;
} n => 5, name => 'doc > text allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;
  my $el01 = $doc->create_comment ('hoge');
  my $el02 = $doc->create_element ('hoge');
  $doc->append_child ($el01);
  $doc->append_child ($el02);

  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');

  $doc->replace_child ($el1, $el01);
  $doc->replace_child ($el2, $el02);

  is $doc->child_nodes->length, 2;
  is $doc->first_child, $el1;
  is $doc->last_child, $el2;
  
  done $c;
} n => 3, name => 'doc > multiple elements, allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;
  my $el01 = $doc->create_comment ('hoge');
  my $el02 = $doc->create_element ('hoge');
  $doc->append_child ($el01);
  $doc->append_child ($el02);

  my $el1 = $doc->implementation->create_document_type ('a', '', '');
  my $el2 = $doc->implementation->create_document_type ('a', '', '');

  $doc->replace_child ($el1, $el01);
  $doc->replace_child ($el2, $el02);

  is $doc->child_nodes->length, 2;
  is $doc->first_child, $el1;
  is $doc->last_child, $el2;
  
  done $c;
} n => 3, name => 'doc > multiple doctypes, allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;
  my $el01 = $doc->create_comment ('hoge');
  my $el02 = $doc->create_element ('hoge');
  $doc->append_child ($el01);
  $doc->append_child ($el02);

  my $el1 = $doc->create_element ('f');
  my $el2 = $doc->implementation->create_document_type ('a', '', '');

  $doc->replace_child ($el1, $el01);
  $doc->replace_child ($el2, $el02);

  is $doc->child_nodes->length, 2;
  is $doc->first_child, $el1;
  is $doc->last_child, $el2;
  
  done $c;
} n => 3, name => 'doc > el + doctype, allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;
  my $el01 = $doc->create_comment ('hoge');
  my $el02 = $doc->create_comment ('hoge');
  my $el03 = $doc->create_element ('hoge');
  $doc->append_child ($el01);
  $doc->append_child ($el02);
  $doc->append_child ($el03);

  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('f');
  my $el2 = $doc->create_element ('f');
  my $el3 = $doc->implementation->create_document_type ('a', '', '');
  my $el4 = $doc->implementation->create_document_type ('a', '', '');
  $df->append_child ($el1);
  $df->append_child ($el2);

  $doc->replace_child ($df, $el01);
  $doc->replace_child ($el3, $el02);
  $doc->replace_child ($el4, $el03);

  is $doc->child_nodes->length, 4;
  is $doc->child_nodes->[0], $el1;
  is $doc->child_nodes->[1], $el2;
  is $doc->child_nodes->[2], $el3;
  is $doc->child_nodes->[3], $el4;
  is $df->child_nodes->length, 0;
  
  done $c;
} n => 6, name => 'doc > df > el + doctype, allowed';

test {
  my $c = shift;

  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;

  my $e1 = $doc->create_element ('e1');
  my $e2 = $doc->create_element ('e2');
  $df->append_child ($e1);
  $df->append_child ($e2);
  $e1->text_content ('abc');
  undef $e1;
  undef $e2;

  my $f1 = $doc->create_element ('f1');
  my $f2 = $doc->create_element ('f2');
  $f1->append_child ($f2);
  $f1->replace_child ($df, $f2);
  undef $df;

  is $f1->child_nodes->[0]->local_name, 'e1';
  is $f1->child_nodes->[1]->local_name, 'e2';

  is $f1->inner_html, q{<e1 xmlns="">abc</e1><e2 xmlns=""></e2>};

  done $c;
} n => 3, name => 'replace df';

test {
  my $c = shift;

  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;

  my $e1 = $doc->create_element ('e1');
  my $e2 = $doc->create_element ('e2');
  $df->append_child ($e1);
  $df->append_child ($e2);
  $e1->text_content ('abc');
  $e2->inner_html (q{<p>abc<q foo="124">X&lt;<!--AB--></q></p>});
  undef $e1;
  undef $e2;

  my $f1 = $doc->create_element ('f1');
  my $f2 = $doc->create_element ('f2');
  $f2->text_content ('abc');
  my $f3 = $doc->create_element ('f3');
  my $f4 = $doc->create_element ('f4');
  $f1->append_child ($f4);
  $f1->append_child ($f2);
  $f1->append_child ($f3);
  $f1->replace_child ($df, $f2);
  undef $df;

  is $f1->inner_html, q{<f4 xmlns=""></f4><e1 xmlns="">abc</e1><e2 xmlns=""><p>abc<q foo="124">X&lt;<!--AB--></q></p></e2><f3 xmlns=""></f3>};
  is $f1->inner_html, q{<f4 xmlns=""></f4><e1 xmlns="">abc</e1><e2 xmlns=""><p>abc<q foo="124">X&lt;<!--AB--></q></p></e2><f3 xmlns=""></f3>};
  is $f2->inner_html, q{abc};

  done $c;
} n => 3, name => 'replace df';

test {
  my $c = shift;

  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;

  my $f1 = $doc->create_element ('f1');
  my $f2 = $doc->create_element ('f2');
  my $f3 = $doc->create_element ('f3');
  my $f4 = $doc->create_element ('f4');
  $f1->append_child ($f4);
  $f1->append_child ($f2);
  $f1->append_child ($f3);
  $f1->replace_child ($df, $f2);
  undef $df;

  is $f1->inner_html, q{<f4 xmlns=""></f4><f3 xmlns=""></f3>};

  done $c;
} n => 1, name => 'replace df';

test {
  my $c = shift;

  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $doc2 = new Web::DOM::Document;

  my $e1 = $doc->create_element ('e1');
  my $e2 = $doc->create_element ('e2');
  $df->append_child ($e1);
  $df->append_child ($e2);
  $e1->text_content ('abd');
  $e2->inner_html (q{<p>xbc<q foo="124">X&lt;<!--AB--></q></p>});
  undef $e1;
  undef $e2;

  my $f1 = $doc2->create_element ('f1');
  my $f2 = $doc2->create_element ('f2');
  $f2->text_content ('abC');
  my $f3 = $doc2->create_element ('f3');
  my $f4 = $doc2->create_element ('f4');
  $f1->append_child ($f4);
  $f1->append_child ($f2);
  $f1->append_child ($f3);
  $f1->replace_child ($df, $f2);
  undef $df;
  my $f5 = $doc2->create_element ('f5');
  $f5->text_content ('abc');
  undef $doc2;
  undef $f5;

  is $f1->inner_html, q{<f4 xmlns=""></f4><e1 xmlns="">abd</e1><e2 xmlns=""><p>xbc<q foo="124">X&lt;<!--AB--></q></p></e2><f3 xmlns=""></f3>};
  is $f1->inner_html, q{<f4 xmlns=""></f4><e1 xmlns="">abd</e1><e2 xmlns=""><p>xbc<q foo="124">X&lt;<!--AB--></q></p></e2><f3 xmlns=""></f3>};
  is $f2->inner_html, q{abC};

  done $c;
} n => 3, name => 'replace df';

test {
  my $c = shift;

  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $doc2 = new Web::DOM::Document;

  my $f1 = $doc2->create_element ('f1');
  my $f2 = $doc2->create_element ('f2');
  $f2->text_content ('abc');
  my $f3 = $doc2->create_element ('f3');
  my $f4 = $doc2->create_element ('f4');
  $f1->append_child ($f4);
  $f1->append_child ($f2);
  $f1->append_child ($f3);
  $f1->replace_child ($df, $f2);
  undef $df;
  my $f5 = $doc2->create_element ('f5');
  $f5->text_content ('abc');
  undef $doc2;
  undef $f5;
  undef $f2;

  is $f1->inner_html, q{<f4 xmlns=""></f4><f3 xmlns=""></f3>};
  is $f1->inner_html, q{<f4 xmlns=""></f4><f3 xmlns=""></f3>};

  done $c;
} n => 2, name => 'replace df';

run_tests;

## See also: htmltemplateelement.t

=head1 LICENSE

Copyright 2012-2024 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
