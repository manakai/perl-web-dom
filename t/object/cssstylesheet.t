use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::CSS;
use Test::DOM::Exception;
use Test::DOM::Destroy;

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

test {
  my $c = shift;
  my $css = from_style_el '';

  my $list = $css->css_rules;
  isa_ok $list, 'Web::DOM::CSSRuleList';
  is $list->length, 0;

  is $css->css_rules, $list;

  done $c;
} n => 3, name => 'css_rules empty';

test {
  my $c = shift;
  my $css = from_style_el 'p{}@media{}';

  my $list = $css->css_rules;
  isa_ok $list, 'Web::DOM::CSSRuleList';
  is $list->length, 2;

  is $css->css_rules, $list;

  is $css->css_rules->[0]->type, 1;
  is $css->css_rules->[1]->type, 4;

  done $c;
} n => 5, name => 'css_rules not empty';

test {
  my $c = shift;
  my $css1 = from_style_el 'p {} q{}';
  my $css2 = from_style_el 'p {} q{}';

  ok $css1;

  isnt $css1 cmp $css2, 0;
  is $css1 cmp $css1, 0;
  isnt $css1 cmp undef, 0;
  isnt undef cmp $css1, 0;

  ok $css1 eq $css1;
  ok not $css1 eq $css2;
  ok $css1 ne $css2;
  ok not $css1 ne $css1;

  done $c;
} n => 9, name => 'comparison';

test {
  my $c = shift;
  my $css = from_style_el 'p {poSition: absolUTe; border-top-style:hidden}';
  my $css_s = ''.$css;
  my $node = $css->owner_node;
  undef $css;

  is $node->sheet . '', $css_s;

  done $c;
} n => 1, name => 'string comparison';

test {
  my $c = shift;
  my $css = from_style_el '';
  my $media = $css->media;
  isa_ok $media, 'Web::DOM::MediaList';
  is $media->media_text, '';
  $media->media_text ('scree\n, All');
  is $media->media_text, 'screen, all';
  is $css->owner_node->media, '';
  done $c;
} n => 4, name => 'media not specified';

# XXX
#test {
#  my $c = shift;
#  my $css = from_style_el '', media => 'hoge, (), screEn';
#  my $media = $css->media;
#  isa_ok $media, 'Web::DOM::MediaList';
#  is $media->media_text, 'hoge, not all, screen';
#  $media->media_text ('scree\n, All');
#  is $media->media_text, 'screen, all';
#  is $css->owner_node->media, 'hoge, (), screEn';
#  done $c;
#} n => 4, name => 'media specified';

test {
  my $c = shift;
  my $css = from_style_el '';
  
  dies_here_ok {
    $css->delete_rule (0);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'IndexSizeError';
  is $@->message, 'The specified rule index is invalid';

  is $css->css_rules->length, 0;

  done $c;
} n => 5, name => 'delete_rule empty';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}r{}';
  
  $css->delete_rule (1);

  is $$css->[0]->{data}->[$$css->[1] + 2], undef;

  is $css->css_rules->length, 2;

  is $css->css_rules->[0]->selector_text, 'p';
  is $css->css_rules->[1]->selector_text, 'r';

  done $c;
} n => 4, name => 'delete_rule deleted';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}r{}';
  
  $css->delete_rule (1 + 2**32);

  is $css->css_rules->length, 2;
  is $css->css_rules->[0]->selector_text, 'p';
  is $css->css_rules->[1]->selector_text, 'r';

  done $c;
} n => 3, name => 'delete_rule deleted unsigned long';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}r{}';
  my $old_rule = $css->css_rules->[1];
  my $main_destroyed = 0;
  ondestroy { $main_destroyed = 1 } $$css->[0];
  
  $css->delete_rule (1);

  isnt $$old_rule->[0], $$css->[0];

  is $old_rule->parent_rule, undef;
  is $old_rule->parent_style_sheet, undef;

  undef $css;
  ok $main_destroyed;

  my $old_destroyed = 0;
  ondestroy { $old_destroyed = 1 } $old_rule;
  undef $old_rule;
  ok $old_destroyed;

  done $c;
} n => 5, name => 'delete_rule deleted rule';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}';
  
  dies_here_ok {
    $css->delete_rule (2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'IndexSizeError';
  is $@->message, 'The specified rule index is invalid';

  is $css->css_rules->length, 2;

  done $c;
} n => 5, name => 'delete_rule greater index';

test {
  my $c = shift;
  my $css = from_style_el '@charset "";@import "";@namespace "aa";@namespace b "c";';
  
  $css->delete_rule (2);

  is $css->css_rules->length, 3;
  is $css->css_rules->[2]->prefix, 'b';

  done $c;
} n => 2, name => 'delete_rule @namespace ok';

test {
  my $c = shift;
  my $css = from_style_el '@charset "";@import "";@namespace "aa";p{}';
  
  dies_here_ok {
    $css->delete_rule (2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidStateError';
  is $@->message, 'Namespace rule cannot be deleted if there are following rules';

  is $css->css_rules->length, 4;
  is $css->css_rules->[2]->type, 10;

  done $c;
} n => 6, name => 'delete_rule @namespace ok';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}r{}';
  my $destroyed = 0;
  ondestroy { $destroyed = 1 } $css->css_rules->[1];
  
  $css->delete_rule (1);

  ok $destroyed;

  done $c;
} n => 1, name => 'delete_rule deleted ref';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
