//
//  SettingsView.swift
//  Srz Clipboard
//
//  Created by Md Sohag Islam on 18/10/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject private var clipboardManager = ClipboardManager()
    @StateObject private var hotkeyManager = HotkeyManager()
    @StateObject private var floatingPanelManager = FloatingPanelManager()
    @State private var isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    @State private var maxHistoryItems = UserDefaults.standard.object(forKey: "maxHistoryItems") as? Int ?? 100
    @State private var selectedTheme = AppTheme.system
    @State private var hapticEnabled = UserDefaults.standard.bool(forKey: "hapticEnabled")
    @State private var soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
    @State private var pinBarEnabled = UserDefaults.standard.bool(forKey: "pinBarEnabled")
    @State private var blurEffect = UserDefaults.standard.bool(forKey: "blurEffect")
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Srz Clipboard Settings")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .onChange(of: selectedTheme) { newValue in
                        floatingPanelManager.setTheme(newValue)
                        UserDefaults.standard.set(newValue.rawValue, forKey: "selectedTheme")
                    }
                    
                    Toggle("Dark Mode", isOn: $isDarkMode)
                        .onChange(of: isDarkMode) { newValue in
                            toggleTheme(isDark: newValue)
                        }
                    
                    Toggle("Blur Effect", isOn: $blurEffect)
                        .onChange(of: blurEffect) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "blurEffect")
                        }
                }
                
                Section("UI Features") {
                    Toggle("Pin Bar", isOn: $pinBarEnabled)
                        .onChange(of: pinBarEnabled) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "pinBarEnabled")
                        }
                    
                    Stepper("Max History Items: \(maxHistoryItems)", value: $maxHistoryItems, in: 10...500, step: 10)
                        .onChange(of: maxHistoryItems) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "maxHistoryItems")
                        }
                }
                
                Section("Feedback") {
                    Toggle("Haptic Feedback", isOn: $hapticEnabled)
                        .onChange(of: hapticEnabled) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "hapticEnabled")
                            floatingPanelManager.hapticEnabled = newValue
                        }
                    
                    Toggle("Sound Feedback", isOn: $soundEnabled)
                        .onChange(of: soundEnabled) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "soundEnabled")
                            floatingPanelManager.soundEnabled = newValue
                        }
                }
                
                Section("Data Management") {
                    Button("Clear All History") {
                        clipboardManager.clearHistory()
                    }
                    .foregroundColor(.red)
                    .disabled(clipboardManager.clipboardHistory.isEmpty)
                    
                    Button("Export History") {
                        exportHistory()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Import History") {
                        importHistory()
                    }
                    .foregroundColor(.green)
                }
                
                Section("Hotkey") {
                    HStack {
                        Text("Show History:")
                        Spacer()
                        Text("⌘⌥V")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Press Cmd+Alt+V anywhere to show floating clipboard panel")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("About") {
                    HStack {
                        Text("Version:")
                        Spacer()
                        Text("2.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Created by:")
                        Spacer()
                        Text("Md Sohag Islam")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
            
            Spacer()
        }
        .frame(width: 400, height: 500)
        .padding()
    }
    
    private func toggleTheme(isDark: Bool) {
        if isDark {
            NSApp.appearance = NSAppearance(named: .darkAqua)
        } else {
            NSApp.appearance = NSAppearance(named: .aqua)
        }
        UserDefaults.standard.set(isDark, forKey: "isDarkMode")
    }
    
    private func exportHistory() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "clipboard_history.json"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    let data = try encoder.encode(clipboardManager.clipboardHistory)
                    try data.write(to: url)
                } catch {
                    print("Export failed: \(error)")
                }
            }
        }
    }
    
    private func importHistory() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let importedHistory = try decoder.decode([ClipboardItem].self, from: data)
                    clipboardManager.clipboardHistory = importedHistory
                } catch {
                    print("Import failed: \(error)")
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ClipboardManager())
        .environmentObject(HotkeyManager())
}
