echo with > tmp_make.adb
echo    sockets, >> tmp_make.adb
echo    sockets.multicast, >> tmp_make.adb
echo    sockets.stream_io, >> tmp_make.adb
echo    sockets.naming; >> tmp_make.adb
echo procedure Tmp_Make is >> tmp_make.adb
echo begin >> tmp_make.adb
echo    null; >> tmp_make.adb
echo end; >> tmp_make.adb
set ADA_OBJECTS_PATH=
set ADA_INCLUDE_PATH=
gnatmake -c -O2 tmp_make
del tmp_make.*
attrib +r *.ali
cd examples
gnatmake -I../ multi
gnatmake -I../ stream_sender
gnatmake -I../ stream_listener
gnatmake -I../ tcprelay
gnatmake -I../ listener
