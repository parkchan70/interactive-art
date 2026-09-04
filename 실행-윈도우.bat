@echo off
title Incheon Science Festival - AI Art
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\serve.ps1"
if errorlevel 1 (
  echo.
  echo Failed to start. Just double-click index.html instead - it works in Chrome/Edge.
  pause
)
