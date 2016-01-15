#!/bin/sh -ex

# we are using two staging directories: One for the GS dependencies
# (performance and webserver), and one for the actual app. This
# is beneficial when building the container because we can often cache
# the dependency layer
WS_STAGEDIR=$PWD/stage_ws
STAGEDIR=$PWD/stage

mkdir -p $WS_STAGEDIR/usr/local/lib
mkdir -p $WS_STAGEDIR/usr/local/include
mkdir -p $WS_STAGEDIR/usr/local/bin
mkdir -p $STAGEDIR

export CPATH=$WS_STAGEDIR/usr/local/include:$CPATH
export LIBRARY_PATH=$WS_STAGEDIR/usr/local/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=$WS_STAGEDIR//usr/local/lib:$LD_LIBRARY_PATH
if [ ! -d performance ]; then
  svn export http://svn.gna.org/svn/gnustep/libs/performance/tags/performance-0_5_0/ performance
fi

cd performance
make 
make install DESTDIR=$WS_STAGEDIR
cd ..

if [ ! -d webserver ]; then
    svn export http://svn.gna.org/svn/gnustep/libs/webserver/trunk webserver
fi
cd webserver
make
make install DESTDIR=$WS_STAGEDIR
cd ..
make
make install DESTDIR=$STAGEDIR

docker build "$@" -f Dockerfile  . 
