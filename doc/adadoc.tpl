[+ autogen5 template texi +][+

(define *args* #f)

(define (end-args kind return)
  (let ((args *args*))
    (set! *args* #f)
    (if (string=? kind "procedure")
      (if args ");" ";")
      (sprintf "%s@*@w{return %s;}" (if args ")" "") return))))

(define (format-arg name mode type default)
  (let ((prefix (if *args* "; " " ("))
	(mode-mark (if (string-ci=? "IN" mode) "" (sprintf " %s" mode)))
	(default-expr
         (if (string=? default "") "" (sprintf " := %s" default))))
    (set! *args* #t)
    (sprintf "%s@w{@var{%s} :%s %s%s}" prefix name mode-mark type default-expr)))

+][+ CASE (suffix) +][+
  == texi +]
[+ intro +]
[+ FOR type +]
@deftypefn [+ package +].[+ name +] type [+ name +] [+ IF discr +]([+ discr +]) [+ ENDIF +]is [+ def +];
[+ doc +]
[+ IF (exist? "see") +]See also: [+ FOR see "," +]@ref{[+ see +]}[+ ENDFOR +].
[+ ENDIF +]
@end deftypefn
[+ ENDFOR +]
@menu
[+ FOR subprogram +]* [+
  (let ((w (get "what"))
	(n (string-append (get "name") " (" (get "kind") ")")))
     (sprintf (if (> (string-length n) 19)
		  "%s\n                        %s"
                  "%-21s %s") (string-append n "::") w)) +]
[+ ENDFOR +]@end menu
[+ FOR subprogram +]
@node [+ name +] ([+ kind +])
@unnumberedsubsec [+ name +] ([+ kind +])
[+ FOR concept +]@cindex [+ concept +]
[+ ENDFOR +]
@table @sc
@item Purpose
[+ what +]
@item Prototype
@deftypefn [+ package +].[+ name +] [+ kind +] [+ name +][+ IF (exist? "arg") +][+
   FOR arg +][+
      (format-arg (get "argname") (get "argmode") (get "argtype") (get "argdefault"))
   +][+ ENDFOR +][+ (end-args (get "kind") (get "ret.rettype")) +][+ ENDIF +]
@end deftypefn
@fnindex [+ package +].[+ name +]
[+ IF (exist? "arg") +]
@item Parameters
@multitable {XXXXXXXX} {in out X} {XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}
[+ FOR arg +]@item @var{[+ argname +]} @tab [+ argmode +] @tab [+ argdesc +]
[+ ENDFOR +]@end multitable
[+ ENDIF +][+ IF (exist? "ret") +]
@item Return value
[+ ret.retdesc +][+ ENDIF +]
[+ IF doc +]
@item Description
[+ doc +]
[+ ENDIF +]
[+ IF (exist? "exc") +]
@item Exceptions
@multitable {XXXXXXXXXXXXXXXX} {XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}
[+ FOR exc +]@item @code{[+ excname +]} @tab [+ excdesc +]@exindex [+ excname +]
[+ ENDFOR +]@end multitable
[+ FOR exc +]
[+ ENDFOR +]
[+ ENDIF +]
[+ IF example +]
@item Example
@example
[+ (out-push-new ".example") +][+ example +][+ (out-pop) +][+
   `sed 's/^\\$ //' .example; rm -f .example` +]
@end example
[+ ENDIF +]
[+ IF see +]
@item See also
[+ FOR see ",@*" +]@ref{[+ see +]}[+ ENDFOR +].
[+ ENDIF +]
@end table
[+ ENDFOR +]
[+ ESAC +]
