#!/usr/bin/env python3
"""Upload demos/ folder to /httpdocs/NW-BASIC/demos/ via FTP."""
import ftplib, pathlib, sys, ssl

PROJECT_ROOT = pathlib.Path(__file__).parent.parent
DEMOS_DIR    = PROJECT_ROOT / "demos"

def load_env():
    env = {}
    for line in (PROJECT_ROOT / ".env").read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line: continue
        k, _, v = line.partition("=")
        env[k.strip()] = v.strip()
    return env

class _FTP_TLS_NoReuse(ftplib.FTP_TLS):
    def ntransfercmd(self, cmd, rest=None):
        conn, size = ftplib.FTP.ntransfercmd(self, cmd, rest)
        return conn, size

def connect(env):
    host = env.get("FTP_HOST", "")
    user = env.get("FTP_USER", "")
    pw   = env.get("FTP_PASSWORD", "")
    port = int(env.get("FTP_PORT", 21))

    for use_tls in (False, True):
        try:
            if use_tls:
                ctx = ssl.create_default_context()
                ctx.check_hostname = False
                ctx.verify_mode    = ssl.CERT_NONE
                ftp = _FTP_TLS_NoReuse(context=ctx)
                ftp.connect(host, port, timeout=20)
                ftp.login(user, pw)
                try: ftp.prot_c()
                except: pass
            else:
                ftp = ftplib.FTP()
                ftp.connect(host, port, timeout=20)
                ftp.login(user, pw)
            print(f"Connected ({'TLS' if use_tls else 'plain'})")
            return ftp
        except Exception as e:
            print(f"Connect attempt failed ({'TLS' if use_tls else 'plain'}): {e}")
    sys.exit("Could not connect to FTP server")

def ensure_dir(ftp, path):
    try:
        ftp.mkd(path)
        print(f"  Created {path}")
    except ftplib.error_perm:
        pass  # already exists

def main():
    env = load_env()
    remote_base = env.get("FTP_REMOTE_PATH", "/httpdocs/NW-BASIC").rstrip("/")
    remote_demos = remote_base + "/demos"

    ftp = connect(env)
    ensure_dir(ftp, remote_demos)
    ftp.cwd(remote_demos)

    files = sorted(DEMOS_DIR.glob("*.bas"))
    if not files:
        sys.exit("No .bas files found in demos/")

    for f in files:
        with open(f, "rb") as fh:
            ftp.storbinary(f"STOR {f.name}", fh)
        print(f"  Uploaded {f.name}")

    manifest = DEMOS_DIR / "manifest.json"
    if manifest.exists():
        with open(manifest, "rb") as fh:
            ftp.storbinary("STOR manifest.json", fh)
        print("  Uploaded manifest.json")

    ftp.quit()
    print(f"\nDone. URLs:")
    host_url = "https://johnnwfs.net/NW-BASIC/demos"
    for f in files:
        print(f"  {host_url}/{f.name}")
    print(f"  {host_url}/manifest.json")

if __name__ == "__main__":
    main()
