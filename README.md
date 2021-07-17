SUMMARY
=======
CCTLD - cctld tools is creating IP addresses table TSV-files with Country Code

`bin/makecctld.pl`
create Country Code list from iana.org.

`bin/makeiplist.pl`
create IP addresses table with country code from *nic delegate files.

`bin/makebycountry.pl`
create IP addresses table by country code.

`bin/cctld`
reads stdin and replace IP addresses with country code.


INSTALL
=======
0. install Perl module 'NET::Cidr' and 'Regexp::IPv6'

        % perl -MCPAN -e 'install Net::CIDR'
        % perl -MCPAN -e 'install Regexp::IPv6'

1. make

        % make
        wget -q -O - http://www.iana.org/domains/root/db/ | perl bin/makecctld.pl > cctld.txt || rm -f cctld.txt
        wget -q -O - http://ftp.apnic.net/stats/apnic/delegated-apnic-latest > delegated-apnic-latest || rm -f delegated-apnic-latest
        wget -q -O - http://ftp.apnic.net/stats/arin/delegated-arin-extended-latest > delegated-arin-extended-latest || rm -f delegated-arin-extended-latest
        wget -q -O - http://ftp.apnic.net/stats/ripe-ncc/delegated-ripencc-latest > delegated-ripencc-latest || rm -f delegated-ripencc-latest
        wget -q -O - http://ftp.apnic.net/stats/lacnic/delegated-lacnic-latest > delegated-lacnic-latest || rm -f delegated-lacnic-latest
        wget -q -O - http://ftp.apnic.net/stats/afrinic/delegated-afrinic-latest > delegated-afrinic-latest || rm -f delegated-afrinic-latest
        perl bin/makeiplist.pl -4 -C cctld.txt delegated-apnic-latest delegated-arin-extended-latest delegated-ripencc-latest delegated-lacnic-latest delegated-afrinic-latest > ip4.txt || rm -f ip4.txt
        perl bin/makeiplist.pl -4 -c  -C cctld.txt delegated-apnic-latest delegated-arin-extended-latest delegated-ripencc-latest delegated-lacnic-latest delegated-afrinic-latest > ip4.cidr.txt || rm -f ip4.cidr.txt
        perl bin/makeiplist.pl -6 -C cctld.txt delegated-apnic-latest delegated-arin-extended-latest delegated-ripencc-latest delegated-lacnic-latest delegated-afrinic-latest > ip6.txt || rm -f ip6.txt
        perl bin/makeiplist.pl -6 -c  -C cctld.txt delegated-apnic-latest delegated-arin-extended-latest delegated-ripencc-latest delegated-lacnic-latest delegated-afrinic-latest > ip6.cidr.txt || rm -f ip6.cidr.txt
        perl bin/makebycountry.pl cc/ .ip4 ip4.cidr.txt
        perl bin/makebycountry.pl cc/ .ip6 ip6.cidr.txt

2. confirm

        % head ip4.cidr.txt 
        1.0.0.0/24	AU	Australia
        1.0.1.0/24	CN	China
        1.0.2.0/23	CN	China
        1.0.4.0/22	AU	Australia
        1.0.8.0/21	CN	China
        1.0.16.0/20	JP	Japan
        1.0.32.0/19	CN	China
        1.0.64.0/18	JP	Japan
        1.0.128.0/17	TH	Thailand
        1.1.0.0/24	CN	China
        
        % head ip6.cidr.txt
        2001:200::/32	JP	Japan
        2001:208::/32	SG	Singapore
        2001:218::/32	JP	Japan
        2001:220::/32	KR	Korea, Republic of
        2001:230::/32	KR	Korea, Republic of
        2001:238::/32	TW	Taiwan, Province of China
        2001:240::/32	JP	Japan
        2001:250::/31	CN	China
        2001:252::/32	CN	China
        2001:254::/32	CN	China

3. copy bin/cctld to your $PATH

4. copy cctld.ip4 and cctld.txt to LIBRARY-PATH

        /usr/local/lib  or
        ~/lib           or
        $CCTLDLIB environment variable

        e.g.) cp cctld.ip4 /usr/local/lib


USAGE
----------
	% echo 219.94.233.133 | cctld
	219.94.233.133(JP)
	
	% cctld -l /var/log/httpd/access_log
	219.94.233.133(Japan) - - [13/Feb/2004:17:51:27 +0900] ...
	219.94.233.133(Japan) - - [13/Feb/2004:17:51:27 +0900] ...
	219.94.233.133(Japan) - - [13/Feb/2004:17:51:27 +0900] ...
	        :

Reference
---------
- http://www.iana.org/domains/root/db/
- http://www.apnic.net/ (http://ftp.apnic.net/stats/apnic/)
- http://www.arin.net/ (http://ftp.arin.net/pub/stats/arin/)
- http://www.ripe.net/ (http://ftp.ripe.net/ripe/stats/)
- http://lacnic.net/ (http://ftp.lacnic.net/pub/stats/lacnic/)
- http://afrinic.net/ (http://ftp.afrinic.net/pub/stats/afrinic/)
