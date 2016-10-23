use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->parent->parent->child
    ('t_deps/modules/*/lib')->stringify;
use lib glob path (__FILE__)->parent->parent->parent->child
    ('t_deps/lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Internal;
use Web::DOM::Document;
use Web::CSS::Parser;

for my $attr (qw(title lang accesskey)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'strong');
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
  ['meta', 'name'],
  ['meta', 'content'],
  ['meta', 'http_equiv', 'http-equiv'],
  ['style', 'type'],
  ['style', 'media'],
  ['style', 'nonce'],
  ['script', 'charset'],
  ['script', 'type'],
  ['script', 'html_for', 'for'],
  ['script', 'event'],
  ['script', 'nonce'],
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
  ['img', 'usemap'],
  ['iframe', 'name'],
  ['iframe', 'srcdoc'],
  ['iframe', 'width'],
  ['iframe', 'height'],
  ['embed', 'type'],
  ['embed', 'width'],
  ['embed', 'height'],
  ['object', 'type'],
  ['object', 'name'],
  ['object', 'usemap'],
  ['object', 'width'],
  ['object', 'height'],
  ['param', 'name'],
  ['param', 'value'],
  ['source', 'type'],
  ['source', 'media'],
  ['source', 'srcset'],
  ['source', 'sizes'],
  ['track', 'srclang'],
  ['track', 'label'],
  ['map', 'name'],
  ['area', 'alt'],
  ['area', 'coords'],
  ['area', 'shape'],
  ['area', 'target'],
  ['area', 'rel'],
  ['area', 'download'],
  ['th', 'abbr'],
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
  ['td', 'headers'],
  ['th', 'headers'],
  ['a', 'ping'],
  ['area', 'ping'],
) {
  my $attr = $test->[1];
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->[0]);
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

for my $test (
  ['hoge', 'itemid'],
  ['blockquote', 'cite'],
  ['q', 'cite'],
  ['a', 'href'],
  ['area', 'href'],
  ['ins', 'cite'],
  ['del', 'cite'],
  ['img', 'longdesc'],
  ['img', 'lowsrc'],
  ['iframe', 'longdesc'],
  ['frame', 'src'],
  ['frame', 'longdesc'],
  ['object', 'codebase'],
  ['applet', 'object'],
  ['applet', 'codebase'],
) {
  my $attr = $test->[1];
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->manakai_set_url ('http://foo/bar/');
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->[0]);
    is $el->$attr, '';
    $el->$attr ('hoge');
    is $el->$attr, 'http://foo/bar/hoge';
    is $el->get_attribute ($attr), 'hoge';
    $el->$attr ('  http://ABC/ ');
    is $el->$attr, 'http://abc/';
    is $el->get_attribute ($attr), '  http://ABC/ ';
    $el->$attr ('htTp://fo:a');
    is $el->$attr, 'htTp://fo:a';
    is $el->get_attribute ($attr), 'htTp://fo:a';
    $el->$attr ('');
    is $el->$attr, 'http://foo/bar/';
    is $el->get_attribute ($attr), '';
    $el->set_attribute_ns (XML_NS, 'base' => 'ftp://hoge');
    is $el->$attr, 'http://foo/bar/';
    done $c;
  } n => 10, name => ['reflect url', $test->[0], $test->[1]];
}

for my $test (
  ['link', 'href'],
  ['script', 'src'],
  ['img', 'src'],
  ['iframe', 'src'],
  ['embed', 'src'],
  ['object', 'data'],
  ['audio', 'src'],
  ['video', 'src'],
  ['video', 'poster'],
  ['source', 'src'],
  ['track', 'src'],
  ['form', 'action'],
  ['input', 'src'],
  ['input', 'formaction'],
  ['button', 'formaction'],
  ['menuitem', 'icon'],
) {
  my $attr = $test->[1];
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->manakai_set_url ('http://foo/bar/');
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->[0]);
    is $el->$attr, '';
    $el->$attr ('hoge');
    is $el->$attr, 'http://foo/bar/hoge';
    is $el->get_attribute ($attr), 'hoge';
    $el->$attr ('  http://ABC/ ');
    is $el->$attr, 'http://abc/';
    is $el->get_attribute ($attr), '  http://ABC/ ';
    $el->$attr ('htTp://fo:a');
    is $el->$attr, 'htTp://fo:a';
    is $el->get_attribute ($attr), 'htTp://fo:a';
    $el->$attr ('');
    is $el->$attr, 'http://foo/bar/';
    is $el->get_attribute ($attr), '';
    $el->set_attribute_ns (XML_NS, 'base' => 'ftp://hoge');
    is $el->$attr, 'http://foo/bar/';
    done $c;
  } n => 10, name => ['reflect neurl', $test->[0], $test->[1]];
}

