$!
$! $Revision$
$!
$!
$! This script completes the constants.c_pre file with the
$! the list of defines needed to build the adasockets constant
$! package.
$!
$! This file is part of Adasockets for OpenVMS.
$!
$    OPEN/READ in CONSTANTS.LIST
$    COPY CONSTANTS.C_PRE CONSTANTS.C
$    OPEN/APPEND out CONSTANTS.C
$!
$    Loop:
$       READ/END_OF_FILE=End_Loop in line
$       WRITE out "#ifdef ''line'"
$       WRITE out "  output (""''line'"", ''line');"
$       WRITE out "#else"
$       WRITE out "  output (""''line'"", -1);"
$       WRITE out "#endif"
$    GOTO Loop
$!
$ End_Loop:
$    WRITE out "}"
$    CLOSE in
$    CLOSE out
$    EXIT
