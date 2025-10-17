#!/bin/bash

echo "🔍 Verifying Srz Clipboard Installation"
echo "======================================"

# Check if app is installed
if [ -d "/Applications/Srz Clipboard.app" ]; then
    echo "✅ Application installed: /Applications/Srz Clipboard.app"
    
    # Check app version
    APP_VERSION=$(defaults read "/Applications/Srz Clipboard.app/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "Unknown")
    echo "📱 App version: $APP_VERSION"
    
    # Check if running
    if pgrep -f "Srz Clipboard" > /dev/null; then
        echo "✅ Application is running"
    else
        echo "⚠️  Application is not running"
    fi
    
    # Check LaunchAgent
    LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.sohag.srz-clipboard.plist"
    if [ -f "$LAUNCH_AGENT" ]; then
        echo "✅ LaunchAgent configured"
    else
        echo "⚠️  LaunchAgent not found"
    fi
    
    # Check Accessibility permissions
    if osascript -e 'tell application "System Events" to return UI elements enabled' &>/dev/null; then
        echo "✅ Accessibility permissions granted"
    else
        echo "⚠️  Accessibility permissions not granted"
        echo "   Go to System Settings > Privacy & Security > Accessibility"
    fi
    
else
    echo "❌ Application not found in /Applications/"
fi

echo ""
echo "🎯 Installation verification complete!"
