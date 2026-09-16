# AlbertoAI laptop bootstrap - one paste on a fresh Windows laptop:
#   powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/xmen12cc/laptop-setup/main/bootstrap.ps1 | iex"
# Installs Git + Node from their official direct downloads (no winget/Store
# needed - works on LTSC and debloated installs), clones the private repos
# (GitHub login window pops once), then hands off to TradeCopier's setup script.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = 'Continue'
Write-Host '== AlbertoAI laptop bootstrap ==' -ForegroundColor Cyan

function Find-Git {
  $cmd = Get-Command git.exe -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  foreach ($p in "$env:ProgramFiles\Git\bin\git.exe", "${env:ProgramFiles(x86)}\Git\bin\git.exe") {
    if (Test-Path $p) { return $p }
  }
  return $null
}

if (-not (Find-Git)) {
  Write-Host 'Downloading Git (about 65 MB)...' -ForegroundColor Yellow
  $rel = Invoke-RestMethod 'https://api.github.com/repos/git-for-windows/git/releases/latest'
  $asset = $rel.assets | Where-Object { $_.name -match '^Git-.*-64-bit\.exe$' } | Select-Object -First 1
  if (-not $asset) { Write-Host 'Could not find the Git installer - check your internet and paste the command again.' -ForegroundColor Red; return }
  Invoke-WebRequest $asset.browser_download_url -OutFile "$env:TEMP\git-setup.exe" -UseBasicParsing
  Write-Host 'Installing Git (silent)...' -ForegroundColor Yellow
  Start-Process "$env:TEMP\git-setup.exe" -ArgumentList '/VERYSILENT', '/NORESTART', '/NOCANCEL', '/SP-', '/o:PathOption=CmdTools' -Wait
  Remove-Item "$env:TEMP\git-setup.exe" -Force -ErrorAction SilentlyContinue
}

if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue)) {
  Write-Host 'Downloading Node.js LTS (about 30 MB)...' -ForegroundColor Yellow
  $idx = Invoke-RestMethod 'https://nodejs.org/dist/index.json'
  $lts = $idx | Where-Object { $_.lts } | Select-Object -First 1
  $msi = "https://nodejs.org/dist/$($lts.version)/node-$($lts.version)-x64.msi"
  Invoke-WebRequest $msi -OutFile "$env:TEMP\node-setup.msi" -UseBasicParsing
  Write-Host "Installing Node.js $($lts.version) (silent)..." -ForegroundColor Yellow
  Start-Process msiexec.exe -ArgumentList '/i', "$env:TEMP\node-setup.msi", '/qn', '/norestart' -Wait
  Remove-Item "$env:TEMP\node-setup.msi" -Force -ErrorAction SilentlyContinue
}

$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
$git = Find-Git
if (-not $git) {
  Write-Host 'Git did not install - close this window, reopen PowerShell, and paste the command again.' -ForegroundColor Red
  return
}
if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue)) {
  Write-Host 'Node.js did not install - close this window, reopen PowerShell, and paste the command again.' -ForegroundColor Red
  return
}

$projects = 'C:\Projects'
New-Item -ItemType Directory -Force -Path $projects | Out-Null
if (-not (Test-Path "$projects\TradeCopier\.git")) {
  Write-Host 'Cloning TradeCopier (a GitHub login window may open - sign in once)...' -ForegroundColor Yellow
  & $git clone https://github.com/xmen12cc/TradeCopier.git "$projects\TradeCopier"
  if ($LASTEXITCODE -ne 0) {
    Write-Host 'Clone failed. A browser login usually fixes it - just paste the bootstrap command again.' -ForegroundColor Red
    return
  }
}

& powershell -NoProfile -ExecutionPolicy Bypass -File "$projects\TradeCopier\scripts\laptop\setup_laptop.ps1"
Write-Host ''
Write-Host 'Bootstrap done. For the first launch, double-click C:\Projects\TradeCopier\open_server.bat' -ForegroundColor Green
