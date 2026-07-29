#!/bin/bash
set -u

ROOT="$HOME/Desktop/NOVA_OS/SUPRA"
OUT="$HOME/Desktop/SUPRA_CONTINUITY_$(date +%Y%m%d_%H%M%S)"

mkdir -p "$OUT"

run () {
    local NAME="$1"
    shift
    echo "===================================================="
    echo "$NAME"
    echo "===================================================="
    "$@" 2>&1 | tee "$OUT/$NAME.txt"
    echo
}

cd "$ROOT" || {
    echo "SUPRA introuvable : $ROOT"
    exit 1
}

echo "===================================================="
echo "SUPRA CONTINUITY AUDIT"
echo "===================================================="

date | tee "$OUT/DATE.txt"

########################################

run SYSTEM sw_vers

run XCODE xcodebuild -version

run SWIFT swift --version

run GIT_VERSION git --version

########################################

run GIT_STATUS git status

run GIT_BRANCH git branch -vv

run GIT_WORKTREE git worktree list

run GIT_REMOTE git remote -v

run GIT_LOG git log --graph --decorate --oneline -30

run GIT_STASH git stash list

########################################

run BISECT_STATUS git bisect log

########################################

echo "HEAD" > "$OUT/HEAD.txt"
git rev-parse HEAD >> "$OUT/HEAD.txt"
git log -1 >> "$OUT/HEAD.txt"

########################################

run PROJECTS find . -maxdepth 3 \( -name "*.xcodeproj" -o -name "*.xcworkspace" \)

run PACKAGE find . -name Package.swift

########################################

run PBXPROJ find . -name project.pbxproj

########################################

run SWIFT_FILES bash -c "find . -name '*.swift' | sort"

########################################

run ADAPTERS bash -c "find . -iname '*adapter*' -o -iname '*bridge*' -o -iname '*gateway*'"

########################################

run CANNONICO bash -c "find . | grep -i cannonico"

########################################

run VIDEO bash -c "find . | grep -Ei 'VideoSwap|Video|Media'"

########################################

run RUNTIME bash -c "find . | grep -Ei 'Runtime|Mission|Evidence|Megabus'"

########################################

run BUILDABLE_TARGETS xcodebuild -project SUPRA.xcodeproj -list

########################################

echo "Compilation..." | tee "$OUT/BUILD_HEADER.txt"

xcodebuild \
-project SUPRA.xcodeproj \
-scheme SUPRA \
-configuration Debug \
build \
> "$OUT/BUILD.txt" 2>&1

if grep -q "BUILD SUCCEEDED" "$OUT/BUILD.txt"
then
    echo PASS | tee "$OUT/BUILD_RESULT.txt"
else
    echo FAIL | tee "$OUT/BUILD_RESULT.txt"
fi

########################################

grep -n "error:" "$OUT/BUILD.txt" \
> "$OUT/BUILD_ERRORS.txt" || true

grep -n "warning:" "$OUT/BUILD.txt" \
> "$OUT/BUILD_WARNINGS.txt" || true

########################################

run MODIFIED_SWIFT git diff --name-only -- '*.swift'

########################################

run UNTRACKED bash -c "git status --porcelain"

########################################

run RECENT_COMMITS git log --stat -10

########################################

run DISK df -h

########################################

run TOP_DESKTOP du -sh ~/Desktop/*

########################################

echo
echo "===================================================="
echo "AUDIT TERMINE"
echo "===================================================="
echo
echo "Dossier :"
echo "$OUT"
echo
echo "Fichiers principaux :"
echo "  BUILD_RESULT.txt"
echo "  BUILD_ERRORS.txt"
echo "  BUILD.txt"
echo "  GIT_STATUS.txt"
echo "  GIT_WORKTREE.txt"
echo "  BISECT_STATUS.txt"
echo "  RECENT_COMMITS.txt"
echo
