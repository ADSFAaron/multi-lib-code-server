# PyTorch Code Server with CUDA
Code Server Docker image for PyTorch with python development on the browser. Contains:
- CUDA 11.1
- Python 3.8.3
- PyTorch 1.81.1
- Code Server 3.9.3 (VSCode 1.54.2)

## Requirements
- CUDA device with compute capability 3.5 or higher
- [NVIDIA Docker Toolkit](https://github.com/ghokun/nvidia-docker-host)


## Quickstart
```
$ docker run --privileged --rm -it --init \
  --gpus=all \
  --ipc=host \
  --user="$(id -u):$(id -g)" \
  --volume="$PWD:/projects" \
  -p 8443:8443 \
  ghcr.io/works-on-my-machine/pytorch-code-server:latest
```
After running above command open `localhost:8443` in your browser. Find your password under `~/.config/code-server/config.yaml`
```bash
$ docker exec -it <your_container_name> /bin/bash
$ cat ~/.config/code-server/config.yaml
```
Login with your password. For a working example look at example project folder. Contains recommended extensions and settings.
## Notes
- Due to a possible [bug](https://github.com/cdr/code-server/issues/2514) in `ms-python.python` extension. After installing it revert it to a previous version by selecting "Install Another Version". 2020.10.332292344 worked for me.

## TODO
- [ ] Better documentation
- [ ] NO-VNC support for visualization
- [ ] Docker compose support
