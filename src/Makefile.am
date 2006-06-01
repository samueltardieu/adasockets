privatelibdir = $(libdir)/adasockets

bin_SCRIPTS = adasockets-config

lib_LTLIBRARIES = libadasockets.la
libadasockets_la_SOURCES = $(ADA_SRCS)
libadasockets_la_LDFLAGS = -version-info $(LIBVERSIONINFO)

ADA_SRCS = \
	sockets-constants.ads \
	sockets-link.ads \
	sockets-multicast.ads \
	sockets-multicast.adb \
	sockets-naming.ads \
	sockets-naming.adb \
	sockets-stream_io.ads \
	sockets-stream_io.adb \
	sockets-thin.ads \
	sockets-types.ads \
	sockets-utils.ads \
	sockets-utils.adb \
	sockets.ads \
	sockets.adb \
	$(ADA_SRCS_WIN)

ADA_OBJECTS = \
	sockets-constants.o \
	sockets-link.o \
	sockets-multicast.o \
	sockets-naming.o \
	sockets-stream_io.o \
	sockets-thin.o \
	sockets-types.o \
	sockets-utils.o \
	sockets.o

ALIS = $(ADA_OBJECTS:.o=.ali) $(ADA_OBJECTS_WIN:.o=.ali)

ADACOMPILER = $(top_builddir)/support/adacompiler

ADAFLAGS = -I. -I$(srcdir)

LINK = $(LIBTOOL) --tag=CC --mode=link $(CC) -o libadasockets.la

CLEANFILES = *.o *.ali
DISTCLEANFILES = b_split.c split constants_nodef \
		sockets-thin.ads sockets-thin.adb

constants_nodef: constants.c config.h
	$(CC) -I. -o constants_nodef $(srcdir)/constants.c

sockets-constants.ads: $(srcdir)/constants.sh split constants_nodef
	$(SHELL) $(srcdir)/constants.sh Sockets.Constants $(srcdir) \
	  sockets-constants.ads

split: $(srcdir)/split.adb
	$(GNATMAKE) -g -O2 $(srcdir)/split.adb

if WIN32
ADA_SRCS_WIN=	sockets-windows_link.ads sockets-windows_link.adb \
			sockets-thin.adb
ADA_OBJECTS_WIN=	sockets-windows_link.o
ADA_OBJECTS_WIN_LO=	$(ADA_OBJECTS_WIN:.o=.lo)

sockets-thin.ads: $(srcdir)/sockets-thin.ads.win32
	cp $(srcdir)/sockets-thin.ads.win32 sockets-thin.ads
	cp $(srcdir)/sockets-thin.adb.win32 sockets-thin.adb
else
sockets-thin.ads: $(srcdir)/sockets-thin.ads.unix
	cp -f $(srcdir)/sockets-thin.ads.unix sockets-thin.ads
endif

SUFFIXES = .ads .lo .ali

.ads.lo .ads.ali:
	@chmod a+x $(ADACOMPILER)
	if [ -f `echo $< | sed -e 's/s$$/b/'` ]; then \
	  $(LIBTOOL) --tag=CC --mode=compile $(ADACOMPILER) $(ADAFLAGS) \
	  `echo $< | sed -e 's/s$$/b/'`; \
	else \
	  $(LIBTOOL) --tag=CC --mode=compile $(ADACOMPILER) $(ADAFLAGS) $<; \
	fi

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
sockets-constants.lo:sockets-constants.ads sockets.ads 
sockets-link.lo:sockets-link.ads sockets.ads 
sockets-multicast.lo:sockets-constants.ads sockets-link.ads sockets-multicast.adb sockets-multicast.ads sockets-naming.ads sockets-thin.ads sockets-utils.ads sockets.adb sockets.ads sockets-types.ads
sockets-naming.lo:sockets-constants.ads sockets-naming.adb sockets-naming.ads sockets-thin.ads sockets-utils.ads sockets.ads sockets-types.ads
sockets-stream_io.lo:sockets-stream_io.adb sockets-stream_io.ads sockets.ads 
sockets-thin.lo:sockets-thin.ads sockets.ads sockets-types.ads
sockets-utils.lo:sockets-utils.adb sockets-utils.ads sockets.ads 
sockets.lo:sockets-constants.ads sockets-link.ads sockets-naming.ads sockets-thin.ads sockets-utils.ads sockets.adb sockets.ads sockets-types.ads
