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

test {
  my $c = shift;
  my $css = from_style_el 'p {}';
  my $style = $css->css_rules->[0]->style;
  
  is $style->length, 0;
  is $style->item (0), '';
  is $style->item (1), '';
  is $style->item (-12), '';
  is $style->item (2**31), '';
  is $style->item (2**32), '';

  is scalar @$style, 0;
  eq_or_diff [@$style], [];
  is $style->[0], undef;
  dies_here_ok {
    push @$style, '1';
  };
  like $@, qr{^Modification of a read-only value attempted};
  dies_here_ok {
    $style->[1] = 12;
  };
  like $@, qr{^Modification of a read-only value attempted};

  is $style->get_property_value ('display'), '';
  is $style->get_property_value ('position'), '';
  is $style->get_property_value ('hpge-fuga'), '';
  is $style->get_property_value ('display:'), '';

  is $style->get_property_priority ('display'), '';
  is $style->get_property_priority ('hoge'), '';
  is $style->get_property_priority ('display:'), '';

  is $style->parent_rule, $css->css_rules->[0];

  done $c;
} n => 21, name => 'style rule style empty';


test {
  my $c = shift;
  my $css = from_style_el 'p {poSition: absolUTe; displaY: bloCK!Important}';
  my $style = $css->css_rules->[0]->style;
  
  is $style->length, 2;
  is $style->item (0), 'position';
  is $style->item (1), 'display';
  is $style->item (2), '';
  is $style->item (-12), '';
  is $style->item (2**31), '';
  is $style->item (2**32), 'position';

  is $style->get_property_value ('displAy'), 'block';
  is $style->get_property_value ('positIOn'), 'absolute';
  is $style->get_property_value ('hpge-fuga'), '';
  is $style->get_property_value ('display:'), '';

  is $style->get_property_priority ('displAY'), 'important';
  is $style->get_property_priority ('PosiTion'), '';
  is $style->get_property_priority ('hoge'), '';
  is $style->get_property_priority ('display:'), '';

  is $style->parent_rule, $css->css_rules->[0];

  is scalar @$style, 2;
  eq_or_diff [@$style], ['position', 'display'];
  is $style->[0], 'position';
  dies_here_ok {
    push @$style, '1';
  };
  like $@, qr{^Modification of a read-only value attempted};
  dies_here_ok {
    $style->[1] = 12;
  };
  like $@, qr{^Modification of a read-only value attempted};

  done $c;
} n => 23, name => 'style rule style';

test {
  my $c = shift;
  my $css = from_style_el 'p {poSition: absolUTe; border-top-style:hidden}';
  my $style = $css->css_rules->[0]->style;

  is $style->[1], 'border-top-style';

  done $c;
} n => 1, name => 'key != prop';

test {
  my $c = shift;
  my $css = from_style_el 'p {} q{}';
  my $style1 = $css->css_rules->[0]->style;
  my $style2 = $css->css_rules->[1]->style;

  ok $style1;

  isnt $style1 cmp $style2, 0;
  is $style1 cmp $style1, 0;
  isnt $style1 cmp undef, 0;
  isnt undef cmp $style1, 0;

  ok $style1 eq $style1;
  ok not $style1 eq $style2;
  ok $style1 ne $style2;
  ok not $style1 ne $style1;

  done $c;
} n => 9, name => 'comparison';

test {
  my $c = shift;
  my $css = from_style_el 'p {poSition: absolUTe; border-top-style:hidden}';
  my $style = $css->css_rules->[0]->style;
  my $style_s = ''.$style;
  undef $style;

  is $css->css_rules->[0]->style . '', $style_s;

  done $c;
} n => 1, name => 'string comparison';

test {
  my $c = shift;
  my $css = from_style_el 'p {poSition: absolUTe; border-top-style:hidden}';
  my $style = $css->css_rules->[0]->style;

  $style->set_property ('DISplay' => 'InLiNE', '');
  is $style->get_property_value ('display'), 'inline';
  is $style->get_property_priority ('display'), '';
  is scalar @$style, 3;
  is $style->[2], 'display';

  done $c;
} n => 4, name => 'set_property normal';

test {
  my $c = shift;
  my $css = from_style_el 'p {poSition: absolUTe; border-top-style:hidden}';
  my $style = $css->css_rules->[0]->style;

  $style->set_property ('DISplay' => 'InLiNE', 'ImporTANT');
  is $style->get_property_value ('display'), 'inline';
  is $style->get_property_priority ('display'), 'important';
  is scalar @$style, 3;
  is $style->[2], 'display';

  done $c;
} n => 4, name => 'set_property important';

