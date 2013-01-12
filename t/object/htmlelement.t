use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
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
  ['source', 'type'],
  ['source', 'media'],
  ['track', 'srclang'],
  ['track', 'label'],
  ['video', 'crossorigin'],
  ['audio', 'crossorigin'],
  ['map', 'name'],
  ['area', 'alt'],
  ['area', 'coords'],
  ['area', 'shape'],
  ['area', 'target'],
  ['area', 'type'],
  ['area', 'rel'],
  ['area', 'hreflang'],
  ['area', 'download'],
  ['th', 'abbr'],
  ['th', 'sorted'],
  ['form', 'accept_charset', 'accept-charset'],
  ['form', 'name', 'name'],
  ['form', 'target', 'target'],
  ['fieldset', 'name'],
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
  ['track', 'default'],
  ['video', 'autoplay'],
  ['audio', 'autoplay'],
  ['video', 'loop'],
  ['audio', 'loop'],
  ['video', 'controls'],
  ['audio', 'controls'],
  ['video', 'muted', 'default_muted'],
  ['audio', 'muted', 'default_muted'],
  ['table', 'sortable'],
  ['form', 'novalidate'],
  ['fieldset', 'disabled'],
) {
  my $attr = $test->[2] // $test->[1];
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ($test->[0]);
    ok not $el->$attr;
    $el->$attr (1);
    ok $el->$attr;
    is $el->get_attribute_ns (undef, $test->[1]), '';
    $el->$attr (0);
    ok not $el->$attr;
    is $el->get_attribute_ns (undef, $test->[1]), undef;
    $el->set_attribute_ns (undef, $test->[1], 'false');
    ok $el->$attr;
    $el->remove_attribute_ns (undef, $test->[1]);
    ok not $el->$attr;
    done $c;
  } n => 7, name => ['boolean reflect attributes', @$test];
}

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
      is $el->get_attribute ($attr), $_->[2] // $_->[1];
    }
    for (
      ["" => $test->[2]],
      ["0" => 0],
      ["+0.12" => 0],
      ["-0.12" => 0],
      ["120.61" => 120],
      ["-6563abc" => -6563],
      ["2147483647" => 2**31-1],
      ["2147483648" => 0],
      ["1452151544454" => 0],
      ["-1452151544454" => 0],
      ["abc" => $test->[2]],
      ["inf" => $test->[2]],
      ["-inf" => $test->[2]],
      ["nan" => $test->[2]],
      [" 535" => 535],
      [" -655" => -655],
      ["- 513" => $test->[2]],
      ["44_524" => 44],
      ["0x124" => 0],
      ["213e5" => 213],
    ) {
      test {
        $el->set_attribute ($attr => $_->[0]);
        is $el->$attr, $_->[1];
      } $c, name => 'getter', n => 1;
    }
    done $c;
  } n => 1 + 2*27 + 1*20, name => ['reflect long', @$test];
}

