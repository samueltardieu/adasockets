AC_INIT(src/sockets.ads)
AC_CONFIG_AUX_DIR(support)
AM_INIT_AUTOMAKE([adasockets],[1.8.7])
AM_CONFIG_HEADER(src/config.h)
#
# Package description
#
LIBVERSIONINFO=1:0:0
AC_SUBST(LIBVERSIONINFO)
AM_PROG_LIBTOOL
#
AC_CHECK_PROGS(AWK, [gnuawk gawk awk])
#
# Check for maintainer mode
#
AC_ARG_ENABLE(maintainer-mode,
AS_HELP_STRING(--enable-maintainer-mode,turn on debugging options),
[ADAFLAGS="-g -O2 -Wall -Werror -gnatag -gnatwa -gnatwe"],
[ADAFLAGS="-O2 -gnatpng"])
AC_SUBST(ADAFLAGS)
#
# Check for documentation build and installation
#
AC_ARG_ENABLE(doc,
AS_HELP_STRING(--disable-doc,do not build and install documentation),
[case "${enableval}" in
  yes) doc=true ;;
  no)  doc=false ;;
  *) AC_MSG_ERROR(bad value ${enableval} for --enable-doc) ;;
esac],[doc=true])
AM_CONDITIONAL(BUILD_DOC, test x$doc = xtrue)
#
# Check for examples build and installation
#
AC_ARG_ENABLE(examples,
AS_HELP_STRING(--disable-examples,do not build and install examples),
[case "${enableval}" in
  yes) examples=true ;;
  no)  examples=false ;;
  *) AC_MSG_ERROR(bad value ${enableval} for --enable-examples) ;;
esac],[examples=true])
AM_CONDITIONAL(BUILD_EXAMPLES, test x$examples = xtrue)
#
# Check for documentation software
#
AC_CHECK_PROG(GETDEFS, getdefs, getdefs)
AC_CHECK_PROG(MAKEINFO, makeinfo, makeinfo)
AC_CHECK_PROG(TEXI2DVI, texi2dvi, texi2dvi)
AC_CHECK_PROG(DVIPS, dvips, dvips)
#
# Look for the Ada compiler
#
AC_CHECK_PROG([GNATMAKE], [gnatmake], [gnatmake])
if test -z "$GNATMAKE"; then
  AC_MSG_ERROR([unable to find gnatmake])
fi
#
# Libtool checks
#
AC_PROG_LIBTOOL
#
# Output
#
AC_CONFIG_FILES([Makefile
           src/Makefile
           src/adasockets-config
           man/Makefile
           examples/Makefile
           doc/Makefile])
AC_OUTPUT
