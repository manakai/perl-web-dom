package Web::DOM::StringMap;
use strict;
use warnings;
no warnings 'utf8';
our $VERSION = '1.0';
use Carp;

use overload
    '""' => sub {
      return ref ($_[0]) . '=DOM(' . (tied %{${$_[0]}->[0]})->[0] . ')';
    },
    bool => sub { 1 },
    cmp => sub {
      carp "Use of uninitialized value in string comparison (cmp)"
          unless defined $_[1];
      overload::StrVal ($_[0]) cmp overload::StrVal ($_[1])
    },
    '%{}' => sub {
      return ${$_[0]}->[0];
    },
    fallback => 1;

package Web::DOM::StringMap::Hash;
use Web::DOM::Exception;
push our @CARP_NOT, qw(Web::DOM::Exception);
use Char::Class::XML qw(
  InXMLNameChar InXMLNameStartChar
);

sub TIEHASH ($$) {
  return bless [$_[1]], $_[0]
} # TIEHASH

sub FETCH ($$) {
  my $key = ''.$_[1];
  return undef if $key =~ /-/;
  $key =~ tr/_/-/;
  return $_[0]->[0]->get_attribute_ns (undef, 'data-' . $key);
} # FETCH

sub STORE ($$$) {
  my $key = ''.$_[1];
  _throw Web::DOM::Exception 'SyntaxError',
      'Key cannot contain the hyphen character' if $key =~ /-/;
  $key =~ tr/_/-/;
  unless ("data-$key" =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
    my $value = ''.$_[2];
    _throw Web::DOM::Exception 'SyntaxError',
        'The attribute name is not an XML Name';
  }
  my $doc = $_[0]->[0]->owner_document;
  my $strict = $doc->strict_error_checking;
  $doc->strict_error_checking (0);
  $_[0]->[0]->set_attribute_ns (undef, [undef, 'data-' . $key] => $_[2]);
  $doc->strict_error_checking ($strict);
} # STORE

sub DELETE ($$) {
  my $key = ''.$_[1];
  return undef if $key =~ /-/;
  $key =~ tr/_/-/;
  return $_[0]->[0]->remove_attribute_ns (undef, 'data-' . $key);
} # DELETE

sub CLEAR ($) {
  for (grep { $_->local_name =~ /^data-/ } $_[0]->[0]->attributes->to_list) {
    $_[0]->[0]->remove_attribute_ns (undef, $_->local_name);
  }
} # CLEAR

sub EXISTS ($$) {
  my $key = ''.$_[1];
  return '' if $key =~ /-/;
  $key =~ tr/_/-/;
  return $_[0]->[0]->has_attribute_ns (undef, 'data-' . $key);
} # EXISTS

sub _create_list ($) {
  $_[0]->[1] = [map {
    my $name = $_;
    $name =~ s/^data-//;
    $name =~ tr/-/_/;
    $name;
  } map {
    my $name = $_->local_name;
    $name =~ /_/ ? () : $name;
  } grep {
    not defined $_->namespace_uri and $_->local_name =~ /^data-/;
  } $_[0]->[0]->attributes->to_list];
} # _create_list

sub FIRSTKEY ($) {
  $_[0]->_create_list;
  return $_[0]->[1]->[0];
} # FIRSTKEY

sub NEXTKEY ($$) {
  my $list = $_[0]->[1] || [];
  for (0..$#$list) {
    if ($list->[$_] eq $_[1]) {
      return $list->[$_ + 1];
    }
  }
  return undef;
} # NEXTKEY

sub SCALAR ($) {
  $_[0]->_create_list;
  return scalar @{$_[0]->_create_list};
} # SCALAR

sub DESTROY ($) {
  {
    local $@;
    eval { die };
    warn "Potential memory leak detected" if $@ =~ /during global destruction/;
  }
} # DESTROY

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
