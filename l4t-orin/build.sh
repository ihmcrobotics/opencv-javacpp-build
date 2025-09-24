#!/bin/bash

REPO_DIR=$(pwd)/../
INSTALL_DIR=$(pwd)/install
BUILD_DIR=$(pwd)/build

rm -rf $INSTALL_DIR
mkdir -p $INSTALL_DIR

rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
pushd $BUILD_DIR

cp $REPO_DIR/cppbuild_1.5.11.sh.diff .
cp $REPO_DIR/l4t-orin/javacpp.Dockerfile .
cp $REPO_DIR/l4t-orin/opencv-cudnn-version.patch .

docker build -f javacpp.Dockerfile --progress=plain -t l4t-orin-opencv-javacpp .
docker create --name l4t-orin-opencv-javacpp-temp l4t-orin-opencv-javacpp

docker cp l4t-orin-opencv-javacpp-temp:/root/.m2 $INSTALL_DIR
docker rm l4t-orin-opencv-javacpp-temp

popd
