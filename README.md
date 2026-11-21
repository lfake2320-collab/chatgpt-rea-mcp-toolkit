# ChatGPT REA MCP Toolkit

用于在 Windows 本机部署、检查和维护 REA MCP，并将其通过 OpenAI Secure MCP Tunnel 接入网页版 ChatGPT。

> 本仓库是通用工具包。仓库当前为 Public：只允许提交脱敏文档、示例配置和不含凭据的脚本。禁止提交 API Key、Tunnel Runtime API Key、认证头、真实 tunnel/profile 标识、私有日志、个人文件路径或反编译样本。

## 目标架构

```
ChatGPT Web / Workspace
        │  Custom MCP App
        ▼
OpenAI Secure MCP Tunnel
        │
Tunnel Client (Windows, 127.0.0.1:8787)
        │
REA MCP HTTP (127.0.0.1:8765)
        │
REA runtime / analysis tools
```

本机的 8766 代理是可选的独立本地转发组件（例如供其他受信任网络入口使用），不是 OpenAI Secure MCP Tunnel 的必经链路。

## 当前内容

- `scripts/REA-Manager.ps1`：交互菜单与 CLI 共用的本机状态检查/启动/诊断工具。
- `config/rea-local.example.yaml`：脱敏配置模板说明（不含真实 Tunnel ID）。
- `docs/architecture.md`：链路与组件边界。
- `docs/setup-web-chatgpt.md`：网页版 ChatGPT 接入步骤。
- `docs/account-switching.md`：切换 ChatGPT 账号/工作区的复用流程。
- `docs/troubleshooting.md`：常见故障定位。
- `docs/security.md`：凭据、日志与仓库安全要求。

## 快速开始

1. 将仓库克隆到本机。
2. 阅读 [安全说明](docs/security.md) 和 [接入说明](docs/setup-web-chatgpt.md)。
3. 将 `scripts/REA-Manager.ps1` 复制到本机可信目录，或在仓库目录直接运行。
4. 在 PowerShell 中执行：

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\scripts\REA-Manager.ps1
   .\scripts\REA-Manager.ps1 check
   .\scripts\REA-Manager.ps1 diagnose
   ```

5. 确认本机服务正常后，再到 ChatGPT 对应工作区添加 MCP App，并执行只读工具调用验证。

## 支持范围与边界

- 当前脚本针对 Windows PowerShell 5.1+ / PowerShell 7，依赖本机已有 REA 运行目录结构。
- 管理器默认读取 `%USERPROFILE%\.dsh\rea-runtime`，也可通过 `-RuntimeRoot` 指定其他路径。
- 管理器不会自动创建/删除 Tunnel、重置配置、轮换密钥或修改 ChatGPT 工作区权限。
- 本机检查无法证明 ChatGPT 账号侧授权成功；必须在目标账号/工作区实际调用 MCP 工具验证。
- 版本和 CLI 参数可能随上游更新变化，执行升级前请重新核对官方文档。

## 目录

- [架构](docs/architecture.md)
- [网页版接入](docs/setup-web-chatgpt.md)
- [账号切换](docs/account-switching.md)
- [故障排查](docs/troubleshooting.md)
- [安全规范](docs/security.md)
- [脚本使用](scripts/README.md)
