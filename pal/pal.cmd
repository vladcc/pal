@echo off
REM 1. place palb.exe somewhere in your PATH 
REM 2. place this script in the same directory
REM 3. run pal

palb %*
echo Press enter twice to exit.
palb 1>nul 2>&1