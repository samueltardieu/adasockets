TESTS = value-localhost.test value-invalid.test \
	value-regular.test value-compressed.test \
	multicast_test
XFAIL_TESTS = value-invalid.test

all-local: multicast_test value

multicast_test: never
	$(GNATMAKE) -m -A../src -A$(top_srcdir)/src -I$(srcdir) multicast_test -cargs $(ADAFLAGS) -largs $(LDFLAGS)

value: never
	$(GNATMAKE) -m -A../src -A$(top_srcdir)/src -I$(srcdir) value -cargs $(ADAFLAGS) -largs $(LDFLAGS)

CLEANFILES = *.o *.ali b_*.c b~*.ad[bs]
DISTCLEANFILES = multicast_test value

EXTRA_DIST = *.test multicast_test.adb value.adb

never::
