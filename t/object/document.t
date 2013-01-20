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
  isa_ok $doc, 'Web::DOM::Document';
  ok not $doc->isa ('Web::DOM::XMLDocument');

  is $doc->node_type, $doc->DOCUMENT_NODE;
  is $doc->namespace_uri, undef;
  is $doc->prefix, undef;
  is $doc->manakai_local_name, undef;
  is $doc->local_name, undef;

  is $doc->url, 'about:blank';
  is $doc->document_uri, $doc->url;
  is $doc->content_type, 'application/xml';
  is $doc->character_set, 'utf-8';
  is !!$doc->manakai_is_html, !!0;
  is $doc->compat_mode, 'CSS1Compat';
  is $doc->manakai_compat_mode, 'no quirks';
  is $doc->owner_document, undef;

  is $doc->node_value, undef;
  $doc->node_value ('hoge');
  is $doc->node_value, undef;

  is $doc->text_content, undef;
  $doc->text_content ('hoge');
  is $doc->text_content, undef;

  done $c;
} name => 'constructor', n => 19;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ("http://HOGE.test/%41\x{4300}");
  is $doc->url, 'http://hoge.test/A%E4%8C%80';
  is $doc->document_uri, $doc->url;
  done $c;
} n => 2, name => 'manakai_set_url';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  is $doc->manakai_entity_base_uri, 'about:blank';

  $doc->manakai_set_url ('http://hoge');
  is $doc->manakai_entity_base_uri, 'http://hoge/';

  $doc->manakai_entity_base_uri ('HTTP://foo.TEST');
  is $doc->manakai_entity_base_uri, 'http://foo.test/';
  is $doc->url, 'http://hoge/';

  done $c;
} n => 4, name => 'manakai_entity_base_uri';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->manakai_set_url ('../foo');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'Cannot resolve the specified URL';
  is $doc->url, 'about:blank';
  done $c;
} n => 5, name => 'manakai_set_url not resolvable';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;

  is $doc->text_content, '';
  $doc->text_content ('hoge fuga');
  is $doc->text_content, 'hoge fuga';
  is $doc->child_nodes->length, 1;
  is $doc->first_child->node_type, $doc->TEXT_NODE;
  is $doc->first_child->data, 'hoge fuga';

  $doc->text_content ('');
  is $doc->first_child, undef;

  done $c;
} n => 6, name => 'text_content not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;

  my $el = $doc->create_element ('aaa');
  $el->text_content ('hoge');
  $doc->append_child ($el);

  is $doc->text_content, 'hoge';
  $doc->text_content ('foo');
  is $doc->text_content, 'foo';
  is $el->parent_node, undef;
  is $el->text_content, 'hoge';

  done $c;
} n => 4, name => 'text_content not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  is $doc->character_set, 'utf-8';
  is $doc->charset, 'utf-8';
  is $doc->input_encoding, 'utf-8';

  done $c;
} n => 3, name => 'charset';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  is $doc->xml_version, '1.0';
  is $doc->xml_encoding, undef;
  ok not $doc->xml_standalone;

  $doc->xml_version (1.1);
  is $doc->xml_version, 1.1;

  $doc->xml_encoding ('utf-8');
  is $doc->xml_encoding, 'utf-8';

  $doc->xml_encoding (undef);
  is $doc->xml_encoding, undef;

  $doc->xml_standalone (1);
  ok $doc->xml_standalone;

  $doc->xml_standalone (undef);
  ok not $doc->xml_standalone;
  
  done $c;
} n => 8, name => 'xml_*';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  for my $version (1.2, 1, 'hoge', 0, '', undef) {
    dies_here_ok {
      $doc->xml_version ($version);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'NotSupportedError';
    is $@->message, 'Specified XML version is not supported';
  }

  is $doc->xml_version, '1.0';
  done $c;
} n => 4*6 + 1, name => 'xml_version error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);

  for my $version (1.2, 1, 'hoge', 0, '') {
    $doc->xml_version ($version);
    is $doc->xml_version, $version;
  }

  done $c;
} n => 5, name => 'xml_version not strict';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->strict_error_checking (0);

  $doc->xml_version ('1.1');
  is $doc->xml_version, '1.1';

  $doc->xml_version (undef);
  is $doc->xml_version, '';

  done $c;
} n => 2, name => 'xml_version not strict';

