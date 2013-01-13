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
  ['applet', 'align'],
  ['applet', 'alt'],
  ['applet', 'archive'],
  ['applet', 'code'],
  ['applet', 'height'],
  ['applet', 'name'],
  ['applet', 'width'],
  ['marquee', 'bgcolor'],
  ['marquee', 'height'],
  ['marquee', 'width'],
  ['frameset', 'cols'],
  ['frameset', 'rows'],
  ['frame', 'name'],
  ['frame', 'scrolling'],
  ['frame', 'frameborder'],
  ['frame', 'marginwidth'],
  ['frame', 'marginheight'],
  ['a', 'coords'],
  ['a', 'charset'],
  ['a', 'name'],
  ['a', 'rev'],
  ['a', 'shape'],
  ['basefont', 'color'],
  ['basefont', 'face'],
  ['body', 'text'],
  ['body', 'link'],
  ['body', 'alink'],
  ['body', 'vlink'],
  ['body', 'bgcolor'],
  ['body', 'background'],
  ['br', 'clear'],
  ['caption', 'align'],
  ['col', 'align'],
  ['col', 'width'],
  ['col', 'ch', 'char'],
  ['col', 'ch_off', 'charoff'],
  ['col', 'valign'],
  ['colgroup', 'align'],
  ['colgroup', 'width'],
  ['colgroup', 'ch', 'char'],
  ['colgroup', 'ch_off', 'charoff'],
  ['colgroup', 'valign'],
  ['div', 'align'],
  ['embed', 'align'],
  ['embed', 'name'],
  ['font', 'color'],
  ['font', 'face'],
  ['font', 'size'],
  ['h1', 'align'],
  ['h2', 'align'],
  ['h3', 'align'],
  ['h4', 'align'],
  ['h5', 'align'],
  ['h6', 'align'],
  ['hr', 'align'],
  ['hr', 'color'],
  ['hr', 'size'],
  ['hr', 'width'],
  ['html', 'version'],
  ['iframe', 'align'],
  ['iframe', 'scrolling'],
  ['iframe', 'frameborder'],
  ['iframe', 'marginwidth'],
  ['iframe', 'marginheight'],
  ['img', 'align'],
  ['img', 'name'],
  ['img', 'border'],
  ['input', 'align'],
  ['input', 'usemap'],
  ['legend', 'align'],
  ['li', 'type'],
  ['link', 'charset'],
  ['link', 'rev'],
  ['link', 'target'],
  ['meta', 'scheme'],
  ['object', 'align'],
  ['object', 'archive'],
  ['object', 'border'],
  ['object', 'code'],
  ['object', 'standby'],
  ['object', 'codetype'],
  ['object', 'border'],
  ['p', 'align'],
  ['param', 'type'],
  ['param', 'valuetype'],
  ['table', 'border'],
  ['table', 'align'],
  ['table', 'frame'],
  ['table', 'summary'],
  ['table', 'rules'],
  ['table', 'width'],
  ['table', 'bgcolor'],
  ['table', 'cellpadding'],
  ['table', 'cellspacing'],
  ['tbody', 'align'],
  ['tbody', 'ch', 'char'],
  ['tbody', 'ch_off', 'charoff'],
  ['tbody', 'valign'],
  ['thead', 'align'],
  ['thead', 'ch', 'char'],
  ['thead', 'ch_off', 'charoff'],
  ['thead', 'valign'],
  ['tfoot', 'align'],
  ['tfoot', 'ch', 'char'],
  ['tfoot', 'ch_off', 'charoff'],
  ['tfoot', 'valign'],
  ['td', 'align'],
  ['td', 'ch', 'char'],
  ['td', 'ch_off', 'charoff'],
  ['td', 'valign'],
  ['td', 'axis'],
  ['td', 'height'],
  ['td', 'width'],
  ['td', 'bgcolor'],
  ['th', 'align'],
  ['th', 'ch', 'char'],
  ['th', 'ch_off', 'charoff'],
  ['th', 'valign'],
  ['th', 'axis'],
  ['th', 'height'],
  ['th', 'width'],
  ['th', 'bgcolor'],
  ['td', 'abbr'],
  ['tr', 'align'],
  ['tr', 'ch', 'char'],
  ['tr', 'ch_off', 'charoff'],
  ['tr', 'valign'],
  ['tr', 'bgcolor'],
  ['ul', 'type'],
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
    $el->$attr ("\x{5000}");
    is $el->$attr, "\x{5000}";
    $el->$attr (undef);
    is $el->$attr, '';
    $el->set_attribute ($test->[2] || $attr => 124);
    is $el->$attr, 124;
    done $c;
  } n => 9, name => ['string reflect attributes', @$test];
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
  ['marquee', 'truespeed'],
  ['frame', 'noresize'],
  ['dir', 'compact'],
  ['dl', 'compact'],
  ['hr', 'noshade'],
  ['menu', 'compact'],
  ['object', 'declare'],
  ['ol', 'compact'],
  ['td', 'nowrap'],
  ['th', 'nowrap'],
  ['ul', 'compact'],
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
  ['basefont', 'size', 0],
  ['pre', 'width', 0],
  ['ol', 'start', 1],
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
      ["2147483648" => $test->[2]],
      ["1452151544454" => $test->[2]],
      ["-1452151544454" => $test->[2]],
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
      } $c, name => ['getter', $_->[0]], n => 1;
    }
    done $c;
  } n => 1 + 2*27 + 1*20, name => ['reflect long', @$test];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('ol');
  $el->reversed (1);
  is $el->start, 0;
  $el->append_child ($doc->create_element ('li'));
  is $el->start, 1;
  $el->append_child ($doc->create_element_ns (undef, 'li'));
  $el->append_child ($doc->create_comment ('foo'));
  is $el->start, 1;
  $el->append_child ($doc->create_element ('li'));
  $el->append_child ($doc->create_element ('ul'))
      ->append_child ($doc->create_element ('li'));
  $el->append_child ($doc->create_element ('li'));
  is $el->start, 3;
  $el->start (4);
  is $el->start, 4;
  $el->start (-13);
  is $el->start, -13;
  done $c;
} n => 6, name => 'reflect long ol reversed';

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
  ['applet', 'hspace', 0],
  ['applet', 'vspace', 0],
  ['marquee', 'hspace', 0],
  ['marquee', 'vspace', 0],
  ['marquee', 'scrollamount', 6],
  ['marquee', 'scrolldelay', 85],
  ['img', 'hspace', 0],
  ['img', 'vspace', 0],
  ['object', 'hspace', 0],
  ['object', 'vspace', 0],
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
  {element => 'marquee',
   attr => 'behavior',
   default => 'scroll',
   valid_values => [
     [Scroll => 'scroll'],
     [SliDe => 'slide'],
     [alTErnate => 'alternate'],
   ],
   invalid_values => [[''], ['0'], [undef], ['default']]},
  {element => 'marquee',
   attr => 'direction',
   default => 'left',
   valid_values => [
     [LEFT => 'left'],
     [righT => 'right'],
     [up => 'up'],
     [dOWN => 'down'],
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
  my $el = $doc->create_element ('dfn');
  is $el->contextmenu, undef;

  my $el2 = $doc->create_element ('menu');
  $el2->set_attribute (id => 'abc');
  $doc->append_child ($el2);
  my $el5 = $doc->create_element ('hoge');
  $el5->set_attribute (id => 'abc');
  $el2->append_child ($el5);
  my $el3 = $doc->create_element ('menu');
  $el3->set_attribute (id => 'abc');
  $el2->append_child ($el3);

  $el->contextmenu ($el2);
  is $el->contextmenu, $el2;
  is $el->get_attribute ('contextmenu'), 'abc';
  
  $el->contextmenu ($el3);
  is $el->contextmenu, undef;
  is $el->get_attribute ('contextmenu'), '';

  $el->remove_attribute ('contextmenu');
  my $el4 = $doc->create_element ('menu');
  $el4->set_attribute (id => 'abc');
  $el->contextmenu ($el4);
  is $el->contextmenu, undef;
  is $el->get_attribute ('contextmenu'), '';

  $el->remove_attribute ('contextmenu');
  $el4->append_child ($el);
  $el->contextmenu ($el4);
  is $el->contextmenu, undef;
  is $el->get_attribute ('contextmenu'), '';

  $el->remove_attribute ('contextmenu');
  $el2->id ('');
  $el->contextmenu ($el2);
  is $el->contextmenu, undef;
  is $el->get_attribute ('contextmenu'), '';

  $el->set_attribute (contextmenu => $el5->id);
  is $el->contextmenu, undef;

  $el->remove_attribute ('contextmenu');
  $el->contextmenu ($el3);
  is $el->contextmenu, undef;
  is $el->get_attribute ('contextmenu'), '';

  $el->set_attribute (contextmenu => 'fuga');
  is $el->contextmenu, undef;

  done $c;
} n => 15, name => 'reflect HTMLElement contextmenu';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('dfn');
  $el->set_attribute (contextmenu => 'aa');
  my $e = $doc->create_element ('foo');
  dies_here_ok {
    $el->contextmenu ($e);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->name, 'TypeError';
  is $@->message, 'The argument is not a Web::DOM::HTMLMenuElement';
  is $el->get_attribute ('contextmenu'), 'aa';
  done $c;
} n => 5, name => 'reflect HTMLElement contextmenu bad new value';

for (
  ['not in document' => sub { }],
  ['document element' => sub { $_[0]->append_child ($_[1]) }],
  ['document > non-html > html' => sub {
     my $el = $_[0]->create_element_ns ('hhh', 'fff');
     $_[0]->append_child ($el);
     $el->append_child ($_[1]);
   }],
) {
  my $code = $_->[1];
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('xmp');
    $code->($doc, $el);
    ok $el->translate;
    $el->translate (1);
    ok $el->translate;
    is $el->get_attribute_ns (undef, 'translate'), 'yes';
    $el->translate (0);
    ok not $el->translate;
    is $el->get_attribute_ns (undef, 'translate'), 'no';
    $el->set_attribute (translate => 'No');
    ok not $el->translate;
    $el->set_attribute (translate => 'YES');
    ok $el->translate;
    $el->set_attribute (translate => '');
    ok $el->translate;
    $el->set_attribute (translate => 'hoge');
    ok $el->translate;
    done $c;
  } n => 9, name => ['translate not in document', $_->[0]];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  $el1->append_child ($el2);

  ok $el2->translate;
  $el1->translate (0);
  ok not $el2->translate;
  $el1->translate (1);
  ok $el2->translate;
  $el2->translate (0);
  ok not $el2->translate;
  $el2->translate (1);
  ok $el2->translate;
  $el1->translate (0);
  ok $el2->translate;
  $el2->set_attribute (translate => '');
  ok $el2->translate;
  $el2->set_attribute (translate => 'auto');
  ok not $el2->translate;
  $el1->translate (1);
  ok $el2->translate;
  done $c;
} n => 9, name => 'translate inherit';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns (undef, 'a');
  my $el2 = $doc->create_element ('b');
  $el1->append_child ($el2);

  ok $el2->translate;
  $el1->set_attribute (translate => 'no');
  ok $el2->translate;
  $el1->set_attribute (translate => 'yes');
  ok $el2->translate;
  $el2->translate (0);
  ok not $el2->translate;
  $el2->translate (1);
  ok $el2->translate;
  $el1->set_attribute (translate => 'no');
  ok $el2->translate;
  $el2->set_attribute (translate => '');
  ok $el2->translate;
  $el2->set_attribute (translate => 'auto');
  ok $el2->translate;
  $el1->set_attribute (translate => 'yes');
  ok $el2->translate;
  done $c;
} n => 9, name => 'translate inherit not html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el0 = $doc->create_element ('c');
  my $el2 = $doc->create_element ('b');
  $el1->append_child ($el0);
  $el0->append_child ($el2);

  ok $el2->translate;
  $el1->translate (0);
  ok not $el2->translate;
  $el1->translate (1);
  ok $el2->translate;
  $el2->translate (0);
  ok not $el2->translate;
  $el2->translate (1);
  ok $el2->translate;
  $el1->translate (0);
  ok $el2->translate;
  $el2->set_attribute (translate => '');
  ok $el2->translate;
  $el2->set_attribute (translate => 'auto');
  ok not $el2->translate;
  $el1->translate (1);
  ok $el2->translate;
  done $c;
} n => 9, name => 'translate inherit html > html > html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el0 = $doc->create_element_ns (undef, 'c');
  my $el2 = $doc->create_element ('b');
  $el1->append_child ($el0);
  $el0->append_child ($el2);

  ok $el2->translate;
  $el1->translate (0);
  ok not $el2->translate;
  $el1->translate (1);
  ok $el2->translate;
  $el2->translate (0);
  ok not $el2->translate;
  $el2->translate (1);
  ok $el2->translate;
  $el1->translate (0);
  ok $el2->translate;
  $el2->set_attribute (translate => '');
  ok $el2->translate;
  $el2->set_attribute (translate => 'auto');
  ok not $el2->translate;
  $el1->translate (1);
  ok $el2->translate;
  done $c;
} n => 9, name => 'translate inherit html > non-html > html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('small');
  ok not $el->draggable;
  $el->draggable (1);
  ok $el->draggable;
  is $el->get_attribute_ns (undef, 'draggable'), 'true';
  $el->draggable (0);
  ok not $el->draggable;
  is $el->get_attribute_ns (undef, 'draggable'), 'false';
  $el->set_attribute (draggable => 'TruE');
  ok $el->draggable;
  $el->set_attribute (draggable => 'FALSe');
  ok not $el->draggable;
  $el->set_attribute (draggable => 'hoge');
  ok not $el->draggable;
  done $c;
} n => 8, name => 'draggable normal element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('img');
  ok $el->draggable;
  $el->draggable (1);
  ok $el->draggable;
  is $el->get_attribute_ns (undef, 'draggable'), 'true';
  $el->draggable (0);
  ok not $el->draggable;
  is $el->get_attribute_ns (undef, 'draggable'), 'false';
  $el->set_attribute (draggable => 'TruE');
  ok $el->draggable;
  $el->set_attribute (draggable => 'FALSe');
  ok not $el->draggable;
  $el->set_attribute (draggable => 'hoge');
  ok $el->draggable;
  done $c;
} n => 8, name => 'draggable img';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  ok not $el->draggable;
  $el->draggable (1);
  ok $el->draggable;
  is $el->get_attribute_ns (undef, 'draggable'), 'true';
  $el->draggable (0);
  ok not $el->draggable;
  is $el->get_attribute_ns (undef, 'draggable'), 'false';
  $el->set_attribute (draggable => 'TruE');
  ok $el->draggable;
  $el->set_attribute (draggable => 'FALSe');
  ok not $el->draggable;
  $el->set_attribute (draggable => 'hoge');
  ok not $el->draggable;
  done $c;
} n => 8, name => 'draggable a without href';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute (href => '');
  ok $el->draggable;
  $el->draggable (1);
  ok $el->draggable;
  is $el->get_attribute_ns (undef, 'draggable'), 'true';
  $el->draggable (0);
  ok not $el->draggable;
  is $el->get_attribute_ns (undef, 'draggable'), 'false';
  $el->set_attribute (draggable => 'TruE');
  ok $el->draggable;
  $el->set_attribute (draggable => 'FALSe');
  ok not $el->draggable;
  $el->set_attribute (draggable => 'hoge');
  ok $el->draggable;
  done $c;
} n => 8, name => 'draggable a[href]';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('strike');
  is $el->contenteditable, 'inherit';
  for my $value (qw(true TruE false FalSE FALSE)) {
    $el->contenteditable ($value);
    is $el->contenteditable, lc $value;
    is $el->get_attribute ('contenteditable'), lc $value;

    $el->set_attribute (contenteditable => $value);
    is $el->contenteditable, lc $value;
  }
  $el->contenteditable ('inherit');
  is $el->contenteditable, 'inherit';
  ok not $el->has_attribute ('contenteditable');
  $el->contenteditable ('true');
  $el->contenteditable ('INHERIT');
  is $el->contenteditable, 'inherit';
  ok not $el->has_attribute ('contenteditable');
  $el->set_attribute (contenteditable => 'InherIT');
  is $el->contenteditable, 'inherit';
  done $c;
} n => 21, name => 'contenteditable';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('foo');
  $el->contenteditable ('false');

  dies_here_ok {
    $el->contenteditable ('yes');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'An invalid |contenteditable| value is specified';
  is $el->contenteditable, 'false';
  done $c;
} n => 5, name => 'contenteditable bad value';

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

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('script');
  is $el->event, '';
  $el->event ('hoge');
  is $el->event, '';
  is $el->get_attribute ('event'), undef;
  $el->set_attribute (event => 'foo');
  is $el->event, '';
  done $c;
} n => 4, name => 'script.event';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('script');
  is $el->html_for, '';
  $el->html_for ('hoge');
  is $el->html_for, '';
  is $el->get_attribute ('for'), undef;
  $el->set_attribute (for => 'foo');
  is $el->html_for, '';
  done $c;
} n => 4, name => 'script.html_for';