for my $attr (qw(itemscope hidden)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'strong');
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
  ['script', 'defer'],
  ['ol', 'reversed'],
  ['img', 'ismap'],
  ['iframe', 'allowfullscreen'],
  ['iframe', 'allowusermedia'],
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
  ['video', 'playsinline'],
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
  my $attr = $test->[2] || $test->[1];
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->[0]);
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
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $el_name);
    is $el->text, '';
    $el->text ('hoge');
    is $el->text, 'hoge';
    $el->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo'))->text_content ('abc');
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
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->[0]);
    is $el->$attr, '';
    $el->$attr ('hoge');
    is $el->$attr, 'hoge';
    $el->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo'))->text_content ('abc');
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
  ['pre', 'width', 0],
  ['ol', 'start', 1],
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->[0]);
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
      is $el->get_attribute ($attr), defined $_->[2] ? $_->[2] : $_->[1];
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
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ol');
  $el->reversed (1);
  is $el->start, 1;
  $el->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'li'));
  is $el->start, 1;
  $el->append_child ($doc->create_element_ns (undef, 'li'));
  $el->append_child ($doc->create_comment ('foo'));
  is $el->start, 1;
  $el->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'li'));
  $el->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'ul'))
      ->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'li'));
  $el->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'li'));
  is $el->start, 1;
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
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->[0]);
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
      is $el->get_attribute ($attr), defined $_->[2] ? $_->[2] : $_->[1],
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
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->[0]);
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
      is $el->get_attribute ($attr), defined $_->[2] ? $_->[2] : $_->[1],
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
  ['input', 'size', 20, undef],
  ['colgroup', 'span', 1, 1],
  ['col', 'span', 1, 1],
  ['textarea', 'cols', 20, 20],
  ['textarea', 'rows', 2, 2],
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->[0]);
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
      is $el->get_attribute ($attr), defined $_->[2] ? $_->[2] : $_->[1],
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
      if (defined $test->[3]) {
        $el->$attr ($_->[0]);
        is $el->$attr, $test->[3];
        is $el->get_attribute ($attr), $test->[3];
        ok 1;
        ok 1;
        ok 1;
        ok 1;
      } else {
        dies_here_ok {
          $el->$attr ($_->[0]);
        };
        isa_ok $@, 'Web::DOM::Exception';
        is $@->name, 'IndexSizeError';
        is $@->message, 'The value cannot be set to zero';
        is $el->$attr, 361;
        is $el->get_attribute ($attr), 361;
      }
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
  {element => 'td',
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
   default => 'application/x-www-form-urlencoded',
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
   default => 'application/x-www-form-urlencoded',
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
   default => 'get',
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
  {element => 'menu',
   attr => 'type',
   default => 'toolbar',
   valid_values => [
     [toolbar => 'toolbar'],
     [ConteXt => 'context'],
   ],
   invalid_values => [[''], ['0'], [undef], ['menu'], ['Popup']]},
) {
  my $attr = $test->{attr};
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->{element});
    is $el->$attr, $test->{default};
    for (@{$test->{valid_values}}) {
      $el->$attr ($_->[0]);
      is $el->$attr, $_->[1];
      is $el->get_attribute ($test->{content_attr} || $attr), $_->[0];
    }
    for (
      (map { [$_->[0].'  '] } @{$test->{valid_values}}),
      @{$test->{invalid_values}},
      ['#invalid'],
      ['#missing'],
    ) {
      $el->$attr ($_->[0]);
      is $el->$attr, defined $test->{invalid_default} ? $test->{invalid_default} : $test->{default};
      is $el->get_attribute ($test->{content_attr} || $attr), defined $_->[0] ? $_->[0] : '';
    }
    done $c;
  } n => 3 + @{$test->{valid_values}}*2 +
      (@{$test->{valid_values}} + @{$test->{invalid_values}} + 1)*2,
      name => ['reflect enumerated attr', $test->{element}, $test->{attr}];

}

for my $test (
  {element => 'link',
   attr => 'crossorigin',
   default => undef,
   valid_values => [
     ['' => 'anonymous'],
     [anonymoUs => 'anonymous'],
     ['USE-credentials' => 'use-credentials'],
   ],
   invalid_values => [['0'], [undef], ['menu']]},
  {element => 'script',
   attr => 'crossorigin',
   default => undef,
   valid_values => [
     ['' => 'anonymous'],
     [anonymoUs => 'anonymous'],
     ['USE-credentials' => 'use-credentials'],
   ],
   invalid_values => [['0'], [undef], ['menu']]},
  {element => 'img',
   attr => 'crossorigin',
   default => undef,
   valid_values => [
     ['' => 'anonymous'],
     [anonymoUs => 'anonymous'],
     ['USE-credentials' => 'use-credentials'],
   ],
   invalid_values => [['0'], [undef], ['menu']]},
  {element => 'video',
   attr => 'crossorigin',
   default => undef,
   valid_values => [
     ['' => 'anonymous'],
     [anonymoUs => 'anonymous'],
     ['USE-credentials' => 'use-credentials'],
   ],
   invalid_values => [['0'], [undef], ['menu']]},
  {element => 'audio',
   attr => 'crossorigin',
   default => undef,
   valid_values => [
     ['' => 'anonymous'],
     [anonymoUs => 'anonymous'],
     ['USE-credentials' => 'use-credentials'],
   ],
   invalid_values => [['0'], [undef], ['menu']]},
) {
  my $attr = $test->{attr};
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->{element});
    is $el->$attr, $test->{default};
    for (@{$test->{valid_values}}) {
      $el->$attr ($_->[0]);
      is $el->$attr, $_->[1];
      is $el->get_attribute ($test->{content_attr} || $attr), $_->[0];
    }
    for (
      (map { [$_->[0].'  '] } @{$test->{valid_values}}),
      @{$test->{invalid_values}},
      ['#invalid'],
      ['#missing'],
    ) {
      $el->$attr ($_->[0]);
      is $el->$attr, defined $test->{invalid_default} ? $test->{invalid_default} : $test->{default};
      is $el->get_attribute ($test->{content_attr} || $attr), defined $_->[0] ? $_->[0] : undef;
    }
    done $c;
  } n => 3 + @{$test->{valid_values}}*2 +
      (@{$test->{valid_values}} + @{$test->{invalid_values}} + 1)*2,
      name => ['reflect enumerated attr', $test->{element}, $test->{attr}];
}

for my $test (
  {element => 'link',
   attr => 'as',
   default => '',
   valid_values => [
     ['' => ''],
     [image => 'image'],
     ['script' => 'script'],
   ],
   invalid_values => [['IMAGE'], ['fetch'], ['as']]},
) {
  my $attr = $test->{attr};
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->{element});
    is $el->$attr, $test->{default};
    for (@{$test->{valid_values}}) {
      $el->$attr ($_->[0]);
      is $el->$attr, $_->[1];
      is $el->get_attribute ($test->{content_attr} || $attr), $_->[0];
    }
    for (
      (map { [$_->[0].'  '] } @{$test->{valid_values}}),
      @{$test->{invalid_values}},
      ['#invalid'],
      ['#missing'],
    ) {
      $el->$attr ($_->[0]);
      is $el->$attr, defined $test->{invalid_default} ? $test->{invalid_default} : $test->{default};
      is $el->get_attribute ($test->{content_attr} || $attr), defined $_->[0] ? $_->[0] : undef;
    }
    done $c;
  } n => 3 + @{$test->{valid_values}}*2 +
      (@{$test->{valid_values}} + @{$test->{invalid_values}} + 1)*2,
      name => ['reflect IDL enumerated attr', $test->{element}, $test->{attr}];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'menu');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'menu');
  $el1->append_child ($el2);
  is $el2->type, 'toolbar';
  $el1->type ('popup');
  is $el2->type, 'toolbar';
  $el1->type ('context');
  is $el2->type, 'context';
  $el1->set_attribute (type => 'hoge');
  is $el2->type, 'toolbar';
  $el1->set_attribute (type => 'Toolbar');
  is $el2->type, 'toolbar';
  $el2->set_attribute (type => '');
  is $el2->type, 'toolbar';
  $el2->set_attribute (type => 'ConText');
  is $el2->type, 'context';
  done $c;
} n => 7, name => 'menu.type parent is menu'; 

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'menu');
  my $el2 = $doc->create_element_ns (undef, 'menu');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'menu');
  $el1->append_child ($el2);
  $el2->append_child ($el3);
  is $el3->type, 'toolbar';
  $el1->type ('context');
  is $el3->type, 'toolbar';
  $el1->set_attribute (type => 'hoge');
  is $el3->type, 'toolbar';
  $el1->set_attribute (type => 'Toolbar');
  is $el3->type, 'toolbar';
  $el2->set_attribute (type => '');
  is $el3->type, 'toolbar';
  $el2->set_attribute (type => 'context');
  is $el3->type, 'toolbar';
  $el3->set_attribute (type => 'context');
  is $el3->type, 'context';
  done $c;
} n => 7, name => 'menu.type parent is not menu'; 

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'menu');
  $doc->append_child ($el);
  is $el->type, 'toolbar';
  $el->type ('hoge');
  is $el->get_attribute ('type'), 'hoge';
  is $el->type, 'toolbar';
  $el->type ('Context');
  is $el->get_attribute ('type'), 'Context';
  is $el->type, 'context';
  done $c;
} n => 5, name => 'menu.type parent is document';

