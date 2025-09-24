FROM nvidia/cuda:12.6.1-cudnn-devel-ubuntu22.04

ENV ARCH=aarch64 \
    HOSTCC=gcc \
    TARGET=ARMV8 \
    DEBIAN_FRONTEND=noninteractive

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
        crossbuild-essential-arm64 \
        openjdk-8-jdk \
        && rm -rf /var/lib/apt/lists/*

# Install CUDA cross compiler
RUN wget https://developer.download.nvidia.com/compute/cuda/12.6.1/local_installers/cuda-repo-cross-aarch64-ubuntu2204-12-6-local_12.6.1-1_all.deb && \
    dpkg -i cuda-repo-cross-aarch64-ubuntu2204-12-6-local_12.6.1-1_all.deb && \
    cp /var/cuda-repo-cross-aarch64-ubuntu2204-12-6-local/cuda-*-keyring.gpg /usr/share/keyrings/ && \
    apt-get update && \
    apt-get -y install cuda-cross-aarch64 && \
    rm cuda-repo-cross-aarch64-ubuntu2204-12-6-local_12.6.1-1_all.deb

# Install cuDNN9 cross
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/cross-linux-aarch64/libcudnn9-cross-aarch64-cuda-12_9.3.0.75-1_all.deb && \
    dpkg -i libcudnn9-cross-aarch64-cuda-12_9.3.0.75-1_all.deb && \
    rm libcudnn9-cross-aarch64-cuda-12_9.3.0.75-1_all.deb

# Install cuBLAS
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/arm64/libcublas-12-6_12.6.1.4-1_arm64.deb && \
    dpkg-deb -x libcublas-12-6_12.6.1.4-1_arm64.deb /tmp/deb-extract && \
    cp /tmp/deb-extract/usr/local/cuda-12.6/targets/aarch64-linux/lib/libcublas.so.12.6.1.4 /usr/local/cuda-12.6/targets/aarch64-linux/lib/ && \
    cp /tmp/deb-extract/usr/local/cuda-12.6/targets/aarch64-linux/lib/libcublas.so.12 /usr/local/cuda-12.6/targets/aarch64-linux/lib/ && \
    cp /tmp/deb-extract/usr/local/cuda-12.6/targets/aarch64-linux/lib/libcublasLt.so.12.6.1.4 /usr/local/cuda-12.6/targets/aarch64-linux/lib/ && \
    cp /tmp/deb-extract/usr/local/cuda-12.6/targets/aarch64-linux/lib/libcublasLt.so.12 /usr/local/cuda-12.6/targets/aarch64-linux/lib/ && \
    rm -rf /tmp/deb-extract libcublas-12-6_12.6.1.4-1_arm64.deb

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

# Copy over some files
COPY cppbuild_1.5.11.sh.diff opencv
RUN patch cppbuild.sh < cppbuild_1.5.11.sh.diff
COPY opencv-cudnn-version.patch opencv

# Build javacpp-presets/opencv
RUN mvn clean install -Djavacpp.platform.compiler=aarch64-linux-gnu-g++ -Djavacpp.platform.c.compiler=aarch64-linux-gnu-gcc -Djavacpp.platform.extension=-gpu -Djavacpp.platform=linux-arm64 --projects .,opencv
