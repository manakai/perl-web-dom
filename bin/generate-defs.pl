use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->child ('modules/*/lib')->stringify;
use JSON::Functions::XS qw(json_bytes2perl);
use Data::Dumper;

my $src_path = path (__FILE__)->parent->parent->child ('local/elements.json');
my $src = json_bytes2perl $src_path->slurp;

my $Data = {};

for my $ns (keys %{$src->{elements}}) {
  for my $ln (keys %{$src->{elements}->{$ns}}) {
    if ($src->{elements}->{$ns}->{$ln}->{all_named}) {
      $Data->{all_named}->{$ns}->{$ln} = 1;
    }
  }
}

$Data::Dumper::Sortkeys = 1;
my $dump = Dumper $Data;
$dump =~ s/^\$VAR1/\$Web::DOM::_Defs/;
print $dump;
print "1;";

## License: Public Domain.
