#!/usr/local/bin/perl
#
# convert from
#  http://www.iana.org/domains/root/db/
# to
#  TSV format file

$/ = '</tr>';

while (<>) {
#	print "<<<$_>>>\n";

	s#<span[^>]+>##sg;
	s#</span>##sg;

	if (m#href="/domains/root/db/([A-Za-z]+)\.html">\.[A-Za-z]+</a></td>\s*<td>([^>]*)</td>\s*<td>([^<>]*)#s) {
		my ($cctld, $type, $descr) = ($1, $2, $3);
		if ($type eq 'country-code') {
			$descr =~ s/[\x00-\x1f\x7f]/ /sg;
			print uc($cctld), "\t", $descr, "\n";
		}
	}
}
