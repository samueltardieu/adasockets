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

version:
	@echo $(PACKAGE)-$(VERSION)