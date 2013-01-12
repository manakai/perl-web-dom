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
  ['label', 'html_for', 'for'],
  ['input', 'accept'],
  ['input', 'alt'],
  ['input', 'dirname'],
  ['input', 'formtarget'],
  ['input', 'max'],
  ['input', 'min'],
  ['input', 'name'],
  ['input', 'pattern'],
  ['input', 'placeholder'],
  ['input', 'step'],
  ['input', 'default_value', 'value'],
  ['button', 'formtarget'],
  ['button', 'name'],
  ['button', 'value'],
  ['select', 'name'],
  ['optgroup', 'label'],
  ['textarea', 'dirname'],
  ['textarea', 'name'],
  ['textarea', 'placeholder'],
  ['keygen', 'challenge'],
  ['keygen', 'name'],
  ['output', 'name'],
  ['menu', 'label'],
  ['menu', 'type'],
  ['menuitem', 'label'],
  ['menuitem', 'radiogroup'],
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
  ['input', 'autofocus'],
  ['input', 'checked', 'default_checked'],
  ['input', 'disabled'],
  ['input', 'formnovalidate'],
  ['input', 'multiple'],
  ['input', 'readonly'],
  ['input', 'required'],
  ['button', 'autofocus'],
  ['button', 'disabled'],
  ['button', 'formnovalidate'],
  ['select', 'autofocus'],
  ['select', 'disabled'],
  ['select', 'multiple'],
  ['select', 'required'],
  ['optgroup', 'disabled'],
  ['option', 'disabled'],
  ['option', 'selected', 'default_selected'],
  ['textarea', 'autofocus'],
  ['textarea', 'disabled'],
  ['textarea', 'readonly'],
  ['textarea', 'required'],
  ['keygen', 'autofocus'],
  ['keygen', 'disabled'],
  ['details', 'open'],
  ['menuitem', 'checked'],
  ['menuitem', 'default'],
  ['menuitem', 'disabled'],
  ['dialog', 'open'],
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

