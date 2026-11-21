# 架构与组件职责

## 数据链路

1. REA MCP Server 在本机回环地址监听 HTTP MCP，默认 `127.0.0.1:8765/mcp`。
2. OpenAI Secure MCP Tunnel Client 读取本地 profile，使用运行时凭据向控制平面认证，并建立安全隧道。
3. Tunnel Client 默认在本机 `127.0.0.1:8787` 提供健康检查端点；它将已授权的远端 MCP 请求转发到配置的本地 REA MCP 服务。
4. ChatGPT 通过工作区中配置的自定义 MCP App 访问该 Tunnel。

## 端口约定

| 端口 | 组件 | 用途 |
|---|---|---|
| 8765 | REA MCP HTTP | 本地 MCP 服务 |
| 8766 | 可选 Node 代理 | 独立本地转发，不属于 OpenAI Tunnel 必经链路 |
| 8787 | Tunnel Client | 本地健康/就绪检查 |

端口只是当前部署约定；如有改动，需同步更新本机配置和管理器参数。

## 权限边界

- OpenAI Platform 组织/项目层面的 Tunnel Read 与 Tunnel Use 权限，控制 Tunnel 的读取和使用。
- ChatGPT 工作区的自定义 MCP/App 管理权限，控制工作区能否添加和使用 MCP App。
- 这两类权限不是同一项授权。拥有本机 Tunnel Client 并不代表 ChatGPT 账号已被授权。
- 新账号接入后，需确认目标组织/项目权限、Tunnel 与工作区的关联，以及该工作区的 MCP App 配置。

## 设计原则

- 本机服务层与 ChatGPT 账号/工作区授权层分离。
- 状态检查默认只读。
- 启动操作幂等：端口已有服务时先探测，不盲目启动第二个实例。
- 修复操作必须由操作者明确确认，不自动杀进程、不删除配置、不重置 Tunnel。
- 不将密钥放在命令行参数、仓库文件或日志中。
