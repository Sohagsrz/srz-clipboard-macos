#!/bin/bash
echo "🗑️  Uninstalling Srz Clipboard..."

# Kill running instances
pkill -f "Srz Clipboard" 2>/dev/null || true
sleep 2

# Remove from Applications
if [ -d "/Applications/Srz Clipboard.app" ]; then
    rm -rf "/Applications/Srz Clipboard.app"
    echo "✅ Removed from Applications"
fi

# Remove LaunchAgent if exists
LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.sohag.srz-clipboard.plist"
if [ -f "$LAUNCH_AGENT" ]; then
    launchctl unload "$LAUNCH_AGENT" 2>/dev/null || true
    rm -f "$LAUNCH_AGENT"
    echo "✅ Removed auto-start configuration"
fi

echo "✅ Srz Clipboard uninstalled successfully!"
