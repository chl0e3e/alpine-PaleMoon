#!/bin/bash
cd "$(dirname "$0")"
if [ ! -f BUILD ]
then
    echo -n 0 > BUILD
fi
n=$(cat BUILD)
BUILD=$(( n + 1 ))
echo -n $BUILD > BUILD

IMAGE="palemoon-$BUILD"
docker build --no-cache -t $IMAGE .

JSON=$(docker run $IMAGE | tr --delete '\n')
ARCHIVE=$(echo $JSON | sed 's/json/tar.xz/')

mkdir builds || echo "Builds folder exists"

echo "Creating '$IMAGE' container"
echo ""
id=$(docker create $IMAGE)
echo ""
echo "Copying release archive and version information"
echo "JSON    - $JSON"
echo "ARCHIVE - $ARCHIVE"
docker cp $id:$JSON builds/ && echo "Copied JSON"
docker cp $id:$ARCHIVE builds/ && echo "Copied archive"
echo "Copy complete"
echo ""
echo "Removing '$IMAGE' container"
docker kill $id
docker rm -v $id && echo "Container 'palemoon' removed"

echo "Removing '$IMAGE' image"
docker image rm $IMAGE

basename $ARCHIVE > builds/latest && echo "Build added to builds/ folder and version updated" 
