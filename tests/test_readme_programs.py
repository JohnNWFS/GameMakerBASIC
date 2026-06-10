#!/usr/bin/env python3
"""
README program tester for NW-BASIC.

Extracts every ```basic code block from README.md, categorizes it,
strips PAUSE, and runs each one through the autotest loop:
  1. Write to autotest.bas
  2. gm-cli run A_NEW_BASIC_3.yyp
  3. Poll autotest_output.txt for "Program has ended"
  4. Kill the process
  5. Check output for errors

Usage:
  python tests/test_readme_programs.py [--category text|graphics|audio|file_io|all]
"""

import re
import sys
import os
import time
import subprocess
import signal

# ─── Paths ───────────────────────────────────────────────────────────────────
PROJECT_ROOT  = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AUTOTEST_IN   = r"C:\Users\hoffe\Documents\BasicInterpreter\autotest.bas"
AUTOTEST_OUT  = r"C:\Users\hoffe\Documents\BasicInterpreter\autotest_output.txt"
README_PATH   = os.path.join(PROJECT_ROOT, "README.md")
YYP_PATH      = os.path.join(PROJECT_ROOT, "A_NEW_BASIC_3.yyp")

POLL_INTERVAL = 2        # seconds between output-file polls
TIMEOUT_SEC   = 120      # max seconds to wait per program
AUDIO_TEMPO   = 600      # BPM injected into audio programs to keep tests fast

# ─── Classification helpers ───────────────────────────────────────────────────
# Patterns that force a category regardless of other rules
SKIP_INPUT_PAT  = re.compile(r'(?:^\s*\d+\s+INPUT\s+(?!#))|(?:INKEY\$)', re.MULTILINE | re.IGNORECASE)
MODE2_PAT       = re.compile(r'^\s*\d+\s+(MODE\s+2|PRINTAT|DRAWSTR|CHARAT|TILE\s+\d|TILEDEF|TILEPX|TILECLEAR|TILERESTORE|TILESAVE|TILELOAD|CLSCHAR|LOCATE\s+\d|SCROLL\s+|HLINE\b|VLINE\b|FILL\s+\d|BOX\s+\d.*(?:YELLOW|WHITE|BLACK|RED|BLUE|GREEN|CYAN|MAGENTA|GRAY|ORANGE))', re.MULTILINE | re.IGNORECASE)
MODE3_PAT       = re.compile(r'^\s*\d+\s+(MODE\s+3|PSET\s+\d.*(?:\d|RED|BLUE)|CIRCLE\b|LINE\s+\d|BOX\s+\d.*(?:WHITE|RED|GREEN)|POINT\()', re.MULTILINE | re.IGNORECASE)
AUDIO_PAT       = re.compile(r'^\s*\d+\s+(BEEP|PLAY\s+")', re.MULTILINE | re.IGNORECASE)
NAMED_DATA_PAT  = re.compile(r'DATA\s+@', re.IGNORECASE)
FILE_IO_PAT     = re.compile(r'^\s*\d+\s+OPEN\b', re.MULTILINE | re.IGNORECASE)

def classify(code):
    """Return category string for a code block."""
    if SKIP_INPUT_PAT.search(code):
        return "skip_input"
    if NAMED_DATA_PAT.search(code):
        return "known_broken"
    if MODE2_PAT.search(code) or MODE3_PAT.search(code):
        return "graphics"
    if AUDIO_PAT.search(code):
        return "audio"
    if FILE_IO_PAT.search(code):
        return "file_io"
    return "text"

# ─── Code transformations ─────────────────────────────────────────────────────

def strip_pause(code):
    """Remove PAUSE statements (standalone and inline)."""
    lines = code.splitlines()
    out = []
    for line in lines:
        # Remove inline PAUSE: keep the line but strip the PAUSE part
        # Simple approach: if the whole non-numbered content is PAUSE, drop the line
        m = re.match(r'^(\s*\d+\s+)(.*)', line)
        if m:
            content = m.group(2).strip()
            # Replace PAUSE with REM PAUSE (keeps line numbers intact)
            content = re.sub(r'\bPAUSE\b', "REM 'was PAUSE'", content, flags=re.IGNORECASE)
            out.append(m.group(1) + content)
        else:
            out.append(line)
    return '\n'.join(out)

