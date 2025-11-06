//
//  ContentView.swift
//  Srz Clipboard
//
//  Created by Md Sohag Islam on 18/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var clipboardManager = ClipboardManager()
    @StateObject private var hotkeyManager = HotkeyManager()
    @StateObject private var floatingPanelManager = FloatingPanelManager()
    @State private var commandParser: CommandParser?
    @State private var isDarkMode = false
    @State private var commandResult = ""
    @State private var showCommandResult = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with theme toggle
            HStack {
                Text("Srz Clipboard")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    let cursorPosition = NSEvent.mouseLocation
                    floatingPanelManager.showPanel(at: cursorPosition)
                }) {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    isDarkMode.toggle()
                    toggleTheme()
                }) {
                    Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Command input
            HStack {
                Text(">")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .monospaced))
                
                TextField("Type command or search...", text: $clipboardManager.commandText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(.body, design: .monospaced))
                    .onSubmit {
                        executeCommand()
                    }
                
                if !clipboardManager.commandText.isEmpty {
                    Button("Run") {
                        executeCommand()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Command result
            if showCommandResult && !commandResult.isEmpty {
                ScrollView {
                    Text(commandResult)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .frame(maxHeight: 100)
                .background(Color(NSColor.controlBackgroundColor))
                
                Divider()
            }
            
            // Clipboard history list
            if clipboardManager.clipboardHistory.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    
                    Text("No clipboard history yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Copy some text to start building your clipboard history")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(Array(clipboardManager.clipboardHistory.enumerated()), id: \.element.id) { index, item in
                            ClipboardItemView(
                                item: item,
                                index: index,
                                isSelected: index == clipboardManager.selectedIndex
                            ) {
                                clipboardManager.pasteItem(at: index)
                            } onAppend: {
                                clipboardManager.appendItem(at: index)
                            } onDelete: {
                                clipboardManager.deleteItem(at: index)
                            } onPin: {
                                clipboardManager.pinItem(at: index)
                            } onFavorite: {
                                clipboardManager.favoriteItem(at: index)
                            } onLock: {
                                clipboardManager.lockItem(at: index)
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // Footer with status
            HStack {
                Text("\(clipboardManager.clipboardHistory.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("⌘⌥V to show • Enter=paste • Space=preview • Del=delete • Esc=close")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 500, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
                    .onAppear {
                        setupHotkey()
                        loadTheme()
                        commandParser = CommandParser(clipboardManager: clipboardManager)
                        floatingPanelManager.setClipboardManager(clipboardManager)
                        // Ensure permissions are requested early so paste works seamlessly
                        clipboardManager.ensurePermissions()
                    }
        .onKeyPress(.escape) {
            clipboardManager.hideHistory()
            return .handled
        }
        .onKeyPress(.return) {
            if clipboardManager.selectedIndex < clipboardManager.clipboardHistory.count {
                clipboardManager.pasteItem(at: clipboardManager.selectedIndex)
            }
            return .handled
        }
        .onKeyPress(.space) {
            if clipboardManager.selectedIndex < clipboardManager.clipboardHistory.count {
                let result = commandParser?.parseCommand("preview \(clipboardManager.selectedIndex)") ?? "❌ Command parser not initialized"
                commandResult = result
                showCommandResult = true
            }
            return .handled
        }
        .onKeyPress(.delete) {
            if clipboardManager.selectedIndex < clipboardManager.clipboardHistory.count {
                clipboardManager.deleteItem(at: clipboardManager.selectedIndex)
            }
            return .handled
        }
    }
    
    private func executeCommand() {
        let command = clipboardManager.commandText.trimmingCharacters(in: .whitespacesAndNewlines)
        clipboardManager.commandText = ""
        
        if command.isEmpty {
            return
        }
        
        let result = commandParser?.parseCommand(command) ?? "❌ Command parser not initialized"
        commandResult = result
        showCommandResult = true
        
        // Hide result after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showCommandResult = false
        }
    }
    
                private func setupHotkey() {
                    print("Setting up hotkey action")
                    hotkeyManager.setHotkeyAction {
                        print("Hotkey action triggered!")
                        let cursorPosition = NSEvent.mouseLocation
                        print("Cursor position: \(cursorPosition)")
                        floatingPanelManager.showPanel(at: cursorPosition)
                    }
                }
    
    private func toggleTheme() {
        if isDarkMode {
            NSApp.appearance = NSAppearance(named: .darkAqua)
        } else {
            NSApp.appearance = NSAppearance(named: .aqua)
        }
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
    }
    
    private func loadTheme() {
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if isDarkMode {
            NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }
}

struct ClipboardItemView: View {
    let item: ClipboardItem
    let index: Int
    let isSelected: Bool
    let onPaste: () -> Void
    let onAppend: () -> Void
    let onDelete: () -> Void
    let onPin: () -> Void
    let onFavorite: () -> Void
    let onLock: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Index number
            Text("\(index)")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .trailing)
            
            // Type indicator
            Text(typeIcon)
                .font(.caption)
                .frame(width: 20)
            
            // Content preview
            VStack(alignment: .leading, spacing: 2) {
                Text(item.preview)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                            HStack {
                                Text(formatSize(item.size))
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                                
                                Text(item.timestamp, style: .relative)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                                
                                // Smart tags
                                ForEach(item.tags.prefix(3), id: \.self) { tag in
                                    Text(tag)
                                        .font(.system(.caption2, design: .monospaced))
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(3)
                                }
                                
                                if item.isPinned {
                                    Text("⭐")
                                        .font(.caption)
                                }
                                if item.isFavorite {
                                    Text("❤️")
                                        .font(.caption)
                                }
                                if item.isLocked {
                                    Text("🔒")
                                        .font(.caption)
                                }
                            }
            }
            
            Spacer()
            
            // Action buttons (shown on hover)
            if isHovered {
                HStack(spacing: 4) {
                    Button(action: onPaste) {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.blue)
                    
                    Button(action: onAppend) {
                        Image(systemName: "plus")
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.green)
                    
                    Button(action: onPin) {
                        Image(systemName: item.isPinned ? "pin.fill" : "pin")
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.orange)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isSelected ? Color.accentColor.opacity(0.3) : (isHovered ? Color(NSColor.controlBackgroundColor) : Color.clear))
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            onPaste()
        }
    }
    
    private var typeIcon: String {
        switch item.type {
        case .text: return "📄"
        case .image: return "🖼️"
        case .html: return "🌐"
        case .snippet: return "📋"
        }
    }
    
    private func formatSize(_ size: Int) -> String {
        if size < 1024 {
            return "\(size)B"
        } else if size < 1024 * 1024 {
            return "\(size / 1024)KB"
        } else {
            return "\(size / (1024 * 1024))MB"
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ClipboardManager())
        .environmentObject(HotkeyManager())
}
