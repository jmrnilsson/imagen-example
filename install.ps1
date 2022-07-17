#!/usr/bin/env pwsh

echo "Starting!"

Remove-Item ".\.venv" -Force -Recurse
pip3 cache purge
python3 -m venv ./.venv
.\.venv\Scripts\activate.ps1
python.exe -m pip install --upgrade pip
pip3 install -r requirements_cuda.txt --extra-index-url https://download.pytorch.org/whl/cu116
pip3 install -r requirements.txt

echo "Done!"