for my $test (
  {element => 'a', attr => 'rel', method => 'rel_list'},
  {element => 'area', attr => 'rel', method => 'rel_list'},
  {element => 'link', attr => 'rel', method => 'rel_list'},
  {element => 'em', attr => 'dropzone'},
  {element => 'em', attr => 'itemprop'},
  {element => 'em', attr => 'itemref'},
  {element => 'em', attr => 'itemtype'},
  {element => 'link', attr => 'sizes'},
  {element => 'iframe', attr => 'sandbox'},
  {element => 'output', attr => 'for', method => 'html_for'},
) {
  my $el_name = $test->{element};
  my $method = $test->{method} || $test->{attr};
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $el_name);
    my $tokens = $el->$method;

    isa_ok $tokens, 'Web::DOM::TokenList';
    is scalar @$tokens, 0;

    push @$tokens, 'aaa';
    is $el->get_attribute ($test->{attr}), 'aaa';

    $el->set_attribute ($test->{attr} => 'bb  ccc  ');
    is ''.$tokens, 'bb  ccc  ';
    is $el->get_attribute ($test->{attr}), 'bb  ccc  ';
    
    done $c;
  } n => 5, name => ['reflect DOMTokenList', $el_name, $test->{attr}];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $el_name);
    $el->$method->remove ('foo');
    ok not $el->has_attribute ($test->{attr});
    ok ! $el->$method->add;
    ok not $el->has_attribute ($test->{attr});
    ok ! $el->$method->add ('bar');
    is $el->get_attribute ($test->{attr}), 'bar';
    $el->$method->remove ('bar');
    is $el->get_attribute ($test->{attr}), '';
    is !! $el->$method->toggle ('baR'), !0;
    is $el->get_attribute ($test->{attr}), 'baR';
    done $c;
  } n => 8, name => ['reflect DOMTokenList attribute existence', $el_name];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $el_name);
    $el->$method ('');
    ok not $el->has_attribute_ns (undef, $test->{attr});

    $el->$method ("foo bar\x09\x0C");
    is $el->get_attribute ($test->{attr}), 'foo bar';

    $el->$method ("\x09\x0C");
    is $el->get_attribute ($test->{attr}), '';

    done $c;
  } n => 3, name => ['reflect DOMSettableTokenList',
                     $el_name, $test->{attr}];
}

for my $test (
  {element => 'dfn', attr => 'contextmenu', target_element => 'menu'},
  {element => 'button', attr => 'menu', target_element => 'menu'},
) {
  my $attr = $test->{attr};
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->{element});
    is $el->$attr, undef;

    my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->{target_element});
    $el2->set_attribute (id => 'abc');
    $doc->append_child ($el2);
    my $el5 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
    $el5->set_attribute (id => 'abc');
    $el2->append_child ($el5);
    my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->{target_element});
    $el3->set_attribute (id => 'abc');
    $el2->append_child ($el3);

    $el->$attr ($el2);
    is $el->$attr, $el2;
    is $el->get_attribute ($attr), 'abc';
    
    $el->$attr ($el3);
    is $el->$attr, undef;
    is $el->get_attribute ($attr), '';

    $el->remove_attribute ($attr);
    my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->{target_element});
    $el4->set_attribute (id => 'abc');
    $el->$attr ($el4);
    is $el->$attr, undef;
    is $el->get_attribute ($attr), '';

    $el->remove_attribute ($attr);
    $el4->append_child ($el);
    $el->$attr ($el4);
    is $el->$attr, undef;
    is $el->get_attribute ($attr), '';

    $el->remove_attribute ($attr);
    $el2->id ('');
    $el->$attr ($el2);
    is $el->$attr, undef;
    is $el->get_attribute ($attr), '';

    $el->set_attribute ($attr => $el5->id);
    is $el->$attr, undef;

    $el->remove_attribute ($attr);
    $el->$attr ($el3);
    is $el->$attr, undef;
    is $el->get_attribute ($attr), '';

    $el->set_attribute ($attr => 'fuga');
    is $el->$attr, undef;

    done $c;
  } n => 15, name => ['reflect HTMLElement', $test->{element}, $attr];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $test->{element});
    $el->set_attribute ($attr => 'aa');
    my $e = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
    dies_here_ok {
      $el->$attr ($e);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->name, 'TypeError';
    is $@->message, 'The argument is not a Web::DOM::HTMLMenuElement';
    is $el->get_attribute ($attr), 'aa';
    done $c;
  } n => 5, name => ['reflect HTMLElement', $test->{element},
                     $attr, 'bad new value'];
}

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
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'xmp');
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
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b');
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
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b');
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
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $el0 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'c');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b');
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
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $el0 = $doc->create_element_ns (undef, 'c');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b');
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
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'small');
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
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'img');
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
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
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
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
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
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'strike');
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
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
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
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fieldset');
  is $el->type, 'fieldset';
  done $c;
} n => 1, name => 'fieldset type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'select');
  is $el->type, 'select-one';
  done $c;
} n => 1, name => 'select-one type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'select');
  $el->multiple (1);
  is $el->type, 'select-multiple';
  done $c;
} n => 1, name => 'select-multiple type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'textarea');
  is $el->type, 'textarea';
  done $c;
} n => 1, name => 'textarea type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'keygen');
  is $el->type, 'keygen';
  done $c;
} n => 1, name => 'keygen type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'output');
  is $el->type, 'output';
  done $c;
} n => 1, name => 'output type';