for my $name (qw(caption thead tfoot)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element ('table');
    is $table->$name, undef;

    my $cap1 = $doc->create_element ($name);
    $table->$name ($cap1);
    is $table->$name, $cap1;
    is $cap1->parent_node, $table;

    my $cap2 = $doc->create_element ($name);
    $table->$name ($cap2);
    is $table->$name, $cap2;
    is $cap2->parent_node, $table;
    is $cap1->parent_node, undef;

    $table->append_child ($doc->create_element ('foo'));
    $table->insert_before ($doc->create_element ('foo'), $cap2);
    $table->$name ($cap2);
    is $table->first_child, $cap2;
    $table->append_child ($cap1);
    $table->append_child ($cap2);

    is $table->$name, $cap1;
    my $cap3 = $doc->create_element ($name);
    $table->$name ($cap3);
    is $table->$name, $cap3;
    is $cap1->parent_node, undef;
    is $cap2->parent_node, $table;
    is $cap3->parent_node, $table;
    is $table->first_child, $cap3;

    done $c;
  } n => 13, name => ['table', $name];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element ('table');
    dies_here_ok {
      $table->$name (undef);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, "The new value is not a |$name| element";
    is $table->first_child, undef;
    done $c;
  } n => 5, name => ['table', $name, 'undef'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element ('table');
    dies_here_ok {
      $table->$name ($doc->create_element_ns (undef, $name));
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->name, 'TypeError';
    is $@->message, "The new value is not a |$name| element";
    is $table->first_child, undef;
    done $c;
  } n => 5, name => ['table', $name, 'not expected element'];

  my $create_name = "create_$name";
  my $pfx = $name eq 'caption' ? '' : '<tr><td>';
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->manakai_is_html (1);
    my $table = $doc->create_element ('table');
    $table->inner_html ('<tr><th><td>hoge<tbody>');
    my $cap = $table->$create_name;
    is $table->child_nodes->length, 3;
    is $table->first_child, $cap;
    isa_ok $cap, 'Web::DOM::HTMLElement';
    is $cap->namespace_uri, 'http://www.w3.org/1999/xhtml';
    is $cap->local_name, $name;
    is $cap->first_child, undef;
    done $c;
  } n => 6, name => ['table', $create_name, 'new'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->manakai_is_html (1);
    my $table = $doc->create_element ('table');
    $table->inner_html ("<tr><th><td>hoge<tbody><$name>${pfx}hoge</$name>");
    my $caption = $table->last_child;
    my $cap = $table->$create_name;
    is $table->child_nodes->length, 3;
    is $table->last_child, $cap;
    isa_ok $cap, 'Web::DOM::HTMLElement';
    is $cap, $caption;
    is $cap->text_content, 'hoge';
    done $c;
  } n => 5, name => ['table', $create_name, 'existing'];

  my $delete_name = "delete_$name";
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->manakai_is_html (1);
    my $table = $doc->create_element ('table');
    $table->inner_html ("<tr><th><td>hoge<tbody><$name>${pfx}hoge</$name>");
    my $caption = $table->last_child;
    $table->$delete_name;
    is $table->child_nodes->length, 2;
    is $caption->parent_node, undef;
    done $c;
  } n => 2, name => ['table', $delete_name, 'deleted'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->manakai_is_html (1);
    my $table = $doc->create_element ('table');
    $table->inner_html
        ("<tr><th><td>hoge<tbody><$name>${pfx}hoge</$name><$name>${pfx}hogefuga</$name>");
    my $caption1 = $table->last_child;
    my $caption2 = $caption1->previous_sibling;
    $table->$delete_name;
    is $table->child_nodes->length, 3;
    is $caption2->parent_node, undef;
    is $caption1->parent_node, $table;
    is $table->last_child, $caption1;
    done $c;
  } n => 4, name => ['table', $delete_name, 'deleted multiple'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->manakai_is_html (1);
    my $table = $doc->create_element ('table');
    $table->inner_html ('<tr><th><td>hoge<tbody>');
    $table->$delete_name;
    is $table->child_nodes->length, 2;
    done $c;
  } n => 1, name => ['table', $delete_name, 'not found'];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element ('table');
  $table->inner_html ('<colgroup/><caption/><caption/><!----> <col/><tbody/>');
  my $thead = $doc->create_element ('thead');
  $table->thead ($thead);
  is $table->child_nodes->[5], $thead;
  done $c;
} n => 1, name => 'thead insertion point';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element ('table');
  $table->inner_html ('<colgroup/><caption/><caption/><!----> <col/><tbody/>');
  my $thead = $table->create_thead;
  is $table->child_nodes->[5], $thead;
  done $c;
} n => 1, name => 'create_thead insertion point';

