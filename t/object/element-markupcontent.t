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
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');

  is $el->outer_html,
      q{<hoge xmlns="http://www.w3.org/1999/xhtml"></hoge>};

  $doc->manakai_is_html (1);

  is $el->outer_html, q{<hoge></hoge>};

  done $c;
} n => 2, name => 'outer_xml empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->inner_html ('<!-- foo --><p>abc<bar title="a" xml:lang="en"/><br/></p>');

  is $el->outer_html,
      q{<hoge xmlns="http://www.w3.org/1999/xhtml"><!-- foo --><p>abc<bar title="a" xml:lang="en"></bar><br></br></p></hoge>};

  $doc->manakai_is_html (1);

  is $el->outer_html,
      q{<hoge><!-- foo --><p>abc<bar title="a" xml:lang="en"></bar><br></p></hoge>};

  done $c;
} n => 2, name => 'outer_xml not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');

  $el->outer_html ('hoge <p> ');
  is $el->outer_html, q{<aa xmlns="http://www.w3.org/1999/xhtml"></aa>};

  done $c;
} n => 1, name => 'outer_xml setter no parent xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el->inner_html ('hoge');

  $el->outer_html ('hoge <p> ');
  is $el->outer_html, q{<aa>hoge</aa>};

  done $c;
} n => 1, name => 'outer_xml setter no parent html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el2);

  $el2->outer_html ('hoge <p/> ');
  is $el1->inner_html, q{hoge <p xmlns="http://www.w3.org/1999/xhtml"></p> };

  is $el2->parent_node, undef;
  is $el2->inner_html, 'hoge';

  done $c;
} n => 3, name => 'outer_xml setter parent element xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el2);

  $el2->outer_html ('hoge <p/> ');
  is $el1->inner_html, q{hoge <p> </p>};

  is $el2->parent_node, undef;
  is $el2->inner_html, 'hoge';

  done $c;
} n => 3, name => 'outer_xml setter parent element html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el2);

  $el2->outer_html ('hoge <p></p> </aa>');
  is $el1->inner_html, q{hoge <p></p> };

  is $el2->parent_node, undef;
  is $el2->inner_html, 'hoge';

  done $c;
} n => 3, name => 'outer_xml setter parent element html 2';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el2);

  dies_here_ok {
    $el2->outer_html ('hoge <p> ');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The given string is ill-formed as XML';
  is $el1->inner_html, q{<aa xmlns="http://www.w3.org/1999/xhtml">hoge</aa>};

  is $el2->parent_node, $el1;

  done $c;
} n => 6, name => 'outer_xml setter parent element xml parse error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el2);

  dies_here_ok {
    $el2->outer_html ('hoge <p/> </aa>');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The given string is ill-formed as XML';
  is $el1->inner_html, q{<aa xmlns="http://www.w3.org/1999/xhtml">hoge</aa>};

  is $el2->parent_node, $el1;

  done $c;
} n => 6, name => 'outer_xml setter parent element xml parse error 2';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el3);
  $el1->append_child ($el2);
  $el1->append_child ($el4);

  $el2->outer_html ('hoge <p></p> ');
  is $el1->inner_html, q{<aa></aa>hoge <p></p> <aa></aa>};

  done $c;
} n => 1, name => 'outer_xml setter parent element html siblings';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el3);
  $el1->append_child ($el2);
  $el1->append_child ($el4);

  $el2->outer_html ('hoge <p></p> ');
  is $el1->inner_html, q{<aa xmlns="http://www.w3.org/1999/xhtml"></aa>hoge <p xmlns="http://www.w3.org/1999/xhtml"></p> <aa xmlns="http://www.w3.org/1999/xhtml"></aa>};

  is $el3->parent_node, $el1;
  is $el4->parent_node, $el1;
  is $el2->parent_node, undef;

  done $c;
} n => 4, name => 'outer_xml setter parent element xml siblings';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el1->set_attribute_ns ('http://www.w3.org/2000/xmlns/', ['xmlns', 'abc'], 'http://ns1/');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el2->set_attribute_ns ('http://www.w3.org/2000/xmlns/', ['xmlns', 'abc'], 'http://ns2/');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el3);
  $el1->append_child ($el2);
  $el1->append_child ($el4);

  $el2->outer_html ('hoge <abc:p></abc:p> ');
  is $el1->inner_html, q{<aa></aa>hoge <abc:p></abc:p> <aa></aa>};
  is $el1->child_nodes->[2]->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el1->child_nodes->[2]->local_name, 'abc:p';

  done $c;
} n => 3, name => 'outer_xml setter namespace prefix html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el1->set_attribute_ns ('http://www.w3.org/2000/xmlns/', ['xmlns', 'abc'], 'http://ns1/');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el2->set_attribute_ns ('http://www.w3.org/2000/xmlns/', ['xmlns', 'abc'], 'http://ns2/');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el3);
  $el1->append_child ($el2);
  $el1->append_child ($el4);

  $el2->outer_html ('hoge <abc:p></abc:p> ');
  is $el1->inner_html, q{<aa xmlns="http://www.w3.org/1999/xhtml"></aa>hoge <abc:p xmlns:abc="http://ns1/"></abc:p> <aa xmlns="http://www.w3.org/1999/xhtml"></aa>};
  is $el1->child_nodes->[2]->namespace_uri, 'http://ns1/';
  is $el1->child_nodes->[2]->local_name, 'p';

  done $c;
} n => 3, name => 'outer_xml setter namespace prefix xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el1 = $doc->create_document_fragment;
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el3);
  $el1->append_child ($el2);
  $el1->append_child ($el4);

  $el2->outer_html ('hoge <p></p> <tr>x');
  is $el1->inner_html, q{<aa></aa>hoge <p></p> x<aa></aa>};

  done $c;
} n => 1, name => 'outer_xml setter parent df html siblings';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_document_fragment;
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el3);
  $el1->append_child ($el2);
  $el1->append_child ($el4);

  $el2->outer_html ('hoge <p></p> <tr/>x');
  is $el1->inner_html, q{<aa xmlns="http://www.w3.org/1999/xhtml"></aa>hoge <p xmlns="http://www.w3.org/1999/xhtml"></p> <tr xmlns="http://www.w3.org/1999/xhtml"></tr>x<aa xmlns="http://www.w3.org/1999/xhtml"></aa>};

  done $c;
} n => 1, name => 'outer_xml setter parent df xml siblings';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->inner_html ('<q>aaa</q>');
  $doc->append_child ($el);
  
  dies_here_ok {
    $el->outer_html ('<p>hoge</p>');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NoModificationAllowedError';
  is $@->message, 'Cannot set outer_html of the document element';

  is $el->inner_html, q{<q xmlns="http://www.w3.org/1999/xhtml">aaa</q>};
  is $el->parent_node, $doc;

  done $c;
} n => 6, name => 'outer_xml stter parent document xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->inner_html ('<q>aaa</q>');
  $doc->append_child ($el);
  
  dies_here_ok {
    $el->outer_html ('<p>hoge</p>');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NoModificationAllowedError';
  is $@->message, 'Cannot set outer_html of the document element';

  is $el->inner_html, q{<q>aaa</q>};
  is $el->parent_node, $doc;

  done $c;
} n => 6, name => 'outer_xml stter parent document html';

