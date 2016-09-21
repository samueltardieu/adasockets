CCLD = $(CC)

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
nodist_libadasockets_la_SOURCES = \
	sockets-thin.ads \
	sockets-constants.ads \
	sockets-link.ads \
	sockets-types.ads
libadasockets_la_LDFLAGS = -version-info $(LIBVERSIONINFO)

EXTRA_DIST = Makefile.RTEMS Makefile.VMS sockets-vms_link.ads \
	sockets-windows_link.ads sockets-windows_link.adb \
	sockets-link.ads.vms \
	sockets-thin.adb.vms sockets-thin.adb.win32 \
	sockets-thin.ads.unix sockets-thin.ads.vms sockets-thin.ads.win32 \
	constants.c constants.sh \
	split.adb adasockets-config

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

ALIS = $(ADA_OBJECTS:.o=.ali)

ADACOMPILER = $(top_srcdir)/support/adacompiler

ADAFLAGS = @ADAFLAGS@ -I. -I$(srcdir)

CLEANFILES = *.o *.ali b~*
DISTCLEANFILES = b_split.c split constants_nodef \
		sockets-thin.ads sockets-thin.adb \
		sockets-constants.ads

constants_nodef: constants.c config.h
	$(CC) -I. -o constants_nodef $(srcdir)/constants.c $(CFLAGS) $(CPPFLAGS) $(LDFLAGS)

sockets-constants.ads: $(srcdir)/constants.sh split constants_nodef
	$(SHELL) $(srcdir)/constants.sh Sockets.Constants $(srcdir) \
	  sockets-constants.ads "$(CC)"

split: $(srcdir)/split.adb
	$(GNATMAKE) $(srcdir)/split.adb -cargs $(ADAFLAGS) -largs $(LDFLAGS)

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = adasockets.pc

if WIN32
nodist_libadasockets_la_SOURCES += \
	sockets-windows_link.ads sockets-windows_link.adb \
	sockets-thin.adb
ADA_OBJECTS +=	sockets-windows_link.o

sockets-thin.ads: $(srcdir)/sockets-thin.ads.win32
	cp -p $(srcdir)/sockets-thin.ads.win32 sockets-thin.ads
	cp -p $(srcdir)/sockets-thin.adb.win32 sockets-thin.adb
else
sockets-thin.ads: $(srcdir)/sockets-thin.ads.unix
	cp -p -f $(srcdir)/sockets-thin.ads.unix sockets-thin.ads
endif

SUFFIXES = .ads .lo .ali

.ads.lo:
	if [ -f `echo $< | sed -e 's/s$$/b/'` ]; then \
	  $(LIBTOOL) --tag=CC --mode=compile \
	  $(ADACOMPILER) $(GNATMAKE) -cargs $(ADAFLAGS) -largs $(LDFLAGS) -margs \
	  `echo $< | sed -e 's/s$$/b/'`; \
	else \
	  $(LIBTOOL) --tag=CC --mode=compile \
	  $(ADACOMPILER) $(GNATMAKE) -cargs $(ADAFLAGS) -largs $(LDFLAGS) -margs $<; \
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
sockets-multicast.lo : sockets.ads sockets.adb sockets-constants.ads \
 sockets-link.ads sockets-multicast.ads sockets-multicast.adb \
 sockets-naming.ads sockets-thin.ads sockets-types.ads sockets-utils.ads
sockets.lo : sockets.ads sockets.adb sockets-constants.ads sockets-link.ads \
 sockets-naming.ads sockets-thin.ads sockets-types.ads sockets-utils.ads
sockets-constants.lo : sockets.ads sockets-constants.ads
sockets-naming.lo : sockets.ads sockets-constants.ads sockets-naming.ads \
 sockets-naming.adb sockets-thin.ads sockets-types.ads sockets-utils.ads
sockets-thin.lo : sockets.ads sockets-thin.ads sockets-types.ads
sockets-types.lo : sockets.ads sockets-types.ads
sockets-utils.lo : sockets.ads sockets-thin.ads sockets-types.ads \
 sockets-utils.ads sockets-utils.adb
sockets-link.lo : sockets.ads sockets-link.ads
sockets-stream_io.lo : sockets.ads sockets-stream_io.ads sockets-stream_io.adb
