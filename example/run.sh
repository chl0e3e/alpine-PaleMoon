#!/bin/bash

RELEASE=$(cat ../builds/latest | tr -d '\n')
cat Dockerskeleton | sed "s/RELEASE/$RELEASE/" > Dockerfile
