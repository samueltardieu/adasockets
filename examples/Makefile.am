all-local: tcprelay listener multi stream_listener stream_sender value

tcprelay: never
	$(GNATMAKE) -m -A../src -A$(top_srcdir)/src -I$(srcdir) tcprelay -cargs $(ADAFLAGS)

listener: never
	$(GNATMAKE) -m -A../src -A$(top_srcdir)/src -I$(srcdir) listener -cargs $(ADAFLAGS)

multi: never
	$(GNATMAKE) -m -A../src -A$(top_srcdir)/src -I$(srcdir) multi -cargs $(ADAFLAGS)

stream_listener: never
	$(GNATMAKE) -m -A../src -A$(top_srcdir)/src -I$(srcdir) stream_listener -cargs $(ADAFLAGS)

stream_sender: never
	$(GNATMAKE) -m -A../src -A$(top_srcdir)/src -I$(srcdir) stream_sender -cargs $(ADAFLAGS)

value: never
	$(GNATMAKE) -m -A../src -A$(top_srcdir)/src -I$(srcdir) value -cargs $(ADAFLAGS)

DISTCLEANFILES = tcprelay listener multi stream_listener stream_sender value
CLEANFILES = *.o *.ali b_*.c b~*.ad[bs]

EXTRA_DIST = Makefile.RTEMS Makefile.VMS \
	multi.adb rtems_init.c rtems_networkconfig.h stream_listener.adb \
	listener.adb stream_sender.adb tcprelay.adb value.adb

never::
