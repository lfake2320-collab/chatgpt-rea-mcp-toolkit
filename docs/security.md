# 安全与隐私

## 严禁提交到仓库

- OpenAI Runtime API Key、API Key、Bearer Token、OAuth Token、Cookie、Authorization Header。
- Tunnel ID、真实 profile 内容、账户/组织/项目标识及可用于定位私人资源的连接信息。
- 完整运行日志、认证日志、会话内容、用户文件、反编译样本和个人数据。
- 用户名、家目录、内部网络地址或其他不必要的机器指纹。

## 仓库公开策略

本仓库当前是 Public。所有文件必须按“任何人都能读取”处理。只提交占位符和通用操作说明。即使仓库改为 Private，也不应把密钥或认证材料作为版本控制内容。

## 本机密钥处理

- 需要输入 Runtime API Key 时，使用隐藏输入（SecureString/安全提示）。
- 仅在子进程需要的短时间内通过受支持的环境变量传递。
- 不将密钥写入脚本、profile、日志、PowerShell 历史或命令行参数。
- 操作结束后清理进程环境变量与临时变量。
- 发生疑似泄露时，立即按平台流程撤销/轮换受影响凭据。

## 脚本安全约束

- `check`、`diagnose`、`logs` 默认只读。
- `start` 不覆盖配置，不终止现有进程；端口已占用时先探测。
- `repair` 必须二次确认，并且只执行明确列出的启动动作。
- 不自动删除目录、profile、日志或凭据。
