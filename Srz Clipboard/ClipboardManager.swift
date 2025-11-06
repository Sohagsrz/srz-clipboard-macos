//
//  ClipboardManager.swift
//  Srz Clipboard
//
//  Created by Md Sohag Islam on 18/10/25.
//

import Foundation
import AppKit
import SwiftUI
import Vision
import Combine
import NaturalLanguage
import UniformTypeIdentifiers

class ClipboardManager: ObservableObject {
    @Published var clipboardHistory: [ClipboardItem] = []
    @Published var isShowingHistory = false
    @Published var selectedIndex = 0
    @Published var commandText = ""
    @Published var actionLog: [ActionLogEntry] = []
    @Published var snippets: [String: String] = [:]
    @Published var templates: [String: String] = [:]
    @Published var macros: [String: [String]] = [:]
    @Published var shortcuts: [String: String] = [:]
    @Published var autoRules: [AutoRule] = []
    @Published var entryStats: [String: EntryStats] = [:]
    @Published var reminders: [Reminder] = []
    @Published var scheduledPastes: [ScheduledPaste] = []
    
    private var pasteboard = NSPasteboard.general
    private var lastChangeCount = 0
    private var timer: Timer?
    private var undoStack: [ActionLogEntry] = []
    
    init() {
        startMonitoring()
        loadHistory()
        loadSnippets()
        loadTemplates()
        loadMacros()
        loadShortcuts()
        loadAutoRules()
        loadEntryStats()
        loadReminders()
        loadScheduledPastes()
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.checkClipboard()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkClipboard() {
        let currentChangeCount = pasteboard.changeCount
        
        if currentChangeCount != lastChangeCount {
            lastChangeCount = currentChangeCount
            
            // Check for different content types
            if let content = pasteboard.string(forType: .string), !content.isEmpty {
                addToHistory(content: content, type: .text)
            } else if let image = pasteboard.data(forType: .tiff) {
                addImageToHistory(imageData: image)
            } else if let html = pasteboard.string(forType: .html) {
                addToHistory(content: html, type: .html)
            }
        }
    }
    
    private func addToHistory(content: String, type: ContentType = .text) {
        // Avoid duplicates
        if let lastItem = clipboardHistory.first, lastItem.content == content {
            return
        }
        
        // Apply auto-rules
        let processedContent = applyAutoRules(to: content)
        
        var newItem = ClipboardItem(
            id: UUID(),
            content: processedContent,
            timestamp: Date(),
            preview: String(processedContent.prefix(50)),
            type: type,
            size: processedContent.count,
            isPinned: false,
            isFavorite: false,
            isLocked: false,
            tags: [],
            expiresAt: nil
        )
        
        // Auto-tag the item
        let autoTags = autoTag(newItem)
        newItem.tags.append(contentsOf: autoTags)
        
        clipboardHistory.insert(newItem, at: 0)
        
        // Limit history to 50 items
        if clipboardHistory.count > 50 {
            clipboardHistory = Array(clipboardHistory.prefix(50))
        }
        
        // Initialize entry stats
        let itemId = newItem.id.uuidString
        if entryStats[itemId] == nil {
            entryStats[itemId] = EntryStats()
        }
        
        // Extract links and detect language
        entryStats[itemId]?.extractedLinks = extractLinks(processedContent)
        entryStats[itemId]?.language = detectLanguage(processedContent)
        
        saveHistory()
        saveEntryStats()
    }
    
    private func addImageToHistory(imageData: Data) {
        let newItem = ClipboardItem(
            id: UUID(),
            content: "Image Data",
            timestamp: Date(),
            preview: "🖼️ Image",
            type: .image,
            size: imageData.count,
            isPinned: false,
            isFavorite: false,
            isLocked: false,
            tags: [],
            expiresAt: nil,
            imageData: imageData
        )
        
        clipboardHistory.insert(newItem, at: 0)
        saveHistory()
    }
    
    // MARK: - Core Actions
    
    func pasteItem(at index: Int) {
        guard index < clipboardHistory.count else { return }
        let item = clipboardHistory[index]
        
        if item.isLocked {
            logAction("paste \(index)", "❌ Item is locked")
            return
        }
        
        print("🎯 Pasting item \(index)...")
        
        // Copy to clipboard first (text or image)
        if item.type == .image, let data = item.imageData {
            if copyImageToClipboard(data) {
                print("✅ Image copied to clipboard")
            } else {
                print("❌ Failed to copy image to clipboard")
                logAction("paste \(index)", "❌ Failed to copy image to clipboard")
                return
            }
        } else {
            copyToClipboard(item.content)
            print("✅ Text copied to clipboard")
        }
        
        // Try the most reliable method first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.performReliablePaste()
        }
        
        logAction("paste \(index)", "✅ Attempted paste")
    }
    