for my $name (qw(caption thead)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
    is $table->$name, undef;

    my $cap1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $name);
    $table->$name ($cap1);
    is $table->$name, $cap1;
    is $cap1->parent_node, $table;

    my $cap2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $name);
    $table->$name ($cap2);
    is $table->$name, $cap2;
    is $cap2->parent_node, $table;
    is $cap1->parent_node, undef;

    $table->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo'));
    $table->insert_before ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo'), $cap2);
    $table->$name ($cap2);
    is $table->first_child, $cap2;
    $table->append_child ($cap1);
    $table->append_child ($cap2);

    is $table->$name, $cap1;
    my $cap3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $name);
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
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
    $table->$name (undef);
    is $table->first_child, undef;
    done $c;
  } n => 1, name => ['table', $name, 'undef'];

  my $create_name = "create_$name";
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
    my $el = $table->$create_name;
    $table->$name (undef);
    is $table->first_child, undef;
    is $el->parent_node, undef;
    done $c;
  } n => 2, name => ['table', $name, 'undef'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
    dies_here_ok {
      $table->$name ($doc->create_element_ns (undef, $name));
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->name, 'TypeError';
    is $@->message, "The new value is not a |$name| element";
    is $table->first_child, undef;
    done $c;
  } n => 5, name => ['table', $name, 'not expected element'];

  my $pfx = $name eq 'caption' ? '' : '<tr><td>';
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->manakai_is_html (1);
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
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
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
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
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
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
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
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
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
    $table->inner_html ('<tr><th><td>hoge<tbody>');
    $table->$delete_name;
    is $table->child_nodes->length, 2;
    done $c;
  } n => 1, name => ['table', $delete_name, 'not found'];
}

for my $name (qw(tfoot)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
    is $table->$name, undef;

    my $cap1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $name);
    $table->$name ($cap1);
    is $table->$name, $cap1;
    is $cap1->parent_node, $table;

    my $cap2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $name);
    $table->$name ($cap2);
    is $table->$name, $cap2;
    is $cap2->parent_node, $table;
    is $cap1->parent_node, undef;

    $table->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo'));
    $table->insert_before ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo'), $cap2);
    $table->$name ($cap2);
    is $table->last_child, $cap2;
    $table->append_child ($cap1);
    $table->append_child ($cap2);

    is $table->$name, $cap1;
    my $cap3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $name);
    $table->$name ($cap3);
    is $table->$name, $cap2;
    is $cap1->parent_node, undef;
    is $cap2->parent_node, $table;
    is $cap3->parent_node, $table;
    is $table->last_child, $cap3;

    done $c;
  } n => 13, name => ['table', $name];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
    $table->$name (undef);
    is $table->first_child, undef;
    done $c;
  } n => 1, name => ['table', $name, 'undef'];

  my $create_name = "create_$name";
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
    my $el = $table->$create_name;
    $table->$name (undef);
    is $table->first_child, undef;
    is $el->parent_node, undef;
    done $c;
  } n => 2, name => ['table', $name, 'undef'];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
    dies_here_ok {
      $table->$name ($doc->create_element_ns (undef, $name));
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->name, 'TypeError';
    is $@->message, "The new value is not a |$name| element";
    is $table->first_child, undef;
    done $c;
  } n => 5, name => ['table', $name, 'not expected element'];

  my $pfx = $name eq 'caption' ? '' : '<tr><td>';
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->manakai_is_html (1);
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
    $table->inner_html ('<tr><th><td>hoge<tbody>');
    my $cap = $table->$create_name;
    is $table->child_nodes->length, 3;
    is $table->last_child, $cap;
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
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
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
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
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
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
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
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
    $table->inner_html ('<tr><th><td>hoge<tbody>');
    $table->$delete_name;
    is $table->child_nodes->length, 2;
    done $c;
  } n => 1, name => ['table', $delete_name, 'not found'];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
  $table->inner_html ('<colgroup/><caption/><caption/><!----> <col/><tbody/>');
  my $thead = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'thead');
  $table->thead ($thead);
  is $table->child_nodes->[5], $thead;
  done $c;
} n => 1, name => 'thead insertion point';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
  $table->inner_html ('<colgroup/><caption/><caption/><!----> <col/><tbody/>');
  my $thead = $table->create_thead;
  is $table->child_nodes->[5], $thead;
  done $c;
} n => 1, name => 'create_thead insertion point';

for my $name (qw(tbody tfoot)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
    $table->inner_html ('<colgroup/><caption/><caption/><!----> <col/><tbody/>');
    my $tbody = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $name);
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
  my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
  $table->inner_html ('<colgroup/><caption/><caption/><thead/><!----> <col/><tbody/>');
  my $tfoot = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'tfoot');
  $table->tfoot ($tfoot);
  is $table->child_nodes->[8], $tfoot;
  done $c;
} n => 1, name => 'tfoot insertion point';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
  $table->inner_html ('<colgroup/><caption/><thead/><caption/><!----> <col/><tbody/>');
  my $tfoot = $table->create_tfoot;
  is $table->child_nodes->[8], $tfoot;
  done $c;
} n => 1, name => 'create_tfoot insertion point';

for my $name (qw(thead tbody)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
    $table->inner_html ('<colgroup/><caption/><caption/><!----> <col/><tbody/>');
    my $tbody = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $name);
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
  my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
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
  my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
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
  my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
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
  my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
  $table->inner_html (q{<tbody/><tfoot><tbody/></tfoot><tbody/><tbody/><caption/><tbody xmlns=""/> <!----><tbody/>});
  my $col1 = $table->tbodies;
  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 4;
  is $col1->[0], $table->first_child;
  is $col1->[1], $table->child_nodes->[2];
  is $col1->[2], $table->child_nodes->[3];
  is $col1->[3], $table->child_nodes->[-1];
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'tbody');
  $table->insert_before ($el1, $table->first_child);
  is $col1->length, 5;
  is $col1->[0], $el1;
  is $table->tbodies, $col1;
  isnt $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table')->tbodies, $col1;
  done $c;
} n => 10, name => 'tbodies';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
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
  my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
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

  my $tr4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'tr');
  $table->append_child ($tr4);
  my $tr5 = $table->insert_row (-1);
  is $tr5->previous_sibling, $tr4;

  my $tfoot = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'tfoot');
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
  my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
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
  my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
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
  my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
  $table->insert_row->set_attribute (id => 1);
  $table->insert_row->set_attribute (id => 2);
  is $table->outer_html, q{<table xmlns="http://www.w3.org/1999/xhtml"><tbody><tr id="1"></tr><tr id="2"></tr></tbody></table>};
  done $c;
} n => 1, name => 'insert_row default';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
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
  my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
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

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('table');
  $el->delete_row (-1);
  is $el->first_child, undef;
  done $c;
} n => 1, name => '<table>.delete_row (-1) where <table> has no <tr>';

