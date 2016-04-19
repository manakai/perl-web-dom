package Test::DOM::CSS;
use strict;
use warnings;
use Exporter::Lite;
use Web::DOM::Document;
use Web::CSS::Parser;

our @EXPORT;

push @EXPORT, qw(from_style_el);
sub from_style_el ($;%) {
  my (undef, %args) = @_;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  $doc->inner_html (q{<!DOCTYPE HTML><base>});
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'style');
  $el->text_content ($_[0]);
  $el->type ($args{type}) if defined $args{type};
  $el->title ($args{title}) if defined $args{title};
  $el->media ($args{media}) if defined $args{media};
  $doc->get_elements_by_tag_name ('base')->[0]->href
      ($args{base_url}) if defined $args{base_url};

  my $parser = Web::CSS::Parser->get_parser_of_document ($doc);
  $parser->media_resolver->set_supported (all => 1);

  $parser->parse_style_element ($el);

  return $el->sheet;
} # from_style_el

push @EXPORT, qw(from_style_attr);
sub from_style_attr ($;%) {
  my (undef, %args) = @_;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'p');
  $el->set_attribute_ns (undef, style => $_[0]) if defined $_[0];
  $el->set_attribute_ns ('http://www.w3.org/XML/1998/namespace', 'xml:base' => $args{base_url}) if defined $args{base_url};

  my $parser = Web::CSS::Parser->get_parser_of_document ($doc);
  $parser->media_resolver->set_supported (all => 1);

  return ($el, $el->style);
} # from_style_attr

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
