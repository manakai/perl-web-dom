use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->child ('modules/*/lib')->stringify;
use JSON::PS;
use Data::Dumper;

my $Data = {};

my $root_path = path (__FILE__)->parent->parent;

{
  my $src_path = $root_path->child ('local/elements.json');
  my $src = json_bytes2perl $src_path->slurp;

  for my $ns (keys %{$src->{elements}}) {
    for my $ln (keys %{$src->{elements}->{$ns}}) {
      if ($src->{elements}->{$ns}->{$ln}->{all_named}) {
        $Data->{all_named}->{$ns}->{$ln} = 1;
      }
    }
  }
}

{
  my $src_path = $root_path->child ('local/dom-events.json');
  my $src = json_bytes2perl $src_path->slurp;

  for my $ev (keys %{$src->{event_types}}) {
    if (defined $src->{event_types}->{$ev}->{legacy}) {
      $Data->{legacy_event}->{$ev} = $src->{event_types}->{$ev}->{legacy};
    }
  }
}

$Data::Dumper::Sortkeys = 1;
my $dump = Dumper $Data;
$dump =~ s/^\$VAR1/\$Web::DOM::_Defs/;
print $dump;
print "1;";

## License: Public Domain.
