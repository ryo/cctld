# master site
#APNIC_URL	= http://ftp.apnic.net/stats/apnic/
#ARIN_URL	= ftp://ftp.arin.net/pub/stats/arin/
#RIPE_URL	= ftp://ftp.ripe.net/ripe/stats/
#LACNIC_URL	= ftp://lacnic.net/pub/stats/lacnic/
#AFRINIC_URL	= ftp://ftp.afrinic.net/pub/stats/afrinic/

# mirror site
APNIC_URL	= http://ftp.apnic.net/stats/apnic/
ARIN_URL	= http://ftp.apnic.net/stats/arin/
RIPE_URL	= http://ftp.apnic.net/stats/ripe-ncc/
LACNIC_URL	= http://ftp.apnic.net/stats/lacnic/
AFRINIC_URL	= http://ftp.apnic.net/stats/afrinic/

# iana
IANA_ROOTDB_URL	= http://www.iana.org/domains/root/db/

APNIC		= delegated-apnic-latest
ARIN		= delegated-arin-extended-latest
RIPE		= delegated-ripencc-latest
LACNIC		= delegated-lacnic-latest
AFRINIC		= delegated-afrinic-latest

DELEGATEFILE	= $(APNIC) $(ARIN) $(RIPE) $(LACNIC) $(AFRINIC)
HTTPGET 	= wget -q -O -
#HTTPGET 	= curl -s -o -
PERL		= perl
LIST		= ip4.txt ip4.cidr.txt ip6.txt ip6.cidr.txt

all: $(LIST) bycountry

fetch: $(DELEGATEFILE)

rebuild: clean-txt $(LIST)

cctld.txt:
	${HTTPGET} ${IANA_ROOTDB_URL} | ${PERL} bin/makecctld.pl > $@ || rm -f $@

$(APNIC):
	${HTTPGET} ${APNIC_URL}${APNIC} > $@ || rm -f $@
$(ARIN):
	${HTTPGET} ${ARIN_URL}${ARIN} > $@ || rm -f $@
$(RIPE):
	${HTTPGET} ${RIPE_URL}${RIPE} > $@ || rm -f $@
$(LACNIC):
	${HTTPGET} ${LACNIC_URL}${LACNIC} > $@ || rm -f $@
$(AFRINIC):
	${HTTPGET} ${AFRINIC_URL}${AFRINIC} > $@ || rm -f $@
$(IANA):
	${HTTPGET} ${IANA_URL}${IANA} > $@ || rm -f $@

ip4.txt: cctld.txt $(DELEGATEFILE)
	${PERL} bin/makeiplist.pl -4 -C cctld.txt $(DELEGATEFILE) > $@ || rm -f $@

ip6.txt: cctld.txt $(DELEGATEFILE)
	${PERL} bin/makeiplist.pl -6 -C cctld.txt $(DELEGATEFILE) > $@ || rm -f $@

ip4.cidr.txt: cctld.txt $(DELEGATEFILE)
	${PERL} bin/makeiplist.pl -4 -c  -C cctld.txt $(DELEGATEFILE) > $@ || rm -f $@

ip6.cidr.txt: cctld.txt $(DELEGATEFILE)
	${PERL} bin/makeiplist.pl -6 -c  -C cctld.txt $(DELEGATEFILE) > $@ || rm -f $@

clean-delegate:
	rm -f $(DELEGATEFILE)

clean-txt:
	rm -f cctld.txt $(LIST)

clean-cc:
	rm -f cc/*

clean: clean-delegate clean-txt

bycountry: ip4.cidr.txt ip6.cidr.txt
	${PERL} bin/makebycountry.pl cc/ .ip4 ip4.cidr.txt
	${PERL} bin/makebycountry.pl cc/ .ip6 ip6.cidr.txt
