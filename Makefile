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
	git -C spacemacs remote add upstream https://github.com/syl20bnr/spacemacs.git || true
	git -C spacemacs fetch --all
	git -C spacemacs merge upstream/develop # update-spacemacs
	$(EMACS_PROG) --eval="(progn (configuration-layer/update-packages) (save-buffers-kill-terminal))" # update-packages

install: README.sh
	./$< || true # run install script
