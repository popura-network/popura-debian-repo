#!/bin/bash

# $0 stable

cd deb_output/
for x in *.deb; do
       reprepro -Vb ../repo includedeb $1 "$x"
done
rm -f *.deb
