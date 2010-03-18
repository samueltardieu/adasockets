privatelibdir = $(libdir)/adasockets

bin_SCRIPTS = adasockets-config

lib_LTLIBRARIES = libadasockets.la
dist_libadasockets_la_SOURCES = \
	sockets-multicast.ads \
	sockets-multicast.adb \
	sockets-naming.ads \
	sockets-naming.adb \
	sockets-stream_io.ads \
	sockets-stream_io.adb \
	sockets-utils.ads \
	sockets-utils.adb \
	sockets.ads \
	sockets.adb

libadasockets_la_LDFLAGS = -version-info $(LIBVERSIONINFO)
libadasockets_la_LINK = $(LIBTOOL) --tag=CC --mode=link $(CC) \
	-o libadasockets.la

EXTRA_DIST = Makefile.RTEMS Makefile.VMS adasockets-config

ADA_OBJECTS = \
	sockets-multicast.o \
	sockets-naming.o \
	sockets-stream_io.o \
	sockets-utils.o \
	sockets.o

ALIS = $(ADA_OBJECTS:.o=.ali)

ADACOMPILER = $(top_srcdir)/support/adacompiler

ADAFLAGS = @ADAFLAGS@ -I. -I$(srcdir)

CLEANFILES = *.o *.ali b~*

SUFFIXES = .ads .lo .ali

.ads.lo:
	if [ -f `echo $< | sed -e 's/s$$/b/'` ]; then \
	  $(LIBTOOL) --tag=CC --mode=compile \
	  $(ADACOMPILER) $(GNATMAKE) $(ADAFLAGS) \
	  `echo $< | sed -e 's/s$$/b/'`; \
	else \
	  $(LIBTOOL) --tag=CC --mode=compile \
	  $(ADACOMPILER) $(GNATMAKE) $(ADAFLAGS) $<; \
	fi

.lo.ali:

install-data-local: all
	rm -rf $(DESTDIR)$(privatelibdir)
	$(mkinstalldirs) $(DESTDIR)$(privatelibdir)
	$(INSTALL) -m 444 $(ALIS) $(DESTDIR)$(privatelibdir)
	for i in $(dist_libadasockets_la_SOURCES) $(nodist_libadasockets_la_SOURCES); do \
	  if test -f $$i; then \
	    $(INSTALL) -m 644 $$i $(DESTDIR)$(privatelibdir); \
	  else \
	    $(INSTALL) -m 644  $(srcdir)/$$i $(DESTDIR)$(privatelibdir); \
	  fi \
	done

uninstall-local:
	rm -rf $(DESTDIR)$(privatelibdir)

### DO NOT REMOVE THIS LINE, IT IS USED BY MAKEDEPEND ###
sockets-multicast.o : sockets.ads sockets-multicast.ads sockets-multicast.adb \
 sockets-utils.ads
sockets.o : sockets.ads sockets.adb sockets-utils.ads
sockets-utils.o : sockets.ads sockets-utils.ads sockets-utils.adb
sockets-stream_io.o : sockets.ads sockets-stream_io.ads sockets-stream_io.adb
