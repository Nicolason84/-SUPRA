#!/bin/bash
set -euo pipefail

DESKTOP="$HOME/Desktop"
APP="$DESKTOP/CAnnoNico.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
EXEC="$MACOS/CAnnoNico"
PLIST="$CONTENTS/Info.plist"

mkdir -p "$DESKTOP"
rm -rf "$APP"
mkdir -p "$MACOS"

cat >"$EXEC" <<'SH'
#!/bin/bash
set -u

SUPPORT="$HOME/Library/Application Support/NOVA ERA/SUPRA Updater"
UPDATER="$SUPPORT/supra_autobuild_self_update.sh"
TARGET="$HOME/Applications/SUPRA.app"
LOG="$SUPPORT/cannonico_launcher.log"
LABEL="com.novaera.supra-autoupdate"

mkdir -p "$SUPPORT"

/usr/bin/osascript -e 'display notification "SUPRA démarre. Vérification canonique en arrière-plan…" with title "CAnnoNico"' >/dev/null 2>&1 || true

if [ -d "$TARGET" ]; then
  /usr/bin/open "$TARGET" >/dev/null 2>&1 || true
fi

if /bin/launchctl print "gui/$UID/$LABEL" >/dev/null 2>&1; then
  /bin/launchctl kickstart -k "gui/$UID/$LABEL" >>"$LOG" 2>&1 || true
elif [ -x "$UPDATER" ]; then
  (/bin/bash "$UPDATER" >>"$LOG" 2>&1 </dev/null &) >/dev/null 2>&1
else
  /usr/bin/osascript -e 'display alert "CAnnoNico" message "Updater SUPRA introuvable." as critical' >/dev/null 2>&1 || true
  exit 2
fi

exit 0
SH
chmod 755 "$EXEC"

cat >"$PLIST" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDisplayName</key>
  <string>CAnnoNico</string>
  <key>CFBundleExecutable</key>
  <string>CAnnoNico</string>
  <key>CFBundleIdentifier</key>
  <string>com.novaera.cannonico-launcher</string>
  <key>CFBundleName</key>
  <string>CAnnoNico</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>2.0</string>
  <key>CFBundleVersion</key>
  <string>2</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
</dict>
</plist>
PLIST

/usr/bin/plutil -lint "$PLIST" >/dev/null
/usr/bin/codesign --force --sign - --timestamp=none "$APP" >/dev/null 2>&1 || true
xattr -dr com.apple.quarantine "$APP" >/dev/null 2>&1 || true

[ -x "$EXEC" ]
[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$PLIST")" = "com.novaera.cannonico-launcher" ]

printf 'STATUS=PASS\n'
printf 'CANNONICO_APP=%s\n' "$APP"
printf 'MODE=NATIVE_SHELL_BUNDLE_V2\n'
printf 'ACTION_NICOLAS=DOUBLE_CLICK_CANNONICO\n'