for my $test (
  ['a', 'text'],
  ['textarea', 'default_value'],
) {
  my $attr = $test->[1];
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ($test->[0]);
    is $el->$attr, '';
    $el->$attr ('hoge');
    is $el->$attr, 'hoge';
    $el->append_child ($doc->create_element ('foo'))->text_content ('abc');
    my $node1 = $el->append_child ($doc->create_text_node ('ahq'));
    is $el->$attr, 'hogeabcahq';
    $el->$attr ('');
    is $el->first_child, undef;
    is $node1->parent_node, undef;
    $el->$attr ('abc');
    is $el->$attr, 'abc';
    my $text = $el->first_child;
    $el->$attr ('bbqa');
    is $text->parent_node, undef;
    done $c;
  } n => 7, name => [$test->[0], $attr];
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
  ['input', 'maxlength', -1],
  ['textarea', 'maxlength', -1],
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
      ["34e6" => 34000000],
      [2**32+1 => 1],
      [2**31-1 => 2**31-1, 2**31-1],
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
      [-2**31-1 => 2**31-1],
      [-2**31-1.7 => 2**31-1],
    ) {
      $el->$attr ($_->[0]);
      is $el->$attr, $_->[1], [$_->[0], 'idl attr'];
      is $el->get_attribute ($attr), $_->[2] // $_->[1],
          [$_->[0], 'content attr'];
    }
    $el->set_attribute ($attr => '361');
    for (
      [-10 => $test->[2], 2**32-10],
      ["-120abc" => $test->[2], 2**32-120],
      ["-120.524abc" => $test->[2], 2**32-120],
      [2**32-1 => $test->[2], '4294967295'],
      [2**32-14.6 => $test->[2], '4294967281'],
      [2**31+1 => $test->[2], 2**31+1],
      [2**31 => $test->[2], 2**31],
      [-2**31+1 => $test->[2], 2**31+1],
      [-2**31 => $test->[2], 2**31],
      [-2**31+1.7 => $test->[2], 2**31+2],
    ) {
      dies_here_ok {
        $el->$attr ($_->[0]);
      };
      isa_ok $@, 'Web::DOM::Exception';
      is $@->name, 'IndexSizeError';
      is $@->message, 'The value cannot be set to a negative value';
      is $el->$attr, 361;
      is $el->get_attribute ($attr), 361;
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
  } n => 1 + 2*23 + 6*10 + 1*22, name => ['reflect long limited', @$test];
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
  ['input', 'size', 0],
  ['select', 'size', 0],
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
  ['textarea', 'cols', 20],
  ['textarea', 'rows', 2],
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
      is $@->message, 'The value cannot be set to zero';
      is $el->$attr, 361;
      is $el->get_attribute ($attr), 361;
    }
    for (
      ["" => $test->[2]],
      ["0" => $test->[2]],
      ["+0.12" => $test->[2]],
      ["-0.12" => $test->[2]],
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
      ["0x124" => $test->[2]],
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
  {element => 'input',
   attr => 'formenctype',
   default => '',
   invalid_default => 'application/x-www-form-urlencoded',
   valid_values => [
     ['application/x-www-form-URLEncoded' =>
          'application/x-www-form-urlencoded'],
     ['multipart/form-data' => 'multipart/form-data'],
     ['Text/Plain' => 'text/plain'],
   ],
   invalid_values => [[''], ['0'], [undef]]},
  {element => 'input',
   attr => 'formmethod',
   default => '',
   invalid_default => 'get',
   valid_values => [
     ['get' => 'get'],
     ['POST' => 'post'],
     ['Dialog' => 'dialog'],
   ],
   invalid_values => [[''], ['0'], [undef]]},
  {element => 'input',
   attr => 'inputmode',
   default => '',
   valid_values => [
     [verbatim => 'verbatim'],
     [latin => 'latin'],
     ['latin-name' => 'latin-name'],
     ['latin-prose' => 'latin-prose'],
     ['full-width-latin' => 'full-width-latin'],
     [kana => 'kana'],
     [katakana => 'katakana'],
     [numeric => 'numeric'],
     [tel => 'tel'],
     [email => 'email'],
     [url => 'url'],
   ],
   invalid_values => [[''], ['0'], [undef], ['default']]},
  {element => 'textarea',
   attr => 'inputmode',
   default => '',
   valid_values => [
     [verbatim => 'verbatim'],
     [latin => 'latin'],
     ['latin-name' => 'latin-name'],
     ['latin-prose' => 'latin-prose'],
     ['full-width-latin' => 'full-width-latin'],
     [kana => 'kana'],
     [katakana => 'katakana'],
     [numeric => 'numeric'],
     [tel => 'tel'],
     [email => 'email'],
     [url => 'url'],
   ],
   invalid_values => [[''], ['0'], [undef], ['default']]},
  {element => 'input',
   attr => 'type',
   default => 'text',
   valid_values => [
     [hidden => 'hidden'],
     [text => 'text'],
     [search => 'search'],
     [tel => 'tel'],
     [url => 'url'],
     [email => 'email'],
     [password => 'password'],
     [datetime => 'datetime'],
     [date => 'date'],
     [month => 'month'],
     [week => 'week'],
     [time => 'time'],
     ['datetime-local' => 'datetime-local'],
     [number => 'number'],
     [range => 'range'],
     [color => 'color'],
     [checkbox => 'checkbox'],
     [radio => 'radio'],
     [file => 'file'],
     [submit => 'submit'],
     [image => 'image'],
     [reset => 'reset'],
     [button => 'button'],
   ],
   invalid_values => [[''], ['0'], [undef], ['default']]},
  {element => 'button',
   attr => 'formenctype',
   default => '',
   invalid_default => 'application/x-www-form-urlencoded',
   valid_values => [
     ['application/x-www-form-URLEncoded' =>
          'application/x-www-form-urlencoded'],
     ['multipart/form-data' => 'multipart/form-data'],
     ['Text/Plain' => 'text/plain'],
   ],
   invalid_values => [[''], ['0'], [undef]]},
  {element => 'button',
   attr => 'formmethod',
   default => '',
   invalid_default => 'get',
   valid_values => [
     ['get' => 'get'],
     ['POST' => 'post'],
     ['Dialog' => 'dialog'],
   ],
   invalid_values => [[''], ['0'], [undef]]},
  {element => 'button',
   attr => 'type',
   default => 'submit',
   valid_values => [
     [submit => 'submit'],
     [reset => 'reset'],
     [button => 'button'],
     [menu => 'menu'],
   ],
   invalid_values => [[''], ['0'], [undef], ['default']]},
  {element => 'textarea',
   attr => 'wrap',
   default => 'soft',
   valid_values => [
     ['soft' => 'soft'],
     ['HARd' => 'hard'],
   ],
   invalid_values => [[''], ['0'], [undef]]},
  {element => 'menuitem',
   attr => 'type',
   default => 'command',
   valid_values => [
     [command => 'command'],
     [checkbox => 'checkbox'],
     [radio => 'radio'],
   ],
   invalid_values => [[''], ['0'], [undef], ['default']]},
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

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('select');
  is $el->type, 'select-one';
  done $c;
} n => 1, name => 'select-one type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('select');
  $el->multiple (1);
  is $el->type, 'select-multiple';
  done $c;
} n => 1, name => 'select-multiple type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('textarea');
  is $el->type, 'textarea';
  done $c;
} n => 1, name => 'textarea type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('keygen');
  is $el->type, 'keygen';
  done $c;
} n => 1, name => 'keygen type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('output');
  is $el->type, 'output';
  done $c;
} n => 1, name => 'output type';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
