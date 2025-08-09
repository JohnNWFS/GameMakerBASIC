#!/usr/bin/env python3
"""
concat_files.py – Concatenate *.gml files into a specified number of output files.

Usage:
    python concat_files.py [root_folder] [-n NUM_FILES]

Arguments:
    root_folder       Directory to search for *.gml files (default: current directory)
    -n, --num-files   Number of output files to split into (default: 3)
"""

import os
import argparse
from pathlib import Path

# Parse command-line arguments
parser = argparse.ArgumentParser(description='Concatenate *.gml files into specified number of files.')
parser.add_argument('root_folder', nargs='?', default=os.getcwd(),
                   help='Directory to search for *.gml files (default: current directory)')
parser.add_argument('-n', '--num-files', type=int, default=3, choices=range(1, 1001),
                   help='Number of output files to split into (default: 3)')
args = parser.parse_args()

ROOT = Path(args.root_folder)
NUM_FILES = args.num_files

# 1) Collect every .gml file, sorted
files = sorted(p for p in ROOT.rglob('*.gml') if p.is_file())

# 2) Build (file_path, size_in_bytes) and sort largest-first (FFD heuristic)
sizes = sorted(((f, f.stat().st_size) for f in files), key=lambda x: x[1], reverse=True)

# 3) Greedy bin-packing to keep each .gml whole
bins = [[] for _ in range(NUM_FILES)]         # per-bin list of Paths
bins_size = [0] * NUM_FILES                   # per-bin total size in bytes

for f, sz in sizes:
    idx = bins_size.index(min(bins_size))     # place into the currently smallest bin
    bins[idx].append(f)
    bins_size[idx] += sz

# 4) Write the output files
for idx, file_list in enumerate(bins):
    out_path = ROOT / f'output_{idx}gml.txt'  # keeping your original naming
    content = '\n'.join(f.read_text(encoding='utf-8') for f in file_list)
    out_path.write_text(content, encoding='utf-8')
    print(f'{out_path}  ({len(content.encode("utf-8")):,} bytes, {len(file_list)} files)')
