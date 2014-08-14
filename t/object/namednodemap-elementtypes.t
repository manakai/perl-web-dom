use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

{
  package test::DestroyCallback;
  sub DESTROY {
    $_[0]->();
  }
}

sub GET ($$) {
  my ($dt, $name) = @_;
  my $node = $dt->get_element_type_definition_node ($name);
  return $node ? $node->get_user_data ('value') : undef;
} # GET

sub SET ($$$) {
  my ($dt, $name, $value) = @_;
  my $node = $dt->owner_document->create_element_type_definition ($name);
  $node->set_user_data (value => $value);
  $dt->set_element_type_definition_node ($node);
} # SET

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_type_definition ('a');
  my $called;
  $node->set_user_data (destroy => bless sub {
                         $called = 1;
                       }, 'test::DestroyCallback');

  my $nl = $node->element_types;
  isa_ok $nl, 'Web::DOM::NamedNodeMap';
  is scalar @$nl, 0;
  is $nl->length, 0;

  undef $node;
  ok not $called;

  undef $nl;
  ok $called;

  done $c;
} n => 5, name => 'element_type_definitions empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_type_definition ('a');
  SET ($node, hoge => 1);
  SET ($node, abc => 2);
  my $called;
  $node->set_user_data (destroy => bless sub {
                         $called = 1;
                       }, 'test::DestroyCallback');

  my $nl = $node->element_types;
  isa_ok $nl, 'Web::DOM::NamedNodeMap';
  is scalar @$nl, 2;
  is $nl->length, 2;

  undef $node;
  ok not $called;

  undef $nl;
  ok $called;

  done $c;
} n => 5, name => 'element_type_definitions not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_document_type_definition ('a');

  my $nl = $node->element_types;
  my $nl2 = $node->element_types;
  
  is $nl2, $nl;

  my $node2 = $doc->create_document_type_definition ('b');
  my $nl3 = $node2->element_types;

  isnt $nl3, $nl;

  SET ($node, 'bb', 'CC');

  is scalar @$nl, 1;
  is $nl->length, 1;
  
  done $c;
} n => 4, name => 'element_type_definitions liveness and sameness';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_type_definition ('a');
  my $node2 = $doc->create_text_node ('a');

  my $nl = $node->element_types;

  dies_here_ok {
    $nl->[0] = $node2;
  };
  ok not ref $@;
  like $@, qr{^Modification of a read-only value attempted};

  is scalar @$nl, 0;
  ok not $node->element_types->length;
  ok not $node2->parent_node;

  done $c;
} n => 6, name => 'element_type_definitions read-only';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_type_definition ('a');
  my $node2 = $doc->create_element_type_definition ('a');
  my $node3 = $doc->create_element_type_definition ('a');
  $node->set_element_type_definition_node ($node3);

  my $nl = $node->element_types;

  dies_here_ok {
    $nl->[0] = $node2;
  };
  ok not ref $@;
  like $@, qr{^Modification of a read-only value attempted};

  is scalar @$nl, 1;
  is $nl->[0], $node3;
  is $node3->owner_document_type_definition, $node;
  is $node2->owner_document_type_definition, undef;

  $$node3->[100] = 14;
  is $$node3->[100], 14;

  done $c;
} n => 8, name => 'element_types read-only';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_type_definition ('a');
  my $node2 = $doc->create_document_type_definition ('a');

  my $nl = $node->element_types;
  my $nl_s = $nl . '';
  undef $nl;

  my $nl2 = $node->element_types;
  my $nl2_s = $nl2 . '';

  ok $nl2_s eq $nl_s;
  ok not $nl2_s ne $nl_s;
  ok not $nl2 eq $nl_s;
  ok $nl2 ne $nl_s;
  ok not $nl2 eq undef;
  ok $nl2 ne undef;
  ok $nl2 eq $node->element_types;
  ok not $nl2 ne $node->element_types;
  is $nl2 cmp $node->element_types, 0;
  isnt $nl2 cmp $node->element_types, undef;

  my $nl3 = $node2->element_types;
  ok $nl3 ne $nl2;
  ok not $nl3 eq $nl2;

  ok $nl2;

  done $c;
} n => 13, name => 'element_type_definitions comparison';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_document_type_definition ('a');
  my $nl = $node->element_types;

  is $nl->length, 0;
  is scalar @$nl, 0;

  is $nl->item (0), undef;
  is $nl->item (1), undef;
  is $nl->item (2), undef;
  is $nl->item (0+"inf"), undef;
  is $nl->item (0+"-inf"), undef;
  is $nl->item (0+"nan"), undef;
  is $nl->item (+0**1), undef;
  is $nl->item (-0**1), undef;
  is $nl->item (-1), undef;
  is $nl->item (-3), undef;

  is $nl->[0], undef;
  is $nl->[1], undef;
  is $nl->[2], undef;
  is scalar $nl->[0+"inf"], undef;
  is scalar $nl->[0+"-inf"], undef;
  is scalar $nl->[0+"nan"], undef;
  is $nl->[+0**1], undef;
  is $nl->[-0**1], undef;
  is scalar $nl->[-1], undef;
  is scalar $nl->[-3], undef;

  done $c;
} n => 22, name => 'element_type_definitions items, empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_document_type_definition ('a');
  my $nl = $node->element_types;
  SET ($node, fuga => 3);

  is $nl->length, 1;
  is scalar @$nl, 1;

  isa_ok $nl->item (0), 'Web::DOM::ElementTypeDefinition';
  my $el = $nl->item (0);
  is $el->node_name, 'fuga';
  is $el->get_user_data ('value'), '3';

  is $nl->item (1), undef;
  is $nl->item (2), undef;
  is $nl->item (0+"inf"), $el;
  is $nl->item (0+"-inf"), $el;
  is $nl->item (0+"nan"), $el;
  is $nl->item (+0**1), $el;
  is $nl->item (-0**1), $el;
  is $nl->item (0.52), $el;
  is $nl->item (-0.52), $el;
  is $nl->item (1.42), undef;
  is $nl->item (-1.323), undef;
  is $nl->item (-1), undef;
  is $nl->item (-3), undef;

  is $nl->[0], $el;
  is $nl->[1], undef;
  is $nl->[2], undef;
  is scalar $nl->[0+"inf"], $el;
  is scalar $nl->[0+"-inf"], [$el]->["-inf"];
  is scalar $nl->[0+"nan"], $el;
  is $nl->[+0**1], $el;
  is $nl->[-0**1], $el;
  is $nl->[0.542], $el;
  is $nl->[1.444], undef;
  is scalar $nl->[-1], $el;
  is scalar $nl->[-3], undef;
  is scalar $nl->[-2**31], undef;
  ok exists $nl->[0];
  ok exists $nl->[0.55];
  ok exists $nl->[-1];
  ok not exists $nl->[-2];
  ok not exists $nl->[1];
  ok not exists $nl->[2**31];

  done $c;
} n => 37, name => 'element_type_definitions items, empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_type_definition ('a');
  my $nl = $node->element_types;

  my $array1 = $nl->to_a;
  is ref $array1, 'ARRAY';
  is_deeply $array1, [];
  push @$array1, 1;
  is_deeply $array1, [1];

  $array1 = $nl->as_list;
  is ref $array1, 'ARRAY';
  is_deeply $array1, [];
  push @$array1, 1;
  is_deeply $array1, [1];

  isnt $nl->to_a, $nl->to_a;
  isnt $nl->as_list, $nl->as_list;
  isnt $nl->to_a, $nl->as_list;

  my @array2 = $nl->to_list;
  is 0+@array2, 0;
  push @array2, 1;
  is 0+@array2, 1;
  
  is 0+@$nl, 0;

  done $c;
} n => 12, name => 'element_type_definitions perl binding empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_type_definition ('a');
  my $nl = $node->element_types;
  SET ($node, zzz => 'aa');
  SET ($node, ggg => 'fwa');

  my $array1 = $nl->to_a;
  is ref $array1, 'ARRAY';
  my $el1 = $array1->[0];
  my $el2 = $array1->[1];
  is_deeply $array1, [$el1, $el2];
  push @$array1, 2;
  is_deeply $array1, [$el1, $el2, 2];

  $array1 = $nl->as_list;
  is ref $array1, 'ARRAY';
  is_deeply $array1, [$el1, $el2];
  push @$array1, 2;
  is_deeply $array1, [$el1, $el2, 2];

  isnt $nl->to_a, $nl->to_a;
  isnt $nl->as_list, $nl->as_list;
  isnt $nl->to_a, $nl->as_list;

  my @array2 = $nl->to_list;
  is 0+@array2, 2;
  push @array2, 3;
  is 0+@array2, 3;
  is $array2[0], $el1;
  is $array2[1], $el2;
  
  is 0+@$nl, 2;

  done $c;
} n => 14, name => 'element_type_definitions perl binding not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_document_type_definition ('a');
  my $col = $el->element_types;
  is $col->get_named_item ('hoge'), undef;
  is $col->get_named_item ('120'), undef;
  dies_here_ok {
    $col->get_named_item_ns (undef, 'hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotSupportedError';
  is $@->message, 'This operation is not supported';
  dies_here_ok {
    $col->get_named_item_ns ('abc', 'hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotSupportedError';
  is $@->message, 'This operation is not supported';
  done $c;
} n => 10, name => 'get not found';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_document_type_definition ('a');
  my $col = $el->element_types;
  SET ($el, 'hoge' => 112);
  SET ($el, 'fuga:aa', "aa");

  my $attr1 = $col->get_named_item ('hoge');
  isa_ok $attr1, 'Web::DOM::ElementTypeDefinition';
  is $attr1->node_name, 'hoge';
  is $attr1->get_user_data ('value'), '112';

  my $attr2 = $col->get_named_item ('fuga:aa');
  is $attr2->get_user_data ('value'), 'aa';
  
  dies_here_ok {
    $col->get_named_item_ns (undef, 'hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotSupportedError';
  is $@->message, 'This operation is not supported';
  
  dies_here_ok {
    $col->get_named_item_ns ('aaa', 'aa');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotSupportedError';
  is $@->message, 'This operation is not supported';
  
  done $c;
} n => 12, name => 'get found';

for my $method (qw(set_named_item)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_document_type_definition ('a');
    my $attr = $doc->create_element_type_definition ('b');
    $attr->set_user_data (value => '');
    my $col = $el->element_types;
    
    is $col->$method ($attr), undef;
    is GET ($el, 'b'), '';
    
    done $c;
  } n => 2, name => [$method, 'new'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_document_type_definition ('a');
    my $attr = $doc->create_element_type_definition ('b');
    $attr->set_user_data (value => '');
    my $col = $el->element_types;
    SET ($el, b => 21);

    my $attr2 = $col->$method ($attr), undef;
    is GET ($el, 'b'), '';
    isa_ok $attr2, 'Web::DOM::ElementTypeDefinition';
    is $attr2->owner_document_type_definition, undef;
    is $attr2->node_name, 'b';
    is $attr2->get_user_data ('value'), '21';

    done $c;
  } n => 5, name => [$method, 'replace'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_document_type_definition ('a');
    SET ($el, 'fuga' => 'abc');
    my $col = $el->element_types;

    my $attr = $col->$method ($col->[0]);
    is $attr->node_type, $attr->ELEMENT_TYPE_DEFINITION_NODE;
    is $attr->owner_document_type_definition, $el;
    is $attr->node_name, 'fuga';
    is $attr->get_user_data ('value'), 'abc';
    is GET ($el, 'fuga'), 'abc';

    done $c;
  } n => 5, name => [$method, 'self'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_document_type_definition ('a');
    SET ($el, 'fuga' => 'abc');
    my $el2 = $doc->create_document_type_definition ('a');
    my $col = $el2->element_types;

    dies_here_ok {
      $col->$method ($el->element_types->[0]);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'The specified node has already attached to another node';
    
    is $el->element_types->[0]->owner_document_type_definition, $el;
    is GET ($el, 'fuga'), 'abc';
    
    done $c;
  } n => 6, name => [$method, 'self'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_document_type_definition ('a');
    my $el2 = $doc->create_element ('a');
    my $col = $el->element_types;

    dies_here_ok {
      $col->$method ($el2);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'Specified type of node cannot be set';
    
    is $el->element_types->length, 0;
    is $el2->parent_node, undef;
    
    done $c;
  } n => 6, name => [$method, 'not attr'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_document_type_definition ('a');
    my $col = $el->element_types;

    dies_here_ok {
      $col->$method (undef);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->name, 'TypeError';
    is $@->message, 'The argument is not a Node';
    
    is $el->element_types->length, 0;
    
    done $c;
  } n => 5, name => [$method, 'not node'];
}

for my $method (qw(set_named_item_ns)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_document_type_definition ('a');
    my $attr = $doc->create_element_type_definition ('b');
    my $col = $el->element_types;

    dies_here_ok {
      $col->$method ($attr);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'NotSupportedError';
    is $@->message, 'This operation is not supported';
    
    is GET ($el, 'b'), undef;
    
    done $c;
  } n => 5, name => [$method, 'new'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_document_type_definition ('a');
    my $attr = $doc->create_element_type_definition ('b');
    my $col = $el->element_types;
    SET ($el, b => 21);

    dies_here_ok {
      $col->$method ($attr), undef;
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'NotSupportedError';
    is $@->message, 'This operation is not supported';

    is GET ($el, 'b'), '21';

    done $c;
  } n => 5, name => [$method, 'replace'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_document_type_definition ('a');
    SET ($el, 'fuga' => 'abc');
    my $col = $el->element_types;
    
    dies_here_ok {
      $col->$method ($col->[0]);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'NotSupportedError';
    is $@->message, 'This operation is not supported';
    is GET ($el, 'fuga'), 'abc';

    done $c;
  } n => 5, name => [$method, 'self'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_document_type_definition ('a');
    SET ($el, 'fuga' => 'abc');
    my $el2 = $doc->create_document_type_definition ('a');
    my $col = $el2->element_types;

    dies_here_ok {
      $col->$method ($el->element_types->[0]);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'NotSupportedError';
    is $@->message, 'This operation is not supported';
    
    is $el->element_types->[0]->owner_document_type_definition, $el;
    is GET ($el, 'fuga'), 'abc';
    
    done $c;
  } n => 6, name => [$method, 'self'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_document_type_definition ('a');
    my $el2 = $doc->create_element ('a');
    my $col = $el->element_types;

    dies_here_ok {
      $col->$method ($el2);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'NotSupportedError';
    is $@->message, 'This operation is not supported';
    
    is $el->element_types->length, 0;
    is $el2->parent_node, undef;
    
    done $c;
  } n => 6, name => [$method, 'not attr'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_document_type_definition ('a');
    my $col = $el->element_types;

    dies_here_ok {
      $col->$method (undef);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->name, 'TypeError';
    is $@->message, 'The argument is not a Node';
    
    is $el->element_types->length, 0;
    
    done $c;
  } n => 5, name => [$method, 'not node'];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_document_type_definition ('a');
  my $col = $el->element_types;

  dies_here_ok {
    $col->remove_named_item ('hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'Specified node not found';

  is $col->length, 0;
  done $c;
} n => 5, name => 'remove_named_item not found';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_document_type_definition ('a');
  my $col = $el->element_types;

  dies_here_ok {
    $col->remove_named_item_ns (undef, 'hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotSupportedError';
  is $@->message, 'This operation is not supported';

  is $col->length, 0;
  done $c;
} n => 5, name => 'remove_named_item not found';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_document_type_definition ('a');
  my $col = $el->element_types;
  SET ($el, hoge => 'abc');

  my $node = $col->remove_named_item ('hoge');
  isa_ok $node, 'Web::DOM::ElementTypeDefinition';
  is $node->node_name, 'hoge';
  is $node->get_user_data ('value'), 'abc';
  is $node->owner_document_type_definition, undef;
  is GET ($el, 'hoge'), undef;

  done $c;
} n => 5, name => 'remove_named_item simple attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_document_type_definition ('a');
  my $col = $el->element_types;
  SET ($el, hoge => 'abc');

  dies_here_ok {
    $col->remove_named_item_ns ('', 'hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotSupportedError';
  is $@->message, 'This operation is not supported';
  is $el->element_types->length, 1;
  is $el->element_types->[0]->owner_document_type_definition, $el;
  is GET ($el, 'hoge'), 'abc';

  done $c;
} n => 7, name => 'remove_named_item_ns removed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_document_type_definition ('a');
  my $col = $el->element_types;
  SET ($el, hoge => 'abc');

  dies_here_ok {
    $col->remove_named_item_ns ('aa', 'hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotSupportedError';
  is $@->message, 'This operation is not supported';
  is GET ($el, 'hoge'), 'abc';

  done $c;
} n => 5, name => 'remove_named_item_ns node attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_type_definition ('hoge');
  my $map = $node->element_types;
  is $map->{hoge}, undef;
  is $map->{120}, undef;
  is $map->{+undef}, undef;
  dies_here_ok {
    $map->{foo} = 'bar';
  };
  like $@, qr{^Modification of a read-only value attempted};
  ok not exists $map->{foo};
  is $map->{foo}, undef;
  is scalar keys %$map, 0;
  done $c;
} n => 8, name => '%{} empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_type_definition ('hoge');
  my $map = $node->element_types;
  $node->set_element_type_definition_node
      ($doc->create_element_type_definition ('hoge'));
  $node->set_element_type_definition_node
      ($doc->create_element_type_definition ('hoge:aaa'));
  is $map->{120}, undef;
  isa_ok $map->{hoge}, 'Web::DOM::ElementTypeDefinition';
  isa_ok $map->{'hoge:aaa'}, 'Web::DOM::ElementTypeDefinition';
  is_deeply [sort { $a cmp $b } keys %$map], ['hoge', 'hoge:aaa'];
  is $map->{120}, undef;
  is $map->{+undef}, undef;
  dies_here_ok {
    $map->{hoge} = 'bar';
  };
  like $@, qr{^Modification of a read-only value attempted};
  ok not exists $map->{foo};
  ok exists $map->{'hoge:aaa'};
  is scalar keys %$map, 2;
  dies_here_ok {
    %$map = ();
  };
  like $@, qr{^Modification of a read-only value attempted};
  is scalar keys %$map, 2;
  is_deeply [sort { $a cmp $b } keys %$map], ['hoge', 'hoge:aaa'];
  my $item = [];
  while (defined (my $v = each %$map)) {
    push @$item, $map->{$v};
  }
  is scalar @$item, 2;
  ok $item->[0]->node_name eq 'hoge' || $item->[0]->node_name eq 'hoge:aaa';
  ok $item->[1]->node_name eq 'hoge' || $item->[1]->node_name eq 'hoge:aaa';
  isnt $item->[0], $item->[1];
  done $c;
} n => 19, name => '%{} non empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_type_definition ('hoge');
  my $map = $node->element_types;

  is $map->{hoge}, undef;

  $node->set_element_type_definition_node
      ($doc->create_element_type_definition ('hoge'));

  is $map->{hoge}->node_name, 'hoge';

  done $c;
} n => 2, name => '%{} mutation';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_type_definition ('hoge');
  my $map = $node->element_types;

  is $map->[0], undef;

  $node->set_element_type_definition_node
      ($doc->create_element_type_definition ('hoge'));

  is $map->[0]->node_name, 'hoge';

  done $c;
} n => 2, name => '@{} mutation set_element_type_definition_node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_type_definition ('hoge');
  my $map = $node->element_types;
  $node->set_element_type_definition_node
      ($doc->create_element_type_definition ('hoge'));

  is $map->[0]->node_name, 'hoge';

  $node->remove_element_type_definition_node
      ($node->get_element_type_definition_node ('hoge'));

  is $map->[0], undef;

  done $c;
} n => 2, name => '@{} mutation remove_attribute';

run_tests;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
