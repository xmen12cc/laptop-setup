# AlbertoAI laptop bootstrap - one paste on a fresh Windows laptop:
#   powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/xmen12cc/laptop-setup/main/bootstrap.ps1 | iex"
# Installs Git + Node, clones the private repos (GitHub login window pops once),
# then hands off to TradeCopier\scripts\laptop\setup_laptop.ps1 for everything else.
$ErrorActionPreference = 'Continue'
Write-Host '== AlbertoAI laptop bootstrap ==' -ForegroundColor Cyan

if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) {
  Write-Host 'Installing Git...' -ForegroundColor Yellow
  winget install --id Git.Git -e --source winget --silent --accept-package-agreements --accept-source-agreements | Out-Null
}
if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue)) {
  Write-Host 'Installing Node.js LTS...' -ForegroundColor Yellow
  winget install --id OpenJS.NodeJS.LTS -e --source winget --silent --accept-package-agreements --accept-source-agreements | Out-Null
}
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) {
  Write-Host 'Git is not available yet - close this window, reopen PowerShell, and paste the command again.' -ForegroundColor Red
  return
}

$projects = 'C:\Projects'
New-Item -ItemType Directory -Force -Path $projects | Out-Null
if (-not (Test-Path "$projects\TradeCopier\.git")) {
  Write-Host 'Cloning TradeCopier (a GitHub login window may open - sign in once)...' -ForegroundColor Yellow
  git clone https://github.com/xmen12cc/TradeCopier.git "$projects\TradeCopier"
  if ($LASTEXITCODE -ne 0) {
    Write-Host 'Clone failed. A browser login usually fixes it - just paste the bootstrap command again.' -ForegroundColor Red
    return
  }
}

& powershell -NoProfile -ExecutionPolicy Bypass -File "$projects\TradeCopier\scripts\laptop\setup_laptop.ps1"
Write-Host ''
Write-Host 'Bootstrap done. For the first launch, double-click C:\Projects\TradeCopier\open_server.bat' -ForegroundColor Green
