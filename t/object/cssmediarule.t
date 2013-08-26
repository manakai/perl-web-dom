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

test {
  my $c = shift;
  my $css = from_style_el '@media {}';
  my $rule = $css->css_rules->[0];
  is $rule->type, 4;
  is $rule->parent_rule, undef;
  is $rule->parent_style_sheet, $css;
  done $c;
} n => 3, name => 'basic';

test {
  my $c = shift;
  my $css = from_style_el '@media {}';
  my $rule = $css->css_rules->[0];

  my $list = $rule->css_rules;
  isa_ok $list, 'Web::DOM::CSSRuleList';
  is $list->length, 0;

  is $rule->css_rules, $list;

  done $c;
} n => 3, name => 'css_rules empty';

test {
  my $c = shift;
  my $css = from_style_el '@media {p{} Q{}}';
  my $rule = $css->css_rules->[0];

  my $list = $rule->css_rules;
  isa_ok $list, 'Web::DOM::CSSRuleList';
  is $list->length, 2;
  is $list->[0]->selector_text, 'p';
  is $list->[1]->selector_text, 'Q';

  is $list->[0]->parent_rule, $rule;
  is $list->[1]->parent_rule, $rule;
  is $list->[0]->parent_style_sheet, $css;
  is $list->[1]->parent_style_sheet, $css;

  done $c;
} n => 8, name => 'css_rules not empty';

test {
  my $c = shift;
  my $css = from_style_el '@media screen  , print  {}';
  my $rule = $css->css_rules->[0];

  my $media = $rule->media;
  is $media->media_text, 'screen, print';
  is $media->[0], 'screen';
  is $media->[1], 'print';

  $rule->media ('abc, speech');
  is $media->media_text, 'abc, speech';

  done $c;
} n => 4, name => 'media';

test {
  my $c = shift;
  my $css = from_style_el '@media{p {}}';
  my $rule = $css->css_rules->[0];

  $rule->delete_rule (0);

  is $rule->css_rules->length, 0;

  done $c;
} n => 1, name => 'delete_rule';

test {
  my $c = shift;
  my $css = from_style_el '@media{p {}}';
  my $rule = $css->css_rules->[0];

  $rule->delete_rule (0 - 2**32);

  is $rule->css_rules->length, 0;

  done $c;
} n => 1, name => 'delete_rule';

