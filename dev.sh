#!/bin/bash
set -e
set -o pipefail

cd "$(dirname "$0")"

export CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-$PWD/.build/ModuleCache}"
export SWIFTPM_MODULECACHE_OVERRIDE="${SWIFTPM_MODULECACHE_OVERRIDE:-$PWD/.build/ModuleCache}"

APP_NAME="CopyKeep"
APP_BUNDLE="$APP_NAME.app"
DEV_DIR="build/dev"
BUNDLE_ID="com.copykeep.app"

find_codesign_identity() {
    if [ -n "${COPYKEEP_CODESIGN_IDENTITY:-}" ]; then
        echo "$COPYKEEP_CODESIGN_IDENTITY"
        return
    fi

    security find-identity -v -p codesigning 2>/dev/null \
        | sed -n 's/.*"\(Apple Development:.*\)"/\1/p' \
        | head -1
}

echo "→ Killing existing $APP_NAME..."
pkill -f "$APP_NAME" 2>/dev/null || true
sleep 0.3

echo "→ Building (debug)..."
bash build.sh 2>&1 | tail -5

echo "→ Preparing dev .app bundle..."
mkdir -p "$DEV_DIR/$APP_BUNDLE/Contents/MacOS"
mkdir -p "$DEV_DIR/$APP_BUNDLE/Contents/Frameworks"
mkdir -p "$DEV_DIR/$APP_BUNDLE/Contents/Resources"
cp Info.plist "$DEV_DIR/$APP_BUNDLE/Contents/"
cp Sources/CopyKeep/Resources/AppIcon.icns "$DEV_DIR/$APP_BUNDLE/Contents/Resources/"
echo "APPL????" > "$DEV_DIR/$APP_BUNDLE/Contents/PkgInfo"
rm -rf "$DEV_DIR/$APP_BUNDLE/Contents/Frameworks/Sparkle.framework"
cp -R .build/debug/Sparkle.framework "$DEV_DIR/$APP_BUNDLE/Contents/Frameworks/Sparkle.framework"

# Copy fresh binary
BIN_PATH=$(swift build --disable-sandbox --show-bin-path 2>/dev/null || echo ".build/debug")
cp "$BIN_PATH/$APP_NAME" "$DEV_DIR/$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# Fix rpath so Sparkle.framework is found at ../Frameworks
install_name_tool -delete_rpath "@loader_path" "$DEV_DIR/$APP_BUNDLE/Contents/MacOS/$APP_NAME" 2>/dev/null || true
install_name_tool -add_rpath "@executable_path/../Frameworks" "$DEV_DIR/$APP_BUNDLE/Contents/MacOS/$APP_NAME"

SIGN_IDENTITY="$(find_codesign_identity)"
if [ -n "$SIGN_IDENTITY" ]; then
    echo "→ Signing dev app with: $SIGN_IDENTITY"
else
    SIGN_IDENTITY="-"
    echo "→ Signing dev app ad-hoc (no Apple developer certificate required)"
fi
codesign --force --deep --sign "$SIGN_IDENTITY" --identifier "$BUNDLE_ID" "$DEV_DIR/$APP_BUNDLE"

echo "→ Launching $APP_NAME..."
"$DEV_DIR/$APP_BUNDLE/Contents/MacOS/$APP_NAME" &>/dev/null &

echo "✓ Dev app launched! Check menu bar."
echo "  Logs: Console.app → search 'CopyKeep'"
echo "  Re-run: ./dev.sh"