def inject_fast_tempo(code):
    """Prepend a TEMPO 600 line so audio tests run quickly."""
    lines = code.splitlines()
    # Find the lowest line number
    nums = [int(re.match(r'^\s*(\d+)', l).group(1)) for l in lines if re.match(r'^\s*\d+', l)]
    if not nums:
        return code
    first = min(nums)
    if first > 1:
        return f"1 TEMPO {AUDIO_TEMPO}\n" + code
    else:
        # Insert before first line
        return f"1 TEMPO {AUDIO_TEMPO}\n" + '\n'.join(
            re.sub(r'^\s*1\b', '2', l) if re.match(r'^\s*1\b', l) else l
            for l in lines
        )

def prepare_program(code, category):
    """Apply transformations appropriate for the category."""
    code = strip_pause(code)
    if category == "audio":
        code = inject_fast_tempo(code)
    return code

# ─── README parser ────────────────────────────────────────────────────────────

def extract_blocks(readme_path):
    """
    Extract all ```basic ... ``` blocks from README.md.
    Returns a list of dicts: {index, section, title, code, category}.
    """
    with open(readme_path, encoding='utf-8') as f:
        content = f.read()

    # Track current section heading
    section = "Preamble"
    blocks = []
    pos = 0
    heading_re = re.compile(r'^#{1,3} (.+)$', re.MULTILINE)
    block_re   = re.compile(r'```basic\r?\n(.*?)```', re.DOTALL)

    # Build an ordered list of headings and code blocks by position
    events = []
    for m in heading_re.finditer(content):
        events.append(('heading', m.start(), m.group(1).strip()))
    for m in block_re.finditer(content):
        events.append(('block', m.start(), m.group(1).rstrip()))
    events.sort(key=lambda e: e[1])

    current_section = "Preamble"
    idx = 0
    for kind, pos, val in events:
        if kind == 'heading':
            current_section = val
        else:
            code = val
            cat  = classify(code)
            blocks.append({
                'index':    idx,
                'section':  current_section,
                'code':     code,
                'category': cat,
            })
            idx += 1
    return blocks

# ─── Autotest runner ──────────────────────────────────────────────────────────

def write_autotest(code):
    os.makedirs(os.path.dirname(AUTOTEST_IN), exist_ok=True)
    with open(AUTOTEST_IN, 'w', encoding='utf-8') as f:
        f.write(code + '\n')

def clear_output():
    """Wipe the output file so old content doesn't fool us."""
    try:
        with open(AUTOTEST_OUT, 'w', encoding='utf-8') as f:
            f.write("")
    except Exception:
        pass

def read_output():
    try:
        with open(AUTOTEST_OUT, encoding='utf-8', errors='replace') as f:
            return f.read()
    except Exception:
        return ""

DONE_SENTINEL = "Program has ended"
ERROR_PATTERN = re.compile(r'(SYNTAX ERROR|RUNTIME ERROR|UNKNOWN COMMAND|UNKNOWN ERROR|Stack overflow|GameMaker Fatal)', re.IGNORECASE)

