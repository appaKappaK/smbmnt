# smbmnt Makefile
# Installs the script, man page, and bash completion.
# Targets: install, uninstall, check

SHELL        := /bin/bash
PREFIX       ?= /usr/local
BINDIR       := $(PREFIX)/bin
MANDIR       := $(PREFIX)/share/man/man1
COMPDIR      := $(PREFIX)/share/bash-completion/completions

SCRIPT       := smbmnt-stable
BIN_NAME     := smbmnt
MAN_PAGE     := smbmnt.1
COMP_FILE    := completions/smbmnt

.PHONY: all install uninstall check

all:
	@echo "Targets: install, uninstall, check"

## install: Copy binary, man page, and completion file into place.
install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 $(SCRIPT) $(DESTDIR)$(BINDIR)/$(BIN_NAME)
	install -d $(DESTDIR)$(MANDIR)
	install -m 644 $(MAN_PAGE) $(DESTDIR)$(MANDIR)/$(MAN_PAGE)
	gzip -f $(DESTDIR)$(MANDIR)/$(MAN_PAGE)
	@if [ -f $(COMP_FILE) ]; then \
	    install -d $(DESTDIR)$(COMPDIR); \
	    install -m 644 $(COMP_FILE) $(DESTDIR)$(COMPDIR)/$(BIN_NAME); \
	    echo "Installed bash completion to $(DESTDIR)$(COMPDIR)/$(BIN_NAME)"; \
	fi
	@echo "Installed $(BIN_NAME) to $(DESTDIR)$(BINDIR)/$(BIN_NAME)"
	@echo "Installed man page to $(DESTDIR)$(MANDIR)/$(MAN_PAGE).gz"

## uninstall: Remove all installed files.
uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(BIN_NAME)
	rm -f $(DESTDIR)$(MANDIR)/$(MAN_PAGE).gz
	rm -f $(DESTDIR)$(COMPDIR)/$(BIN_NAME)
	@echo "Uninstalled $(BIN_NAME)"

## check: Verify runtime dependencies are present.
check:
	@echo "Checking runtime dependencies..."
	@command -v mountpoint >/dev/null 2>&1 \
	    && echo "  [ok] mountpoint" \
	    || echo "  [MISSING] mountpoint  (install util-linux)"
	@command -v mount.cifs >/dev/null 2>&1 \
	    && echo "  [ok] mount.cifs" \
	    || echo "  [MISSING] mount.cifs  (install cifs-utils)"
	@command -v smbclient >/dev/null 2>&1 \
	    && echo "  [ok] smbclient  (optional — needed for -Ss)" \
	    || echo "  [missing] smbclient  (optional — needed for -Ss)"
	@command -v nmap >/dev/null 2>&1 \
	    && echo "  [ok] nmap  (optional — needed for -S)" \
	    || echo "  [missing] nmap  (optional — needed for -S)"
