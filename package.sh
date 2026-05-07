#!/bin/bash
set -e

cd "$(dirname "$0")"

VERSION="${1:-1.0.0}"
BUILD_DIR=".build/x86_64-apple-macosx/release"
APP_NAME="CopyKeep"
APP_BUNDLE="$APP_NAME.app"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
STAGING_DIR="build/staging"
BUNDLE_ID="com.copykeep.app"

find_codesign_identity() {
    if [ -n "${COPYKEEP_CODESIGN_IDENTITY:-}" ]; then
        echo "$COPYKEEP_CODESIGN_IDENTITY"
        return
    fi

    security find-identity -v -p codesigning 2>/dev/null \
        | sed -n 's/.*"\(Developer ID Application:.*\)"/\1/p' \
        | head -1
}

echo "→ Building release binary..."
bash build.sh --configuration release

echo "→ Creating app bundle..."
rm -rf "$STAGING_DIR" "$APP_BUNDLE"
mkdir -p "$STAGING_DIR/$APP_BUNDLE/Contents/MacOS"
mkdir -p "$STAGING_DIR/$APP_BUNDLE/Contents/Frameworks"
mkdir -p "$STAGING_DIR/$APP_BUNDLE/Contents/Resources"

# Copy binary
cp "$BUILD_DIR/$APP_NAME" "$STAGING_DIR/$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# Copy Info.plist
cp Info.plist "$STAGING_DIR/$APP_BUNDLE/Contents/"

# Copy AppIcon
cp Sources/CopyKeep/Resources/AppIcon.icns "$STAGING_DIR/$APP_BUNDLE/Contents/Resources/"

# Copy Sparkle framework
cp -R "$BUILD_DIR/Sparkle.framework" "$STAGING_DIR/$APP_BUNDLE/Contents/Frameworks/Sparkle.framework"

# Set rpath so the binary finds Sparkle
install_name_tool -add_rpath "@executable_path/../Frameworks" \
    "$STAGING_DIR/$APP_BUNDLE/Contents/MacOS/$APP_NAME" 2>/dev/null || true

# Minimal PkgInfo (required for macOS app bundles)
echo "APPL????" > "$STAGING_DIR/$APP_BUNDLE/Contents/PkgInfo"

SIGN_IDENTITY="$(find_codesign_identity)"
if [ -n "$SIGN_IDENTITY" ]; then
    echo "→ Signing app with: $SIGN_IDENTITY"
else
    SIGN_IDENTITY="-"
    echo "→ Signing app ad-hoc (GitHub distribution without an Apple developer certificate)"
fi
codesign --force --deep --sign "$SIGN_IDENTITY" --identifier "$BUNDLE_ID" "$STAGING_DIR/$APP_BUNDLE"

echo "→ Creating DMG..."
rm -f "$DMG_NAME"

# Create temporary DMG with folder
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING_DIR/$APP_BUNDLE" \
    -ov -format UDZO -size 100m "$DMG_NAME"

echo "→ Cleaning up..."
rm -rf "$STAGING_DIR"

echo ""
echo "✓ Package created: $DMG_NAME"
echo "  Size: $(ls -lh "$DMG_NAME" | awk '{print $5}')"
echo ""
echo "→ To set up Sparkle updates:"
echo "  1. Generate EdDSA keys:"
echo "     ./generate_keys.sh"
echo "  2. Upload $DMG_NAME to GitHub Releases"
echo "  3. Update appcast.xml and SUFeedURL in Info.plist"
echo "  4. Update SUPublicEDKey in Info.plist with the public key"
