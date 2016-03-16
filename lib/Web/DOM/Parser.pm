package Web::DOM::Parser;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::TypeError;
use Web::DOM::Document;
our @CARP_NOT = qw(Web::DOM::TypeError);

sub new ($) {
  return bless {}, $_[0];
} # new

sub parse_from_string ($$$) {
  my $s = ''.$_[1];
  my $type = ''.$_[2];
  if ($type eq 'text/html') {
    my $doc = new Web::DOM::Document;
    $doc->manakai_is_html (1);
    # XXX origin
    # XXX disable scripting
    require Web::HTML::Parser;
    Web::HTML::Parser->new->parse_char_string ($s => $doc);
    # XXX redirect errors to the Console object
    return $doc;
  } elsif ($type eq 'text/xml' or
           $type eq 'application/xml' or
           $type eq 'application/xhtml+xml' or
           $type eq 'image/svg+xml') {
    # 1.
    my $doc = new Web::DOM::Document;
    # XXX origin
    # XXX disable scripting
    require Web::XML::Parser;
    my $parser = Web::XML::Parser->new;
    my $orig_onerror = $parser->onerror;
    $parser->onerror (sub {
      my %args = @_;
      $orig_onerror->(@_);
      if (($args{level} || 'm') eq 'm') {
        $parser->throw (sub {
          undef $parser;
          die bless {%args}, 'Web::DOM::Parser::_ParseError';
        });
      }
    });
    # XXX redirect errors to the Console object
    my $error;
    {
      local $@;
      eval {
        $parser->parse_char_string ($s => $doc);
      };
      $error = $@;
    }

    # 2.
    $$doc->[2]->{content_type} = $type;
    return $doc unless $error;
    die $error unless UNIVERSAL::isa ($error, 'Web::DOM::Parser::_ParseError');

    # 3.-4.
    # XXX origin
    $doc = $doc->implementation->create_document
        ('http://www.mozilla.org/newlayout/xml/parsererror.xml',
         'parsererror');
    my $p = $doc->create_element ('p');
    # XXX
    $p->text_content (sprintf '%s at line %d column %d',
                          $error->{type}, $error->{line}, $error->{column});
    $doc->document_element->append_child ($p);

    # 5.
    $$doc->[2]->{content_type} = $type;
    return $doc;
  } else {
    _throw Web::DOM::TypeError
        'Unknown type is specified';
  }
} # parse_from_string

package Web::DOM::Parser::_ParseError;

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
