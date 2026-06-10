#!/usr/bin/env python3
"""
NW-BASIC HTML5 deploy script.

1. Compiles the HTML5 build with gm-cli
2. Locates the output files
3. Uploads them to the GoDaddy FTP server

Usage:
    python scripts/deploy_html5.py [--build-only] [--upload-only <dir>]

Reads credentials from .env in the project root (never committed to git).
Copy .env.example to .env and fill in FTP_PASSWORD before first run.
"""

import os
import sys
import ftplib
import pathlib
import subprocess
import glob
import argparse

PROJECT_ROOT = pathlib.Path(__file__).parent.parent

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
    print("Building HTML5...")
    yyp = PROJECT_ROOT / "A_NEW_BASIC_3.yyp"
    result = subprocess.run(
        ["pwsh", "-NoProfile", "-Command",
         f"gm-cli compile '{yyp}' --target html5 --errors-only"],
        cwd=str(PROJECT_ROOT),
    )
    if result.returncode != 0:
        print("ERROR: gm-cli compile failed.")
        sys.exit(1)
    print("Build complete.")

def find_html5_output():
    """Search common gm-cli output locations for HTML5 build artifacts."""
    candidates = [
        PROJECT_ROOT / "__output",
        PROJECT_ROOT / "build",
        PROJECT_ROOT / "built",
    ]
    # Look for index.html as the marker of a successful HTML5 build
    for base in candidates:
        hits = list(base.rglob("index.html")) if base.exists() else []
        if hits:
            # Return the directory containing index.html
            return hits[0].parent
    # Also check the GameMaker default temp output path
    gm_output = pathlib.Path(os.environ.get("LOCALAPPDATA", "")) / "GameMakerStudio2" / "GMS2TEMP"
    if gm_output.exists():
        hits = list(gm_output.rglob("index.html"))
        if hits:
            return hits[0].parent
    return None

# ─── Upload ───────────────────────────────────────────────────────────────────

def ftp_upload(local_dir: pathlib.Path, env: dict):
    host        = env.get("FTP_HOST", "")
    user        = env.get("FTP_USER", "")
    password    = env.get("FTP_PASSWORD", "")
    port        = int(env.get("FTP_PORT", 21))
    remote_path = env.get("FTP_REMOTE_PATH", "/public_html/basic")

    if not password:
        print("ERROR: FTP_PASSWORD is empty in .env. Fill it in and retry.")
        sys.exit(1)

    print(f"Connecting to {host}:{port} as {user} ...")
    try:
        ftp = ftplib.FTP_TLS()
        ftp.connect(host, port, timeout=30)
        ftp.auth()
        ftp.login(user, password)
        ftp.prot_p()  # secure data channel
    except Exception as e:
        print(f"ERROR: FTP connection failed: {e}")
        sys.exit(1)

    print(f"Connected. Uploading to {remote_path} ...")

    def ensure_dir(path):
        """Create remote directory if it doesn't exist."""
        try:
            ftp.mkd(path)
        except ftplib.error_perm:
            pass  # already exists

    def upload_tree(local_root: pathlib.Path, remote_root: str):
        ensure_dir(remote_root)
        for item in sorted(local_root.iterdir()):
            remote_item = remote_root.rstrip("/") + "/" + item.name
            if item.is_dir():
                upload_tree(item, remote_item)
            else:
                print(f"  {item.relative_to(local_dir)}")
                with open(item, "rb") as f:
                    ftp.storbinary(f"STOR {remote_item}", f)

    upload_tree(local_dir, remote_path)
    ftp.quit()
    print(f"\nDone. Uploaded {local_dir} -> ftp://{host}{remote_path}")

# ─── Entry point ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build and deploy NW-BASIC HTML5")
    parser.add_argument("--build-only",   action="store_true", help="Compile but do not upload")
    parser.add_argument("--upload-only",  metavar="DIR",       help="Skip build; upload DIR instead")
    args = parser.parse_args()

    env = load_env()

    if args.upload_only:
        local_dir = pathlib.Path(args.upload_only)
        if not local_dir.exists():
            print(f"ERROR: {local_dir} does not exist.")
            sys.exit(1)
    else:
        build_html5()
        local_dir = find_html5_output()
        if not local_dir:
            print("ERROR: Could not find HTML5 output (index.html not found).")
            print("Run with --verbose to see build output, or check the GameMaker output folder.")
            sys.exit(1)
        print(f"Build output: {local_dir}")

    if not args.build_only:
        ftp_upload(local_dir, env)
