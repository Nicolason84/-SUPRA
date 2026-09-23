#!/bin/bash
set -euo pipefail

REPO="Nicolason84/-SUPRA"
UPDATER_COMMIT="f7dcd46ec863ec5053cd8febea28366b055c7220"
RAW="https://raw.githubusercontent.com/$REPO/$UPDATER_COMMIT"

SUPPORT="$HOME/Library/Application Support/NOVA ERA/SUPRA Updater"
UPDATER="$SUPPORT/supra_autobuild_self_update.sh"
APP="$HOME/Desktop/CAnnoNico.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
EXEC="$MACOS/CAnnoNico"
PLIST="$CONTENTS/Info.plist"

TMP="$(mktemp -d /tmp/CANNONICO_NATIVE_V5.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT

/usr/bin/pkill -TERM -x CAnnoNico >/dev/null 2>&1 || true
/bin/sleep 0.5
/usr/bin/pkill -KILL -x CAnnoNico >/dev/null 2>&1 || true
rm -rf "$APP"
mkdir -p "$SUPPORT" "$MACOS"

printf '[1/5] Install governed updater\n'
curl -fsSL "$RAW/RECOVERY/SUPRA_AUTOBUILD_SELF_UPDATE_V1.sh" -o "$TMP/updater.sh"
/bin/bash -n "$TMP/updater.sh"
cp "$TMP/updater.sh" "$UPDATER"
chmod 700 "$UPDATER"

printf '[2/5] Build native ONE_SUPRA launcher\n'
cat >"$TMP/main.m" <<'OBJC'
#import <Cocoa/Cocoa.h>

@interface CAnnoNicoDelegate : NSObject <NSApplicationDelegate>
@property (strong) NSWindow *window;
@property (strong) NSTextField *statusLabel;
@property (strong) NSProgressIndicator *spinner;
@property (strong) NSTask *task;
@property (strong) NSFileHandle *logHandle;
@property (copy) NSString *logPath;
@end

@implementation CAnnoNicoDelegate

- (NSString *)logTail {
    NSData *data = [NSData dataWithContentsOfFile:self.logPath ?: @""];
    if (!data) return @"";
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
    NSUInteger max = 2400;
    if (text.length > max) return [text substringFromIndex:text.length - max];
    return text;
}

