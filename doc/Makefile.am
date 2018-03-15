AUTOMAKE_OPTIONS = info-in-builddir

info_TEXINFOS = adasockets.texi
adasockets_TEXINFOS = sockets.texi sockets-multicast.texi sockets-naming.texi version.texi

ADADOC_ARGS = --subblock=arg=argname,argmode,argtype,argdefault,argdesc \
	  --subblock=ret=rettype,retdesc \
	  --subblock=exc=excname,excdesc \
	  --template=${srcdir}/adadoc

DISTCLEANFILES =	*.defs ${adasockets_TEXINFOS} stamp-vti

CLEANFILES = adasockets.aux adasockets.cp adasockets.cps adasockets.fn adasockets.fns adasockets.info adasockets.log adasockets.toc

EXTRA_DIST = adasockets.pdf \
	${info_TEXINFOS} ${adasockets_TEXINFOS} \
	adadoc.tpl sockets.desc sockets-multicast.desc \
	sockets-naming.desc

docdir = ${prefix}/share/doc/adasockets
doc_DATA = adasockets.pdf

adasockets.info: ${srcdir}/adasockets.texi
	${MAKEINFO} --force --no-validate -I ${srcdir} \
	  ${srcdir}/adasockets.texi

sockets.texi: ${srcdir}/sockets.desc ${srcdir}/adadoc.tpl
	${GETDEFS} ${ADADOC_ARGS} \
	  --input="${srcdir}/sockets.desc" --base-name=sockets

sockets-multicast.texi: ${srcdir}/sockets-multicast.desc ${srcdir}/adadoc.tpl
	${GETDEFS} ${ADADOC_ARGS} \
	  --input="${srcdir}/sockets-multicast.desc" \
	  --base-name=sockets-multicast

sockets-naming.texi: ${srcdir}/sockets-naming.desc ${srcdir}/adadoc.tpl
	${GETDEFS} ${ADADOC_ARGS} \
	  --input="${srcdir}/sockets-naming.desc" --base-name=sockets-naming

adasockets.pdf: ${srcdir}/adasockets.texi ${adasockets_TEXINFOS}
	-${TEXI2DVI} --pdf ${srcdir}/adasockets.texi

adasockets.dvi: ${srcdir}/adasockets.texi ${adasockets_TEXINFOS}
	-${TEXI2DVI} --dvi ${srcdir}/adasockets.texi
