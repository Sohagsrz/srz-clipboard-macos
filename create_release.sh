#!/bin/bash

# Srz Clipboard Release Script
# This script builds the app in Release mode and creates a DMG file

set -e

echo "🚀 Creating Srz Clipboard Release Package"
echo "=========================================="

# Configuration
APP_NAME="Srz Clipboard"
BUNDLE_ID="sohag.app.Srz-Clipboard"
VERSION="2.0.0"
DMG_NAME="Srz_Clipboard_v${VERSION}.dmg"
RELEASE_DIR="Release"

# Clean up previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

# Build the app in Release mode
echo "🔨 Building app in Release mode..."
xcodebuild -project "Srz Clipboard.xcodeproj" \
           -scheme "Srz Clipboard" \
           -configuration Release \
           -derivedDataPath "DerivedData" \
           build

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
else
    echo "❌ Build failed!"
    exit 1
fi

# Copy the app to release directory
echo "📦 Copying app to release directory..."
cp -R "DerivedData/Build/Products/Release/Srz Clipboard.app" "$RELEASE_DIR/"

# Create DMG
echo "💿 Creating DMG file..."
hdiutil create -volname "$APP_NAME" \
               -srcfolder "$RELEASE_DIR" \
               -ov -format UDZO \
               "$DMG_NAME"

if [ $? -eq 0 ]; then
    echo "✅ DMG created successfully: $DMG_NAME"
else
    echo "❌ DMG creation failed!"
    exit 1
fi

# Get DMG file size
DMG_SIZE=$(du -h "$DMG_NAME" | cut -f1)
echo "📊 DMG file size: $DMG_SIZE"

# Create checksums
echo "🔐 Creating checksums..."
shasum -a 256 "$DMG_NAME" > "${DMG_NAME}.sha256"
echo "✅ SHA256 checksum created: ${DMG_NAME}.sha256"

# Clean up
echo "🧹 Cleaning up temporary files..."
rm -rf "$RELEASE_DIR"
rm -rf "DerivedData"

echo ""
echo "🎉 Release package created successfully!"
echo "========================================"
echo "📁 DMG file: $DMG_NAME"
echo "📁 Checksum: ${DMG_NAME}.sha256"
echo "📊 Size: $DMG_SIZE"
echo ""
echo "🚀 Ready for GitHub release!"
