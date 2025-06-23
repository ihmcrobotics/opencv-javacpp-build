#!/bin/sh
docker build -f javacpp.Dockerfile --progress=plain -t opencv-arm64-cuda-cross-javacpp .  --no-cache 
docker create --name opencv-arm64-cuda-cross-javacpp-temp opencv-arm64-cuda-cross-javacpp
rm -rf ./install
mkdir ./install
docker cp opencv-arm64-cuda-cross-javacpp-temp:/root/.m2 ./install
docker rm opencv-arm64-cuda-cross-javacpp-temp
