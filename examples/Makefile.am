all-local: tcprelay listener multi stream_listener stream_sender

tcprelay: never
	$(GNATMAKE) -m -A../src -A$(top_srcdir)/src -I$(srcdir) tcprelay -cargs $(ADAFLAGS) -largs $(LDFLAGS)

listener: never
	$(GNATMAKE) -m -A../src -A$(top_srcdir)/src -I$(srcdir) listener -cargs $(ADAFLAGS) -largs $(LDFLAGS)

multi: never
	$(GNATMAKE) -m -A../src -A$(top_srcdir)/src -I$(srcdir) multi -cargs $(ADAFLAGS) -largs $(LDFLAGS)

stream_listener: never
	$(GNATMAKE) -m -A../src -A$(top_srcdir)/src -I$(srcdir) stream_listener -cargs $(ADAFLAGS) -largs $(LDFLAGS)

stream_sender: never
	$(GNATMAKE) -m -A../src -A$(top_srcdir)/src -I$(srcdir) stream_sender -cargs $(ADAFLAGS) -largs $(LDFLAGS)

DISTCLEANFILES = tcprelay listener multi stream_listener stream_sender
CLEANFILES = *.o *.ali b_*.c b~*.ad[bs]

EXTRA_DIST = Makefile.RTEMS Makefile.VMS \
	multi.adb rtems_init.c rtems_networkconfig.h stream_listener.adb \
	listener.adb stream_sender.adb tcprelay.adb

never::
