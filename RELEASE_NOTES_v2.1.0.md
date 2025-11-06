# Srz Clipboard v2.1.0 Release Notes

## 🚀 What's New

### ✨ **Improved Paste Reliability**
- **Removed AppleScript dependency**: Now uses pure Swift/Foundation with CGEvent for more reliable pasting
- **Enhanced app activation**: Better focus management when pasting into target applications
- **Improved diagnostics**: Better logging to help troubleshoot paste issues

### 🖼️ **Image Paste Support**
- **Full image paste functionality**: Click image items in history to paste them directly
- **PNG/TIFF support**: Automatic format detection and conversion
- **Image clipboard compatibility**: Works with all image types supported by macOS

### 🔧 **Technical Improvements**
- **Pure Swift implementation**: No AppleScript dependencies, cleaner codebase
- **Better permission handling**: Streamlined Accessibility permission prompts
- **Enhanced error handling**: More informative error messages and fallbacks

## 🐛 Bug Fixes

- Fixed paste not working when clicking items from filtered/search results
- Fixed index mapping issues when using pinned items
- Improved panel focus management for better paste reliability

## ⚠️ Important Notes

### **Accessibility Permission Required**
For automatic pasting to work, you **must** grant Accessibility permissions:

1. Go to **System Settings** → **Privacy & Security** → **Accessibility**
2. Find **"Srz Clipboard"** in the list
3. **Enable the toggle**

Without this permission, the app will show a notification asking you to manually press Cmd+V.

### **Installation**
- Download the DMG or PKG installer from the releases page
- Drag the app to Applications folder (DMG) or run the installer (PKG)
- Grant Accessibility permissions when prompted
- The app will start automatically in the background

## 📋 Full Changelog

### v2.1.0 (Current)
- Removed AppleScript usage, now pure Swift/Foundation
- Added image paste support (PNG/TIFF)
- Improved paste reliability with better app activation
- Fixed index mapping for filtered/search results
- Enhanced diagnostics and error handling
- Updated version to 2.1.0

### v2.0.0
- Initial public release
- Triple-method paste system
- Smart content intelligence
- Workflow automation
- Auto-start functionality

## 🙏 Thank You!

Thank you for using Srz Clipboard! We hope these improvements make your clipboard experience even better.

**Created by:** Md Sohag Islam  
**GitHub:** https://github.com/Sohagsrz/srz-clipboard-macos  
**Support:** Open an issue on GitHub for bugs or feature requests

