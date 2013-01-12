use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::Document;

for my $attr (qw(title lang itemid accesskey)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('strong');
    is $el->$attr, '';
    $el->$attr ('hoge ');
    is $el->$attr, 'hoge ';
    is $el->get_attribute ($attr), 'hoge ';
    $el->$attr ('0');
    is $el->$attr, '0';
    $el->$attr ('');
    is $el->$attr, '';
    $el->set_attribute ($attr => 124);
    is $el->$attr, 124;
    done $c;
  } n => 6, name => ['string reflect attributes', $attr];
}

for my $test (
  ['base', 'target'],
  ['link', 'rel'],
  ['link', 'media'],
  ['link', 'hreflang'],
  ['link', 'type'],
  ['link', 'crossorigin'],
  ['meta', 'name'],
  ['meta', 'content'],
  ['meta', 'http_equiv', 'http-equiv'],
  ['style', 'type'],
  ['style', 'media'],
  ['script', 'charset'],
  ['script', 'type'],
  ['script', 'crossorigin'],
  ['ol', 'type'],
  ['a', 'target'],
  ['a', 'type'],
  ['a', 'rel'],
  ['a', 'hreflang'],
  ['a', 'download'],
  ['data', 'value'],
  ['time', 'datetime'],
  ['ins', 'datetime'],
  ['del', 'datetime'],
  ['img', 'alt'],
  ['img', 'srcset'],
  ['img', 'crossorigin'],
  ['img', 'usemap'],
  ['iframe', 'name'],
  ['iframe', 'srcdoc'],
  ['iframe', 'width'],
  ['iframe', 'height'],
  ['embed', 'src'],
  ['embed', 'type'],
  ['embed', 'width'],
  ['embed', 'height'],
  ['object', 'data'],
  ['object', 'type'],
  ['object', 'name'],
  ['object', 'usemap'],
  ['object', 'width'],
  ['object', 'height'],
  ['param', 'name'],
  ['param', 'value'],
) {
  my $attr = $test->[1];
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ($test->[0]);
    is $el->$attr, '';
    $el->$attr ('hoge ');
    is $el->$attr, 'hoge ';
    is $el->get_attribute ($test->[2] || $attr), 'hoge ';
    $el->$attr ('0');
    is $el->$attr, '0';
    $el->$attr ('');
    is $el->$attr, '';
    $el->set_attribute ($test->[2] || $attr => 124);
    is $el->$attr, 124;
    done $c;
  } n => 6, name => ['string reflect attributes', @$test];
}

for my $attr (qw(itemscope hidden)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('strong');
    ok not $el->$attr;
    $el->$attr (1);
    ok $el->$attr;
    is $el->get_attribute_ns (undef, $attr), '';
    $el->$attr (0);
    ok not $el->$attr;
    is $el->get_attribute_ns (undef, $attr), undef;
    $el->set_attribute_ns (undef, $attr, 'false');
    ok $el->$attr;
    $el->remove_attribute_ns (undef, $attr);
    ok not $el->$attr;
    done $c;
  } n => 7, name => ['boolean reflect attributes', $attr];
}

for my $test (
  ['style', 'scoped'],
  ['script', 'defer'],
  ['ol', 'reversed'],
  ['img', 'ismap'],
  ['iframe', 'seamless'],
  ['iframe', 'allowfullscreen'],
  ['object', 'typemustmatch'],
) {
  my $attr = $test->[1];
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ($test->[0]);
    ok not $el->$attr;
    $el->$attr (1);
    ok $el->$attr;
    is $el->get_attribute_ns (undef, $attr), '';
    $el->$attr (0);
    ok not $el->$attr;
    is $el->get_attribute_ns (undef, $attr), undef;
    $el->set_attribute_ns (undef, $attr, 'false');
    ok $el->$attr;
    $el->remove_attribute_ns (undef, $attr);
    ok not $el->$attr;
    done $c;
  } n => 7, name => ['boolean reflect attributes', @$test];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('em');
  is $el->dir, '';
  $el->dir ('ltr');
  is $el->dir, 'ltr';
  is $el->get_attribute ('dir'), 'ltr';
  $el->dir ('RtL');
  is $el->dir, 'rtl';
  is $el->get_attribute ('dir'), 'RtL';
  $el->dir ('auTO');
  is $el->dir, 'auto';
  is $el->get_attribute ('dir'), 'auTO';
  $el->dir ('ltr  ');
  is $el->dir, '';
  is $el->get_attribute ('dir'), 'ltr  ';
  $el->dir ('');
  is $el->dir, '';
  is $el->get_attribute ('dir'), '';
  $el->dir ('0');
  is $el->dir, '';
  is $el->get_attribute ('dir'), '0';
  $el->dir (undef);
  is $el->dir, '';
  is $el->get_attribute ('dir'), '';
  done $c;
} n => 15, name => 'dir';

