#!/usr/local/bin/perl

use strict;
use warnings;
use Getopt::Std;
use Net::CIDR::Set;
use Data::Dumper;

sub usage {
	(my $__prog = $0) =~ s,.*/,,;
	die <<__USAGE__;
usage: $__prog [-46c] [-C cctld.txt] [delegate-file [...]]
	-4		output IPv4 address list (default)
	-6		output IPv6 address list
	-c		output CIDR format (e.g. "10.0.0.0/8", "3ffe::/16")
	-C cctld.txt	cctld file
	-U		don't unify
__USAGE__
}

my %opts;
getopts('46C:cU', \%opts) or usage();

($opts{4} or $opts{6}) or ($opts{4} = 1);

my %cctld;
if (exists $opts{C}) {
	open(my $fh, $opts{C}) or die "open: $opts{C}: $!\n";
	while (<$fh>) {
		chop;
		my ($cc, $country) = split(/\t/, $_, 2);
		$cctld{$cc} = $country;
	}
	close($fh);
}

my @ip4_result;
my @ip6_result;
while (<>) {
	chop;
	my ($registry, $cc, $type, $address, $range, $date, $status, $ext) = split(/\|/, $_);

	next if (!defined $cc || ($cc eq '*'));

	if ((exists $opts{4}) && ($type =~ m/ipv4/)) {
		# Net::CIDR cannot treat {"192.168.0.0", "256"} format...
		my $n_start = IP4toN($address);
		my $n_end = $n_start + $range - 1;
		my $address_end = NtoIP4($n_end);

		push(@ip4_result, {
		    'N' => expand_ip4($address),	# sortable string
		    'begin' => $address,
		    'end' => $address_end,
		    'cc' => $cc,
		});
	}

	if ((exists $opts{6}) && ($type =~ m/ipv6/)) {
		my $cidr = Net::CIDR::Set->new({type => 'ipv6'}, "$address/$range");
		my ($address_begin, $address_end) = split('-', ($cidr->as_range_array(2))[0], 2);
		push(@ip6_result, {
		    'N' => expand_ip6($address_begin),	# sortable string
		    'begin' => $address_begin,
		    'end' => $address_end,
		    'cc' => $cc,
		});
	}
}

output_result('ipv4', @ip4_result) if (exists $opts{4});
output_result('ipv6', @ip6_result) if (exists $opts{6});

exit;



sub output_result {
	my ($type, @result) = @_;

	my $lastcc = '?';
	my $cidr;

	for my $entry (sort { $a->{N} cmp $b->{N} } @result) {
		if (!defined $cidr) {
			$cidr = Net::CIDR::Set->new({type => $type}, join("-", @$entry{qw(begin end)}));
		} elsif ($lastcc eq $entry->{cc}) {
			$cidr->add(join("-", @$entry{qw(begin end)}));
		} else {
			output_cidr($cidr, $lastcc);
			$cidr = Net::CIDR::Set->new({type => $type}, join("-", @$entry{qw(begin end)}));
		}
		$lastcc = $entry->{cc};

		if (exists($opts{U})) {
			output_cidr($cidr, $lastcc);
			undef $cidr;
		}
	}

	if (defined $cidr) {
		output_cidr($cidr, $lastcc);
	}
}

sub output_cidr {
	my ($cidr, $cc) = @_;

	if (exists($opts{c})) {
		my $iter = $cidr->iterate_cidr;
		while (my $addr = $iter->()) {
			printf "%s	%s	%s\n",
			    $addr,
			    $cc,
			    exists $cctld{$cc} ? $cctld{$cc} : "-";
		}
	} else {
		for my $range ($cidr->as_range_array(2)) {
			my ($begin, $end) = split('-', $range, 2);

			printf "%s	%s	%s	%s\n",
			    $begin, $end,
			    $cc,
			    exists $cctld{$cc} ? $cctld{$cc} : "-";
		}
	}
}

#
# - convert ip6 addr to sortable string
#
# e.g.) expand_ip6("3ffe:507:108::1")
#       -> "3ffe:0507:0108:0000:0000:0000:0000:0001"
#
sub expand_ip6 {
	my $ip = shift;

	$ip =~ s/:://;
	my @a16 = split(/:/, $ip);
	$ip =~ s//":" x (7 - $#a16)/e;
	$ip =~ s/:$/:0/;
	@a16 = split(/:/, $ip);

	map { $_ = sprintf("%04x", hex($_) + 0) } @a16;

	join(":", @a16);
}

sub expand_ip4 {
	my $ip4addr = shift;
	sprintf("0x%08x", IP4toN($ip4addr));	# hexadecimal
}

sub IP4toN {
	my $ip4addr = shift;
	unpack("N", pack("CCCC", split(/\./, $ip4addr, 4)));
}

sub NtoIP4 {
	my $n = shift;
	sprintf("%d.%d.%d.%d", unpack("CCCC", pack("N", $n)));
}
