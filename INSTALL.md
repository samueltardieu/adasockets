# Installing AdaSockets

## Building on Unix or Cygwin/Windows

```
% ./configure --prefix=<any directory>
% make install
```

This will build and install this software under *<any directory>*`/lib/adasockets`.
The `adasockets-config` program and its associated man page will be installed
respectively under *<any directory>*`/bin` and *<any directory>*`/man/`.

In the examples subdirectory, you will find an example called `tcprelay` which
illustrates how this package can be used.

GNU make is not strictly necessary but is recommended. It is needed if
you want to rebuild the documentation.

You need to install the autogen software if you want to rebuild the
documentation. You also need the autotools if you plan on modifying the
AdaSockets build structure.

## Building the development version

If you build from the current development version (for example the git head version),
you need to regenerate the configure file:

```
% autoreconf -i
```

This will invoke `autoconf`, `automake` and `libtool` (which all must be installed)
with the right arguments.

## Building on OpenVMS

```
% make
```

GNU make must be available as well as the DEC C compiler. If no C
compiler is available on your system, the file `sockets-constants.ads`
in the `contrib/vms` directory must be copied into the `vms` one. This
file is given as is and has not been tested on other host than the one
used to port AdaSockets.
