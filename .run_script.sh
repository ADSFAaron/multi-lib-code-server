docker run --privileged -d --init `
  --name vscode-server `
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

  docker run --privileged -d --init `
  --name vscode-server `
  --gpus=all `
  --restart always `
  --cpus="4" `
  --dns 8.8.8.8  `
  --ipc=host `
  --user="1000:1000" `
  --volume="${PWD}:/projects" `
  -p 8888:8443 `
  -e PASSWORD='password' `
  -e EXTENSIONS="ms-python.python,tushortz.python-extended-snippets,andyyaldoo.vscode-json,golang.go,redhat.vscode-yaml,vscode-icons-team.vscode-icons,HashiCorp.terraform,Tim-Koehler.helm-intellisense,Equinusocio.vsc-material-theme" `
  vscode-server-gpu:11.6.2