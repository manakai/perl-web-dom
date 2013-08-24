package Web::DOM::CSSRule;
use strict;
use warnings;
our $VERSION = '3.0';
use Carp;
use Web::DOM::Internal;

our @EXPORT;
*import = \&Web::DOM::Internal::import;

use overload
    '""' => sub {
      return ref ($_[0]) . '=DOM(' . ${$_[0]}->[2] . ')';
    },
    bool => sub { 1 },
    cmp => sub {
      carp "Use of uninitialized value in string comparison (cmp)"
          unless defined $_[1];
      overload::StrVal ($_[0]) cmp overload::StrVal ($_[1])
    },
    fallback => 1;

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
  die "Not implemented";
} # type

# XXX css_text

sub parent_rule ($) {
  my $id = ${$_[0]}->[2]->{parent_id};
  if (defined $id and ${$_[0]}->[0]->{data}->[$id]->{rule_type} ne 'sheet') {
    return ${$_[0]}->[0]->node ($id);
  } else {
    return undef;
  }
} # parent_rule

sub parent_style_sheet ($) {
  my $id = ${$_[0]}->[2]->{owner_sheet};
  return defined $id ? ${$_[0]}->[0]->node ($id) : undef;
} # parent_style_sheet

sub DESTROY ($) {
  ${$_[0]}->[0]->gc (${$_[0]}->[1]);
} # DESTROY

package Web::DOM::CSSUnknownRule;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::CSSRule);

sub type ($) { Web::DOM::CSSRule::UNKNOWN_RULE }

package Web::DOM::CSSStyleRule;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::CSSRule);

sub type ($) { Web::DOM::CSSRule::STYLE_RULE }

sub selector_text ($;$) {
  if (@_ > 1) {
    require Web::CSS::Selectors::Parser;
    # XXX media context, parser reuse
    my $parser = Web::CSS::Selectors::Parser->new;
    # XXX namespaces
    my $parsed = $parser->parse_char_string_as_selectors (''.$_[1]);
    if (defined $parsed) {
      ${$_[0]}->[2]->{selectors} = $parsed;

      # XXX notification
    }
  }
  return unless defined wantarray;
  
  require Web::CSS::Selectors::Serializer;
  my $serializer = Web::CSS::Selectors::Serializer->new;
  # XXX namespaces
  return $serializer->serialize_selector_text (${$_[0]}->[2]->{selectors});
} # selector_text

sub style ($;$) {
  my $style = ${$_[0]}->[0]->source_style ('rule', $_[0]);
  if (@_ > 1) {
    $style->css_text ($_[1]);
  }
  return $style;
} # style

package Web::DOM::CSSCharsetRule;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::CSSRule);

sub type ($) { Web::DOM::CSSRule::CHARSET_RULE }

sub encoding ($;$) {
  if (@_ > 1) {
    ${$_[0]}->[2]->{encoding} = ''.$_[1];
  }
  return ${$_[0]}->[2]->{encoding};
} # encoding

package Web::DOM::CSSImportRule;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::CSSRule);

sub type ($) { Web::DOM::CSSRule::IMPORT_RULE }

sub href ($) {
  return ${$_[0]}->[2]->{href};
} # href

sub media ($;$) {
  my $list = ${$_[0]}->[0]->media ($_[0]);
  if (@_ > 1) {
    $list->media_text ($_[1]);
  }
  return $list;
} # media

# XXX
sub style_sheet ($) {
  return ${$_[0]}->[0]->node (${$_[0]}->[2]->{sheet});
} # style_sheet

package Web::DOM::CSSGroupingRule;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::CSSRule);

sub css_rules ($) {
  my $self = $_[0];
  return $$self->[0]->collection ('css_rules', $self, sub {
    my $node = $_[0];
    return @{$$node->[2]->{rule_ids} or []};
  });
} # css_rules

# XXX insert_rule

# XXX delete_rule

package Web::DOM::CSSMediaRule;
our $VERSION = '2.0';
push our @ISA, qw(Web::DOM::CSSGroupingRule);

sub type ($) { Web::DOM::CSSRule::MEDIA_RULE }

sub media ($;$) {
  my $list = ${$_[0]}->[0]->media ($_[0]);
  if (@_ > 1) {
    $list->media_text ($_[1]);
  }
  return $list;
} # media

package Web::DOM::CSSFontFaceRule;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::CSSRule);

sub type ($) { Web::DOM::CSSRule::FONT_FACE_RULE }

#XXX
sub style ($) {
  return ${$_[0]}->[0]->style (${$_[0]}->[1]);
} # style

package Web::DOM::CSSPageRule;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::CSSRule);

sub type ($) { Web::DOM::CSSRule::PAGE_RULE }

# XXX selector_text

#XXX
sub style ($) {
  return ${$_[0]}->[0]->style (${$_[0]}->[1]);
} # style

package Web::DOM::CSSNamespaceRule;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::CSSRule);

sub type ($) { Web::DOM::CSSRule::NAMESPACE_RULE }

sub namespace_uri ($) {
  # XXXsetter
  return ${$_[0]}->[2]->{nsurl};
} # namespace_uri

sub prefix ($) {
  # XXX setter
  return defined ${$_[0]}->[2]->{prefix} ? ${$_[0]}->[2]->{prefix} : '';
} # prefix

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
