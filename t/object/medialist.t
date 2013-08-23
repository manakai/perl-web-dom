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
  my $css = from_style_el '';
  my $media = $css->media;

  isa_ok $media, 'Web::DOM::MediaList';
  is $media->media_text, '';
  is scalar @$media, 0;

  $media->media_text ('scree\n, All');
  is $media->media_text, 'screen, all';
  is $media->length, 2;
  is $media->[0], 'screen';
  is $media->[1], 'all';

  $media->media_text ('');
  is $media->media_text, '';
  is $media->length, 0;

  $media->media_text ('{{');
  is $media->media_text, 'not all';
  is $media->length, 1;
  is $media->item (0), 'not all';

  is ''.$media, 'not all';
  ok $media;

  $media->delete_medium ('not  all');
  is ''.$media, '';
  ok $media;

  done $c;
} n => 16, name => 'media_text, ""';

test {
  my $c = shift;
  my $css = from_style_el '';
  my $media = $css->media;

  $media->append_medium ('screen');
  is $media->media_text, 'screen';

  $media->media_text (undef);
  is $media->media_text, '';

  done $c;
} n => 2, name => 'media_text undef';

test {
  my $c = shift;
  my $css1 = from_style_el '';
  my $media1 = $css1->media;
  my $css2 = from_style_el '';
  my $media2 = $css2->media;

  isnt $media1 cmp $media2, 0;
  ok not $media1 eq $media2;
  ok $media1 ne $media2;
  ok $media1 ne $media2;
  ok not $media1 eq $media2;

  ok $media1 eq $media1;
  ok not $media1 ne $media1;

  done $c;
} n => 7, name => 'cmp';

test {
  my $c = shift;
  my $css = from_style_el '';
  my $media = $css->media;

  eq_or_diff [@$media], [];
  is scalar @$media, 0;
  is $media->length, 0;

  $media->append_medium ('screen');
  eq_or_diff [@$media], ['screen'];

  $media->append_medium ('screen');
  eq_or_diff [@$media], ['screen'];
  is scalar @$media, 1;
  is $media->length, 1;

  $media->append_medium ('all');
  eq_or_diff [@$media], ['screen', 'all'];
  is scalar @$media, 2;
  is $media->length, 2;

  dies_here_ok {
    push @$media, 'speech';
  };
  like $@, qr{^Modification of a read-only value attempted};

  dies_here_ok {
    $media->[0] = 'print';
  };
  like $@, qr{^Modification of a read-only value attempted};

  eq_or_diff [@$media], ['screen', 'all'];
  is $media->length, 2;
  is scalar @$media, 2;

  done $c;
} n => 17, name => '@{}, length';

test {
  my $c = shift;
  my $css = from_style_el '';
  my $media = $css->media;

  is $media->[0], undef;
  is $media->item (0), undef;
  is $media->item (-1), undef;

  $media->append_medium (' screen /**/ ');
  is $media->[0], 'screen';
  is $media->[-1], 'screen';
  is $media->[2], undef;
  is $media->item (0), 'screen';
  is $media->item (-1), undef;
  is $media->item (2), undef;
  is $media->item (2**32), 'screen';
  is $media->item (2**31), undef;

  done $c;
} n => 11, name => 'item';

test {
  my $c = shift;
  my $css = from_style_el '';
  my $media = $css->media;

  $media->append_medium ('print');
  is $media->media_text, 'print';

  $media->append_medium ('screen, all');
  is $media->media_text, 'print';

  $media->append_medium ('');
  is $media->media_text, 'print, not all';

  $media->append_medium ('NOT ALL');
  is $media->media_text, 'print, not all';

  done $c;
} n => 4, name => 'append_medium';

test {
  my $c = shift;
  my $css = from_style_el '';
  my $media = $css->media;

  $media->delete_medium ('screen');
  is $media->media_text, '';

  $media->media_text ('screen, all, print, screen');
  $media->delete_medium ('Screen');
  is $media->media_text, 'all, print';

  $media->media_text ('not all, hoge, fuga, screen, ({]');
  $media->delete_medium ('Speech, aural');
  is $media->media_text, 'not all, hoge, fuga, screen, not all';
  $media->delete_medium (1);
  is $media->media_text, 'hoge, fuga, screen';

  done $c;
} n => 4, name => 'delete_medium';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
