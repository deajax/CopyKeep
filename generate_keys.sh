#!/bin/bash
set -e

cd "$(dirname "$0")"

GENERATE_KEYS=".build/artifacts/sparkle/Sparkle/bin/generate_keys"

if [ ! -f "$GENERATE_KEYS" ]; then
    echo "Sparkle not found. Building dependencies first..."
    swift build 2>/dev/null || true
fi

if [ ! -f "$GENERATE_KEYS" ]; then
    echo "Error: Sparkle generate_keys tool not found at $GENERATE_KEYS"
    exit 1
fi

echo "→ Generating Sparkle EdDSA keys..."
echo ""
echo "  The private key will be stored in your macOS Keychain."
echo "  The public key will be printed below."
echo "  You only need ONE key pair for all your apps."
echo ""

"$GENERATE_KEYS"

echo ""
echo "→ Copy the above public key string and add it to Info.plist:"
echo '  <key>SUPublicEDKey</key>'
echo '  <string>PASTE_THE_PUBLIC_KEY_HERE</string>'
echo ""
echo "→ To sign an update DMG:"
echo "  .build/artifacts/sparkle/Sparkle/bin/sign_update -f ~/.sparkle/private-key.pem CopyKeep-x.x.x.dmg"
echo ""
echo "  OR (if private key is in Keychain):"
echo "  .build/artifacts/sparkle/Sparkle/bin/sign_update CopyKeep-x.x.x.dmg"
