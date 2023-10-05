# Source: Internet

# Change the port that you want to forward
$ports = @(80, 443);

# from port 8000 ~ 8080
$ports += 8000 .. 8080

# total: 80, 443, 8000, 8001, ... 8080

# Check wsl ip address
$wslAddress = bash.exe -c "ifconfig eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'";

if ($wslAddress -match '^(\d{1,3}\.){3}\d{1,3}$') {
  Write-Host "WSL IP address: $wslAddress" -ForegroundColor Green
  Write-Host "Ports: $ports" -ForegroundColor Green
}
else {
  Write-Host "Error: Could not find WSL IP address." -ForegroundColor Red
  exit
}

$listenAddress = '0.0.0.0';

# delete previous port forwarding and add
foreach ($port in $ports) {
  Invoke-Expression "netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$listenAddress";
  Invoke-Expression "netsh interface portproxy add v4tov4 listenport=$port listenaddress=$listenAddress connectport=$port connectaddress=$wslAddress";
}

$fireWallDisplayName = 'WSL Port Forwarding';
$portsStr = $ports -join ",";

# add rule to firewall
Invoke-Expression "Remove-NetFireWallRule -DisplayName $fireWallDisplayName";
Invoke-Expression "New-NetFireWallRule -DisplayName $fireWallDisplayName -Direction Outbound -LocalPort $portsStr -Action Allow -Protocol TCP";
Invoke-Expression "New-NetFireWallRule -DisplayName $fireWallDisplayName -Direction Inbound -LocalPort $portsStr -Action Allow -Protocol TCP";