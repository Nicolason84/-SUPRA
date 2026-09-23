#!/bin/bash
set -euo pipefail

APP="$HOME/Desktop/CAnnoNico.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
EXEC="$MACOS/CAnnoNico"
PLIST="$CONTENTS/Info.plist"

rm -rf "$APP"
mkdir -p "$MACOS"

cat >"$EXEC" <<'SH'
#!/bin/bash
set -u

SUPPORT="$HOME/Library/Application Support/NOVA ERA/SUPRA Updater"
UPDATER="$SUPPORT/supra_autobuild_self_update.sh"
APP="$HOME/Applications/SUPRA.app"
LOG="$SUPPORT/cannonico_launcher.log"
LOCK="$SUPPORT/update.lock"

mkdir -p "$SUPPORT"
/usr/bin/osascript -e 'display notification "Vérification de la version canonique…" with title "CAnnoNico"' >/dev/null 2>&1 || true

if [ ! -x "$UPDATER" ]; then
  /usr/bin/osascript -e 'display alert "CAnnoNico" message "Updater SUPRA introuvable." as critical' >/dev/null 2>&1 || true
  exit 2
fi

n=0
while [ -d "$LOCK" ]; do
  n=$((n+1))
  [ "$n" -le 900 ] || exit 75
  /bin/sleep 1
done

/bin/bash "$UPDATER" >>"$LOG" 2>&1
rc=$?
[ "$rc" -eq 0 ] || exit "$rc"

[ -d "$APP" ] || exit 3
/usr/bin/open "$APP" >/dev/null 2>&1 || exit 4
/usr/bin/osascript -e 'display notification "SUPRA canonique prête." with title "CAnnoNico"' >/dev/null 2>&1 || true
SH

chmod 755 "$EXEC"

cat >"$PLIST" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDisplayName</key><string>CAnnoNico</string>
  <key>CFBundleExecutable</key><string>CAnnoNico</string>
  <key>CFBundleIdentifier</key><string>com.novaera.cannonico-launcher</string>
  <key>CFBundleName</key><string>CAnnoNico</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>3.0</string>
  <key>CFBundleVersion</key><string>3</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
</dict>
</plist>
PLIST

/usr/bin/plutil -lint "$PLIST" >/dev/null
/usr/bin/codesign --force --sign - --timestamp=none "$APP" >/dev/null 2>&1 || true
xattr -dr com.apple.quarantine "$APP" >/dev/null 2>&1 || true

printf 'STATUS=PASS\n'
printf 'CANNONICO_APP=%s\n' "$APP"
printf 'MODE=UPDATE_FIRST_V3\n'
