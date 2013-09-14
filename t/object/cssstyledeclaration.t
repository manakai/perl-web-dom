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
  my $style = from_style_attr undef;

  is $style->css_text, '';
  is $style->length, 0;
  is $style->item (0), '';
  is $style->[0], undef;
  is $style->get_property_value ('display'), '';
  is $style->get_property_priority ('display'), '';
  is $style->display, '';
  is $style->parent_rule, undef;

  done $c;
} n => 8, name => 'style="" basic no attr';

test {
  my $c = shift;
  my $style = from_style_attr 'display: block';

  is $style->css_text, 'display: block;';
  is $style->length, 1;
  is $style->item (0), 'display';
  is $style->[0], 'display';
  is $style->get_property_value ('display'), 'block';
  is $style->get_property_priority ('display'), '';
  is $style->display, 'block';
  is $style->parent_rule, undef;

  done $c;
} n => 8, name => 'style="" basic has attr';

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
  my ($el, $style) = from_style_attr 'display:block';

  $style->set_property (display => 'inline', 'important');

  is $style->css_text, 'display: inline !important;';
  is $el->get_attribute_ns (undef, 'style'), 'display: inline !important;';
  done $c;
} n => 2, name => 'set_property style=""';

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

test {
  my $c = shift;
  my ($el, $style) = from_style_attr 'display:none';

  $style->remove_property ('display');
  is $style->css_text, '';
  is $style->display, '';
  is $el->get_attribute_ns (undef, 'style'), '';

  done $c;
} n => 3, name => 'remove_property style=""';

test {
  my $c = shift;
  my ($el, $style) = from_style_attr 'display:none';

  $style->remove_property ('color');
  is $style->css_text, 'display: none;';
  is $style->display, 'none';
  is $el->get_attribute_ns (undef, 'style'), 'display:none';

  done $c;
} n => 3, name => 'remove_property style="" not found';

test {
  my $c = shift;
  my $css = from_style_el 'p {}';
  my $style = $css->css_rules->[0]->style;

  $style->set_property (display => 'block');
  $style->set_property (float => 'left');

  eq_or_diff [@$style], [qw(display float)];

  $style->set_property (display => 'inline');

  eq_or_diff [@$style], [qw(display float)];

  $style->set_property ('list-style-type' => 'none');

  eq_or_diff [@$style], [qw(display float list-style-type)];

  $style->remove_property ('float');

  eq_or_diff [@$style], [qw(display list-style-type)];

  done $c;
} n => 4, name => 'property order';

test {
  my $c = shift;
  my $css = from_style_el 'p {}';
  my $style = $css->css_rules->[0]->style;

  is $style->display, '';

  $style->display ('block');
  is $style->display, 'block';
  is $style->get_property_value ('display'), 'block';

  $style->set_property ('float', 'left', 'important');
  is $style->float, 'left';
  is $style->css_float, 'left';

  $style->float ('Right');
  is $style->float, 'right';
  is $style->get_property_priority ('float'), '';

  $style->float ('');
  is $style->float, '';
  is $style->length, 1;
  is $style->[0], 'display';

  $style->list_style_type ('none');
  is $style->list_style_type, 'none';
  is $style->get_property_value ('list-style-type'), 'none';

  done $c;
} n => 12, name => '<style> style camel-cased attributes';

test {
  my $c = shift;
  my ($el, $style) = from_style_attr undef;

  $style->display ('none');
  is $style->css_text, 'display: none;';
  is $el->get_attribute_ns (undef, 'style'), 'display: none;';

  done $c;
} n => 2, name => 'style="" camel-cased property';

