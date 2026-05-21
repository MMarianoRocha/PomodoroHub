@echo off
setlocal

pushd "%~dp0"

if not exist ".venv-client\Scripts\python.exe" (
    py -3 -m venv .venv-client
)

call ".venv-client\Scripts\activate.bat"
python -m pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r requirements-client.txt

set "POMODORO_HUB_API_URL=http://10.20.30.228:8000"

python -m desktop
