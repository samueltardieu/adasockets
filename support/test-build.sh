#! /bin/sh -e
autoreconf -fvi
rm -rf *.tar.gz
./configure
make dist
rm -rf _build
mkdir _build
cd _build
tar zxvf ../*.tar.gz
cd adasockets*
mkdir _build _install
parent="$PWD"
cd _build
../configure --prefix="$parent/_install"
make
make check
make install
