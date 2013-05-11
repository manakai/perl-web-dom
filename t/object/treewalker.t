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
  my $el = $doc->create_element ('e');
  my $filter = sub { };
  my $tw = $doc->create_tree_walker ($el, 0xFFFFFFFF, $filter, 1);

  ok $tw->isa ('Web::DOM::TreeWalker'), 'create_tw [2] if';
  is $tw->what_to_show, 0xFFFFFFFF, 'create_tw [2] what_to_show';
  is $tw->filter, $filter, 'create_tw [2] filter';
  ok not ($tw->expand_entity_references), 'create_tw [2] xent';
  is $tw->current_node, $el, 'create_tw [2] current_node';
  is $tw->root, $el, 'create_tw [2] root';
  done $c;
} n => 6;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('e');
  my $filter = sub { };
  my $tw = $doc->create_tree_walker ($el, 0xFFFFFFFF, $filter, 0);

  ok $tw->isa ('Web::DOM::TreeWalker'), 'create_tw [3] if';
  is $tw->what_to_show, 0xFFFFFFFF, 'create_tw [3] what_to_show';
  is $tw->filter, $filter, 'create_tw [3] filter';
  ok not ($tw->expand_entity_references), 'create_tw [3] xent';
  is $tw->current_node, $el, 'create_tw [3] current_node';
  is $tw->root, $el, 'create_tw [3] root';
  done $c;
} n => 6;

