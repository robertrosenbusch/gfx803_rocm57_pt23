# ROCm 5.7, PyTorch 2.3, Torchvision 0.18 with AMD GFX803 aka AMD Polaris aka AMD RX570/RX580/RX590

This repo provides a docker buildfile based on the original ROCm Dockerimage to compile PyTorch and Torchvision for the AMD RX570/RX580/RX590 generation. PyTorch and Torchvision are not compiled to use the GPU-Polaris generation in the original PIP repository. However, if Polaris GPU support is to be used in ComfyUI or A1111 StableDiffusion, there is no way around newly compiled pyTorch and Torvision whl/wheel python files. That what this Docker Buildfile will do for you.

## ROCm-5.7.0 in a Dockerfile

|OS            |linux|Python|ROCm |PyTorch|Torchvision|GPU|
|--------------|-----|------|-----|-----|-----|-----|
|Ubuntu-22.04.2|5.19 |3.10.10|5.7.0|2.3.0|0.18.0|RX570 aka Polaris|

* <https://github.com/xuhuisheng/rocm-gfx803/releases/tag/rocm541>
* PyTorch GIT: <https://github.com/pytorch/pytorch>
* Torchvison GIT: 

Install ROCm First <https://docs.amd.com/bundle/ROCm-Installation-Guide-v5.4.1/page/Introduction_to_ROCm_Installation_Guide_for_Linux.html>


1. Install ROCm-5.4.1
3. `sudo dpkg -i rocblas_2.46.0.50401-84.20.04_amd64.deb`
4. `pip3 install torch-1.11.0a0+git503a092-cp38-cp38-linux_x86_64.whl`
5. `pip3 install torchvision-0.12.0a0+2662797-cp38-cp38-linux_x86_64.whl`
6. `pip3 install tensorflow_rocm-2.8.0-cp38-cp38-linux_x86_64.whl`

PS: You may need `export LD_LIBRARY_PATH=/opt/rocm/lib` to resolve cannot find libmiopen.so error.

2. `export LB_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rocm/hip/lib`
3. `pip3 install torch-1.7.0a0-cp38-cp38-linux_x86_64.whl`
4. `pip3 install torchvision-0.8.0a0+2f40a48-cp38-cp38-linux_x86_64.whl`
