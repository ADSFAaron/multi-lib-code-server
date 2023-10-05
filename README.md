# Multi-Lib Code Server with CUDA

[🀄 繁體中文 Readme](/README-zh-TW.md)

This repository aims to solve the complex installation environment caused by different computers and enables running [VS Code](https://github.com/Microsoft/vscode) in any web browser.

Thank you [works-on-my-machine](https://github.com/works-on-my-machine/pytorch-code-server) for providing me with a great base image that I can modify.

The Dockerfile includes the following packages:

- CUDA 11.6.2
- CUDNN 8
- Python 2.7.18
- Python 3.8.10
- PyTorch 1.13.0+cu116
- torchdata==0.6.1, torchtext==0.15.2, ...
- Tensorflow-gpu 2.10.1
- Code Server 4.17.1 (VS Code v1.82.2)

## Requirements

### Windows

- CUDA device with compute capability higher than 3.5
- Install the following drivers and applications depends on your machine specifications:
  - [WSL2](https://learn.microsoft.com/zh-tw/windows/wsl/install)
  - [Nvidia Driver](https://www.nvidia.com/download/index.aspx)
  - [Docker](https://www.docker.com/)
- To verify the successful installation and recognition of Nvidia display drivers using `nvidia-smi`.
- After installing Docker, test if `docker info` shows Docker information successfully.
- Make sure you have an NVIDIA graphics card with CUDA support.

### Linux

- CUDA device with compute capability higher than 3.5. Refer to [NVIDIA-CUDA-GPUS](https://developer.nvidia.com/cuda-gpus) for more information.
- [NVIDIA Docker Toolkit](https://github.com/ghokun/nvidia-docker-host)

## Docker image link

[DockerHub](https://hub.docker.com/r/adsfaaron/vscode-server-gpu)

## Quick Start

In a Windows environment, open PowerShell/Ubuntu and navigate to the desired volume.

### Launch VSCode Server from Docker Image

Windows

```powershell
docker run --privileged --rm -it --init `
  --gpus=all `
  --ipc=host `
  --user="1000:1000" `
  --volume="${PWD}:/projects" `
  -p 8888:8443 `
  adsfaaron/vscode-server-gpu:11.6.2
```

Linux

```bash
docker run --privileged --rm -it --init \
  --gpus=all \
  --ipc=host \
  --user="$(id -u):$(id -g)" \
  --volume="$PWD:/projects" \
  -p 8888:8443 \
  adsfaaron/vscode-server-gpu:11.6.2
```

After running above command without any errors, you can access VS Code in your web browser at <http://localhost:8888> (～￣▽￣)～

### Launch VSCode Server with More Configurations

Windows

```powershell
docker run --privileged -d --init `
  --gpus=all `
  --restart always `
  --cpus="4" `
  --dns 8.8.8.8  `
  --ipc=host `
  --user="1000:1000" `
  --volume="${PWD}:/projects" `
  -p 8888:8443 `
  -e PASSWORD='password' `
  -e EXTENSIONS="ms-python.vscode-pylance,tushortz.python-extended-snippets,andyyaldoo.vscode-json,vscode-icons-team.vscode-icons" `
  adsfaaron/vscode-server-gpu:11.6.2
```

Linux

```bash
docker run --privileged --rm -it --init \
  --gpus=all \
  --restart always \
  --cpus=4 \
  --dns 8.8.8.8 \
  --ipc=host \
  --user="$(id -u):$(id -g)" \
  --volume="$PWD:/projects" \
  -p 8888:8443 \ 
  -e PASSWORD='password' \
  -e EXTENSIONS="ms-python.vscode-pylance,tushortz.python-extended-snippets,andyyaldoo.vscode-json,vscode-icons-team.vscode-icons" \
  adsfaaron/vscode-server-gpu:11.6.2
```

### Command Explanation

> You can choose whether to include these parameters.

- `--restart always` : Automatically restart the container if it unexpectedly stops.
- `--cpus="4"` : Limit the container to use a maximum of 4 logical processor cores.
- `--dns 8.8.8.8` : Set the DNS for the container. This is used because the default DNS on the host machine is sometimes unstable. It is not necessary to include this parameter if you don't need it.
- `-p 8888:8443` : This maps port 8443 from the container to port 8888 on the host. You can change it to any other port, e.g., `-p 1234:8443`.
  - In Windows Server might encounter the firewall rules problem, please reference to [Open WslPort](/Bridge-WslPorts.ps1) file to fix it.
- `-e PASSWORD` : Set the password for accessing the VS Code interface. It is recommended to set a strong password. If not set, you will need to open another terminal in the container and look for the password in `~/.config/code-server/config.yaml`.
- `-e EXTENSIONS` : Pre-install extensions for Code-server. For more extensions, navigate to [Open-vsx](https://open-vsx.org/) and copy "Bundled Extensions" contents, separating multiple extensions with commas.

```bash
docker exec -it <your_container_name> /bin/bash
cat ~/.config/code-server/config.yaml
```

You can also use the Docker Container ID (`docker ps -a`) to access it.

```bash
docker attach <your_container_id> /bin/bash
cat ~/.config/code-server/config.yaml
```

To detach from the container, you can use `CTRL-p CTRL-q`. Refer to [DockerAttach](https://docs.docker.com/engine/reference/commandline/attach/) for more details.

- `--volume, -v`: Connect the container to a local folder to transfer files.
  - `host_path : container_path`
  - `${PWD}` represents the current path.
  - Multiple paths can be connected, for example, to connect the VS Code config file:

```powershell
  -v ${PWD}/config:/home/coder/.config
```

- `--ipc`: For more details, refer to [philipzheng](https://philipzheng.gitbook.io/docker_practice/underly/namespace).

- `--user`: User permission. Only applicable on Linux. You can refer to [askubuntu](https://askubuntu.com/questions/645236/command-to-list-all-users-with-their-uid) for the default user (1000). In Windows, you can directly specify the value to avoid errors.

- `--gpus=all`: Allows the container to access all available graphics cards. If you want to specify a specific graphics card, you can use the following command to find the GPU UUID:

  ```bash
  nvidia-smi --query-gpu=uuid --format=csv
  ```

  After obtaining the UUID, modify the `--gpus` field in the `docker run` command as follows:

  ```bash
  --gpus "device=GPU-<uuid>"
  ```

  Alternatively, you can use the following command (this command didn't work in my WSL2 environment):

  ```bash
  --gpus device=0
  ```

## How to Rebuild this Image

1. Navigate to the current folder.
2. Run `docker build -t vscode-server-gpu:11.6.2 ..`

🔣 Command Explanations:

- `-t(--tag) vscode-server-gpu:11.6.2` : Tags the image with the name vscode-server-gpu and version 11.6.2.
- `.` : Specifies that the build should use the current directory. You can specify a different path if needed.
- It's **recommended to build the image in a Linux** environment, as Windows may encounter user permission issues during the building process.

## Notes

- HTTPS can only be used when entering the URL. If you try to use HTTPS with an IP address (e.g., <https://192.168.0.1>), it will not work. Only HTTP can be used in such cases.

## Limitations

- Cannot use SSH to connect to other hosts within the vscode-server.

## TODO

- [x] Enhance Dockerfile configuration and usage instructions.
- [x] Default installation of VSCode extensions using commands.
- [ ] Add README images.
- [ ] Explain the Dockerfile and entrypoint.sh.

## Reference

- [WSL-config](https://learn.microsoft.com/zh-tw/windows/wsl/wsl-config)
- [pytorch-code-server](https://github.com/works-on-my-machine/pytorch-code-server)
- [NVIDIA-CUDA](https://hub.docker.com/r/nvidia/cuda)
- [NginxProxyManager](https://github.com/NginxProxyManager/nginx-proxy-manager)