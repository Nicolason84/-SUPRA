#!/bin/bash
set -euo pipefail

REPO="Nicolason84/-SUPRA"
UPDATER_COMMIT="5cbe24c7a43ce3d1b92b7e3d9bde98b8e39659fd"
RAW="https://raw.githubusercontent.com/$REPO/$UPDATER_COMMIT"

SUPPORT="$HOME/Library/Application Support/NOVA ERA/SUPRA Updater"
UPDATER="$SUPPORT/supra_autobuild_self_update.sh"
APP="$HOME/Desktop/CAnnoNico.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"
EXEC="$MACOS/CAnnoNico"
PLIST="$CONTENTS/Info.plist"

TMP="$(mktemp -d /tmp/CANNONICO_NATIVE_V4.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$SUPPORT" "$MACOS" "$RESOURCES"

printf '[1/5] Install exact governed updater\n'
curl -fsSL "$RAW/RECOVERY/SUPRA_AUTOBUILD_SELF_UPDATE_V1.sh" -o "$TMP/updater.sh"
/bin/bash -n "$TMP/updater.sh"
cp "$TMP/updater.sh" "$UPDATER"
chmod 700 "$UPDATER"

printf '[2/5] Build native CAnnoNico executable\n'
cat >"$TMP/main.m" <<'OBJC'
#import <Cocoa/Cocoa.h>

@interface CAnnoNicoDelegate : NSObject <NSApplicationDelegate>
@property (strong) NSWindow *window;
@property (strong) NSTextField *statusLabel;
@property (strong) NSProgressIndicator *spinner;
@property (strong) NSTask *task;
@property (strong) NSFileHandle *logHandle;
@end

@implementation CAnnoNicoDelegate

