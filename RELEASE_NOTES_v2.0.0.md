# 🚀 Srz Clipboard v2.0.0 - Release Notes

## 📦 **Release Package**
- **DMG File:** `Srz_Clipboard_v2.0.0.dmg` (628KB)
- **Checksum:** `Srz_Clipboard_v2.0.0.dmg.sha256`
- **Version:** 2.0.0
- **Build:** Release (Optimized)

## ✨ **What's New in v2.0.0**

### 🎯 **Core Features**
- **Windows-like Clipboard History** - Press `Cmd+Alt+V` to show floating panel
- **Smart Content Intelligence** - Auto-tagging, language detection, link extraction
- **Triple-Method Paste System** - Guaranteed paste functionality
- **Command-Line Interface** - Powerful text-based commands
- **Pin & Favorite System** - Keep important items accessible
- **Search & Filter** - Find items quickly with fuzzy search and regex

### 🔧 **Technical Improvements**
- **Reliable Paste Functionality** - Multiple fallback methods ensure it always works
- **Enhanced UI/UX** - Modern SwiftUI interface with dark/light themes
- **Smart Notifications** - Clear user guidance for paste operations
- **Export/Import** - Backup and restore clipboard history
- **Performance Optimized** - Release build with optimizations

### 🛡️ **Security & Privacy**
- **Local Storage** - All data stays on your Mac
- **No Cloud Sync** - Privacy-first approach
- **Secure Permissions** - Only requests necessary system access

## 📋 **System Requirements**
- **macOS:** 15.6 or later
- **Architecture:** Apple Silicon (ARM64) and Intel (x86_64)
- **Memory:** 50MB RAM usage
- **Storage:** 1MB disk space

## 🚀 **Installation Instructions**

### **Method 1: DMG Installation (Recommended)**
1. Download `Srz_Clipboard_v2.0.0.dmg`
2. Double-click the DMG file to mount it
3. Drag "Srz Clipboard" to your Applications folder
4. Launch the app from Applications
5. Grant Accessibility permissions when prompted

### **Method 2: Manual Installation**
1. Download the DMG file
2. Verify checksum: `shasum -a 256 Srz_Clipboard_v2.0.0.dmg`
3. Mount and install as above

## 🎮 **Quick Start Guide**

### **1. First Launch**
- The app will appear in your menu bar
- Click the clipboard icon to access settings
- Press `Cmd+Alt+V` to open the floating panel

### **2. Basic Usage**
- **Copy text** - Automatically added to history
- **Press `Cmd+Alt+V`** - Show floating panel
- **Click any item** - Paste into focused app
- **Use commands** - Type commands in the panel

### **3. Essential Commands**
```
help                    # Show all commands
pin 0                   # Pin item 0
search "keyword"        # Search history
clear                   # Clear non-pinned items
export history          # Export to JSON
```

## 🔧 **Permissions Setup**

### **Required Permissions:**
1. **Accessibility** - For automatic paste functionality
   - Go to System Settings → Privacy & Security → Accessibility
   - Add "Srz Clipboard" and enable it

2. **Automation** - For AppleScript paste fallback
   - Go to System Settings → Privacy & Security → Automation
   - Enable "System Events" for Srz Clipboard

### **Optional Permissions:**
- **Notifications** - For paste confirmations
- **Full Disk Access** - For advanced file operations

## 🐛 **Known Issues & Workarounds**

### **Issue: Paste doesn't work automatically**
- **Solution:** Grant Accessibility permissions and restart the app
- **Fallback:** You'll get notifications guiding you to press Cmd+V

### **Issue: Floating panel doesn't appear**
- **Solution:** Check Accessibility permissions
- **Alternative:** Use the menu bar icon to access history

### **Issue: Hotkey conflicts**
- **Solution:** Change hotkey in Settings or disable conflicting apps

## 🔄 **Upgrade from Previous Versions**

### **From v1.x:**
- Settings and history will be preserved
- New features will be available immediately
- No data migration required

## 📞 **Support & Feedback**

### **Getting Help:**
- Check the built-in help: Type `help` in the command interface
- Review troubleshooting guides in the app
- Check Console.app for error messages

### **Reporting Issues:**
- Use GitHub Issues for bug reports
- Include macOS version and app logs
- Describe steps to reproduce the problem

### **Feature Requests:**
- Submit via GitHub Discussions
- Vote on existing feature requests
- Contribute to the project

## 📄 **License**
This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 **Credits**
- **Developer:** Md Sohag Islam
- **Framework:** SwiftUI, AppKit
- **Icons:** SF Symbols
- **Inspiration:** Windows Clipboard Manager

---

**🎉 Thank you for using Srz Clipboard!**

**Download:** [Srz_Clipboard_v2.0.0.dmg](Srz_Clipboard_v2.0.0.dmg)  
**Checksum:** [Srz_Clipboard_v2.0.0.dmg.sha256](Srz_Clipboard_v2.0.0.dmg.sha256)
