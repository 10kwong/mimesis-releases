# 映題 Mimesis · first install (Windows PowerShell)
#
#   $env:MIMESIS_BASE="https://…"; $env:MIMESIS_EXPECTED_SHA="<bootstrap sha256>"
#   irm "$env:MIMESIS_BASE/install.ps1" -OutFile "$env:TEMP\mimesis-install.ps1"
#   (check the installer's SHA-256 against the published value)
#   powershell -NoProfile -ExecutionPolicy Bypass -File "$env:TEMP\mimesis-install.ps1"
#
# Use -ExecutionPolicy Bypass: a fresh Windows 10/11 client defaults to Restricted, so calling the
# downloaded file with "&" fails. The hash pins the bootstrap (Node + installer); the installer then
# verifies the ed25519 signature of the app archive before extracting it. Company policy may block
# scripts or unsigned programs; see docs/local-desktop.md for what to do when that happens.

$ErrorActionPreference = "Stop"

if (-not $env:MIMESIS_BASE) { throw "請設定 MIMESIS_BASE（下載位置）。" }
if (-not $env:MIMESIS_EXPECTED_SHA) { throw "請設定 MIMESIS_EXPECTED_SHA（安裝檔的 SHA-256）。" }

$base = $env:MIMESIS_BASE.TrimEnd("/")
$tmp = Join-Path $env:TEMP ("mimesis-install-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tmp | Out-Null

try {
  $url = "$base/bootstrap.tar.gz"
  Write-Host "[映題安裝] 下載 $url"
  Invoke-WebRequest -Uri $url -OutFile (Join-Path $tmp "bootstrap.tar.gz") -UseBasicParsing

  $got = (Get-FileHash (Join-Path $tmp "bootstrap.tar.gz") -Algorithm SHA256).Hash.ToLowerInvariant()
  $expected = $env:MIMESIS_EXPECTED_SHA.Trim().ToLowerInvariant()
  if ($got -ne $expected) {
    throw "安裝檔檢查碼不符，已停止。預期 $expected，實際 $got。"
  }

  tar -xzf (Join-Path $tmp "bootstrap.tar.gz") -C $tmp
  $node = Join-Path $tmp "runtime\node.exe"
  $installer = Join-Path $tmp "install.mjs"
  if (-not (Test-Path $node) -or -not (Test-Path $installer)) { throw "安裝檔不完整。" }

  & $node $installer --base $base
  if ($LASTEXITCODE -ne 0) { throw "安裝程式失敗（代碼 $LASTEXITCODE）。" }
} finally {
  Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