{
  my $doc = new Web::DOM::Document;
  my $tw = $doc->create_tree_walker ($doc);

  my %tree1;
  $tree1{el1} = $doc->create_element ('el1');
  $tree1{el2} = $doc->create_element ('el2');
  $tree1{el3} = $doc->create_element ('el3');
  $tree1{el4} = $doc->create_element ('el4');
  $tree1{el1}->append_child ($tree1{el2});
  $tree1{el1}->append_child ($tree1{el3});
  $tree1{el3}->append_child ($tree1{el4});

  my %tree2;
  $tree2{el1} = $doc->create_element ('el1');
  $tree2{el2} = $doc->create_element ('el2');
  $tree2{el3} = $doc->create_element ('el3');
  $tree2{el4} = $doc->create_element ('el4');
  $tree2{el5} = $doc->create_element ('el5');
  $tree2{el1}->append_child ($tree2{el2});
  $tree2{el1}->append_child ($tree2{el3});
  $tree2{el3}->append_child ($tree2{el4});
  $tree2{el3}->append_child ($tree2{el5});

  my %tree3;
  $tree3{el1} = $doc->create_element ('el1');
  $tree3{el2} = $doc->create_element ('el2');
  $tree3{el3} = $doc->create_element ('el3');
  $tree3{el4} = $doc->create_element ('el4');
  $tree3{el5} = $doc->create_element ('el5');
  $tree3{el1}->append_child ($tree3{el2});
  $tree3{el1}->append_child ($tree3{el3});
  $tree3{el3}->append_child ($tree3{el4});
  $tree3{el1}->append_child ($tree3{el5});

  my %tree4;
  $tree4{el1} = $doc->create_element ('el1');
  $tree4{el3} = $doc->create_element ('el3');
  $tree4{el4} = $doc->create_element ('el4');
  $tree4{el5} = $doc->create_element ('el5');
  $tree4{el6} = $doc->create_element ('el6');
  $tree4{el1}->append_child ($tree4{el3});
  $tree4{el3}->append_child ($tree4{el4});
  $tree4{el1}->append_child ($tree4{el5});
  $tree4{el1}->append_child ($tree4{el6});

  my %tree5;
  $tree5{el1} = $doc->create_element ('el1');
  $tree5{el2} = $doc->create_element ('el2');
  $tree5{el3} = $doc->create_element ('el3');
  $tree5{el4} = $doc->create_element ('el4');
  $tree5{el5} = $doc->create_element ('el5');
  $tree5{el1}->append_child ($tree5{el2});
  $tree5{el1}->append_child ($tree5{el3});
  $tree5{el1}->append_child ($tree5{el5});
  $tree5{el3}->append_child ($tree5{el4});

  test {
    my $c = shift;
    my $el = $doc->create_element ('e');
    $tw->current_node ($el);
    is $tw->current_node, $el, 'current_node set [1]';
    done $c;
  } n => 1, name => 'current_node setter';

  test {
    my $c = shift;
    my $tw = $doc->create_tree_walker ($doc);
    dies_here_ok {
      $tw->current_node (undef);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->message, 'The new value is not a Node';
    done $c;
  } n => 3, name => 'current_node setter undef';

  test {
    my $c = shift;
    my $tw = $doc->create_tree_walker ($tree2{el1}, 0xFFFFFFFF);
    ok $tw->can ('first_child'), 'can first_child';

    is $tw->first_child, $tree2{el2}, 'fc fc [1]';
    is $tw->current_node, $tree2{el2}, 'fc cn [1]';

    is $tw->first_child, undef, 'fc fc [2]';
    is $tw->current_node, $tree2{el2}, 'fc cn [2]';

    $tw->current_node ($tree2{el3});
    is $tw->first_child, $tree2{el4}, 'fc fc [3]';
    is $tw->current_node, $tree2{el4}, 'fc cn [3]';

    is $tw->first_child, undef, 'fc fc [4]';
    is $tw->current_node, $tree2{el4}, 'fc cn [4]';
    done $c;
  } n => 9, name => 'first_child';

  test {
    my $c = shift;
    my $tw = $doc->create_tree_walker ($tree1{el1}, 0x00000002); # SHOW_ATTRIBUTE

    is $tw->first_child, undef, 'fc fc [5]';
    is $tw->current_node, $tree1{el1}, 'fc cn [5]';

    $tw->current_node ($tree1{el2});
    is $tw->first_child, undef, 'fc fc [6]';
    is $tw->current_node, $tree1{el2}, 'fc cn [6]';

    $tw->current_node ($tree1{el3});
    is $tw->first_child, undef, 'fc fc [7]';
    is $tw->current_node, $tree1{el3}, 'fc cn [7]';

    $tw->current_node ($tree1{el4});
    is $tw->first_child, undef, 'fc fc [8]';
    is $tw->current_node, $tree1{el4}, 'fc cn [8]';
    done $c;
  } n => 8, name => 'first_child';

  test {
    my $c = shift;
    my $tw = $doc->create_tree_walker ($tree4{el1}, 0xFFFFFFFF, undef, 0);

    is $tw->first_child, $tree4{el3}, 'fc fc [9]';
    is $tw->current_node, $tree4{el3}, 'fc cn [9]';
    
    $tw->current_node ($tree4{el1});
    is $tw->first_child, $tree4{el3}, 'fc fc [10]';
    is $tw->current_node, $tree4{el3}, 'fc cn [10]';

    $tw->current_node ($tree4{el3});
    is $tw->first_child, $tree4{el4}, 'fc fc [11]';
    is $tw->current_node, $tree4{el4}, 'fc cn [11]';

    is $tw->first_child, undef, 'fc fc [12]';
    is $tw->current_node, $tree4{el4}, 'fc cn [12]';

    $tw->current_node ($tree4{el5});
    is $tw->first_child, undef, 'fc fc [13]';
    is $tw->current_node, $tree4{el5}, 'fc cn [13]';

    $tw->current_node ($tree4{el6});
    is $tw->first_child, undef, 'fc fc [14]';
    is $tw->current_node, $tree4{el6}, 'fc cn [14]';
    done $c;
  } n => 12, name => 'first_child';

  {
    my $tw = $doc->create_tree_walker
        ($tree4{el1}, 0xFFFFFFFF, sub { 1 }, 1);
    
    for my $test (
       ['el1', 'el1', 'el3', 'el3'],
       ['el3', 'el3', 'el4', 'el4'],
       ['el4', 'el4', undef, 'el4'],
       ['el5', 'el5', undef, 'el5'],
       ['el6', 'el6', undef, 'el6'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree4{$test->[1]}) if $test->[1];
        is $tw->first_child, $test->[2] ? $tree4{$test->[2]} : undef,
            'first_child [4] ' . $test->[0] . ' first_child';
        is $tw->current_node, $tree4{$test->[3]},
            'first_child [4] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => ['first_child', @$test];
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree2{el1}, 0xFFFFFFFF);
    for my $test (
       ['el1', 'el1', 'el3', 'el3'],
       ['el3', 'el3', 'el5', 'el5'],
       ['el5', 'el5', undef, 'el5'],
       ['el2', 'el2', undef, 'el2'],
       ['el4', 'el4', undef, 'el4'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree2{$test->[1]}) if $test->[1];
        is $tw->last_child, $test->[2] ? $tree2{$test->[2]} : undef,
            'last_child [1] ' . $test->[0] . ' last_child';
        is $tw->current_node, $tree2{$test->[3]},
            'last_child [1] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'last_child';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree1{el1}, 0x00000002); # SHOW_ATTRIBUTE

    for my $test (
       ['el1', 'el1', undef],
       ['el2', 'el2', undef],
       ['el3', 'el3', undef],
       ['el4', 'el4', undef],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree1{$test->[1]}) if $test->[1];
        is $tw->last_child, $test->[2] ? $tree1{$test->[2]} : undef,
            'last_child [2] ' . $test->[0] . ' last_child';
        is $tw->current_node, $tree1{$test->[2] || $test->[1] || $test->[0]},
            'last_child [2] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'last_child';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree5{el1}, 0xFFFFFFFF, undef, 0);

    for my $test (
       ['el1', 'el1', 'el5'],
       ['el2', 'el2', undef],
       ['el3', 'el3', 'el4'],
       ['el4', 'el4', undef],
       ['el5', 'el5', undef],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree5{$test->[1]}) if $test->[1];
        is $tw->last_child, $test->[2] ? $tree5{$test->[2]} : undef,
            'last_child [3] ' . $test->[0] . ' last_child';
        is $tw->current_node, $tree5{$test->[2] || $test->[1] || $test->[0]},
            'last_child [3] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'last_child';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree5{el1}, 0xFFFFFFFF, sub { 1 }, 1);

    for my $test (
       ['el1', 'el1', 'el5'],
       ['el3', 'el3', 'el4'],
       ['el4', 'el4', undef],
       ['el5', 'el5', undef],
       ['el2', 'el2', undef],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree5{$test->[1]}) if $test->[1];
        is $tw->last_child, $test->[2] ? $tree5{$test->[2]} : undef,
            'last_child [4] ' . $test->[0] . ' last_child';
        is $tw->current_node, $tree5{$test->[2] || $test->[1] || $test->[0]},
            'last_child [4] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'last_child';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree1{el1}, 0xFFFFFFFF);

    for my $test (
       ['el1', 'el1', undef],
       ['el4', 'el4', 'el3'],
       ['el3', 'el3', 'el1'],
       ['el2', 'el2', 'el1'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree1{$test->[1]}) if $test->[1];
        is $tw->parent_node, $test->[2] ? $tree1{$test->[2]} : undef,
            'parent_node [1] ' . $test->[0] . ' parent_node';
        is $tw->current_node, $tree1{$test->[2] || $test->[1] || $test->[0]},
            'parent_node [1] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'parent_node';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree1{el1}, 0xFFFFFFFF, sub {
      $_[1]->local_name eq 'el3' ? 1 : 2 # ACCEPT : REJECT
    });

    for my $test (
       ['el1', 'el1', undef],
       ['el2', 'el2', undef],
       ['el3', 'el3', undef],
       ['el4', 'el4', 'el3'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree1{$test->[1]});
        is $tw->parent_node, $test->[2] ? $tree1{$test->[2]} : undef,
            'parent_node [2] ' . $test->[0] . ' parent_node';
        is $tw->current_node, $tree1{$test->[2] || $test->[1] || $test->[0]},
            'parent_node [2] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'parent_node';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree1{el1}, 0xFFFFFFFF, sub {
      $_[1]->local_name eq 'el3' ? 3 : 1 # SKIP : ACCEPT
    });

    for my $test (
       ['el1', 'el1', undef],
       ['el2', 'el2', 'el1'],
       ['el3', 'el3', 'el1'],
       ['el4', 'el4', 'el1'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree1{$test->[1]});
        is $tw->parent_node, $test->[2] ? $tree1{$test->[2]} : undef,
            'parent_node [3] ' . $test->[0] . ' parent_node';
        is $tw->current_node, $tree1{$test->[2] || $test->[1] || $test->[0]},
            'parent_node [3] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'parent_node';
    }
  }

  {
    ## NOTE: FILTER_REJECT works as if FILTER_SKIP if the currentNode
    ## is in the rejected subtree.

    my $tw = $doc->create_tree_walker ($tree1{el1}, 0xFFFFFFFF, sub {
      $_[1]->local_name eq 'el3' ? 2 : 1 # REJECT : ACCEPT
    });

    for my $test (
       ['el1', 'el1', undef],
       ['el2', 'el2', 'el1'],
       ['el3', 'el3', 'el1'],
       ['el4', 'el4', 'el1'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree1{$test->[1]});
        is $tw->parent_node, $test->[2] ? $tree1{$test->[2]} : undef,
            'parent_node [4] ' . $test->[0] . ' parent_node';
        is $tw->current_node, $tree1{$test->[2] || $test->[1] || $test->[0]},
            'parent_node [4] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'parent_node';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree4{el1}, 0xFFFFFFFF, undef, 0);

    for my $test (
       ['el1', 'el1', undef],
       ['el3', 'el3', 'el1'],
       ['el4', 'el4', 'el3'],
       ['el5', 'el5', 'el1'],
       ['el6', 'el6', 'el1'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree4{$test->[1]});
        is $tw->parent_node, $test->[2] ? $tree4{$test->[2]} : undef,
            'parent_node [5] ' . $test->[0] . ' parent_node';
        is $tw->current_node, $tree4{$test->[2] || $test->[1] || $test->[0]},
            'parent_node [5] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => ['parent_node', @$test];
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree5{el1}, 0xFFFFFFFF, sub { 1 }, 1);
    for my $test (
       ['el1', 'el1', undef],
       ['el3', 'el3', 'el1'],
       ['el4', 'el4', 'el3'],
       ['el5', 'el5', 'el1'],
       ['el2', 'el2', 'el1'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree5{$test->[1]}) if $test->[1];
        is $tw->parent_node, $test->[2] ? $tree5{$test->[2]} : undef,
            'parent_node [6] ' . $test->[0] . ' parent_node';
        is $tw->current_node, $tree5{$test->[2] || $test->[1] || $test->[0]},
            'parent_node [6] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'parent_node';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree3{el1}, 0xFFFFFFFF);
    for my $test (
       ['el1', 'el1', 'el2'],
       ['el2', 'el2', 'el3'],
       ['el3', 'el3', 'el4'],
       ['el4', 'el4', 'el5'],
       ['el5', 'el5', undef],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree3{$test->[1]}) if $test->[1];
        is $tw->next_node, $test->[2] ? $tree3{$test->[2]} : undef,
            'next_node [1] ' . $test->[0] . ' next_node';
        is $tw->current_node, $tree3{$test->[2] || $test->[1] || $test->[0]},
            'next_node [1] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'next_node';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree3{el3}, 0xFFFFFFFF);

    for my $test (
       ['el1', 'el1', 'el2'],
       ['el2', 'el2', 'el3'],
       ['el3', 'el3', 'el4'],
       ['el4', 'el4', undef],
       ['el5', 'el5', undef],
     ) {
      test {
        my $c = shift;
        $tw->current_node ($tree3{$test->[1]});
        is $tw->next_node, $test->[2] ? $tree3{$test->[2]} : undef,
            'next_node [2] ' . $test->[0] . ' next_node';
        is $tw->current_node, $tree3{$test->[2] || $test->[1] || $test->[0]},
            'next_node [2] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => ['next_node', @$test];
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree3{el1}, 0xFFFFFFFF, sub {
      $_[1]->local_name eq 'el3' ? 3 : 1 # SKIP : ACCEPT
    });

    for my $test (
       ['el1', 'el1', 'el2'],
       ['el2', 'el2', 'el4'],
       ['el3', 'el3', 'el4'],
       ['el4', 'el4', 'el5'],
       ['el5', 'el5', undef],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree3{$test->[1]}) if $test->[1];
        is $tw->next_node, $test->[2] ? $tree3{$test->[2]} : undef,
            'next_node [3] ' . $test->[0] . ' next_node';
        is $tw->current_node, $tree3{$test->[2] || $test->[1] || $test->[0]},
            'next_node [3] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'next_node';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree3{el1}, 0xFFFFFFFF, sub {
      $_[1]->local_name eq 'el3' ? 2 : 1 # REJECT : ACCEPT
    });
    for my $test (
       ['el1', 'el1', 'el2'],
       ['el2', 'el2', 'el5'],
       ['el3', 'el3', 'el4'],
       ['el4', 'el4', 'el5'],
       ['el5', 'el5', undef],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree3{$test->[1]}) if $test->[1];
        is $tw->next_node, $test->[2] ? $tree3{$test->[2]} : undef,
            'next_node [4] ' . $test->[0] . ' next_node';
        is $tw->current_node, $tree3{$test->[2] || $test->[1] || $test->[0]},
            'next_node [4] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => ['next_node', @$test];
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree4{el1}, 0xFFFFFFFF);
    for my $test (
       ['el1', 'el1', 'el3'],
       ['el3', 'el3', 'el4'],
       ['el4', 'el4', 'el5'],
       ['el5', 'el5', 'el6'],
       ['el6', 'el6', undef],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree4{$test->[1]}) if $test->[1];
        is $tw->next_node, $test->[2] ? $tree4{$test->[2]} : undef,
            'next_node [5] ' . $test->[0] . ' next_node';
        is $tw->current_node, $tree4{$test->[2] || $test->[1] || $test->[0]},
            'next_node [5] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => ['next_node', @$test];
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree4{el1}, 0xFFFFFFFF, sub { 1 }, 1);
    for my $test (
       ['el1', 'el1', 'el3'],
       ['el3', 'el3', 'el4'],
       ['el4', 'el4', 'el5'],
       ['el5', 'el5', 'el6'],
       ['el6', 'el6', undef],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree4{$test->[1]}) if $test->[1];
        is $tw->next_node, $test->[2] ? $tree4{$test->[2]} : undef,
            'next_node [6] ' . $test->[0] . ' next_node';
        is $tw->current_node, $tree4{$test->[2] || $test->[1] || $test->[0]},
            'next_node [6] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'next_node';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree3{el1}, 0xFFFFFFFF);
    for my $test (
       ['el1', 'el1', undef],
       ['el2', 'el2', 'el3'],
       ['el3', 'el3', 'el5'],
       ['el4', 'el4', undef],
       ['el5', 'el5', undef],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree3{$test->[1]}) if $test->[1];
        is $tw->next_sibling, $test->[2] ? $tree3{$test->[2]} : undef,
            'next_sibling [1] ' . $test->[0] . ' next_sibling';
        is $tw->current_node, $tree3{$test->[2] || $test->[1] || $test->[0]},
            'next_sibling [1] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'next_sibling';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree3{el3}, 0xFFFFFFFF);
    for my $test (
       ['el1', 'el1', undef],
       ['el2', 'el2', 'el3'],
       ['el3', 'el3', undef],
       ['el4', 'el4', undef],
       ['el5', 'el5', undef],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree3{$test->[1]}) if $test->[1];
        is $tw->next_sibling, $test->[2] ? $tree3{$test->[2]} : undef,
            'next_sibling [2] ' . $test->[0] . ' next_sibling';
        is $tw->current_node, $tree3{$test->[2] || $test->[1] || $test->[0]},
            'next_sibling [2] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'next_sibling';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree3{el1}, 0xFFFFFFFF, sub {
      $_[1]->local_name eq 'el3' ? 3 : 1 # SKIP : ACCEPT
    });
    for my $test (
       ['el1', 'el1', undef],
       ['el2', 'el2', 'el4'],
       ['el3', 'el3', 'el5'],
       ['el4', 'el4', 'el5'],
       ['el5', 'el5', undef],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree3{$test->[1]}) if $test->[1];
        is $tw->next_sibling, $test->[2] ? $tree3{$test->[2]} : undef,
            'next_sibling [3] ' . $test->[0] . ' next_sibling';
        is $tw->current_node, $tree3{$test->[2] || $test->[1] || $test->[0]},
            'next_sibling [3] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'next_sibling';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree3{el1}, 0xFFFFFFFF, sub {
      $_[1]->local_name eq 'el3' ? 2 : 1 # REJECT : ACCEPT
    });
    for my $test (
       ['el1', 'el1', undef],
       ['el2', 'el2', 'el5'],
       ['el3', 'el3', 'el5'],
       ['el4', 'el4', 'el5'],
       ['el5', 'el5', undef],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree3{$test->[1]}) if $test->[1];
        is $tw->next_sibling, $test->[2] ? $tree3{$test->[2]} : undef,
            'next_sibling [4] ' . $test->[0] . ' next_sibling';
        is $tw->current_node, $tree3{$test->[2] || $test->[1] || $test->[0]},
            'next_sibling [4] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => ['next_sibling', @$test];
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree4{el1}, 0xFFFFFFFF, undef, 0);
    for my $test (
       ['el1', 'el1', undef],
       ['el3', 'el3', 'el5'],
       ['el4', 'el4', undef],
       ['el5', 'el5', 'el6'],
       ['el6', 'el6', undef],
     ) {
      test {
        my $c = shift;
        $tw->current_node ($tree4{$test->[1]});
        is $tw->next_sibling, $test->[2] ? $tree4{$test->[2]} : undef,
            'next_sibling [5] ' . $test->[0] . ' next_sibling';
        is $tw->current_node, $tree4{$test->[2] || $test->[1] || $test->[0]},
            'next_sibling [5] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'next_sibling';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree4{el1}, 0xFFFFFFFF, sub { 1 }, 1);
    for my $test (
       ['el1', 'el1', undef],
       ['el3', 'el3', 'el5'],
       ['el4', 'el4', undef],
       ['el5', 'el5', 'el6'],
       ['el6', 'el6', undef],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree4{$test->[1]}) if $test->[1];
        is $tw->next_sibling, $test->[2] ? $tree4{$test->[2]} : undef,
            'next_sibling [6] ' . $test->[0] . ' next_sibling';
        is $tw->current_node, $tree4{$test->[2] || $test->[1] || $test->[0]},
            'next_sibling [6] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'next_sibling';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree3{el1}, 0xFFFFFFFF);
    for my $test (
       ['el1', 'el1', undef],
       ['el2', 'el2', 'el1'],
       ['el3', 'el3', 'el2'],
       ['el4', 'el4', 'el3'],
       ['el5', 'el5', 'el4'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree3{$test->[1]}) if $test->[1];
        is $tw->previous_node, $test->[2] ? $tree3{$test->[2]} : undef,
            'previous_node [1] ' . $test->[0] . ' previous_node';
        is $tw->current_node, $tree3{$test->[2] || $test->[1] || $test->[0]},
            'previous_node [1] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'previous_node';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree3{el3}, 0xFFFFFFFF);
    for my $test (
       ['el1', 'el1', undef],
       ['el2', 'el2', 'el1'],
       ['el3', 'el3', undef],
       ['el4', 'el4', 'el3'],
       ['el5', 'el5', 'el4'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree3{$test->[1]}) if $test->[1];
        is $tw->previous_node, $test->[2] ? $tree3{$test->[2]} : undef,
            'previous_node [2] ' . $test->[0] . ' next_node';
        is $tw->current_node, $tree3{$test->[2] || $test->[1] || $test->[0]},
            'previous_node [2] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'previous_node';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree3{el1}, 0xFFFFFFFF, sub {
      $_[1]->local_name eq 'el3' ? 3 : 1 # SKIP : ACCEPT
    });
    for my $test (
       ['el1', 'el1', undef],
       ['el2', 'el2', 'el1'],
       ['el3', 'el3', 'el2'],
       ['el4', 'el4', 'el2'],
       ['el5', 'el5', 'el4'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree3{$test->[1]}) if $test->[1];
        is $tw->previous_node, $test->[2] ? $tree3{$test->[2]} : undef,
            'previous_node [3] ' . $test->[0] . ' next_node';
        is $tw->current_node, $tree3{$test->[2] || $test->[1] || $test->[0]},
            'previous_node [3] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'previous_node';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree3{el1}, 0xFFFFFFFF, sub {
      $_[1]->local_name eq 'el3' ? 2 : 1 # REJECT : ACCEPT
    });
    for my $test (
       ['el1', 'el1', undef],
       ['el2', 'el2', 'el1'],
       ['el3', 'el3', 'el2'],
       ['el4', 'el4', 'el2'],
       ['el5', 'el5', 'el2'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree3{$test->[1]}) if $test->[1];
        is $tw->previous_node, $test->[2] ? $tree3{$test->[2]} : undef,
            'previous_node [4] ' . $test->[0] . ' next_node';
        is $tw->current_node, $tree3{$test->[2] || $test->[1] || $test->[0]},
            'previous_node [4] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'previous_node';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree4{el1}, 0xFFFFFFFF, undef, 0);
    for my $test (
       ['el1', 'el1', undef],
       ['el3', 'el3', 'el1'],
       ['el4', 'el4', 'el3'],
       ['el5', 'el5', 'el4'],
       ['el6', 'el6', 'el5'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree4{$test->[1]}) if $test->[1];
        is $tw->previous_node, $test->[2] ? $tree4{$test->[2]} : undef,
            'previous_node [5] ' . $test->[0] . ' next_node';
        is $tw->current_node, $tree4{$test->[2] || $test->[1] || $test->[0]},
            'previous_node [5] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'previous_node';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree4{el1}, 0xFFFFFFFF, sub { 1 }, 1);
    for my $test (
       ['el1', 'el1', undef],
       ['el3', 'el3', 'el1'],
       ['el4', 'el4', 'el3'],
       ['el5', 'el5', 'el4'],
       ['el6', 'el6', 'el5'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree4{$test->[1]}) if $test->[1];
        is $tw->previous_node, $test->[2] ? $tree4{$test->[2]} : undef,
            'previous_node [6] ' . $test->[0] . ' previous_node';
        is $tw->current_node, $tree4{$test->[2] || $test->[1] || $test->[0]},
            'previous_node [6] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'previous_node';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree3{el1}, 0xFFFFFFFF);
    for my $test (
       ['el1', 'el1', undef],
       ['el2', 'el2', undef],
       ['el3', 'el3', 'el2'],
       ['el4', 'el4', undef],
       ['el5', 'el5', 'el3'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree3{$test->[1]}) if $test->[1];
        is $tw->previous_sibling, $test->[2] ? $tree3{$test->[2]} : undef,
            'previous_sibling [1] ' . $test->[0] . ' previous_sibling';
        is $tw->current_node, $tree3{$test->[2] || $test->[1] || $test->[0]},
            'previous_sibling [1] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'previous_sibling';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree3{el3}, 0xFFFFFFFF);
    for my $test (
       ['el1', 'el1', undef],
       ['el2', 'el2', undef],
       ['el3', 'el3', undef],
       ['el4', 'el4', undef],
       ['el5', 'el5', 'el3'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree3{$test->[1]}) if $test->[1];
        is $tw->previous_sibling, $test->[2] ? $tree3{$test->[2]} : undef,
            'previous_sibling [2] ' . $test->[0] . ' previous_sibling';
        is $tw->current_node, $tree3{$test->[2] || $test->[1] || $test->[0]},
            'previous_sibling [2] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'previous_sibling';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree3{el1}, 0xFFFFFFFF, sub {
      $_[1]->local_name eq 'el3' ? 3 : 1 # SKIP : ACCEPT
    });
    for my $test (
       ['el1', 'el1', undef],
       ['el2', 'el2', undef],
       ['el3', 'el3', 'el2'],
       ['el4', 'el4', 'el2'],
       ['el5', 'el5', 'el4'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree3{$test->[1]}) if $test->[1];
        is $tw->previous_sibling, $test->[2] ? $tree3{$test->[2]} : undef,
            'previous_sibling [3] ' . $test->[0] . ' previous_sibling';
        is $tw->current_node, $tree3{$test->[2] || $test->[1] || $test->[0]},
            'previous_sibling [3] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'previous_sibling';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree3{el1}, 0xFFFFFFFF, sub {
      $_[1]->local_name eq 'el3' ? 2 : 1 # REJECT : ACCEPT
    });
    for my $test (
       ['el1', 'el1', undef],
       ['el2', 'el2', undef],
       ['el3', 'el3', 'el2'],
       ['el4', 'el4', 'el2'],
       ['el5', 'el5', 'el2'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree3{$test->[1]}) if $test->[1];
        is $tw->previous_sibling, $test->[2] ? $tree3{$test->[2]} : undef,
            'previous_sibling [4] ' . $test->[0] . ' previous_sibling';
        is $tw->current_node, $tree3{$test->[2] || $test->[1] || $test->[0]},
            'previous_sibling [4] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'previous_sibling';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree4{el1}, 0xFFFFFFFF, undef, 0);
    for my $test (
       ['el1', 'el1', undef],
       ['el3', 'el3', undef],
       ['el4', 'el4', undef],
       ['el5', 'el5', 'el3'],
       ['el6', 'el6', 'el5'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree4{$test->[1]}) if $test->[1];
        is $tw->previous_sibling, $test->[2] ? $tree4{$test->[2]} : undef,
            'previous_sibling [5] ' . $test->[0] . ' previous_sibling';
        is $tw->current_node, $tree4{$test->[2] || $test->[1] || $test->[0]},
            'previous_sibling [5] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'previous_sibling';
    }
  }

  {
    my $tw = $doc->create_tree_walker ($tree4{el1}, 0xFFFFFFFF, sub { 1 }, 1);
    for my $test (
       ['el1', 'el1', undef],
       ['el3', 'el3', undef],
       ['el4', 'el4', undef],
       ['el5', 'el5', 'el3'],
       ['el6', 'el6', 'el5'],
    ) {
      test {
        my $c = shift;
        $tw->current_node ($tree4{$test->[1]}) if $test->[1];
        is $tw->previous_sibling, $test->[2] ? $tree4{$test->[2]} : undef,
            'previous_sibling [6] ' . $test->[0] . ' previous_sibling';
        is $tw->current_node, $tree4{$test->[2] || $test->[1] || $test->[0]},
            'previous_sibling [6] ' . $test->[0] . ' current_node';
        done $c;
      } n => 2, name => 'previous_sibling';
    }
  }
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('nb7a');
  $doc->append_child ($el);
  my $tw = $doc->create_tree_walker ($doc, undef, sub {
    die "hoge";
  });
  dies_ok {
    $tw->next_node;
  };
  like $@, qr{^hoge at };
  is $tw->current_node, $doc;
  done $c;
} n => 3, name => 'nodefilter exception, next_node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('nb7a');
  $doc->append_child ($el);
  my $x = {};
  my $tw = $doc->create_tree_walker ($doc, undef, sub {
    die $x;
  });
  $tw->current_node ($el);
  dies_ok {
    $tw->previous_node;
  };
  is $@, $x;
  is ref $@, 'HASH';
  is $tw->current_node, $el;
  done $c;
} n => 4, name => 'nodefilter exception, previous_node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $et = $doc->create_element_type_definition ('hoge');
  my $tw = $doc->create_tree_walker ($doc, 0xFFFFFFFF);
  $tw->current_node ($et);
  is $tw->next_node, undef;
  is $tw->parent_node, undef;
  is $tw->previous_node, undef;
  done $c;
} n => 3, name => 'element_type_definition';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute ('aaA');
  my $tw = $doc->create_tree_walker ($doc, 0xFFFFFFFF);
  $tw->current_node ($attr);
  is $tw->next_node, undef;
  is $tw->parent_node, undef;
  is $tw->previous_node, undef;
  done $c;
} n => 3, name => 'attr';

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
  my $tw = $doc->create_tree_walker ($el1, 0xFFFFFFFF, sub {
    my $wa = wantarray;
    test {
      ok defined $wa;
      ok not $wa;
    } $c;
    $_[1] eq $el3 ? 2**16 + 3 : 1 - 2**16; # SKIP : ACCEPT
  });
  $tw->current_node ($el2);
  is $tw->next_sibling, $el4;
  done $c;
} n => 2*2 + 1, name => 'filter callback return';

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
  my $tw = $doc->create_tree_walker ($el1, 0, sub { 1 });
  is $tw->next_node, undef;
  $tw->current_node ($el3);
  is $tw->next_node, undef;
  is $tw->parent_node, undef;
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
  my $tw; $tw = $doc->create_tree_walker ($el1, undef, sub {
    $tw->next_node;
    ok 0;
  });
  dies_ok {
    $tw->next_node;
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidStateError';
  is $@->message, 'TreeWalker is active';
  is $tw->current_node, $el1;
  done $c;
  undef $tw;
} n => 5, name => 'treewalker exception';

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
  my $tw; $tw = $doc->create_tree_walker ($el1, undef, sub {
    dies_here_ok {
      $tw->next_node;
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'InvalidStateError';
    is $@->message, 'TreeWalker is active';
    return 1;
  });
  is $tw->next_node, $el2;
  is $tw->current_node, $el2;
  done $c;
  undef $tw;
} n => 6, name => 'treewalker exception';

run_tests;

=head1 LICENSE

Copyright 2007-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
