//
//  FloatingPanel.swift
//  Srz Clipboard
//
//  Created by Md Sohag Islam on 18/10/25.
//

import SwiftUI
import AppKit
import Combine

class FloatingPanelManager: ObservableObject {
    @Published var isVisible = false
    @Published var position: CGPoint = .zero
    @Published var currentTheme: AppTheme = .system
    @Published var hapticEnabled = true
    @Published var soundEnabled = false
    @Published var syncEnabled = false
    @Published var privacyMode = false
    
    private var panel: NSPanel?
    private var hostingView: NSHostingView<AnyView>?
    private var clipboardManager: ClipboardManager?
    
    func showPanel(at cursorPosition: CGPoint) {
        print("showPanel called with position: \(cursorPosition)")
        if panel == nil {
            print("Creating new panel")
            createPanel()
        }
        // Capture current frontmost app so we can paste into it later
        let frontBundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        clipboardManager?.setPreferredPasteTarget(frontBundleId)
        
        // Position panel near cursor but ensure it stays on screen
        let screenFrame = NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let panelSize = CGSize(width: 400, height: 500)
        
        var x = cursorPosition.x - panelSize.width / 2
        var y = cursorPosition.y - panelSize.height - 20
        
        // Keep panel on screen
        if x < 0 { x = 20 }
        if x + panelSize.width > screenFrame.width { x = screenFrame.width - panelSize.width - 20 }
        if y < 0 { y = cursorPosition.y + 20 }
        
        position = CGPoint(x: x, y: y)
        
        print("Panel position: \(position)")
        panel?.setFrameOrigin(position)
        panel?.orderFront(nil)
        isVisible = true
        
        print("Panel should be visible now")
        
        // Add haptic feedback
        if hapticEnabled {
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
        }
        
        // Add sound feedback
        if soundEnabled {
            NSSound.beep()
        }
    }
    
    func hidePanel() {
        panel?.orderOut(nil)
        isVisible = false
    }
    
    private func createPanel() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
            styleMask: [.nonactivatingPanel, .titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        panel.title = "Srz Clipboard"
        panel.level = .floating
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.canHide = false
        panel.backgroundColor = NSColor.clear
        
        // Create hosting view with environment objects
        let hostingView = NSHostingView(
            rootView: AnyView(
                FloatingPanelView(manager: self)
                    .environmentObject(clipboardManager ?? ClipboardManager())
                    .environmentObject(HotkeyManager())
            )
        )
        panel.contentView = hostingView
        
        self.panel = panel
        self.hostingView = hostingView
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        applyTheme()
    }
    
    func setClipboardManager(_ manager: ClipboardManager) {
        self.clipboardManager = manager
    }
    
    // Windows-like functionality
    func clearClipboardHistory() {
        clipboardManager?.clearHistory()
    }
    
    func clearClipboardKeepPinned() {
        clipboardManager?.clearHistoryKeepPinned()
    }
    
    func toggleSync() {
        syncEnabled.toggle()
        UserDefaults.standard.set(syncEnabled, forKey: "syncEnabled")
    }
    
    func togglePrivacyMode() {
        privacyMode.toggle()
        UserDefaults.standard.set(privacyMode, forKey: "privacyMode")
    }
    
    private func applyTheme() {
        switch currentTheme {
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        case .system:
            NSApp.appearance = nil
        case .minimal:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        case .blur:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }
}

enum AppTheme: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case minimal = "Minimal"
    case blur = "Blur"
    
    var displayName: String {
        return self.rawValue
    }
}

struct FloatingPanelView: View {
    @ObservedObject var manager: FloatingPanelManager
    @EnvironmentObject var clipboardManager: ClipboardManager
    @EnvironmentObject var hotkeyManager: HotkeyManager
    @State private var commandParser: CommandParser?
    @State private var searchText = ""
    @State private var selectedTag: String?
    @State private var showPinBar = true
    
