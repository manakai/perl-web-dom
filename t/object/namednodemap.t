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

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  my $called;
  $node->set_user_data (destroy => bless sub {
                         $called = 1;
                       }, 'test::DestroyCallback');

  my $nl = $node->attributes;
  isa_ok $nl, 'Web::DOM::NamedNodeMap';
  is scalar @$nl, 0;
  is $nl->length, 0;

  undef $node;
  ok not $called;

  undef $nl;
  ok $called;

  done $c;
} n => 5, name => 'attributes empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  $node->set_attribute (hoge => 1);
  $node->set_attribute (abc => 2);
  my $called;
  $node->set_user_data (destroy => bless sub {
                         $called = 1;
                       }, 'test::DestroyCallback');

  my $nl = $node->attributes;
  isa_ok $nl, 'Web::DOM::NamedNodeMap';
  is scalar @$nl, 2;
  is $nl->length, 2;

  undef $node;
  ok not $called;

  undef $nl;
  ok $called;

  done $c;
} n => 5, name => 'attributes not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element ('a');

  my $nl = $node->attributes;
  my $nl2 = $node->attributes;
  
  is $nl2, $nl;

  my $node2 = $doc->create_element ('b');
  my $nl3 = $node2->attributes;

  isnt $nl3, $nl;

  $node->set_attribute_ns ('aa', 'bb', 'CC');

  is scalar @$nl, 1;
  is $nl->length, 1;
  
  done $c;
} n => 4, name => 'attributes liveness and sameness';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  my $node2 = $doc->create_text_node ('a');

  my $nl = $node->attributes;

  dies_here_ok {
    $nl->[0] = $node2;
  };
  ok not ref $@;
  like $@, qr{^Modification of a read-only value attempted};

  is scalar @$nl, 0;
  ok not $node->has_attributes;
  ok not $node2->parent_node;

  done $c;
} n => 6, name => 'attributes read-only';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  my $node2 = $doc->create_attribute ('a');
  my $node3 = $doc->create_attribute ('a');
  $node->set_attribute_node ($node3);

  my $nl = $node->attributes;

  dies_here_ok {
    $nl->[0] = $node2;
  };
  ok not ref $@;
  like $@, qr{^Modification of a read-only value attempted};

  is scalar @$nl, 1;
  is $nl->[0], $node3;
  is $node3->owner_element, $node;
  is $node2->owner_element, undef;

  $$node3->[100] = 14;
  is $$node3->[100], 14;

  done $c;
} n => 8, name => 'attributes read-only';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');

  my $nl = $node->attributes;
  my $nl_s = $nl . '';
  undef $nl;

  my $nl2 = $node->attributes;
  my $nl2_s = $nl2 . '';

  ok $nl2_s eq $nl_s;
  ok not $nl2_s ne $nl_s;
  ok not $nl2 eq $nl_s;
  ok $nl2 ne $nl_s;
  ok not $nl2 eq undef;
  ok $nl2 ne undef;
  ok $nl2 eq $node->attributes;
  ok not $nl2 ne $node->attributes;
  is $nl2 cmp $node->attributes, 0;
  isnt $nl2 cmp $node->attributes, undef;

  my $nl3 = $doc->attributes;
  ok $nl3 ne $nl2;
  ok not $nl3 eq $nl2;

  ok $nl2;

  done $c;
} n => 13, name => 'attributes comparison';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element ('a');
  my $nl = $node->attributes;

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
} n => 22, name => 'attributes items, empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element ('a');
  my $nl = $node->attributes;
  $node->set_attribute (fuga => 3);

  is $nl->length, 1;
  is scalar @$nl, 1;

  isa_ok $nl->item (0), 'Web::DOM::Attr';
  my $el = $nl->item (0);
  is $el->name, 'fuga';
  is $el->value, '3';

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
} n => 37, name => 'attributes items, empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  my $nl = $node->attributes;

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
} n => 12, name => 'attributes perl binding empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  my $nl = $node->attributes;
  $node->set_attribute (zzz => 'aa');
  $node->set_attribute (ggg => 'fwa');

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
} n => 14, name => 'attributes perl binding not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $col = $el->attributes;
  is $col->get_named_item ('hoge'), undef;
  is $col->get_named_item ('120'), undef;
  is $col->get_named_item_ns (undef, 'hoge'), undef;
  is $col->get_named_item_ns ('abc', 'hoge'), undef;
  done $c;
} n => 4, name => 'get not found';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $col = $el->attributes;
  $el->set_attribute ('hoge' => 112);
  $el->set_attribute_ns ('aaa', 'fuga:aa', "aa");

  my $attr1 = $col->get_named_item ('hoge');
  isa_ok $attr1, 'Web::DOM::Attr';
  is $attr1->name, 'hoge';
  is $attr1->value, '112';

  my $attr2 = $col->get_named_item ('fuga:aa');
  is $attr2->value, 'aa';
  
  my $attr3 = $col->get_named_item_ns (undef, 'hoge');
  is $attr3, $attr1;
  
  my $attr4 = $col->get_named_item_ns ('aaa', 'aa');
  is $attr4, $attr2;
  
  done $c;
} n => 6, name => 'get found';