for my $section (qw(tbody thead tfoot)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $section);
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
    is $col1->length, 2;
    is $col1->[0]->get_attribute ('n'), 5;
    is $col1->[1]->get_attribute ('n'), 11;
    is $table->rows, $col1;
    done $c;
  } n => 6, name => ['rows', $section];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $section);
    $table->inner_html (q{<!----> hoge <td/> <thead/>});
    my $tr = $table->insert_row (0);
    is $tr->namespace_uri, $table->namespace_uri;
    is $tr->local_name, 'tr';
    is $tr->parent_node, $table;
    is $table->last_child, $tr;
    is $tr->first_child, undef;

    my $tr2 = $table->insert_row (1);
    is $tr2->previous_sibling, $tr;
    is $tr2->local_name, 'tr';

    my $tr4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'tr');
    $table->append_child ($tr4);
    my $tr5 = $table->insert_row (-1);
    is $tr5->previous_sibling, $tr4;

    my $tfoot = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'tfoot');
    $tfoot->inner_html (q{<tr/>});
    my $tr6 = $tfoot->first_child;

    $table->insert_before ($tfoot, $table->first_child);

    my $tr7 = $table->insert_row (3);
    is $table->last_child, $tr5;
    is $tr5->previous_sibling, $tr7;

    done $c;
  } n => 10, name => ['insert_row', $section];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $section);
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
  } n => 7*4+2, name => ['insert_row index size error', $section];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $section);
    $table->inner_html (q{<tbody><tr/></tbody><tr/>});
    
    $table->insert_row (0+'nan')->set_attribute (id => 1);
    $table->insert_row (0+'inf')->set_attribute (id => 2);
    $table->insert_row (1.41)->set_attribute (id => 3);
    $table->insert_row (2**32-1)->set_attribute (id => 4);
    
    is $table->outer_html, qq{<$section xmlns="http://www.w3.org/1999/xhtml"><tbody><tr></tr></tbody><tr id="2"></tr><tr id="3"></tr><tr id="1"></tr><tr></tr><tr id="4"></tr></$section>};
    done $c;
  } n => 1, name => ['insert_row index stupid', $section];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $section);
    $table->insert_row->set_attribute (id => 1);
    $table->insert_row->set_attribute (id => 2);
    is $table->outer_html, qq{<$section xmlns="http://www.w3.org/1999/xhtml"><tr id="1"></tr><tr id="2"></tr></$section>};
    done $c;
  } n => 1, name => ['insert_row default', $section];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $section);
    $table->inner_html (q{<tbody><tr/><tr/></tbody><tr/><tr/><tr/>});
    $table->delete_row (2);
    is $table->inner_html, q{<tbody xmlns="http://www.w3.org/1999/xhtml"><tr></tr><tr></tr></tbody><tr xmlns="http://www.w3.org/1999/xhtml"></tr><tr xmlns="http://www.w3.org/1999/xhtml"></tr>};
    $table->delete_row (1);
    is $table->inner_html, q{<tbody xmlns="http://www.w3.org/1999/xhtml"><tr></tr><tr></tr></tbody><tr xmlns="http://www.w3.org/1999/xhtml"></tr>};
    $table->delete_row (2**32);
    is $table->inner_html, q{<tbody xmlns="http://www.w3.org/1999/xhtml"><tr></tr><tr></tr></tbody>};
    done $c;
  } n => 3, name => ['delete_row', $section];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $section);
    $table->inner_html (q{<tbody><tr/><tr/></tbody><tr/>});
    for (2**32-2, -50.12, 100.21, 3, -2, -1, 1) {
      dies_here_ok {
        $table->delete_row ($_);
      };
      isa_ok $@, 'Web::DOM::Exception';
      is $@->name, 'IndexSizeError';
      is $@->message, 'The specified row index is invalid';
    }
    is $table->inner_html, q{<tbody xmlns="http://www.w3.org/1999/xhtml"><tr></tr><tr></tr></tbody><tr xmlns="http://www.w3.org/1999/xhtml"></tr>};
    done $c;
  } n => 4*7 + 1, name => ['delete_row error', $section];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');

  $table->inner_html (q{<caption><tr n="1"/></caption><thead
><tr n="2"/><tr n="3"/>
<hoge/></thead><tfoot><tr n="4"/></tfoot>
<tbody/><tr n="5"/>
<tbody><tr n="6"/><tr n="7"/><tr n="8"><tr n="9"/></tr
><thead><tr n="10"/></thead></tbody>
<tr n="11"/><foo><tr n="12"/></foo><tfoot><tr n="12"/></tfoot>});
  my $trs = $table->get_elements_by_tag_name ('tr');
  for (
    [0 => -1, -1],
    [1 => 0, 0],
    [2 => 1, 1],
    [3 => 7, 0],
    [4 => 2, 2],
    [5 => 3, 0],
    [6 => 4, 1],
    [7 => 5, 2],
    [8 => -1, -1],
    [9 => -1, 0],
    [10 => 6, 6],
    [11 => -1, -1],
    [12 => 8, 0],
  ) {
    is $trs->[$_->[0]]->row_index, $_->[1];
    is $trs->[$_->[0]]->section_row_index, $_->[2];
  }
  done $c;
} n => 2*13, name => 'row_index section_row_index';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'tr');
  is $el->row_index, -1;
  is $el->section_row_index, -1;
  $doc->append_child ($el);
  is $el->row_index, -1;
  is $el->section_row_index, -1;
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'div');
  $el2->append_child ($el);
  is $el->row_index, -1;
  is $el->section_row_index, -1;
  for my $section (qw(thead tbody tfoot)) {
    my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $section);
    $el3->append_child ($el);
    is $el->row_index, -1;
    is $el->section_row_index, 0;
  }
  done $c;
} n => 12, name => 'row_index section_row_index no parent table';

