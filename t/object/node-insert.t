use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

for my $method (qw(append_child insert_before)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    
    my $node = $doc->create_element ('el');
    $method; # Perl 5.8 compat
    dies_here_ok {
      $node->$method (undef);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->message, 'The first argument is not a Node';
    is scalar @{$node->child_nodes}, 0;
    done $c;
  } n => 4, name => [$method, 'child typeerror'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    
    my $node = $doc->create_element ('el');
    $method; # Perl 5.8 compat
    dies_here_ok {
      $node->$method ('hoge');
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->message, 'The first argument is not a Node';
    is scalar @{$node->child_nodes}, 0;
    done $c;
  } n => 4, name => [$method, 'child typeerror'];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $node = $doc->create_element ('el');
  my $el = $doc->create_element ('foo');
  dies_here_ok {
    $node->insert_before ($el, 'hoge');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a Node';
  is scalar @{$node->child_nodes}, 0;
  done $c;
} n => 4, name => 'insert_before refchild typeerror';

for my $method (qw(append_child insert_before)) {
  my $doc = new Web::DOM::Document;
  for my $parent (
    $doc->create_text_node ('hoge'),
    $doc->create_comment ('hoge'),
    $doc->create_processing_instruction ('hoge', 'fuga'),
    $doc->implementation->create_document_type ('aa', '', ''),
  ) {
    for my $node2 (
      $doc->create_element ('el'),
      new Web::DOM::Document,
      $doc->implementation->create_document_type ('a', '', ''),
      $doc->create_text_node ('a'),
      $doc->create_comment ('hoge'),
      $doc->create_processing_instruction ('hoge', 'fuga'),
      $doc->create_document_fragment,
    ) {
      test {
        my $c = shift;
        $method; # Perl 5.8 compat
        dies_here_ok {
          $parent->$method ($node2);
        };
        isa_ok $@, 'Web::DOM::Exception';
        is $@->name, 'HierarchyRequestError';
        is $@->message, 'The parent node cannot have a child';
        is scalar @{$parent->child_nodes}, 0;
        is $node2->parent_node, undef;
        done $c;
      } n => 6, name => [$method, $parent->node_type, $node2->node_type, 'bad parent'];
    }
  }
}

for my $method (qw(append_child insert_before)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('hoge');
    dies_here_ok {
      $el->append_child ($el);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'The child is a host-including inclusive ancestor of the parent';
    is scalar @{$el->child_nodes}, 0;
    is $el->parent_node, undef;
    done $c;
  } n => 6, name => [$method, 'same'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el1 = $doc->create_element ('hoge');
    my $el2 = $doc->create_element ('fuga');
    $el1->append_child ($el2);
    dies_here_ok {
      $el2->append_child ($el1);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'The child is a host-including inclusive ancestor of the parent';
    is scalar @{$el2->child_nodes}, 0;
    is $el1->parent_node, undef;
    done $c;
  } n => 6, name => [$method, 'parent'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el1 = $doc->create_element ('hoge');
    my $el2 = $doc->create_element ('fuga');
    my $el3 = $doc->create_element ('fuga2');
    my $el4 = $doc->create_element ('fuga3');
    $el1->append_child ($el2);
    $el2->append_child ($el3);
    $el3->append_child ($el4);
    dies_here_ok {
      $el4->append_child ($el1);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'The child is a host-including inclusive ancestor of the parent';
    is scalar @{$el4->child_nodes}, 0;
    is $el1->parent_node, undef;
    done $c;
  } n => 6, name => [$method, 'ancestor'];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  my $el3 = $doc->create_element ('c');

  $el1->append_child ($el2);
  dies_here_ok {
    $el1->insert_before ($el2, $el3);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'The reference child is not a child of the parent node';
  is scalar @{$el1->child_nodes}, 1;
  is $el3->parent_node, undef;
  done $c;
} n => 6, name => 'insert_before / refChild has no parent';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  
  my $el1 = $doc1->create_element ('hoge');
  my $el3 = $doc1->create_element ('hoge');
  
  my $el2 = $doc2->create_element ('fuga');
  
  dies_here_ok {
    $el1->insert_before ($el3, $el2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'The reference child is not a child of the parent node';
  done $c;
} n => 4, name => ['insert_before', 'wrong ref document, another document'];

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  
  my $el1 = $doc1->create_element ('hoge');
  my $el3 = $doc1->create_element ('hoge');
  
  my $el2 = $doc2->create_element ('fuga');
  my $el4 = $doc2->create_element ('fuga');
  $el2->append_child ($el4);
  
  dies_here_ok {
    $el1->insert_before ($el3, $el4);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'The reference child is not a child of the parent node';
  done $c;
} n => 4, name => ['insert_before', 'wrong ref document, another document'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  my $el3 = $doc->create_element ('c');
  my $el4 = $doc->create_element ('d');

  $el1->append_child ($el2);
  $el3->append_child ($el4);

  dies_here_ok {
    $el3->insert_before ($el1, $el2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'The reference child is not a child of the parent node';
  is scalar @{$el1->child_nodes}, 1;
  is $el3->parent_node, undef;
  done $c;
} n => 6, name => 'insert_before / refChild has different parent';

for my $method (qw(insert_before append_child)) {
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->create_text_node ('hoge'),
  ) {
    test {
      my $c = shift;

      $method; # Perl 5.8 compat
      dies_here_ok {
        $doc->$method ($node);
      };
      isa_ok $@, 'Web::DOM::Exception';
      is $@->name, 'HierarchyRequestError';
      is $@->message, 'Document node cannot contain this kind of node';
      is scalar @{$doc->child_nodes}, 0;
      is $node->parent_node, undef;
      done $c;
    } n => 6, name => [$method, $node->node_type, 'cannot be a document node child'];
  }

  for my $node (
    new Web::DOM::Document,
  ) {
    test {
      my $c = shift;

      $method; # Perl 5.8 compat
      dies_here_ok {
        $doc->$method ($node);
      };
      isa_ok $@, 'Web::DOM::Exception';
      is $@->name, 'HierarchyRequestError';
      is $@->message, 'The parent cannot contain this kind of node';
      is scalar @{$doc->child_nodes}, 0;
      is $node->parent_node, undef;
      done $c;
    } n => 6, name => [$method, $node->node_type, 'cannot be a document node child'];
  }

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    
    my $df = $doc->create_document_fragment;
    my $el1 = $doc->create_element ('a');
    my $el2 = $doc->create_element ('b');
    $df->append_child ($el1);
    $df->append_child ($el2);

    dies_here_ok {
      $doc->$method ($df);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'Document node cannot have two element children';
    is scalar @{$doc->child_nodes}, 0;
    is $el1->parent_node, $df;
    is $el2->parent_node, $df;
    is scalar @{$df->child_nodes}, 2;
    done $c;
  } n => 8, name => [$method, 'two document elements'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    
    my $df = $doc->create_document_fragment;
    my $el1 = $doc->create_element ('a');
    my $el2 = $doc->create_element ('b');
    my $text = $doc->create_text_node ('text');
    $df->append_child ($el1);
    $df->append_child ($text);
    $df->append_child ($el2);

    dies_here_ok {
      $doc->$method ($df);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'Document node cannot contain this kind of node';
    is scalar @{$doc->child_nodes}, 0;
    is $el1->parent_node, $df;
    is $text->parent_node, $df;
    is $el2->parent_node, $df;
    is scalar @{$df->child_nodes}, 3;
    done $c;
  } n => 9, name => [$method, 'document > df > text'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el1 = $doc->create_element ('a');
    my $df = $doc->create_document_fragment;
    my $el2 = $doc->create_element ('b');
    $doc->append_child ($el1);
    $df->append_child ($el2);

    dies_here_ok {
      $doc->$method ($df);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'Document node cannot have two element children';

    is scalar @{$doc->child_nodes}, 1;
    is scalar @{$df->child_nodes}, 1;
    is $el2->parent_node, $df;
    done $c;
  } n => 7, name => [$method, 'multiple document elements'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $dt1 = $doc->implementation->create_document_type ('a', '', '');
    my $dt2 = $doc->implementation->create_document_type ('a', '', '');
    $doc->append_child ($dt1);
    dies_here_ok {
      $doc->$method ($dt2);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'Document node cannot have two doctype children';
    is scalar @{$doc->child_nodes}, 1;
    is $dt1->parent_node, $doc;
    is $dt2->parent_node, undef;
    done $c;
  } n => 7, name => [$method, 'multiple doctype'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $dt = $doc->implementation->create_document_type ('a', '', '');
    my $el = $doc->create_element ('a');
    $doc->append_child ($el);
    dies_here_ok {
      $doc->$method ($dt);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'Element cannot precede the document type';
    is scalar @{$doc->child_nodes}, 1;
    is $el->parent_node, $doc;
    is $dt->parent_node, undef;
    done $c;
  } n => 7, name => [$method, 'element before doctype'];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('a', '', '');
  my $pi = $doc->create_processing_instruction ('b', '', '');
  my $el = $doc->create_element ('a');
  $doc->append_child ($el);
  $doc->append_child ($pi);
  dies_here_ok {
    $doc->insert_before ($dt, $pi);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Element cannot precede the document type';
  is scalar @{$doc->child_nodes}, 2;
  is $el->parent_node, $doc;
  is $dt->parent_node, undef;
  done $c;
} n => 7, name => ['insert_before', 'element before doctype'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('a', '', '');
  my $pi = $doc->create_processing_instruction ('b', '', '');
  my $el = $doc->create_element ('a');
  $doc->append_child ($el);
  $doc->append_child ($pi);
  $doc->insert_before ($dt, $el);
  is scalar @{$doc->child_nodes}, 3;
  is $el->parent_node, $doc;
  is $dt->parent_node, $doc;
  is $doc->first_child, $dt;
  done $c;
} n => 4, name => ['insert_before', 'element after doctype'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $el = $doc->create_element ('a');
  $df->append_child ($el);
  my $dt = $doc->implementation->create_document_type ('a', '', '');
  $doc->append_child ($dt);
  
  dies_here_ok {
    $doc->insert_before ($df, $dt);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Element cannot precede the document type';

  is scalar @{$doc->child_nodes}, 1;
  is scalar @{$df->child_nodes}, 1;
  is $el->parent_node, $df;

  done $c;
} n => 7, name => 'insert_before doctype after element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $comment = $doc->create_comment ('&aa');
  my $df = $doc->create_document_fragment;
  my $el = $doc->create_element ('a');
  $df->append_child ($el);
  my $dt = $doc->implementation->create_document_type ('a', '', '');
  $doc->append_child ($comment);
  $doc->append_child ($dt);
  
  dies_here_ok {
    $doc->insert_before ($df, $comment);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Element cannot precede the document type';

  is scalar @{$doc->child_nodes}, 2;
  is scalar @{$df->child_nodes}, 1;
  is $el->parent_node, $df;

  done $c;
} n => 7, name => 'insert_before doctype after element';

for my $method (qw(append_child insert_before)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el1 = $doc->create_element ('a');
    my $el2 = $doc->create_element ('b');
    $doc->append_child ($el1);
    $method; # Perl 5.8 compat
    dies_here_ok {
      $doc->$method ($el2);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'Document node cannot have two element children';
    is scalar @{$doc->child_nodes}, 1;
    is $el2->parent_node, undef;
    done $c;
  } n => 6, name => [$method, 'multiple document element children'];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el2 = $doc->create_element ('b');
  my $doctype = $doc->implementation->create_document_type ('a', '', '');
  $doc->append_child ($doctype);
  
  dies_here_ok {
    $doc->insert_before ($el2, $doctype);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Element cannot precede the document type';
  is scalar @{$doc->child_nodes}, 1;
  is $el2->parent_node, undef;
  done $c;
} n => 6, name => 'insert_before insert element before doctype';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el2 = $doc->create_element ('b');
  my $comment = $doc->create_comment ('c');
  my $doctype = $doc->implementation->create_document_type ('a', '', '');
  $doc->append_child ($comment);
  $doc->append_child ($doctype);
  
  dies_here_ok {
    $doc->insert_before ($el2, $comment);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Element cannot precede the document type';
  is scalar @{$doc->child_nodes}, 2;
  is $el2->parent_node, undef;
  done $c;
} n => 6, name => 'insert_before insert element before doctype';

for my $method (qw(append_child insert_before)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $pi = $doc->create_processing_instruction ('a', 'b');
    my $dt = $doc->implementation->create_document_type ('c', '', '');
    my $comment = $doc->create_comment ('e');
    my $el = $doc->create_element ('f');
    my $comment2 = $doc->create_comment ('g');
    $doc->$method ($pi);
    $doc->$method ($dt);
    $doc->$method ($comment);
    $doc->$method ($el);
    $doc->$method ($comment2);
    is scalar @{$doc->child_nodes}, 5;
    done $c;
  } n => 1, name => [$method, 'document children'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $df = $doc->create_document_fragment;
    my $pi = $doc->create_processing_instruction ('a', 'b');
    my $dt = $doc->implementation->create_document_type ('c', '', '');
    my $comment = $doc->create_comment ('e');
    my $el = $doc->create_element ('f');
    my $comment2 = $doc->create_comment ('g');
    $doc->$method ($pi);
    $doc->$method ($dt);
    $df->$method ($comment);
    $df->$method ($el);
    $df->$method ($comment2);
    $doc->append_child ($df);
    is scalar @{$doc->child_nodes}, 5;
    done $c;
  } n => 1, name => [$method, 'document children'];
}

for my $method (qw(append_child insert_before)) {
  my $doc = new Web::DOM::Document;
  for my $parent (
    $doc->create_element ('a'),
    $doc->create_document_fragment,
  ) {
    for my $child (
      new Web::DOM::Document,
    ) {
      test {
        my $c = shift;
        $method; # Perl 5.8 compat
        dies_here_ok {
          $parent->$method ($child);
        };
        isa_ok $@, 'Web::DOM::Exception';
        is $@->name, 'HierarchyRequestError';
        is $@->message, 'The parent cannot contain this kind of node';
        is scalar @{$parent->child_nodes}, 0;
        is $child->parent_node, undef;
        done $c;
      } n => 6, name => [$method, $parent->node_type, $child->node_type, 'parent/child error'];
    }

    for my $child (
      $doc->implementation->create_document_type ('hoge', '', ''),
    ) {
      test {
        my $c = shift;
        $method; # Perl 5.8 compat
        dies_here_ok {
          $parent->$method ($child);
        };
        isa_ok $@, 'Web::DOM::Exception';
        is $@->name, 'HierarchyRequestError';
        is $@->message, 'Document type cannot be contained by this kind of node';
        is scalar @{$parent->child_nodes}, 0;
        is $child->parent_node, undef;
        done $c;
      } n => 6, name => [$method, $parent->node_type, $child->node_type, 'parent/child error'];
    }
  }

  for my $parent (
    $doc->create_element ('a'),
    $doc->create_document_fragment,
  ) {
    my $i = 0;
    for my $child (
      $doc->create_element ('a'),
      $doc->create_text_node ('b'),
      $doc->create_processing_instruction ('c', 'd'),
      $doc->create_comment ('e'),
    ) {
      test {
        my $c = shift;
        $i++;
        $parent->$method ($child);
        is scalar @{$parent->child_nodes}, $i;
        is $child->parent_node, $parent;
        is $parent->last_child, $child;
        done $c;
      } n => 3, name => [$method, $parent->node_type, $child->node_type, 'parent/child ok'];
    }
  }
}

for my $method (qw(append_child insert_before)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;

    my $node1 = $doc->create_element ('a');
    my $node2 = $doc->create_element ('b');

    $node1->$method ($node2);

    is $node1->owner_document, $doc;
    is $node2->owner_document, $doc;

    is $node1->first_child, $node2;
    is $node1->last_child, $node2;
    is scalar @{$node1->child_nodes}, 1;
    is scalar @{$node2->child_nodes}, 0;

    is $node1->parent_node, undef;
    is $node2->parent_node, $node1;

    is $$node1->[0]->{tree_id}->[$$node1->[1]],
        $$node2->[0]->{tree_id}->[$$node2->[1]];
    is $$node1->[0], $$node2->[0];

    done $c;
  } n => 10, name => [$method, 'append single nodes'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;

    my $node1 = $doc->create_element ('a');
    my $node2 = $doc->create_element ('b');
    my $node3 = $doc->create_element ('c');
    $node2->append_child ($node3);

    $node1->$method ($node2);

    is $node1->owner_document, $doc;
    is $node2->owner_document, $doc;

    is $node1->first_child, $node2;
    is $node1->last_child, $node2;
    is scalar @{$node1->child_nodes}, 1;
    is scalar @{$node2->child_nodes}, 1;

    is $node1->parent_node, undef;
    is $node2->parent_node, $node1;

    is $$node1->[0]->{tree_id}->[$$node1->[1]],
        $$node2->[0]->{tree_id}->[$$node2->[1]];
    is $$node1->[0]->{tree_id}->[$$node1->[1]],
        $$node3->[0]->{tree_id}->[$$node3->[1]];
    is $$node1->[0], $$node2->[0];
    is $$node1->[0], $$node3->[0];

    done $c;
  } n => 12, name => [$method, 'append node with child'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;

    my $node1 = $doc->create_element ('a');
    my $node2 = $doc->create_element ('b');
    my $node3 = $doc->create_element ('b');
    $node1->append_child ($node2);

    $node1->$method ($node3);

    is $node1->owner_document, $doc;
    is $node2->owner_document, $doc;
    is $node3->owner_document, $doc;

    is $node1->first_child, $node2;
    is $node1->last_child, $node3;
    is scalar @{$node1->child_nodes}, 2;
    is scalar @{$node2->child_nodes}, 0;
    is scalar @{$node3->child_nodes}, 0;

    is $node1->parent_node, undef;
    is $node2->parent_node, $node1;
    is $node3->parent_node, $node1;

    is $$node1->[0]->{tree_id}->[$$node1->[1]],
        $$node2->[0]->{tree_id}->[$$node2->[1]];
    is $$node1->[0]->{tree_id}->[$$node1->[1]],
        $$node3->[0]->{tree_id}->[$$node3->[1]];
    is $$node1->[0], $$node2->[0];
    is $$node1->[0], $$node3->[0];

    done $c;
  } n => 15, name => [$method, 'append after existing node'];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $node1 = $doc->create_element ('a');
  my $node2 = $doc->create_element ('b');
  my $node3 = $doc->create_element ('b');
  $node1->append_child ($node2);
  
  $node1->insert_before ($node3, $node2);
  
  is $node1->owner_document, $doc;
  is $node2->owner_document, $doc;
  is $node3->owner_document, $doc;

  is $node1->first_child, $node3;
  is $node1->last_child, $node2;
  is scalar @{$node1->child_nodes}, 2;
  is scalar @{$node2->child_nodes}, 0;
  is scalar @{$node3->child_nodes}, 0;

  is $node1->parent_node, undef;
  is $node2->parent_node, $node1;
  is $node3->parent_node, $node1;

  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$node2->[0]->{tree_id}->[$$node2->[1]];
  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$node3->[0]->{tree_id}->[$$node3->[1]];
  is $$node1->[0], $$node2->[0];
  is $$node1->[0], $$node3->[0];
  
  done $c;
} n => 15, name => ['insert_before', 'append before existing node'];

for my $method (qw(append_child insert_before)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;

    my $node1 = $doc->create_element ('a');
    my $df = $doc->create_document_fragment;

    $node1->$method ($df);

    is $node1->owner_document, $doc;
    is $df->owner_document, $doc;

    is scalar @{$node1->child_nodes}, 0;
    is scalar @{$df->child_nodes}, 0;

    is $node1->parent_node, undef;
    is $df->parent_node, undef;

    isnt $$df->[0]->{tree_id}->[$$df->[1]],
      $$node1->[0]->{tree_id}->[$$node1->[1]];
    is $$node1->[0], $$df->[0];

    done $c;
  } n => 8, name => [$method, 'document fragment empty'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;

    my $node1 = $doc->create_element ('a');
    my $node2 = $doc->create_element ('b');
    my $df = $doc->create_document_fragment;
    $df->append_child ($node2);

    $node1->$method ($df);

    is $node1->owner_document, $doc;
    is $node2->owner_document, $doc;
    is $df->owner_document, $doc;

    is scalar @{$node1->child_nodes}, 1;
    is scalar @{$node2->child_nodes}, 0;
    is scalar @{$df->child_nodes}, 0;

    is $node1->first_child, $node2;

    is $node1->parent_node, undef;
    is $node2->parent_node, $node1;
    is $df->parent_node, undef;

    is $$node1->[0]->{tree_id}->[$$node1->[1]],
        $$node2->[0]->{tree_id}->[$$node2->[1]];
    isnt $$df->[0]->{tree_id}->[$$df->[1]],
      $$node2->[0]->{tree_id}->[$$node2->[1]];
    is $$node1->[0], $$node2->[0];
    is $$node1->[0], $$df->[0];

    done $c;
  } n => 14, name => [$method, 'document fragment a child'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;

    my $node1 = $doc->create_element ('a');
    my $node2 = $doc->create_element ('b');
    my $node3 = $doc->create_element ('b');
    my $node4 = $doc->create_element ('b');
    my $df = $doc->create_document_fragment;
    $df->append_child ($node2);
    $df->append_child ($node3);
    $df->append_child ($node4);

    $node1->$method ($df);

    is $node1->owner_document, $doc;
    is $node2->owner_document, $doc;
    is $node3->owner_document, $doc;
    is $node4->owner_document, $doc;
    is $df->owner_document, $doc;

    is scalar @{$node1->child_nodes}, 3;
    is scalar @{$node2->child_nodes}, 0;
    is scalar @{$node3->child_nodes}, 0;
    is scalar @{$node4->child_nodes}, 0;
    is scalar @{$df->child_nodes}, 0;

    is $node1->first_child, $node2;
    is $node1->last_child, $node4;

    is $node1->parent_node, undef;
    is $node2->parent_node, $node1;
    is $node3->parent_node, $node1;
    is $node4->parent_node, $node1;
    is $df->parent_node, undef;

    is $$node1->[0]->{tree_id}->[$$node1->[1]],
        $$node2->[0]->{tree_id}->[$$node2->[1]];
    is $$node1->[0]->{tree_id}->[$$node1->[1]],
        $$node3->[0]->{tree_id}->[$$node3->[1]];
    is $$node1->[0]->{tree_id}->[$$node1->[1]],
        $$node4->[0]->{tree_id}->[$$node4->[1]];
    isnt $$df->[0]->{tree_id}->[$$df->[1]],
      $$node2->[0]->{tree_id}->[$$node2->[1]];
    is $$node1->[0], $$node2->[0];
    is $$node1->[0], $$node3->[0];
    is $$node1->[0], $$node4->[0];
    is $$node1->[0], $$df->[0];

    done $c;
  } n => 25, name => [$method, 'document fragment multiple children'];
}

for my $method (qw(append_child insert_before)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $node1 = $doc->create_element ('a');
    my $node2 = $doc->create_element ('a');

    my $node3 = $node1->$method ($node2);
    isa_ok $node3, 'Web::DOM::Node';
    is $node3, $node2;

    done $c;
  } n => 2, name => [$method, 'return value'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $node1 = $doc->create_element ('a');
    my $node2 = $doc->create_element ('a');
    my $df = $doc->create_document_fragment ($node2);

    my $node3 = $node1->$method ($df);
    isa_ok $node3, 'Web::DOM::Node';
    is $node3, $df;

    done $c;
  } n => 2, name => [$method, 'return value / document fragment'];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('a');
  my $node2 = $doc->create_element ('b');
  $node1->append_child ($node2);

  my $node3 = $node1->insert_before ($node2, $node2);
  isa_ok $node3, 'Web::DOM::Node';
  is $node3, $node2;

  is scalar @{$node1->child_nodes}, 1;
  is $node1->first_child, $node2;
  is $node2->parent_node, $node1;
  
  done $c;
} n => 5, name => 'insert_before before itself';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('a');
  my $node2 = $doc->create_element ('b');
  my $node4 = $doc->create_element ('b');
  $node1->append_child ($node2);
  $node1->append_child ($node4);

  my $node3 = $node1->insert_before ($node2, $node2);
  isa_ok $node3, 'Web::DOM::Node';
  is $node3, $node2;

  is scalar @{$node1->child_nodes}, 2;
  is $node1->first_child, $node2;
  is $node1->last_child, $node4;
  is $node2->parent_node, $node1;
  
  done $c;
} n => 6, name => 'insert_before before itself, with following sibling';

for my $method (qw(append_child insert_before)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;

    my $node1 = $doc->create_element ('a');
    my $node2 = $doc->create_element ('b');
    my $node3 = $doc->create_element ('c');

    $node1->append_child ($node2);
    $node1->append_child ($node3);

    $node1->$method ($node2);

    is scalar @{$node1->child_nodes}, 2;
    is $node1->first_child, $node3;
    is $node1->last_child, $node2;

    is $node2->parent_node, $node1;
    is $node3->parent_node, $node1;

    done $c;
  } n => 5, name => [$method, 'swap children'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;

    my $node1 = $doc->create_element ('a');
    my $node2 = $doc->create_element ('b');
    my $node3 = $doc->create_element ('c');
    my $node4 = $doc->create_element ('d');

    $node1->append_child ($node2);
    $node1->append_child ($node3);
    $node1->append_child ($node4);

    $node1->$method ($node2);

    is scalar @{$node1->child_nodes}, 3;
    is $node1->first_child, $node3;
    is $node1->last_child, $node2;

    is $node2->parent_node, $node1;
    is $node3->parent_node, $node1;
    is $node4->parent_node, $node1;

    done $c;
  } n => 6, name => [$method, 'swap children'];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('a');
  my $node2 = $doc->create_element ('b');
  my $node3 = $doc->create_element ('c');
  my $node4 = $doc->create_element ('d');

  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node1->append_child ($node4);

  $node1->insert_before ($node2, $node4);

  is scalar @{$node1->child_nodes}, 3;
  is $node1->first_child, $node3;
  is $node1->last_child, $node4;

  is $node2->parent_node, $node1;
  is $node3->parent_node, $node1;
  is $node4->parent_node, $node1;

  done $c;
} n => 6, name => ['insert_before', 'swap children'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node1 = $doc->create_element ('a');
  my $node2 = $doc->create_element ('b');
  my $node3 = $doc->create_element ('c');
  my $node4 = $doc->create_element ('d');

  $node1->append_child ($node2);
  $node1->append_child ($node3);
  $node1->append_child ($node4);

  $node1->insert_before ($node4, $node2);

  is scalar @{$node1->child_nodes}, 3;
  is $node1->first_child, $node4;
  is $node1->last_child, $node3;

  is $node2->parent_node, $node1;
  is $node3->parent_node, $node1;
  is $node4->parent_node, $node1;

  done $c;
} n => 6, name => ['insert_before', 'swap children'];

for my $method (qw(append_child insert_before)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $df1 = $doc->create_document_fragment;
    my $df2 = $doc->create_document_fragment;
    
    my $node3 = $df1->$method ($df2);
    is $node3, $df2;

    is scalar @{$df1->child_nodes}, 0;
    is scalar @{$df2->child_nodes}, 0;
    is $df1->parent_node, undef;
    is $df2->parent_node, undef;

    done $c;
  } n => 5, name => [$method, 'df - df empty'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $df1 = $doc->create_document_fragment;
    my $df2 = $doc->create_document_fragment;
    my $node1 = $doc->create_element ('a');
    $df2->append_child ($node1);
    
    my $node3 = $df1->$method ($df2);
    is $node3, $df2;

    is scalar @{$df1->child_nodes}, 1;
    is scalar @{$df2->child_nodes}, 0;
    is $df1->parent_node, undef;
    is $df2->parent_node, undef;
    is $node1->parent_node, $df1;

    done $c;
  } n => 6, name => [$method, 'df - df a child'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $df1 = $doc->create_document_fragment;
    my $node1 = $doc->create_element ('a');
    $df1->append_child ($node1);
    
    dies_here_ok {
      $df1->$method ($df1);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'The child is a host-including inclusive ancestor of the parent';

    is scalar @{$df1->child_nodes}, 1;
    is $node1->parent_node, $df1;

    done $c;
  } n => 6, name => [$method, 'df - df self'];
}

for my $method (qw(append_child insert_before)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el1 = $doc->create_element ('a');
    my $el2 = $doc->create_element ('a');
    my $el3 = $doc->create_element ('a');
    $el1->append_child ($el2);

    my $nl = $el1->child_nodes;
    is scalar @$nl, 1;
    my $cl = $el1->children;
    is scalar @$cl, 1;

    my $nl2 = $el3->child_nodes;
    is scalar @$nl2, 0;
    my $cl2 = $el3->children;
    is scalar @$cl2, 0;

    $el3->$method ($el2);

    is scalar @$nl, 0;
    is scalar @$nl2, 1;
    is scalar @$cl, 0;
    is scalar @$cl2, 1;

    done $c;
  } n => 8, name => [$method, 'parent child_nodes'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el1 = $doc->create_element ('a');
    my $df = $doc->create_document_fragment;
    my $el2 = $doc->create_element ('a');
    my $el3 = $doc->create_element ('a');
    $df->append_child ($el2);
    $df->append_child ($el3);

    my $nl = $df->child_nodes;
    is scalar @$nl, 2;
    my $cl = $df->children;
    is scalar @$cl, 2;

    my $nl2 = $el1->child_nodes;
    is scalar @$nl2, 0;
    my $cl2 = $el1->children;
    is scalar @$cl2, 0;

    $el1->$method ($df);

    is scalar @$nl, 0;
    is scalar @$nl2, 2;
    is scalar @$cl, 0;
    is scalar @$cl2, 2;

    done $c;
  } n => 8, name => [$method, 'df child_nodes'];

  test {
    my $c = shift;
    my $doc1 = new Web::DOM::Document;
    my $doc2 = new Web::DOM::Document;
    $doc2->create_text_node ('a') for 1..rand 10;

    my $el1 = $doc1->create_element ('aa');
    my $el2 = $doc2->create_element ('aa');

    my $el3 = $el1->$method ($el2);
    is $el3, $el2;

    is $el1->first_child, $el2;
    is $el2->parent_node, $el1;

    is $el1->owner_document, $doc1;
    is $el2->owner_document, $doc1;
    
    done $c;
  } n => 5, name => [$method, 'different document'];
}

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;

  my $el1 = $doc1->create_element ('a');
  my $el2 = $doc1->create_element ('a');
  my $el3 = $doc2->create_element ('a');

  dies_here_ok {
    $el1->insert_before ($el2, $el3);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'The reference child is not a child of the parent node';

  is $el1->child_nodes->length, 0;
  is $el2->parent_node, undef;

  is $el1->owner_document, $doc1;
  is $el2->owner_document, $doc1;
  is $el3->owner_document, $doc2;
  
  done $c;
} n => 9, name => 'insert_before refchild is different doc';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  $doc2->create_text_node ('a') for 1..rand 10;

  my $el1 = $doc1->create_element ('a');
  my $el2 = $doc1->create_element ('a');
  my $el3 = $doc2->create_element ('a');
  $el1->append_child ($el2);

  my $el4 = $el1->insert_before ($el3, $el2);
  is $el4, $el3;

  is $el1->first_child, $el3;
  is $el1->last_child, $el2;
  is $el3->parent_node, $el1;
  is $el2->parent_node, $el1;

  is $el1->owner_document, $doc1;
  is $el2->owner_document, $doc1;
  is $el3->owner_document, $doc1;

  done $c;
} n => 8, name => 'insert_before diferent document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $pi = $doc->create_processing_instruction ('hoge', 'fyuga');
  dies_here_ok {
    $dt->append_child ($pi);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The parent node cannot have a child';
  is $dt->child_nodes->length, 0;
  done $c;
} n => 5, name => 'doctype > pi';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $pi = $doc->create_processing_instruction ('hoge', 'fyuga');
  my $pi2 = $dt->append_child ($pi);
  is $pi2, $pi;
  is $dt->child_nodes->length, 1;
  is $dt->child_nodes->[0], $pi;
  done $c;
} n => 3, name => 'doctype > pi allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $text = $doc->create_text_node ('hhh');
  dies_here_ok {
    $dt->append_child ($text);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The node cannot be contain this kind of node';
  is $text->parent_node, undef;
  is $dt->child_nodes->length, 0;
  done $c;
} n => 6, name => 'doctype > pi allowed / text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $df = $doc->create_document_fragment;
  my $pi = $doc->create_processing_instruction ('hoge', 'fyuga');
  $df->append_child ($pi);
  dies_here_ok {
    $dt->append_child ($df);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The parent node cannot have a child';
  is $dt->child_nodes->length, 0;
  is $df->child_nodes->length, 1;
  done $c;
} n => 6, name => 'doctype > df > pi';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $df = $doc->create_document_fragment;
  my $pi = $doc->create_processing_instruction ('hoge', 'fyuga');
  $df->append_child ($pi);
  my $pi2 = $dt->append_child ($df);
  is $pi2, $df;
  is $dt->child_nodes->length, 1;
  is $dt->child_nodes->[0], $pi;
  is $pi->parent_node, $dt;
  is $df->child_nodes->length, 0;
  done $c;
} n => 5, name => 'doctype > df > pi allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $df = $doc->create_document_fragment;
  my $pi = $doc->create_processing_instruction ('hoge', 'fyuga');
  my $text = $doc->create_text_node ('aa');
  $df->append_child ($pi);
  $df->append_child ($text);
  dies_here_ok {
    $dt->append_child ($df);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The node cannot be contain this kind of node';
  is $dt->child_nodes->length, 0;
  is $df->child_nodes->length, 2;
  done $c;
} n => 6, name => 'doctype > df > pi + text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $df = $doc->create_document_fragment;
  dies_here_ok {
    $dt->append_child ($df);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The parent node cannot have a child';
  is $dt->child_nodes->length, 0;
  is $df->child_nodes->length, 0;
  done $c;
} n => 6, name => 'doctype > df > empty not allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_allow_doctype_children} = 1;
  my $dt = $doc->implementation->create_document_type ('aa', '', '');
  my $df = $doc->create_document_fragment;
  my $pi2 = $dt->append_child ($df);
  is $pi2, $df;
  is $dt->child_nodes->length, 0;
  is $df->child_nodes->length, 0;
  done $c;
} n => 3, name => 'doctype > df > empty allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_text_node ('a');
  $doc->dom_config->{manakai_strict_document_children} = 0;
  
  $doc->append_child ($node);

  is $doc->child_nodes->length, 1;
  is $doc->first_child, $node;

  done $c;
} n => 2, name => 'doc > text allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;
  my $df = $doc->create_document_fragment;
  my $node = $doc->create_text_node ('a');
  $df->append_child ($node);
  
  $doc->append_child ($df);

  is $doc->child_nodes->length, 1;
  is $doc->first_child, $node;
  is $node->parent_node, $doc;
  is $df->child_nodes->length, 0;

  done $c;
} n => 4, name => 'doc > df > text allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;

  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');

  $doc->append_child ($el1);
  $doc->append_child ($el2);

  is $doc->child_nodes->length, 2;
  is $doc->first_child, $el1;
  is $doc->last_child, $el2;
  
  done $c;
} n => 3, name => 'doc > multiple elements, allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;

  my $el1 = $doc->implementation->create_document_type ('a', '', '');
  my $el2 = $doc->implementation->create_document_type ('a', '', '');

  $doc->append_child ($el1);
  $doc->append_child ($el2);

  is $doc->child_nodes->length, 2;
  is $doc->first_child, $el1;
  is $doc->last_child, $el2;
  
  done $c;
} n => 3, name => 'doc > multiple doctypes, allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;

  my $el1 = $doc->create_element ('f');
  my $el2 = $doc->implementation->create_document_type ('a', '', '');

  $doc->append_child ($el1);
  $doc->append_child ($el2);

  is $doc->child_nodes->length, 2;
  is $doc->first_child, $el1;
  is $doc->last_child, $el2;
  
  done $c;
} n => 3, name => 'doc > el + doctype, allowed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;

  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('f');
  my $el2 = $doc->create_element ('f');
  my $el3 = $doc->implementation->create_document_type ('a', '', '');
  my $el4 = $doc->implementation->create_document_type ('a', '', '');
  $df->append_child ($el1);
  $df->append_child ($el2);

  $doc->append_child ($df);
  $doc->append_child ($el3);
  $doc->append_child ($el4);

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
  $doc->dom_config->{manakai_strict_document_children} = 0;

  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('f');
  my $el2 = $doc->create_element ('f');
  my $el3 = $doc->implementation->create_document_type ('a', '', '');
  my $el4 = $doc->implementation->create_document_type ('a', '', '');
  $df->append_child ($el1);
  $df->append_child ($el2);

  $doc->insert_before ($el4, undef);
  $doc->insert_before ($el3, $el4);
  $doc->insert_before ($df, $el3);

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
  my $el = $doc->create_element ('a');
  my $df = $doc->create_document_fragment;
  $df->append_child ($doc->create_element ('b'));
  $df->append_child ($doc->create_element ('c'));

  $el->append_child ($df);

  is $el->child_nodes->length, 2;
  isa_ok $el->first_child, 'Web::DOM::Node';
  isa_ok $el->last_child, 'Web::DOM::Node';
  is $el->first_child->local_name, 'b';
  is $el->last_child->local_name, 'c';

  done $c;
} n => 5, name => 'df child GC';

run_tests;

## See also: htmltemplateelement.t

=head1 LICENSE

Copyright 2012-2014 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