    var filteredHistory: [ClipboardItem] {
        var items = clipboardManager.clipboardHistory
        
        // Filter by search
        if !searchText.isEmpty {
            items = items.filter { item in
                item.content.localizedCaseInsensitiveContains(searchText) ||
                item.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Filter by tag
        if let selectedTag = selectedTag {
            items = items.filter { $0.tags.contains(selectedTag) }
        }
        
        return items
    }
    
    var pinnedItems: [ClipboardItem] {
        clipboardManager.clipboardHistory.filter { $0.isPinned }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with controls
            headerView
            
            Divider()
            
            // Pin Bar (if enabled)
            if showPinBar && !pinnedItems.isEmpty {
                pinBarView
                Divider()
            }
            
            // Search and filters
            searchAndFiltersView
            
            Divider()
            
            // Content
            if filteredHistory.isEmpty {
                emptyStateView
            } else {
                historyListView
            }
            
            Divider()
            
            // Footer
            footerView
        }
        .background(backgroundView)
        .onAppear {
            commandParser = CommandParser(clipboardManager: clipboardManager)
        }
        .onKeyPress(.escape) {
            manager.hidePanel()
            return .handled
        }
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "doc.on.clipboard")
                .foregroundColor(.blue)
                .font(.system(size: 16, weight: .medium))
            
            Text("Clipboard History")
                .font(.headline)
                .fontWeight(.medium)
            
            Spacer()
            
            // Windows-like sync indicator
            if manager.syncEnabled {
                Image(systemName: "icloud.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
            }
            
            // Close button
            Button(action: {
                manager.hidePanel()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 20, height: 20)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var pinBarView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(pinnedItems.prefix(8).enumerated()), id: \.element.id) { index, item in
                    Button(action: {
                        if let originalIndex = clipboardManager.clipboardHistory.firstIndex(where: { $0.id == item.id }) {
                            clipboardManager.pasteItem(at: originalIndex)
                        }
                        manager.hidePanel()
                    }) {
                        VStack(spacing: 2) {
                            Text(item.preview)
                                .font(.system(.caption, design: .monospaced))
                                .lineLimit(1)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 2) {
                                ForEach(item.tags.prefix(2), id: \.self) { tag in
                                    Text(tag)
                                        .font(.system(.caption2, design: .monospaced))
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 2)
                                        .padding(.vertical, 1)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(2)
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(NSColor.controlBackgroundColor))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 60)
    }
    
    private var searchAndFiltersView: some View {
        VStack(spacing: 8) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search clipboard history...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(.body, design: .monospaced))
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor))
            )
            
            // Tag filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    Button("All") {
                        selectedTag = nil
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(selectedTag == nil ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                    )
                    .foregroundColor(selectedTag == nil ? .white : .primary)
                    
                    ForEach(Array(Set(clipboardManager.clipboardHistory.flatMap { $0.tags })).sorted(), id: \.self) { tag in
                        Button(tag) {
                            selectedTag = selectedTag == tag ? nil : tag
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(selectedTag == tag ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                        )
                        .foregroundColor(selectedTag == tag ? .white : .primary)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var historyListView: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(Array(filteredHistory.enumerated()), id: \.element.id) { index, item in
                    FloatingItemView(
                        item: item,
                        index: index,
                        isSelected: index == clipboardManager.selectedIndex
                    ) {
                        // Hide panel first to return focus to target app
                        manager.hidePanel()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            if let originalIndex = clipboardManager.clipboardHistory.firstIndex(where: { $0.id == item.id }) {
                                clipboardManager.pasteItem(at: originalIndex)
                            }
                        }
                    } onAppend: {
                        if let originalIndex = clipboardManager.clipboardHistory.firstIndex(where: { $0.id == item.id }) {
                            clipboardManager.appendItem(at: originalIndex)
                        }
                    } onDelete: {
                        if let originalIndex = clipboardManager.clipboardHistory.firstIndex(where: { $0.id == item.id }) {
                            clipboardManager.deleteItem(at: originalIndex)
                        }
                    } onPin: {
                        if let originalIndex = clipboardManager.clipboardHistory.firstIndex(where: { $0.id == item.id }) {
                            clipboardManager.pinItem(at: originalIndex)
                        }
                    } onFavorite: {
                        if let originalIndex = clipboardManager.clipboardHistory.firstIndex(where: { $0.id == item.id }) {
                            clipboardManager.favoriteItem(at: originalIndex)
                        }
                    } onLock: {
                        if let originalIndex = clipboardManager.clipboardHistory.firstIndex(where: { $0.id == item.id }) {
                            clipboardManager.lockItem(at: originalIndex)
                        }
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            Text("No clipboard history")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Copy some text to start building your clipboard history")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var footerView: some View {
        HStack {
            Button("Clear all") {
                manager.clearClipboardHistory()
            }
            .foregroundColor(.red)
            .buttonStyle(PlainButtonStyle())
            .font(.caption)
            
            Spacer()
            
            Text("\(filteredHistory.count) of 25")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Menu {
                Toggle("Sync across devices", isOn: $manager.syncEnabled)
                Toggle("Privacy mode", isOn: $manager.privacyMode)
                
                Divider()
                
                Button("Settings") {
                    // Open settings window
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch manager.currentTheme {
        case .minimal:
            Color(NSColor.windowBackgroundColor)
                .opacity(0.95)
        case .blur:
            Color(NSColor.windowBackgroundColor)
                .opacity(0.8)
                .background(.ultraThinMaterial)
        default:
            Color(NSColor.windowBackgroundColor)
        }
    }
}

struct FloatingItemView: View {
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
        HStack(alignment: .center, spacing: 12) {
            // Type indicator (Windows-like)
            Text(typeIcon)
                .font(.system(size: 16))
                .frame(width: 24)
            
            // Content preview (Windows-like layout)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.preview)
                    .font(.system(.body))
                    .lineLimit(2)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Text(item.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if item.isPinned {
                        Text("📌")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Text(formatSize(item.size))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Pin button (Windows-like)
            Button(action: onPin) {
                Image(systemName: item.isPinned ? "pin.fill" : "pin")
                    .font(.system(size: 14))
                    .foregroundColor(item.isPinned ? .orange : .secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 24, height: 24)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Rectangle()
                .fill(isSelected ? Color.accentColor.opacity(0.2) : (isHovered ? Color(NSColor.controlBackgroundColor) : Color.clear))
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
    FloatingPanelView(manager: FloatingPanelManager())
        .environmentObject(ClipboardManager())
        .environmentObject(HotkeyManager())
}
