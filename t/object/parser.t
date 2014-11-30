use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Parser;

test {
  my $c = shift;
  my $parser = new Web::DOM::Parser;
  isa_ok $parser, 'Web::DOM::Parser';

  my $doc = $parser->parse_from_string ('hoge <p> fu&<>', 'text/html');
  isa_ok $doc, 'Web::DOM::Document';
  ok not $doc->isa ('Web::DOM::XMLDocument');
  ok $doc->manakai_is_html;
  
  is $doc->inner_html, '<html><head></head><body>hoge <p> fu&amp;&lt;&gt;</p></body></html>';

  is $doc->content_type, 'text/html';
  is $doc->character_set, 'UTF-8';
  is $doc->url, 'about:blank';

  done $c;
} n => 8, name => 'text/html';

for my $type (qw(text/xml application/xml application/xhtml+xml
                 image/svg+xml)) {
  test {
    my $c = shift;
    my $parser = new Web::DOM::Parser;
    isa_ok $parser, 'Web::DOM::Parser';

    my $doc = $parser->parse_from_string
        ('<b><![CDATA[hoge <p> fu&<>]]><C/></b>', $type);
    isa_ok $doc, 'Web::DOM::Document';
    ok not $doc->manakai_is_html;
    
    is $doc->inner_html, '<b xmlns="">hoge &lt;p&gt; fu&amp;&lt;&gt;<C></C></b>';

    is $doc->content_type, $type;
    is $doc->character_set, 'UTF-8';
    is $doc->url, 'about:blank';

    done $c;
  } n => 7, name => [$type, 'well-formed'];

  test {
    my $c = shift;
    my $parser = new Web::DOM::Parser;
    isa_ok $parser, 'Web::DOM::Parser';

    my $doc = $parser->parse_from_string
        ('<b>hoge <p> fu&<>><C/></b>', $type);
    isa_ok $doc, 'Web::DOM::XMLDocument';
    ok not $doc->manakai_is_html;

    is $doc->document_element->namespace_uri,
        'http://www.mozilla.org/newlayout/xml/parsererror.xml';
    is $doc->document_element->local_name, 'parsererror';

    is $doc->content_type, $type;
    is $doc->character_set, 'UTF-8';
    is $doc->url, 'about:blank';

    #warn $doc->inner_html;

    done $c;
  } n => 8, name => [$type, 'not well-formed'];
}

test {
  my $c = shift;
  my $parser = new Web::DOM::Parser;
  isnt new Web::DOM::Parser, $parser;
  done $c;
} n => 1, name => 'constructor';

for my $type (undef, '', 'Text/html', 'application/octet-stream') {
  test {
    my $c = shift;
    my $parser = new Web::DOM::Parser;
    dies_here_ok {
      $parser->parse_from_string ('<p>hoge</p>', $type);
    };
    isa_ok $@, 'Web::DOM::TypeError';
    is $@->message, 'Unknown type is specified';
    done $c;
  } n => 3, name => ['unknown type', $type];
}

run_tests;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
