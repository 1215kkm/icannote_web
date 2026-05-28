# Building ICanNote

ICanNote v1 ships as a **local-only whiteboard** for three platforms: Web,
Windows desktop, and macOS desktop. All cloud features (sign-in, real-time
collaboration, cloud sync, real payments) are stubbed as "coming soon" in
this release.

Requires Flutter 3.41+ on the stable channel.

```
flutter --version   # confirm 3.41 or newer, stable
flutter doctor      # resolve any reported issues before building
flutter pub get
```

## Web (works on any OS)

```
flutter build web --release
```

The output is `build/web/`. Host the directory on any static file server.
For a quick local smoke test:

```
dart run tool/serve_web.dart 8091
# → http://127.0.0.1:8091
```

## Windows desktop

**One-time prerequisite — enable Developer Mode** so Windows allows the
symlinks the Flutter plugin system needs. Without this `flutter build
windows` fails with *"Building with plugins requires symlink support."*

```
start ms-settings:developers
# Toggle "Developer Mode" on, accept the dialog, then close Settings.
```

Then:

```
flutter build windows --release
```

The output is `build\windows\x64\runner\Release\icannote_web.exe` plus
its DLL/data dependencies in the same folder. Ship the whole folder.

## macOS desktop

Cannot be built from Windows — requires a Mac with Xcode 15+. On the
Mac, from a checkout of this repo:

```
flutter pub get
flutter build macos --release
```

The output is `build/macos/Build/Products/Release/icannote_web.app`. For
distribution outside the App Store you also need to sign and notarize:

```
codesign --deep --force --options runtime --sign "<Developer ID Application: …>" \
  build/macos/Build/Products/Release/icannote_web.app

xcrun notarytool submit icannote_web.app.zip \
  --apple-id <you@example.com> --team-id <TEAMID> --keychain-profile <profile> --wait
xcrun stapler staple icannote_web.app
```

(Signing/notarization is optional for personal use; macOS will gate
unsigned apps behind a Gatekeeper prompt instead.)

## Smoke test (any build)

1. App launches and shows three cards: *New Lecture*, *Lecture File*,
   *Open Textbook*.
2. "New Lecture" opens the editor with a blank A4 page.
3. Pen tool draws strokes on the canvas.
4. *Save/Print → Save As* writes an `.icn` file (web: browser download).
5. *Lecture File* re-opens the saved `.icn` and the strokes are restored.
6. *Sign in (soon)* and *Collaborate (soon)* show a "coming in a future
   update" snackbar — they do **not** navigate to a broken cloud screen.
7. The subscription page shows three plans with visible prices; the
   payment page shows a "DEMO MODE" banner.