for my $test (
  [1, 'beforebegin', '<p>hoge</p><br>',
   q{<b></b><p>hoge</p><br><c><e></e></c><d></d>}],
  [1, 'beFOreBegIn', '<p>hoge</p><br>',
   q{<b></b><p>hoge</p><br><c><e></e></c><d></d>}],
  [1, 'afterbegin', '<p>hoge</p><br>',
   q{<b></b><c><p>hoge</p><br><e></e></c><d></d>}],
  [1, 'befOREEND', '<p>hoge</p><br>',
   q{<b></b><c><e></e><p>hoge</p><br></c><d></d>}],
  [1, 'AFTErEnd', '<p>hoge</p><br>',
   q{<b></b><c><e></e></c><p>hoge</p><br><d></d>}],

  [0, 'beforebegin', '<p>hoge</p><br/>',
   q{<b></b><p>hoge</p><br></br><c><e></e></c><d></d>}],
  [0, 'beFOreBegIn', '<p>hoge</p><br/>',
   q{<b></b><p>hoge</p><br></br><c><e></e></c><d></d>}],
  [0, 'afterbegin', '<p>hoge</p><br/>',
   q{<b></b><c><p>hoge</p><br></br><e></e></c><d></d>}],
  [0, 'befOREEND', '<p>hoge</p><br/>',
   q{<b></b><c><e></e><p>hoge</p><br></br></c><d></d>}],
  [0, 'AFTErEnd', '<p>hoge</p><br/>',
   q{<b></b><c><e></e></c><p>hoge</p><br></br><d></d>}],
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->manakai_is_html ($test->[0]);
    my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
    my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b');
    my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'c');
    my $el4 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'd');
    my $el5 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'e');
    $el1->append_child ($el2);
    $el1->append_child ($el3);
    $el1->append_child ($el4);
    $el3->append_child ($el5);
    
    $el3->insert_adjacent_html ($test->[1], $test->[2]);
    if ($test->[0]) {
      is $el1->inner_html, $test->[3];
    } else {
      is $el1->outer_html, '<a xmlns="http://www.w3.org/1999/xhtml">'.$test->[3].'</a>';
    }

    done $c;
  } n => 1, name => ['insert_adjacent_html', $test->[0] ? 'html' : 'xml',
                     $test->[1], $test->[2]];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hogte');
  $doc->append_child ($el);

  dies_here_ok {
    $el->insert_adjacent_html ('beforebegin', '<p>aa</p>');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NoModificationAllowedError';
  is $@->message, 'Cannot insert before or after the root element';
  is $doc->child_nodes->length, 1;
  is $el->first_child, undef;
  done $c;
} n => 6, name => 'insert_adjacent_html before_begin parent document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hogte');
  $doc->append_child ($el);

  dies_here_ok {
    $el->insert_adjacent_html ('afterend', '<p>aa</p>');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NoModificationAllowedError';
  is $@->message, 'Cannot insert before or after the root element';
  is $doc->child_nodes->length, 1;
  is $el->first_child, undef;
  done $c;
} n => 6, name => 'insert_adjacent_html after_end parent document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hogte');

  dies_here_ok {
    $el->insert_adjacent_html ('beforebegin', '<p>aa</p>');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NoModificationAllowedError';
  is $@->message, 'Cannot insert before or after the root element';
  is $el->first_child, undef;
  done $c;
} n => 5, name => 'insert_adjacent_html before_begin parent none';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hogte');

  dies_here_ok {
    $el->insert_adjacent_html ('afterend', '<p>aa</p>');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NoModificationAllowedError';
  is $@->message, 'Cannot insert before or after the root element';
  is $el->first_child, undef;
  done $c;
} n => 5, name => 'insert_adjacent_html after_end parent none';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hogte');
  $el->inner_html ('<br/>');
  $doc->append_child ($el);

  $el->insert_adjacent_html ('afterbegin', '<p>aa</p>');
  is $doc->child_nodes->length, 1;
  is $el->inner_html, '<p xmlns="http://www.w3.org/1999/xhtml">aa</p><br xmlns="http://www.w3.org/1999/xhtml"></br>';
  done $c;
} n => 2, name => 'insert_adjacent_html after_begin parent document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hogte');
  $el->inner_html ('<br/>');
  $doc->append_child ($el);

  $el->insert_adjacent_html ('BeforEend', '<p>aa</p>');
  is $doc->child_nodes->length, 1;
  is $el->inner_html, '<br xmlns="http://www.w3.org/1999/xhtml"></br><p xmlns="http://www.w3.org/1999/xhtml">aa</p>';
  done $c;
} n => 2, name => 'insert_adjacent_html beforeend parent document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hogte');
  $el->inner_html ('<br/>');

  $el->insert_adjacent_html ('afterbegin', '<p>aa</p>');
  is $el->inner_html, '<p xmlns="http://www.w3.org/1999/xhtml">aa</p><br xmlns="http://www.w3.org/1999/xhtml"></br>';
  done $c;
} n => 1, name => 'insert_adjacent_html after_begin parent none';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hogte');
  $el->inner_html ('<br/>');

  $el->insert_adjacent_html ('BeforEend', '<p>aa</p>');
  is $el->inner_html, '<br xmlns="http://www.w3.org/1999/xhtml"></br><p xmlns="http://www.w3.org/1999/xhtml">aa</p>';
  done $c;
} n => 1, name => 'insert_adjacent_html beforeend parent none';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  $el->inner_html ('aa');
  dies_here_ok {
    $el->insert_adjacent_html ('after_end', 'hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'Unknown position is specified';
  is $el->inner_html, 'aa';
  done $c;
} n => 5, name => 'insert_adjacent_html unknown position';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'html');
  $el1->insert_adjacent_html ('beforeend', '<p>hoge');
  is $el1->inner_html, '<p>hoge</p>';
  done $c;
} n => 1, name => 'insert_adjacent_html html html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'html');
  $df->append_child ($el1);
  $el1->insert_adjacent_html ('afterend', '<p>hoge');
  is $df->inner_html, '<html></html><p>hoge</p>';
  done $c;
} n => 1, name => 'insert_adjacent_html html df';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
  $el1->insert_adjacent_html ('beforeend', '<p>hoge<tr><td>foo<th>');
  is $el1->inner_html, '<p>hoge</p><tbody><tr><td>foo</td><th></th></tr></tbody>';
  done $c;
} n => 1, name => 'insert_adjacent_html html table';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'p');
  $el1->append_child ($el2);
  $el2->insert_adjacent_html ('afterend', '<p>hoge<tr><td>foo<th>');
  is $el1->inner_html, '<p></p><p>hoge</p><tbody><tr><td>foo</td><th></th></tr></tbody>';
  done $c;
} n => 1, name => 'insert_adjacent_html html table';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el1->append_child ($el2);
  $el1->set_attribute_ns ('http://www.w3.org/2000/xmlns/', ['xmlns', 'b'],
                          'http://ns1/');
  $el2->set_attribute_ns ('http://www.w3.org/2000/xmlns/', ['xmlns', 'b'],
                          'http://ns2/');

  $el2->insert_adjacent_html ('AfterEnd', '<b:ab/>');
  
  is $el1->inner_html, q{<hoge xmlns="http://www.w3.org/1999/xhtml" xmlns:b="http://ns2/"></hoge><b:ab xmlns:b="http://ns1/"></b:ab>};

  done $c;
} n => 1, name => 'isnert_adjacent_html xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el1->append_child ($el2);
  $el1->set_attribute_ns ('http://www.w3.org/2000/xmlns/', ['xmlns', 'b'],
                          'http://ns1/');
  $el2->set_attribute_ns ('http://www.w3.org/2000/xmlns/', ['xmlns', 'b'],
                          'http://ns2/');

  $el2->insert_adjacent_html ('BEFOREEnd', '<b:ab/>');
  
  is $el1->inner_html, q{<hoge xmlns="http://www.w3.org/1999/xhtml" xmlns:b="http://ns2/"><b:ab></b:ab></hoge>};

  done $c;
} n => 1, name => 'isnert_adjacent_html xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'table');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el1->append_child ($el2);

  dies_here_ok {
    $el2->insert_adjacent_html ('AfterEnd', '<ab>');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The given string is ill-formed as XML';
  
  is $el1->inner_html, q{<hoge xmlns="http://www.w3.org/1999/xhtml"></hoge>};

  done $c;
} n => 5, name => 'isnert_adjacent_html xml ill-formed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');

  $el->insert_adjacent_html ('afterbegin', '<p>abc</p>');
  is $el->child_nodes->length, 1;
  is $el->content->child_nodes->length, 0;

  $el->insert_adjacent_html ('beforeend', '<p>abc</p>');
  is $el->child_nodes->length, 2;
  is $el->content->child_nodes->length, 0;

  done $c;
} n => 4, name => 'insert_adjacent_html <template> XML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'template');

  $el->insert_adjacent_html ('afterbegin', '<p>abc</p>');
  is $el->child_nodes->length, 1;
  is $el->content->child_nodes->length, 0;

  $el->insert_adjacent_html ('beforeend', '<p>abc</p>');
  is $el->child_nodes->length, 2;
  is $el->content->child_nodes->length, 0;

  done $c;
} n => 4, name => 'insert_adjacent_html <template> HTML';

run_tests;

=head1 LICENSE

Copyright 2012-2014 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
