privatelibdir = $(libdir)/adasockets

bin_SCRIPTS = adasockets-config

lib_LTLIBRARIES = libadasockets.la
libadasockets_la_SOURCES = $(ADA_SRCS)
libadasockets_la_LDFLAGS = -version-info $(LIBVERSIONINFO)
libadasockets_la_LINK = $(LIBTOOL) --tag=CC --mode=link $(CC) \
	-o libadasockets.la

ADA_SRCS = \
	sockets-link.ads \
	sockets-multicast.ads \
	sockets-multicast.adb \
	sockets-naming.ads \
	sockets-naming.adb \
	sockets-stream_io.ads \
	sockets-stream_io.adb \
	sockets-utils.ads \
	sockets-utils.adb \
	sockets.ads \
	sockets.adb \
	$(ADA_SRCS_WIN)

ADA_OBJECTS = \
	sockets-link.o \
	sockets-multicast.o \
	sockets-naming.o \
	sockets-stream_io.o \
	sockets-utils.o \
	sockets.o

ALIS = $(ADA_OBJECTS:.o=.ali) $(ADA_OBJECTS_WIN:.o=.ali)

ADACOMPILER = $(top_srcdir)/support/adacompiler

ADAFLAGS = @ADAFLAGS@ -I. -I$(srcdir)

CLEANFILES = *.o *.ali

if WIN32
ADA_SRCS_WIN=	sockets-windows_link.ads sockets-windows_link.adb
ADA_OBJECTS_WIN=	sockets-windows_link.o
ADA_OBJECTS_WIN_LO=	$(ADA_OBJECTS_WIN:.o=.lo)
endif

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
	for i in $(ADA_SRCS); do \
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
sockets.o : sockets.ads sockets.adb sockets-link.ads sockets-utils.ads
sockets-utils.o : sockets.ads sockets-utils.ads sockets-utils.adb
sockets-link.o : sockets.ads sockets-link.ads
sockets-stream_io.o : sockets.ads sockets-stream_io.ads sockets-stream_io.adb
