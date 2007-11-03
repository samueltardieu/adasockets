This directory containts files to create
a simple installation only for win32 platform.
The users of the installation would not have
to have any unix command tool for Windows
to build the library.

The shell script
./distr
achives the subset of win32 sources with batch file
for compilation to the adasockets.tgz archive.
You should call it from the current directory.

AdaSockets should be already maked under the Win32 platform
as a regular process under the any unix command tools.
For example cygwin http://cygwin.com/

ATTENTION: For the cygwin unit command tools.
gcc should be used from GNAT installation,
but make utility should be used from the cygwin
installation.