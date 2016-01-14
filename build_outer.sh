#!/bin/sh

# Run this script with the docker build arguments e.g '-t repo/ws-example'
docker run -v $PWD:/build -v /var/run/docker.sock:/var/run/docker.sock  -w /build --rm ngrewe/gnustep-headless-dev /build/build_inner.sh "$@"
