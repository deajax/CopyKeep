#!/bin/bash
# Fix Command Line Tools Swift module map conflict
# Run with: sudo bash fix-clt.sh

MODULE_MAP="/Library/Developer/CommandLineTools/usr/include/swift/module.modulemap"
BACKUP="${MODULE_MAP}.bak"

echo "Backing up original module.modulemap to ${BACKUP}..."
cp "$MODULE_MAP" "$BACKUP"

echo "Removing duplicate SwiftBridging definition from module.modulemap..."
sed -i '' '/^module SwiftBridging {/,/^}/d' "$MODULE_MAP"

echo "Done! Swift compiler should work now."
echo ""
echo "Verifying with swiftc..."
echo 'import Foundation; print("Swift works!")' > /tmp/swift_fix_test.swift
swiftc /tmp/swift_fix_test.swift -o /tmp/swift_fix_test 2>&1 && /tmp/swift_fix_test && rm -f /tmp/swift_fix_test.swift /tmp/swift_fix_test
