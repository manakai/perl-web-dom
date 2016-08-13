all: deps build

CURL = curl
GIT = git
WGET = wget
PERL = ./perl
PMBP_OPTIONS =

updatenightly: local/bin/pmbp.pl updatedata
	$(CURL) -f -l https://gist.githubusercontent.com/wakaba/34a71d3137a52abb562d/raw/gistfile1.txt | sh
	git add t_deps/modules
	perl local/bin/pmbp.pl --update
	git add config lib/

updatedata: clean build

clean: clean-data
	rm -fr lib/Web/DOM/_CharClasses.pm

## ------ Setup ------

deps: git-submodules pmbp-install

git-submodules:
	$(GIT) submodule update --init

local/bin/pmbp.pl:
	mkdir -p local/bin
	$(WGET) -O $@ https://raw.github.com/wakaba/perl-setupenv/master/bin/pmbp.pl
pmbp-upgrade: local/bin/pmbp.pl
	perl local/bin/pmbp.pl $(PMBP_OPTIONS) --update-pmbp-pl
pmbp-update: pmbp-upgrade
	perl local/bin/pmbp.pl $(PMBP_OPTIONS) --update
pmbp-install: pmbp-upgrade
	perl local/bin/pmbp.pl $(PMBP_OPTIONS) --install \
            --create-perl-command-shortcut perl \
            --create-perl-command-shortcut prove

## ------ Build ------

build: all-data lib/Web/DOM/_CharClasses.pm

all-data: json-ps lib/Web/DOM/_Defs.pm
clean-data: clean-json-ps
	rm -fr local/elements.json

lib/Web/DOM/_Defs.pm: local/elements.json bin/generate-defs.pl \
    local/dom-events.json
	$(PERL) bin/generate-defs.pl > $@
	perl -c $@

local/elements.json:
	$(WGET) -O $@ https://raw.githubusercontent.com/manakai/data-web-defs/master/data/elements.json

local/dom-events.json:
	$(WGET) -O $@ https://raw.githubusercontent.com/manakai/data-web-defs/master/data/dom-events.json

json-ps: local/perl-latest/pm/lib/perl5/JSON/PS.pm
clean-json-ps:
	rm -fr local/perl-latest/pm/lib/perl5/JSON/PS.pm
local/perl-latest/pm/lib/perl5/JSON/PS.pm:
	mkdir -p local/perl-latest/pm/lib/perl5/JSON
	$(WGET) -O $@ https://raw.githubusercontent.com/wakaba/perl-json-ps/master/lib/JSON/PS.pm

lib/Web/DOM/_CharClasses.pm:
	echo 'package Web::DOM::Internal;' > $@;
	$(CURL) -f -l https://chars.suikawiki.org/set/perlrevars?item=InNameStartChar=%24xml10-5e%3ANameStartChar >> $@
	$(CURL) -f -l https://chars.suikawiki.org/set/perlrevars?item=InNameChar=%24xml10-5e%3ANameChar >> $@
	$(CURL) -f -l https://chars.suikawiki.org/set/perlrevars?item=InNCNameStartChar=%24xml10-5e%3ANCNameStartChar >> $@
	$(CURL) -f -l https://chars.suikawiki.org/set/perlrevars?item=InNCNameChar=%24xml10-5e%3ANCNameChar >> $@
	$(CURL) -f -l https://chars.suikawiki.org/set/perlrevars?item=InPCENChar=%24html%3APCENChar >> $@
	echo '1;' >> $@
	$(PERL) -c $@

## ------ Tests ------

PROVE = ./prove

test: test-deps test-main

test-deps: deps

test-main:
	$(PROVE) t/object/*.t

## License: Public Domain.
