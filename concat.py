#!/usr/bin/env python3
"""
concat_to_3.py  –  Concatenate *.gml into exactly 3 files.

Usage:
    python concat_to_3.py  [root_folder]
"""

import os
import sys
from pathlib import Path

ROOT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()

# 1. Collect every .gml file, sorted
files = sorted(ROOT.rglob('*.gml'))

# 2. Build a list of (file_path, byte_size) without reading yet
sizes = [(f, len(f.read_text(encoding='utf-8').encode('utf-8'))) for f in files]

# 3. Greedy bin-packing to keep each .gml whole
bins = [[] for _ in range(3)]
bins_size = [0, 0, 0]

for f, sz in sizes:
    # choose smallest current bin
    idx = bins_size.index(min(bins_size))
    bins[idx].append(f)
    bins_size[idx] += sz

# 4. Write the three files
for idx, file_list in enumerate(bins):
    out_path = ROOT / f'output_{idx}gml.txt'
    content = '\n'.join(f.read_text(encoding='utf-8') for f in file_list)
    out_path.write_text(content, encoding='utf-8')
    print(f'{out_path}  ({len(content.encode("utf-8")):,} bytes, {len(file_list)} files)')