for my $section (qw(tr)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $section);
    my $col1 = $table->cells;
    isa_ok $col1, 'Web::DOM::HTMLCollection';
    is $col1->length, 0;

    $table->inner_html (q{<caption><td n="1"/></caption><thead
><th n="2"/><td n="3"/>
<hoge/></thead><tfoot><td n="4"/></tfoot>
<tbody/><td n="5"/><tr/>
<tbody><th n="6"/><td n="7"/><th n="8"><td n="9"/></th
><thead><th n="10"/></thead></tbody>
<td n="11"/><foo><th n="12"/></foo><tfoot><td n="12"/></tfoot>});
    is $col1->length, 2;
    is $col1->[0]->get_attribute ('n'), 5;
    is $col1->[1]->get_attribute ('n'), 11;
    is $table->cells, $col1;
    done $c;
  } n => 6, name => ['cells', $section];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $section);
    $table->inner_html (q{<!----> hoge <tr/> <thead/>});
    my $tr = $table->insert_cell (0);
    is $tr->namespace_uri, $table->namespace_uri;
    is $tr->local_name, 'td';
    is $tr->parent_node, $table;
    is $table->last_child, $tr;
    is $tr->first_child, undef;

    my $tr2 = $table->insert_cell (1);
    is $tr2->previous_sibling, $tr;
    is $tr2->local_name, 'td';

    my $tr4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'th');
    $table->append_child ($tr4);
    my $tr5 = $table->insert_cell (-1);
    is $tr5->previous_sibling, $tr4;

    my $tfoot = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'tfoot');
    $tfoot->inner_html (q{<td/>});
    my $tr6 = $tfoot->first_child;

    $table->insert_before ($tfoot, $table->first_child);

    my $tr7 = $table->insert_cell (3);
    is $table->last_child, $tr5;
    is $tr5->previous_sibling, $tr7;

    done $c;
  } n => 10, name => ['insert_cell', $section];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $section);
    $table->inner_html (q{<tbody><th/></tbody><th/>});
    for my $index (-6, -51, 3, 12, 21, 2**32+3, 2**31) {
      dies_here_ok {
        $table->insert_cell ($index);
      };
      isa_ok $@, 'Web::DOM::Exception';
      is $@->name, 'IndexSizeError';
      is $@->message, 'The specified cell index is invalid';
    }
    is $table->child_nodes->length, 2;
    is $table->first_child->child_nodes->length, 1;
    done $c;
  } n => 7*4+2, name => ['insert_cell index size error', $section];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $section);
    $table->inner_html (q{<tbody><td/></tbody><td/>});
    
    $table->insert_cell (0+'nan')->set_attribute (id => 1);
    $table->insert_cell (0+'inf')->set_attribute (id => 2);
    $table->insert_cell (1.41)->set_attribute (id => 3);
    $table->insert_cell (2**32-1)->set_attribute (id => 4);
    
    is $table->outer_html, qq{<$section xmlns="http://www.w3.org/1999/xhtml"><tbody><td></td></tbody><td id="2"></td><td id="3"></td><td id="1"></td><td></td><td id="4"></td></$section>};
    done $c;
  } n => 1, name => ['insert_cell index stupid', $section];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $section);
    $table->insert_cell->set_attribute (id => 1);
    $table->insert_cell->set_attribute (id => 2);
    is $table->outer_html, qq{<$section xmlns="http://www.w3.org/1999/xhtml"><td id="1"></td><td id="2"></td></$section>};
    done $c;
  } n => 1, name => ['insert_cell default', $section];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $section);
    $table->inner_html (q{<tbody><td/><td/></tbody><td/><th/><td/>});
    $table->delete_cell (2);
    is $table->inner_html, q{<tbody xmlns="http://www.w3.org/1999/xhtml"><td></td><td></td></tbody><td xmlns="http://www.w3.org/1999/xhtml"></td><th xmlns="http://www.w3.org/1999/xhtml"></th>};
    $table->delete_cell (1);
    is $table->inner_html, q{<tbody xmlns="http://www.w3.org/1999/xhtml"><td></td><td></td></tbody><td xmlns="http://www.w3.org/1999/xhtml"></td>};
    $table->delete_cell (2**32);
    is $table->inner_html, q{<tbody xmlns="http://www.w3.org/1999/xhtml"><td></td><td></td></tbody>};
    done $c;
  } n => 3, name => ['delete_cell', $section];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $table = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $section);
    $table->inner_html (q{<tbody><td/><td/></tbody><td/>});
    for (2**32-2, -50.12, 100.21, 3, -2, -1, 1) {
      dies_here_ok {
        $table->delete_cell ($_);
      };
      isa_ok $@, 'Web::DOM::Exception';
      is $@->name, 'IndexSizeError';
      is $@->message, 'The specified cell index is invalid';
    }
    is $table->inner_html, q{<tbody xmlns="http://www.w3.org/1999/xhtml"><td></td><td></td></tbody><td xmlns="http://www.w3.org/1999/xhtml"></td>};
    done $c;
  } n => 4*7 + 1, name => ['delete_cell error', $section];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $td = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'td');
  is $td->cell_index, -1;
  my $th = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'th');
  is $th->cell_index, -1;
  $doc->append_child ($td);
  is $td->cell_index, -1;
  $doc->replace_child ($th, $td);
  is $th->cell_index, -1;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
  $el->append_child ($td);
  $el->append_child ($th);
  is $td->cell_index, -1;
  is $th->cell_index, -1;
  done $c;
} n => 6, name => 'cell_index no parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $tr = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'tr');
  my $td = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'td');
  $tr->append_child ($td);
  is $td->cell_index, 0;
  my $th = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'th');
  $tr->append_child ($th);
  is $th->cell_index, 1;
  done $c;
} n => 2, name => 'cell_index has tr parent';

