@echo off
:: Get the directory of the current script
set scriptDir=%~dp0

:: Execute the PowerShell script
powershell -ExecutionPolicy Bypass -File "%scriptDir%switchlayout.ps1"
