use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::Differences;
use Web::DOM::Document;
use Web::CSS::Parser;

sub from_style_el ($;%) {
  my (undef, %args) = @_;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('style');
  $el->text_content ($_[0]);
  $el->type ($args{type}) if defined $args{type};
  $el->title ($args{title}) if defined $args{title};

  my $parser = Web::CSS::Parser->new;
  $parser->parse_style_element ($el);

  return $el->sheet;
} # from_style_el

test {
  my $c = shift;
  my $css = from_style_el 'p {}';

  is $css->type, 'text/css';

  $css->owner_node->type ('text/CSS');
  is $css->type, 'text/css';

  $css->owner_node->type ('text/plain');
  is $css->type, 'text/css';

  done $c;
} n => 3, name => 'type - default';

test {
  my $c = shift;
  my $css = from_style_el 'p {}', type => 'text/javascript';

  is $css->type, 'text/css';

  done $c;
} n => 1, name => 'type - non css value';

test {
  my $c = shift;
  my $css = from_style_el 'p {}';

  is $css->href, undef;
  is $css->parent_style_sheet, undef;

  done $c;
} n => 2, name => '<style> attributes';

test {
  my $c = shift;
  my $css = from_style_el 'p {}';

  is $css->title, undef;

  $css->owner_node->title ('');
  is $css->title, undef;

  $css->owner_node->title ('abc');
  is $css->title, 'abc';

  done $c;
} n => 3, name => '<style> no title';

test {
  my $c = shift;
  my $css = from_style_el 'p {}', title => 'aaa';

  is $css->title, 'aaa';

  $css->owner_node->title ('');
  is $css->title, undef;

  $css->owner_node->title ('abc');
  is $css->title, 'abc';

  done $c;
} n => 3, name => '<style> with title';

test {
  my $c = shift;
  my $css = from_style_el 'p {}';

  $css->disabled (0);
  ok not $css->disabled;
  ok not $css->owner_node->disabled;
  ok not $css->disabled;

  $css->disabled (1);
  ok $css->disabled;
  ok $css->owner_node->disabled;
  ok $css->disabled;

  $css->owner_node->disabled (1);
  ok $css->disabled;
  ok $css->owner_node->disabled;

  $css->owner_node->disabled (0);
  ok not $css->disabled;
  ok not $css->owner_node->disabled;

  done $c;
} n => 10, name => '<style> disabled';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('style');

  is $el->sheet, undef;
  ok not $el->disabled;
  
  $el->disabled (1);
  ok not $el->disabled;

  $el->disabled (0);
  ok not $el->disabled;

  done $c;
} n => 4, name => '<style> disabled, no sheet';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
