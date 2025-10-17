# 🧪 **Simple Paste Test Script**

## **Step-by-Step Testing Guide**

### **1. Grant Permissions First**
```bash
# Open System Preferences → Security & Privacy → Privacy → Accessibility
# Add "Srz Clipboard" to the list and enable it
```

### **2. Test the Paste Functionality**

#### **Method 1: Manual Test**
1. **Open TextEdit** (Applications → TextEdit)
2. **Click in the text area** to focus it
3. **Press Cmd+Alt+V** to open the floating panel
4. **Click any text item** in the history
5. **Check if text appears** in TextEdit

#### **Method 2: Command Line Test**
1. **Open Terminal**
2. **Press Cmd+Alt+V** to open the floating panel
3. **Type `paste 0`** in the command field
4. **Press Enter**
5. **Check if text appears** in Terminal

### **3. Debug Information**

Open **Console.app** (Applications → Utilities → Console) and search for "Srz Clipboard" to see debug messages:

#### **✅ Success Messages:**
```
🎯 Pasting item 0: Hello World...
✅ Text copied to clipboard
🎯 Performing paste operation...
✅ Paste command sent
```

#### **❌ Error Messages:**
```
❌ Accessibility permissions not granted
❌ Failed to create CGEventSource
❌ Failed to create CGEvent
```

### **4. Alternative Applications to Test**

Try pasting into these applications:
- **TextEdit** (most compatible)
- **Notes** app
- **Safari** (address bar)
- **Terminal** (command line)
- **VS Code** (if installed)

### **5. Troubleshooting**

If paste still doesn't work:

1. **Check Accessibility permissions** are granted
2. **Restart the app** after granting permissions
3. **Try different applications**
4. **Check Console.app** for error messages
5. **Test manual Cmd+V** to ensure clipboard works

### **6. Expected Behavior**

When working correctly:
- ✅ **Click text item** → **Text appears in focused app**
- ✅ **Works with most text editors**
- ✅ **Handles special characters**
- ✅ **Fast response** (< 1 second)

---

**💡 The paste should work exactly like Windows clipboard - click to paste into any software!**
