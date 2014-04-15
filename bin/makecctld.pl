#!/usr/local/bin/perl
#
# convert from
#  http://www.iana.org/domains/root/db/
# to
#  TSV format file

$/ = '</tr>';

while (<>) {
#	print "<<<$_>>>\n";

	if (m#href="/domains/root/db/([A-Za-z]+)\.html">\.[A-Za-z]+</a></span></td>\s*<td>([^>]*)</td>\s*<!-- <td>([^>]*)<br/><#s) {
		my ($cctld, $type, $descr) = ($1, $2, $3);
		if ($type eq 'country-code') {
			$descr =~ s/[\x00-\x1f\x7f]/ /sg;
			print uc($1), "\t", $descr, "\n";
		}
	}
}
