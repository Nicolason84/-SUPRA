#!/bin/bash
set -e

OUT="$HOME/Desktop/STORAGE_AUDIT_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT"

echo "===== DISK ====="
df -h /

echo
echo "===== TOP HOME ====="
du -hd 1 "$HOME" 2>/dev/null | sort -hr | tee "$OUT/home.txt"

echo
echo "===== TOP DESKTOP ====="
du -hd 2 "$HOME/Desktop" 2>/dev/null | sort -hr | head -100 | tee "$OUT/desktop.txt"

echo
echo "===== TOP NOVA ====="
du -hd 3 "$HOME/NOVA_OS" 2>/dev/null | sort -hr | head -200 | tee "$OUT/nova.txt"

echo
echo "===== XCODE ====="
du -sh \
"$HOME/Library/Developer/Xcode/DerivedData" \
"$HOME/Library/Developer/Xcode/Archives" \
"$HOME/Library/Developer/CoreSimulator" \
2>/dev/null | tee "$OUT/xcode.txt"

echo
echo "===== LIBRARY ====="
du -hd 1 "$HOME/Library" 2>/dev/null | sort -hr | head -80 | tee "$OUT/library.txt"

echo
echo "===== FILES >1GB ====="
find "$HOME" -type f -size +1G -print 2>/dev/null | tee "$OUT/bigfiles.txt"

echo
echo "Rapport : $OUT"
