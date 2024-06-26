# ROCm 5.7, PyTorch 2.3, Torchvision 0.18 with AMD GFX803 aka AMD Polaris aka AMD RX570/RX580/RX590

This repo provides a docker buildfile based on the original ROCm-Dockerimage to compile PyTorch and Torchvision for the [AMD RX570/RX580/RX590](https://en.wikipedia.org/wiki/Radeon_500_series) generation. PyTorch and Torchvision are not compiled to use the GPU-Polaris generation in the original PIP repository. And of course not compiled too in the official ROCm-PyTorch Dockerfile. However, if Polaris 20/21 GPU support is to be used in ComfyUI or A1111 StableDiffusion, there is no way around newly compiled pyTorch and Torvision whl/wheel python files. That what this Docker Buildfile will do for you.

## ROCm-5.7.0 in a Dockerfile

|OS            |linux|Python|ROCm |PyTorch|Torchvision|GPU|
|--------------|-----|------|-----|-----|-----|-----|
|Ubuntu-22.04.2|5.19 |3.10.10|5.7.0|2.3.0|0.18.0|RX570/580/590 aka Polaris 20/21 aka GCN 4|

* Used ROCm Docker Version: [Ubuntu 22.04+ROCm5.7+Python3.10](https://hub.docker.com/layers/rocm/pytorch/rocm5.7_ubuntu22.04_py3.10_pytorch_2.0.1/images/sha256-21df283b1712f3d73884b9bc4733919374344ceacb694e8fbc2c50bdd3e767ee)     

* PyTorch GIT: [v2.3.0](https://github.com/pytorch/pytorch)
* Torchvison GIT: [v0.18.0](https://github.com/pytorch/vision)

- It is _not_ necessary to install the entire ROCm-Stack on the host system. _Unless_ you want to use something to optimize your GPU via rocm-smi. In my case, I need the rocm stuff to reduce the power consumption of my RX570 GPU to 145 watts with `rocm-smi --setpoweroverdrive 145 && watch -n2 rocm-smi` every time I restart the container.

1. install the docker-subsystem / docker.io on your linux system
2. download the latest file version of this github
3. build your Docker image via `docker build . -t 'rocm57_pt23:v1'`
4. start the container via:
5. `docker run -it --device=/dev/kfd --device=/dev/dri --group-add=video --ipc=host \
   --cap-add=SYS_PTRACE --security-opt seccomp=unconfined  -p 8188:8188 rocm57_pt23:v1`
7. install ComfyUI and download a Model or map an Directory on your Host-Computer
8. After installing ComfyUI _reinstall_ pytorch and torchvision wheels into your ComfyUI-Python-Environment. you find the Polaris compiled Python-Wheel-Files into the "/pytorch/dist" and "/torchvision/dist" Directory
