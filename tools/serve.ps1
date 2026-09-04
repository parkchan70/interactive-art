$ErrorActionPreference = 'Stop'
# 인천과학대제전 · 인공지능창작교실 — 설치 없이 도는 로컬 서버(인터넷 불필요)
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

$listener = $null
$port = 0
foreach ($p in 8123..8143) {
  try {
    $l = New-Object System.Net.HttpListener
    $l.Prefixes.Add("http://localhost:$p/")
    $l.Start()
    $listener = $l; $port = $p; break
  } catch { }
}
if (-not $listener) {
  Write-Host "사용할 수 있는 포트를 찾지 못했습니다. 이미 실행 중인 창이 있는지 확인해 주세요."
  Read-Host "엔터를 누르면 닫힙니다"; exit 1
}

$mime = @{
  '.html' = 'text/html; charset=utf-8';  '.htm' = 'text/html; charset=utf-8'
  '.js'   = 'text/javascript; charset=utf-8'; '.css' = 'text/css; charset=utf-8'
  '.json' = 'application/json'; '.md'  = 'text/markdown; charset=utf-8'
  '.png'  = 'image/png';  '.jpg' = 'image/jpeg'; '.jpeg' = 'image/jpeg'
  '.gif'  = 'image/gif';  '.svg' = 'image/svg+xml'; '.ico' = 'image/x-icon'
  '.webp' = 'image/webp'; '.mp3' = 'audio/mpeg'; '.ogg' = 'audio/ogg'
  '.woff2'= 'font/woff2'; '.woff'= 'font/woff'
}
$url = "http://localhost:$port/index.html"

Write-Host ""
Write-Host "  ============================================"
Write-Host "   인천과학대제전 · 인공지능창작교실"
Write-Host "  ============================================"
Write-Host ""
Write-Host "   주소 : $url"
Write-Host "   폴더 : $root"
Write-Host ""
Write-Host "   * 인터넷 연결은 필요하지 않습니다."
Write-Host "   * 브라우저가 카메라를 물으면 [허용]을 눌러 주세요."
Write-Host "   * 다 쓰신 뒤에는 이 검은 창을 닫으면 종료됩니다."
Write-Host ""
Start-Process $url

while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart('/')
    if ([string]::IsNullOrEmpty($rel)) { $rel = 'index.html' }
    $full = Join-Path $root ($rel -replace '/', '\')

    $serve = $false
    try {
      $resolved = (Resolve-Path -LiteralPath $full).Path
      if ($resolved.StartsWith($root) -and (Test-Path -LiteralPath $resolved -PathType Leaf)) {
        $full = $resolved; $serve = $true
      }
    } catch { }

    if ($serve) {
      $bytes = [System.IO.File]::ReadAllBytes($full)
      $ext = [System.IO.Path]::GetExtension($full).ToLower()
      $ct = 'application/octet-stream'
      if ($mime.ContainsKey($ext)) { $ct = $mime[$ext] }
      $ctx.Response.ContentType = $ct
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
    }
    $ctx.Response.Close()
  } catch { }
}
