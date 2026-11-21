[CmdletBinding()]
param(
    [ValidateSet('menu','check','start','diagnose','repair','logs','help')]
    [string]$Action = 'menu',
    [string]$RuntimeRoot = (Join-Path $env:USERPROFILE '.dsh\rea-runtime'),
    [string]$DshRoot = (Join-Path $env:USERPROFILE '.dsh')
)
$ErrorActionPreference = 'Stop'
$ReaPort = 8765
$ProxyPort = 8766
$TunnelPort = 8787
$ReaUrl = "http://127.0.0.1:$ReaPort/mcp"
$TunnelBaseUrl = "http://127.0.0.1:$TunnelPort"
$ReaStartScript = Join-Path $DshRoot 'profiles\desktop\scripts\start-rea-server.ps1'
$TunnelStartScript = Join-Path $RuntimeRoot 'tunnel-client\run-rea-tunnel.ps1'
$TunnelLog = Join-Path $RuntimeRoot 'tunnel-client\tunnel-client.log'

function Get-Listener([int]$Port) {
    try {
        return @(Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop | Select-Object -First 5)
    } catch { return @() }
}
function Test-HttpEndpoint([string]$Url) {
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 3 -Method Get
        return [pscustomobject]@{ Reachable=$true; StatusCode=[int]$response.StatusCode; Detail='HTTP response received' }
    } catch {
        $status = $null
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
            try { $status = [int]$_.Exception.Response.StatusCode } catch { }
        }
        if ($null -ne $status) {
            return [pscustomobject]@{ Reachable=($status -lt 500); StatusCode=$status; Detail='HTTP error response received' }
        }
        return [pscustomobject]@{ Reachable=$false; StatusCode=$null; Detail=$_.Exception.Message }
    }
}
function Test-TunnelReady {
    $health = Test-HttpEndpoint "$TunnelBaseUrl/healthz"
    $ready = Test-HttpEndpoint "$TunnelBaseUrl/readyz"
    return [pscustomobject]@{
        Health=$health; Ready=$ready
        IsReady=($health.Reachable -and $health.StatusCode -ge 200 -and $health.StatusCode -lt 300 -and $ready.Reachable -and $ready.StatusCode -ge 200 -and $ready.StatusCode -lt 300)
    }
}
function Show-Port([int]$Port, [string]$Name) {
    $listeners = Get-Listener $Port
    if ($listeners.Count -eq 0) {
        Write-Host ("[未监听] {0} / TCP {1}" -f $Name,$Port) -ForegroundColor Yellow
        return
    }
    foreach ($listener in $listeners) {
        $processName = '未知'
        try { $processName = (Get-Process -Id $listener.OwningProcess -ErrorAction Stop).ProcessName } catch { }
        Write-Host ("[监听中] {0} / TCP {1} / PID {2} / {3}" -f $Name,$Port,$listener.OwningProcess,$processName) -ForegroundColor Green
    }
}
function Invoke-Check {
    Write-Host ''; Write-Host '=== REA MCP ===' -ForegroundColor Cyan
    Show-Port $ReaPort 'REA MCP'
    $rea = Test-HttpEndpoint $ReaUrl
    if ($rea.Reachable) { Write-Host ("REA HTTP 可达：状态码 {0}" -f $rea.StatusCode) -ForegroundColor Green }
    else { Write-Host ("REA HTTP 不可达：{0}" -f $rea.Detail) -ForegroundColor Yellow }

    Write-Host ''; Write-Host '=== 可选本地代理 ===' -ForegroundColor Cyan
    Show-Port $ProxyPort 'Optional proxy'

    Write-Host ''; Write-Host '=== OpenAI Secure MCP Tunnel ===' -ForegroundColor Cyan
    Show-Port $TunnelPort 'Tunnel Client'
    $tunnel = Test-TunnelReady
    if ($tunnel.IsReady) { Write-Host 'Tunnel healthz / readyz 已通过。' -ForegroundColor Green }
    else { Write-Host ("Tunnel 尚未确认 READY。healthz={0}; readyz={1}" -f $tunnel.Health.Detail,$tunnel.Ready.Detail) -ForegroundColor Yellow }
    Write-Host ''; Write-Host '本机检查不能证明 ChatGPT 账号/工作区已获授权；仍需执行只读 MCP 调用。' -ForegroundColor DarkYellow
}
function Invoke-Diagnose {
    Invoke-Check
    Write-Host ''; Write-Host '=== 运行目录与启动脚本 ===' -ForegroundColor Cyan
    Write-Host "RuntimeRoot: $RuntimeRoot"
    Write-Host "REA start:   $ReaStartScript"
    Write-Host "Tunnel start:$TunnelStartScript"
    Write-Host "Tunnel log:  $TunnelLog"
    foreach ($path in @($RuntimeRoot,$ReaStartScript,$TunnelStartScript)) {
        if (Test-Path $path) { Write-Host "[存在] $path" -ForegroundColor Green }
        else { Write-Host "[缺失] $path" -ForegroundColor Yellow }
    }
    Write-Host ''; Write-Host '=== 关键运行时目录（仅检查存在性） ===' -ForegroundColor Cyan
    $runtimePaths = @(
        (Join-Path $RuntimeRoot 'node'),
        (Join-Path $RuntimeRoot 'npm-global\rea.cmd'),
        (Join-Path $RuntimeRoot 'ghidra'),
        (Join-Path $RuntimeRoot 'jdk25'),
        (Join-Path $RuntimeRoot 'tunnel-client\bin\tunnel-client.exe')
    )
    foreach ($path in $runtimePaths) {
        if (Test-Path $path) { Write-Host "[存在] $path" -ForegroundColor Green }
        else { Write-Host "[缺失] $path" -ForegroundColor Yellow }
    }
    if (Test-Path $TunnelLog) { Write-Host 'Tunnel 日志文件存在；使用 logs 查看末尾内容。' }
    else { Write-Host '尚未找到 Tunnel 日志文件。' }
}
function Wait-ForEndpoint([string]$Url,[int]$Seconds=20) {
    for ($i=0; $i -lt $Seconds; $i++) {
        if ((Test-HttpEndpoint $Url).Reachable) { return $true }
        Start-Sleep -Seconds 1
    }
    return $false
}
function Invoke-Start {
    Write-Host ''; Write-Host '=== 启动 REA MCP ===' -ForegroundColor Cyan
    $rea = Test-HttpEndpoint $ReaUrl
    if ($rea.Reachable) { Write-Host 'REA MCP 已有 HTTP 响应，跳过重复启动。' -ForegroundColor Green }
    elseif ((Get-Listener $ReaPort).Count -gt 0) {
        throw "TCP $ReaPort 已被占用，但 REA MCP endpoint 无法确认可用。请先定位占用进程；管理器不会结束该进程。"
    } else {
        if (-not (Test-Path $ReaStartScript)) { throw "找不到 REA 启动脚本：$ReaStartScript" }
        Write-Host '调用现有 REA 启动脚本（不改写其配置）...'
        & $ReaStartScript
        if (-not (Wait-ForEndpoint $ReaUrl 25)) { throw 'REA MCP 在等待时间内未响应，请检查 REA 启动错误。' }
        Write-Host 'REA MCP 已响应。' -ForegroundColor Green
    }

    Write-Host ''; Write-Host '=== 启动 Tunnel Client ===' -ForegroundColor Cyan
    $tunnel = Test-TunnelReady
    if ($tunnel.IsReady) { Write-Host 'Tunnel Client 已 READY，跳过重复启动。' -ForegroundColor Green; return }
    if ((Get-Listener $TunnelPort).Count -gt 0) {
        throw "TCP $TunnelPort 已被占用，但 Tunnel 未通过 READY 检查。为避免重复实例或误杀进程，已停止自动启动。请运行 diagnose 并检查日志。"
    }
    if (-not (Test-Path $TunnelStartScript)) { throw "找不到 Tunnel 启动脚本：$TunnelStartScript" }
    Write-Host '调用现有 Tunnel 启动脚本；它将安全提示输入 Runtime API Key。' -ForegroundColor Cyan
    & $TunnelStartScript
    $tunnel = Test-TunnelReady
    if (-not $tunnel.IsReady) { throw 'Tunnel 启动脚本已返回，但本机尚未通过 READY 检查。请查看 Tunnel 日志。' }
    Write-Host 'Tunnel Client 已 READY。' -ForegroundColor Green
}
function Invoke-Repair {
    Write-Host ''; Write-Host '=== 修复前确认 ===' -ForegroundColor Cyan
    Write-Host '只调用现有启动脚本补齐未运行的服务；不会杀进程、删除文件、重置 Tunnel、覆盖 profile 或轮换密钥。'
    if ((Read-Host '确认继续？请输入 YES') -cne 'YES') { Write-Host '已取消，没有执行更改。'; return }
    Invoke-Start
}
function Invoke-Logs {
    if (-not (Test-Path $TunnelLog)) { Write-Host "日志不存在：$TunnelLog" -ForegroundColor Yellow; return }
    Write-Host '显示 Tunnel 日志最后 80 行。分享前请确认没有敏感信息。' -ForegroundColor DarkYellow
    Get-Content -LiteralPath $TunnelLog -Tail 80
}
function Show-Help {
@'
REA-Manager.ps1
  （无参数）  打开交互菜单
  check       只读检查端口与 HTTP endpoint
  start       安全启动缺失的 REA / Tunnel 服务
  diagnose    只读诊断运行目录和服务状态
  repair      二次确认后补齐未运行的服务
  logs        查看 Tunnel 日志末尾
  help        显示帮助
可选参数：
  -RuntimeRoot <path>   默认 %USERPROFILE%\.dsh\rea-runtime
  -DshRoot <path>       默认 %USERPROFILE%\.dsh
'@ | Write-Host
}
function Show-Menu {
    while ($true) {
        Write-Host ''
        Write-Host '========== REA Manager ==========' -ForegroundColor Cyan
        Write-Host '1. 检查连接状态（只读）'
        Write-Host '2. 启动 REA 和 Tunnel'
        Write-Host '3. 诊断连接故障（只读）'
        Write-Host '4. 修复本机连接（需确认）'
        Write-Host '5. 查看 Tunnel 日志'
        Write-Host '0. 退出'
        $choice = Read-Host '请选择'
        try {
            switch ($choice) {
                '1' { Invoke-Check }
                '2' { Invoke-Start }
                '3' { Invoke-Diagnose }
                '4' { Invoke-Repair }
                '5' { Invoke-Logs }
                '0' { return }
                default { Write-Host '无效选项。' -ForegroundColor Yellow }
            }
        } catch { Write-Host ("操作失败：{0}" -f $_.Exception.Message) -ForegroundColor Red }
        if ($choice -ne '0') { [void](Read-Host '按 Enter 返回菜单') }
    }
}
try {
    switch ($Action) {
        'menu'     { Show-Menu }
        'check'    { Invoke-Check }
        'start'    { Invoke-Start }
        'diagnose' { Invoke-Diagnose }
        'repair'   { Invoke-Repair }
        'logs'     { Invoke-Logs }
        'help'     { Show-Help }
    }
} catch {
    Write-Error $_
    exit 1
}
