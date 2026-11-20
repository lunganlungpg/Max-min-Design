import urllib.request
import zipfile
import os
import subprocess

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
GIT_DIR = os.path.join(BASE_DIR, "tools", "git")
ZIP_PATH = os.path.join(BASE_DIR, "mingit.zip")
URL = "https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.1/MinGit-2.47.1-64-bit.zip"

os.makedirs(os.path.join(BASE_DIR, "tools"), exist_ok=True)

if not os.path.exists(os.path.join(GIT_DIR, "cmd", "git.exe")):
    print(f"Downloading MinGit from {URL} ...", flush=True)
    req = urllib.request.Request(URL, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp, open(ZIP_PATH, 'wb') as out_f:
        total = int(resp.info().get('Content-Length', -1))
        downloaded = 0
        while True:
            chunk = resp.read(1024 * 1024)
            if not chunk:
                break
            out_f.write(chunk)
            downloaded += len(chunk)
            if downloaded % (5 * 1024 * 1024) < 1024 * 1024:
                print(f"Downloaded {downloaded / 1024 / 1024:.1f} MB / {total / 1024 / 1024:.1f} MB", flush=True)
    print("Download complete. Extracting ...", flush=True)
    with zipfile.ZipFile(ZIP_PATH, 'r') as z:
        z.extractall(GIT_DIR)
    if os.path.exists(ZIP_PATH):
        os.remove(ZIP_PATH)
    print("MinGit extracted successfully!", flush=True)
else:
    print("MinGit already exists.")

git_exe = os.path.join(GIT_DIR, "cmd", "git.exe")
res = subprocess.run([git_exe, "--version"], capture_output=True, text=True)
print("Git version:", res.stdout.strip())
