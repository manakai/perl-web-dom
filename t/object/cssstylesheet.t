use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::Differences;
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
  is $css->owner_rule, undef;
  is $css->owner_node, $css->owner_node;
  is $css->owner_node->local_name, 'style';
  is $css->owner_node->text_content, 'p {}';
  is $css->manakai_base_uri, 'about:blank';
  is $css->manakai_input_encoding, 'utf-8';
  ok not $css->disabled;

  done $c;
} n => 9, name => '<style> attributes';

test {
  my $c = shift;
  my $css = from_style_el 'p{}', base_url => 'http://hoge.FOO/';
  is $css->manakai_base_uri, 'http://hoge.foo/';
  done $c;
} n => 1, name => 'base URL';

test {
  my $c = shift;
  my $css = from_style_el 'p{}', base_url => 'http://hoge.FOO/';
  $css->owner_node->set_attribute_ns ('http://www.w3.org/XML/1998/namespace', 'xml:base' => 'http://fpoobar/');
  is $css->manakai_base_uri, 'http://hoge.foo/';
  done $c;
} n => 1, name => 'base URL changed';

test {
  my $c = shift;
  my $css = from_style_el 'p {}';

  is $css->title, undef;

  $css->owner_node->title ('');
  is $css->title, undef;

  $css->owner_node->title ('abc');
  is $css->title, undef;

  done $c;
} n => 3, name => '<style> no title';

