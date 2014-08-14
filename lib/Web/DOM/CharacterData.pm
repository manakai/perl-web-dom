package Web::DOM::CharacterData;
use strict;
use warnings;
no warnings 'utf8';
our $VERSION = '2.0';
use Web::DOM::Node;
use Web::DOM::ChildNode;
push our @ISA, qw(Web::DOM::Node Web::DOM::ChildNode);

*node_value = \&data;
*text_content = \&data;

sub data ($;$) {
  if (@_ > 1) {
    ## "Replace data" steps (simplified)
    # XXX mutation record
    @{${$_[0]}->[2]->{data}} = ([defined $_[1] ? ''.$_[1] : '', -1, 0]); # WebIDL; IndexedStringSegment
    # XXX range
  }
  return join '', map { $_->[0] } @{${$_[0]}->[2]->{data}}; # IndexedString
} # data

sub length ($) {
  my $data = $_[0]->data;
  my $length = CORE::length $data;
  if ($data =~ /[\x{10000}-\x{10FFFF}]/) {
    $length += $data =~ tr/\x{10000}-\x{10FFFF}/\x{10000}-\x{10FFFF}/;
  }
  return $length;
} # length

sub append_data ($$) {
  push @{${$_[0]}->[2]->{data}}, [''.$_[1], -1, 0]; # IndexedStringSegment
  return;
} # append_data

sub manakai_append_text ($$) {
  ## See also ParentNode::manakai_append_text

  # IndexedStringSegment
  my $segment = [ref $_[1] eq 'SCALAR' ? ${$_[1]} : $_[1], -1, 0];
  $segment->[0] = ''.$segment->[0] if ref $_[1];

  push @{${$_[0]}->[2]->{data}}, $segment;

  return $_[0];
} # manakai_append_text

sub substring_data ($$$) {
  # WebIDL: unsigned long
  my $offset = $_[1] % 2**32;
  my $count = $_[2] % 2**32;

  # Substring data
  my $data = $_[0]->data;
  if ($data =~ /[\x{10000}-\x{10FFFF}]/ or
      $offset >= 2**31 or $count >= 2**31) {
    # 1.-4.
    my @data = split //, $data;
    my @result;
    my $i = 0;
    for (@data) {
      last if $i >= $offset + $count;
      if (/[\x{10000}-\x{10FFFF}]/) {
        if ($offset == $i + 1) {
          push @result, chr ((((ord $_) - 0x10000) % 0x400) + 0xDC00);
        } elsif ($offset + $count == $i + 1) {
          push @result, chr ((((ord $_) - 0x10000) / 0x400) + 0xD800);
        } elsif ($offset <= $i) {
          push @result, $_;
        }
        $i += 2;
      } else {
        if ($offset <= $i) {
          push @result, $_;
        }
        $i++;
      }
    }
    if ($offset > $i) {
      _throw Web::DOM::Exception 'IndexSizeError',
          'Offset is greater than the length';
    }
    return join '', @result;
  } else {
    # 1.-2.
    if ($offset > CORE::length $data) {
      _throw Web::DOM::Exception 'IndexSizeError',
          'Offset is greater than the length';
    }

    # 3.-4.
    return substr $data, $offset, $count;
  }
} # substring_data

sub insert_data ($$$) {
  return $_[0]->replace_data ($_[1], 0, $_[2]);
} # insert_data

sub delete_data ($$$) {
  return $_[0]->replace_data ($_[1], $_[2], '');
} # delete_data

sub replace_data ($$$$) {
  # WebIDL: unsigned long
  my $offset = $_[1] % 2**32;
  my $count = $_[2] % 2**32;
  my $s = ''.$_[3];

  # IndexedString
  if (@{${$_[0]}->[2]->{data}} != 1) {
    @{${$_[0]}->[2]->{data}} = ([$_[0]->data, -1, 0]);
  } else {
    ${$_[0]}->[2]->{data}->[0]->[1] = -1;
    ${$_[0]}->[2]->{data}->[0]->[2] = 0;
  }

  # Replace data
  if (${$_[0]}->[2]->{data}->[0]->[0] =~ /[\x{D800}-\x{DFFF}\x{10000}-\x{10FFFF}]/ or # IndexedString
      $s =~ /[\x{D800}-\x{DFFF}]/ or
      $offset >= 2**31 or $count >= 2**31) {
    # XXX 4. mutation

    # 1.-3., 5.
    my @data = split //, ${$_[0]}->[2]->{data}->[0]->[0]; # IndexedString
    my @before;
    my @after;
    my $i = 0;
    for (@data) {
      if (/[\x{10000}-\x{10FFFF}]/) {
        if ($offset == $i + 1) {
          push @before, chr ((((ord $_) - 0x10000) / 0x400) + 0xD800);
        } elsif ($offset + $count == $i + 1) {
          push @after, chr ((((ord $_) - 0x10000) % 0x400) + 0xDC00);
        } elsif ($offset + $count <= $i) {
          push @after, $_;
        } elsif ($i < $offset) {
          push @before, $_;
        } # $offset <= $i
        $i += 2;
      } else {
        if ($offset + $count <= $i) {
          push @after, $_;
        } elsif ($i < $offset) {
          push @before, $_;
        }
        $i++;
      }
    }
    if ($offset > $i) {
      _throw Web::DOM::Exception 'IndexSizeError',
          'Offset is greater than the length';
    }
    ${$_[0]}->[2]->{data}->[0]->[0] = join '', @before, $s, @after; # IndexedString
  } else {
    # 1.-2.
    if ($offset > CORE::length ${$_[0]}->[2]->{data}->[0]->[0]) { # IndexedString
      _throw Web::DOM::Exception 'IndexSizeError',
          'Offset is greater than the length';
    }

    # XXX 4. mutation

    # 3., 5.
    substr (${$_[0]}->[2]->{data}->[0]->[0], $offset, $count) = $s; # IndexedString
  }

  # XXX 6.-11. range
  return;
} # replace_data

1;

=head1 LICENSE

Copyright 2012-2014 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