test {
  my $c = shift;
  my $css = from_style_el '@media{p {}}';
  my $rule = $css->css_rules->[0];

  dies_here_ok {
    $rule->delete_rule (1);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'IndexSizeError';
  is $@->message, 'The specified rule index is invalid';

  is $rule->css_rules->length, 1;

  done $c;
} n => 5, name => 'delete_rule';

test {
  my $c = shift;
  my $css = from_style_el '@media{p {}}';
  my $rule = $css->css_rules->[0];

  dies_here_ok {
    $rule->delete_rule (1 + 2**32);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'IndexSizeError';
  is $@->message, 'The specified rule index is invalid';

  is $rule->css_rules->length, 1;

  done $c;
} n => 5, name => 'delete_rule';

test {
  my $c = shift;
  my $css = from_style_el '@media{p {display:none}}';
  my $rule = $css->css_rules->[0];
  my $old_rule = $rule->css_rules->[0];
  my $old_style = $old_rule->style;

  $rule->delete_rule (0);

  is $rule->css_rules->length, 0;
  is $old_rule->parent_rule, undef;
  is $old_rule->parent_style_sheet, undef;
  is $old_style->parent_rule, $old_rule;
  is $old_style->display, 'none';

  done $c;
} n => 5, name => 'delete_rule old rule';

test {
  my $c = shift;
  my $css = from_style_el '@media{p {display:none}}';
  my $rule = $css->css_rules->[0];
  my $rule_list = $rule->css_rules;
  is $rule_list->length, 1;

  my $result = $rule->insert_rule ('q{}', 1 + 2**32 + 2**32);
  is $result, 1;

  is $rule_list->length, 2;

  is $rule_list->[1]->selector_text, 'q';

  done $c;
} n => 4, name => 'insert_rule';

test {
  my $c = shift;
  my $css = from_style_el '@media{p {display:none}}';
  my $rule = $css->css_rules->[0];
  my $rule_list = $rule->css_rules;
  is $rule_list->length, 1;

  my $result = $rule->insert_rule ('@media{}', 1);
  is $result, 1;

  is $rule_list->length, 2;

  done $c;
} n => 3, name => 'insert_rule';

test {
  my $c = shift;
  my $css = from_style_el '@media{p {display:none}}';
  my $rule = $css->css_rules->[0];
  my $rule_list = $rule->css_rules;
  is $rule_list->length, 1;

  dies_here_ok {
    $rule->insert_rule ('@charset "a";', 0);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, '@charset is not allowed';

  is $rule_list->length, 1;

  done $c;
} n => 6, name => 'insert_rule not allowed';

test {
  my $c = shift;
  my $css = from_style_el '@media{p {display:none}}';
  my $rule = $css->css_rules->[0];
  my $rule_list = $rule->css_rules;
  is $rule_list->length, 1;

  dies_here_ok {
    $rule->insert_rule ('@import "a";', 0);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The specified rule cannot be inserted in this rule';

  is $rule_list->length, 1;

  done $c;
} n => 6, name => 'insert_rule not allowed';

test {
  my $c = shift;
  my $css = from_style_el '@media{p {display:none}}';
  my $rule = $css->css_rules->[0];
  my $rule_list = $rule->css_rules;
  is $rule_list->length, 1;

  dies_here_ok {
    $rule->insert_rule ('@namespace "a";', 0);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The specified rule cannot be inserted in this rule';

  is $rule_list->length, 1;

  done $c;
} n => 6, name => 'insert_rule not allowed';

test {
  my $c = shift;
  my $css = from_style_el '@media{}';
  my $rule = $css->css_rules->[0];
  my $rule_list = $rule->css_rules;
  is $rule_list->length, 0;

  dies_here_ok {
    $rule->insert_rule ('@namespace "a";', 0);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The specified rule cannot be inserted in this rule';

  is $rule_list->length, 0;

  done $c;
} n => 6, name => 'insert_rule not allowed';

test {
  my $c = shift;
  my $css = from_style_el '@media{p {display:none}}';
  my $rule = $css->css_rules->[0];
  my $rule_list = $rule->css_rules;
  is $rule_list->length, 1;

  $rule->insert_rule ('@media{', 0);

  is $rule_list->length, 2;

  done $c;
} n => 2, name => 'insert_rule incomplete';

test {
  my $c = shift;
  my $css = from_style_el '@media{p {display:none}}';
  my $rule = $css->css_rules->[0];
  my $rule_list = $rule->css_rules;
  is $rule_list->length, 1;

  dies_here_ok {
    $rule->insert_rule ('@namespaces "a";', 0);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The specified rule is invalid';

  is $rule_list->length, 1;

  done $c;
} n => 6, name => 'insert_rule unknown rule';

test {
  my $c = shift;
  my $css = from_style_el '@media{p {display:none}}';
  my $rule = $css->css_rules->[0];
  my $rule_list = $rule->css_rules;
  is $rule_list->length, 1;

  dies_here_ok {
    $rule->insert_rule ('p{}q{}', 0);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The specified rule is invalid';

  is $rule_list->length, 1;

  done $c;
} n => 6, name => 'insert_rule multiple rules';

test {
  my $c = shift;
  my $css = from_style_el '@media{p {display:none}}';
  my $rule = $css->css_rules->[0];
  my $rule_list = $rule->css_rules;
  is $rule_list->length, 1;

  dies_here_ok {
    $rule->insert_rule ('/**/', 0);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The specified rule is invalid';

  is $rule_list->length, 1;

  done $c;
} n => 6, name => 'insert_rule zero rule';

test {
  my $c = shift;
  my $css = from_style_el '@media{p {display:none}}';
  my $rule = $css->css_rules->[0];
  my $rule_list = $rule->css_rules;
  is $rule_list->length, 1;

  dies_here_ok {
    $rule->insert_rule ('p{}', 3);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'IndexSizeError';
  is $@->message, 'The specified rule index is invalid';

  is $rule_list->length, 1;

  done $c;
} n => 6, name => 'insert_rule bad index';

test {
  my $c = shift;
  my $css = from_style_el '@media{p{}}';
  my $rule = $css->css_rules->[0];
  my $rules = $rule->css_rules;
  is $rules->length, 1;

  $rule->insert_rule ('q{}', 1);
  is $rules->length, 2;

  $rule->delete_rule (0);

  is $rules->length, 1;

  done $c;
} n => 3, name => 'css_rules mutation';

test {
  my $c = shift;
  my $css = from_style_el '@media PRINT { p{} }';
  my $rule = $css->css_rules->[0];
  
  is $rule->css_text, '@media print { p { } }';

  done $c;
} n => 1, name => 'css_text getter';

test {
  my $c = shift;
  my $css = from_style_el '@namespace hoge "http://hoge/";@media{}';
  $css->css_rules->[1]->insert_rule ('hoge|p {} ', 0);
  is $css->css_rules->[1]->css_rules->[0]->selector_text, 'hoge|p';
  done $c;
} n => 1, name => 'insert_rule namespace';

test {
  my $c = shift;
  my $css = from_style_el '@namespace hoge "http://hoge/";@media{}';
  dies_here_ok {
    $css->css_rules->[1]->insert_rule ('HOGE|p {} ', 0);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $css->css_rules->[1]->css_rules->length, 0;
  done $c;
} n => 4, name => 'insert_rule namespace';

test {
  my $c = shift;
  my $css = from_style_el '@namespace hoge "http://hoge/";@media{}';
  my $rule = $css->css_rules->[1];
  $css->delete_rule (1);
  dies_here_ok {
    $rule->insert_rule ('hoge|p {} ', 0);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $rule->css_rules->length, 0;

  $rule->insert_rule ('p{}', 0);
  is $rule->css_rules->length, 1;

  done $c;
} n => 5, name => 'insert_rule namespace deleted';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
