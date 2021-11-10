#!/bin/sh

# This is a lazy script to create a .deb for Debian/Ubuntu. It installs
# yggdrasil and enables it in systemd. You can give it the PKGARCH= argument
# i.e. PKGARCH=i386 sh contrib/deb/generate.sh

if [ `pwd` != `git rev-parse --show-toplevel` ]
then
  echo "You should run this script from the top-level directory of the git repo"
  exit 1
fi

[ -z "$PKGREL" ] && PKGREL=1
export PKGBRANCH=$(basename `git name-rev --name-only HEAD`)
export PKGNAME=$(sh contrib/semver/name.sh | sed -e 's/^yggdrasil/popura/g')
export PKGVERSION="$(sh contrib/semver/version.sh --bare)"
export PKGARCH=${PKGARCH-amd64}
export PKGFILE=$PKGNAME-$PKGVERSION+$PKGREL-$PKGARCH.deb
export PKGREPLACES='yggdrasil, yggdrasil-develop, popura, popura-develop'

if [ $PKGARCH = "amd64" ]; then GOARCH=amd64 GOOS=linux ./build -l '-extldflags "-static"'
elif [ $PKGARCH = "i386" ]; then GOARCH=386 GOOS=linux ./build -l '-extldflags "-static"'
elif [ $PKGARCH = "mipsel" ]; then GOARCH=mipsle GOOS=linux ./build -l '-extldflags "-static"'
elif [ $PKGARCH = "mips" ]; then GOARCH=mips64 GOOS=linux ./build -l '-extldflags "-static"'
elif [ $PKGARCH = "armhf" ]; then GOARCH=arm GOOS=linux GOARM=6 ./build -l '-extldflags "-static"'
elif [ $PKGARCH = "arm64" ]; then GOARCH=arm64 GOOS=linux ./build -l '-extldflags "-static"'
elif [ $PKGARCH = "armel" ]; then GOARCH=arm GOOS=linux GOARM=5 ./build -l '-extldflags "-static"'
else
  echo "Specify PKGARCH=amd64,i386,mips,mipsel,armhf,arm64,armel"
  exit 1
fi

echo "Building $PKGFILE"

mkdir -p /tmp/$PKGNAME/
mkdir -p /tmp/$PKGNAME/debian/
mkdir -p /tmp/$PKGNAME/usr/bin/
mkdir -p /tmp/$PKGNAME/etc/systemd/system/

cat > /tmp/$PKGNAME/debian/changelog << EOF
Please see https://github.com/popura-network/Popura
EOF
echo 9 > /tmp/$PKGNAME/debian/compat
cat > /tmp/$PKGNAME/debian/control << EOF
Package: $PKGNAME
Version: $PKGVERSION+$PKGREL
Section: contrib/net
Priority: extra
Architecture: $PKGARCH
Replaces: $PKGREPLACES
Conflicts: $PKGREPLACES
Maintainer: rany <rany at i2pmail dot org>
Description: Popura ポプラ: alternative Yggdrasil network client
 Popura uses the same Yggdrasil core API internally, but adds some useful and
 experimental features which the original client lacks.
EOF
cat > /tmp/$PKGNAME/debian/copyright << EOF
Please see https://github.com/popura-network/Popura
EOF
cat > /tmp/$PKGNAME/debian/docs << EOF
Please see https://github.com/popura-network/Popura
EOF
cat > /tmp/$PKGNAME/debian/install << EOF
usr/bin/yggdrasil usr/bin
usr/bin/yggdrasilctl usr/bin
etc/systemd/system/*.service etc/systemd/system
EOF
cat > /tmp/$PKGNAME/debian/postinst << EOF
#!/bin/sh
if ! getent group yggdrasil 2>&1 > /dev/null; then
  groupadd --system --force yggdrasil || echo "Failed to create group 'yggdrasil' - please create it manually and reinstall"
fi

if command -v systemctl >/dev/null; then
  systemctl daemon-reload >/dev/null || true
  systemctl enable yggdrasil || true
  systemctl start yggdrasil || true
fi
EOF
cat > /tmp/$PKGNAME/debian/prerm << EOF
#!/bin/sh
if command -v systemctl >/dev/null; then
  systemctl disable yggdrasil || true
  systemctl stop yggdrasil || true
fi
EOF

cp yggdrasil /tmp/$PKGNAME/usr/bin/
cp yggdrasilctl /tmp/$PKGNAME/usr/bin/
cp contrib/systemd/*.service /tmp/$PKGNAME/etc/systemd/system/

tar -czvf \
  /tmp/$PKGNAME/data.tar.gz -C /tmp/$PKGNAME/ \
  usr/bin/yggdrasil usr/bin/yggdrasilctl \
  etc/systemd/system/yggdrasil.service \
  etc/systemd/system/yggdrasil-default-config.service \
  --owner=0 --group=0
tar -czvf /tmp/$PKGNAME/control.tar.gz -C /tmp/$PKGNAME/debian .
echo 2.0 > /tmp/$PKGNAME/debian-binary

ar -r ../deb_output/$PKGFILE \
  /tmp/$PKGNAME/debian-binary \
  /tmp/$PKGNAME/control.tar.gz \
  /tmp/$PKGNAME/data.tar.gz

rm -rf /tmp/$PKGNAME