test {
  my $c = shift;
  my $css = from_style_el 'p {poSition: absolUTe; border-top-style:hidden}';
  my $style = $css->css_rules->[0]->style;

  $style->set_property ('display' => 'block');

  $style->set_property ('border-top-style' => '');
  is scalar @$style, 2;
  is $style->[0], 'position';
  is $style->[1], 'display';

  $style->set_property ('DISplay' => '', 'ImporTANT');
  is $style->get_property_value ('display'), '';
  is $style->get_property_priority ('display'), '';
  is scalar @$style, 1;
  is $style->[0], 'position';

  done $c;
} n => 7, name => 'set_property empty';

test {
  my $c = shift;
  my $css = from_style_el 'p {poSition: absolUTe; border-top-style:hidden}';
  my $style = $css->css_rules->[0]->style;

  $style->set_property ('HoGefuga' => 'block');
  is scalar @$style, 2;
  is $style->[0], 'position';
  is $style->[1], 'border-top-style';

  done $c;
} n => 3, name => 'set_property unknown property';

test {
  my $c = shift;
  my $css = from_style_el 'p {poSition: absolUTe; border-top-style:hidden}';
  my $style = $css->css_rules->[0]->style;

  $style->set_property ('list-style-type' => '');
  is scalar @$style, 2;
  is $style->[0], 'position';
  is $style->[1], 'border-top-style';

  done $c;
} n => 3, name => 'set_property remove no value property';

test {
  my $c = shift;
  my $css = from_style_el 'p {poSition: absolUTe; border-top-style:hidden}';
  my $style = $css->css_rules->[0]->style;

  $style->set_property ('display' => 'block', 'Hoge');
  is scalar @$style, 2;
  is $style->[0], 'position';
  is $style->[1], 'border-top-style';
  is $style->get_property_value ('display'), '';

  done $c;
} n => 4, name => 'set_property wrong priority';

test {
  my $c = shift;
  my $css = from_style_el 'p {display: none !important}';
  my $style = $css->css_rules->[0]->style;

  $style->set_property ('display' => 'block', '');
  is $style->get_property_value ('display'), 'block';
  is $style->get_property_priority ('display'), '';

  done $c;
} n => 2, name => 'set_property clear priority';

test {
  my $c = shift;
  my $css = from_style_el 'p {display: none !important}';
  my $style = $css->css_rules->[0]->style;

  $style->set_property ('display' => 'block');
  is $style->get_property_value ('display'), 'block';
  is $style->get_property_priority ('display'), '';

  done $c;
} n => 2, name => 'set_property clear priority by default';

test {
  my $c = shift;
  my $css = from_style_el 'p {display: none !important}';
  my $style = $css->css_rules->[0]->style;

  $style->set_property ('display');
  is $style->get_property_value ('display'), '';
  is $style->get_property_priority ('display'), '';
  is scalar @$style, 0;

  done $c;
} n => 3, name => 'set_property clear by default';

test {
  my $c = shift;
  my $css = from_style_el 'p {display: none !important}';
  my $style = $css->css_rules->[0]->style;

  $style->remove_property ('display');
  is $style->get_property_value ('display'), '';
  is $style->get_property_priority ('display'), '';
  is scalar @$style, 0;

  done $c;
} n => 3, name => 'remove_property';

test {
  my $c = shift;
  my $css = from_style_el 'p {display: none !important}';
  my $style = $css->css_rules->[0]->style;

  $style->remove_property ('dispLAY');
  is $style->get_property_value ('display'), '';
  is $style->get_property_priority ('display'), '';
  is scalar @$style, 0;

  done $c;
} n => 3, name => 'remove_property';

test {
  my $c = shift;
  my $css = from_style_el 'p {display: none !important}';
  my $style = $css->css_rules->[0]->style;

  $style->remove_property ('list-style-type');
  is $style->get_property_value ('list-style-type'), '';
  is $style->get_property_priority ('list-style-type'), '';
  is scalar @$style, 1;
  is $style->[0], 'display';

  done $c;
} n => 4, name => 'remove_property not set';

test {
  my $c = shift;
  my $css = from_style_el 'p {display: none !important}';
  my $style = $css->css_rules->[0]->style;

  my $value = $style->remove_property ('display');
  is $value, 'none';

  done $c;
} n => 1, name => 'remove_property return';

test {
  my $c = shift;
  my $css = from_style_el 'p {display: none !important}';
  my $style = $css->css_rules->[0]->style;

  my $value = $style->remove_property ('position');
  is $value, '';

  done $c;
} n => 1, name => 'remove_property not found return';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