    private func performReliablePaste() {
        print("🔄 Performing reliable paste...")
        
        // Method 1: Try AppleScript (most reliable on modern macOS)
        if tryAppleScriptPaste() {
            print("✅ AppleScript paste successful")
            return
        }
        
        // Method 2: Try CGEvent
        if tryCGEventPaste() {
            print("✅ CGEvent paste successful")
            return
        }
        
        // Method 3: Show helpful notification
        print("⚠️ All paste methods failed, showing notification")
        showHelpfulNotification()
    }
    
    private func tryAppleScriptPaste() -> Bool {
        print("🎯 Trying AppleScript paste...")
        
        let script = """
        tell application "System Events"
            keystroke "v" using command down
        end tell
        """
        
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        let result = appleScript?.executeAndReturnError(&error)
        
        if let error = error {
            print("❌ AppleScript error: \(error)")
            return false
        }
        
        print("✅ AppleScript executed successfully")
        return true
    }
    
    private func tryCGEventPaste() -> Bool {
        print("🎯 Trying CGEvent paste...")
        
        guard let source = CGEventSource(stateID: .hidSystemState) else {
            print("❌ Failed to create CGEventSource")
            return false
        }
        
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false)
        
        guard let keyDown = keyDown, let keyUp = keyUp else {
            print("❌ Failed to create CGEvent")
            return false
        }
        
        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand
        
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
        
