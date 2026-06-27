# NW-BASIC agent test helper — copy diagnostic, optionally build, read transcript.
# Usage:
#   .\tools\agent-test.ps1 -Diagnostic diagnostics\stress_memory_audit.bas
#   .\tools\agent-test.ps1 -Diagnostic diagnostics\stress_modernize.bas -WaitSeconds 45
param(
    [Parameter(Mandatory = $true)]
    [string]$Diagnostic,
    [string]$AutotestPath = "$env:USERPROFILE\Documents\BasicInterpreter\autotest.bas",
    [string]$TranscriptPath = "$env:USERPROFILE\Documents\BasicInterpreter\autotest_output.txt",
    [string]$ProjectYyp = "",
    [int]$WaitSeconds = 0,
    [switch]$CopyOnly
)

$ErrorActionPreference = "Stop"
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$repoRoot = Resolve-Path (Join-Path $scriptDir "..")
if (-not $ProjectYyp) {
    $ProjectYyp = Join-Path $repoRoot "A_NEW_BASIC_3.yyp"
}
$diagPath = if ([System.IO.Path]::IsPathRooted($Diagnostic)) { $Diagnostic } else { Join-Path $repoRoot $Diagnostic }

if (-not (Test-Path $diagPath)) {
    Write-Error "Diagnostic not found: $diagPath"
}

New-Item -ItemType Directory -Force -Path (Split-Path $AutotestPath) | Out-Null
Copy-Item -Force $diagPath $AutotestPath
Write-Host "Copied $diagPath -> $AutotestPath"

if ($CopyOnly) { exit 0 }

$igor = "$env:LOCALAPPDATA\GameMakerCLI\cache\runtimes-gms2\runtime-2026.0.0.23\bin\igor\windows\x64\Igor.exe"
$runner = "$env:LOCALAPPDATA\GameMakerCLI\cache\runtimes-gms2\runtime-2026.0.0.23\windows\x64\Runner.exe"

if (-not (Test-Path $igor)) {
    Write-Host "Igor not found at $igor"
    Write-Host "Launch NW-BASIC manually, then re-run with -WaitSeconds to poll the transcript."
}

if ($WaitSeconds -gt 0) {
    Write-Host "Waiting ${WaitSeconds}s for autotest transcript..."
    Start-Sleep -Seconds $WaitSeconds
}

if (-not (Test-Path $TranscriptPath)) {
    Write-Error "Transcript not found: $TranscriptPath (run NW-BASIC with autotest.bas present)"
}

$text = Get-Content $TranscriptPath -Raw
$failLines = Select-String -InputObject $text -Pattern "TEST: .* = FAIL" -AllMatches
if ($failLines.Matches.Count -gt 0) {
    Write-Host $text
    Write-Error "Found $($failLines.Matches.Count) FAIL line(s) in transcript"
}

Write-Host "Transcript OK (no TEST: ... = FAIL lines)"
exit 0