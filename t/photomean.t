use Test::More tests => 6;

my %results = (
		'000000.png' => '#000000',
		'ffffff.png' => '#ffffff',
		'777777.png' => '#777777',
		'ff003e.png' => '#ff003e',
		'00ff14.png' => '#00ff14',
		'0014ff.png' => '#0014ff',
);

for (keys %results) {
	doit($_, $results{$_});
}


sub doit
{
	my ($file, $expected) = @_;
	my $out = `../photomean -file img/$file`;
	my ($col) = $out =~ /(#[0-9a-f]+)/i;
	ok($col eq $expected, "$file: expected $expected, got $col");
}


# vim:ft=perl
