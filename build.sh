#!/bin/sh
IMAGE="registry.cn-hangzhou.aliyuncs.com/wolcen/subversion"
TAG="$1"
docker build --no-cache --rm=true -t $IMAGE:$TAG .
docker push $IMAGE:$TAG
docker tag $IMAGE:$TAG $IMAGE:latest
docker push $IMAGE:latest
