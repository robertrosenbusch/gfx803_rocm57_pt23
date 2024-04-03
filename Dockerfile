FROM rocm/pytorch:rocm5.7_ubuntu22.04_py3.10_pytorch_2.0.1
ARG SD_BRANCH="rocm6.0"
SHELL ["/bin/bash", "-c"]  
ENV PORT=8188 \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    radePYTHONIOENCODING=UTF-8 \
    REQS_FILE='requirements.txt' \
    COMMANDLINE_ARGS='' \
    ### For your AMD GPU
    PYTORCH_ROCM_ARCH=gfx803 


RUN echo HSA_OVERRIDE_GFX_VERSION=8.0.3 >> /etc/environment && \
    echo ROC_ENABLE_PRE_VEGA=1  >> /etc/environment && \
    true

## Update System and install necesarry stuff 
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends ffmpeg  && \
    true

## Personal Stuff to handle docker better        
RUN apt-get install -y --no-install-recommends tmux mc pigz && \
    true

RUN git clone --recursive https://github.com/pytorch/pytorch.git -b release/2.3 /pytorch && \
    true

WORKDIR /

RUN apt-get install -y --no-install-recommends virtualenv &&\
    pip install --upgrade pip wheel && \
    pip install cmake mkl mkl-include && \
    true


ENV MAX_JOBS=14

WORKDIR /pytorch

RUN export PYTORCH_ROCM_ARCH=gfx803 && \
    export HSA_OVERRIDE_GFX_VERSION=8.0.3 && \
    export USE_CUDA=0 USE_ROCM=1 USE_NINJA=1 && \
    export ROC_ENABLE_PRE_VEGA=1 && \
    python setup.py clean && \
    pip install -r requirements.txt && \
   # pip3 uninstall torch torchvision -y && \
    true

RUN python3 tools/amd_build/build_amd.py && \
    true


RUN echo "** BUILDING PYTORCH *** " && \
    export PYTORCH_BUILD_VERSION=$(git describe --tags --exact | sed 's/^v//') && \
    export PYTORCH_BUILD_NUMBER=0 && \
    python3 setup.py bdist_wheel && \
    true

RUN echo "** INSTALL PYTORCH ***" && \    
    pip install /pytorch/dist/torch*-cp310-cp310-linux_x86_64.whl && \
    true

## Build Vision
RUN git clone https://github.com/pytorch/vision.git -b release/0.18 /vision

WORKDIR /vision

RUN export BUILD_VERSION=$(git describe --tags --exact | sed 's/^v//')  && \
    export FORCE_CUDA=1 && \
    python3 setup.py bdist_wheel && \
    pip install dist/torchvision-*-cp310-cp310-linux_x86_64.whl && \
    true



EXPOSE ${PORT}
EXPOSE 22/tcp

#VOLUME [ "/ComfyUI", "/ComfyUI/custom_nodes","/ComfyUI/models","/ComfyUI/output","/ComfyUI/input"]
#ENTRYPOINT python main.py --listen --use-split-cross-attention --port "${PORT}"
CMD ["/bin/bash","-c"]