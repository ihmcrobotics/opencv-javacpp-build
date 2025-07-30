FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu20.04

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
        python2.7 \
        python-is-python2 \
        curl \
        cmake \
        crossbuild-essential-arm64 \
        openjdk-8-jdk \
        && rm -rf /var/lib/apt/lists/*

# Install CUDA cross compiler
RUN wget https://developer.download.nvidia.com/compute/cuda/12.1.0/local_installers/cuda-repo-cross-aarch64-ubuntu2004-12-1-local_12.1.0-1_all.deb && \
    dpkg -i cuda-repo-cross-aarch64-ubuntu2004-12-1-local_12.1.0-1_all.deb && \
    cp /var/cuda-repo-cross-aarch64-ubuntu2004-12-1-local/cuda-*-keyring.gpg /usr/share/keyrings/ && \
    apt-get update && \
    apt-get -y install cuda-cross-aarch64 && \
    rm cuda-repo-cross-aarch64-ubuntu2004-12-1-local_12.1.0-1_all.deb

# Install cuDNN8 cross
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/cross-linux-sbsa/libcudnn8-cross-sbsa_8.9.3.28-1+cuda12.1_all.deb && \
    dpkg -i libcudnn8-cross-sbsa_8.9.3.28-1+cuda12.1_all.deb && \
    rm libcudnn8-cross-sbsa_8.9.3.28-1+cuda12.1_all.deb

# Install cuBLAS
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/arm64/libcublas-12-1_12.1.0.26-1_arm64.deb && \
    dpkg-deb -x libcublas-12-1_12.1.0.26-1_arm64.deb /tmp/deb-extract && \
    cp /tmp/deb-extract/usr/local/cuda-12.1/targets/aarch64-linux/lib/libcublas.so.12.1.0.26 /usr/local/cuda-12.1/targets/aarch64-linux/lib/ && \
    cp /tmp/deb-extract/usr/local/cuda-12.1/targets/aarch64-linux/lib/libcublas.so.12 /usr/local/cuda-12.1/targets/aarch64-linux/lib/ && \
    cp /tmp/deb-extract/usr/local/cuda-12.1/targets/aarch64-linux/lib/libcublasLt.so.12.1.0.26 /usr/local/cuda-12.1/targets/aarch64-linux/lib/ && \
    cp /tmp/deb-extract/usr/local/cuda-12.1/targets/aarch64-linux/lib/libcublasLt.so.12 /usr/local/cuda-12.1/targets/aarch64-linux/lib/ && \
    rm -rf /tmp/deb-extract libcublas-12-1_12.1.0.26-1_arm64.deb

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

# Build javacpp-presets/opencv
WORKDIR /root
RUN git clone https://github.com/bytedeco/javacpp-presets
WORKDIR /root/javacpp-presets
RUN git checkout 1.5.9
RUN curl -L "https://gist.githubusercontent.com/ds58/c9490e5a9b5432d755a1e270ec70bb00/raw/a31528e2282596d959678db703f2fc0d9bbf66eb/cppbuild.sh" -o opencv/cppbuild.sh
RUN mvn clean install -Djavacpp.platform.compiler=aarch64-linux-gnu-g++ -Djavacpp.platform.c.compiler=aarch64-linux-gnu-gcc -Djavacpp.platform.extension=-gpu -Djavacpp.platform=linux-arm64 --projects .,opencv