test {
  my $c = shift;
  my $css = from_style_el 'p {}', title => 'aaa';

  is $css->title, 'aaa';

  $css->owner_node->title ('');
  is $css->title, 'aaa';

  $css->owner_node->title ('abc');
  is $css->title, 'aaa';

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

test {
  my $c = shift;
  my $css = from_style_el '', media => 'hoge, (), screEn';
  my $media = $css->media;
  isa_ok $media, 'Web::DOM::MediaList';
  is $media->media_text, 'hoge, not all, screen';
  $media->media_text ('scree\n, All');
  is $media->media_text, 'screen, all';
  is $css->owner_node->media, 'hoge, (), screEn';
  done $c;
} n => 4, name => 'media specified';

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
  my $css = from_style_el 'p{}q{}';
  
  dies_here_ok {
    $css->delete_rule (3);
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

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}';
  
  $css->insert_rule ('r{}', 2);

  is $css->css_rules->length, 3;
  is $css->css_rules->[0]->selector_text, 'p';
  is $css->css_rules->[1]->selector_text, 'q';
  is $css->css_rules->[2]->selector_text, 'r';

  my $rule = $css->css_rules->[2];
  is $rule->parent_style_sheet, $css;
  is $rule->parent_rule, undef;
  is $rule->style->length, 0;

  done $c;
} n => 7, name => 'insert_rule';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}';
  
  $css->insert_rule ('@media{r{display:block}}', 2);

  is $css->css_rules->length, 3;
  is $css->css_rules->[0]->selector_text, 'p';
  is $css->css_rules->[1]->selector_text, 'q';
  is $css->css_rules->[2]->type, 4;

  my $rule = $css->css_rules->[2];
  is $rule->parent_style_sheet, $css;
  is $rule->parent_rule, undef;
  is $rule->css_rules->length, 1;
  is $rule->css_rules->[0]->selector_text, 'r';
  is $rule->css_rules->[0]->style->length, 1;
  is $rule->css_rules->[0]->style->display, 'block';

  done $c;
} n => 10, name => 'insert_rule nested';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}';
  
  my $return = $css->insert_rule ('r{}', 1 + 2**32);
  is $return, 1;

  is $css->css_rules->length, 3;
  is $css->css_rules->[0]->selector_text, 'p';
  is $css->css_rules->[1]->selector_text, 'r';
  is $css->css_rules->[2]->selector_text, 'q';

  done $c;
} n => 5, name => 'insert_rule return';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}';
  
  my $return = $css->insert_rule ('r{}', 2**32);
  is $return, 0;

  is $css->css_rules->length, 3;
  is $css->css_rules->[0]->selector_text, 'r';
  is $css->css_rules->[1]->selector_text, 'p';
  is $css->css_rules->[2]->selector_text, 'q';

  done $c;
} n => 5, name => 'insert_rule return 0';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}';
  
  dies_here_ok {
    $css->insert_rule ('r{}', 3);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'IndexSizeError';
  is $@->message, 'The specified rule index is invalid';

  is $css->css_rules->length, 2;
  is $css->css_rules->[0]->selector_text, 'p';
  is $css->css_rules->[1]->selector_text, 'q';

  done $c;
} n => 7, name => 'insert_rule size error';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}';
  
  dies_here_ok {
    $css->insert_rule ('r{}', -1);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'IndexSizeError';
  is $@->message, 'The specified rule index is invalid';

  is $css->css_rules->length, 2;
  is $css->css_rules->[0]->selector_text, 'p';
  is $css->css_rules->[1]->selector_text, 'q';

  done $c;
} n => 7, name => 'insert_rule size error';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}';
  
  dies_here_ok {
    $css->insert_rule ('@hoge{}', 1);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The specified rule is invalid';

  is $css->css_rules->length, 2;
  is $css->css_rules->[0]->selector_text, 'p';
  is $css->css_rules->[1]->selector_text, 'q';

  done $c;
} n => 7, name => 'insert_rule unknown rule';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}';
  
  dies_here_ok {
    $css->insert_rule ('r{}s{}', 1);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The specified rule is invalid';

  is $css->css_rules->length, 2;
  is $css->css_rules->[0]->selector_text, 'p';
  is $css->css_rules->[1]->selector_text, 'q';

  done $c;
} n => 7, name => 'insert_rule multiple rules';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}';
  
  dies_here_ok {
    $css->insert_rule ('  ', 1);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The specified rule is invalid';

  is $css->css_rules->length, 2;
  is $css->css_rules->[0]->selector_text, 'p';
  is $css->css_rules->[1]->selector_text, 'q';

  done $c;
} n => 7, name => 'insert_rule zero rule';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}';
  
  $css->insert_rule ('r{disp', 1);

  is $css->css_rules->length, 3;
  is $css->css_rules->[0]->selector_text, 'p';
  is $css->css_rules->[1]->selector_text, 'r';
  is $css->css_rules->[2]->selector_text, 'q';

  done $c;
} n => 4, name => 'insert_rule partially broken';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}';
  
  dies_here_ok {
    $css->insert_rule ('@charset "UTF-8";', 0);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, '@charset is not allowed';

  is $css->css_rules->length, 2;
  is $css->css_rules->[0]->selector_text, 'p';
  is $css->css_rules->[1]->selector_text, 'q';

  done $c;
} n => 7, name => 'insert_rule @charset';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}';
  
  $css->insert_rule ('@import "a";', 0);

  is $css->css_rules->length, 3;
  is $css->css_rules->[0]->href, 'a';
  is $css->css_rules->[1]->selector_text, 'p';
  is $css->css_rules->[2]->selector_text, 'q';

  done $c;
} n => 4, name => 'insert_rule @import ok';

test {
  my $c = shift;
  my $css = from_style_el '@charset "b";q{}';
  
  $css->insert_rule ('@import "a";', 1);

  is $css->css_rules->length, 3;
  is $css->css_rules->[0]->encoding, 'b';
  is $css->css_rules->[1]->href, 'a';
  is $css->css_rules->[2]->selector_text, 'q';

  done $c;
} n => 4, name => 'insert_rule @import ok';

