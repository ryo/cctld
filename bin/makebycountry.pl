#!/usr/local/bin/perl

use strict;
use warnings;

my $prefix = shift;
my $postfix = shift;
my %by_country;
while (<>) {
	my ($addr, $cc, $country) = split(/\t/, $_, 3);
	next if ($cc eq '');
	push(@{$by_country{$cc}}, $addr);
}

for my $cc (keys(%by_country)) {
	my $file = "$prefix$cc$postfix";
	open my $output, '>', $file or die "open: $file: $!\n";
	print $output join("\n", @{$by_country{$cc}}, '');
	close $output;
}
