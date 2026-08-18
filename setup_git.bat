@echo off
setlocal enabledelayedexpansion

:: 1. Get current folder name
for %%I in ("%cd%") do set "foldername=%%~nxI"
if "%foldername%"=="" (
    echo Failed to get folder name.
    exit /b 1
)
echo Using folder name: %foldername%

:: 2. Create README.md if missing
if not exist README.md (
    echo # %foldername% > README.md
    echo Created README.md
) else (
    echo README.md already exists, skipping.
)

:: 3. Initialize Git if needed
if not exist .git (
    git init
) else (
    echo Git repository already initialized.
)

:: 4. Add ALL files and commit
echo Adding all files...
git add .
git commit -m "first commit" 2>nul
if errorlevel 1 (
    echo No new changes to commit.
) else (
    echo Commit successful.
)

:: 5. Rename current branch to 'master' (explicitly)
git branch -M master

:: 6. Set or update remote origin (using the CORRECT URL without "-master")
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo Adding remote origin...
    git remote add origin https://github.com/pascaldemon1337/%foldername%.git
) else (
    echo Remote origin already exists. Updating URL...
    git remote set-url origin https://github.com/pascaldemon1337/%foldername%.git
)

:: 7. Push to remote 'master' and set upstream
git push -u origin master

echo Done!
pause