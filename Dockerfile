# based on https://raw.githubusercontent.com/BVLC/caffe/master/docker/gpu/Dockerfile
FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04
MAINTAINER Alexandre Maia <alexandre.maia@gmail.com>

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        wget \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        python-dev \
        python-numpy \
        python-pip \
        python-setuptools \
        python-scipy && \
    rm -rf /var/lib/apt/lists/*

ENV CAFFE_ROOT=/opt/caffe
WORKDIR $CAFFE_ROOT

# build caffe from faster RCNN PR containing ROIPooling layers.
RUN git clone --depth 1 https://github.com/BVLC/caffe.git . && \
    git fetch origin pull/4163/head:dir && \
    git checkout dir && \
    pip install --upgrade pip && \
    cd python && for req in $(cat requirements.txt) pydot; do pip install $req; done && cd .. && \
    git clone https://github.com/NVIDIA/nccl.git && cd nccl && make -j install && cd .. && rm -rf nccl && \
    mkdir build && cd build && \
    cmake -DUSE_CUDNN=1 -DUSE_NCCL=1 .. && \
    make -j"$(nproc)"

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig


RUN pip install opencv-python && \
    pip install tqdm && \
    rm -rf /root/.cache/pip/*
        
RUN wget http://download.europe.naverlabs.com/Computer-Vision-CodeandModels/deep_retrieval.tgz && \
        tar xzf deep_retrieval.tgz  
        #&& cd deep_retrieval && \
    

#http://download.europe.naverlabs.com/Computer-Vision-CodeandModels/annotations_landmarks.zip

WORKDIR /workspace

