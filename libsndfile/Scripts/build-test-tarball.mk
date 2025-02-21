#!/usr/bin/make -f

# This is probably only going to work with GNU Make.
# This in a separate file instead of in Makefile.am because Automake complains
# about the GNU Make-isms.

EXEEXT = 

PACKAGE_VERSION = 1.0.27

HOST_TRIPLET = x86_64-pc-linux-gnu

SRC_BINDIR = src/
TEST_BINDIR = tests/

LIBRARY := $(SRC_BINDIR)libsndfile.so.$(LIB_VERSION)

LIB_VERSION := $(shell echo $(PACKAGE_VERSION) | sed -e 's/[a-z].*//')

TESTNAME = libsndfile-testsuite-$(HOST_TRIPLET)-$(PACKAGE_VERSION)

TARBALL = $(TESTNAME).tar.gz

# Find the test programs by grepping the script for the programs it executes.
testprogs := $(shell grep '^\./' tests/test_wrapper.sh | sed -e "s|./||" -e "s/ .*//" | sort | uniq)
# Also add the programs not found by the above.
testprogs += sfversion stdin_test stdout_test cpp_test win32_test

# Find the single test program in src/ .
srcprogs := $(shell if test -x src/.libs/test_main$(EXEEXT) ; then echo "src/.libs/test_main$(EXEEXT)" ; else echo "src/test_main$(EXEEXT)" ; fi)

libfiles := $(shell if test ! -z $(EXEEXT) ; then echo "src/libsndfile-1.def src/.libs/libsndfile-1.dll" ; elif test -f $(LIBRARY) ; then echo $(LIBRARY) ; fi  ; fi)

testbins := $(addprefix $(TEST_BINDIR),$(subst ,$(EXEEXT),$(testprogs))) $(libfiles) $(srcprogs)


all : $(TARBALL)

clean :
	rm -rf $(TARBALL) $(TESTNAME)/

check : $(TESTNAME)/test_wrapper.sh
	(cd ./$(TESTNAME)/ && ./test_wrapper.sh)

$(TARBALL) : $(TESTNAME)/test_wrapper.sh
	tar zcf $@ $(TESTNAME)
	rm -rf $(TESTNAME)
	@echo
	@echo "Created : $(TARBALL)"
	@echo

$(TESTNAME)/test_wrapper.sh : $(testbins) tests/test_wrapper.sh tests/pedantic-header-test.sh
	rm -rf $(TESTNAME)
	mkdir -p $(TESTNAME)/tests/
	cp $(testbins) $(TESTNAME)/tests/
	cp tests/test_wrapper.sh $(TESTNAME)/
	cp tests/pedantic-header-test.sh $(TESTNAME)/tests/
	chmod u+x $@

tests/test_wrapper.sh : tests/test_wrapper.sh.in
	(cd tests/ ; make $@)