for my $test (
  ['video', 'width', 0],
  ['video', 'height', 0],
  ['canvas', 'width', 300],
  ['canvas', 'height', 150],
  ['td', 'colspan', 1],
  ['td', 'rowspan', 1],
  ['th', 'colspan', 1],
  ['th', 'rowspan', 1],
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ($test->[0]);
    my $attr = $test->[1];
    is $el->$attr, $test->[2];
    for (
      [0 => 0],
      [-10 => $test->[2], 2**32-10],
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
      ["-120abc" => $test->[2], 2**32-120],
      ["-120.524abc" => $test->[2], 2**32-120],
      ["0 but true" => 0],
      ["34e6" => 34000000],
      ["34e-6" => 0],
      [2**32+1 => 1],
      [2**32 => 0],
      [2**32-1 => $test->[2], '4294967295'],
      [2**32-14.6 => $test->[2], '4294967281'],
      [2**31+1 => $test->[2], 2**31+1],
      [2**31 => $test->[2], 2**31],
      [2**31-1 => 2**31-1, 2**31-1],
      [-2**31+1 => $test->[2], 2**31+1],
      [-2**31 => $test->[2], 2**31],
      [-2**31-1 => 2**31-1],
      [-2**31+1.7 => $test->[2], 2**31+2],
      [-2**31-1.7 => 2**31-1],
    ) {
      $el->$attr ($_->[0]);
      is $el->$attr, $_->[1], [$_->[0], 'idl attr'];
      is $el->get_attribute ($attr), $_->[2] // $_->[1],
          [$_->[0], 'content attr'];
    }
    for (
      ["" => $test->[2]],
      ["0" => 0],
      ["+0.12" => 0],
      ["-0.12" => 0],
      ["120.61" => 120],
      ["-6563abc" => $test->[2]],
      ["2147483647" => 2**31-1],
      ["2147483648" => $test->[2]],
      ["1452151544454" => $test->[2]],
      ["-1452151544454" => $test->[2]],
      ["abc" => $test->[2]],
      ["inf" => $test->[2]],
      ["-inf" => $test->[2]],
      ["nan" => $test->[2]],
      [" 535" => 535],
      [" -655" => $test->[2]],
      ["- 513" => $test->[2]],
      ["44_524" => 44],
      ["0x124" => 0],
      ["213e5" => 213],
    ) {
      test {
        $el->set_attribute ($attr => $_->[0]);
        is $el->$attr, $_->[1];
      } $c, name => 'getter', n => 1;
    }
    done $c;
  } n => 1 + 2*30 + 1*22, name => ['reflect unsigned long', @$test];
}

for my $test (
  ['colgroup', 'span', 1],
  ['col', 'span', 1],
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ($test->[0]);
    my $attr = $test->[1];
    is $el->$attr, $test->[2];
    for (
      [1 => 1],
      [2 => 2],
      [1265 => 1265],
      [-10 => $test->[2], 2**32-10],
      ["-120abc" => $test->[2], 2**32-120],
      ["-120.524abc" => $test->[2], 2**32-120],
      ["34e6" => 34000000],
      [2**32+1 => 1],
      [2**32-1 => $test->[2], '4294967295'],
      [2**32-14.6 => $test->[2], '4294967281'],
      [2**31+1 => $test->[2], 2**31+1],
      [2**31 => $test->[2], 2**31],
      [2**31-1 => 2**31-1, 2**31-1],
      [-2**31+1 => $test->[2], 2**31+1],
      [-2**31 => $test->[2], 2**31],
      [-2**31-1 => 2**31-1],
      [-2**31+1.7 => $test->[2], 2**31+2],
      [-2**31-1.7 => 2**31-1],
    ) {
      $el->$attr ($_->[0]);
      is $el->$attr, $_->[1], [$_->[0], 'idl attr'];
      is $el->get_attribute ($attr), $_->[2] // $_->[1],
          [$_->[0], 'content attr'];
    }
    $el->set_attribute ($attr => '361');
    for (
      [0 => 0],
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
      ["0 but true" => 0],
      [2**32 => 0],
      ["34e-6" => 0],
    ) {
      dies_here_ok {
        $el->$attr ($_->[0]);
      };
      isa_ok $@, 'Web::DOM::Exception';
      is $@->name, 'IndexSizeError';
      is $@->message, 'Cannot set the value to zero';
      is $el->$attr, 361;
      is $el->get_attribute ($attr), 361;
    }
    for (
      ["" => $test->[2]],
      ["0" => 1],
      ["+0.12" => 1],
      ["-0.12" => 1],
      ["120.61" => 120],
      ["-6563abc" => $test->[2]],
      ["2147483647" => 2**31-1],
      ["2147483648" => $test->[2]],
      ["1452151544454" => $test->[2]],
      ["-1452151544454" => $test->[2]],
      ["abc" => $test->[2]],
      ["inf" => $test->[2]],
      ["-inf" => $test->[2]],
      ["nan" => $test->[2]],
      [" 535" => 535],
      [" -655" => $test->[2]],
      ["- 513" => $test->[2]],
      ["44_524" => 44],
      ["0x124" => 1],
      ["213e5" => 213],
    ) {
      test {
        $el->set_attribute ($attr => $_->[0]);
        is $el->$attr, $_->[1];
      } $c, name => 'getter', n => 1;
    }
    done $c;
  } n => 1 + 2*17 + 6*16 + 1*22, name => ['reflect unsigned long limited', @$test];
}