test {
  my $c = shift;
  my $css = from_style_el 'p {}';
  my $style = $css->css_rules->[0]->style;

  is $style->background_position, '';
  is $style->get_property_value ('background-position'), '';
  is $style->get_property_priority ('background-position'), '';
  is $style->get_property_value ('background-position-x'), '';
  is $style->get_property_priority ('background-position-x'), '';
  is $style->get_property_value ('background-position-y'), '';
  is $style->get_property_priority ('background-position-y'), '';

  $style->background_position ('1px 2PX');
  is $style->background_position, '1px 2px';
  is $style->get_property_value ('baCKGROUND-POSITION'), '1px 2px';
  is $style->get_property_priority ('baCKGROUND-POSITION'), '';

  $style->set_property ('background-position', 'top');
  is $style->background_position, '50% top';
  is $style->get_property_value ('background-position'), '50% top';

  $style->set_property ('background-position', '20px', 'important');
  is $style->get_property_priority ('background-position'), 'important';
  is $style->get_property_priority ('background-position-x'), 'important';
  is $style->get_property_priority ('background-position-y'), 'important';

  $style->set_property ('background-position', '20px');
  is $style->get_property_priority ('background-position'), '';
  is $style->get_property_priority ('background-position-x'), '';
  is $style->get_property_priority ('background-position-y'), '';

  $style->set_property ('background-position-x', '10px', 'important');
  is $style->get_property_priority ('background-position'), '';
  is $style->get_property_priority ('background-position-x'), 'important';
  is $style->get_property_priority ('background-position-y'), '';

  $style->remove_property ('background-position');
  is $style->get_property_value ('background-position'), '';
  is $style->get_property_priority ('background-position'), '';
  is $style->get_property_value ('background-position-x'), '';
  is $style->get_property_priority ('background-position-x'), '';
  is $style->get_property_value ('background-position-y'), '';
  is $style->get_property_priority ('background-position-y'), '';

  done $c;
} n => 27, name => 'shorthand props';

test {
  my $c = shift;
  my $css = from_style_el 'p {  }';
  my $style = $css->css_rules->[0]->style;

  is $style->css_text, '';

  $style->css_text ('display : BLOCK  /**/ ');
  is $style->css_text, 'display: block;';
  is $style->length, 1;
  is $style->display, 'block';

  $style->list_style_type ('disc');
  is $style->css_text, 'display: block; list-style-type: disc;';

  $style->set_property ('display', 'inline', 'IMPORTANt');
  is $style->css_text, 'display: inline !important; list-style-type: disc;';

  done $c;
} n => 6, name => 'css_text';

test {
  my $c = shift;
  my $css = from_style_el 'p {list-style-type: none;display: Block !important }';
  my $style = $css->css_rules->[0]->style;

  is $style->css_text, 'list-style-type: none; display: block !important;';

  $style->remove_property ('list-style-type');
  $style->list_style_type ('disc');
  is $style->css_text, 'display: block !important; list-style-type: disc;';

  $style->css_text ('');
  is $style->css_text, '';

  is $css->owner_node->text_content, 'p {list-style-type: none;display: Block !important }';

  done $c;
} n => 4, name => 'css_text';

test {
  my $c = shift;
  my $css = from_style_el 'p {list-style-type: none;display: Block !important }';
  my $style = $css->css_rules->[0]->style;

  $style->css_text ('hoge: fuga');

  is $style->css_text, '';

  done $c;
} n => 1, name => 'css_text invalid';

test {
  my $c = shift;
  my $css = from_style_el 'p {}';
  my $style = $css->css_rules->[0]->style;

  delete Web::CSS::Parser->get_parser_of_document ($css)->media_resolver->{prop}->{display};

  $style->css_text ('display: block');
  is $style->css_text, '';

  done $c;
} n => 1, name => 'css_text non-supported property';

test {
  my $c = shift;
  my ($el, $style) = from_style_attr 'display: list-item';

  $style->css_text ('display: compact');
  is $el->get_attribute ('style'), 'display: compact;';

  done $c;
} n => 1, name => 'css_text style=""';

