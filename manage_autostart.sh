#!/bin/bash

# Srz Clipboard Auto-Start Management Script
# Provides easy control over the app's background operation

LAUNCH_AGENT_FILE="$HOME/Library/LaunchAgents/com.sohag.srz-clipboard.plist"

show_help() {
    echo "🚀 Srz Clipboard Auto-Start Manager"
    echo "=================================="
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  enable     - Enable auto-start (app starts on login)"
    echo "  disable    - Disable auto-start"
    echo "  restart    - Restart the app"
    echo "  status     - Show current status"
    echo "  logs       - Show app logs"
    echo "  help       - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 enable    # Enable auto-start"
    echo "  $0 status    # Check if app is running"
    echo "  $0 restart   # Restart the app"
}

enable_autostart() {
    echo "🚀 Enabling Srz Clipboard auto-start..."
    
    # Create LaunchAgent directory
    mkdir -p "$HOME/Library/LaunchAgents"
    
    # Create LaunchAgent plist
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
    
    chmod 644 "$LAUNCH_AGENT_FILE"
    
    # Load the LaunchAgent
    launchctl load "$LAUNCH_AGENT_FILE" 2>/dev/null || true
    
    echo "✅ Auto-start enabled successfully!"
    echo "   • App will start automatically when you log in"
    echo "   • App will restart automatically if it crashes"
    echo "   • App runs continuously in the background"
}

disable_autostart() {
    echo "🛑 Disabling Srz Clipboard auto-start..."
    
    # Unload LaunchAgent
    launchctl unload "$LAUNCH_AGENT_FILE" 2>/dev/null || true
    
    # Remove LaunchAgent file
    rm -f "$LAUNCH_AGENT_FILE"
    
    # Stop the app
    pkill -f "Srz Clipboard" 2>/dev/null || true
    
    echo "✅ Auto-start disabled successfully!"
    echo "   • App will not start automatically"
    echo "   • You can still start it manually from Applications"
}

restart_app() {
    echo "🔄 Restarting Srz Clipboard..."
    
    # Stop the app
    pkill -f "Srz Clipboard" 2>/dev/null || true
    sleep 2
    
    # Restart via LaunchAgent if enabled
    if [ -f "$LAUNCH_AGENT_FILE" ]; then
        launchctl unload "$LAUNCH_AGENT_FILE" 2>/dev/null || true
        sleep 1
        launchctl load "$LAUNCH_AGENT_FILE" 2>/dev/null || true
        echo "✅ App restarted via LaunchAgent"
    else
        # Start manually
        open -a "Srz Clipboard" 2>/dev/null || true
        echo "✅ App restarted manually"
    fi
}

show_status() {
    echo "📊 Srz Clipboard Status"
    echo "======================"
    
    # Check if app is installed
    if [ -d "/Applications/Srz Clipboard.app" ]; then
        echo "✅ Application installed: /Applications/Srz Clipboard.app"
        
        # Check app version
        APP_VERSION=$(defaults read "/Applications/Srz Clipboard.app/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "Unknown")
        echo "📱 App version: $APP_VERSION"
    else
        echo "❌ Application not found in /Applications/"
        return 1
    fi
    
    # Check if running
    if pgrep -f "Srz Clipboard" > /dev/null; then
        echo "✅ Application is running"
        PROCESS_ID=$(pgrep -f "Srz Clipboard")
        echo "🆔 Process ID: $PROCESS_ID"
    else
        echo "⚠️  Application is not running"
    fi
    
    # Check LaunchAgent
    if [ -f "$LAUNCH_AGENT_FILE" ]; then
        echo "✅ Auto-start enabled (LaunchAgent configured)"
        if launchctl list | grep -q "com.sohag.srz-clipboard"; then
            echo "✅ LaunchAgent is loaded and active"
        else
            echo "⚠️  LaunchAgent file exists but not loaded"
        fi
    else
        echo "❌ Auto-start disabled (no LaunchAgent)"
    fi
    
    # Check Accessibility permissions
    if osascript -e 'tell application "System Events" to return UI elements enabled' &>/dev/null; then
        echo "✅ Accessibility permissions granted"
    else
        echo "⚠️  Accessibility permissions not granted"
        echo "   Go to System Settings > Privacy & Security > Accessibility"
    fi
    
    echo ""
    echo "🎯 Summary:"
    if pgrep -f "Srz Clipboard" > /dev/null && [ -f "$LAUNCH_AGENT_FILE" ]; then
        echo "   Status: ✅ Running with auto-start enabled"
    elif pgrep -f "Srz Clipboard" > /dev/null; then
        echo "   Status: ⚠️  Running but auto-start disabled"
    elif [ -f "$LAUNCH_AGENT_FILE" ]; then
        echo "   Status: ⚠️  Auto-start enabled but app not running"
    else
        echo "   Status: ❌ Not running and auto-start disabled"
    fi
}

show_logs() {
    echo "📋 Srz Clipboard Logs"
    echo "===================="
    
    if [ -f "/tmp/srz-clipboard.log" ]; then
        echo "📄 Application Log:"
        echo "------------------"
        tail -20 "/tmp/srz-clipboard.log"
    else
        echo "⚠️  No application log found"
    fi
    
    echo ""
    
    if [ -f "/tmp/srz-clipboard-error.log" ]; then
        echo "❌ Error Log:"
        echo "-------------"
        tail -20 "/tmp/srz-clipboard-error.log"
    else
        echo "✅ No error log found"
    fi
}

# Main script logic
case "${1:-help}" in
    "enable")
        enable_autostart
        ;;
    "disable")
        disable_autostart
        ;;
    "restart")
        restart_app
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs
        ;;
    "help"|*)
        show_help
        ;;
esac
