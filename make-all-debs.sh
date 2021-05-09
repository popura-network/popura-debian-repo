#!/bin/bash

# $0 v0.3.15+popura1 stable

mkdir -p deb_output/

cd Popura/

for x in amd64 i386 mipsel mips armhf arm64 armel;do
	PKGARCH=$x ../generate-deb.sh
done