for my $el_name (qw(title script)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ($el_name);
    is $el->text, '';
    $el->text ('hoge');
    is $el->text, 'hoge';
    $el->append_child ($doc->create_element ('foo'))->text_content ('abc');
    my $node1 = $el->append_child ($doc->create_text_node ('ahq'));
    is $el->text, 'hogeahq';
    $el->text ('');
    is $el->first_child, undef;
    is $node1->parent_node, undef;
    $el->text ('abc');
    is $el->text, 'abc';
    my $text = $el->first_child;
    $el->text ('bbqa');
    is $text->parent_node, undef;
    done $c;
  } n => 7, name => [$el_name, 'text'];
}

for my $el_name (qw(a)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ($el_name);
    is $el->text, '';
    $el->text ('hoge');
    is $el->text, 'hoge';
    $el->append_child ($doc->create_element ('foo'))->text_content ('abc');
    my $node1 = $el->append_child ($doc->create_text_node ('ahq'));
    is $el->text, 'hogeabcahq';
    $el->text ('');
    is $el->first_child, undef;
    is $node1->parent_node, undef;
    $el->text ('abc');
    is $el->text, 'abc';
    my $text = $el->first_child;
    $el->text ('bbqa');
    is $text->parent_node, undef;
    done $c;
  } n => 7, name => [$el_name, 'text'];
}

for my $test (
  ['li', 'value', 0],
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ($test->[0]);
    my $attr = $test->[1];
    is $el->$attr, $test->[2];
    for (
      [0 => 0],
      [-10 => -10],
      [0.0006 => 0],
      [0.6 => 0],
      [0.9996 => 0],
      [-0.1 => 0],
      [-0.6 => 0],
      [-0.9 => 0],
      [(0+"inf") => 0],
      [(0+"-inf") => 0],
      [(0+"nan") => 0],
      [(1/"inf") => 0],
      [(1/"-inf") => 0],
      ["abc" => 0],
      ["-120abc" => -120],
      ["-120.524abc" => -120],
      ["0 but true" => 0],
      ["34e6" => 34000000],
      ["34e-6" => 0],
      [2**32 => 0],
      [2**32-1 => -1],
      [2**32-14.6 => -15],
      [2**31 => -2**31],
      [2**31-1 => 2**31-1],
      [-2**31 => -2**31],
      [-2**31-1 => 2**31-1],
      [-2**31-1.7 => 2**31-1],
    ) {
      $el->$attr ($_->[0]);
      is $el->$attr, $_->[1];
      is $el->get_attribute ($attr), $_->[1];
    }
    for (
      ["" => $test->[2]],
      ["0" => 0],
      ["+0.12" => 0],
      ["-0.12" => 0],
      ["120.61" => 120],
      ["-6563abc" => -6563],
      ["1452151544454" => 0],
      ["-1452151544454" => 0],
      ["abc" => 0],
      ["inf" => 0],
      ["-inf" => 0],
      ["nan" => 0],
      [" 535" => 535],
      [" -655" => -655],
      ["- 513" => 0],
      ["44_524" => 44],
      ["0x124" => 0],
      ["213e5" => 213],
    ) {
      $el->set_attribute ($attr => $_->[0]);
      is $el->$attr, $_->[1];
    }
    done $c;
  } n => 1 + 2*27 + 1*18, name => ['reflect long', @$test];
}

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
