#!/bin/sh
mkdir /tmp
mount -t ramfs -o size=256M ramfs /tmp/
cp -r /browser_profile/MSVS/ /tmp/
python /scripts/MSVS.py /tmp/
