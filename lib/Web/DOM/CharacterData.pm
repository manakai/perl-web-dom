package Web::DOM::CharacterData;
use strict;
use warnings;
no warnings 'utf8';
our $VERSION = '1.0';
use Web::DOM::Node;
use Web::DOM::ChildNode;
push our @ISA, qw(Web::DOM::Node Web::DOM::ChildNode);

*node_value = \&data;
*text_content = \&data;

sub data ($;$) {
  if (@_ > 1) {
    ## "Replace data" steps (simplified)
    # XXX mutation record
    ${${$_[0]}->[2]->{data}} = defined $_[1] ? ''.$_[1] : ''; # WebIDL
    # XXX range
  }
  return ${${$_[0]}->[2]->{data}};
} # data

sub length ($) {
  my $length = CORE::length ${${$_[0]}->[2]->{data}};
  if (${${$_[0]}->[2]->{data}} =~ /[\x{10000}-\x{10FFFF}]/) {
    $length += ${${$_[0]}->[2]->{data}} =~ tr/\x{10000}-\x{10FFFF}/\x{10000}-\x{10FFFF}/;
  }
  return $length;
} # length

sub append_data ($$) {
  #my $has_trail = ${${$_[0]}->[2]->{data}} =~ /[\x{D800}-\x{DBFF}]\z/;
  #if ($has_trail) {
  #  my $old_length = CORE::length ${${$_[0]}->[2]->{data}};
  #  ${${$_[0]}->[2]->{data}} .= $_[1];
  #  my $boundary = substr ${${$_[0]}->[2]->{data}}, $old_length - 1, 2;
  #  if ($boundary =~ /\A([\x{D800}-\x{DBFF}])([\x{DC00}-\x{DFFF}])\z/) {
  #    substr (${${$_[0]}->[2]->{data}}, $old_length - 1, 2)
  #        = chr (2**16 + ((ord $1) & 0x3FF) * 2**10 + ((ord $2) & 0x3FF));
  #  }
  #} else {
    ${${$_[0]}->[2]->{data}} .= $_[1];
  #}
  return;
} # append_data

sub manakai_append_text ($$) {
  ## See also ParentNode::manakai_append_text
  $_[0]->append_data (ref $_[1] eq 'SCALAR' ? ${$_[1]} : $_[1]);
  return $_[0];
} # manakai_append_text

sub substring_data ($$$) {
  # WebIDL: unsigned long
  my $offset = $_[1] % 2**32;
  my $count = $_[2] % 2**32;

  # Substring data
  if (${${$_[0]}->[2]->{data}} =~ /[\x{10000}-\x{10FFFF}]/ or
      $offset >= 2**31 or $count >= 2**31) {
    # 1.-4.
    my @data = split //, ${${$_[0]}->[2]->{data}};
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
    if ($offset > CORE::length ${${$_[0]}->[2]->{data}}) {
      _throw Web::DOM::Exception 'IndexSizeError',
          'Offset is greater than the length';
    }

    # 3.-4.
    return substr ${${$_[0]}->[2]->{data}}, $offset, $count;
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

  # Replace data
  if (${${$_[0]}->[2]->{data}} =~ /[\x{D800}-\x{DFFF}\x{10000}-\x{10FFFF}]/ or
      $s =~ /[\x{D800}-\x{DFFF}]/ or
      $offset >= 2**31 or $count >= 2**31) {
    # XXX 4. mutation

    # 1.-3., 5.
    my @data = split //, ${${$_[0]}->[2]->{data}};
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
    #if (@before and $before[-1] =~ /[\x{D800}-\x{DBFF}]\z/ and
    #    $s =~ /\A([\x{DC00}-\x{DFFF}])/) {
    #  ${${$_[0]}->[2]->{data}} = join '',
    #      @before[0..($#before-1)],
    #      chr (2**16
    #           + ((ord $before[-1]) & 0x3FF) * 2**10
    #           + ((ord $1) & 0x3FF)),
    #      (substr $s, 1),
    #      @after;
    #} elsif (@after and $after[0] =~ /\A[\x{DC00}-\x{DFFF}]/ and
    #         $s =~ /([\x{D800}-\x{DBFF}])\z/) {
    #  ${${$_[0]}->[2]->{data}} = join '',
    #      @before,
    #      (substr $s, 0, -1 + length $s),
    #      chr (2**16
    #           + ((ord $1) & 0x3FF) * 2**10
    #           + ((ord $after[0]) & 0x3FF)),
    #      @after[1..$#after];
    #} elsif ($s eq '' and ... $before[-1] $after[0] ...) {
    #  ...
    #} else {
      ${${$_[0]}->[2]->{data}} = join '', @before, $s, @after;
    #}
  } else {
    # 1.-2.
    if ($offset > CORE::length ${${$_[0]}->[2]->{data}}) {
      _throw Web::DOM::Exception 'IndexSizeError',
          'Offset is greater than the length';
    }

    # XXX 4. mutation

    # 3., 5.
    substr (${${$_[0]}->[2]->{data}}, $offset, $count) = $s;
  }

  # XXX 6.-11. range
  return;
} # replace_data

1;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