test {
  my $c = shift;
  my $css = from_style_el 'p{}q{}';
  
  dies_here_ok {
    $css->insert_rule ('@import "a";', 1);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The specified rule cannot be inserted at the specified index';

  is $css->css_rules->length, 2;
  is $css->css_rules->[0]->selector_text, 'p';
  is $css->css_rules->[1]->selector_text, 'q';

  done $c;
} n => 7, name => 'insert_rule @import not ok';

for my $test (
  ['@namespace "b";q{}' => '@import "a";', 1 => 0],
  ['@media{}q{}'        => '@import "a";', 1 => 0],
  ['@charset "a";'      => '@import "b";', 0 => 0],
  ['@charset "a";'      => '@import "b";', 1 => 1],
  ['@charset "a";@import "b";@import "c";@namespace "d";p{}'
                        => '@import "e";', 0 => 0],
  ['@charset "a";@import "b";@import "c";@namespace "d";p{}'
                        => '@import "e";', 1 => 1],
  ['@charset "a";@import "b";@import "c";@namespace "d";p{}'
                        => '@import "e";', 2 => 1],
  ['@charset "a";@import "b";@import "c";@namespace "d";p{}'
                        => '@import "e";', 3 => 1],
  ['@charset "a";@import "b";@import "c";@namespace "d";p{}'
                        => '@import "e";', 4 => 0],
  ['@charset "a";@import "b";@import "c";@namespace "d";p{}'
                        => '@import "e";', 5 => 0],
  ['@charset "a";@import "b";@import "c";@namespace "d";'
                        => '@namespace "e";', 0 => 0],
  ['@charset "a";@import "b";@import "c";@namespace "d";'
                        => '@namespace "e";', 1 => 0],
  ['@charset "a";@import "b";@import "c";@namespace "d";'
                        => '@namespace "e";', 2 => 0],
  ['@charset "a";@import "b";@import "c";@namespace "d";'
                        => '@namespace "e";', 3 => 1],
  ['@charset "a";@import "b";@import "c";@namespace "d";'
                        => '@namespace "e";', 4 => 1],
  ['@namespace "a";'    => '@namespace "a";', 1 => 1],
  ['@namespace x "a";'  => '@namespace x "a";', 1 => 1],
) {
  if ($test->[3]) {
    test {
      my $c = shift;
      my $css = from_style_el $test->[0];
      my $length = $css->css_rules->length;

      $css->insert_rule ($test->[1], $test->[2]);

      is $css->css_rules->length, $length + 1;

      done $c;
    } n => 1, name => ['insert_rule @import', $test->[0], $test->[1], $test->[2], 'ok'];
  } else {
    test {
      my $c = shift;
      my $css = from_style_el $test->[0];
      my $length = $css->css_rules->length;

      dies_here_ok {
        $css->insert_rule ($test->[1], $test->[2]);
      };
      isa_ok $@, 'Web::DOM::Exception';
      is $@->name, 'HierarchyRequestError';
      is $@->message, 'The specified rule cannot be inserted at the specified index';

      is $css->css_rules->length, $length;

      done $c;
    } n => 5, name => ['insert_rule @import', $test->[0], $test->[1], $test->[2], 'ng'];
  }
}

test {
  my $c = shift;
  my $css = from_style_el 'p{}';
  
  dies_here_ok {
    $css->insert_rule ('@namespace x "y";', 0);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidStateError';
  is $@->message, '@namespace cannot be inserted to this style sheet';

  is $css->css_rules->length, 1;

  done $c;
} n => 5, name => 'insert_rule @namespace not allowed';

test {
  my $c = shift;
  my $css = from_style_el 'p{}';
  my $rules = $css->css_rules;
  is $rules->length, 1;

  $css->insert_rule ('q{}', 1);

  is $rules->length, 2;

  $css->delete_rule (0);

  is $rules->length, 1;

  done $c;
} n => 3, name => 'css_rules mutation';

test {
  my $c = shift;
  my $css = from_style_el '';
  my $rules = $css->css_rules;

  ok not $css->manakai_is_default_namespace (undef);
  ok not $css->manakai_is_default_namespace ('');
  ok not $css->manakai_is_default_namespace ('http://hoge/');

  done $c;
} n => 3, name => 'manakai_is_default_namespace no decls';

test {
  my $c = shift;
  my $css = from_style_el '@namespace "";';
  my $rules = $css->css_rules;

  ok $css->manakai_is_default_namespace (undef);
  ok $css->manakai_is_default_namespace ('');
  ok not $css->manakai_is_default_namespace ('http://hoge/');

  done $c;
} n => 3, name => 'manakai_is_default_namespace default = null';

test {
  my $c = shift;
  my $css = from_style_el '@namespace "http://hoge/";';
  my $rules = $css->css_rules;

  ok not $css->manakai_is_default_namespace (undef);
  ok not $css->manakai_is_default_namespace ('');
  ok $css->manakai_is_default_namespace ('http://hoge/');
  ok not $css->manakai_is_default_namespace ('http://fuga/');

  done $c;
} n => 4, name => 'manakai_is_default_namespace default = non null';

test {
  my $c = shift;
  my $css = from_style_el '@namespace aa "http://hoge/";';
  my $rules = $css->css_rules;

  ok not $css->manakai_is_default_namespace (undef);
  ok not $css->manakai_is_default_namespace ('');
  ok not $css->manakai_is_default_namespace ('http://hoge/');
  ok not $css->manakai_is_default_namespace ('http://fuga/');

  done $c;
} n => 4, name => 'manakai_is_default_namespace';

test {
  my $c = shift;
  my $css = from_style_el '@namespace aa "";';
  my $rules = $css->css_rules;

  ok not $css->manakai_is_default_namespace (undef);
  ok not $css->manakai_is_default_namespace ('');
  ok not $css->manakai_is_default_namespace ('http://hoge/');
  ok not $css->manakai_is_default_namespace ('http://fuga/');

  done $c;
} n => 4, name => 'manakai_is_default_namespace';

test {
  my $c = shift;
  my $css = from_style_el '@namespace "";@namespace "http://hoge/"';
  my $rules = $css->css_rules;

  ok not $css->manakai_is_default_namespace (undef);
  ok not $css->manakai_is_default_namespace ('');
  ok $css->manakai_is_default_namespace ('http://hoge/');
  ok not $css->manakai_is_default_namespace ('http://fuga/');

  done $c;
} n => 4, name => 'manakai_is_default_namespace';

test {
  my $c = shift;
  my $css = from_style_el '@namespace "http://hoge/";@namespace "";';
  my $rules = $css->css_rules;

  ok $css->manakai_is_default_namespace (undef);
  ok $css->manakai_is_default_namespace ('');
  ok not $css->manakai_is_default_namespace ('http://hoge/');
  ok not $css->manakai_is_default_namespace ('http://fuga/');

  done $c;
} n => 4, name => 'manakai_is_default_namespace';

test {
  my $c = shift;
  my $css = from_style_el '';
  my $rules = $css->css_rules;

  ok not $css->manakai_is_default_namespace ('http://hoge/');
  ok not $css->manakai_is_default_namespace ('http://fuga/');

  $css->insert_rule ('@namespace "http://hoge/";', 0);
  ok $css->manakai_is_default_namespace ('http://hoge/');
  ok not $css->manakai_is_default_namespace ('http://fuga/');

  $css->insert_rule ('@namespace "http://fuga/";', 1);
  ok not $css->manakai_is_default_namespace ('http://hoge/');
  ok $css->manakai_is_default_namespace ('http://fuga/');

  $css->delete_rule (1);
  ok $css->manakai_is_default_namespace ('http://hoge/');
  ok not $css->manakai_is_default_namespace ('http://fuga/');

  done $c;
} n => 8, name => 'manakai_is_default_namespace mutation';

test {
  my $c = shift;
  my $css = from_style_el '';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_uri (undef), undef;
  is $css->manakai_lookup_namespace_uri (''), undef;
  is $css->manakai_lookup_namespace_uri ('hoge'), undef;

  done $c;
} n => 3, name => 'manakai_lookup_namespace_uri';

test {
  my $c = shift;
  my $css = from_style_el '@namespace "";';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_uri (undef), '';
  is $css->manakai_lookup_namespace_uri (''), '';
  is $css->manakai_lookup_namespace_uri ('hoge'), undef;

  done $c;
} n => 3, name => 'manakai_lookup_namespace_uri';

test {
  my $c = shift;
  my $css = from_style_el '@namespace "aa";';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_uri (undef), 'aa';
  is $css->manakai_lookup_namespace_uri (''), 'aa';
  is $css->manakai_lookup_namespace_uri ('hoge'), undef;

  done $c;
} n => 3, name => 'manakai_lookup_namespace_uri';

test {
  my $c = shift;
  my $css = from_style_el '@namespace hoge "";';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_uri (undef), undef;
  is $css->manakai_lookup_namespace_uri (''), undef;
  is $css->manakai_lookup_namespace_uri ('hoge'), '';
  is $css->manakai_lookup_namespace_uri ('fuga'), undef;

  done $c;
} n => 4, name => 'manakai_lookup_namespace_uri';

test {
  my $c = shift;
  my $css = from_style_el '@namespace hoge "aa";';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_uri (undef), undef;
  is $css->manakai_lookup_namespace_uri (''), undef;
  is $css->manakai_lookup_namespace_uri ('hoge'), 'aa';
  is $css->manakai_lookup_namespace_uri ('fuga'), undef;

  done $c;
} n => 4, name => 'manakai_lookup_namespace_uri';

test {
  my $c = shift;
  my $css = from_style_el '@namespace  "aa";@namespace  "bb";';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_uri (undef), 'bb';
  is $css->manakai_lookup_namespace_uri (''), 'bb';
  is $css->manakai_lookup_namespace_uri ('hoge'), undef;
  is $css->manakai_lookup_namespace_uri ('fuga'), undef;

  done $c;
} n => 4, name => 'manakai_lookup_namespace_uri';

test {
  my $c = shift;
  my $css = from_style_el '@namespace hoge "aa";@namespace hoge "bb"';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_uri (undef), undef;
  is $css->manakai_lookup_namespace_uri (''), undef;
  is $css->manakai_lookup_namespace_uri ('hoge'), 'bb';
  is $css->manakai_lookup_namespace_uri ('fuga'), undef;

  done $c;
} n => 4, name => 'manakai_lookup_namespace_uri';

test {
  my $c = shift;
  my $css = from_style_el '';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_uri ('hoge'), undef;

  $css->insert_rule ('@namespace hoge "ab";', 0);
  is $css->manakai_lookup_namespace_uri ('hoge'), 'ab';

  $css->insert_rule ('@namespace hoge "cd";', 1);
  is $css->manakai_lookup_namespace_uri ('hoge'), 'cd';

  $css->insert_rule ('@namespace hoge "ef";', 1);
  is $css->manakai_lookup_namespace_uri ('hoge'), 'cd';

  $css->delete_rule (2);
  is $css->manakai_lookup_namespace_uri ('hoge'), 'ef';

  done $c;
} n => 5, name => 'manakai_lookup_namespace_uri';

test {
  my $c = shift;
  my $css = from_style_el '';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_prefix (undef), undef;
  is $css->manakai_lookup_namespace_prefix (''), undef;
  is $css->manakai_lookup_namespace_prefix ('hoge'), undef;
  is $css->manakai_lookup_namespace_prefix ('fuga'), undef;

  done $c;
} n => 4, name => 'manakai_lookup_namespace_prefix';

test {
  my $c = shift;
  my $css = from_style_el '@namespace "";';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_prefix (undef), undef;
  is $css->manakai_lookup_namespace_prefix (''), undef;
  is $css->manakai_lookup_namespace_prefix ('hoge'), undef;
  is $css->manakai_lookup_namespace_prefix ('fuga'), undef;

  done $c;
} n => 4, name => 'manakai_lookup_namespace_prefix';

test {
  my $c = shift;
  my $css = from_style_el '@namespace abc "";';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_prefix (undef), 'abc';
  is $css->manakai_lookup_namespace_prefix (''), 'abc';
  is $css->manakai_lookup_namespace_prefix ('hoge'), undef;
  is $css->manakai_lookup_namespace_prefix ('fuga'), undef;

  done $c;
} n => 4, name => 'manakai_lookup_namespace_prefix';

test {
  my $c = shift;
  my $css = from_style_el '@namespace "hoge";';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_prefix (undef), undef;
  is $css->manakai_lookup_namespace_prefix (''), undef;
  is $css->manakai_lookup_namespace_prefix ('hoge'), undef;
  is $css->manakai_lookup_namespace_prefix ('fuga'), undef;

  done $c;
} n => 4, name => 'manakai_lookup_namespace_prefix';

test {
  my $c = shift;
  my $css = from_style_el '@namespace abc "hoge";';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_prefix (undef), undef;
  is $css->manakai_lookup_namespace_prefix (''), undef;
  is $css->manakai_lookup_namespace_prefix ('hoge'), 'abc';
  is $css->manakai_lookup_namespace_prefix ('fuga'), undef;

  done $c;
} n => 4, name => 'manakai_lookup_namespace_prefix';

test {
  my $c = shift;
  my $css = from_style_el '@namespace abc "hoge";@namespace "hoge";';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_prefix (undef), undef;
  is $css->manakai_lookup_namespace_prefix (''), undef;
  is $css->manakai_lookup_namespace_prefix ('hoge'), 'abc';
  is $css->manakai_lookup_namespace_prefix ('fuga'), undef;

  done $c;
} n => 4, name => 'manakai_lookup_namespace_prefix';

test {
  my $c = shift;
  my $css = from_style_el '@namespace abc "hoge";@namespace d "hoge";';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_prefix (undef), undef;
  is $css->manakai_lookup_namespace_prefix (''), undef;
  is $css->manakai_lookup_namespace_prefix ('hoge'), 'd';
  is $css->manakai_lookup_namespace_prefix ('fuga'), undef;

  done $c;
} n => 4, name => 'manakai_lookup_namespace_prefix';

test {
  my $c = shift;
  my $css = from_style_el '@namespace abc "hoge";@namespace abc "fuga";';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_prefix (undef), undef;
  is $css->manakai_lookup_namespace_prefix (''), undef;
  is $css->manakai_lookup_namespace_prefix ('hoge'), undef;
  is $css->manakai_lookup_namespace_prefix ('fuga'), 'abc';

  done $c;
} n => 4, name => 'manakai_lookup_namespace_prefix';

test {
  my $c = shift;
  my $css = from_style_el '';
  my $rules = $css->css_rules;

  is $css->manakai_lookup_namespace_prefix (undef), undef;
  is $css->manakai_lookup_namespace_prefix (''), undef;
  is $css->manakai_lookup_namespace_prefix ('hoge'), undef;
  is $css->manakai_lookup_namespace_prefix ('fuga'), undef;

  $css->insert_rule ('@namespace abc "hoge";', 0);

  is $css->manakai_lookup_namespace_prefix (undef), undef;
  is $css->manakai_lookup_namespace_prefix (''), undef;
  is $css->manakai_lookup_namespace_prefix ('hoge'), 'abc';
  is $css->manakai_lookup_namespace_prefix ('fuga'), undef;

  $css->insert_rule ('@namespace abc "fuga";', 1);

  is $css->manakai_lookup_namespace_prefix (undef), undef;
  is $css->manakai_lookup_namespace_prefix (''), undef;
  is $css->manakai_lookup_namespace_prefix ('hoge'), undef;
  is $css->manakai_lookup_namespace_prefix ('fuga'), 'abc';

  $css->delete_rule (1);

  is $css->manakai_lookup_namespace_prefix (undef), undef;
  is $css->manakai_lookup_namespace_prefix (''), undef;
  is $css->manakai_lookup_namespace_prefix ('hoge'), 'abc';
  is $css->manakai_lookup_namespace_prefix ('fuga'), undef;

  done $c;
} n => 16, name => 'manakai_lookup_namespace_prefix mutation';

test {
  my $c = shift;
  my $css = from_style_el '';

  is $css->css_text, '';

  done $c;
} n => 1, name => 'css_text getter empty';

test {
  my $c = shift;
  my $css = from_style_el '@Charset"UTF-8";@namespace A\z "about:";p{} Q.a{display: BLOCK}@media ALL{:not(a){}}';

  eq_or_diff $css->css_text, join "\x0A",
      '@charset "UTF-8";',
      '@namespace Az url("about:");',
      'p { }',
      'Q.a { display: block; }',
      '@media all { ',
      '  :not(a) { }',
      '}';

  done $c;
} n => 1, name => 'css_text getter not empty';

test {
  my $c = shift;
  my $css = from_style_el '@namespace hoge "http://hoge/";';
  $css->insert_rule ('hoge|p {} ', 0);
  is $css->css_rules->[0]->selector_text, 'hoge|p';
  done $c;
} n => 1, name => 'insert_rule namespace';

test {
  my $c = shift;
  my $css = from_style_el '@namespace hoge "http://hoge/";';
  dies_here_ok {
    $css->insert_rule ('HOGE|p {} ', 0);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $css->css_rules->length, 1;
  done $c;
} n => 4, name => 'insert_rule namespace';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