        print("✅ CGEvent posted")
        return true
    }
    
    private func showHelpfulNotification() {
        // Create a helpful notification
        let notification = NSUserNotification()
        notification.title = "Srz Clipboard"
        notification.informativeText = "Text copied! Press Cmd+V to paste into any app."
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
        
        // Also show a system alert for better visibility
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let alert = NSAlert()
            alert.messageText = "Text Copied to Clipboard"
            alert.informativeText = "The text has been copied to your clipboard.\n\nPress Cmd+V to paste it into any application."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    func appendItem(at index: Int) {
        guard index < clipboardHistory.count else { return }
        let item = clipboardHistory[index]
        
        if item.isLocked {
            logAction("append \(index)", "❌ Item is locked")
            return
        }
        
        let currentContent = pasteboard.string(forType: .string) ?? ""
        let newContent = currentContent.isEmpty ? item.content : "\(currentContent) \(item.content)"
        copyToClipboard(newContent)
        logAction("append \(index)", "✅ Appended")
    }
    
    func copyItem(at index: Int) {
        guard index < clipboardHistory.count else { return }
        let item = clipboardHistory[index]
        
        if item.isLocked {
            logAction("copy \(index)", "❌ Item is locked")
            return
        }
        
        copyToClipboard(item.content)
        logAction("copy \(index)", "✅ Copied")
    }
    
    func pinItem(at index: Int) {
        guard index < clipboardHistory.count else { return }
        clipboardHistory[index].isPinned.toggle()
        saveHistory()
        logAction("pin \(index)", clipboardHistory[index].isPinned ? "⭐ Pinned" : "⭐ Unpinned")
    }
    
    func favoriteItem(at index: Int) {
        guard index < clipboardHistory.count else { return }
        clipboardHistory[index].isFavorite.toggle()
        saveHistory()
        logAction("favorite \(index)", clipboardHistory[index].isFavorite ? "❤️ Favorited" : "❤️ Unfavorited")
    }
    
    func deleteItem(at index: Int) {
        guard index < clipboardHistory.count else { return }
        let item = clipboardHistory[index]
        clipboardHistory.remove(at: index)
        saveHistory()
        logAction("delete \(index)", "🗑️ Deleted")
        undoStack.append(ActionLogEntry(action: "delete", itemId: item.id, content: item.content))
    }
    
    func lockItem(at index: Int) {
        guard index < clipboardHistory.count else { return }
        clipboardHistory[index].isLocked.toggle()
        saveHistory()
        logAction("lock \(index)", clipboardHistory[index].isLocked ? "🔒 Locked" : "🔓 Unlocked")
    }
    
    // MARK: - Content Transformations
    
    func transformItem(at index: Int, transform: ContentTransform) {
        guard index < clipboardHistory.count else { return }
        let item = clipboardHistory[index]
        
        if item.isLocked {
            logAction("transform \(index)", "❌ Item is locked")
            return
        }
        
        var newContent = item.content
        
        switch transform {
        case .trim:
            newContent = item.content.trimmingCharacters(in: .whitespacesAndNewlines)
        case .uppercase:
            newContent = item.content.uppercased()
        case .lowercase:
            newContent = item.content.lowercased()
        case .titlecase:
            newContent = item.content.capitalized
        case .compress:
            newContent = compressText(item.content)
        case .formatJSON:
            newContent = formatJSON(item.content)
        case .formatYAML:
            newContent = formatYAML(item.content)
        case .toMarkdown:
            newContent = convertToMarkdown(item.content)
        case .toPlain:
            newContent = convertToPlain(item.content)
        }
        
        clipboardHistory[index].content = newContent
        clipboardHistory[index].preview = String(newContent.prefix(50))
        saveHistory()
        logAction("transform \(index)", "✅ \(transform.rawValue)")
    }
    
    // MARK: - Search and Filter
    
    func searchHistory(query: String) -> [ClipboardItem] {
        if query.hasPrefix("re:") {
            let regex = String(query.dropFirst(3))
            return clipboardHistory.filter { item in
                item.content.range(of: regex, options: .regularExpression) != nil
            }
        } else if query.hasPrefix("\"") && query.hasSuffix("\"") {
            let exactQuery = String(query.dropFirst().dropLast())
            return clipboardHistory.filter { $0.content.contains(exactQuery) }
        } else {
            return clipboardHistory.filter { item in
                item.content.localizedCaseInsensitiveContains(query) ||
                item.preview.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    func filterHistory(type: ContentType? = nil, pinned: Bool? = nil, favorites: Bool? = nil) -> [ClipboardItem] {
        return clipboardHistory.filter { item in
            if let type = type, item.type != type { return false }
            if let pinned = pinned, item.isPinned != pinned { return false }
            if let favorites = favorites, item.isFavorite != favorites { return false }
            return true
        }
    }
    
    // MARK: - Snippets and Templates
    
    func saveSnippet(name: String, from index: Int) {
        guard index < clipboardHistory.count else { return }
        let item = clipboardHistory[index]
        snippets[name] = item.content
        saveSnippets()
        logAction("snippet save \(name)", "✅ Saved")
    }
    
    func pasteSnippet(name: String) {
        guard let content = snippets[name] else {
            logAction("snippet paste \(name)", "❌ Not found")
            return
        }
        copyToClipboard(content)
        logAction("snippet paste \(name)", "✅ Pasted")
    }
    
    func insertTemplate(name: String) {
        guard let template = templates[name] else {
            logAction("template insert \(name)", "❌ Not found")
            return
        }
        copyToClipboard(template)
        logAction("template insert \(name)", "✅ Inserted")
    }
    
    // MARK: - OCR
    
    func performOCR(on index: Int) {
        guard index < clipboardHistory.count else { return }
        let item = clipboardHistory[index]
        
        guard let imageData = item.imageData else {
            logAction("ocr \(index)", "❌ Not an image")
            return
        }
        
        guard let image = NSImage(data: imageData) else {
            logAction("ocr \(index)", "❌ Invalid image")
            return
        }
        
        // Perform OCR using Vision framework
        let request = VNRecognizeTextRequest { request, error in
            DispatchQueue.main.async {
                if let observations = request.results as? [VNRecognizedTextObservation] {
                    let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                    if !text.isEmpty {
                        self.addToHistory(content: text, type: .text)
                        self.logAction("ocr \(index)", "✅ OCR completed")
                    } else {
                        self.logAction("ocr \(index)", "❌ No text found")
                    }
                }
            }
        }
        
        request.recognitionLevel = .accurate
        
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            logAction("ocr \(index)", "❌ Image conversion failed")
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
    
    // MARK: - Helper Methods
    
    private func copyToClipboard(_ content: String) {
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
    }

    private func copyImageToClipboard(_ imageData: Data) -> Bool {
        pasteboard.clearContents()
        // Try to create NSImage from data
        guard let image = NSImage(data: imageData) else { return false }
        // Prefer PNG representation when possible
        var wrote = false
        if let tiffData = image.tiffRepresentation,
           let rep = NSBitmapImageRep(data: tiffData),
           let pngData = rep.representation(using: .png, properties: [:]) {
            wrote = pasteboard.setData(pngData, forType: .png)
        }
        // Fallback to TIFF
        if !wrote {
            wrote = pasteboard.setData(image.tiffRepresentation, forType: .tiff)
        }
        // Also set general pasteboard item with NSImage for broader compatibility
        if wrote {
            let item = NSPasteboardItem()
            if let tiff = image.tiffRepresentation {
                item.setData(tiff, forType: .tiff)
            }
            pasteboard.writeObjects([image])
        }
        return wrote
    }
    
    private func simulatePaste() {
        print("📋 Starting paste operation...")
        
        // Use the simplest and most reliable method: direct CGEvent
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.performPaste()
        }
    }
    
    private func performPaste() {
        print("🎯 Performing paste operation...")
        
        // Create a simple Cmd+V event
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true) // V key
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false)
        
        // Set command key modifier
        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand
        
        // Post the events
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
        
        print("✅ Paste command sent")
    }
    
    func checkAccessibilityPermissions() -> Bool {
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [checkOptPrompt: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !accessEnabled {
            print("❌ Accessibility permissions not granted")
            print("📋 Please go to System Preferences > Security & Privacy > Privacy > Accessibility")
            print("📋 Add 'Srz Clipboard' to the list of allowed applications")
        } else {
            print("✅ Accessibility permissions granted")
        }
        
        return accessEnabled
    }

    /// Ensures required permissions are prompted: Accessibility (for CGEvent paste)
    /// and Automation (for AppleScript). Call on app launch.
    func ensurePermissions() {
        _ = checkAccessibilityPermissions()
        // Trigger Automation permission prompt by executing a harmless AppleScript
        let script = """
        tell application "System Events"
            get name of application processes
        end tell
        """
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        _ = appleScript?.executeAndReturnError(&error)
        if let error = error {
            print("ℹ️ Automation permission may be required: \(error)")
        } else {
            print("✅ Automation check executed (AppleScript)")
        }
    }
    
    private func pasteUsingCGEvent() -> Bool {
        print("🎯 Attempting CGEvent paste...")
        
        // Check accessibility permissions first
        if !checkAccessibilityPermissions() {
            return false
        }
        
        // Ensure we have a valid event source
        guard let source = CGEventSource(stateID: .hidSystemState) else {
            print("❌ Failed to create CGEventSource")
            return false
        }
        
        // Create Cmd+V key events
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true) // V key
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false)
        
        guard let keyDown = keyDown, let keyUp = keyUp else {
            print("❌ Failed to create CGEvent")
            return false
        }
        
        // Set command key modifier
        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand
        
        // Post the events
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
        
        print("✅ CGEvent posted successfully")
        return true
    }
    
    private func pasteUsingSimpleAppleScript() -> Bool {
        print("🎯 Attempting simple AppleScript paste...")
        
        // Simple AppleScript that just simulates Cmd+V
        let script = """
        tell application "System Events"
            keystroke "v" using command down
        end tell
        """
        
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        let result = appleScript?.executeAndReturnError(&error)
        
        if let error = error {
            print("❌ AppleScript error: \(error)")
            return false
        }
        
        print("✅ Simple AppleScript executed successfully")
        return true
    }
    
    private func compressText(_ text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        let filteredLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return Array(Set(filteredLines)).joined(separator: "\n")
    }
    
    func formatJSON(_ text: String) -> String {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let formattedData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
              let formattedString = String(data: formattedData, encoding: .utf8) else {
            return text
        }
        return formattedString
    }
    
    private func formatYAML(_ text: String) -> String {
        // Simple YAML formatting - in a real implementation, you'd use a YAML library
        return text
    }
    
    private func convertToMarkdown(_ text: String) -> String {
        // Simple markdown conversion
        return text
    }
    
    private func convertToPlain(_ text: String) -> String {
        return text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
    
    private func logAction(_ action: String, _ result: String) {
        let entry = ActionLogEntry(action: action, itemId: nil, content: result)
        actionLog.insert(entry, at: 0)
        if actionLog.count > 100 {
            actionLog = Array(actionLog.prefix(100))
        }
    }
    
    // MARK: - Persistence
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(clipboardHistory) {
            UserDefaults.standard.set(data, forKey: "clipboardHistory")
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "clipboardHistory"),
           let history = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            clipboardHistory = history
        }
    }
    
    private func saveSnippets() {
        UserDefaults.standard.set(snippets, forKey: "snippets")
    }
    
    private func loadSnippets() {
        snippets = UserDefaults.standard.dictionary(forKey: "snippets") as? [String: String] ?? [:]
    }
    
    private func saveTemplates() {
        UserDefaults.standard.set(templates, forKey: "templates")
    }
    
    private func loadTemplates() {
        templates = UserDefaults.standard.dictionary(forKey: "templates") as? [String: String] ?? [:]
    }
    
    private func saveMacros() {
        UserDefaults.standard.set(macros, forKey: "macros")
    }
    
    private func loadMacros() {
        macros = UserDefaults.standard.dictionary(forKey: "macros") as? [String: [String]] ?? [:]
    }
    
    private func saveShortcuts() {
        UserDefaults.standard.set(shortcuts, forKey: "shortcuts")
    }
    
    private func loadShortcuts() {
        shortcuts = UserDefaults.standard.dictionary(forKey: "shortcuts") as? [String: String] ?? [:]
    }
    
    private func saveAutoRules() {
        if let data = try? JSONEncoder().encode(autoRules) {
            UserDefaults.standard.set(data, forKey: "autoRules")
        }
    }
    
    private func loadAutoRules() {
        if let data = UserDefaults.standard.data(forKey: "autoRules"),
           let decoded = try? JSONDecoder().decode([AutoRule].self, from: data) {
            autoRules = decoded
        }
    }
    
    private func saveEntryStats() {
        if let data = try? JSONEncoder().encode(entryStats) {
            UserDefaults.standard.set(data, forKey: "entryStats")
        }
    }
    
    private func loadEntryStats() {
        if let data = UserDefaults.standard.data(forKey: "entryStats"),
           let decoded = try? JSONDecoder().decode([String: EntryStats].self, from: data) {
            entryStats = decoded
        }
    }
    
    private func saveReminders() {
        if let data = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(data, forKey: "reminders")
        }
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: "reminders"),
           let decoded = try? JSONDecoder().decode([Reminder].self, from: data) {
            reminders = decoded
        }
    }
    
    private func saveScheduledPastes() {
        if let data = try? JSONEncoder().encode(scheduledPastes) {
            UserDefaults.standard.set(data, forKey: "scheduledPastes")
        }
    }
    
    private func loadScheduledPastes() {
        if let data = UserDefaults.standard.data(forKey: "scheduledPastes"),
           let decoded = try? JSONDecoder().decode([ScheduledPaste].self, from: data) {
            scheduledPastes = decoded
        }
    }
    
    func showHistory() {
        isShowingHistory = true
    }
    
    func hideHistory() {
        isShowingHistory = false
    }
    
    func clearHistory() {
        clipboardHistory.removeAll()
        saveHistory()
    }
    
    func clearHistoryKeepPinned() {
        clipboardHistory = clipboardHistory.filter { $0.isPinned }
        saveHistory()
    }
    
    // MARK: - Smart Content Intelligence
    
    func autoTag(_ item: ClipboardItem) -> [String] {
        var tags: [String] = []
        let content = item.content.lowercased()
        
        // URL detection
        if content.contains("http://") || content.contains("https://") || content.contains("www.") {
            tags.append(ContentTag.url.rawValue)
        }
        
        // Email detection
        if content.contains("@") && content.contains(".") {
            tags.append(ContentTag.email.rawValue)
        }
        
        // Phone number detection
        let phonePattern = #"(\+?1[-.\s]?)?\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}"#
        if content.range(of: phonePattern, options: .regularExpression) != nil {
            tags.append(ContentTag.phone.rawValue)
        }
        
        // Code detection
        if content.contains("{") && content.contains("}") || 
           content.contains("function") || content.contains("class") ||
           content.contains("import ") || content.contains("def ") {
            tags.append(ContentTag.code.rawValue)
        }
        
        // JSON detection
        if content.hasPrefix("{") && content.hasSuffix("}") ||
           content.hasPrefix("[") && content.hasSuffix("]") {
            tags.append(ContentTag.json.rawValue)
        }
        
        // Markdown detection
        if content.contains("# ") || content.contains("## ") || content.contains("*") {
            tags.append(ContentTag.markdown.rawValue)
        }
        
        // HTML detection
        if content.contains("<") && content.contains(">") {
            tags.append(ContentTag.html.rawValue)
        }
        
        // OTP detection (6-digit numbers)
        if content.count == 6 && content.allSatisfy({ $0.isNumber }) {
            tags.append(ContentTag.otp.rawValue)
        }
        
        // Number detection
        if content.allSatisfy({ $0.isNumber || $0 == "." || $0 == "," }) {
            tags.append(ContentTag.number.rawValue)
        }
        
        return tags
    }
    
    func summarize(_ content: String) -> String {
        let sentences = content.components(separatedBy: ". ")
        if sentences.count <= 3 {
            return content
        }
        
        // Simple summarization - take first sentence and key phrases
        let firstSentence = sentences.first ?? ""
        let words = content.components(separatedBy: .whitespaces)
        
        if words.count > 50 {
            let keyWords = words.filter { $0.count > 4 }.prefix(5)
            return "\(firstSentence). Key terms: \(keyWords.joined(separator: ", "))..."
        }
        
        return firstSentence
    }
    
    func detectLanguage(_ content: String) -> String {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(content)
        
        if let language = recognizer.dominantLanguage {
            return language.rawValue
        }
        
        return "Unknown"
    }
    
    func extractLinks(_ content: String) -> [String] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count)) ?? []
        
        return matches.compactMap { match in
            if let range = Range(match.range, in: content) {
                return String(content[range])
            }
            return nil
        }
    }
    
    func shortenURL(_ url: String) -> String {
        // Simple URL shortening - in production, you'd use a service like bit.ly
        if url.count > 50 {
            let components = url.components(separatedBy: "/")
            if components.count > 3 {
                return "\(components[0])//\(components[2])/..."
            }
        }
        return url
    }
    
    func updateEntryStats(for itemId: String) {
        if entryStats[itemId] == nil {
            entryStats[itemId] = EntryStats()
        }
        
        entryStats[itemId]?.useCount += 1
        entryStats[itemId]?.lastUsed = Date()
        
        saveEntryStats()
    }
    
    func addReminder(entryId: String, message: String, scheduledTime: Date) {
        let reminder = Reminder(entryId: entryId, message: message, scheduledTime: scheduledTime)
        reminders.append(reminder)
        saveReminders()
    }
    
    func schedulePaste(entryId: String, scheduledTime: Date) {
        let scheduledPaste = ScheduledPaste(entryId: entryId, scheduledTime: scheduledTime)
        scheduledPastes.append(scheduledPaste)
        saveScheduledPastes()
    }
    
    func addAutoRule(name: String, pattern: String, action: String) {
        let rule = AutoRule(name: name, pattern: pattern, action: action)
        autoRules.append(rule)
        saveAutoRules()
    }
    
    func applyAutoRules(to content: String) -> String {
        var processedContent = content
        
        for rule in autoRules where rule.isEnabled {
            if processedContent.range(of: rule.pattern, options: .regularExpression) != nil {
                switch rule.action {
                case "trim":
                    processedContent = processedContent.trimmingCharacters(in: .whitespacesAndNewlines)
                case "uppercase":
                    processedContent = processedContent.uppercased()
                case "lowercase":
                    processedContent = processedContent.lowercased()
                case "remove-spaces":
                    processedContent = processedContent.replacingOccurrences(of: " ", with: "")
                default:
                    break
                }
            }
        }
        
        return processedContent
    }
}

