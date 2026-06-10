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

WEB_CONFIG = """\
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <staticContent>
      <!-- GameMaker HTML5 build uses .data and .unx — IIS blocks unknown extensions by default -->
      <mimeMap fileExtension=".data" mimeType="application/octet-stream" />
      <mimeMap fileExtension=".unx"  mimeType="application/octet-stream" />
    </staticContent>
  </system.webServer>
</configuration>
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

    # Inject web.config for IIS MIME types (.data and .unx are blocked by default)
    (EXTRACT_DIR / "web.config").write_text(WEB_CONFIG, encoding="utf-8")

    files = list(EXTRACT_DIR.iterdir())
    print(f"Extracted {len(files)} files:")
    for f in sorted(files):
        size_kb = f.stat().st_size // 1024
        print(f"  {f.name:30s}  {size_kb:>6} KB")

    return EXTRACT_DIR

# ─── Upload ───────────────────────────────────────────────────────────────────

class _FTP_TLS_NoReuse(ftplib.FTP_TLS):
    """FTP_TLS subclass that disables SSL session reuse on the data channel.
    Required for GoDaddy and other servers that don't support RFC 4507 session tickets."""
    def ntransfercmd(self, cmd, rest=None):
        conn, size = ftplib.FTP.ntransfercmd(self, cmd, rest)
        if self._prot_p:
            conn = self.context.wrap_socket(conn, server_hostname=self.host,
                                            session=None)  # no session reuse
        return conn, size

def _ftp_tls_connect(host, port, user, password, ctx):
    ftp = _FTP_TLS_NoReuse(context=ctx)
    ftp.connect(host, port, timeout=30)
    ftp.login(user, password)
    ftp.prot_c()  # clear data channel — GoDaddy times out on encrypted data transfers
    return ftp

def _ftp_plain_connect(host, port, user, password):
    ftp = ftplib.FTP()
    ftp.connect(host, port, timeout=30)
    ftp.login(user, password)
    return ftp

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
    ftp = None
    import ssl
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    attempts = [
        ("explicit TLS",  lambda: _ftp_tls_connect(host, port, user, password, ctx)),
        ("plain FTP",     lambda: _ftp_plain_connect(host, port, user, password)),
        ("TLS lowercase", lambda: _ftp_tls_connect(host, port, user.lower(), password, ctx)),
        ("plain lowercase", lambda: _ftp_plain_connect(host, port, user.lower(), password)),
    ]
    for label, connect_fn in attempts:
        try:
            ftp = connect_fn()
            print(f"Connected ({label}).")
            break
        except Exception as e:
            print(f"  {label} failed: {e}")
            ftp = None

    if ftp is None:
        print("ERROR: All connection attempts failed.")
        print("Check that FTP_USER and FTP_PASSWORD in .env match your GoDaddy FTP credentials.")
        print("Note: GoDaddy FTP password may differ from your account/cPanel login password.")
        sys.exit(1)

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
