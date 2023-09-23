#!/bin/bash
cd "$(dirname "$0")"

mkdir bin || echo "Binary folder exists"

RELEASE=$(cat ../../builds/latest | tr -d '\n')
cat Dockerskeleton | sed "s/RELEASE/$RELEASE/" > Dockerfile
docker build -t msvs .
