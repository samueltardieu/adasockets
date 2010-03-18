AUTOMAKE_OPTIONS = foreign no-dependencies
ACLOCAL_AMFLAGS = -I support
AUTOHEADER_AMFLAGS = -l support

SUBDIRS = src man $(SUBDIRS_DOC) $(SUBDIRS_EXAMPLES)
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

EXTRA_DIST = AUTHORS COPYING GMGPL INSTALL NEWS README README.RTEMS \
	ChangeLog Makefile.VMS \
	contrib/vms/README \
	contrib/win32/adasockets/build.bat contrib/win32/adasockets/clean.bat \
	contrib/win32/adasockets/Readme.txt contrib/win32/distr \
	contrib/win32/Readme.txt \
	support/adacompiler

CLEANFILES = ChangeLog

ChangeLog: never
	(cd ${srcdir} && git2cl) > ChangeLog

never::

version:
	@echo $(PACKAGE)-$(VERSION)