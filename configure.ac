AC_INIT([adasockets], [1.10.1])
AC_CONFIG_SRCDIR([src/sockets.ads])
AC_CONFIG_AUX_DIR([support])
AC_CONFIG_MACRO_DIR([support])
AM_INIT_AUTOMAKE
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
AC_ARG_VAR(ADAFLAGS,[Ada compiler flags])
AC_ARG_ENABLE(maintainer-mode,
AS_HELP_STRING(--enable-maintainer-mode,turn on debugging options),
[ADAFLAGS="-g -O2 -Wall -Werror -gnatag -gnatwa -gnatwe $ADAFLAGS"],
[ADAFLAGS="-O2 -gnatpng $ADAFLAGS"])
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
#
# Look for the C compiler
#
AC_PROG_CC
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
# Test for -lnsl, -lsocket and -lresolv
#
AC_CHECK_FUNC(gethostbyname,NSLNEEDED="--  ",
  AC_CHECK_LIB(nsl,gethostbyname,,NSLNEEDED="--  "))
AC_SUBST(NSLNEEDED)
AC_CHECK_FUNC(connect,SOCKETNEEDED="--  ",
  AC_CHECK_LIB(socket,connect,,SOCKETNEEDED="--  "))
AC_SUBST(SOCKETNEEDED)
AC_CHECK_FUNC(inet_aton,RESOLVNEEDED="--  ",
  AC_CHECK_LIB(resolv,inet_aton,,RESOLVNEEDED="--  "))
AC_SUBST(RESOLVNEEDED)
#
# Extra libraries
#
AC_ARG_WITH(extra-libs,
 [  --with-extra-libs=libs  Add extra libraries when building a program],
 [EXTRA_LIBS="${withval}"])
AC_SUBST(EXTRA_LIBS)
#
# Header files
#
AC_CHECK_HEADERS([stdio.h sys/types.h sys/socket.h errno.h netdb.h stdlib.h])
AC_CHECK_HEADERS([netinet/in.h signal.h fcntl.h termio.h termios.h sys/file.h])
AC_CHECK_HEADERS([sys/ioctl.h netinet/tcp.h sys/systeminfo.h poll.h stropts.h])
AC_CHECK_HEADERS([sys/conf.h sys/param.h time.h windows.h string.h linux/sockios.h])
AC_CHECK_HEADERS(windows.h, [usewin32=true useunix=false],
                            [usewin32=false useunix=true])
#
# sa_len field ?
#
AC_CHECK_MEMBER(struct sockaddr.sa_len,[SA_LEN="" NO_SA_LEN="--  "],[SA_LEN="--  " NO_SA_LEN=""],[#include <sys/types.h>
AC_SUBST(SA_LEN)
AC_SUBST(NO_SA_LEN)
#include <sys/socket.h>])
#
# Conditional import for Win32 and substitution
#
AM_CONDITIONAL(WIN32, $usewin32)
if $useunix; then
  WINNEEDED="--  "
fi
AC_SUBST(WINNEEDED)
#
# Output
#
AC_CONFIG_FILES([Makefile
           src/Makefile
           src/sockets-link.ads
           src/sockets-types.ads
	   src/adasockets.pc
           man/Makefile
           examples/Makefile
           doc/Makefile
           tests/Makefile])
AC_OUTPUT
