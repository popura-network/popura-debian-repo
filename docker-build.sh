#!/bin/bash -x

# $0 v0.3.15+popura1 stable (optional: PKGREL)

if [ -n "$1" ]; then
  if [ ! -d "Popura/" ]; then
    git clone https://github.com/popura-network/Popura.git
    cd Popura/
    git checkout $1
  else
    cd Popura/
    git fetch --all
    git reset --hard origin/master
    git pull --rebase --autostash
    git checkout $1
  fi
  cd ..
else
  exit 1
fi

cd Popura/
#curl -s https://publicpeers.neilalexander.dev/publicnodes.json \
#  | jq -rc 'to_entries[] | .value | to_entries[] | .key' > assets/peers.txt
#./make_assets
cd ..

docker run -t -i --rm \
  -u $(id -u):$(id -g) \
  -v `pwd`:/io \
  ghcr.io/foobarwidget/holy-build-box-x64:latest \
  /hbb_exe/activate-exec \
  bash -c "cd /io/ && GOPATH=/io/gopath GOCACHE=/dev/shm/gocache PKGREL=$3 /io/make-all-debs.sh $1 $2"
#GOPROXY="https://proxy.golang.org,direct" PKGREL=$3 CGO_ENABLED=0 ./make-all-debs.sh $1 $2
./add-to-pool.sh $2
