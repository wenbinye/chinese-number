EMACS = emacs
EMACSFLAGS =
CASK = cask

OBJECTS = chinese-number.elc

elpa:
	$(CASK) install
	$(CASK) update
	touch $@

.PHONY: build
build : elpa $(OBJECTS)

.PHONY: byte-compile-strict
byte-compile-strict : elpa
	$(CASK) exec $(EMACS) --no-site-file --no-site-lisp --batch \
		--directory "."                          \
		$(EMACSFLAGS)                            \
		--eval "(progn                           \
			(setq byte-compile-error-on-warn t)  \
			(batch-byte-compile))" chinese-number.el

.PHONY: test
test : byte-compile-strict
	$(CASK) exec $(EMACS) --no-site-file --no-site-lisp --batch \
		$(EMACSFLAGS) \
		-l chinese-number.el -l chinese-number-test.el --eval '(ert-run-tests-batch-and-exit t)'

.PHONY: clean
clean :
	rm -f $(OBJECTS)
	rm -f elpa
	rm -rf .cask # Clean packages installed for development

%.elc : %.el
	$(CASK) exec $(EMACS) --no-site-file --no-site-lisp --batch \
		$(EMACSFLAGS) \
		-f batch-byte-compile $<
