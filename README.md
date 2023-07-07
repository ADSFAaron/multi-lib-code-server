# Multi-Lib Code Server with CUDA

Code Server Docker image for PyTorch and Tensorflow with python development on the browser. Contains:

- CUDA 11.6.2
- CUDNN 8
- Python 2.7.18
- Python 3.8.10
- PyTorch 1.13.0+cu116
- Tensorflow-gpu 2.10.1
- Code Server 4.14.1 (VS Code v1.79.2)

## Requirements

- CUDA device with compute capability 3.5 or higher
- [NVIDIA Docker Toolkit](https://github.com/ghokun/nvidia-docker-host)
- For Windows user, please use WSL2.
- Check the driver, used this command
  - `nvidia-smi`

## Quick Start

```bash
docker run --privileged --rm -it --init \
  --gpus=all \
  --ipc=host \
  --user="$(id -u):$(id -g)" \
  --volume="$PWD:/projects" \
  -p 8443:8443 \
  ghcr.io/works-on-my-machine/pytorch-code-server:1.10.0
```

After running above command open `localhost:8443` in your browser. Find your password under `~/.config/code-server/config.yaml`

```bash
docker exec -it <your_container_name> /bin/bash
cat ~/.config/code-server/config.yaml
```

Login with your password. For a working example look at example project folder. Contains recommended extensions and settings. Example project also contains noVNC support. Checkout `docker-compose.yml` file for more information.

## Notes


## TODO

- [ ] Better documentation
- [x] NO-VNC support for visualization
- [x] Docker compose support
- [ ] HTTPS enabled
