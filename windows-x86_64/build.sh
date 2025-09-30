#!/bin/bash

REPO_DIR=$(pwd)/../
INSTALL_DIR=$(pwd)/install
BUILD_DIR=$(pwd)/build

rm -rf $INSTALL_DIR
mkdir -p $INSTALL_DIR

rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
pushd $BUILD_DIR

git clone https://github.com/bytedeco/javacpp-presets
cd javacpp-presets
git checkout 1.5.11

cp ../../javacpp-presets_pom.xml.diff .
cp ../../cppbuild_1.5.11.sh.diff opencv
cp ../../opencv-cudnn-version.patch opencv
cp ../../private.cuda.hpp.diff opencv

patch pom.xml < javacpp-presets_pom.xml.diff
patch opencv/cppbuild.sh < opencv/cppbuild_1.5.11.sh.diff

# Remap the group ID for the opencv maven project
sed -i.bak '12s/.*/  <groupId>us.ihmc<\/groupId>/' opencv/pom.xml
# Replace the version
sed -i "s|<version>4.10.0-\${project.parent.version}</version>|<version>4.10.0-\${project.parent.version}-$(date +%Y%m%d)-ihmc</version>|" opencv/pom.xml

mvn -Dmaven.repo.local=$INSTALL_DIR/.m2/repository clean install -Djavacpp.platform.extension=-gpu -Djavacpp.platform=windows-x86_64 --projects .,opencv

popd