enum ContentType: String, Codable, CaseIterable {
    case text = "text"
    case image = "image"
    case html = "html"
    case snippet = "snippet"
}

enum ContentTransform: String, CaseIterable {
    case trim = "trim"
    case uppercase = "uppercase"
    case lowercase = "lowercase"
    case titlecase = "titlecase"
    case compress = "compress"
    case formatJSON = "formatJSON"
    case formatYAML = "formatYAML"
    case toMarkdown = "toMarkdown"
    case toPlain = "toPlain"
}

struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    var content: String
    let timestamp: Date
    var preview: String
    let type: ContentType
    let size: Int
    var isPinned: Bool
    var isFavorite: Bool
    var isLocked: Bool
    var tags: [String]
    var expiresAt: Date?
    var imageData: Data?
    
    init(id: UUID = UUID(), content: String, timestamp: Date = Date(), preview: String, type: ContentType = .text, size: Int, isPinned: Bool = false, isFavorite: Bool = false, isLocked: Bool = false, tags: [String] = [], expiresAt: Date? = nil, imageData: Data? = nil) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
        self.preview = preview
        self.type = type
        self.size = size
        self.isPinned = isPinned
        self.isFavorite = isFavorite
        self.isLocked = isLocked
        self.tags = tags
        self.expiresAt = expiresAt
        self.imageData = imageData
    }
}