test {
  my $c = shift;

  my $doc = new Web::DOM::Document;

  my $impl = $doc->implementation;
  isa_ok $impl, 'Web::DOM::Implementation';

  is $doc->implementation, $impl;

  done $c;
} name => 'implementation', n => 2;

test {
  my $c = shift;

  my $doc = new Web::DOM::Document;

  my $config = $doc->dom_config;
  isa_ok $config, 'Web::DOM::Configuration';

  is $doc->dom_config, $config;

  done $c;
} name => 'dom_config', n => 2;

test {
  my $c = shift;
  
  my $doc = new Web::DOM::Document;

  my $doc2 = $doc->implementation->create_document;
  is $doc2->can ('manakai_is_html') ? 1 : 0, 1, "can manakai_is_html";
  is $doc2->can ('compat_mode') ? 1 : 0, 1, "can compat_mode";
  is $doc2->can ('manakai_compat_mode') ? 1 : 0, 1, "can manakai_compat_mode";
  is $doc2->manakai_is_html ? 1 : 0, 0, "manakai_is_html [0]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [0]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [0]';

  $doc2->manakai_compat_mode ('quirks');
  is $doc2->manakai_is_html ? 1 : 0, 0, "manakai_is_html [1]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [1]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [1]';

  $doc2->manakai_compat_mode ('limited quirks');
  is $doc2->manakai_is_html ? 1 : 0, 0, "manakai_is_html [2]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [2]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [2]';

  $doc2->manakai_compat_mode ('no quirks');
  is $doc2->manakai_is_html ? 1 : 0, 0, "manakai_is_html [3]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [3]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [3]';

  $doc2->manakai_compat_mode ('bogus');
  is $doc2->manakai_is_html ? 1 : 0, 0, "manakai_is_html [4]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [4]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [4]';

  $doc2->manakai_is_html (1);
  is $doc2->manakai_is_html ? 1 : 0, 1, "manakai_is_html [5]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [5]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [5]';

  $doc2->manakai_compat_mode ('quirks');
  is $doc2->manakai_is_html ? 1 : 0, 1, "manakai_is_html [6]";
  is $doc2->compat_mode, 'BackCompat', 'compat_mode [6]';
  is $doc2->manakai_compat_mode, 'quirks', 'manakai_compat_mode [6]';

  $doc2->manakai_compat_mode ('limited quirks');
  is $doc2->manakai_is_html ? 1 : 0, 1, "manakai_is_html [7]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [7]';
  is $doc2->manakai_compat_mode, 'limited quirks', 'manakai_compat_mode [7]';

  $doc2->manakai_compat_mode ('no quirks');
  is $doc2->manakai_is_html ? 1 : 0, 1, "manakai_is_html [8]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [8]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [8]';

  $doc2->manakai_compat_mode ('bogus');
  is $doc2->manakai_is_html ? 1 : 0, 1, "manakai_is_html [9]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [9]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [9]';

  $doc2->manakai_compat_mode ('quirks');
  $doc2->manakai_is_html (0);
  is $doc2->manakai_is_html ? 1 : 0, 0, "manakai_is_html [10]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [10]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [10]';

  $doc2->manakai_is_html (1);
  is $doc2->manakai_is_html ? 1 : 0, 1, "manakai_is_html [11]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [11]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [11]';

  done $c;
} name => 'html mode', n => 39;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  is $doc->content_type, 'application/xml';
  $doc->manakai_is_html (1);
  is $doc->content_type, 'text/html';
  $doc->manakai_is_html (0);
  is $doc->content_type, 'application/xml';
  $doc->manakai_is_html (1);
  is $doc->content_type, 'text/html';
  done $c;
} n => 4, name => 'content_type vs manakai_is_html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  is $doc->doctype, undef;
  is $doc->document_element, undef;
  done $c;
} n => 2, name => 'empty document child accessors';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('a', '', '');
  $doc->append_child ($dt);
  is $doc->doctype, $dt;
  is $doc->document_element, undef;
  done $c;
} n => 2, name => 'document child accessors, with doctype';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $comment = $doc->create_comment ('gg');
  $doc->append_child ($comment);
  my $el = $doc->create_element ('f');
  $doc->append_child ($el);
  is $doc->doctype, undef;
  is $doc->document_element, $el;
  done $c;
} n => 2, name => 'document child accessors, with document element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('a', '', '');
  $doc->append_child ($dt);
  my $comment = $doc->create_comment ('gg');
  $doc->append_child ($comment);
  my $el = $doc->create_element ('f');
  $doc->append_child ($el);
  is $doc->doctype, $dt;
  is $doc->document_element, $el;
  done $c;
} n => 2, name => 'document child accessors, with doctype, document element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  ok $doc->strict_error_checking;
  
  $doc->strict_error_checking (0);
  ok not $doc->strict_error_checking;

  $doc->strict_error_checking (1);
  ok $doc->strict_error_checking;

  done $c;
} n => 3, name => 'strict_error_checking';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  is $doc->manakai_charset, undef;

  $doc->manakai_charset ('hogE');
  is $doc->manakai_charset, 'hogE';

  $doc->manakai_charset (undef);
  is $doc->manakai_charset, undef;

  done $c;
} n => 3, name => 'manakai_charset';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  ok not $doc->manakai_has_bom;

  $doc->manakai_has_bom ('hogE');
  ok $doc->manakai_has_bom;

  $doc->manakai_has_bom (undef);
  ok not $doc->manakai_has_bom;

  done $c;
} n => 3, name => 'manakai_has_bom';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  ok not $doc->all_declarations_processed;

  $doc->all_declarations_processed ('hogE');
  ok $doc->all_declarations_processed;

  $doc->all_declarations_processed (undef);
  ok not $doc->all_declarations_processed;

  done $c;
} n => 3, name => 'all_declarations_processed';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  ok not $doc->manakai_is_srcdoc;

  $doc->manakai_is_srcdoc ('hogE');
  ok $doc->manakai_is_srcdoc;

  $doc->manakai_is_srcdoc (undef);
  ok not $doc->manakai_is_srcdoc;

  done $c;
} n => 3, name => 'manakai_is_srcdoc';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  is $doc->manakai_html, undef;
  is $doc->head, undef;
  is $doc->manakai_head, undef;
  is $doc->body, undef;
  done $c;
} n => 4, name => 'html structure, empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->append_child ($doc->create_element_ns (undef, 'html'));
  is $doc->manakai_html, undef;
  is $doc->head, undef;
  is $doc->manakai_head, undef;
  is $doc->body, undef;
  done $c;
} n => 4, name => 'html structure, non-HTML element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->append_child ($doc->create_element_ns
                          ('http://www.w3.org/1999/xhtml', 'a'));
  is $doc->manakai_html, undef;
  is $doc->head, undef;
  is $doc->manakai_head, undef;
  is $doc->body, undef;
  done $c;
} n => 4, name => 'html structure, non-html element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $html = $doc->append_child ($doc->create_element_ns
                          ('http://www.w3.org/1999/xhtml', 'html'));
  is $doc->manakai_html, $html;
  is $doc->head, undef;
  is $doc->manakai_head, undef;
  is $doc->body, undef;
  done $c;
} n => 4, name => 'html structure, html element only';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $html = $doc->append_child ($doc->create_element_ns
                          ('http://www.w3.org/1999/xhtml', 'html'));
  my $head = $html->append_child ($doc->create_element ('head'));
  my $body = $html->append_child ($doc->create_element ('body'));
  is $doc->manakai_html, $html;
  is $doc->head, $head;
  is $doc->manakai_head, $head;
  is $doc->body, $body;
  done $c;
} n => 4, name => 'html structure, html, head, body';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $html = $doc->append_child ($doc->create_element_ns
                          ('http://www.w3.org/1999/xhtml', 'html'));
  my $head = $html->append_child ($doc->create_element_ns (undef, 'head'));
  my $body = $html->append_child ($doc->create_element_ns (undef, 'body'));
  is $doc->manakai_html, $html;
  is $doc->head, undef;
  is $doc->manakai_head, undef;
  is $doc->body, undef;
  done $c;
} n => 4, name => 'html structure, html, without head, body';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $html = $doc->append_child ($doc->create_element_ns
                          ('http://www.w3.org/1999/xhtml', 'html'));
  my $body1 = $html->append_child ($doc->create_element ('body'));
  my $body2 = $html->append_child ($doc->create_element ('body'));
  my $head1 = $html->append_child ($doc->create_element ('head'));
  my $head2 = $html->append_child ($doc->create_element ('head'));
  is $doc->manakai_html, $html;
  is $doc->head, $head1;
  is $doc->manakai_head, $head1;
  is $doc->body, $body1;
  done $c;
} n => 4, name => 'html structure, html, head, body reordered multiple';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $html = $doc->append_child ($doc->create_element_ns
                          ('http://www.w3.org/1999/xhtml', 'html'));
  my $head = $html->append_child ($doc->create_element ('head'));
  my $body = $html->append_child ($doc->create_element ('frameset'));
  is $doc->manakai_html, $html;
  is $doc->head, $head;
  is $doc->manakai_head, $head;
  is $doc->body, $body;
  done $c;
} n => 4, name => 'html structure, html, head, frameset';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $html = $doc->append_child ($doc->create_element_ns
                          ('http://www.w3.org/1999/xhtml', 'html'));
  my $head = $html->append_child ($doc->create_element ('head'));
  my $body = $html->append_child ($doc->create_element ('frameset'));
  my $body2 = $html->append_child ($doc->create_element ('body'));
  is $doc->manakai_html, $html;
  is $doc->head, $head;
  is $doc->manakai_head, $head;
  is $doc->body, $body;
  done $c;
} n => 4, name => 'html structure, html, head, frameset, body';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('body');
  $el1->append_child ($el3);
  my $el4 = $doc->create_element ('body');
  $doc->body ($el4);
  is $doc->body, $el4;
  is $el3->parent_node, undef;
  is $el4->parent_node, $el1;
  done $c;
} n => 3, name => 'body setter body';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('body');
  $el1->append_child ($el3);
  my $el4 = $doc->create_element ('frameset');
  $doc->body ($el4);
  is $doc->body, $el4;
  is $el3->parent_node, undef;
  is $el4->parent_node, $el1;
  done $c;
} n => 3, name => 'body setter frameset';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('body');
  $el1->append_child ($el3);
  my $el4 = $doc->create_element ('body');
  $el1->append_child ($el4);
  my $el5 = $doc->create_element ('body');
  $doc->body ($el5);
  is $doc->body, $el5;
  is $el3->parent_node, undef;
  is $el4->parent_node, $el1;
  is $el5->parent_node, $el1;
  is $el5->next_sibling, $el4;
  done $c;
} n => 5, name => 'body setter multiple body';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('frameset');
  $el1->append_child ($el3);
  my $el4 = $doc->create_element ('body');
  $el1->append_child ($el4);
  my $el5 = $doc->create_element ('body');
  $doc->body ($el5);
  is $doc->body, $el5;
  is $el3->parent_node, undef;
  is $el4->parent_node, $el1;
  is $el5->parent_node, $el1;
  is $el5->next_sibling, $el4;
  done $c;
} n => 5, name => 'body setter multiple body';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('body');
  $el1->append_child ($el3);
  $doc->body ($el3);
  is $doc->body, $el3;
  is $el3->parent_node, $el1;
  done $c;
} n => 2, name => 'body setter self';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('frameset');
  $el1->append_child ($el3);
  $doc->body ($el3);
  is $doc->body, $el3;
  is $el3->parent_node, $el1;
  done $c;
} n => 2, name => 'body setter self frameset';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns (undef, 'hoge');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('body');
  $doc->body ($el2);
  is $doc->body, undef;
  is $el2->parent_node, $el1;
  my $el3 = $doc->create_element ('frameset');
  $doc->body ($el3);
  is $doc->body, undef;
  is $el3->parent_node, $el1;
  is $el1->child_nodes->length, 2;
  done $c;
} n => 5, name => 'body setter non-html root';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('body');
  $el1->append_child ($el3);
  dies_here_ok {
    $doc->body (undef);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The specified value cannot be used as the body element';
  is $doc->body, $el3;
  done $c;
} n => 5, name => 'body setter undef';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('body');
  $el1->append_child ($el3);
  my $el4 = $doc->create_element ('Body');
  dies_here_ok {
    $doc->body ($el4);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The specified value cannot be used as the body element';
  is $doc->body, $el3;
  done $c;
} n => 5, name => 'body setter not body';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('body');
  $el1->append_child ($el3);
  my $el4 = $doc->create_element_ns (undef, 'body');
  dies_here_ok {
    $doc->body ($el4);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->name, 'TypeError';
  is $@->message, 'The argument is not an HTMLElement';
  is $doc->body, $el3;
  done $c;
} n => 5, name => 'body setter not htmlelement';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('body');
  dies_here_ok {
    $doc->body ($el1);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'There is no root element';
  is $doc->body, undef;
  is $el1->parent_node, undef;
  done $c;
} n => 6, name => 'body setter no root element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  is $doc->title, '';
  done $c;
} n => 1, name => 'title not found';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'svg');
  $doc->append_child ($el);
  is $doc->title, '';
  done $c;
} n => 1, name => 'title /svg/empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'svg');
  $doc->append_child ($el);
  my $el2 = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'title');
  $el2->text_content ('');
  $el->append_child ($el2);
  is $doc->title, '';
  done $c;
} n => 1, name => 'title /svg/title/empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'svg');
  $doc->append_child ($el);
  my $el2 = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'title');
  $el2->text_content ('hoge fuga');
  $el->append_child ($el2);
  is $doc->title, 'hoge fuga';
  done $c;
} n => 1, name => 'title /svg/title/text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'svg');
  $doc->append_child ($el);
  my $el1 = $doc->create_element ('title');
  $el1->text_content ('aaa');
  $el->append_child ($el1);
  my $el2 = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'title');
  $el2->inner_html ('hoge <p>fuga</p>bar');
  $el->append_child ($el2);
  is $doc->title, 'hoge fugabar';
  done $c;
} n => 1, name => 'title /svg/{html:title|title}';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'svg');
  $doc->append_child ($el);
  my $el1 = $doc->create_element ('title');
  $el1->text_content ('aaa');
  $el->append_child ($el1);
  is $doc->title, '';
  done $c;
} n => 1, name => 'title /svg/html:title';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'svg');
  $doc->append_child ($el);
  my $el2 = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'title');
  $el2->inner_html ('hoge <p>fuga</p>bar  ');
  $el->append_child ($el2);
  is $doc->title, 'hoge fugabar  ';
  done $c;
} n => 1, name => 'title /svg/title/nodes';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  is $doc->title, '';
  done $c;
} n => 1, name => 'title /html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  is $doc->title, '';
  done $c;
} n => 1, name => 'title /html/head';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('title');
  $el2->append_child ($el3);
  is $doc->title, '';
  done $c;
} n => 1, name => 'title /html/head/title';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('title');
  $el2->append_child ($el3);
  $el3->text_content ('hpoge ');
  is $doc->title, 'hpoge';
  done $c;
} n => 1, name => 'title /html/head/title';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('title');
  $el2->append_child ($el3);
  $el3->text_content ("\x09\x0C\x0Dhp\x0A\x20og\x09e ");
  is $doc->title, 'hp og e';
  done $c;
} n => 1, name => 'title /html/head/title';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('title');
  $el2->append_child ($el3);
  $el3->text_content ("\x09\x0C\x0Dhp\x0A\x20og\x09e ");
  $el3->append_child ($doc->create_element ('title'))->text_content ('abc');
  $el3->manakai_append_text (' aa  bc');
  is $doc->title, 'hp og e aa bc';
  done $c;
} n => 1, name => 'title /html/head/title';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->title ('hoge');
  is $doc->title, '';
  is $doc->first_child, undef;
  done $c;
} n => 2, name => 'title setter empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('foo');
  $doc->append_child ($el1);
  $doc->title ('hoge');
  is $doc->title, '';
  is $doc->first_child, $el1;
  done $c;
} n => 2, name => 'title setter /root';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('title');
  $doc->append_child ($el1);
  $doc->title ('hoge');
  is $doc->title, 'hoge';
  is $doc->first_child, $el1;
  is $el1->text_content, 'hoge';
  done $c;
} n => 3, name => 'title setter /title';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'svg');
  $doc->append_child ($el1);
  $doc->title ('hoge');
  is $doc->title, '';
  is $doc->first_child, $el1;
  done $c;
} n => 2, name => 'title setter /svg';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'svg');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'title');
  $el1->append_child ($el2);
  $doc->title ('hoge');
  is $doc->title, '';
  is $el2->first_child, undef;
  done $c;
} n => 2, name => 'title setter /svg/title';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'svg');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'title');
  $el1->append_child ($el2);
  $el2->inner_html ('foo<p>bar</p>');
  $doc->title ('hoge');
  is $doc->title, 'foobar';
  is $el2->child_nodes->length, 2;
  done $c;
} n => 2, name => 'title setter /svg/title';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'svg');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'g');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'title');
  $el2->append_child ($el3);
  $el3->inner_html ('foo<p>bar</p>');
  $doc->title ('hoge');
  is $doc->title, '';
  is $el3->child_nodes->length, 2;
  done $c;
} n => 2, name => 'title setter /svg/g/title';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'svg');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'g');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element_ns ('http://www.w3.org/1999/html', 'title');
  $el2->append_child ($el3);
  $el3->inner_html ('foo<p>bar</p>');
  $doc->title ('hoge');
  is $doc->title, '';
  is $el3->child_nodes->length, 2;
  done $c;
} n => 2, name => 'title setter /svg/g/title';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('hoge');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('title');
  $el1->append_child ($el2);
  $doc->title ("fo\x0C\x09o bar  ");
  is $doc->title, 'fo o bar';
  is $el2->text_content, "fo\x0C\x09o bar  ";
  done $c;
} n => 2, name => 'title setter html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('hoge');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('title');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('title');
  $el1->append_child ($el3);
  $doc->title ("fo\x0C\x09o bar  ");
  is $doc->title, 'fo o bar';
  is $el2->text_content, "fo\x0C\x09o bar  ";
  is $el3->text_content, '';
  done $c;
} n => 3, name => 'title setter html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  $doc->title ('foo ');
  is $doc->title, 'foo';
  is $el2->first_child->local_name, 'title';
  is $el2->first_child->text, 'foo ';
  done $c;
} n => 3, name => 'title setter head/null';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('title');
  $el2->append_child ($el3);
  $doc->title ('foo ');
  is $doc->title, 'foo';
  is $el2->first_child, $el3;
  is $el2->first_child->text, 'foo ';
  done $c;
} n => 3, name => 'title setter head/title';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('title');
  $el1->append_child ($el3);
  $doc->title ('foo ');
  is $doc->title, 'foo';
  is $el2->first_child, undef;
  is $el3->text, 'foo ';
  done $c;
} n => 3, name => 'title setter head/title';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('title');
  $el2->append_child ($el3);
  $doc->title ('');
  is $doc->title, '';
  is $el3->first_child->node_type, 3;
  done $c;
} n => 2, name => 'title setter head/title empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('html');
  $doc->append_child ($el1);
  my $el2 = $doc->create_element ('head');
  $el1->append_child ($el2);
  my $el3 = $doc->create_element ('title');
  $el2->append_child ($el3);
  $el3->text_content ("fff");
  my $text = $el3->first_child;
  $doc->title ('abc');
  is $doc->title, 'abc';
  is $text->parent_node, undef;
  is $text->text_content, 'fff';
  done $c;
} n => 3, name => 'title setter head/title old child';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  is $doc->dir, '';
  $doc->dir ('ltr');
  is $doc->dir, '';
  done $c;
} n => 2, name => 'dir empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('head');
  $el->dir ('rtl');
  $doc->append_child ($el);
  is $doc->dir, '';
  $doc->dir ('ltr');
  is $doc->dir, '';
  is $el->get_attribute ('dir'), 'rtl';
  done $c;
} n => 3, name => 'dir not html element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (undef, 'html');
  $el->set_attribute (dir => 'rtl');
  $doc->append_child ($el);
  is $doc->dir, '';
  $doc->dir ('ltr');
  is $doc->dir, '';
  is $el->get_attribute ('dir'), 'rtl';
  done $c;
} n => 3, name => 'dir not html element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('html');
  $doc->append_child ($el);
  is $doc->dir, '';
  $doc->dir ('Rtl');
  is $doc->dir, 'rtl';
  is $el->get_attribute ('dir'), 'Rtl';
  $doc->dir ('abc');
  is $doc->dir, '';
  is $el->get_attribute ('dir'), 'abc';
  done $c;
} n => 5, name => 'dir html element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('html');
  $el->dir ('rtl');
  $doc->append_child ($el);
  is $doc->dir, 'rtl';
  $doc->dir ('ltr');
  is $doc->dir, 'ltr';
  is $el->get_attribute ('dir'), 'ltr';
  done $c;
} n => 3, name => 'dir html element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('head');
  $doc->append_child ($el);
  is $doc->dir, '';
  $doc->dir ('ltr');
  is $doc->dir, '';
  is $el->attributes->length, 0;
  done $c;
} n => 3, name => 'dir not html element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  $doc->append_child ($el);
  $doc->clear;
  is $doc->child_nodes->length, 1;
  done $c;
} n => 1, name => 'clear';

run_tests;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
