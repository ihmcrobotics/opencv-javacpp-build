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
cp $REPO_DIR/linux-x86_64/javacpp.Dockerfile .
cp $REPO_DIR/linux-x86_64/opencv-cudnn-version.patch .
cp $REPO_DIR/linux-x86_64/private.cuda.hpp.diff .
cp $REPO_DIR/linux-x86_64/OpenCVDetectCUDAUtils.cmake.diff .

docker build -f javacpp.Dockerfile --progress=plain --no-cache -t linux-x86_64-opencv-javacpp .
docker create --name linux-x86_64-opencv-javacpp-temp linux-x86_64-opencv-javacpp

docker cp linux-x86_64-opencv-javacpp-temp:/root/.m2 $INSTALL_DIR
docker rm linux-x86_64-opencv-javacpp-temp

popd