struct ActionLogEntry: Identifiable, Codable {
    let id = UUID()
    let action: String
    let itemId: UUID?
    let content: String
    let timestamp = Date()
}

// MARK: - Smart Content Intelligence Data Structures

struct AutoRule: Codable, Identifiable {
    let id = UUID()
    let name: String
    let pattern: String
    let action: String
    let isEnabled: Bool
    let createdAt: Date
    
    init(name: String, pattern: String, action: String, isEnabled: Bool = true) {
        self.name = name
        self.pattern = pattern
        self.action = action
        self.isEnabled = isEnabled
        self.createdAt = Date()
    }
}

struct EntryStats: Codable {
    var useCount: Int = 0
    var lastUsed: Date = Date()
    var tags: [String] = []
    var language: String?
    var summary: String?
    var extractedLinks: [String] = []
    
    init() {
        self.useCount = 0
        self.lastUsed = Date()
        self.tags = []
        self.language = nil
        self.summary = nil
        self.extractedLinks = []
    }
}

struct Reminder: Codable, Identifiable {
    let id = UUID()
    let entryId: String
    let message: String
    let scheduledTime: Date
    let isCompleted: Bool
    
    init(entryId: String, message: String, scheduledTime: Date) {
        self.entryId = entryId
        self.message = message
        self.scheduledTime = scheduledTime
        self.isCompleted = false
    }
}

struct ScheduledPaste: Codable, Identifiable {
    let id = UUID()
    let entryId: String
    let scheduledTime: Date
    let isCompleted: Bool
    
    init(entryId: String, scheduledTime: Date) {
        self.entryId = entryId
        self.scheduledTime = scheduledTime
        self.isCompleted = false
    }
}

enum ContentTag: String, CaseIterable {
    case url = "URL"
    case email = "Email"
    case code = "Code"
    case image = "Image"
    case number = "Number"
    case command = "Command"
    case phone = "Phone"
    case address = "Address"
    case date = "Date"
    case json = "JSON"
    case csv = "CSV"
    case markdown = "Markdown"
    case html = "HTML"
    case password = "Password"
    case otp = "OTP"
}
