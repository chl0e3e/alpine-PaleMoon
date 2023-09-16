#!/bin/bash

RELEASE=$(cat latest | tr -d '\n')
cat Dockerskeleton | sed "s/RELEASE/$RELEASE/" > Dockerfile