for my $control_name (qw(input button keygen meter output progress select
                         textarea)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->inner_html (q{<hoge/>});
    my $label = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'label');
    $label->html_for ('hofe');

    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $control_name);
    $doc->document_element->append_child ($el);
    $el->id ('hofe');
    
    is $label->control, $el;
    done $c;
  } n => 1, name => ['control', $control_name];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->inner_html (q{<hoge/>});
    my $label = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'label');
    $label->html_for ('hofe');

    my $el0 = $doc->create_element_ns (undef, $control_name);
    $el0->set_attribute (id => 'hofe');
    $doc->document_element->append_child ($el0);
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $control_name);
    $doc->document_element->append_child ($el);
    $el->id ('hofe');
    
    is $label->control, undef;
    done $c;
  } n => 1, name => ['control not first', $control_name];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $label = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'label');

    my $el0 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', uc $control_name);
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $control_name);
    $label->append_child ($el0);
    $el0->append_child ($el);
    
    is $label->control, $el;
    done $c;
  } n => 1, name => ['control descendant', $control_name];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $label = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'label');

    my $el0 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', uc $control_name);
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $control_name);
    my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $control_name);
    $label->append_child ($el0);
    $el0->append_child ($el);
    $el0->append_child ($el2);
    
    is $label->control, $el;
    done $c;
  } n => 1, name => ['control descendant', $control_name];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $label = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'label');
    $label->html_for ('aa');

    my $el0 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', uc $control_name);
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $control_name);
    my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $control_name);
    $label->append_child ($el0);
    $el0->append_child ($el);
    $el0->append_child ($el2);
    $el2->id ('aa');
    $doc->append_child ($label);
    
    is $label->control, $el2;
    done $c;
  } n => 1, name => ['control id descendant', $control_name];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $label = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'label');
    $label->html_for ('aa');

    my $el0 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', uc $control_name);
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $control_name);
    my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $control_name);
    $label->append_child ($el0);
    $el0->append_child ($el);
    $el0->append_child ($el2);
    $el2->id ('aa');
    
    is $label->control, undef;
    done $c;
  } n => 1, name => ['control id-not-in-doc descendant', $control_name];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->inner_html (q{<hoge/>});
  my $label = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'label');
  $label->html_for ('hofe');

  my $el0 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'input');
  $el0->set_attribute (id => 'hofe');
  $el0->type ('HiDDEn');
  $doc->document_element->append_child ($el0);
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'input');
  $doc->document_element->append_child ($el);
  $el->id ('hofe');
  
  is $label->control, undef;
  done $c;
} n => 1, name => ['control input[type=hidden]'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->inner_html (q{<hoge/>});
  my $label = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'label');

  my $el0 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'input');
  $el0->type ('HiDDEn');
  $label->append_child ($el0);
  
  is $label->control, undef;
  done $c;
} n => 1, name => ['control descendant input[type=hidden]'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->inner_html (q{<hoge/>});
  my $label = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'label');

  my $el0 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'input');
  $el0->type ('HiDDEn');
  $label->append_child ($el0);
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'select');
  $label->append_child ($el);
  
  is $label->control, $el;
  done $c;
} n => 1, name => ['control descendant input[type=hidden]'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->inner_html (q{<hoge/>});
  my $label = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'label');

  my $el0 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'input');
  $el0->type ('hidden');
  $label->append_child ($el0);
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'input');
  $label->append_child ($el);
  
  is $label->control, $el;
  done $c;
} n => 1, name => ['control descendant input[type=hidden]'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $input = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'input');
  is $input->list, undef;
  $input->set_attribute (list => 'hoge');
  is $input->list, undef;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'datalist');
  $el->id ('hoge');
  $input->append_child ($el);
  is $input->list, undef;
  $doc->append_child ($el);
  is $input->list, $el;
  my $el2 = $doc->create_element_ns (undef, 'datalist');
  $doc->replace_child ($el2, $el);
  is $input->list, undef;
  done $c;
} n => 5, name => 'input.list';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $root = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'datalist');
  my $col1 = $root->options;
  isa_ok $col1, 'Web::DOM::HTMLCollection';
  is $col1->length, 0;
  is $root->options, $col1;

  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'option');
  $root->append_child ($el1);

  is $root->options->length, 1;
  is $col1->length, 1;
  is $col1->[0], $el1;

  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'option');
  $el1->append_child ($el2);

  is $col1->length, 2;
  is $col1->[1], $el2;

  done $c;
} n => 8, name => 'datalist.options';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'option');
  is $el->text, '';
  is $el->label, '';
  is $el->value, '';
  
  $el->text ("hoge  fuga \x0D\x0C aa\x09\x0A");
  is $el->text, "hoge fuga aa";
  is $el->label, "hoge fuga aa";
  is $el->value, "hoge fuga aa";
  is $el->text_content, "hoge  fuga \x0D\x0C aa\x09\x0A";

  $el->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo'))->text_content ('0');
  $el->manakai_append_text ("\x09");

  is $el->text, "hoge fuga aa 0";
  is $el->label, "hoge fuga aa 0";
  is $el->value, "hoge fuga aa 0";
  is $el->text_content, "hoge  fuga \x0D\x0C aa\x09\x0A0\x09";

  $el->label (0);
  is $el->text, "hoge fuga aa 0";
  is $el->label, "0";
  is $el->value, "hoge fuga aa 0";
  is $el->text_content, "hoge  fuga \x0D\x0C aa\x09\x0A0\x09";

  $el->value (100);
  is $el->text, "hoge fuga aa 0";
  is $el->label, "0";
  is $el->value, "100";
  is $el->text_content, "hoge  fuga \x0D\x0C aa\x09\x0A0\x09";

  my $text = $el->last_child;
  $el->text ('');
  is $el->first_child, undef;
  is $text->parent_node, undef;
  is $el->text, "";
  is $el->label, "0";
  is $el->value, "100";
  is $el->text_content, "";
  is $el->get_attribute_ns (undef, 'label'), 0;
  is $el->get_attribute_ns (undef, 'value'), 100;

  done $c;
} n => 27, name => 'option text label value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $opt = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'option');
  $opt->set_attribute (label => '');
  $opt->text_content (13);
  is $opt->label, '';
  is $opt->text, '13';
  is $opt->value, '13';
  done $c;
} n => 3, name => 'option.label empty label attribute';

