package Web::DOM::CSSRule;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Internal;

our @EXPORT;
*import = \&Web::DOM::Internal::import;

push @EXPORT, qw(UNKNOWN_RULE STYLE_RULE CHARSET_RULE IMPORT_RULE MEDIA_RULE
                 FONT_FACE_RULE PAGE_RULE NAMESPACE_RULE);
sub UNKNOWN_RULE () { 0 }
sub STYLE_RULE () { 1 }
sub CHARSET_RULE () { 2 }
sub IMPORT_RULE () { 3 }
sub MEDIA_RULE () { 4 }
sub FONT_FACE_RULE () { 5 }
sub PAGE_RULE () { 6 }
sub NAMESPACE_RULE () { 10 }

sub type ($) {
  return ${$_[0]}->[2]->{type};
} # type

# XXX css_text

sub parent_rule ($) {
  return ${$_[0]}->[0]->rule (${$_[0]}->[2]->{parent_rule}); # or undef
} # parent_rule

sub parent_style_sheet ($) {
  return ${$_[0]}->[0]->sheet (${$_[0]}->[2]->{parent_style_sheet}); # or undef
} # parent_style_sheet

sub DESTROY ($) {
  ${$_[0]}->[0]->destroy_rule (${$_[0]}->[1]);
} # DESTROY

package Web::DOM::CSSUnknownRule;
push our @ISA, qw(Web::DOM::CSSRule);

package Web::DOM::CSSStyleRule;
push our @ISA, qw(Web::DOM::CSSRule);

# XXX selector_text

sub style ($) {
  return ${$_[0]}->[0]->style (${$_[0]}->[1]);
} # style

package Web::DOM::CSSCharsetRule;
push our @ISA, qw(Web::DOM::CSSRule);

sub encoding ($;$) {
  # XXX setter behavior not defined in spec (this is chrome behavior)
  if (@_ > 1) {
    ${$_[0]}->[2]->{encoding} = ''.$_[1];
  }
  return ${$_[0]}->[2]->{encoding};
} # encoding

package Web::DOM::CSSImportRule;
push our @ISA, qw(Web::DOM::CSSRule);

sub href ($) {
  return ${$_[0]}->[2]->{href};
} # href

# XXX media

sub style_sheet ($) {
  return ${$_[0]}->[0]->sheet (${$_[0]}->[2]->{style_sheet});
} # style_sheet

package Web::DOM::CSSMediaRule;
push our @ISA, qw(Web::DOM::CSSRule);

# XXX media

# XXX css_rules

# XXX insert_rule

# XXX delete_rule

package Web::DOM::CSSFontFaceRule;
push our @ISA, qw(Web::DOM::CSSRule);

sub style ($) {
  return ${$_[0]}->[0]->style (${$_[0]}->[1]);
} # style

package Web::DOM::CSSPageRule;
push our @ISA, qw(Web::DOM::CSSRule);

# XXX selector_text

sub style ($) {
  return ${$_[0]}->[0]->style (${$_[0]}->[1]);
} # style

package Web::DOM::CSSNamespaceRule;
push our @ISA, qw(Web::DOM::CSSRule);

sub namespace_uri ($) {
  return ${${$_[0]}->[2]->{namespace_uri}};
} # namespace_uri

sub prefix ($) {
  return ${${$_[0]}->[2]->{prefix}};
} # prefix

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
