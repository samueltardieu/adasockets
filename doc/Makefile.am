info_TEXINFOS = adasockets.texi
adasockets_TEXINFOS = sockets.texi sockets-multicast.texi sockets-naming.texi

ADADOC_ARGS = --subblock=arg=argname,argmode,argtype,argdefault,argdesc \
	  --subblock=ret=rettype,retdesc \
	  --subblock=exc=excname,excdesc \
	  --template=${srcdir}/adadoc

CLEANFILES=	*.defs ${adasockets_TEXINFOS}

all-local:: adasockets.ps adasockets.pdf

docdir = ${DESTDIR}${prefix}/share/doc/adasockets

install-data-local::
	${mkinstalldirs} ${docdir}
	-${INSTALL_DATA} adasockets.ps adasockets.pdf ${docdir}

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

adasockets.ps: ${srcdir}/adasockets.texi ${adasockets_TEXINFOS}
	-${TEXI2DVI} ${srcdir}/adasockets.texi && \
	  ${DVIPS} -o adasockets.ps adasockets.dvi
