AUTOMAKE_OPTIONS = foreign no-dependencies
ACLOCAL_AMFLAGS = -I support
AUTOHEADER_AMFLAGS = -l support

SUBDIRS = src man tests $(SUBDIRS_DOC) $(SUBDIRS_EXAMPLES)
if BUILD_DOC
SUBDIRS_DOC = doc
else
SUBDIRS_DOC =
endif
if BUILD_EXAMPLES
SUBDIRS_EXAMPLES = examples
else
SUBDIRS_EXAMPLES =
endif

EXTRA_DIST = AUTHORS.md COPYING GMGPL INSTALL.md README.md README-RTEMS.md \
	rtems/ChangeLog rtems/create_constants_c.sh rtems/Makefile.RTEMS \
	rtems/README rtems/rtems_main.c rtems/sockets-constants-rtems.ads \
	ChangeLog Makefile.VMS \
	contrib/vms/README contrib/vms/sockets-constants.ads \
	contrib/win32/adasockets/build.bat contrib/win32/adasockets/clean.bat \
	contrib/win32/adasockets/Readme.txt contrib/win32/distr \
	contrib/win32/Readme.txt \
	src/adasockets.gpr.in support/adacompiler \
	vms/constants.c_pre vms/constants.list vms/create_constants_ads.com \
	vms/create_constants_c.com vms/Makefile.VMS

CLEANFILES = ChangeLog

ChangeLog: never
	(cd ${srcdir} && support/git2cl) > ChangeLog

never::

version:
	@echo $(PACKAGE)-$(VERSION)