for my $test (
  {element => 'em',
   attr => 'dir',
   default => '',
   valid_values => [
     ['ltr' => 'ltr'],
     ['rTl' => 'rtl'],
     ['auTO' => 'auto'],
   ],
   invalid_values => [[''], ['0'], [undef]]},
  {element => 'track',
   attr => 'kind',
   default => 'subtitles',
   valid_values => [
     [captions => 'captions'],
     [DEscRiptions => 'descriptions'],
     [DescRiPTIons => 'descriptions'],
     [SubTitles => 'subtitles'],
     [ChapTERs => 'chapters'],
     [Metadata => 'metadata'],
   ],
   invalid_values => [[''], ['0'], [undef]]},
  {element => 'th',
   attr => 'scope',
   default => '',
   valid_values => [
     [row => 'row'],
     [COL => 'col'],
     [rowGroup => 'rowgroup'],
     [coLGrouP => 'colgroup'],
   ],
   invalid_values => [
     [''], ['0'], [undef],
     ['ChaptErS  '],
     ['row group'],
     ['auto'],
   ]},
  {element => 'form',
   attr => 'autocomplete',
   default => 'on',
   valid_values => [
     [On => 'on'],
     [off => 'off'],
   ],
   invalid_values => [[''], ['0'], [undef]]},
  {element => 'form',
   attr => 'enctype',
   default => '',
   invalid_default => 'application/x-www-form-urlencoded',
   valid_values => [
     ['application/x-www-form-URLEncoded' =>
          'application/x-www-form-urlencoded'],
     ['multipart/form-data' => 'multipart/form-data'],
     ['Text/Plain' => 'text/plain'],
   ],
   invalid_values => [[''], ['0'], [undef]]},
  {element => 'form',
   attr => 'encode',
   content_attr => 'enctype',
   default => '',
   invalid_default => 'application/x-www-form-urlencoded',
   valid_values => [
     ['application/x-www-form-URLEncoded' =>
          'application/x-www-form-urlencoded'],
     ['multipart/form-data' => 'multipart/form-data'],
     ['Text/Plain' => 'text/plain'],
   ],
   invalid_values => [[''], ['0'], [undef]]},
  {element => 'form',
   attr => 'method',
   default => '',
   invalid_default => 'get',
   valid_values => [
     ['get' => 'get'],
     ['POST' => 'post'],
     ['Dialog' => 'dialog'],
   ],
   invalid_values => [[''], ['0'], [undef]]},
) {
  my $attr = $test->{attr};
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ($test->{element});
    is $el->$attr, $test->{default};
    for (@{$test->{valid_values}}) {
      $el->$attr ($_->[0]);
      is $el->$attr, $_->[1];
      is $el->get_attribute ($test->{content_attr} // $attr), $_->[0];
    }
    for (
      (map { [$_->[0].'  '] } @{$test->{valid_values}}),
      @{$test->{invalid_values}},
      ['#invalid'],
      ['#missing'],
    ) {
      $el->$attr ($_->[0]);
      is $el->$attr, $test->{invalid_default} // $test->{default};
      is $el->get_attribute ($test->{content_attr} // $attr), $_->[0] // '';
    }
    done $c;
  } n => 3 + @{$test->{valid_values}}*2 +
      (@{$test->{valid_values}} + @{$test->{invalid_values}} + 1)*2,
      name => ['reflect enumerated attr', $test->{element}, $test->{attr}];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('fieldset');
  is $el->type, 'fieldset';
  done $c;
} n => 1, name => 'fieldset type';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