test {
  my $c = shift;
  my $css = from_style_el 'p {}';
  my $style = $css->css_rules->[0]->style;

  delete Web::CSS::Parser->get_parser_of_document ($css)->media_resolver->{prop}->{display};

  $style->display ('block');
  is $style->display, '';

  done $c;
} n => 1, name => 'non-supported property method';

test {
  my $c = shift;
  my $css = from_style_el 'p {display:inline}';
  my $style = $css->css_rules->[0]->style;

  delete Web::CSS::Parser->get_parser_of_document ($css)->media_resolver->{prop_value}->{display}->{block};

  $style->display ('block');
  is $style->display, 'inline';

  done $c;
} n => 1, name => 'non-supported property method value';

test {
  my $c = shift;
  my $css = from_style_el 'p {opacity: 1.2}';
  my $style = $css->css_rules->[0]->style;

  is $style->opacity, '1.2';
  is $style->_webkit_opacity, '1.2';

  $style->set_property (opacity => '-12');
  is $style->get_property_value ('-webkit-opacity'), '-12';

  $style->set_property ('-webkit-opacity' => '-12');
  is $style->get_property_value ('-webkit-opacity'), '-12';

  done $c;
} n => 4, name => 'opacity';

test {
  my $c = shift;
  my $css = from_style_el 'p {-manakai-border-spacing-x: 1.2px}';
  my $style = $css->css_rules->[0]->style;

  is $style->_manakai_border_spacing_x, '1.2px';
  is $style->_webkit_border_horizontal_spacing, '1.2px';

  $style->set_property ('-manakai-border-spacing-x' => '12px');
  is $style->get_property_value ('-webkit-border-horizontal-spacing'), '12px';

  done $c;
} n => 3, name => 'border-spacing';

test {
  my $c = shift;
  my $css = from_style_el 'p {-manakai-border-spacing-Y: 1.2px}';
  my $style = $css->css_rules->[0]->style;

  is $style->_manakai_border_spacing_y, '1.2px';
  is $style->_webkit_border_vertical_spacing, '1.2px';

  $style->set_property ('-manakai-border-spacing-y' => '12px');
  is $style->get_property_value ('-webkit-border-vertical-spacing'), '12px';

  done $c;
} n => 3, name => 'border-spacing';

test {
  my $c = shift;
  my $css = from_style_el 'p{}';
  my $style = $css->css_rules->[0]->style;

  $style->content ('attr(foo)');
  is $style->content, 'attr(foo)';

  $style->content ('attr(abc|foo)');
  is $style->content, 'attr(foo)';

  done $c;
} n => 2, name => 'attr() with no namespace';

test {
  my $c = shift;
  my $css = from_style_el '@namespace aB " dd"; p{}';
  my $style = $css->css_rules->[1]->style;

  $style->content ('attr(aB|foo)');
  is $style->content, 'attr(aB|foo)';

  $style->content ('attr(ab|foo)');
  is $style->content, 'attr(aB|foo)';

  done $c;
} n => 2, name => 'attr() with namespace';

test {
  my $c = shift;
  my ($el, $style) = from_style_attr 'display: list-item';

  $style->content ('attr(ax|bar)');
  is $style->content, '';
  is $el->get_attribute ('style'), 'display: list-item;';

  done $c;
} n => 2, name => 'style="" attr() prefixed';

test {
  my $c = shift;
  my $css = from_style_el '@namespace aB " dd"; p{}';
  my $style = $css->css_rules->[1]->style;

  $style->css_text ('content: attr(aB|foo)');
  is $style->content, 'attr(aB|foo)';

  $style->css_text ('content: attr(ab|foo)');
  is $style->content, '';

  done $c;
} n => 2, name => 'css_text - attr() with namespace';

test {
  my $c = shift;
  my ($el, $style) = from_style_attr 'display: list-item';

  $style->css_text ('content: attr(ax|bar)');
  is $style->content, '';
  is $el->get_attribute ('style'), '';

  done $c;
} n => 2, name => 'style="" css_text - attr() prefixed';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
