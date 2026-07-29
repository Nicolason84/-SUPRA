#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

OUT="$HOME/Desktop/SUPRA_XCODE_IDENTITY"
mkdir -p "$OUT"

PROJECT="$(mdfind 'kMDItemFSName == "*.xcodeproj"' | grep '/SUPRA\.xcodeproj$' | head -n1 || true)"
WORKSPACE="$(mdfind 'kMDItemFSName == "*.xcworkspace"' | grep '/SUPRA.*\.xcworkspace$' | head -n1 || true)"

[ -n "$PROJECT" ] || {
  echo "ERREUR: SUPRA.xcodeproj introuvable."
  exit 1
}

if [ -n "$WORKSPACE" ]; then
  xcodebuild -list -workspace "$WORKSPACE" -json > "$OUT/list.json"
  MODE="-workspace"
  CONTAINER="$WORKSPACE"
else
  xcodebuild -list -project "$PROJECT" -json > "$OUT/list.json"
  MODE="-project"
  CONTAINER="$PROJECT"
fi

SCHEME="$(python3 - <<'PY'
import json
j=json.load(open("'"$OUT"'/list.json"))
for root in ("workspace","project"):
    if root in j:
        s=j[root].get("schemes",[])
        if s:
            print(s[0]); raise SystemExit
PY
)"

xcodebuild \
    $MODE "$CONTAINER" \
    -scheme "$SCHEME" \
    -showBuildSettings \
    > "$OUT/build_settings.txt" 2>/dev/null

python3 <<PY
import json,re,pathlib

txt=pathlib.Path("$OUT/build_settings.txt").read_text(errors="ignore")

def g(k):
    m=re.search(rf"^\s*{k}\s*=\s*(.+)$",txt,re.M)
    return m.group(1).strip() if m else ""

data={
    "workspace":"$WORKSPACE",
    "project":"$PROJECT",
    "scheme":"$SCHEME",
    "target":g("TARGET_NAME"),
    "product_name":g("PRODUCT_NAME"),
    "bundle_identifier":g("PRODUCT_BUNDLE_IDENTIFIER"),
    "info_plist":g("INFOPLIST_FILE"),
    "swift_version":g("SWIFT_VERSION"),
    "deployment_target":
        g("MACOSX_DEPLOYMENT_TARGET")
        or g("IPHONEOS_DEPLOYMENT_TARGET"),
}

pathlib.Path("$OUT/PROJECT.json").write_text(
    json.dumps(data,indent=2,ensure_ascii=False)
)
print(json.dumps(data,indent=2,ensure_ascii=False))
PY

echo
echo "=========================================="
echo "PASS"
echo "$OUT/PROJECT.json"
echo "=========================================="
