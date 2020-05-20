EMACS_PROG ?= emacs
EMACS_FLAGS ?= -Q --batch
EMACS_CMD ::= $(EMACS_PROG) $(EMACS_FLAGS)

ORG_FILES ::= $(wildcard *.org)
FILES ::=
FILES += $(patsubst %.org, %.sh, $(ORG_FILES)) # scripts

.PHONY: all prune clean update install

all: $(FILES)

prune:
	rm -f *.sh\~ *.org\~

clean: prune
	rm -f *.sh

%.sh: %.org
	$(EMACS_CMD) $< --eval="(org-mode)" -f org-babel-tangle # tangle install script

update:
	git submodule update --recursive --remote
	git -C doom-emacs remote add upstream https://github.com/hlissner/doom-emacs.git || true
	git -C doom-emacs fetch --all
	git -C doom-emacs merge upstream/develop # update-doom-emacs
	./doom-emacs/bin/doom upgrade # update-packages

install: README.sh
	./$< || true # run install script
	./doom-emacs/bin/doom sync # install doom
