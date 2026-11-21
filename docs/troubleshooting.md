# 故障排查

## 8765 端口未监听

- 运行 `REA-Manager.ps1 diagnose`。
- 检查 REA CLI、Node.js、Ghidra 与 Java 运行目录是否存在。
- 查看 REA Server 启动日志/终端错误。
- 如果端口已被其他进程占用，先确认进程身份与命令行，不要直接结束进程。

## 8787 已占用

- 先检查 `http://127.0.0.1:8787/healthz` 和 `/readyz`。
- 如果已有 Tunnel Client 正常 READY，不要启动第二个实例。
- 如果端口被其他程序占用或健康检查失败，先定位进程；不要自动杀进程或清空端口。

## Tunnel 未 READY

- 检查 Tunnel Client 日志。
- 使用当前版本的官方 CLI doctor/preflight 命令。
- 确认运行时凭据有效，并且组织/项目权限包含所需 Tunnel Read 与 Tunnel Use。
- 检查 profile 中本地 MCP URL 与实际监听地址一致。
- 不要把密钥或完整认证日志贴到问题单。

## 本机正常但 ChatGPT 无法调用

依次检查：
1. Tunnel 与控制平面是否成功建立连接。
2. 新账号是否属于正确的组织/项目。
3. 账号是否具有 Tunnel Read/Use 权限。
4. Tunnel 是否关联到目标 ChatGPT 工作区。
5. 目标工作区是否启用了对应自定义 MCP App。
6. 工具调用是否被工作区策略或审批流程阻止。

## 安全提交诊断信息

分享前删除用户名、绝对路径、Tunnel ID、密钥、Authorization、Cookie、会话标识、文件名和样本信息。优先提供端口状态、错误类别、退出码和脱敏后的时间戳。
