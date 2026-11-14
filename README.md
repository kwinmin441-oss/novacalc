# NovaCalc

Futuristic Flutter calculator starter project.

## Included

- Futuristic dark/light interface
- Basic expression calculator with scientific function keys
- Local calculation history
- Smart Tools placeholder screen
- Google Mobile Ads integration scaffold (Google test ad unit IDs)
- GitHub Actions workflow for Android APK and AAB builds

## Important status

This is a runnable starter/foundation, **not yet a finished production release**.
The Smart Tools screen currently contains placeholders. Currency conversion,
finance tools, privacy/consent flow, production ad configuration, store assets,
and release signing must be completed and tested before publishing.

## Requirements

- Flutter stable SDK
- Android SDK / Android Studio command-line tools
- VS Code with Flutter and Dart extensions
- Android device with USB debugging for local testing

## Create platform folders

This source bundle intentionally contains the app source and GitHub workflow.
Generate the platform-specific Flutter wrapper files from the project root:

```bash
flutter create --org com.novacalc --platforms=android,ios .
```

If Flutter asks to overwrite files, keep the existing `lib`, `pubspec.yaml`,
`.github`, `README.md`, and `test` files.

Then install packages:

```bash
flutter pub get
```

## Android AdMob setup

The app currently uses Google's official test ad unit IDs.
Before publishing, create your own AdMob app and ad units, then replace the
test IDs in `lib/services/ad_service.dart`.

Add your AdMob App ID inside the `<application>` element of
`android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="YOUR_ADMOB_APP_ID"/>
```

Do not publish with the sample App ID or test ad unit IDs. Follow Google's
current consent, privacy, and ad policies for your target regions.

## Run

```bash
flutter analyze
flutter test
flutter run
```

## GitHub

Create a repository named `novacalc`, then from this folder:

```bash
git init
git add .
git commit -m "Initial NovaCalc project"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/novacalc.git
git push -u origin main
```

GitHub Actions builds APK and AAB files on pushes to `main`.
Download the generated files from the workflow run's Artifacts section.

## iOS

You can generate iOS project files on Windows, but building/signing/releasing
the iOS app requires macOS and Xcode.
