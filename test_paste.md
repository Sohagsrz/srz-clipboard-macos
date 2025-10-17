# 🧪 **Paste Functionality Test Guide**

## **How to Test the Windows-like Clipboard Paste:**

### **Step 1: Grant Permissions**
1. **Open System Preferences** → **Security & Privacy** → **Privacy**
2. **Add "Srz Clipboard"** to these sections:
   - **Accessibility** (for `Cmd+Alt+V` hotkey)
   - **AppleScript** (for direct text pasting)
3. **Restart the app** after granting permissions

### **Step 2: Test Basic Paste**
1. **Open TextEdit** (or any text editor)
2. **Click the menu bar icon** (📋) to open the floating panel
3. **Click any text item** in the history
4. **Check if text appears** in TextEdit's input field

### **Step 3: Test with Different Apps**
Try pasting into:
- **Safari** (address bar or text fields)
- **VS Code** (editor)
- **Terminal** (command line)
- **Notes** app
- **Any text input field**

### **Step 4: Debug Information**
The app now prints debug messages to help troubleshoot:
- `🎯 Pasting item X: [text preview]...`
- `📋 Starting paste operation...`
- `🎯 Attempting simple AppleScript paste...`
- `✅ Simple AppleScript executed successfully` or `❌ AppleScript error: [error]`
- `📋 Using CGEvent simulation with delay`
- `✅ Cmd+V simulated`

### **Step 5: Check Console Logs**
If paste still doesn't work:
1. **Open Console.app**
2. **Search for "Srz Clipboard"**
3. **Look for error messages** when you click text items

### **Expected Behavior:**
- ✅ **Click text** → **Text appears in focused app**
- ✅ **Works with any application**
- ✅ **Handles special characters** (quotes, newlines, etc.)
- ✅ **Fallback methods** if AppleScript fails

### **Troubleshooting:**
- **No text appears**: Check permissions in System Preferences
- **AppleScript errors**: Try different applications
- **CGEvent fails**: Check Accessibility permissions
- **App not responding**: Restart the app after granting permissions

### **Test Commands:**
You can also test via the command interface:
- Type `paste 0` to paste the first item
- Type `paste 1` to paste the second item
- Type `help` to see all available commands

---

**🎯 The paste functionality should now work exactly like Windows clipboard - click to paste into any software's input field!**
