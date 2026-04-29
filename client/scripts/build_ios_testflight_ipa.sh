#!/usr/bin/env bash
# Builds a release IPA for App Store Connect / TestFlight.
# Prerequisites: Xcode + CocoaPods + Flutter SDK; signing configured in Xcode
# for the Runner target (automatic signing + your Apple Developer team).
#
# Usage (from repo root or client/):
#   chmod +x client/scripts/build_ios_testflight_ipa.sh
#   ./client/scripts/build_ios_testflight_ipa.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo ">> Flutter: $(flutter --version | head -1)"
flutter pub get

echo ">> pod install..."
pushd ios >/dev/null
pod install --silent
popd >/dev/null

echo ">> flutter build ipa (Release)..."
flutter build ipa --release \
  --export-options-plist="${ROOT}/ios/ExportOptions.plist"

IPA_DIR="${ROOT}/build/ios/ipa"
echo ""
echo "Done. IPA output directory:"
echo "  ${IPA_DIR}"
ls -la "${IPA_DIR}"/*.ipa 2>/dev/null || true
echo ""
echo "Next: upload with Transporter (Mac App Store) or Xcode Organizer."
echo "  App Store Connect → TestFlight waits for „Processing“."