- (void)showFailure:(NSString *)message {
    [self.spinner stopAnimation:nil];
    self.statusLabel.stringValue = message;
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"CAnnoNico";
    alert.informativeText = message;
    alert.alertStyle = NSAlertStyleCritical;
    [alert runModal];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

    NSRect frame = NSMakeRect(0, 0, 480, 170);
    self.window = [[NSWindow alloc]
        initWithContentRect:frame
        styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable)
        backing:NSBackingStoreBuffered
        defer:NO];
    self.window.title = @"CAnnoNico";
    [self.window center];

    NSTextField *title = [NSTextField labelWithString:@"SUPRA canonique"];
    title.font = [NSFont boldSystemFontOfSize:22];
    title.frame = NSMakeRect(28, 105, 420, 32);

    self.statusLabel = [NSTextField labelWithString:@"Vérification et actualisation de la bonne version…"];
    self.statusLabel.font = [NSFont systemFontOfSize:14];
    self.statusLabel.frame = NSMakeRect(28, 66, 420, 24);

    self.spinner = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(28, 28, 24, 24)];
    self.spinner.style = NSProgressIndicatorStyleSpinning;
    self.spinner.indeterminate = YES;
    [self.spinner startAnimation:nil];

    [self.window.contentView addSubview:title];
    [self.window.contentView addSubview:self.statusLabel];
    [self.window.contentView addSubview:self.spinner];
    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];

    NSString *home = NSHomeDirectory();
    NSString *support = [home stringByAppendingPathComponent:@"Library/Application Support/NOVA ERA/SUPRA Updater"];
    NSString *updater = [support stringByAppendingPathComponent:@"supra_autobuild_self_update.sh"];
    NSString *logPath = [support stringByAppendingPathComponent:@"cannonico_native_v4.log"];
    NSString *supraApp = [home stringByAppendingPathComponent:@"Applications/SUPRA.app"];

    if (![[NSFileManager defaultManager] isExecutableFileAtPath:updater]) {
        [self showFailure:@"Updater SUPRA introuvable ou non exécutable."];
        return;
    }

    [[NSFileManager defaultManager] createFileAtPath:logPath contents:nil attributes:nil];
    self.logHandle = [NSFileHandle fileHandleForWritingAtPath:logPath];
    [self.logHandle seekToEndOfFile];

    NSString *gateScript = [NSString stringWithFormat:
        @"set -e; "
         "REPO='Nicolason84/-SUPRA'; "
         "BRANCH='supra/human-gate-single-source-20260721_072447'; "
         "API='https://api.github.com/repos/'\"$REPO\"; "
         "PY=$(command -v python3); [ -n \"$PY\" ]; "
         "ENC_BRANCH=$($PY -c 'import urllib.parse; print(urllib.parse.quote(\"supra/human-gate-single-source-20260721_072447\", safe=\"\"))'); "
         "HEAD=$(/usr/bin/curl -fsSL \"$API/branches/$ENC_BRANCH\" | $PY -c 'import json,sys; print(json.load(sys.stdin)[\"commit\"][\"sha\"])'); "
         "ok=0; i=0; "
         "while [ \"$i\" -lt 120 ]; do i=$((i+1)); "
           "RUNS=$(/usr/bin/curl -fsSL \"$API/actions/runs?head_sha=$HEAD&status=completed&per_page=50\" || true); "
           "if printf '%%s' \"$RUNS\" | $PY -c 'import json,sys; "
             "x=json.load(sys.stdin); "
             "raise SystemExit(0 if any(r.get(\"name\")==\"Validate Canonical SUPRA\" and r.get(\"conclusion\")==\"success\" for r in x.get(\"workflow_runs\",[])) else 1)' >/dev/null 2>&1; then "
             "ok=1; break; "
           "fi; "
           "/bin/sleep 5; "
         "done; "
         "[ \"$ok\" = 1 ] || exit 31; "
         "exec /bin/bash '%@'",
         [updater stringByReplacingOccurrencesOfString:@"'" withString:@"'\\''"]];

    self.task = [[NSTask alloc] init];
    self.task.executableURL = [NSURL fileURLWithPath:@"/bin/bash"];
    self.task.arguments = @[@"-lc", gateScript];
    self.task.standardOutput = self.logHandle;
    self.task.standardError = self.logHandle;

    __weak typeof(self) weakSelf = self;
    self.task.terminationHandler = ^(NSTask *task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            typeof(self) selfRef = weakSelf;
            if (!selfRef) return;
            [selfRef.logHandle closeFile];
            [selfRef.spinner stopAnimation:nil];

            if (task.terminationStatus != 0) {
                [selfRef showFailure:[NSString stringWithFormat:@"Actualisation SUPRA échouée (code %d).", task.terminationStatus]];
                return;
            }

            if (![[NSFileManager defaultManager] fileExistsAtPath:supraApp]) {
                [selfRef showFailure:@"SUPRA canonique introuvable après actualisation."];
                return;
            }

            selfRef.statusLabel.stringValue = @"SUPRA canonique prête — ouverture…";
            [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:supraApp]];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                [NSApp terminate:nil];
            });
        });
    };

    NSError *error = nil;
    if (![self.task launchAndReturnError:&error]) {
        [self showFailure:[NSString stringWithFormat:@"Impossible de lancer l’updater: %@", error.localizedDescription]];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        CAnnoNicoDelegate *delegate = [[CAnnoNicoDelegate alloc] init];
        app.delegate = delegate;
        [app run];
    }
    return 0;
}
OBJC

/usr/bin/xcrun clang -fobjc-arc -framework Cocoa "$TMP/main.m" -o "$EXEC"
chmod 755 "$EXEC"

printf '[3/5] Write bundle metadata\n'
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
  <key>CFBundleShortVersionString</key><string>4.1</string>
  <key>CFBundleVersion</key><string>41</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

/usr/bin/plutil -lint "$PLIST" >/dev/null

printf '[4/5] Sign and verify native bundle\n'
/usr/bin/codesign --force --sign - --timestamp=none "$APP" >/dev/null
/usr/bin/codesign --verify --deep --strict "$APP"
xattr -dr com.apple.quarantine "$APP" >/dev/null 2>&1 || true
/usr/bin/file "$EXEC" | grep -q 'Mach-O'

printf '[5/5] Launch CAnnoNico V4\n'
/usr/bin/open "$APP"

printf '\nSTATUS=PASS\n'
printf 'CANNONICO_APP=%s\n' "$APP"
printf 'MODE=NATIVE_MACHO_CI_WAIT_UPDATE_FIRST_V4_1\n'
printf 'UPDATER_COMMIT=%s\n' "$UPDATER_COMMIT"
printf 'ACTION_NICOLAS=NONE\n'
