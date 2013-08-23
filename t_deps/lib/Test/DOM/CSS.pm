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
  my $el = $doc->create_element ('style');
  $el->text_content ($_[0]);
  $el->type ($args{type}) if defined $args{type};
  $el->title ($args{title}) if defined $args{title};
  $el->media ($args{media}) if defined $args{media};

  my $parser = Web::CSS::Parser->new;
  $parser->parse_style_element ($el);

  return $el->sheet;
} # from_style_el

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
