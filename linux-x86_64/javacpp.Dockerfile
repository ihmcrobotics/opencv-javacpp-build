FROM nvidia/cuda:12.9.0-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root

# Install common tools and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ninja-build \
        git \
        wget \
        zip \
        unzip \
        python3 \
        python-is-python3 \
        curl \
        cmake \
        build-essential \
        openjdk-8-jdk \
        && rm -rf /var/lib/apt/lists/*

# Install Maven
RUN wget https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz -P /tmp && \
    tar xf /tmp/apache-maven-3.9.11-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.9.11 /opt/maven && \
    rm /tmp/apache-maven-3.9.11-bin.tar.gz

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV JAVA_INCLUDE_PATH=/usr/lib/jvm/java-8-openjdk-amd64/include
ENV JAVA_INCLUDE_PATH2=/usr/lib/jvm/java-8-openjdk-amd64/include/linux
ENV M2_HOME=/opt/maven
ENV MAVEN_HOME=/opt/maven
ENV PATH=$M2_HOME/bin:$PATH

# Clone javacpp-presets and checkout tag 1.5.11
WORKDIR /root
RUN git clone https://github.com/bytedeco/javacpp-presets
WORKDIR /root/javacpp-presets
RUN git checkout 1.5.11

# Copy over extra patch files
COPY opencv-cudnn-version.patch opencv
COPY private.cuda.hpp.diff opencv

# Copy and patch cppbuild.sh diff
COPY cppbuild_1.5.11.sh.diff opencv
RUN patch opencv/cppbuild.sh < opencv/cppbuild_1.5.11.sh.diff

# Build javacpp-presets/opencv
RUN mvn clean install -Djavacpp.platform.extension=-gpu -Djavacpp.platform=linux-x86_64 --projects .,opencv
