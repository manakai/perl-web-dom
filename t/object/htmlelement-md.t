use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');

  my $props = $el->manakai_get_properties;
  is ref $props, 'HASH';
  is scalar keys %$props, 0;
  dies_here_ok {
    $props->{hoge} = 124;
  };
  like $@, qr{^Modification of a read-only value attempted};
  dies_here_ok {
    delete $props->{hoge};
  };
  like $@, qr{^Modification of a read-only value attempted};
  ok not exists $props->{hoge};
  ok not defined $props->{hoge};
  done $c;
} n => 8, name => 'manakai_get_properties empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->set_attribute (itemscope => '');
  $el->set_attribute (itemprop => '');
  $el->inner_html (q{<p itemproP=a>?<p itemprop=b>});

  my $props = $el->manakai_get_properties;
  is ref $props, 'HASH';
  is scalar keys %$props, 2;
  is scalar @{$props->{a}}, 1;
  is scalar @{$props->{b}}, 1;
  is $props->{a}->[0], $el->first_child;
  is $props->{b}->[0], $el->last_child;
  dies_here_ok {
    $props->{a}->[1] = $el;
  };
  like $@, qr{^Modification of a read-only value attempted};
  is scalar @{$props->{a}}, 1;
  dies_here_ok {
    delete $props->{a};
  };
  like $@, qr{^Modification of a read-only value attempted};
  done $c;
} n => 11, name => 'manakai_get_properties not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $doc->append_child ($el);
  $el->inner_html (q{<p id=a itemprop=foo><p itemscope id=b itemref="a c"><br itemprop=foo><div id=c><br itemprop=foo></div>});
  my $el2 = $el->child_nodes->[1];
  my $props = $el2->manakai_get_properties;
  is scalar @{$props->{foo}}, 3;
  is $props->{foo}->[0], $el->first_child;
  is $props->{foo}->[1], $el2->first_child;
  is $props->{foo}->[2], $el->last_child->first_child;
  is $props->{foo}, $props->{foo};
  done $c;
} n => 5, name => 'manakai_get_properties multiple prop values';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $doc->append_child ($el);
  $el->inner_html (q{<p id=a itemprop=foo><p id=b itemref="a c"><br itemprop=foo><div id=c><br itemprop=foo></div>});
  my $el2 = $el->child_nodes->[1];
  my $props = $el2->manakai_get_properties;
  is scalar keys %$props, 0;
  done $c;
} n => 1, name => 'manakai_get_properties not item';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  is $el->itemvalue, undef;
  dies_here_ok {
    $el->itemvalue ('foo');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidAccessError';
  is $@->message, 'The element has no |itemprop| attribute';
  is $el->itemvalue, undef;
  done $c;
} n => 6, name => 'itemvalue not itemprop';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'hoge');
  $el->set_attribute (itemprop => '');
  $el->set_attribute (itemscope => '');
  is $el->itemvalue, $el;
  dies_here_ok {
    $el->itemvalue ('foo');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidAccessError';
  is $@->message, 'The value is an item';
  is $el->itemvalue, $el;
  done $c;
} n => 6, name => 'itemvalue itemscope';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'meta');
  $el->set_attribute (itemprop => '');
  is $el->itemvalue, '';
  $el->itemvalue ('hoge');
  is $el->get_attribute ('content'), 'hoge';
  is $el->itemvalue, 'hoge';
  done $c;
} n => 3, name => 'itemvalue <meta>';

for my $ln (qw(audio embed iframe img source track video)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->manakai_set_url ('http://hoge/f');
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $ln);
    $el->set_attribute (itemprop => '');
    is $el->itemvalue, '';
    $el->itemvalue ('ahoge');
    is $el->get_attribute ('src'), 'ahoge';
    is $el->itemvalue, 'http://hoge/ahoge';
    done $c;
  } n => 3, name => ['itemvalue', $ln];
}

for my $ln (qw(a area link)) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    $doc->manakai_set_url ('http://hoge/f');
    my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', $ln);
    $el->set_attribute (itemprop => '');
    is $el->itemvalue, '';
    $el->itemvalue ('ahoge');
    is $el->get_attribute ('href'), 'ahoge';
    is $el->itemvalue, 'http://hoge/ahoge';
    done $c;
  } n => 3, name => ['itemvalue', $ln];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://hoge/f');
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'object');
  $el->set_attribute (itemprop => '');
  is $el->itemvalue, '';
  $el->itemvalue ('ahoge');
  is $el->get_attribute ('data'), 'ahoge';
  is $el->itemvalue, 'http://hoge/ahoge';
  done $c;
} n => 3, name => ['itemvalue', 'object'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://hoge/f');
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'data');
  $el->set_attribute (itemprop => '');
  is $el->itemvalue, '';
  $el->itemvalue ('ahoge');
  is $el->get_attribute ('value'), 'ahoge';
  is $el->itemvalue, 'ahoge';
  done $c;
} n => 3, name => ['itemvalue', 'data'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://hoge/f');
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'meter');
  $el->set_attribute (itemprop => '');
  is $el->itemvalue, '';
  $el->itemvalue ('ahoge');
  is $el->get_attribute ('value'), 'ahoge';
  is $el->itemvalue, 'ahoge';
  done $c;
} n => 3, name => ['itemvalue', 'meter'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://hoge/f');
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'time');
  $el->set_attribute (itemprop => '');
  is $el->itemvalue, '';
  $el->inner_html (q{x<span>aa</span>y});
  is $el->itemvalue, 'xy';
  $el->itemvalue ('ahoge');
  is $el->get_attribute ('datetime'), 'ahoge';
  is $el->itemvalue, 'ahoge';
  is $el->text_content, 'xaay';
  done $c;
} n => 5, name => ['itemvalue', 'time'];

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_set_url ('http://hoge/f');
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'fuga');
  $el->set_attribute (itemprop => '');
  is $el->itemvalue, '';
  $el->inner_html (q{<span>aa</span>});
  is $el->itemvalue, 'aa';
  $el->itemvalue ('ahoge');
  is $el->itemvalue, 'ahoge';
  is $el->text_content, 'ahoge';
  done $c;
} n => 4, name => ['itemvalue', 'misc'];

run_tests;

=head1 LICENSE

Copyright 2014-2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
