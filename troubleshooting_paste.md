# 🔧 **Paste Functionality Troubleshooting Guide**

## **Issue: Text not appearing in Notepad/TextEdit when clicking clipboard items**

### **🔍 Step 1: Check Permissions**

The most common cause is missing macOS permissions. Follow these steps:

1. **Open System Preferences** → **Security & Privacy** → **Privacy**
2. **Click on "Accessibility"** in the left sidebar
3. **Look for "Srz Clipboard"** in the list
4. **If not there**: Click the **"+"** button and add the app
5. **If there but unchecked**: Check the box to enable it
6. **Restart the app** after granting permissions

### **🔍 Step 2: Check Console Logs**

The app now provides detailed debug information:

1. **Open Console.app** (Applications → Utilities → Console)
2. **Search for "Srz Clipboard"** in the search bar
3. **Look for these messages** when you click a text item:

#### **✅ Success Messages:**
```
🎯 Pasting item 0: Hello World...
✅ Clipboard updated successfully
📋 Starting paste operation...
🎯 Attempting CGEvent paste...
✅ Accessibility permissions granted
✅ CGEvent posted successfully
✅ Text pasted using CGEvent
```

#### **❌ Error Messages:**
```
❌ Accessibility permissions not granted
📋 Please go to System Preferences > Security & Privacy > Privacy > Accessibility
❌ Failed to create CGEventSource
❌ Failed to create CGEvent
❌ Clipboard update failed
❌ All paste methods failed
```

### **🔍 Step 3: Test Different Applications**

Try pasting into different apps to isolate the issue:

- **TextEdit** (should work)
- **Notes** app
- **Safari** (address bar)
- **Terminal** (command line)
- **VS Code** (if installed)

### **🔍 Step 4: Manual Test**

Test if the clipboard itself is working:

1. **Copy some text** manually (Cmd+C)
2. **Open TextEdit**
3. **Press Cmd+V** manually
4. **If this works**: The issue is with the app's paste mechanism
5. **If this doesn't work**: There's a system-level issue

### **🔍 Step 5: Alternative Testing Methods**

#### **Method 1: Command Line Test**
1. **Open the floating panel** (Cmd+Alt+V)
2. **Type `paste 0`** in the command field
3. **Press Enter**
4. **Check if text appears** in the focused app

#### **Method 2: Direct Clipboard Test**
1. **Copy some text** to clipboard manually
2. **Open floating panel** (Cmd+Alt+V)
3. **Click any text item**
4. **Check if the same text appears** in the focused app

### **🔧 Common Solutions**

#### **Solution 1: Grant Accessibility Permissions**
- **Most common fix**
- **Required for CGEvent simulation**
- **System Preferences** → **Security & Privacy** → **Privacy** → **Accessibility**

#### **Solution 2: Restart the App**
- **After granting permissions**
- **Quit the app completely**
- **Reopen from Applications folder**

#### **Solution 3: Check App Focus**
- **Make sure the target app is focused** (click on it)
- **Then try pasting from clipboard panel**

#### **Solution 4: Try Different Apps**
- **Some apps may block programmatic paste**
- **Try TextEdit first** (most compatible)
- **Then try other applications**

### **🚨 If Nothing Works**

#### **Check System Requirements:**
- **macOS 10.15+** (Catalina or later)
- **Accessibility permissions** granted
- **App not blocked** by security software

#### **Reset Permissions:**
1. **Remove "Srz Clipboard"** from Accessibility list
2. **Restart the app**
3. **Grant permissions again** when prompted

#### **Check for Conflicts:**
- **Other clipboard managers** running
- **Security software** blocking the app
- **System integrity protection** issues

### **📋 Debug Information to Share**

If the issue persists, please share:

1. **Console log messages** (from Console.app)
2. **macOS version** (Apple menu → About This Mac)
3. **Which applications** you're trying to paste into
4. **Whether manual Cmd+V works** in those apps

### **🎯 Expected Behavior**

When working correctly:
- ✅ **Click text item** → **Text appears in focused app**
- ✅ **Works with TextEdit, Notes, Safari, Terminal, etc.**
- ✅ **Handles special characters** (quotes, newlines, etc.)
- ✅ **Automatic fallback** if one method fails

---

**💡 The paste functionality should work exactly like Windows clipboard - click to paste into any software's input field!**
