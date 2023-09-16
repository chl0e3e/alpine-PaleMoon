#!/bin/bash
docker build -t palemoon .

JSON=$(docker run palemoon | tr --delete '\n')
ARCHIVE=$(echo $JSON | sed 's/json/tar.xz/')

mkdir build

id=$(docker create palemoon)
docker cp $id:$JSON build/
docker cp $id:$ARCHIVE build/
docker rm -v $id

basename $ARCHIVE > build/latest

