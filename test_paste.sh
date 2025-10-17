#!/bin/bash

echo "🧪 Testing Srz Clipboard Paste Functionality"
echo "=============================================="

# Check if app is running
if pgrep -f "Srz Clipboard" > /dev/null; then
    echo "✅ Srz Clipboard app is running"
else
    echo "❌ Srz Clipboard app is not running"
    exit 1
fi

# Check accessibility permissions
echo ""
echo "🔍 Checking Accessibility Permissions..."
if sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "SELECT * FROM access WHERE service='kTCCServiceAccessibility' AND client='sohag.app.Srz-Clipboard';" 2>/dev/null | grep -q "1"; then
    echo "✅ Accessibility permissions granted"
else
    echo "❌ Accessibility permissions NOT granted"
    echo "📋 Please go to System Preferences → Security & Privacy → Privacy → Accessibility"
    echo "📋 Add 'Srz Clipboard' to the list and enable it"
fi

echo ""
echo "🧪 Test Instructions:"
echo "1. Open TextEdit (Applications → TextEdit)"
echo "2. Click in the text area to focus it"
echo "3. Press Cmd+Alt+V to open the floating panel"
echo "4. Click any text item in the history"
echo "5. Check if text appears in TextEdit"
echo ""
echo "🔍 Debug Information:"
echo "- Open Console.app (Applications → Utilities → Console)"
echo "- Search for 'Srz Clipboard'"
echo "- Look for paste-related messages"
echo ""
echo "📋 Expected Success Messages:"
echo "🎯 Pasting item 0: [text]..."
echo "✅ Text copied to clipboard"
echo "🎯 Performing paste operation..."
echo "✅ Paste command sent"
echo ""
echo "❌ Common Error Messages:"
echo "❌ Accessibility permissions not granted"
echo "❌ Failed to create CGEventSource"
echo "❌ Failed to create CGEvent"
