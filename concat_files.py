#!/usr/bin/env python3
"""
concat_files.py – Concatenate *.gml files into a single output file with file and event headers.
Usage:
    python concat_files.py [root_folder] [-o OUTPUT_FILE] [-d DAYS]
Arguments:
    root_folder       Directory to search for *.gml files (default: current directory)
    -o, --output-file Output file name (default: output_gml.txt)
    -d, --days        Only include files modified within the last N days (default: include all files)
"""
import os
import argparse
from pathlib import Path
import re
from datetime import datetime, timedelta

# Parse command-line arguments
parser = argparse.ArgumentParser(description='Concatenate *.gml files with headers for files and object events.')
parser.add_argument('root_folder', nargs='?', default=os.getcwd(),
                   help='Directory to search for *.gml files (default: current directory)')
parser.add_argument('-o', '--output-file', type=str, default='output_gml.txt',
                   help='Output file name (default: output_gml.txt)')
parser.add_argument('-d', '--days', type=int, metavar='DAYS',
                   help='Only include files modified within the last N days (0 = today only, 1 = today and yesterday, etc.)')

args = parser.parse_args()
ROOT = Path(args.root_folder)
OUTPUT_FILE = Path(args.output_file)

def get_file_header(file_path):
    """Generate a header for a .gml file, including event header if applicable."""
    # Relative path from root
    rel_path = file_path.relative_to(ROOT).as_posix()
    header = f'/// @file {rel_path}\n'
    
    # Check if file is an object event (e.g., obj_name_Event_0.gml)
    file_name = file_path.name
    event_match = re.match(r'(obj_[a-zA-Z0-9_]+)_([a-zA-Z_]+)_\d+\.gml$', file_name)
    if event_match:
        obj_name = event_match.group(1)
        event_name = event_match.group(2)
        # Normalize event name (e.g., Game_End → Game_End, Create_0 → Create)
        event_name = re.sub(r'_\d+$', '', event_name)
        header += f'/// @event {obj_name}/{event_name}\n'
    
    return header

def is_file_within_date_range(file_path, days):
    """Check if file was modified within the specified number of days."""
    if days is None:
        return True
    
    # Get file modification time
    mod_time = datetime.fromtimestamp(file_path.stat().st_mtime)
    
    # Calculate the cutoff date (start of day N days ago)
    today = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    cutoff_date = today - timedelta(days=days)
    
    # File is included if modified on or after the cutoff date
    return mod_time >= cutoff_date

# Collect all .gml files, sorted for consistency
all_files = sorted(p for p in ROOT.rglob('*.gml') if p.is_file())

# Filter files by date if -d option is specified
if args.days is not None:
    files = [f for f in all_files if is_file_within_date_range(f, args.days)]
    print(f'Filtered to {len(files)} files modified within the last {args.days} day{"s" if args.days != 1 else ""} (from {len(all_files)} total)')
else:
    files = all_files

# Build output content
content = []
for file_path in files:
    # Add file and event header
    content.append(get_file_header(file_path))
    # Add file content
    file_content = file_path.read_text(encoding='utf-8')
    # Preserve existing /// @script or /// @function headers
    content.append(file_content)
    # Add separator for readability
    content.append('\n' + '=' * 80 + '\n')

# Write to output file
OUTPUT_FILE.write_text('\n'.join(content), encoding='utf-8')
print(f'Wrote {OUTPUT_FILE} ({len("".join(content).encode("utf-8")):,} bytes, {len(files)} files)')