# REA-Manager.ps1 使用说明

## 交互菜单

```powershell
.\scripts\REA-Manager.ps1
```

## CLI

```powershell
.\scripts\REA-Manager.ps1 check
.\scripts\REA-Manager.ps1 start
.\scripts\REA-Manager.ps1 diagnose
.\scripts\REA-Manager.ps1 repair
.\scripts\REA-Manager.ps1 logs
```

## 参数

```powershell
.\scripts\REA-Manager.ps1 check -RuntimeRoot "D:\MyDsh\rea-runtime"
```

默认运行目录为 `%USERPROFILE%\.dsh\rea-runtime`。启动脚本路径默认按当前部署结构查找：
- `%USERPROFILE%\.dsh\profiles\desktop\scripts\start-rea-server.ps1`
- `%USERPROFILE%\.dsh\rea-runtime\tunnel-client\run-rea-tunnel.ps1`

管理器不会读取或输出 Runtime API Key。启动 Tunnel 时由现有启动脚本自行安全提示输入密钥。

## 注意

脚本仅提供本机端口/HTTP健康检查和安全启动协调，不检查 ChatGPT 账号侧授权，也不修改 Tunnel profile。
