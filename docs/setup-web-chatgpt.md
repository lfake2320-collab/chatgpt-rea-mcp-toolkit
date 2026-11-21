# 将本机 REA 接入网页版 ChatGPT

> 界面名称和入口会随 ChatGPT 版本、套餐及组织策略变化。请以当前账号实际可见的设置为准。

## 一、本机准备

1. 确认 REA MCP Server 已启动，并在本机回环地址提供 MCP HTTP 服务（默认 `127.0.0.1:8765/mcp`）。
2. 确认 Tunnel Client 使用正确的 profile，并通过官方 CLI 的诊断/doctor 检查。
3. 启动 Tunnel Client，确认本机 `http://127.0.0.1:8787/healthz` 与 `/readyz` 按当前客户端版本返回健康/就绪状态。
4. 运行 `REA-Manager.ps1 check` 和 `diagnose`，保存脱敏后的结果。

## 二、Platform 权限与 Tunnel

1. 使用需要接入的 OpenAI Platform 组织/项目登录。
2. 确认该身份拥有该 Tunnel 所需的 Tunnel Read 与 Tunnel Use 权限（实际权限名称以控制台当前显示为准）。
3. 在组织/项目中确认目标 Tunnel 可用，并按当前 OpenAI 文档将其关联到目标 ChatGPT 工作区。
4. 不要把 Runtime API Key 写进 profile、命令行参数、聊天消息或仓库。

## 三、ChatGPT 工作区配置

1. 登录网页版 ChatGPT，并切换到目标工作区。
2. 打开工作区提供的 Apps / Connectors / 自定义 MCP 配置入口（名称可能随版本变化）。
3. 添加由组织管理员配置/授权的 MCP App，检查名称、描述和可用工具范围。
4. 如果界面要求审批或管理员发布，先完成工作区的相应流程。
5. 在新对话中实际调用一个无副作用的只读 REA 工具，确认请求到达本机 REA 并收到应用层响应。

## 四、验收标准

- 本机 REA MCP 服务可达。
- Tunnel Client 处于 READY，而不只是进程存在。
- 目标组织/项目拥有正确的 Tunnel 权限。
- Tunnel 与目标 ChatGPT 工作区关联正确。
- 目标工作区能实际调用 REA 只读工具并收到有效结果。

只看到本机端口开放或 Tunnel Client READY，不足以证明网页版 ChatGPT 已成功接入。
