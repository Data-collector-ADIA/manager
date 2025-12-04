@echo off
REM Custom git command: git mounir "commit message"
REM This command runs: git add . && git commit -m "message" && git push

if "%~1"=="" (
    echo Error: Commit message is required
    echo Usage: git mounir "your commit message"
    exit /b 1
)

set MESSAGE=%~1

echo Adding all changes...
git add .
if errorlevel 1 (
    echo Error: git add failed
    exit /b 1
)

echo Committing with message: %MESSAGE%
git commit -m "%MESSAGE%"
if errorlevel 1 (
    echo Error: git commit failed
    exit /b 1
)

echo Pushing to remote...
git push
if errorlevel 1 (
    echo Error: git push failed
    exit /b 1
)

echo.
echo Success! All changes have been added, committed, and pushed.