for my $name (qw(tbody tfoot)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element ('table');
    $table->inner_html ('<colgroup/><caption/><caption/><!----> <col/><tbody/>');
    my $tbody = $doc->create_element ($name);
    dies_here_ok {
      $table->thead ($tbody);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'The new value is not a |thead| element';
    is $tbody->parent_node, undef;
    is $table->child_nodes->length, 7;
    done $c;
  } n => 6, name => ['create_thead bad element', $name];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element ('table');
  $table->inner_html ('<colgroup/><caption/><caption/><thead/><!----> <col/><tbody/>');
  my $tfoot = $doc->create_element ('tfoot');
  $table->tfoot ($tfoot);
  is $table->child_nodes->[6], $tfoot;
  done $c;
} n => 1, name => 'tfoot insertion point';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element ('table');
  $table->inner_html ('<colgroup/><caption/><thead/><caption/><!----> <col/><tbody/>');
  my $tfoot = $table->create_tfoot;
  is $table->child_nodes->[6], $tfoot;
  done $c;
} n => 1, name => 'create_tfoot insertion point';

for my $name (qw(thead tbody)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element ('table');
    $table->inner_html ('<colgroup/><caption/><caption/><!----> <col/><tbody/>');
    my $tbody = $doc->create_element ($name);
    dies_here_ok {
      $table->tfoot ($tbody);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'HierarchyRequestError';
    is $@->message, 'The new value is not a |tfoot| element';
    is $tbody->parent_node, undef;
    is $table->child_nodes->length, 7;
    done $c;
  } n => 6, name => ['create_tfoot bad element', $name];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element ('table');
  my $tbody = $table->create_tbody;
  isa_ok $tbody, 'Web::DOM::HTMLTableSectionElement';
  is $tbody->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $tbody->local_name, 'tbody';
  is $table->first_child, $tbody;
  is $table->child_nodes->length, 1;
  is $tbody->child_nodes->length, 0;
  done $c;
} n => 6, name => 'create_tbody empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element ('table');
  $table->inner_html (q{<tbody/><!----><tfoot/><a/><!---->});
  my $tbody = $table->create_tbody;
  isa_ok $tbody, 'Web::DOM::HTMLTableSectionElement';
  is $tbody->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $tbody->local_name, 'tbody';
  is $table->child_nodes->length, 6;
  is $table->child_nodes->[1], $tbody;
  is $tbody->child_nodes->length, 0;
  done $c;
} n => 6, name => 'create_tbody not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element ('table');
  $table->inner_html (q{<tbody xmlns=""/><!----><tfoot/><a/><!---->});
  my $tbody = $table->create_tbody;
  isa_ok $tbody, 'Web::DOM::HTMLTableSectionElement';
  is $tbody->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $tbody->local_name, 'tbody';
  is $table->child_nodes->length, 6;
  is $table->child_nodes->[5], $tbody;
  is $tbody->child_nodes->length, 0;
  done $c;
} n => 6, name => 'create_tbody not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element ('table');
  $table->inner_html (q{<tbody/><tfoot><tbody/></tfoot><tbody/><tbody/><caption/><tbody xmlns=""/> <!----><tbody/>});
  my $col1 = $table->tbodies;
  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 4;
  is $col1->[0], $table->first_child;
  is $col1->[1], $table->child_nodes->[2];
  is $col1->[2], $table->child_nodes->[3];
  is $col1->[3], $table->child_nodes->[-1];
  my $el1 = $doc->create_element ('tbody');
  $table->insert_before ($el1, $table->first_child);
  is $col1->length, 5;
  is $col1->[0], $el1;
  is $table->tbodies, $col1;
  isnt $doc->create_element ('table')->tbodies, $col1;
  done $c;
} n => 10, name => 'tbodies';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element ('table');
  my $col1 = $table->rows;
  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 0;

  $table->inner_html (q{<caption><tr n="1"/></caption><thead
><tr n="2"/><tr n="3"/>
<hoge/></thead><tfoot><tr n="4"/></tfoot>
<tbody/><tr n="5"/>
<tbody><tr n="6"/><tr n="7"/><tr n="8"><tr n="9"/></tr
><thead><tr n="10"/></thead></tbody>
<tr n="11"/><foo><tr n="12"/></foo><tfoot><tr n="12"/></tfoot>});
  is $col1->length, 9;
  is $col1->[0]->get_attribute ('n'), 2;
  is $col1->[1]->get_attribute ('n'), 3;
  is $col1->[2]->get_attribute ('n'), 5;
  is $col1->[3]->get_attribute ('n'), 6;
  is $col1->[4]->get_attribute ('n'), 7;
  is $col1->[5]->get_attribute ('n'), 8;
  is $col1->[6]->get_attribute ('n'), 11;
  is $col1->[7]->get_attribute ('n'), 4;
  is $col1->[8]->get_attribute ('n'), 12;
  is $table->rows, $col1;
  done $c;
} n => 13, name => 'rows';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element ('table');
  $table->inner_html (q{<!----> hoge <td/> <thead/>});
  my $tr = $table->insert_row (0);
  is $tr->namespace_uri, $table->namespace_uri;
  is $tr->local_name, 'tr';
  is $tr->parent_node, $table->last_child;
  is $table->last_child->local_name, 'tbody';
  is $table->last_child->namespace_uri, $tr->namespace_uri;
  my $tbody = $table->last_child;
  is $tr->first_child, undef;

  my $tr2 = $table->insert_row (1);
  is $tr2->previous_sibling, $tr;
  is $tr2->local_name, 'tr';

  $tr->parent_node->text_content ('');
  
  my $tr3 = $table->insert_row (0);
  is $tr3->local_name, 'tr';
  is $tr3->parent_node, $tbody;

  my $tr4 = $doc->create_element ('tr');
  $table->append_child ($tr4);
  my $tr5 = $table->insert_row (-1);
  is $tr5->previous_sibling, $tr4;

  my $tfoot = $doc->create_element ('tfoot');
  $tfoot->inner_html (q{<tr/>});
  my $tr6 = $tfoot->first_child;

  $table->insert_before ($tfoot, $table->first_child);

  my $tr7 = $table->insert_row (4);
  is $tr7->previous_sibling, $tr6;

  my $tr8 = $table->insert_row (3);
  is $tr8->previous_sibling, undef;
  is $tr8->parent_node, $tfoot;

  done $c;
} n => 14, name => 'insert_row';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element ('table');
  $table->inner_html (q{<tbody><tr/></tbody><tr/>});
  for my $index (-6, -51, 3, 12, 21, 2**32+3, 2**31) {
    dies_here_ok {
      $table->insert_row ($index);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'IndexSizeError';
    is $@->message, 'The specified row index is invalid';
  }
  is $table->child_nodes->length, 2;
  is $table->first_child->child_nodes->length, 1;
  done $c;
} n => 7*4+2, name => 'insert_row index size error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element ('table');
  $table->inner_html (q{<tbody><tr/></tbody><tr/>});
  
  $table->insert_row (0+'nan')->set_attribute (id => 1);
  $table->insert_row (0+'inf')->set_attribute (id => 2);
  $table->insert_row (1.41)->set_attribute (id => 3);
  $table->insert_row (2**32-1)->set_attribute (id => 4);

  is $table->inner_html, q{<tbody xmlns="http://www.w3.org/1999/xhtml"><tr id="2"></tr><tr id="3"></tr><tr id="1"></tr><tr></tr></tbody><tr xmlns="http://www.w3.org/1999/xhtml"></tr><tr xmlns="http://www.w3.org/1999/xhtml" id="4"></tr>};
  done $c;
} n => 1, name => 'insert_row index stupid';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element ('table');
  $table->insert_row->set_attribute (id => 1);
  $table->insert_row->set_attribute (id => 2);
  is $table->outer_html, q{<table xmlns="http://www.w3.org/1999/xhtml"><tbody><tr id="1"></tr><tr id="2"></tr></tbody></table>};
  done $c;
} n => 1, name => 'insert_row default';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element ('table');
  $table->inner_html (q{<tbody><tr/><tr/></tbody><tr/>});
  $table->delete_row (-1);
  is $table->inner_html, q{<tbody xmlns="http://www.w3.org/1999/xhtml"><tr></tr><tr></tr></tbody>};
  $table->delete_row (1);
  is $table->inner_html, q{<tbody xmlns="http://www.w3.org/1999/xhtml"><tr></tr></tbody>};
  $table->delete_row (2**32);
  is $table->inner_html, q{<tbody xmlns="http://www.w3.org/1999/xhtml"></tbody>};
  done $c;
} n => 3, name => 'delete_row';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element ('table');
  $table->inner_html (q{<tbody><tr/><tr/></tbody><tr/>});
  for (2**32-2, -50.12, 100.21, 3, -2) {
    dies_here_ok {
      $table->delete_row ($_);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'IndexSizeError';
    is $@->message, 'The specified row index is invalid';
  }
  is $table->inner_html, q{<tbody xmlns="http://www.w3.org/1999/xhtml"><tr></tr><tr></tr></tbody><tr xmlns="http://www.w3.org/1999/xhtml"></tr>};
  done $c;
} n => 4*5 + 1, name => 'delete_row error';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
