#!/bin/bash
set -e

cd "$(dirname "$0")"

export CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-$PWD/.build/ModuleCache}"
export SWIFTPM_MODULECACHE_OVERRIDE="${SWIFTPM_MODULECACHE_OVERRIDE:-$PWD/.build/ModuleCache}"

echo "→ Patching KeyboardShortcuts dependencies..."
RECORDER="$PWD/.build/checkouts/KeyboardShortcuts/Sources/KeyboardShortcuts/Recorder.swift"
if [ -f "$RECORDER" ]; then
    # Remove #Preview blocks that fail without Xcode's macro plugin
    sed -i '' '/#Preview {/,/^}/d' "$RECORDER"
    echo "  Patched: Removed #Preview blocks from Recorder.swift"
fi

echo "→ Building CopyKeep..."
swift build --disable-sandbox "$@"

echo "✓ Build complete!"
echo "  Binary at: $(swift build --disable-sandbox --show-bin-path "$@" 2>/dev/null || echo ".build/debug")/CopyKeep"
