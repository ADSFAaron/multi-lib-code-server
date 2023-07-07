# Multi-Lib Code Server with CUDA

期望可以解決不同電腦造成的複雜的安裝環境，且可以在任何瀏覽器中運行 [VS Code](https://github.com/Microsoft/vscode)

Dockerfile 包含下列套件：

- CUDA 11.6.2
- CUDNN 8
- Python 2.7.18
- Python 3.8.10
- PyTorch 1.13.0+cu116
- torchdata==0.6.1, torchtext==0.15.2, ...
- Tensorflow-gpu 2.10.1
- Code Server 4.14.1 (VS Code v1.79.2)

## Requirements

### Windows

- Windows 使用者，請安裝下列驅動和應用程式
  - [WSL2](https://learn.microsoft.com/zh-tw/windows/wsl/install)
  - [Nvidia 顯示卡驅動](https://www.nvidia.com/download/index.aspx)
  - [Docker](https://www.docker.com/)
- 可使用 `nvidia-smi` 檢查 Nvidia 顯示卡驅動是否成功安裝和辨識
- Docker 安裝完成後，可使用 Powershell/Ubuntu 測試 `docker info` 是否有成功顯示 Docker 資訊

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
  adsfaaron/vscode-server-gpu:11.6.2
```

### 指令說明

> 您可以自行選擇是否要加入這些參數

- `--restart always` : Container 意外中斷後，會持續進行重新啟動
- `--cpus="4"` : 設定最多可調用 4 個邏輯處理器核心到 Container
- `--dns 8.8.8.8` : 設定 Container 的 DNS，是因為小弟我的主機預設的 DNS 有時很不穩，沒有一定要加拉 〒▽〒
- `-e PASSWORD` : 設定 VSCode 進入頁面前的密碼，建議設定較高難度的密碼。若沒有設定，需另開一個 Container 的 Terminal 進入 `~/.config/code-server/config.yaml` 中尋找密碼

```bash
docker exec -it <your_container_name> /bin/bash
cat ~/.config/code-server/config.yaml
```

也可以使用 Docker Container ID ( `docker ps -a` ) 進入

```bash
docker attach <your_container_id> /bin/bash
cat ~/.config/code-server/config.yaml
```

- `--volume`, `-v` : Container 與本機資料夾連線，可傳輸檔案
  - `本機路徑 : Container 路徑`
  - 可套用多個路徑連接 e.g. 連接 vscode config 檔案
- `--ipc` : 可參考 [philipzheng](https://philipzheng.gitbook.io/docker_practice/underly/namespace) 所撰寫的詳細內容
- `--user` : 使用者的權限，僅在 linux 上才有，可參考 [askubuntu](https://askubuntu.com/questions/645236/command-to-list-all-users-with-their-uid)，預設使用者是 1000，因此 Windows 上直接指定值，避免出錯

## Encrypted Code Server

由於在 http 中的 VSCode Server 圖片顯示上會無法顯示，為了解決此方法，您有兩種選擇

1. 使用 Reverse Proxy
2. 修改 `Dockerfile`，在檔案的最後 `ENTRYPOINT` 需加上 `"--cert"`，並且在 `entrypoint.sh` 中增加 volume 連接，

因為這個 Code server 主要是多人使用，因此選擇 Reverse Proxy 來實作
> 這方法不會是最快、耗最少資源的方式，但比較簡易操作

1. 至 DockerHub 下載 [DockerHub](https://hub.docker.com/r/jc21/nginx-proxy-manager)
2. 啟用 Nginx Proxy Manager，若要使用 dockerfile 啟動，可參考 [NginxProxyManager](https://github.com/NginxProxyManager/nginx-proxy-manager)
3. 進入 `localhost:81` 登入帳號密碼
4. 在 Menu 選單中，點擊 `SSL Certificates`，點擊 `Add SSL Certificate`，並選擇 Let's Encrypt
5. Domain Names 填寫申請的網址位置，可透過 Godaddy、Cloudflare 等多種營運商，可自行選擇其一，接著點擊 Save
6. 經過一段時間後，驗證完成，即可以使用憑證
7. 在 Menu 選單中，進入 `Host` > `Proxy Hosts`，點擊 `Add Proxy Host`
8. `Domain Names` 填入剛剛申請的網址
   1. `Scheme` 選擇 http
   2. `Forward Hostname / IP` 填入自己電腦的 ip，或是在雲端運算的 ip 位置 (e.g. 127.0.0.1，localhost 填入會無法解析)
   3. `Forward Port` 選擇電腦送出的 port
   4. `Web Socket Supports` 在 VS Code Server 需打開，否則登入畫面會呈現空白
9. 選擇 `SSL`，`SSL Certificate`，選擇在 6. 取得的網頁憑證，`Force SSL` `HTTP/2 Support` 需開啟
10. 點擊 Save，透過網址輸入即可看到 VS Code 登入畫面

## Notes

- HTTPS 僅可在輸入網址時可使用，若要在 ip 上使用 HTTPS (如 <https://192.168.0.1>)，將無法使用，僅可使用 http 連入

## TODO

- [ ] 完善 dockerfile 配置使用說明
- [ ] 說明 docker run 流程
- [ ] noVNC support 理解

## Reference

- [WSL-config](https://learn.microsoft.com/zh-tw/windows/wsl/wsl-config)
- [pytorch-code-server](https://github.com/works-on-my-machine/pytorch-code-server)
- [NVIDIA-CUDA](https://hub.docker.com/r/nvidia/cuda)
