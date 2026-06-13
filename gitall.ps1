# save as update-nwbasic-git.ps1

$RepoPath = "C:\Users\hoffe\GameMakerProjects\A_NEW_BASIC_3"
$CommitMessage = @"
fix: demos local loading, ESC stop, and second-run black screen

- :DEMOS on Windows desktop now loads manifest and .bas files from
  included datafiles (working_directory + demos/) instead of http_get,
  which silently failed on desktop builds
- Added demos_load_manifest_local and demos_load_file_local scripts;
  registered demo files (manifest.json + 4 .bas files) as GMS2
  included files under datafiles/demos/
- Loading any demo now calls new_program() first so the previous
  program in memory is cleared before importing
- Browser :DEMOS path uses __demos_loading flag so the async HTTP
  handler also clears existing code before importing
- ESC during a running program now fully terminates: sets
  interpreter_running=false, clears all pause/input/inkey state,
  sets justreturned=1, and room_goto's back to the editor
- Added interpreter_running guard in Step_0 so stale interpreter
  instances don't execute program lines after ESC or room restart
- interpreter Draw_0 now exits early when not running and not ended,
  preventing a black overlay from covering the editor on return
- Fixed second-run black screen: obj_editor Step_0 now guards with
  if (room != rm_editor) exit so the persistent editor never
  processes ENTER or calls run_program() from inside rm_basic_interpreter
- Removed duplicate editor_return_room = room assignment in
  run_program() that could overwrite the correct rm_editor value
  when triggered from the wrong room
- Removed redundant instance_create_layer(obj_editor) from
  obj_globals Create_0; obj_editor is placed in rm_editor and
  was creating a second persistent instance causing doubled events
"@

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