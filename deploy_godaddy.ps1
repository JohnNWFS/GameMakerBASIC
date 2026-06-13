# deploy_godaddy.ps1
# Builds NW-BASIC as HTML5 (operagx target via gm-cli), extracts the zip,
# then uploads to GoDaddy via FTP using scripts/deploy_html5.py.
# Credentials are read from .env — never committed to git.

$RepoPath = "C:\Users\hoffe\GameMakerProjects\A_NEW_BASIC_3"
Set-Location $RepoPath

# ── Load .env ─────────────────────────────────────────────────────────────────
$EnvFile = "$RepoPath\.env"
if (-not (Test-Path $EnvFile)) {
    Write-Host "ERROR: .env not found. Copy .env.example to .env and fill in FTP_PASSWORD." -ForegroundColor Red
    exit 1
}

$env_vars = @{}
foreach ($line in Get-Content $EnvFile) {
    $line = $line.Trim()
    if ($line -eq "" -or $line.StartsWith("#") -or -not $line.Contains("=")) { continue }
    $parts = $line -split "=", 2
    $env_vars[$parts[0].Trim()] = $parts[1].Trim()
}

$FtpHost       = $env_vars["FTP_HOST"]
$FtpUser       = $env_vars["FTP_USER"]
$FtpPassword   = $env_vars["FTP_PASSWORD"]
$FtpRemotePath = $env_vars["FTP_REMOTE_PATH"]

if (-not $FtpPassword) {
    Write-Host "ERROR: FTP_PASSWORD is empty in .env. Fill it in and retry." -ForegroundColor Red
    exit 1
}

Write-Host "`n== NW-BASIC GoDaddy Deploy ==" -ForegroundColor Cyan
Write-Host "  Target : $FtpHost$FtpRemotePath"
Write-Host "  User   : $FtpUser"

# ── Build ─────────────────────────────────────────────────────────────────────
Write-Host "`n== Building HTML5 (operagx) ==" -ForegroundColor Cyan

$BuildDir    = "$RepoPath\.gmcache\html5_deploy"
$ZipPath     = "$BuildDir\NW-BASIC.zip"
$ExtractDir  = "$BuildDir\extracted"
$YypPath     = "$RepoPath\A_NEW_BASIC_3.yyp"

New-Item -ItemType Directory -Force $BuildDir | Out-Null
if (Test-Path $ZipPath)    { Remove-Item $ZipPath    -Force }
if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force }

gm-cli package $YypPath --target operagx -o $ZipPath

if ($LASTEXITCODE -ne 0 -or -not (Test-Path $ZipPath)) {
    Write-Host "`nERROR: gm-cli build failed (exit $LASTEXITCODE). Aborting." -ForegroundColor Red
    exit 1
}

Write-Host "Build succeeded: $ZipPath" -ForegroundColor Green

# ── Extract ───────────────────────────────────────────────────────────────────
Write-Host "`n== Extracting build ==" -ForegroundColor Cyan
Expand-Archive -Path $ZipPath -DestinationPath $ExtractDir -Force

$fileCount = (Get-ChildItem $ExtractDir -Recurse -File).Count
Write-Host "Extracted $fileCount file(s) to $ExtractDir"

# ── Confirm before upload ─────────────────────────────────────────────────────
$answer = Read-Host "`nUpload to GoDaddy ($FtpHost$FtpRemotePath)? Type YES to continue"
if ($answer -ne "YES") {
    Write-Host "Cancelled. Extracted files kept at: $ExtractDir" -ForegroundColor Yellow
    exit 0
}

# ── Upload ────────────────────────────────────────────────────────────────────
Write-Host "`n== Uploading to GoDaddy ==" -ForegroundColor Cyan

python "$RepoPath\scripts\deploy_html5.py" --upload-only $ExtractDir

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nERROR: Upload failed (exit $LASTEXITCODE)." -ForegroundColor Red
    exit 1
}

Write-Host "`nDone. NW-BASIC is live at https://johnnwfs.net/NW-BASIC" -ForegroundColor Green
