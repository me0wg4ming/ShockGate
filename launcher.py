import os
import sys
import shutil
import subprocess

_BASE_DIR = os.path.dirname(os.path.abspath(__file__))
_APP_NAME = "ShockHubClient"

if os.name == "nt":
    _APPDATA_DIR = os.path.join(os.environ.get("APPDATA", ""), _APP_NAME)
    python = os.path.join(_BASE_DIR, "python", "pythonw.exe")
    if not os.path.exists(python):
        python = sys.executable
else:
    _APPDATA_DIR = os.path.join(os.path.expanduser("~"), f".{_APP_NAME}")
    python = sys.executable

_APPDATA_CLIENT = os.path.join(_APPDATA_DIR, "client.py")
_INSTALL_CLIENT = os.path.join(_BASE_DIR, "client.py")

# Migrate client.py from install dir to data dir if not already there
if not os.path.exists(_APPDATA_CLIENT) and os.path.exists(_INSTALL_CLIENT):
    os.makedirs(_APPDATA_DIR, exist_ok=True)
    shutil.copy2(_INSTALL_CLIENT, _APPDATA_CLIENT)

# Copy icon to appdata dir
for asset in ("shockhub_icon.ico", "shockhub_logo.bmp"):
    src = os.path.join(_BASE_DIR, asset)
    dst = os.path.join(_APPDATA_DIR, asset)
    if os.path.exists(src) and not os.path.exists(dst):
        shutil.copy2(src, dst)

# On Windows: delete client.py from install dir after migration
if os.name == "nt" and os.path.exists(_APPDATA_CLIENT) and os.path.exists(_INSTALL_CLIENT):
    try:
        os.remove(_INSTALL_CLIENT)
    except Exception:
        pass

script = _APPDATA_CLIENT if os.path.exists(_APPDATA_CLIENT) else _INSTALL_CLIENT

subprocess.Popen([python, script])
