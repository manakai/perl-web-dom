use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->parent->parent->child ('t_deps/modules/*/lib')->stringify;
use lib glob path (__FILE__)->parent->parent->parent->child ('t_deps/lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

{
  package test::DestroyCallback;
  sub DESTROY {
    $_[0]->();
  }
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hh');

  my $tokens = $el->class_list;

  push @$tokens, 'hoge', 'fuga';
  is_deeply [@$tokens], ['hoge', 'fuga'];

  is $el->get_attribute ('class'), 'hoge fuga';

  done $c;
} n => 2, name => '@{} push';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hh');
  $el->set_attribute (class => "\x0Ahoge\x09fuga\x0C");

  my $tokens = $el->class_list;

  is shift @$tokens, 'hoge';
  is_deeply [@$tokens], ['fuga'];

  is $el->get_attribute ('class'), 'fuga';

  done $c;
} n => 3, name => '@{} shift';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $called;
  $el->set_user_data (destroy => bless sub {
                        $called = 1;
                      }, 'test::DestroyCallback');

  my $tokens = $el->class_list;

  undef $el;
  undef $doc;
  ok not $called;

  undef $tokens;
  ok $called;
  
  done $c;
} n => 2, name => 'class_list destroy';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aa');
  my $tokens = $el->class_list;

  is scalar @$tokens, 0;
  dies_here_ok {
    $#$tokens = 3;
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The token cannot be the empty string';
  is scalar @$tokens, 0;

  unshift @$tokens, 'abc', 'cde', 'xgga';

  is $tokens->[0], 'abc';
  is $tokens->[1], 'cde';
  is $tokens->[2], 'xgga';
  is $tokens->[3], undef;
  is $tokens->[-1], 'xgga';
  $tokens->[-2] = 'abdedde';
  is $tokens->[1], 'abdedde';
  is $tokens->[1 + 2**32], 'abdedde';
  is $tokens->item (1), 'abdedde';
  is $tokens->item (1 + 2**32), 'abdedde';
  is $tokens->item (5), undef;
  is $tokens->item (-1), undef;
  dies_here_ok {
    $tokens->[1] = 'ab  ';
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The token cannot contain any ASCII white space character';

  is pop @$tokens, 'xgga';
  is scalar @$tokens, 2;
  is $tokens->length, 2;

  is $el->class_name, 'abc abdedde';

  dies_here_ok {
    $tokens->[8] = 'abc';
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The token cannot be the empty string';

  is $el->class_name, 'abc abdedde';

  done $c;
} n => 30, name => 'length, item, setter';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  my $tokens = $el->class_list;

  ok not $tokens->contains ('hoge');
  ok not $tokens->contains ('a');
  ok not $tokens->contains ("\x{5000}");
  ok not $tokens->contains ('0');

  for (undef, '') {
    ok ! $tokens->contains ($_);
  }

  for ('ho ge', "\x09", "fu\x0C") {
    ok ! $tokens->contains ($_);
  }

  done $c;
} n => 9, name => 'contains empty list';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->set_attribute (class => "hoge \x09 fuga \x0Cfaa hoge 0  aaa \x{5000}");
  my $tokens = $el->class_list;

  ok $tokens->contains ('hoge');
  ok not $tokens->contains ('a');
  ok $tokens->contains ("\x{5000}");
  ok $tokens->contains ('0');

  for (undef, '') {
    ok ! $tokens->contains ($_);
  }

  for ('ho ge', "\x09", "fu\x0C", 'hoge 0') {
    ok ! $tokens->contains ($_);
  }

  done $c;
} n => 10, name => 'contains not empty list';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  my $tokens = $el->class_list;

  ok ! $tokens->add ('hoge,', 'fuga');
  is_deeply [@{$tokens}], ['hoge,', 'fuga'];

  ok ! $tokens->add;
  is_deeply [@{$tokens}], ['hoge,', 'fuga'];

  ok ! $tokens->add ('abc');
  is_deeply [@{$tokens}], ['hoge,', 'fuga', 'abc'];
  is $el->class_name, 'hoge, fuga abc';

  dies_here_ok {
    $tokens->add ('');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The token cannot be the empty string';

  dies_here_ok {
    $tokens->add (' ');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The token cannot contain any ASCII white space character';

  is $el->get_attribute ('class'), 'hoge, fuga abc';
  is_deeply [@{$tokens}], ['hoge,', 'fuga', 'abc'];

  done $c;
} n => 17, name => 'add';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  my $tokens = $el->class_list;

  $tokens->add ('hoge,', 'fuga');
  is_deeply [@{$tokens}], ['hoge,', 'fuga'];

  dies_here_ok {
    $tokens->add ('xx', '');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The token cannot be the empty string';

  is $el->get_attribute ('class'), 'hoge, fuga';
  is_deeply [@{$tokens}], ['hoge,', 'fuga'];

  done $c;
} n => 7, name => 'add';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  my $tokens = $el->class_list;

  $tokens->add ('hoge,', 'fuga');
  is_deeply [@{$tokens}], ['hoge,', 'fuga'];

  dies_here_ok {
    $tokens->add (' ', '');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The token cannot contain any ASCII white space character';

  is $el->get_attribute ('class'), 'hoge, fuga';
  is_deeply [@{$tokens}], ['hoge,', 'fuga'];

  done $c;
} n => 7, name => 'add';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'f');
  my $tokens = $el->class_list;
  $tokens->add ('foo');
  ok ! $tokens->add ('foo');
  is scalar @$tokens, 1;
  is $el->class_name, 'foo';
  push @$tokens, 'foo';
  is scalar @$tokens, 1;
  is $el->class_name, 'foo';
  $tokens->add ('bar', 'bar');
  is scalar @$tokens, 2;
  is $el->class_name, 'foo bar';
  push @$tokens, 'baz', 'baz';
  is scalar @$tokens, 3;
  is $el->class_name, 'foo bar baz';
  done $c;
} n => 9, name => 'add unique';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'link');
  my $tokens = $el->rel_list;
  ok ! $tokens->add ('foo');
  ok ! $tokens->add ('foo');
  is scalar @$tokens, 1;
  is $el->rel, 'foo';
  is ''.$tokens, 'foo';
  ok ! $tokens->add ('bar', 'bar');
  is scalar @$tokens, 2;
  is $el->rel, 'foo bar';
  ok ! $tokens->add ('bar', 'bar');
  done $c;
} n => 9, name => 'add unique supportedness';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'td');
  my $tokens = $el->itemprop;
  $tokens->add ('foo');
  ok ! $tokens->add ('foo');
  is scalar @$tokens, 1;
  is $el->get_attribute ('itemprop'), 'foo';
  push @$tokens, 'foo';
  is scalar @$tokens, 1;
  is $el->get_attribute ('itemprop'), 'foo';
  $tokens->add ('bar', 'bar');
  is scalar @$tokens, 2;
  is $el->get_attribute ('itemprop'), 'foo bar';
  push @$tokens, 'baz', 'baz';
  is scalar @$tokens, 3;
  is $el->get_attribute ('itemprop'), 'foo bar baz';
  done $c;
} n => 9, name => 'add unique DOMSettableTokenList';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hhe');
  my $tokens = $el->class_list;
  $el->set_attribute (class => 'abc def   aa abc Def');

  $tokens->remove ('abc');
  is $el->get_attribute ('class'), 'def aa Def';

  $tokens->remove ('aa', 'hoge');
  is $el->class_name, 'def Def';

  $tokens->add ('f');
  is $el->class_name, 'def Def f';

  $tokens->remove;
  is $el->class_name, 'def Def f';

  $tokens->remove ('Def');
  is $el->class_name, 'def f';

  done $c;
} n => 5, name => 'remove';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->class_name ('ho eafe');
  my $tokens = $el->class_list;

  dies_here_ok {
    $tokens->remove ('');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The token cannot be the empty string';

  dies_here_ok {
    $tokens->remove ('ho eafe');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The token cannot contain any ASCII white space character';

  done $c;
} n => 8, name => 'remove error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->class_name ('ho eafe');
  my $tokens = $el->class_list;

  dies_here_ok {
    $tokens->remove ('ho', '');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The token cannot be the empty string';

  is $el->get_attribute ('class'), 'ho eafe';
  is_deeply [@{$tokens}], ['ho', 'eafe'];

  done $c;
} n => 6, name => 'remove error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->class_name ('ho eafe');
  my $tokens = $el->class_list;

  dies_here_ok {
    $tokens->remove ('ho', ' ', '');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The token cannot contain any ASCII white space character';

  is $el->get_attribute ('class'), 'ho eafe';
  is_deeply [@{$tokens}], ['ho', 'eafe'];

  done $c;
} n => 6, name => 'remove error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->class_name ('ho eafe');
  my $tokens = $el->class_list;

  dies_here_ok {
    $tokens->toggle ('');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The token cannot be the empty string';

  dies_here_ok {
    $tokens->toggle ('ho eafe');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The token cannot contain any ASCII white space character';

  done $c;
} n => 8, name => 'toggle error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  my $tokens = $el->class_list;

  ok $tokens->toggle ('hoge');
  is $el->class_name, 'hoge';

  ok $tokens->toggle ('fuga');
  is $el->class_name, 'hoge fuga';

  ok not $tokens->toggle ('hoge');
  is $el->class_name, 'fuga';

  ok $tokens->toggle ('hoge');
  is $el->class_name, 'fuga hoge';

  ok $tokens->toggle ('hoge', 1);
  is $el->class_name, 'fuga hoge';

  ok not $tokens->toggle ('hoge', 0);
  is $el->class_name, 'fuga';

  ok $tokens->toggle ('hoge', 1);
  is $el->class_name, 'fuga hoge';

  ok not $tokens->toggle ('hoge2', 0);
  is $el->class_name, 'fuga hoge';

  done $c;
} n => 16, name => 'toggle';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'area');
  my $tokens = $el->rel_list;

  ok $tokens->toggle ('hoge');
  is $el->rel, 'hoge';

  ok $tokens->toggle ('fuga');
  is $el->rel, 'hoge fuga';

  ok not $tokens->toggle ('hoge');
  is $el->rel, 'fuga';

  ok $tokens->toggle ('hoge');
  is $el->rel, 'fuga hoge';

  ok $tokens->toggle ('hoge', 1);
  is $el->rel, 'fuga hoge';

  ok not $tokens->toggle ('hoge', 0);
  is $el->rel, 'fuga';

  ok $tokens->toggle ('hoge', 1);
  is $el->rel, 'fuga hoge';

  ok not $tokens->toggle ('hoge2', 0);
  is $el->rel, 'fuga hoge';

  done $c;
} n => 16, name => 'toggle supportedness';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b7ff');
  my $tokens = $el->class_list;
  is ''.$tokens, '';
  is 0+$tokens, 0;
  ok !!$tokens;

  push @$tokens, 'hoge', '12', '&';
  is ''.$tokens, 'hoge 12 &';
  ok !!$tokens;

  @$tokens = ('0');
  is ''.$tokens, '0';
  is 0+$tokens, 0;
  ok !!$tokens;

  @$tokens = ('120.4a');
  is ''.$tokens, '120.4a';
  is 0+$tokens, 120.4;
  ok !!$tokens;

  done $c;
} n => 11, name => 'stringifier';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'b7ff');
  $el->set_attribute (class => '  abc    def h');

  my $tokens = $el->class_list;
  is ''.$tokens, '  abc    def h';

  push @$tokens, 'hoge';
  is ''.$tokens, 'abc def h hoge';

  $el->set_attribute (class => '  abc    def h hoge ');
  is ''.$tokens, '  abc    def h hoge ';

  done $c;
} n => 3, name => 'stringifier';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  my $tokens = $el->class_list;
  is $el->class_list, $tokens;
  push @$tokens, 'hoge';
  is $el->class_list, $tokens;

  my $el2 = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fuga');
  isnt $el2->class_list, $tokens;
  push @$tokens, 'hoge';
  isnt $el2->class_list, $tokens;

  my $tokens2 = $el2->class_list;

  ok $tokens eq $tokens;
  ok not $tokens ne $tokens;
  is $tokens cmp $tokens, 0;
  ok not $tokens eq undef;
  ok not undef eq $tokens;
  ok $tokens ne undef;
  ok undef ne $tokens;
  ok $tokens ne ''.$tokens;
  ok not $tokens eq ''.$tokens;
  
  ok not $tokens eq $tokens2;
  ok not $tokens2 eq $tokens;
  ok $tokens ne $tokens2;
  ok $tokens2 ne $tokens;
  isnt $tokens cmp $tokens2, 0;
  isnt $tokens2 cmp $tokens, 0;

  my $tokens_s = ''.$tokens;
  undef $tokens;
  isnt $el->class_list, $tokens_s;
  is ''.$el->class_list, $tokens_s;

  done $c;
} n => 21, name => 'cmp';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  my $tokens = $el->class_list;
  ok ! $tokens->replace ('hoge', 'fuga');
  is ''.$tokens, '';
  is $el->get_attribute ('class'), undef;
  done $c;
} n => 3, name => 'replace no attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->set_attribute (class => 'ab  hoge ss xs  ');
  my $tokens = $el->class_list;
  ok $tokens->replace ('hoge', 'fuga');
  is ''.$tokens, 'ab fuga ss xs';
  is $el->get_attribute ('class'), 'ab fuga ss xs';
  done $c;
} n => 3, name => 'replace a value found';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->set_attribute (class => 'ab  hoge ss xs hoge  ');
  my $tokens = $el->class_list;
  ok $tokens->replace ('hoge', 'fuga');
  is ''.$tokens, 'ab fuga ss xs';
  is $el->get_attribute ('class'), 'ab fuga ss xs';
  done $c;
} n => 3, name => 'replace multiple value found';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->set_attribute (class => 'ab  hoge ss xs Hoge   ');
  my $tokens = $el->class_list;
  ok $tokens->replace ('hoge', 'fuga');
  is ''.$tokens, 'ab fuga ss xs Hoge';
  is $el->get_attribute ('class'), 'ab fuga ss xs Hoge';
  done $c;
} n => 3, name => 'replace a value found, case sensitive';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->set_attribute (class => 'ab  hogE ss xs hoge  ');
  my $tokens = $el->class_list;
  ok $tokens->replace ('hogE', 'fuga');
  is ''.$tokens, 'ab fuga ss xs hoge';
  is $el->get_attribute ('class'), 'ab fuga ss xs hoge';
  done $c;
} n => 3, name => 'replace a value found, case-sensitive';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->set_attribute (class => 'ab  hoge ss xs fuga ');
  my $tokens = $el->class_list;
  ok $tokens->replace ('hoge', 'fuga');
  is ''.$tokens, 'ab fuga ss xs';
  is $el->get_attribute ('class'), 'ab fuga ss xs';
  done $c;
} n => 3, name => 'replace a value found, duplicate';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->set_attribute (class => 'ab  hoge ss xs  ');
  my $tokens = $el->class_list;
  dies_here_ok {
    $tokens->replace ('', 'fuga');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The token cannot be the empty string';
  is ''.$tokens, 'ab  hoge ss xs  ';
  is $el->get_attribute ('class'), 'ab  hoge ss xs  ';
  done $c;
} n => 6, name => 'replace bad old value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->set_attribute (class => 'ab  hoge ss xs  ');
  my $tokens = $el->class_list;
  dies_here_ok {
    $tokens->replace ('hoge', '');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The token cannot be the empty string';
  is ''.$tokens, 'ab  hoge ss xs  ';
  is $el->get_attribute ('class'), 'ab  hoge ss xs  ';
  done $c;
} n => 6, name => 'replace bad new value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->set_attribute (class => 'ab  hoge ss xs  ');
  my $tokens = $el->class_list;
  dies_here_ok {
    $tokens->replace (' ', '');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The token cannot be the empty string';
  is ''.$tokens, 'ab  hoge ss xs  ';
  is $el->get_attribute ('class'), 'ab  hoge ss xs  ';
  done $c;
} n => 6, name => 'replace bad new value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->set_attribute (class => 'ab  hoge ss xs  ');
  my $tokens = $el->class_list;
  dies_here_ok {
    $tokens->replace (' ', 'fuga');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The token cannot contain any ASCII white space character';
  is ''.$tokens, 'ab  hoge ss xs  ';
  is $el->get_attribute ('class'), 'ab  hoge ss xs  ';
  done $c;
} n => 6, name => 'replace bad old value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->set_attribute (class => 'ab  hoge ss xs  ');
  my $tokens = $el->class_list;
  dies_here_ok {
    $tokens->replace ('hoge', ' ');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The token cannot contain any ASCII white space character';
  is ''.$tokens, 'ab  hoge ss xs  ';
  is $el->get_attribute ('class'), 'ab  hoge ss xs  ';
  done $c;
} n => 6, name => 'replace bad new value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  $el->set_attribute (rel => 'ab  hoge ss xs Hoge   ');
  my $tokens = $el->rel_list;
  ok $tokens->replace ('hoge', 'fuga');
  is ''.$tokens, 'ab fuga ss xs Hoge';
  is $el->get_attribute ('rel'), 'ab fuga ss xs Hoge';
  done $c;
} n => 3, name => 'replace new unknown';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $tokens = $el->class_list;
  dies_here_ok {
    $tokens->supports ('canonical');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'Any token is supported';
  dies_here_ok {
    $tokens->supports ('tag');
  };
  dies_here_ok {
    $tokens->supports ('hoge');
  };
  dies_here_ok {
    $tokens->supports ('');
  };
  done $c;
} n => 6, name => 'supports';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'a');
  my $tokens = $el->rel_list;
  ok ! $tokens->supports ('canonical');
  ok ! $tokens->supports ('tag');
  ok ! $tokens->supports ('Tag');
  ok ! $tokens->supports ('hoge');
  ok ! $tokens->supports ('');
  done $c;
} n => 5, name => 'supports';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'iframe');
  my $tokens = $el->sandbox;
  ok ! $tokens->supports ('');
  ok ! $tokens->supports ('allow-plugins');
  ok ! $tokens->supports ('Allow-Plugins');
  ok ! $tokens->supports ('hoge');
  done $c;
} n => 4, name => 'supports';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'iframe');
  my $tokens = $el->dropzone;
  ok ! $tokens->supports ('');
  ok ! $tokens->supports ('allow-plugins');
  ok ! $tokens->supports ('Allow-Plugins');
  ok ! $tokens->supports ('hoge');
  done $c;
} n => 4, name => 'supports dropzone';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'td');
  my $list = $el->itemprop;
  is $list->value, '';
  
  $list->value (' ');
  is $list->value, '';
  is scalar @$list, 0;
  
  $list->value ("\x0c\x0D\x0a\x20\x09def abc abc def");
  is $list->value, 'def abc';
  is scalar @$list, 2;
  is $el->get_attribute ('itemprop'), 'def abc';

  $list->value ("bbb cddd");
  is $list->value, 'bbb cddd';
  is scalar @$list, 2;
  is $el->get_attribute ('itemprop'), 'bbb cddd';

  $list->value ("");
  is $list->value, '';
  is scalar @$list, 0;
  is $el->get_attribute ('itemprop'), '';

  done $c;
} n => 12, name => 'value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'td');
  my $tokens = $el->itemprop;
  $el->set_attribute (itemprop => '  abc    def h');

  is ''.$tokens, '  abc    def h';
  is $tokens->value, '  abc    def h';

  push @$tokens, 'hoge';
  is ''.$tokens, 'abc def h hoge';
  is $tokens->value, 'abc def h hoge';

  $el->set_attribute (itemprop => '  abc    def h hoge ');
  is ''.$tokens, '  abc    def h hoge ';
  is $tokens->value, '  abc    def h hoge ';

  done $c;
} n => 6, name => 'stringifier';

run_tests;

=head1 LICENSE

Copyright 2013-2018 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
