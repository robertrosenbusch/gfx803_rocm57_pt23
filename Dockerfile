
FROM rocm/pytorch:rocm5.7_ubuntu22.04_py3.10_pytorch_2.0.1
ENV PORT=8188 \
    COMMANDLINE_ARGS='' \
    ### how many CPUCores are using while compiling
    MAX_JOBS=14 \ 
    ### Settings for AMD GPU RX570/RX580/RX590 GPU
    HSA_OVERRIDE_GFX_VERSION=8.0.3 \ 
    PYTORCH_ROCM_ARCH=gfx803 \
    ROC_ENABLE_PRE_VEGA=1 \
    USE_CUDA=0 \  
    USE_ROCM=1 \ 
    USE_NINJA=1 \
    FORCE_CUDA=1 \ 
#######
    DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONENCODING=UTF-8\      
    REQS_FILE='requirements.txt' \
    COMMANDLINE_ARGS='' 

## Write the Environment VARSs to global... to compile later with while you use #docker save# or #docker commit#
RUN echo MAX_JOB=${MAX_JOB} >> /etc/environment && \ 
    echo HSA_OVERRIDE_GFX_VERSION=${HSA_OVERRIDE_GFX_VERSION} >> /etc/environment \ 
    echo ROC_ENABLE_PRE_VEGA=${ROC_ENABLE_PRE_VEGA} >> /etc/environment && \
    echo USE_CUDA=${USE_CUDA} >> /etc/environment && \
    echo USE_ROCM=${USE_ROCM} >> /etc/environment && \
    echo USE_NINJA=${USE_NINJA} >> /etc/environment && \
    echo FORCE_CUDA=${FORCE_CUDA} >> /etc/environment && \
    true

## Export the AMD Stuff
RUN export ${MAX_JOB} && \ 
    export ROC_ENABLE_PRE_VEGA=${ROC_ENABLE_PRE_VEGA} && \
    export HSA_OVERRIDE_GFX_VERSION=${HSA_OVERRIDE_GFX_VERSION} && \
    export USE_CUDA=${USE_CUDA}  && \
    export USE_ROCM=${USE_ROCM}  && \
    export USE_NINJA=${USE_NINJA} && \
    export FORCE_CUDA=${FORCE_CUDA} && \
    export ROC_ENABLE_PRE_VEGA=${ROC_ENABLE_PRE_VEGA} && \
    export HSA_OVERRIDE_GFX_VERSION=${HSA_OVERRIDE_GFX_VERSION} && \
    true

# Update System and install ffmpeg for SDXL video and python virtual Env
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends ffmpeg virtualenv google-perftools && \
    pip install --upgrade pip wheel && \
    pip install cmake mkl mkl-include && \ 
    true

# git clone PyTorch Version you need for
### PyTorch Version

ENV PYTORCH_GIT_VERSION="release/2.3"
RUN echo "Checkout ${PYTORCH_GIT_VERSION} " && \  
    git clone --recursive https://github.com/pytorch/pytorch.git -b ${PYTORCH_GIT_VERSION} /pytorch && \
    true

# git clone Torchvision you need
### Torchvision Version
ENV TORCH_GIT_VERSION="release/0.18"
RUN echo "Checkout ${TORCH_GIT_VERSION} " && \ 
    git clone https://github.com/pytorch/vision.git -b ${TORCH_GIT_VERSION} /vision && \
    true

WORKDIR /pytorch

RUN echo "BULDING PYTORCH $(git describe --tags --exact | sed 's/^v//')" && \
    true 

RUN python setup.py clean && \
    pip install -r requirements.txt && \
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

# Build Vision
WORKDIR /vision

RUN export BUILD_VERSION=$(git describe --tags --exact | sed 's/^v//')  && \
    python3 setup.py bdist_wheel && \
    pip install dist/torchvision-*-cp310-cp310-linux_x86_64.whl && \
    true


## Personal Stuff to handle docker better        
RUN apt-get install -y --no-install-recommends tmux mc pigz && \
    true


EXPOSE ${PORT}
EXPOSE 22/tcp

#VOLUME [ "/ComfyUI", "/ComfyUI/custom_nodes","/ComfyUI/models","/ComfyUI/output","/ComfyUI/input"]
#ENTRYPOINT python main.py --listen --use-split-cross-attention --port "${PORT}"
CMD ["/bin/bash","-c"]
