# 切换 ChatGPT 账号或工作区

## 核心原则

将部署分成两层：

- **本机常驻层**：REA MCP Server、Tunnel Client、profile、运行目录和本机端口。
- **账号授权层**：OpenAI Platform 身份/组织权限、Tunnel Read/Use 权限、Tunnel 与 ChatGPT 工作区的关联，以及 ChatGPT 工作区 MCP App 配置。

切换账号通常不意味着必须重装 REA，但也不能假设复制原有 Tunnel 标识就完成了授权。

## 新账号接入检查表

- [ ] 确认新账号属于正确的 Platform 组织/项目。
- [ ] 确认该身份有目标 Tunnel 所需的 Read 与 Use 权限。
- [ ] 确认目标 Tunnel 对新账号/工作区可见且可用。
- [ ] 按当前控制台流程将 Tunnel 关联到目标 ChatGPT 工作区。
- [ ] 在目标工作区添加/启用 MCP App。
- [ ] 确认工具列表出现预期 REA 工具。
- [ ] 执行一次无副作用的只读调用并确认返回来自 REA 应用层。

## 不要做的事

- 不要把 Runtime API Key 复制到聊天、GitHub、共享文档或截图。
- 不要为了切换账号而直接删除本机 profile 或重置 Tunnel。
- 不要将“本机健康检查通过”误判为“新账号已获授权”。
- 不要在未确认影响前终止当前仍在使用的 Tunnel Client。

## 故障定位顺序

先检查本机服务，再检查 Tunnel Client 与控制平面权限，最后检查 ChatGPT 工作区授权。这样可避免为账号侧问题反复重装本机运行时。
