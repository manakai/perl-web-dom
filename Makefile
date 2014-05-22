all: deps all-data

updatenightly: local/bin/pmbp.pl updatedata
	curl https://gist.githubusercontent.com/wakaba/34a71d3137a52abb562d/raw/gistfile1.txt | sh
	git add modules t_deps/modules
	perl local/bin/pmbp.pl --update
	git add config lib/

updatedata: clean-data all-data

## ------ Setup ------

GIT = git
WGET = wget
PERL = ./perl

deps: git-submodules pmbp-install

git-submodules:
	$(GIT) submodule update --init

local/bin/pmbp.pl:
	mkdir -p local/bin
	$(WGET) -O $@ https://raw.github.com/wakaba/perl-setupenv/master/bin/pmbp.pl
pmbp-upgrade: local/bin/pmbp.pl
	perl local/bin/pmbp.pl --update-pmbp-pl
pmbp-update: pmbp-upgrade
	perl local/bin/pmbp.pl --update
pmbp-install: pmbp-upgrade
	perl local/bin/pmbp.pl --install \
            --create-perl-command-shortcut perl \
            --create-perl-command-shortcut prove

## ------ Build ------

all-data: json-ps lib/Web/DOM/_Defs.pm
clean-data: clean-json-ps
	rm -fr local/elements.json

lib/Web/DOM/_Defs.pm: local/elements.json bin/generate-defs.pl
	$(PERL) bin/generate-defs.pl > $@
	perl -c $@

local/elements.json:
	$(WGET) -O $@ https://raw.githubusercontent.com/manakai/data-web-defs/master/data/elements.json

json-ps: local/perl-latest/pm/lib/perl5/JSON/PS.pm
clean-json-ps:
	rm -fr local/perl-latest/pm/lib/perl5/JSON/PS.pm
local/perl-latest/pm/lib/perl5/JSON/PS.pm:
	mkdir -p local/perl-latest/pm/lib/perl5/JSON
	$(WGET) -O $@ https://raw.githubusercontent.com/wakaba/perl-json-ps/master/lib/JSON/PS.pm

## ------ Tests ------

PROVE = ./prove

test: test-deps test-main

test-deps: deps

test-main:
	$(PROVE) t/object/*.t

## License: Public Domain.
