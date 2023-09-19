#!/bin/bash
docker build -t palemoon .

JSON=$(docker run palemoon | tr --delete '\n')
ARCHIVE=$(echo $JSON | sed 's/json/tar.xz/')

mkdir builds || echo "Builds folder exists"

echo "Creating `palemoon` container"
id=$(docker create palemoon)
echo "Copying release archive and version information"
echo "JSON    - $JSON"
echo "ARCHIVE - $ARCHIVE"
docker cp $id:$JSON builds/ && echo "Copied JSON"
docker cp $id:$ARCHIVE builds/ && echo "Copied archive"
echo "Removing `palemoon` container"
docker rm -v $id && echo "Container `palemoon` removed"

basename $ARCHIVE > builds/latest && echo "Build added to builds/ folder and version updated" 
