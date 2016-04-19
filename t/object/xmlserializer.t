use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::XMLSerializer;
use Web::DOM::Document;

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  isa_ok $s, 'Web::DOM::XMLSerializer';
  isnt new Web::DOM::XMLSerializer, $s;
  done $c;
} n => 2, name => 'constructor';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  dies_here_ok {
    $s->serialize_to_string (undef);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The argument is not a Node';

  done $c;
} n => 3, name => 'not a node';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  is $s->serialize_to_string ($doc), '';

  done $c;
} n => 1, name => 'xml document empty';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  is $s->serialize_to_string ($doc), '';

  done $c;
} n => 1, name => 'html document empty';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  $doc->append_child ($doc->create_document_type_definition ('FAaf'));
  $doc->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge'))
      ->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'br'));
  is $s->serialize_to_string ($doc),
      '<!DOCTYPE FAaf><hoge xmlns="http://www.w3.org/1999/xhtml"><br></br></hoge>';

  done $c;
} n => 1, name => 'xml document not empty';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  $doc->append_child ($doc->create_document_type_definition ('FAaf'));
  $doc->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge'))
      ->append_child ($doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'br'));
  is $s->serialize_to_string ($doc),
      '<!DOCTYPE FAaf><hoge><br></hoge>';

  done $c;
} n => 1, name => 'html document not empty';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  my $el2 = $doc->create_element_ns (undef, 'foo');
  $doc->append_child ($el1);
  $doc->append_child ($el2);
  is $s->serialize_to_string ($doc),
      q{<foo xmlns="http://www.w3.org/1999/xhtml"></foo><foo xmlns=""></foo>};

  done $c;
} n => 1, name => 'xml document multiple children';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  $doc->dom_config->{manakai_strict_document_children} = 0;
  $doc->manakai_is_html (1);
  my $el1 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  $doc->append_child ($el1);
  $doc->append_child ($el2);
  is $s->serialize_to_string ($doc), q{<foo></foo><foo></foo>};

  done $c;
} n => 1, name => 'html document multiple children';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  $el->inner_html (q{<p>aaa<br/>bbbx&amp;s</p><img title="&quot;"/>});
  is $s->serialize_to_string ($el), q{<foo xmlns="http://www.w3.org/1999/xhtml"><p>aaa<br></br>bbbx&amp;s</p><img title="&quot;"></img></foo>};

  done $c;
} n => 1, name => 'xml element';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'foo');
  $el->inner_html (q{<p>aaa<br/>bbbx&amp;s</p><img title>});
  is $s->serialize_to_string ($el),
      q{<foo><p>aaa<br>bbbx&amp;s</p><img title=""></foo>};

  done $c;
} n => 1, name => 'html element';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_document_fragment;
  $el->inner_html (q{<p>aaa<br/>bbbx&amp;s</p><img title=""/>});
  is $s->serialize_to_string ($el),
      q{<p xmlns="http://www.w3.org/1999/xhtml">aaa<br></br>bbbx&amp;s</p><img xmlns="http://www.w3.org/1999/xhtml" title=""></img>};

  done $c;
} n => 1, name => 'xml document fragment';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_document_fragment;
  $el->inner_html (q{<p>aaa<br/>bbbx&amp;s</p><img title>});
  is $s->serialize_to_string ($el), q{<p>aaa<br>bbbx&amp;s</p><img title="">};

  done $c;
} n => 1, name => 'html document fragment';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_text_node ("ab&bc");
  is $s->serialize_to_string ($node), q{ab&amp;bc};

  done $c;
} n => 1, name => 'xml text';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $node = $doc->create_text_node ("ab&bc");
  is $s->serialize_to_string ($node), q{ab&amp;bc};

  done $c;
} n => 1, name => 'html text';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_comment ("ab&bc");
  is $s->serialize_to_string ($node), q{<!--ab&bc-->};

  done $c;
} n => 1, name => 'xml comment';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $node = $doc->create_comment ("ab&bc");
  is $s->serialize_to_string ($node), q{<!--ab&bc-->};

  done $c;
} n => 1, name => 'html comment';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_processing_instruction ('foo', "ab&bc");
  is $s->serialize_to_string ($node), q{<?foo ab&bc?>};

  done $c;
} n => 1, name => 'xml pi';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $node = $doc->create_processing_instruction ('foo', "ab&bc");
  is $s->serialize_to_string ($node), q{<?foo ab&bc>};

  done $c;
} n => 1, name => 'html pi';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_document_type_definition ('fooBar');
  is $s->serialize_to_string ($node), q{<!DOCTYPE fooBar>};

  done $c;
} n => 1, name => 'xml dt';

test {
  my $c = shift;
  my $s = new Web::DOM::XMLSerializer;
  
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $node = $doc->create_document_type_definition ('fooBar');
  is $s->serialize_to_string ($node), q{<!DOCTYPE fooBar>};

  done $c;
} n => 1, name => 'html dt';

for my $is_html (0, 1) {
  for my $method (qw(
    create_attribute create_element_type_definition create_attribute_definition
    create_general_entity create_notation
  )) {
    test {
      my $c = shift;
      my $s = new Web::DOM::XMLSerializer;
      
      my $doc = new Web::DOM::Document;
      $doc->manakai_is_html ($is_html);
      my $node = $doc->$method ('fooBar');
      dies_here_ok {
        $s->serialize_to_string ($node);
      };
      isa_ok $@, 'Web::DOM::Exception';
      is $@->name, 'NotSupportedError';
      is $@->message, 'The node cannot be serialized';
      
      done $c;
    } n => 4, name => [$is_html ? 'html' : 'xml', $method];
  }
}

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