def run_program(code, timeout=TIMEOUT_SEC):
    """
    Write code to autotest.bas, launch gm-cli, wait for completion.
    Returns (passed: bool, output: str, error_lines: list[str], elapsed: float).
    """
    clear_output()
    write_autotest(code)
    time.sleep(0.3)  # small settle

    t0 = time.time()
    proc = subprocess.Popen(
        ["pwsh", "-NoProfile", "-Command", f"gm-cli run '{YYP_PATH}' --errors-only"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd=PROJECT_ROOT,
    )

    output = ""
    done   = False
    timed_out = False

    try:
        while True:
            elapsed = time.time() - t0
            if elapsed > timeout:
                timed_out = True
                break
            time.sleep(POLL_INTERVAL)
            output = read_output()
            if DONE_SENTINEL in output:
                done = True
                break
    finally:
        # Kill the entire process tree (gm-cli spawns the GameMaker runner as a child)
        try:
            subprocess.call(
                ["taskkill", "/T", "/F", "/PID", str(proc.pid)],
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
            )
            proc.wait(timeout=5)
        except Exception:
            try:
                proc.kill()
            except Exception:
                pass
        # Clean up so next run doesn't auto-start
        try:
            os.remove(AUTOTEST_IN)
        except Exception:
            pass
        # Give the OS a moment to release file handles before next run
        time.sleep(2)

    elapsed = time.time() - t0

    if timed_out:
        return False, output, [f"TIMEOUT after {int(elapsed)}s"], elapsed

    error_lines = [l.strip() for l in output.splitlines()
                   if ERROR_PATTERN.search(l)]

    passed = done and len(error_lines) == 0
    return passed, output, error_lines, elapsed

# ─── Main ─────────────────────────────────────────────────────────────────────

CATEGORY_LABELS = {
    'text':         'text        ',
    'graphics':     'graphics    ',
    'audio':        'audio       ',
    'file_io':      'file_io     ',
    'skip_input':   'skip(input) ',
    'known_broken': 'known_broken',
}

def run_suite(blocks, run_categories):
    results = []
    to_run  = [b for b in blocks if b['category'] in run_categories]
    skip    = [b for b in blocks if b['category'] not in run_categories]

    total = len(to_run)
    print(f"\nRunning {total} programs  (skipping {len(skip)} — {set(b['category'] for b in skip)})\n")
    print("=" * 72)

    for i, block in enumerate(to_run):
        cat  = block['category']
        idx  = block['index']
        sec  = block['section']
        code = prepare_program(block['code'], cat)
        first_line = block['code'].splitlines()[0][:60]

        print(f"[{i+1:02d}/{total}] #{idx:02d} {CATEGORY_LABELS[cat]}  {sec}")
        print(f"       {first_line}")
        sys.stdout.flush()

        passed, output, errors, elapsed = run_program(code)

        status = "PASS" if passed else "FAIL"
        print(f"       -> {status}  ({elapsed:.1f}s)")
        if errors:
            for e in errors:
                print(f"         !! {e}")
        print()

        results.append({
            'index':   idx,
            'section': sec,
            'category': cat,
            'passed':  passed,
            'errors':  errors,
            'elapsed': elapsed,
        })

    # Summary
    print("=" * 72)
    passed_n = sum(1 for r in results if r['passed'])
    failed_n = len(results) - passed_n
    print(f"\nResults: {passed_n} PASS  /  {failed_n} FAIL  (of {len(results)} run)")

    if failed_n > 0:
        print("\nFailed programs:")
        for r in results:
            if not r['passed']:
                print(f"  #{r['index']:02d} [{r['category']}] {r['section']}")
                for e in r['errors']:
                    print(f"       {e}")

    print(f"\nSkipped categories (not run):")
    for b in skip:
        cat = b['category']
        sec = b['section']
        print(f"  #{b['index']:02d} [{CATEGORY_LABELS[cat]}] {sec}")

    return failed_n == 0

# ─── Entry point ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Test all README example programs")
    parser.add_argument("--category", default="text,graphics,audio,file_io",
                        help="Comma-separated categories to run. Options: text,graphics,audio,file_io,all")
    parser.add_argument("--index", type=int, default=None,
                        help="Run only a single block by index (for debugging)")
    parser.add_argument("--list", action="store_true",
                        help="List all blocks with their categories and exit")
    args = parser.parse_args()

    blocks = extract_blocks(README_PATH)

    if args.list:
        for b in blocks:
            first = b['code'].splitlines()[0][:55]
            print(f"#{b['index']:02d} [{b['category']:12}] {b['section'][:30]:30}  {first}")
        sys.exit(0)

    if args.index is not None:
        block = next((b for b in blocks if b['index'] == args.index), None)
        if block is None:
            print(f"No block with index {args.index}")
            sys.exit(1)
        code = prepare_program(block['code'], block['category'])
        print(f"Running #{args.index} [{block['category']}] {block['section']}")
        print("--- Program ---")
        print(code)
        print("--- Running ---")
        passed, output, errors, elapsed = run_program(code)
        print(f"--- Output ({elapsed:.1f}s) ---")
        print(output)
        print(f"--- {'PASS' if passed else 'FAIL'} ---")
        for e in errors:
            print(f"  !! {e}")
        sys.exit(0 if passed else 1)

    if "all" in args.category:
        run_cats = {"text", "graphics", "audio", "file_io"}
    else:
        run_cats = set(args.category.split(","))

    ok = run_suite(blocks, run_cats)
    sys.exit(0 if ok else 1)
