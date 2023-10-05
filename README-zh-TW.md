# Multi-Lib Code Server with CUDA

[🌎 English Readme](/README.md)

期望可以解決不同電腦造成的複雜的安裝環境，且可以在任何瀏覽器中運行 [VS Code](https://github.com/Microsoft/vscode)

感謝 [works-on-my-machine](https://github.com/works-on-my-machine/pytorch-code-server)，讓我有個好的 base image 可以做修改

Dockerfile 包含下列套件：

- CUDA 11.6.2
- CUDNN 8
- Python 2.7.18
- Python 3.8.10
- PyTorch 1.13.0+cu116
- torchdata==0.6.1, torchtext==0.15.2, ...
- Tensorflow-gpu 2.10.1
- Code Server 4.17.1 (VS Code v1.82.2)
- 等等等等等

## Requirements

### Windows

- CUDA 裝置且有計算能力 (compute capability) 高於 3.5
- 根據自身主機規格，安裝下列驅動和應用程式
  - [WSL2](https://learn.microsoft.com/zh-tw/windows/wsl/install)
  - [Nvidia 顯示卡驅動](https://www.nvidia.com/download/index.aspx)
  - [Docker](https://www.docker.com/)
- 可使用 `nvidia-smi` 檢查 Nvidia 顯示卡驅動是否成功安裝和辨識
- Docker 安裝完成後，可使用 Powershell/Ubuntu 測試 `docker info` 是否有成功顯示 Docker 資訊
- 要有 CUDA 支援要有 NVIDIA 顯示卡阿~

### Linux

- CUDA 裝置且有計算能力 (compute capability) 高於 3.5，可至 [NVIDIA-CUDA-GPUS](https://developer.nvidia.com/cuda-gpus) 參考
- [NVIDIA Docker Toolkit](https://github.com/ghokun/nvidia-docker-host)

## Docker image link

[DockerHub](https://hub.docker.com/r/adsfaaron/vscode-server-gpu)

## 如何使用

在 Windows 環境下，進入 Powershell/Ubuntu 後，切換路徑到欲連接的 Volume

### 從 Docker Image 啟動 VSCode Server

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

執行完上述的指令，且沒有錯誤時，即可從 <http://localhost:8888> 連入網頁中的 VS Code (～￣▽￣)～

### 更多設定啟動 VSCode Server

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

### 指令說明

> 您可以自行選擇是否要加入這些參數

- `--restart always` : Container 意外中斷後，會持續進行重新啟動
- `--cpus="4"` : 設定最多可調用 4 個邏輯處理器核心到 Container
- `--dns 8.8.8.8` : 設定 Container 的 DNS，是因為小弟我的主機預設的 DNS 有時很不穩，沒有一定要加拉 〒▽〒
- `-p 8888:8443` : 表示建立的 container 目前 8443 port 將與主機的 8888 port 連接。
  - 舉例來說，目前主機想要一個對外的 port 是 1234，則需修改為 `-p 1234:8443`
  - ⚠️ 在 Windows Server 中，須至防火牆設定對外連接阜，否則在 wsl 設定的 port 在外也連不到，可參考 [Bridge-WslPorts](/Bridge-WslPorts.ps1) 解決此問題
- `-e PASSWORD` : 設定 VSCode 進入頁面前的密碼，建議設定較高難度的密碼。若沒有設定，需另開一個 Container 的 Terminal 進入 `~/.config/code-server/config.yaml` 中尋找密碼
- `-e EXTENSIONS` : 預先安裝 Code-server 中的套件，方便使用者進入後即可快速使用。更多的使用者套件，請至 [Open-vsx](https://open-vsx.org/) 查詢，並且記錄套件頁面的 Bundled Extensions。多個套件使用 `,` 進行分隔

```bash
docker exec -it <your_container_name> /bin/bash
cat ~/.config/code-server/config.yaml
```

也可以使用 Docker Container ID ( `docker ps -a` ) 進入

```bash
docker attach <your_container_id> /bin/bash
cat ~/.config/code-server/config.yaml
```

若要跳出 Container，可以使用 `CTRL-p CTRL-q`，詳細指令請參考 [DockerAttach](https://docs.docker.com/engine/reference/commandline/attach/)

- `--volume`, `-v` : Container 與本機資料夾連線，可傳輸檔案
  - `本機路徑 : Container 路徑`
  - 可套用多個路徑連接 e.g. 連接 vscode config 檔案
  - `${PWD}` : 表示為目前路徑
  
  ```powershell
  -v ${PWD}/config:/home/coder/.config
  ```

- `--ipc` : 可參考 [philipzheng](https://philipzheng.gitbook.io/docker_practice/underly/namespace) 所撰寫的詳細內容
- `--user` : 使用者的權限，僅在 linux 上才有，可參考 [askubuntu](https://askubuntu.com/questions/645236/command-to-list-all-users-with-their-uid)，預設使用者是 1000，因此 Windows 上直接指定值，避免出錯
- `--gpus=all` : 表示 Container 可以調用到所有的顯示卡，若要指定特定的顯卡，可以使用下方指令尋找
  
  ```bash
  nvidia-smi --query-gpu=uuid --format=csv
  ```

  查詢後，在 docker run GPU 欄位修改如下

  ```bash
  --gpus "device=GPU-<uuid>"
  ```

  或是使用 (在我的 WSL2 環境下，底下這個指令沒有作用)

  ```bash
  --gpus device=0
  ```

## Encrypted Code Server

由於在 http 中的 VSCode Server 圖片顯示上會無法顯示，為了解決此方法，您有兩種選擇

1. 使用 Reverse Proxy
2. 修改 `Dockerfile`，在檔案的最後 `ENTRYPOINT` 需加上 `"--cert"`，並且在 `entrypoint.sh` 中增加 volume 連接，

因為我的 Code server 主要是多人使用，因此選擇 Reverse Proxy 來實作
> 這方法不會是最快、耗最少資源的方式，但比較簡易操作

1. 至 DockerHub 下載 [nginx-proxy-manager](https://hub.docker.com/r/jc21/nginx-proxy-manager)
2. 啟用 Nginx Proxy Manager，若要使用 dockerfile 啟動，可參考 [NginxProxyManager]
3. 進入 `localhost:81` 或是  `127.0.0.1:81` 登入帳號密碼
4. 在 Menu 選單中，點擊 `SSL Certificates`，點擊 `Add SSL Certificate`，並選擇 Let's Encrypt
5. Domain Names 填寫申請的網址位置，可透過 Godaddy、Cloudflare 等多種營運商購買，或使用免費的 Duckdns、Freenom ，可自行選擇其一，設定好 domain name 轉 ip address，接著點擊 Save
6. 經過一段時間後，驗證完成，即可以使用憑證
7. 在 Menu 選單中，進入 `Host` > `Proxy Hosts`，點擊 `Add Proxy Host`
8. `Domain Names` 填入剛剛申請的網址
   1. `Scheme` 選擇 http
   2. `Forward Hostname / IP` 填入自己電腦的 ip，或是在雲端運算的 ip 位置 (e.g. 127.0.0.1，localhost 填入會無法解析)
   3. `Forward Port` 選擇電腦送出的 port
   4. `Web Socket Supports` 在 VS Code Server 需開啟，否則登入畫面會呈現空白
9. 選擇 `SSL`，`SSL Certificate`，選擇在 6. 取得的網頁憑證，`Force SSL` `HTTP/2 Support` 需開啟
10. 點擊 Save，透過網址輸入即可看到 VS Code 登入畫面

## How to rebuild this image

1. 切換路徑至目前 Folder 下
2. `docker build -t vscode-server-gpu:11.6.2 .`

🔣 指令說明

- `-t(--tag) vscode-server-gpu:11.6.2` : 標籤 image 名字
- `.` : 表示為根據目前的目錄建置，若有特別的路徑 可在此設置
- 更多詳細內容，可參考 [Docker build](https://docs.docker.com/engine/reference/commandline/build/)

⚠️ 建議 build 時是在 linux 環境下，windows 容易在設置使用者權限時出錯

## Limitation

- 在 vscode-server 中無法再使用 ssh 連線至其他主機

## Notes

- 在 reversed proxy 時，HTTPS 僅可在輸入網址時可使用，若要在 ip 上使用 HTTPS (如 <https://192.168.0.1>)，會使用 http 連入

## TODO

- [x] 完善 dockerfile 配置使用說明
- [x] 使用指令預設安裝 VSCode 套件
- [ ] 增加 readme 圖片
- [ ] 說明 dockerfile / entrypoint.sh

## Reference

- [WSL-config](https://learn.microsoft.com/zh-tw/windows/wsl/wsl-config)
- [pytorch-code-server](https://github.com/works-on-my-machine/pytorch-code-server)
- [NVIDIA-CUDA](https://hub.docker.com/r/nvidia/cuda)
- [NginxProxyManager](https://github.com/NginxProxyManager/nginx-proxy-manager)
