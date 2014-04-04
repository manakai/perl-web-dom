# -*- Makefile -*-

all:

updatenightly: local/bin/pmbp.pl
	curl https://gist.githubusercontent.com/motemen/667573/raw/git-submodule-track | sh
	git add modules t_deps/modules
	perl local/bin/pmbp.pl --update
	git add config

## ------ Setup ------

GIT = git
WGET = wget

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

## ------ Tests ------

PROVE = ./prove

test: test-deps test-main

test-deps: deps

test-main:
	$(PROVE) t/object/*.t

## License: Public Domain.