for my $method (qw(set_named_item set_named_item_ns)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');
    my $attr = $doc->create_attribute ('b');
    my $col = $el->attributes;
    
    is $col->$method ($attr), undef;
    is $el->get_attribute ('b'), '';
    
    done $c;
  } n => 2, name => [$method, 'new'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');
    my $attr = $doc->create_attribute ('b');
    my $col = $el->attributes;
    $el->set_attribute (b => 21);

    my $attr2 = $col->$method ($attr), undef;
    is $el->get_attribute ('b'), '';
    isa_ok $attr2, 'Web::DOM::Attr';
    is $attr2->owner_element, undef;
    is $attr2->name, 'b';
    is $attr2->value, '21';

    done $c;
  } n => 5, name => [$method, 'replace'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');
    $el->set_attribute ('fuga' => 'abc');
    my $col = $el->attributes;

    my $attr = $col->$method ($col->[0]);
    is $attr->node_type, $attr->ATTRIBUTE_NODE;
    is $attr->owner_element, $el;
    is $attr->name, 'fuga';
    is $attr->value, 'abc';
    is $el->get_attribute ('fuga'), 'abc';

    done $c;
  } n => 5, name => [$method, 'self'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');
    $el->set_attribute ('fuga' => 'abc');
    my $el2 = $doc->create_element ('a');
    my $col = $el2->attributes;

    dies_here_ok {
      $col->$method ($el->attributes->[0]);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'InUseAttributeError';
    is $@->message, 'The specified attribute has already attached to another node';
    
    is $el->attributes->[0]->owner_element, $el;
    is $el->get_attribute ('fuga'), 'abc';
    
    done $c;
  } n => 6, name => [$method, 'self'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');
    my $el2 = $doc->create_element ('a');
    my $col = $el->attributes;

    dies_here_ok {
      $col->$method ($el2);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'Specified type of node cannot be set';
    
    is $el->attributes->length, 0;
    is $el2->parent_node, undef;
    
    done $c;
  } n => 6, name => [$method, 'not attr'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');
    my $col = $el->attributes;

    dies_here_ok {
      $col->$method (undef);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->name, 'TypeError';
    is $@->message, 'The argument is not a Node';
    
    is $el->attributes->length, 0;
    
    done $c;
  } n => 5, name => [$method, 'not node'];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $col = $el->attributes;

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
  my $el = $doc->create_element ('a');
  my $col = $el->attributes;

  dies_here_ok {
    $col->remove_named_item_ns (undef, 'hoge');
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
  my $el = $doc->create_element ('a');
  my $col = $el->attributes;
  $el->set_attribute (hoge => 'abc');

  my $node = $col->remove_named_item ('hoge');
  isa_ok $node, 'Web::DOM::Attr';
  is $node->name, 'hoge';
  is $node->value, 'abc';
  is $node->owner_element, undef;
  is $el->get_attribute ('hoge'), undef;

  done $c;
} n => 5, name => 'remove_named_item simple attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $col = $el->attributes;
  $el->set_attribute (hoge => 'abc');

  my $node = $col->remove_named_item_ns ('', 'hoge');
  isa_ok $node, 'Web::DOM::Attr';
  is $node->name, 'hoge';
  is $node->value, 'abc';
  is $node->owner_element, undef;
  is $el->get_attribute ('hoge'), undef;

  done $c;
} n => 5, name => 'remove_named_item_ns simple attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $col = $el->attributes;
  $el->set_attribute_ns ('aa', hoge => 'abc');

  my $node = $col->remove_named_item ('hoge');
  isa_ok $node, 'Web::DOM::Attr';
  is $node->name, 'hoge';
  is $node->value, 'abc';
  is $node->owner_element, undef;
  is $el->get_attribute_ns ('aa', 'hoge'), undef;

  done $c;
} n => 5, name => 'remove_named_item node attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $col = $el->attributes;
  $el->set_attribute_ns ('aa', hoge => 'abc');

  my $node = $col->remove_named_item_ns ('aa', 'hoge');
  isa_ok $node, 'Web::DOM::Attr';
  is $node->name, 'hoge';
  is $node->value, 'abc';
  is $node->owner_element, undef;
  is $el->get_attribute_ns ('aa', 'hoge'), undef;

  done $c;
} n => 5, name => 'remove_named_item_ns node attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('hoge');
  my $map = $node->attributes;
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
  my $node = $doc->create_element ('hoge');
  my $map = $node->attributes;
  $node->set_attribute (hoge => '12');
  $node->set_attribute_ns ('http://foo/', 'hoge:aaa', 'aa');
  is $map->{120}, undef;
  isa_ok $map->{hoge}, 'Web::DOM::Attr';
  is $map->{hoge}->value, '12';
  isa_ok $map->{'hoge:aaa'}, 'Web::DOM::Attr';
  is $map->{'hoge:aaa'}->value, 'aa';
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
} n => 21, name => '%{} non empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('hoge');
  my $map = $node->attributes;
  $node->set_attribute (hoge => '12');
  $node->set_attribute_ns ('http://foo/', 'hoge', 'aa');

  is $map->{hoge}->value, '12';

  done $c;
} n => 1, name => '%{} multiple';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $node = $doc->create_element ('hoge');
  $node->set_attribute_ns (undef, 'hoge', 'bar');
  $node->set_attribute_ns (undef, 'hoGe', 'foo');

  my $map = $node->attributes;
  my @keys = keys %$map;
  is 0+@keys, 1;
  is $keys[0], 'hoge';
  is $map->{hoge}->value, 'bar';

  done $c;
} n => 3, name => '%{} uppercase HTML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $node = $doc->create_element ('hoge');
  $node->set_attribute_ns (undef, 'hoge', 'bar');
  $node->set_attribute_ns ('https://foo/', 'hoGe', 'foo');

  my $map = $node->attributes;
  my @keys = keys %$map;
  is 0+@keys, 1;
  is $keys[0], 'hoge';
  is $map->{hoge}->value, 'bar';

  done $c;
} n => 3, name => '%{} uppercase HTML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $node = $doc->create_element_ns (undef, 'hoge');
  $node->set_attribute_ns (undef, 'hoge', 'bar');
  $node->set_attribute_ns (undef, 'hoGe', 'foo');

  my $map = $node->attributes;
  my @keys = sort { $a cmp $b } keys %$map;
  is 0+@keys, 2;
  is $keys[1], 'hoge';
  is $keys[0], 'hoGe';
  is $map->{hoge}->value, 'bar';
  is $map->{hoGe}->value, 'foo';

  done $c;
} n => 5, name => '%{} uppercase non-HTML element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $node->set_attribute_ns (undef, 'hoge', 'bar');
  $node->set_attribute_ns (undef, 'hoGe', 'foo');

  my $map = $node->attributes;
  my @keys = sort { $a cmp $b } keys %$map;
  is 0+@keys, 2;
  is $keys[1], 'hoge';
  is $keys[0], 'hoGe';
  is $map->{hoge}->value, 'bar';
  is $map->{hoGe}->value, 'foo';

  done $c;
} n => 5, name => '%{} uppercase non-HTML document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('hoge');
  my $map = $node->attributes;
  $node->set_attribute_ns ('http://foo/', 'hoge', 'aa');
  $node->set_attribute_ns (undef, hoge => '12');

  is $map->{hoge}->value, 'aa';

  done $c;
} n => 1, name => '%{} multiple';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('hoge');
  my $map = $node->attributes;

  is $map->{hoge}, undef;

  $node->set_attribute_ns (undef, hoge => '12');

  is $map->{hoge}->value, '12';

  done $c;
} n => 2, name => '%{} mutation';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('hoge');
  my $map = $node->attributes;

  is $map->[0], undef;

  $node->set_attribute (hoge => '12');

  is $map->[0]->value, '12';

  done $c;
} n => 2, name => '@{} mutation set_attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('hoge');
  my $map = $node->attributes;

  is $map->[0], undef;

  $node->set_attribute_ns (undef, hoge => '12');

  is $map->[0]->value, '12';

  done $c;
} n => 2, name => '@{} mutation set_attribute_ns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('hoge');
  my $map = $node->attributes;

  is $map->[0], undef;

  $node->set_attribute_node ($doc->create_attribute ('hoge'));

  is $map->[0]->value, '';

  done $c;
} n => 2, name => '@{} mutation set_attribute_node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('hoge');
  my $map = $node->attributes;
  $node->set_attribute_ns (undef, hoge => '12');

  is $map->[0]->value, '12';

  $node->remove_attribute ('hoge');

  is $map->[0], undef;

  done $c;
} n => 2, name => '@{} mutation remove_attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('hoge');
  my $map = $node->attributes;
  $node->set_attribute_ns (undef, hoge => '12');

  is $map->[0]->value, '12';

  $node->remove_attribute_ns (undef, 'hoge');

  is $map->[0], undef;

  done $c;
} n => 2, name => '@{} mutation remove_attribute_ns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('hoge');
  my $map = $node->attributes;
  $node->set_attribute_ns (undef, hoge => '12');

  is $map->[0]->value, '12';

  $node->remove_attribute_node ($node->get_attribute_node ('hoge'));

  is $map->[0], undef;

  done $c;
} n => 2, name => '@{} mutation remove_attribute_node';

run_tests;

=head1 LICENSE

Copyright 2012-2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
