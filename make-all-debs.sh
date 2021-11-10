#!/bin/bash

# $0 v0.3.15+popura1 stable

if ! [ -d go1.17.3.linux-amd64 ]
then
	curl -LO https://golang.org/dl/go1.17.3.linux-amd64.tar.gz
	sha256sum go1.17.3.linux-amd64.tar.gz | grep 550f9845451c0c94be679faf116291e7807a8d78b43149f9506c1b15eb89008c || exit 1
	tar xf go1.17.3.linux-amd64.tar.gz
	mv go go1.17.3.linux-amd64
	rm go1.17.3.linux-amd64.tar.gz
fi

export PATH=$PWD/go1.17.3.linux-amd64/bin:$PATH

mkdir -p deb_output/

cd Popura/

for x in amd64 i386 mipsel mips armhf arm64 armel;do
	PKGARCH=$x ../generate-deb.sh
done
