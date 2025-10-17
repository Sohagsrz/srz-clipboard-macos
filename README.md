# 🚀 Srz Clipboard

A powerful macOS clipboard manager inspired by Windows clipboard functionality, built with SwiftUI.

![Srz Clipboard](https://img.shields.io/badge/macOS-15.6+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## ✨ Features

### 🎯 **Core Functionality**
- **Windows-like Clipboard History** - Press `Cmd+Alt+V` to show floating panel
- **Smart Content Intelligence** - Auto-tagging, language detection, link extraction
- **Triple-Method Paste System** - Guaranteed paste functionality with fallbacks
- **Command-Line Interface** - Powerful text-based commands for advanced users
- **Pin & Favorite System** - Keep important items accessible
- **Search & Filter** - Find items quickly with fuzzy search and regex support

### 🔧 **Advanced Features**
- **Export/Import** - Backup and restore clipboard history
- **Theme Support** - Dark/light mode with custom themes
- **Smart Notifications** - Clear user guidance for paste operations
- **Performance Optimized** - Release build with optimizations
- **Privacy First** - All data stays local on your Mac

## 🚀 Quick Start

### Installation
1. **Download** the latest release DMG file
2. **Mount** the DMG and drag the app to Applications
3. **Launch** the app (appears in menu bar)
4. **Grant** Accessibility permissions when prompted
5. **Press** `Cmd+Alt+V` to open the floating clipboard panel

### Basic Usage
- **Copy text/images** as usual - automatically added to history
- **Press `Cmd+Alt+V`** - show clipboard history floating panel
- **Click any item** - paste it into focused application
- **Use commands** - type commands in the panel for advanced operations

## 🎮 Command Interface

Type commands in the floating panel:

### **Core Commands**
```bash
help                    # Show all available commands
pin 0                   # Pin the first item
unpin 0                 # Unpin the first item
favorite 0               # Mark item as favorite
delete 0                 # Delete item from history
clear                    # Clear all non-pinned items
```

### **Search & Filter**
```bash
search "keyword"         # Fuzzy search clipboard history
search re:regex          # Regex search
type:text                # Filter by content type
pinned:true              # Show only pinned items
```

### **Content Intelligence**
```bash
auto-tag                 # Auto-tag all items
summarize 0              # Summarize item content
detect-lang 0            # Detect language of item
extract-links 0          # Extract links from item
shorten-url 0            # Shorten URLs in item
```

### **Data Management**
```bash
export history           # Export to JSON
import history           # Import from JSON
stats 0                  # Show item statistics
log show 10              # Show recent actions
```

## 🔧 System Requirements

- **macOS:** 15.6 or later
- **Architecture:** Apple Silicon (ARM64) and Intel (x86_64)
- **Memory:** 50MB RAM usage
- **Storage:** 1MB disk space

## 🛡️ Permissions

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

## 🔒 Privacy & Security

- **Local Storage** - All clipboard data stays on your Mac
- **No Cloud Sync** - Privacy-first approach
- **Secure Permissions** - Only requests necessary system access
- **No Data Transmission** - No external data sharing

## 🐛 Troubleshooting

### **Paste doesn't work automatically**
- **Solution:** Grant Accessibility permissions and restart the app
- **Fallback:** You'll get notifications guiding you to press Cmd+V

### **Floating panel doesn't appear**
- **Solution:** Check Accessibility permissions
- **Alternative:** Use the menu bar icon to access history

### **Hotkey conflicts**
- **Solution:** Change hotkey in Settings or disable conflicting apps

## 📦 Download

### **Latest Release: v2.0.0**
- **DMG File:** [Srz_Clipboard_v2.0.0.dmg](Srz_Clipboard_v2.0.0.dmg) (628KB)
- **Checksum:** [Srz_Clipboard_v2.0.0.dmg.sha256](Srz_Clipboard_v2.0.0.dmg.sha256)

### **Verification**
```bash
# Verify download integrity
shasum -a 256 Srz_Clipboard_v2.0.0.dmg
```

## 🤝 Contributing

Contributions are welcome! Please feel free to:

- **Submit Issues** - Bug reports and feature requests
- **Create Pull Requests** - Code improvements and new features
- **Join Discussions** - Share ideas and get help
- **Star the Repository** - Show your support

### **Development Setup**
1. Clone the repository
2. Open `Srz Clipboard.xcodeproj` in Xcode
3. Build and run the project
4. Make your changes and test thoroughly

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Credits

- **Developer:** Md Sohag Islam
- **Framework:** SwiftUI, AppKit
- **Icons:** SF Symbols
- **Inspiration:** Windows Clipboard Manager

## 📞 Support

- **GitHub Issues** - Bug reports and feature requests
- **GitHub Discussions** - Community support and ideas
- **Built-in Help** - Type `help` in the command interface

---

**🎉 Thank you for using Srz Clipboard!**

**Made with ❤️ for macOS users**