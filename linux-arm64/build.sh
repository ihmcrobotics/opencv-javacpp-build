#!/bin/bash

REPO_DIR=$(pwd)/../
INSTALL_DIR=$(pwd)/install
BUILD_DIR=$(pwd)/build

rm -rf $INSTALL_DIR
mkdir -p $INSTALL_DIR

rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
pushd $BUILD_DIR

cp ../cppbuild_1.5.11.sh.diff .
cp $REPO_DIR/linux-arm64/javacpp.Dockerfile .
cp $REPO_DIR/linux-arm64/opencv-cudnn-version.patch .

docker build -f javacpp.Dockerfile --progress=plain --no-cache -t linux-arm64-opencv-javacpp .
docker create --name linux-arm64-opencv-javacpp-temp linux-arm64-opencv-javacpp

docker cp linux-arm64-opencv-javacpp-temp:/root/.m2 $INSTALL_DIR
docker rm linux-arm64-opencv-javacpp-temp

popd
