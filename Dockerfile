FROM ubuntu:latest

MAINTAINER Paulo Coutinho

# install dependencies
RUN apt-get update && apt-get install -y \
     build-essential \
     git \
	 python \
     wget \
	 nano \
	 curl \
	 unzip \
	 m4 \
	 golang

# versions
ENV GO_VERSION=1.7.4
ENV INSTALLED_GOLANG=1.6
ENV GOROOT_BOOTSTRAP=/usr/lib/go-${INSTALLED_GOLANG}
ENV GOOS=android
ENV GOARCH=arm
ENV GOARM=7
ENV CGO_ENABLED=1

# base paths
ENV BASE_DIR=/golang-for-arm
RUN mkdir -p ${BASE_DIR}

# golang
WORKDIR ${BASE_DIR}
RUN git clone https://go.googlesource.com/go
WORKDIR ${BASE_DIR}/go
RUN git checkout go${GO_VERSION}

# android ndk
ENV ANDROID_API=15

RUN wget https://dl.google.com/android/repository/android-ndk-r13b-linux-x86_64.zip -O ${BASE_DIR}/android-ndk-r13b-linux-x86_64.zip
RUN unzip ${BASE_DIR}/android-ndk-r13b-linux-x86_64.zip -d ${BASE_DIR}

ENV NDK_HOME=${BASE_DIR}/android-ndk-r13b
ENV NDK_GCC_VERSION=4.9

WORKDIR ${NDK_HOME}/build/tools
RUN ./make_standalone_toolchain.py --arch arm --install-dir ${BASE_DIR}/arm-toolchain

ENV ARM_TOOLCHAIN=${BASE_DIR}/arm-toolchain
ENV CROSS_COMPILER_PREFIX=${ARM_TOOLCHAIN}/bin/arm-linux-androideabi
ENV AR=${CROSS_COMPILER_PREFIX}-ar
ENV CC=${CROSS_COMPILER_PREFIX}-gcc
ENV CXX=${CROSS_COMPILER_PREFIX}-g++
ENV CPP=${CROSS_COMPILER_PREFIX}-cpp

WORKDIR ${BASE_DIR}/go/src
RUN ./all.bash

CMD [bash]