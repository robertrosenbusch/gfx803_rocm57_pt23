FROM rocm/pytorch:rocm5.7_ubuntu22.04_py3.10_pytorch_2.0.1
ARG SD_BRANCH="rocm5.7"
SHELL ["/bin/bash", "-c"]  
ENV PORT=8188 \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    radePYTHONIOENCODING=UTF-8 \
    REQS_FILE='requirements.txt' \
    COMMANDLINE_ARGS='' 

ENV HSA_OVERRIDE_GFX_VERSION='8.0.3' \
    PYTORCH_ROCM_ARCH='gfx803' \
    ROC_ENABLE_PRE_VEGA='1' \ 
    GIT_PYTORCH_VERSION='v2.2.2' \
    GIT_TORCHVISION_VERSION='v0.18'

#####
## Building CPU-Cores
####    
ENV MAX_JOBS=15    

RUN echo HSA_OVERRIDE_GFX_VERSION=${HSA_OVERRIDE_GFX_VERSION} >> /etc/environment && \
    echo ROC_ENABLE_PRE_VEGA=${ROC_ENABLE_PRE_VEGA}  >> /etc/environment && \
    true

RUN export HSA_OVERRIDE_GFX_VERSION=${HSA_OVERRIDE_GFX_VERSION} && \
    export ROC_ENABLE_PRE_VEGA=${ROC_ENABLE_PRE_VEGA} && \
    true    

## Update System and install necesarry stuff 
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends ffmpeg  && \
    true

## Personal Stuff to handle docker better        
RUN apt-get install -y --no-install-recommends tmux mc pigz && \
    true

RUN git clone --recursive https://github.com/pytorch/pytorch.git -b ${GIT_PYTORCH_VERSION} /pytorch && \
    true

WORKDIR /

RUN apt-get install -y --no-install-recommends virtualenv &&\
    pip install --upgrade pip wheel && \
    pip install cmake mkl mkl-include && \
    mkdir /whl_dist && \
    true

WORKDIR /pytorch

RUN export PYTORCH_ROCM_ARCH=${PYTORCH_ROCM_ARCH} && \
    export HSA_OVERRIDE_GFX_VERSION=${HSA_OVERRIDE_GFX_VERSION} && \
    export USE_CUDA=0 USE_ROCM=1 USE_NINJA=1 && \
    export ROC_ENABLE_PRE_VEGA=${ROC_ENABLE_PRE_VEGA} && \
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
    cp /pytorch/dist/torch*-cp310-cp310-linux_x86_64.whl /whl_dist && \ 
    true

## Build Vision
RUN git clone https://github.com/pytorch/vision.git -b ${GIT_TORCHVISION_VERSION} /vision

WORKDIR /vision

RUN echo "** BUILD PYTORCH *** " && \
    export BUILD_VERSION=$(git describe --tags --exact | sed 's/^v//')  && \
    export FORCE_CUDA=1 && \
    python3 setup.py bdist_wheel && \
    true

RUN echo "** INSTALL PYTORCH ***" && \    
    pip install dist/torchvision-*-cp310-cp310-linux_x86_64.whl && \
    cp /pytorch/dist/torchvision-*-cp310-cp310-linux_x86_64.whl /whl_dist && \ 
    true


EXPOSE ${PORT}
EXPOSE 22/tcp

#VOLUME [ "/ComfyUI", "/ComfyUI/custom_nodes","/ComfyUI/models","/ComfyUI/output","/ComfyUI/input"]
#ENTRYPOINT python main.py --listen --use-split-cross-attention --port "${PORT}"
CMD ["/bin/bash","-c"]
