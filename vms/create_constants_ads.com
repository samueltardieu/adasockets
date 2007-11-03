$!
$! This script produces a sockets-constants.ads file
$! for adasockets on OpenVMS platform.
$!
$! This file is part of adasockets port to OpenVMS
$!
$!
$! Let's write the header
$!
$    OPEN/WRITE OUT SOCKETS-CONSTANTS.ADS
$    WRITE OUT "--  This file has been generated automatically by"
$    WRITE OUT "--  CREATE_CONSTANTS_ADS.COM."
$    WRITE OUT "--"
$    WRITE OUT "--  This file is part of adasockets port to OpenVMS"
$    WRITE OUT "--"
$    WRITE OUT "package sockets.constants is"
$!
$! Now Include the contents.
$! Make a line copy to get rid of the file attribut
$! compatibility between TMP.OUT and SOCKETS-CONSTANTS.ADS
$!
$    PIPE RUN CONSTANTS.EXE | TYPE/OUT=TMP.OUT SYS$INPUT
$    loop_label:
$        OPEN IN TMP.OUT
$        READ/END_OF_FILE=end_label IN LINE
$        WRITE OUT LINE
$    GOTO loop_label
$    end_label:
$    CLOSE IN
$    DEL/NOCONF/LOG TMP.OUT;*
$!
$! Then close the specification file
$!
$    WRITE OUT "end sockets.constants;"
$    CLOSE OUT
$    EXIT