test {
  my $c = shift;

  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'option');
  $el->append_child ($doc->create_text_node ('hoge'));
  $el->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'script'))
     ->append_child ($doc->create_text_node ('abc'));
  $el->append_child ($doc->create_text_node ('fuga'));
  is $el->text, 'hogefuga';
  is $el->label, 'hogefuga';
  is $el->value, 'hogefuga';

  my $el2 = $el->append_child ($doc->create_element_ns (undef, 'script'));
  $el2->append_child ($doc->create_text_node ('xyz'));
  $el2->append_child ($doc->create_element_ns ('http://www.w3.org/2000/svg', 'script'))
      ->append_child ($doc->create_text_node ('xyza'));
  is $el->text, 'hogefugaxyz';
  is $el->label, 'hogefugaxyz';
  is $el->value, 'hogefugaxyz';
  
  done $c;
} n => 6, name => 'option text label value script';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'dialog');
  is $el->return_value, '';
  $el->return_value (my $value = {});
  is $el->return_value, ''.$value;
  $el->return_value (undef);
  is $el->return_value, '';
  done $c;
} n => 3, name => 'dialog.return_value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'xmp');
  my $ds = $el->dataset;
  isa_ok $ds, 'Web::DOM::StringMap';
  is $el->dataset, $ds;

  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'xmp');
  isnt  $el2->dataset, $ds;

  done $c;
} n => 3, name => 'dataset';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://foo');
  my $base = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'base');
  is $base->href, 'http://foo/';
  done $c;
} n => 1, name => 'base.href no href';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://foo');
  my $base = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'base');
  $base->set_attribute (href => 'http://ABC');
  is $base->href, 'http://abc/';
  done $c;
} n => 1, name => 'base.href href';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://foo');
  my $base = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'base');
  $base->set_attribute (href => ' ba/./r  ');
  is $base->href, 'http://foo/ba/r';
  done $c;
} n => 1, name => 'base.href href';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://foo');
  my $base = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'base');
  $base->set_attribute (href => ' http://ho:fe/ ');
  is $base->href, '';
  done $c;
} n => 1, name => 'base.href href bad url';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'base');
  $el->href ('hoge');
  is $el->get_attribute_ns (undef, 'href'), 'hoge';
  $el->href ('http://foo');
  is $el->get_attribute_ns (undef, 'href'), 'http://foo';
  $el->href (undef);
  is $el->get_attribute_ns (undef, 'href'), '';
  done $c;
} n => 3, name => 'base.href setter';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  my $mr = Web::CSS::Parser->get_parser_of_document ($doc)->media_resolver;
  $mr->{prop}->{display} = 1;
  $mr->{prop_value}->{display}->{block} = 1;

  my $style = $el->style;
  isa_ok $style, 'Web::DOM::CSSStyleDeclaration';
  is $style->length, 0;
  is $style->display, '';

  $style->display ('block');
  is $style->display, 'block';
  is $el->get_attribute_ns (undef, 'style'), 'display: block;';

  is $el->style, $style;

  done $c;
} n => 6, name => 'style no attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  $el->set_attribute (style => 'display: inline; hoge: fuga');
  my $mr = Web::CSS::Parser->get_parser_of_document ($doc)->media_resolver;
  $mr->{prop}->{display} = 1;
  $mr->{prop_value}->{display}->{block} = 1;
  $mr->{prop_value}->{display}->{inline} = 1;

  my $style = $el->style;
  isa_ok $style, 'Web::DOM::CSSStyleDeclaration';
  is $style->length, 1;
  is $style->display, 'inline';
  $style->remove_property ('hoge');
  is $el->get_attribute_ns (undef, 'style'), 'display: inline; hoge: fuga';

  $style->display ('block');
  is $style->display, 'block';
  is $el->get_attribute_ns (undef, 'style'), 'display: block;';

  is $el->style, $style;

  done $c;
} n => 7, name => 'style has attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  $el->set_attribute (style => 'display: inline; hoge: fuga');
  my $mr = Web::CSS::Parser->get_parser_of_document ($doc)->media_resolver;
  $mr->{prop}->{display} = 1;
  $mr->{prop_value}->{display}->{block} = 1;
  $mr->{prop_value}->{display}->{inline} = 1;

  my $style = $el->style;
  is $style->length, 1;

  $el->remove_attribute ('style');

  is $style->length, 0;

  $el->set_attribute (style => 'display: inline');

  is $style->length, 1;
  is $style->display, 'inline';

  done $c;
} n => 4, name => 'style attr mutation';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  my $mr = Web::CSS::Parser->get_parser_of_document ($doc)->media_resolver;
  $mr->{prop}->{display} = 1;
  $mr->{prop_value}->{display}->{block} = 1;
  $mr->{prop_value}->{display}->{inline} = 1;

  $el->style ('display: block  ');

  is $el->get_attribute_ns (undef, 'style'), 'display: block;';

  done $c;
} n => 1, name => 'style setter';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'menuitem');
  is $el->label, '';
  $el->label ('abc');
  is $el->label, 'abc';
  $el->label ("   ");
  is $el->label, '   ';
  $el->label ("\x09\x20abc\x0A");
  is $el->label, "\x09\x20abc\x0A";
  $el->label ('');
  is $el->label, '';
  $el->label ('0');
  is $el->label, '0';
  done $c;
} n => 6, name => '<menuitem label>';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'menuitem');
  $el->inner_html (q{  });
  is $el->label, '';
  $el->label ('abc');
  is $el->label, 'abc';
  $el->label ("   ");
  is $el->label, '   ';
  $el->label ("\x09\x20abc\x0A");
  is $el->label, "\x09\x20abc\x0A";
  $el->label ('');
  is $el->label, '';
  $el->label ('0');
  is $el->label, '0';
  done $c;
} n => 6, name => '<menuitem label>';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'menuitem');
  $el->inner_html (qq{  <p>xy</p>\x09});
  is $el->label, '';
  $el->label ('abc');
  is $el->label, 'abc';
  $el->label ("   ");
  is $el->label, '   ';
  $el->label ("\x09\x20abc\x0A");
  is $el->label, "\x09\x20abc\x0A";
  $el->label ('');
  is $el->label, '';
  $el->label ('0');
  is $el->label, '0';
  done $c;
} n => 6, name => '<menuitem label>';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'menuitem');
  $el->inner_html (q{  a  b  c  });
  is $el->label, 'a b c';
  $el->label ('abc');
  is $el->label, 'abc';
  $el->label ("   ");
  is $el->label, '   ';
  $el->label ("\x09\x20abc\x0A");
  is $el->label, "\x09\x20abc\x0A";
  $el->label ('');
  is $el->label, '';
  $el->label ('0');
  is $el->label, '0';
  done $c;
} n => 6, name => '<menuitem label>';

run_tests;

=head1 LICENSE

Copyright 2013-2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
