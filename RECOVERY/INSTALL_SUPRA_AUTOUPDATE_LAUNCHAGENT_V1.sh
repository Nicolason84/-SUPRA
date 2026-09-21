#!/bin/bash
set -euo pipefail

LABEL="com.novaera.supra-autoupdate"
SUPPORT="$HOME/Library/Application Support/NOVA ERA/SUPRA Updater"
UPDATER="$SUPPORT/supra_autobuild_self_update.sh"
PLIST="$HOME/Library/LaunchAgents/"$LABEL".plist"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_UPDATER="$SOURCE_DIR/SUPRA_AUTOBUILD_SELF_UPDATE_V1.sh"

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
fail(){
  code=1
  [ "$#" -gt 1 ] && code="$2"
  printf '\nSTATUS=FAIL_BOUNDED\nBLOCKER=%s\n' "$1"
  exit "$code"
}

say "1/5 Verify updater source"
[ -f "$SOURCE_UPDATER" ] || fail "UPDATER_SOURCE_MISSING:$SOURCE_UPDATER" 10
/bin/bash -n "$SOURCE_UPDATER" || fail "UPDATER_SOURCE_SYNTAX_FAIL" 11

say "2/5 Install updater payload"
mkdir -p "$SUPPORT" "$HOME/Library/LaunchAgents"
cp "$SOURCE_UPDATER" "$UPDATER"
chmod 700 "$UPDATER"

say "3/5 Install dedicated LaunchAgent"
cat >"$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$UPDATER</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StartInterval</key>
  <integer>600</integer>
  <key>ProcessType</key>
  <string>Background</string>
  <key>LowPriorityIO</key>
  <true/>
  <key>Nice</key>
  <integer>10</integer>
  <key>StandardOutPath</key>
  <string>$SUPPORT/launchagent.stdout.log</string>
  <key>StandardErrorPath</key>
  <string>$SUPPORT/launchagent.stderr.log</string>
</dict>
</plist>
EOF
plutil -lint "$PLIST" >/dev/null || fail "LAUNCHAGENT_PLIST_INVALID" 20

say "4/5 Bootstrap updater"
launchctl bootout "gui/$UID/$LABEL" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$UID" "$PLIST" || fail "LAUNCHAGENT_BOOTSTRAP_FAILED" 30
launchctl kickstart -k "gui/$UID/$LABEL" || fail "LAUNCHAGENT_KICKSTART_FAILED" 31

say "5/5 Proof"
launchctl print "gui/$UID/$LABEL" | sed -n '1,90p'
printf 'UPDATER=%s\n' "$UPDATER"
printf 'PLIST=%s\n' "$PLIST"
printf 'INTERVAL_SECONDS=600\n'
printf '\nSTATUS=AUTOUPDATE_LAUNCHAGENT_INSTALLED\n'
printf 'ACTION_NICOLAS=NONE\n'