- (void)showFailure:(NSString *)message {
    [self.spinner stopAnimation:nil];
    self.statusLabel.stringValue = message;
    NSString *tail = [self logTail];
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"CAnnoNico";
    alert.informativeText = tail.length ? [NSString stringWithFormat:@"%@\n\n%@", message, tail] : message;
    alert.alertStyle = NSAlertStyleCritical;
    [alert runModal];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

    self.window = [[NSWindow alloc]
        initWithContentRect:NSMakeRect(0, 0, 520, 180)
        styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable)
        backing:NSBackingStoreBuffered
        defer:NO];
    self.window.title = @"CAnnoNico";
    [self.window center];

    NSTextField *title = [NSTextField labelWithString:@"SUPRA canonique"];
    title.font = [NSFont boldSystemFontOfSize:22];
    title.frame = NSMakeRect(28, 112, 460, 32);

    self.statusLabel = [NSTextField labelWithString:@"Fermeture des anciennes versions → mise à jour → instance unique…"];
    self.statusLabel.font = [NSFont systemFontOfSize:14];
    self.statusLabel.frame = NSMakeRect(28, 70, 460, 28);

    self.spinner = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(28, 30, 24, 24)];
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
    NSString *supraApp = [home stringByAppendingPathComponent:@"Applications/SUPRA.app"];
    self.logPath = [support stringByAppendingPathComponent:@"cannonico_native_v5.log"];

    [[NSFileManager defaultManager] createFileAtPath:self.logPath contents:nil attributes:nil];
    self.logHandle = [NSFileHandle fileHandleForWritingAtPath:self.logPath];
    [self.logHandle truncateFileAtOffset:0];

    if (![[NSFileManager defaultManager] isExecutableFileAtPath:updater]) {
        [self showFailure:@"Updater SUPRA introuvable ou non exécutable."];
        return;
    }

    NSString *shell = @"set -u; "
    "kill_all(){ "
      "/usr/bin/pkill -TERM -x SUPRA >/dev/null 2>&1 || true; "
      "/usr/bin/pkill -TERM -x SUPRAClean >/dev/null 2>&1 || true; "
      "/usr/bin/pkill -TERM -x OjoCompanion >/dev/null 2>&1 || true; "
      "/bin/sleep 1; "
      "/usr/bin/pkill -KILL -x SUPRA >/dev/null 2>&1 || true; "
      "/usr/bin/pkill -KILL -x SUPRAClean >/dev/null 2>&1 || true; "
      "/usr/bin/pkill -KILL -x OjoCompanion >/dev/null 2>&1 || true; "
    "}; "
    "kill_all; "
    "printf 'CANNONICO_PHASE=OLD_VERSIONS_KILLED\\n'; "
    "tries=0; rc=1; "
    "while [ $tries -lt 120 ]; do "
      "tries=$((tries+1)); "
      "/bin/bash \"$UPDATER\"; rc=$?; "
      "[ $rc -eq 0 ] && break; "
      "if /usr/bin/tail -n 80 \"$LOGFILE\" 2>/dev/null | /usr/bin/grep -q 'CANONICAL_CI_NOT_SUCCESS_FOR_SHA'; then "
        "/bin/sleep 5; continue; "
      "fi; "
      "exit $rc; "
    "done; "
    "[ $rc -eq 0 ] || exit 31; "
    "kill_all; "
    "printf 'CANNONICO_PHASE=POST_UPDATE_PURGE_DONE\\n'; "
    "[ -d \"$SUPRA_APP\" ] || exit 32; "
    "if ! /usr/bin/open -n \"$SUPRA_APP\"; then "
      "(\"$SUPRA_APP/Contents/MacOS/SUPRA\" >/dev/null 2>&1 </dev/null &) >/dev/null 2>&1; "
    "fi; "
    "i=0; "
    "while [ $i -lt 60 ]; do "
      "i=$((i+1)); "
      "CAN=0; TOTAL=0; "
      "for p in $(/usr/bin/pgrep -x SUPRA 2>/dev/null || true); do "
        "TOTAL=$((TOTAL+1)); "
        "cmd=$(/bin/ps -ww -p \"$p\" -o command= 2>/dev/null || true); "
        "case \"$cmd\" in "
          "*\"$SUPRA_APP/Contents/MacOS/SUPRA\"*) CAN=$((CAN+1));; "
          "*) /bin/kill -KILL \"$p\" >/dev/null 2>&1 || true;; "
        "esac; "
      "done; "
      "AUX=$(( $(/usr/bin/pgrep -x SUPRAClean 2>/dev/null | /usr/bin/wc -l | /usr/bin/tr -d ' ') + $(/usr/bin/pgrep -x OjoCompanion 2>/dev/null | /usr/bin/wc -l | /usr/bin/tr -d ' ') )); "
      "[ \"$CAN\" -eq 1 ] && [ \"$TOTAL\" -eq 1 ] && [ \"$AUX\" -eq 0 ] && break; "
      "/bin/sleep 0.5; "
    "done; "
    "[ \"$CAN\" -eq 1 ] || exit 40; "
    "[ \"$TOTAL\" -eq 1 ] || exit 41; "
    "[ \"$AUX\" -eq 0 ] || exit 42; "
    "printf 'ONE_SUPRA_AUTHORITY=PROVEN_CANONICAL_ONLY\\n'; "
    "exit 0";

    self.task = [[NSTask alloc] init];
    self.task.executableURL = [NSURL fileURLWithPath:@"/bin/bash"];
    self.task.arguments = @[@"-lc", shell];
    NSMutableDictionary *env = [[[NSProcessInfo processInfo] environment] mutableCopy];
    env[@"UPDATER"] = updater;
    env[@"SUPRA_APP"] = supraApp;
    env[@"LOGFILE"] = self.logPath;
    self.task.environment = env;
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
                [selfRef showFailure:[NSString stringWithFormat:@"Échec de la convergence SUPRA (code %d).", task.terminationStatus]];
                return;
            }

            selfRef.statusLabel.stringValue = @"ONE_SUPRA prouvé — version canonique active.";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                [NSApp terminate:nil];
            });
        });
    };

    NSError *error = nil;
    if (![self.task launchAndReturnError:&error]) {
        [self showFailure:[NSString stringWithFormat:@"Impossible de lancer la convergence: %@", error.localizedDescription]];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender { return YES; }
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
<plist version="1.0"><dict>
  <key>CFBundleDisplayName</key><string>CAnnoNico</string>
  <key>CFBundleExecutable</key><string>CAnnoNico</string>
  <key>CFBundleIdentifier</key><string>com.novaera.cannonico-launcher</string>
  <key>CFBundleName</key><string>CAnnoNico</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>5.0</string>
  <key>CFBundleVersion</key><string>50</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST

/usr/bin/plutil -lint "$PLIST" >/dev/null

printf '[4/5] Clean, sign and register\n'
/usr/bin/xattr -cr "$APP" >/dev/null 2>&1 || true
/usr/bin/dot_clean -m "$APP" >/dev/null 2>&1 || true
/usr/bin/xattr -cr "$APP" >/dev/null 2>&1 || true
/usr/bin/codesign --force --deep --sign - --timestamp=none "$APP"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$APP"

LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
if [ -x "$LSREGISTER" ]; then
  "$LSREGISTER" -u "$APP" >/dev/null 2>&1 || true
  "$LSREGISTER" -f "$APP" >/dev/null 2>&1 || true
fi

printf '[5/5] Launch V5\n'
if ! /usr/bin/open -n "$APP"; then
  ("$EXEC" >"$SUPPORT/cannonico_native_v5.stdout.log" 2>"$SUPPORT/cannonico_native_v5.stderr.log" </dev/null &) >/dev/null 2>&1
fi

printf '\nSTATUS=PASS\n'
printf 'CANNONICO_APP=%s\n' "$APP"
printf 'MODE=ONE_SUPRA_NATIVE_V5\n'
printf 'UPDATER_COMMIT=%s\n' "$UPDATER_COMMIT"
printf 'ACTION_NICOLAS=NONE\n'
