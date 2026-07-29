#!/usr/bin/env bash
set -e

echo "===== SUPRA Repository Diagnostic ====="
echo

echo "Repository:"
pwd
echo

echo "Git:"
git rev-parse --show-toplevel 2>/dev/null || echo "Not a git repo"
echo

echo "Total files:"
find . -type f | wc -l
echo

echo "Swift files:"
find . -name "*.swift" | wc -l
echo

echo "Largest directories:"
du -hd2 . 2>/dev/null | sort -hr | head -30
echo

echo "Directories >1000 files:"
find . -type d -print0 |
while IFS= read -r -d '' d; do
    n=$(find "$d" -maxdepth 1 -type f 2>/dev/null | wc -l)
    if [ "$n" -gt 1000 ]; then
        echo "$n  $d"
    fi
done | sort -nr

echo
echo "Ignored directories:"
find . \( \
-name .git -o \
-name .build -o \
-name build -o \
-name DerivedData -o \
-name node_modules -o \
-name Pods -o \
-name Carthage -o \
-name .swiftpm \
-o -name .cache \
\) -print
