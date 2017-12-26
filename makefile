SHELL = /bin/sh

# Compilation Variables
ERL = $(shell which erl)
ERLC = $(shell which erlc)
ERLFLAGS = -Werror -v -o
DEBUGFLAGS = -Ddebug +debug_info -W0 -o

# Directory Variables
SRCDIR = src
OUTDIR = ebin
DEBUGDIR = edebug
TESTDIR = etesting
UTILDIR = util

# Utility Variables
DIALYZER = $(shell which dialyzer)
ELVIS = $(UTILDIR)/elvis rock --config $(UTILDIR)/elvis.config

# Colors
RED = \033[0;31m
GREEN = \033[0;32m
BLUE = \033[0;34m
ORANGE = \033[0;33m
PURPLE = \033[0;35m
CYAN = \033[0;36m
NORMAL = \033[0m

release:
	@ echo "$(GREEN)==> Building RELEASE$(NORMAL)"
	@ echo "    Compiling files with debug_info disabled"
	@ echo "    Compiling files with warnings being considered errors"
	@ echo "    Compiling files will fail if any errors occur"
	@ mkdir -p $(OUTDIR)
	@ rm -f $(OUTDIR)/*
	@ echo "$(GREEN)==> Compiling Source Files$(RED)"
	@ $(ERLC) $(ERLFLAGS) $(OUTDIR) $(SRCDIR)/*.erl
	@ echo "$(NORMAL)    Done"
	@ echo "$(GREEN)==> Building Erlpkg Binary$(NORMAL)"
	@ cd $(OUTDIR) && ($(ERL) -pa $(OUTDIR) -noinput -noshell -s erlpkg main erlpkg.beam pkgargs.beam >> /dev/null) && cd ..
	@ rm -f $(OUTDIR)/*.beam
	@ mv $(OUTDIR)/erlpkg.erlpkg $(OUTDIR)/erlpkg
	@ echo "$(NORMAL)    Done"
	@ echo "$(GREEN)==> RELEASE release successfully built in './$(OUTDIR)/'$(NORMAL)"
	@ echo "    Done\n"
debug:
	@ echo "$(BLUE)==> Building DEBUG$(NORMAL)"
	@ echo "    Compiling files with debug_info enabled"
	@ echo "    Compiling files with warnings ignored"
	@ echo "    Compiling files will fail if any errors occur"
	@ mkdir -p $(DEBUGDIR)
	@ rm -f $(DEBUGDIR)/*
	@ echo "$(BLUE)==> Compiling Source Files$(RED)"
	@ $(ERLC) $(DEBUGFLAGS) $(DEBUGDIR) $(SRCDIR)/*.erl
	@ echo "$(NORMAL)    Done"
	@ echo "$(BLUE)==> Building Erlpkg Binary"
	@ cd $(DEBUGDIR)
	@ cd $(DEBUGDIR) && ($(ERL) -pa $(DEBUGDIR) -noinput -noshell -s erlpkg main erlpkg.beam pkgargs.beam >> /dev/null) && cd ..
	@ rm -f $(DEBUGDIR)/*.beam
	@ mv $(DEBUGDIR)/erlpkg.erlpkg $(DEBUGDIR)/erlpkg
	@ echo "$(NORMAL)    Done"
	@ echo "$(BLUE)==> DEBUG release successfully built in './$(DEBUGDIR)/'$(NORMAL)"
	@ echo "    Done\n"
test:
	@ echo "$(PURPLE)==> Building TEST$(NORMAL)"
	@ echo "    Compiling files with debug_info enabled"
	@ echo "    Compiling files with warnings ignored"
	@ echo "    Compiling files will fail if any errors occur"
	@ mkdir -p $(TESTDIR)
	@ rm -f $(TESTDIR)/*
	@ echo "$(PURPLE)==> Compiling Source Files$(RED)"
	@ $(ERLC) $(DEBUGFLAGS) $(TESTDIR) $(SRCDIR)/*.erl
	@ echo "$(NORMAL)    Done"
	@ echo "$(PURPLE)==> Running Dialyzer$(NORMAL)"
	@ $(DIALYZER) $(TESTDIR)/*.beam || true
	@ echo "$(PURPLE)==> Running Elvis$(NORMAL)"
	@ $(ELVIS) || true
	@ echo "$(PURPLE)==> Finished Testing, results are printed to console$(NORMAL)"
	@ echo "    Done\n"
.PHONY: lint
lint:
	@ echo "==> Linting Project with Elvis"
	@ $(ELVIS) || true
.PHONY: clean
clean:
	@ echo "$(ORANGE)==> Cleaning builds"
	@ find . -name "*.beam" -delete
	@ echo "==> Removing all BEAM files from workspace"
	@ find . -name "*.dump" -delete
	@ echo "==> Removing all DUMP files from workspace"
	@ rm -rf $(OUTDIR)
	@ echo "==> Removing $(OUTDIR)/"
	@ rm -rf $(DEBUGDIR)
	@ echo "==> Removing $(DEBUGDIR)/"
	@ rm -rf $(TESTDIR)
	@ echo "==> Removing $(TESTDIR)/"
	@ echo "==> Cleaned\n$(NORMAL)"
