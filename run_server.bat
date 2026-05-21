@echo off
setlocal

pushd "%~dp0"

if not exist ".venv-server\Scripts\python.exe" (
    py -3 -m venv .venv-server
)

call ".venv-server\Scripts\activate.bat"
python -m pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r requirements-server.txt

set "POMODORO_HUB_HOST=0.0.0.0"
set "POMODORO_HUB_PORT=8000"

echo.
echo PomodoroHub Server
echo ------------------
echo Server listening on port %POMODORO_HUB_PORT%.
echo Use this computer's LAN IP in the desktop app, for example:
echo http://10.20.30.228:%POMODORO_HUB_PORT%
echo.
echo If other PCs cannot connect, allow this app/port in Windows Firewall.
echo.

python main.py
pause
