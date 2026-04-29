# Ship Travelo iOS to TestFlight (App Store Connect)

This guide matches the Flutter app under `client/` with bundle ID **`com.travelo.app`**. Change it in Xcode and `ios/Runner.xcodeproj/project.pbxproj` if your App Store app uses another identifier.

## 1. Apple Developer Program

Join at [developer.apple.com/programs](https://developer.apple.com/programs/). You need an **Apple Developer** membership (paid yearly) for TestFlight with your own signing identity.

## 2. Register the App ID

1. [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list) → **Identifiers** → **+**
2. **App IDs** → continue → enter **Bundle ID** `com.travelo.app` (Explicit).
3. Enable capabilities only if your app truly needs them (push, Sign in with Apple, etc.). Save.

## 3. Create the app in App Store Connect

1. [App Store Connect](https://appstoreconnect.apple.com/) → **My Apps** → **+** → **New App**
2. **Platforms**: iOS. **Name**: e.g. Travelo. **Bundle ID**: choose `com.travelo.app` (must exist from step 2). **SKU**: any internal string (e.g. `travelo-ios`).
3. Complete **Privacy** (nutrition labels / data usage) when you submit builds.

## 4. Signing in Xcode (one-time per Mac)

1. Open **`client/ios/Runner.xcworkspace`** (not `.xcodeproj`) in Xcode.
2. Target **Runner** → **Signing & Capabilities**.
3. **Team**: your Apple Developer team. Enable **Automatically manage signing**.
4. Same for target **RunnerTests** if Xcode complains.

## 5. Build the IPA (CLI)

From the **`client`** directory:

```bash
chmod +x scripts/build_ios_testflight_ipa.sh
./scripts/build_ios_testflight_ipa.sh
```

Or manually:

```bash
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

The `.ipa` is under `build/ios/ipa/`.

Bump version in **`pubspec.yaml`** (`version: x.y.z+build`) before each upload; build numbers must increase for each App Store submission.

## 6. Upload to App Store Connect

**Easiest:** install **Transporter** from the Mac App Store, sign in with your Apple ID → drag the `.ipa` → Deliver.

Alternatively: Xcode **Window → Organizer** if you build via Archive from Xcode instead of Flutter’s IPA path.

CLI upload is possible using **Apple’s App Store Connect API** (API key `.p8` + issuer + key ID); use that for CI, not mandatory for manual TestFlight.

## 7. TestFlight

1. In App Store Connect open your app → **TestFlight**.
2. Wait for **Processing** to finish (and fix any emailed issues from Apple).
3. **Internal testing**: add testers in your organization.
4. **External testing**: add testers and complete the lightweight **Beta App Review** the first time you use external testers.

## Notes

- **`ITSAppUsesNonExemptEncryption`** is set to `false` in `Info.plist` (typical when you only use standard HTTPS APIs). Adjust if your app uses proprietary encryption Apple cares about under US export rules.
- If you change bundle ID globally, recreate the App Store Connect app entry and Certificates/Identifiers accordingly.
