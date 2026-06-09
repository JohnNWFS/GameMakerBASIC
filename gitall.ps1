# save as update-nwbasic-git.ps1

$RepoPath = "C:\Users\hoffe\GameMakerProjects\A_NEW_BASIC_3"
$CommitMessage = "Clean up broken code and update README"

Set-Location $RepoPath

Write-Host "`n== Current branch ==" -ForegroundColor Cyan
git branch --show-current

Write-Host "`n== Current status ==" -ForegroundColor Cyan
git status

Write-Host "`n== Pulling latest from remote ==" -ForegroundColor Cyan
git pull
if ($LASTEXITCODE -ne 0) {
    Write-Host "`nPull failed. Resolve conflicts before continuing." -ForegroundColor Red
    exit 1
}

Write-Host "`n== Staging all changes ==" -ForegroundColor Cyan
git add -A

Write-Host "`n== Staged files ==" -ForegroundColor Cyan
git status

Write-Host "`n== Diff summary ==" -ForegroundColor Cyan
git diff --cached --stat

$answer = Read-Host "`nCommit and push these changes? Type YES to continue"
if ($answer -ne "YES") {
    Write-Host "Cancelled. Nothing committed." -ForegroundColor Yellow
    exit 0
}

git commit -m $CommitMessage
if ($LASTEXITCODE -ne 0) {
    Write-Host "`nCommit failed. Maybe there are no staged changes?" -ForegroundColor Red
    exit 1
}

git push
if ($LASTEXITCODE -ne 0) {
    Write-Host "`nPush failed. Check remote/branch/auth." -ForegroundColor Red
    exit 1
}

Write-Host "`nDone. NW-BASIC has been pushed to GitHub." -ForegroundColor Green