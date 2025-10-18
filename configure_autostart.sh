#!/bin/bash

# Enhanced Auto-Start Configuration for Srz Clipboard
# Ensures the app always runs in background and starts on system restart

echo "🚀 Configuring Srz Clipboard for Auto-Start"
echo "==========================================="

# Create LaunchAgent directory
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
LAUNCH_AGENT_FILE="$LAUNCH_AGENT_DIR/com.sohag.srz-clipboard.plist"

echo "📁 Creating LaunchAgent directory..."
mkdir -p "$LAUNCH_AGENT_DIR"

echo "📝 Creating enhanced LaunchAgent configuration..."

# Create comprehensive LaunchAgent plist
cat > "$LAUNCH_AGENT_FILE" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Basic Configuration -->
    <key>Label</key>
    <string>com.sohag.srz-clipboard</string>
    
    <!-- Program to run -->
    <key>ProgramArguments</key>
    <array>
        <string>/Applications/Srz Clipboard.app/Contents/MacOS/Srz Clipboard</string>
    </array>
    
    <!-- Auto-start Configuration -->
    <key>RunAtLoad</key>
    <true/>
    
    <!-- Keep the app running -->
    <key>KeepAlive</key>
    <true/>
    
    <!-- Process Type -->
    <key>ProcessType</key>
    <string>Background</string>
    
    <!-- Environment Variables -->
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
    
    <!-- Logging Configuration -->
    <key>StandardOutPath</key>
    <string>/tmp/srz-clipboard.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/srz-clipboard-error.log</string>
    
    <!-- Resource Limits -->
    <key>SoftResourceLimits</key>
    <dict>
        <key>NumberOfFiles</key>
        <integer>1024</integer>
    </dict>
    
    <!-- Restart Configuration -->
    <key>ThrottleInterval</key>
    <integer>10</integer>
    
    <!-- Network Configuration -->
    <key>NetworkState</key>
    <string>Any</string>
    
    <!-- User Session -->
    <key>LimitLoadToSessionType</key>
    <string>Aqua</string>
    
    <!-- Disable App Nap -->
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

echo "🔐 Setting proper permissions..."
chmod 644 "$LAUNCH_AGENT_FILE"

echo "🚀 Loading LaunchAgent..."
# Unload first if exists
launchctl unload "$LAUNCH_AGENT_FILE" 2>/dev/null || true
sleep 1

# Load the LaunchAgent
launchctl load "$LAUNCH_AGENT_FILE"

echo "✅ LaunchAgent configured successfully!"

# Verify the configuration
echo ""
echo "🔍 Verifying configuration..."
if launchctl list | grep -q "com.sohag.srz-clipboard"; then
    echo "✅ LaunchAgent is loaded and running"
else
    echo "⚠️  LaunchAgent may not be loaded properly"
fi

# Check if app is running
if pgrep -f "Srz Clipboard" > /dev/null; then
    echo "✅ Srz Clipboard is currently running"
else
    echo "🔄 Starting Srz Clipboard..."
    launchctl start com.sohag.srz-clipboard
    sleep 2
    if pgrep -f "Srz Clipboard" > /dev/null; then
        echo "✅ Srz Clipboard started successfully"
    else
        echo "❌ Failed to start Srz Clipboard"
    fi
fi

echo ""
echo "🎯 Auto-Start Configuration Complete!"
echo "====================================="
echo ""
echo "✅ The app will now:"
echo "   • Start automatically when you log in"
echo "   • Restart automatically if it crashes"
echo "   • Run in the background continuously"
echo "   • Start after system restart"
echo ""
echo "📋 Configuration Details:"
echo "   • LaunchAgent: $LAUNCH_AGENT_FILE"
echo "   • Log file: /tmp/srz-clipboard.log"
echo "   • Error log: /tmp/srz-clipboard-error.log"
echo ""
echo "🔧 Management Commands:"
echo "   • Start: launchctl start com.sohag.srz-clipboard"
echo "   • Stop: launchctl stop com.sohag.srz-clipboard"
echo "   • Restart: launchctl unload && launchctl load $LAUNCH_AGENT_FILE"
echo "   • Status: launchctl list | grep srz-clipboard"
echo ""
echo "🎉 Srz Clipboard is now configured for persistent background operation!"
