#!/usr/bin/env python3
"""
NW-BASIC HTML5 deploy script.

1. Packages the HTML5/WebAssembly build with gm-cli (operagx target)
2. Extracts the zip
3. Injects a .htaccess for WebAssembly MIME type (required by Apache/GoDaddy)
4. Uploads to the GoDaddy FTP server, replacing existing files

Usage:
    python scripts/deploy_html5.py              # full build + upload
    python scripts/deploy_html5.py --build-only # package only, no upload
    python scripts/deploy_html5.py --upload-only <dir>  # skip build, upload dir

Reads credentials from .env in the project root (never committed to git).
Copy .env.example to .env and fill in FTP_PASSWORD before first run.
"""

import os
import sys
import ftplib
import pathlib
import subprocess
import zipfile
import shutil
import argparse

PROJECT_ROOT = pathlib.Path(__file__).parent.parent
BUILD_DIR    = PROJECT_ROOT / ".gmcache" / "html5_deploy"
ZIP_PATH     = BUILD_DIR / "NW-BASIC.zip"
EXTRACT_DIR  = BUILD_DIR / "extracted"

HTACCESS = """\
# Required for WebAssembly (wasm) files — Apache won't serve them correctly otherwise
AddType application/wasm .wasm
"""

# ─── Load .env ────────────────────────────────────────────────────────────────

def load_env():
    env_path = PROJECT_ROOT / ".env"
    if not env_path.exists():
        print("ERROR: .env not found. Copy .env.example to .env and fill in FTP_PASSWORD.")
        sys.exit(1)
    env = {}
    for line in env_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, val = line.partition("=")
        env[key.strip()] = val.strip()
    return env

# ─── Build ────────────────────────────────────────────────────────────────────

def build_html5():
    BUILD_DIR.mkdir(parents=True, exist_ok=True)
    if ZIP_PATH.exists():
        ZIP_PATH.unlink()

    yyp = PROJECT_ROOT / "A_NEW_BASIC_3.yyp"
    print("Packaging HTML5 build (operagx target)...")
    result = subprocess.run(
        ["pwsh", "-NoProfile", "-Command",
         f"gm-cli package '{yyp}' --target operagx -o '{ZIP_PATH}'"],
        cwd=str(PROJECT_ROOT),
    )
    if result.returncode != 0 or not ZIP_PATH.exists():
        print("ERROR: gm-cli package failed.")
        sys.exit(1)
    print(f"Package created: {ZIP_PATH}")

def extract_build():
    if EXTRACT_DIR.exists():
        shutil.rmtree(EXTRACT_DIR)
    EXTRACT_DIR.mkdir(parents=True)

    print("Extracting...")
    with zipfile.ZipFile(ZIP_PATH) as zf:
        zf.extractall(EXTRACT_DIR)

    # Inject .htaccess for WebAssembly MIME type (Apache/GoDaddy requirement)
    (EXTRACT_DIR / ".htaccess").write_text(HTACCESS, encoding="utf-8")

    files = list(EXTRACT_DIR.iterdir())
    print(f"Extracted {len(files)} files:")
    for f in sorted(files):
        size_kb = f.stat().st_size // 1024
        print(f"  {f.name:30s}  {size_kb:>6} KB")

    return EXTRACT_DIR

# ─── Upload ───────────────────────────────────────────────────────────────────

def ftp_upload(local_dir: pathlib.Path, env: dict):
    host        = env.get("FTP_HOST", "")
    user        = env.get("FTP_USER", "")
    password    = env.get("FTP_PASSWORD", "")
    port        = int(env.get("FTP_PORT", 21))
    remote_path = env.get("FTP_REMOTE_PATH", "/httpdocs/NW-BASIC")

    if not password:
        print("ERROR: FTP_PASSWORD is empty in .env. Fill it in and retry.")
        sys.exit(1)

    print(f"\nConnecting to {host}:{port} as {user} ...")
    try:
        ftp = ftplib.FTP_TLS()
        ftp.connect(host, port, timeout=30)
        ftp.auth()
        ftp.login(user, password)
        ftp.prot_p()  # encrypted data channel
    except Exception as e:
        print(f"ERROR: FTP connection failed: {e}")
        sys.exit(1)
    print("Connected.")

    def ensure_dir(path):
        try:
            ftp.mkd(path)
        except ftplib.error_perm:
            pass

    def delete_tree(remote_root: str):
        """Delete all files and subdirs under remote_root (leaves the dir itself)."""
        try:
            items = list(ftp.mlsd(remote_root))
        except Exception:
            return
        for name, facts in items:
            if name in (".", ".."):
                continue
            full = remote_root.rstrip("/") + "/" + name
            if facts.get("type") == "dir":
                delete_tree(full)
                try:
                    ftp.rmd(full)
                except Exception:
                    pass
            else:
                try:
                    ftp.delete(full)
                except Exception:
                    pass

    def upload_tree(local_root: pathlib.Path, remote_root: str):
        ensure_dir(remote_root)
        for item in sorted(local_root.iterdir()):
            remote_item = remote_root.rstrip("/") + "/" + item.name
            if item.is_dir():
                upload_tree(item, remote_item)
            else:
                size_kb = item.stat().st_size // 1024
                print(f"  uploading  {item.name:30s}  {size_kb:>6} KB")
                with open(item, "rb") as f:
                    ftp.storbinary(f"STOR {remote_item}", f)

    # Wipe old files first so stale build artifacts don't linger
    print(f"Clearing {remote_path} ...")
    delete_tree(remote_path)

    print(f"Uploading to {remote_path} ...")
    upload_tree(local_dir, remote_path)
    ftp.quit()
    print(f"\nDeploy complete -> {remote_path}")

# ─── Entry point ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build and deploy NW-BASIC HTML5")
    parser.add_argument("--build-only",  action="store_true",
                        help="Package and extract but do not upload")
    parser.add_argument("--upload-only", metavar="DIR",
                        help="Skip build; upload this directory instead")
    args = parser.parse_args()

    env = load_env()

    if args.upload_only:
        local_dir = pathlib.Path(args.upload_only)
        if not local_dir.exists():
            print(f"ERROR: {local_dir} does not exist.")
            sys.exit(1)
    else:
        build_html5()
        local_dir = extract_build()

    if args.build_only:
        print(f"\nBuild-only mode — files ready in: {local_dir}")
    else:
        ftp_upload(local_dir, env)
