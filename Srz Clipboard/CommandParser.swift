//
//  CommandParser.swift
//  Srz Clipboard
//
//  Created by Md Sohag Islam on 18/10/25.
//

import Foundation
import AppKit

class CommandParser {
    private let clipboardManager: ClipboardManager
    
    init(clipboardManager: ClipboardManager) {
        self.clipboardManager = clipboardManager
    }
    
    func parseCommand(_ command: String) -> String {
        let trimmedCommand = command.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = trimmedCommand.components(separatedBy: .whitespaces)
        
        guard !components.isEmpty else { return "" }
        
        let action = components[0].lowercased()
        
        switch action {
        case "paste":
            return handlePaste(components)
        case "append":
            return handleAppend(components)
        case "copy":
            return handleCopy(components)
        case "pin", "unpin":
            return handlePin(components)
        case "favorite", "unfavorite":
            return handleFavorite(components)
        case "delete":
            return handleDelete(components)
        case "lock":
            return handleLock(components)
        case "clear":
            return handleClear(components)
        case "undo":
            return handleUndo(components)
        case "preview":
            return handlePreview(components)
        case "open":
            return handleOpen(components)
        case "edit":
            return handleEdit(components)
        case "trim":
            return handleTrim(components)
        case "uppercase":
            return handleUppercase(components)
        case "lowercase":
            return handleLowercase(components)
        case "titlecase":
            return handleTitlecase(components)
        case "compress":
            return handleCompress(components)
        case "format":
            return handleFormat(components)
        case "convert":
            return handleConvert(components)
        case "snippet":
            return handleSnippet(components)
        case "template":
            return handleTemplate(components)
        case "macro":
            return handleMacro(components)
        case "shortcut":
            return handleShortcut(components)
        case "search":
            return handleSearch(components)
        case "group":
            return handleGroup(components)
        case "merge":
            return handleMerge(components)
        case "sync":
            return handleSync(components)
        case "expire":
            return handleExpire(components)
        case "ocr":
            return handleOCR(components)
        case "log":
            return handleLog(components)
        // Smart Content Intelligence Commands
        case "auto-tag":
            return handleAutoTag(components)
        case "summarize":
            return handleSummarize(components)
        case "translate":
            return handleTranslate(components)
        case "detect-lang":
            return handleDetectLang(components)
        case "shorten-url":
            return handleShortenURL(components)
        case "extract-links":
            return handleExtractLinks(components)
        // Workflow Automation Commands
        case "auto-copy":
            return handleAutoCopy(components)
        case "auto-paste":
            return handleAutoPaste(components)
        case "trigger":
            return handleTrigger(components)
        case "rule":
            return handleRule(components)
        // Time & Context Awareness Commands
        case "stats":
            return handleStats(components)
        case "reminder":
            return handleReminder(components)
        case "schedule":
            return handleSchedule(components)
        // Deep Integration Commands
        case "send":
            return handleSend(components)
        case "webhook":
            return handleWebhook(components)
        case "export":
            return handleExport(components)
        case "import":
            return handleImport(components)
        case "ai-format":
            return handleAIFormat(components)
        case "help":
            return showHelp()
        default:
            return "❌ Unknown command: \(action). Type 'help' for available commands."
        }
    }
    
    // MARK: - Core Actions
    
    private func handlePaste(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: paste N"
        }
        clipboardManager.pasteItem(at: index)
        return "✅ Pasted item \(index)"
    }
    
    private func handleAppend(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: append N"
        }
        clipboardManager.appendItem(at: index)
        return "✅ Appended item \(index)"
    }
    
    private func handleCopy(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: copy N"
        }
        clipboardManager.copyItem(at: index)
        return "✅ Copied item \(index)"
    }
    
    private func handlePin(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: pin N or unpin N"
        }
        clipboardManager.pinItem(at: index)
        return "✅ Toggled pin for item \(index)"
    }
    
    private func handleFavorite(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: favorite N or unfavorite N"
        }
        clipboardManager.favoriteItem(at: index)
        return "✅ Toggled favorite for item \(index)"
    }
    
    private func handleDelete(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: delete N"
        }
        clipboardManager.deleteItem(at: index)
        return "✅ Deleted item \(index)"
    }
    
    private func handleLock(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: lock N"
        }
        clipboardManager.lockItem(at: index)
        return "✅ Toggled lock for item \(index)"
    }
    
    private func handleClear(_ components: [String]) -> String {
        let force = components.contains("--force")
        if !force {
            return "⚠️ Clear all non-pinned entries? Type 'clear --force' to confirm."
        }
        clipboardManager.clipboardHistory.removeAll { !$0.isPinned }
        return "✅ Cleared all non-pinned entries"
    }
    
    private func handleUndo(_ components: [String]) -> String {
        // Implementation for undo functionality
        return "✅ Undo not implemented yet"
    }
    
    private func handlePreview(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: preview N"
        }
        guard index < clipboardManager.clipboardHistory.count else {
            return "❌ Invalid index"
        }
        let item = clipboardManager.clipboardHistory[index]
        return "📄 Preview of item \(index):\n\(item.content)"
    }
    
    private func handleOpen(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: open N"
        }
        guard index < clipboardManager.clipboardHistory.count else {
            return "❌ Invalid index"
        }
        let item = clipboardManager.clipboardHistory[index]
        
        if let url = URL(string: item.content), url.scheme != nil {
            NSWorkspace.shared.open(url)
            return "✅ Opened URL"
        } else {
            return "❌ Not a valid URL"
        }
    }
    
    // MARK: - Transformations
    
    private func handleEdit(_ components: [String]) -> String {
        guard components.count > 1, let _ = Int(components[1]) else {
            return "❌ Usage: edit N"
        }
        return "✅ Edit mode not implemented yet"
    }
    
    private func handleTrim(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: trim N"
        }
        clipboardManager.transformItem(at: index, transform: .trim)
        return "✅ Trimmed item \(index)"
    }
    
    private func handleUppercase(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: uppercase N"
        }
        clipboardManager.transformItem(at: index, transform: .uppercase)
        return "✅ Uppercased item \(index)"
    }
    
    private func handleLowercase(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: lowercase N"
        }
        clipboardManager.transformItem(at: index, transform: .lowercase)
        return "✅ Lowercased item \(index)"
    }
    
    private func handleTitlecase(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: titlecase N"
        }
        clipboardManager.transformItem(at: index, transform: .titlecase)
        return "✅ Titlecased item \(index)"
    }
    
    private func handleCompress(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: compress N"
        }
        clipboardManager.transformItem(at: index, transform: .compress)
        return "✅ Compressed item \(index)"
    }
    
    private func handleFormat(_ components: [String]) -> String {
        guard components.count > 2 else {
            return "❌ Usage: format N as json|yaml"
        }
        guard let index = Int(components[1]) else {
            return "❌ Invalid index"
        }
        
        let format = components[2].lowercased()
        switch format {
        case "json":
            clipboardManager.transformItem(at: index, transform: .formatJSON)
            return "✅ Formatted item \(index) as JSON"
        case "yaml":
            clipboardManager.transformItem(at: index, transform: .formatYAML)
            return "✅ Formatted item \(index) as YAML"
        default:
            return "❌ Unknown format: \(format)"
        }
    }
    
    private func handleConvert(_ components: [String]) -> String {
        guard components.count > 3 else {
            return "❌ Usage: convert N to markdown|plain|rich"
        }
        guard let index = Int(components[1]) else {
            return "❌ Invalid index"
        }
        
        let format = components[3].lowercased()
        switch format {
        case "markdown":
            clipboardManager.transformItem(at: index, transform: .toMarkdown)
            return "✅ Converted item \(index) to Markdown"
        case "plain":
            clipboardManager.transformItem(at: index, transform: .toPlain)
            return "✅ Converted item \(index) to plain text"
        default:
            return "❌ Unknown format: \(format)"
        }
    }
    
    // MARK: - Snippets and Templates
    
    private func handleSnippet(_ components: [String]) -> String {
        guard components.count > 1 else {
            return "❌ Usage: snippet save|list|paste|delete"
        }
        
        let action = components[1].lowercased()
        
        switch action {
        case "save":
            guard components.count > 3, let index = Int(components[3]) else {
                return "❌ Usage: snippet save NAME from N"
            }
            clipboardManager.saveSnippet(name: components[2], from: index)
            return "✅ Saved snippet '\(components[2])'"
        case "list":
            let snippetNames = Array(clipboardManager.snippets.keys).sorted()
            return "📋 Snippets: \(snippetNames.joined(separator: ", "))"
        case "paste":
            guard components.count > 2 else {
                return "❌ Usage: snippet paste NAME"
            }
            clipboardManager.pasteSnippet(name: components[2])
            return "✅ Pasted snippet '\(components[2])'"
        case "delete":
            guard components.count > 2 else {
                return "❌ Usage: snippet delete NAME"
            }
            clipboardManager.snippets.removeValue(forKey: components[2])
            return "✅ Deleted snippet '\(components[2])'"
        default:
            return "❌ Unknown snippet action: \(action)"
        }
    }
    
    private func handleTemplate(_ components: [String]) -> String {
        guard components.count > 2 else {
            return "❌ Usage: template insert NAME"
        }
        clipboardManager.insertTemplate(name: components[2])
        return "✅ Inserted template '\(components[2])'"
    }
    
    private func handleMacro(_ components: [String]) -> String {
        return "✅ Macro functionality not implemented yet"
    }
    
    private func handleShortcut(_ components: [String]) -> String {
        return "✅ Shortcut functionality not implemented yet"
    }
    
    // MARK: - Search and Organization
    
    private func handleSearch(_ components: [String]) -> String {
        guard components.count > 1 else {
            return "❌ Usage: search QUERY"
        }
        let query = components.dropFirst().joined(separator: " ")
        let results = clipboardManager.searchHistory(query: query)
        return "🔍 Found \(results.count) items matching '\(query)'"
    }
    
    private func handleGroup(_ components: [String]) -> String {
        return "✅ Group functionality not implemented yet"
    }
    
    private func handleMerge(_ components: [String]) -> String {
        return "✅ Merge functionality not implemented yet"
    }
    
    // MARK: - Security and Sync
    
    private func handleSync(_ components: [String]) -> String {
        return "✅ Sync functionality not implemented yet"
    }
    
    private func handleExpire(_ components: [String]) -> String {
        return "✅ Expire functionality not implemented yet"
    }
    
    // MARK: - Image Processing
    
    private func handleOCR(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: ocr N"
        }
        clipboardManager.performOCR(on: index)
        return "✅ OCR processing started for item \(index)"
    }
    
    // MARK: - Logging
    
    private func handleLog(_ components: [String]) -> String {
        guard components.count > 1 else {
            return "❌ Usage: log show N"
        }
        
        if components[1] == "show" {
            let count = components.count > 2 ? Int(components[2]) ?? 10 : 10
            let recentLogs = Array(clipboardManager.actionLog.prefix(count))
            let logEntries = recentLogs.map { "\($0.timestamp.formatted()) - \($0.action): \($0.content)" }
            return "📋 Recent actions:\n" + logEntries.joined(separator: "\n")
        }
        
        return "❌ Unknown log action"
    }
    
    // MARK: - Help
    
    private func showHelp() -> String {
        return """
        📋 Srz Clipboard Manager Commands:
        
        Core Actions:
        • paste N — paste entry N
        • append N — append entry N to current clipboard
        • copy N — copy entry N to clipboard
        • pin N / unpin N — pin/unpin entry
        • favorite N / unfavorite N — favorite/unfavorite entry
        • delete N — delete entry
        • lock N — lock/unlock entry
        • clear — clear all non-pinned entries
        • undo — undo last action
        
        View & Search:
        • preview N — show full content of entry N
        • open N — open URL in entry N
        • search QUERY — search history (supports re:regex and "exact")
        
        Transformations:
        • trim N — remove whitespace
        • uppercase N / lowercase N / titlecase N
        • compress N — remove duplicate lines
        • format N as json|yaml
        • convert N to markdown|plain
        
        Snippets & Templates:
        • snippet save NAME from N — save entry N as snippet
        • snippet list — list all snippets
        • snippet paste NAME — paste snippet
        • template insert NAME — insert template
        
        Advanced:
        • ocr N — OCR image entry N
        • log show N — show recent actions
        
        🧠 Smart Content Intelligence:
        • auto-tag [N] — auto-tag entries (URL, Email, Code, etc.)
        • summarize N — auto-summarize long text
        • translate N to LANG — instant translation
        • detect-lang N — show detected language
        • shorten-url N — shorten copied URLs
        • extract-links N — extract all links from text
        
        🚀 Workflow Automation:
        • auto-copy [add NAME PATTERN ACTION] — auto-transform clipboard
        • auto-paste — define auto-paste conditions
        • trigger — keyword-triggered snippets
        • rule — define clipboard rules
        
        📅 Time & Context Awareness:
        • stats N — show entry usage statistics
        • reminder N "message" at TIME — set reminders
        • schedule N at TIME — schedule auto-paste
        
        🧩 Deep Integration:
        • send N to APP — send to specific app
        • webhook N — send to webhook endpoint
        • export — export history to JSON/CSV
        • import — import snippets from files
        • ai-format N — AI-powered code formatting
        
        Keyboard Shortcuts:
        • Enter — paste selected
        • Space — preview selected
        • Cmd+C — copy selected
        • Cmd+T — pin selected
        • Del — delete selected
        • Esc — close
        """
    }
    
    // MARK: - Smart Content Intelligence Handlers
    
    private func handleAutoTag(_ components: [String]) -> String {
        if components.count == 1 {
            // Auto-tag all items
            for (index, item) in clipboardManager.clipboardHistory.enumerated() {
                let tags = clipboardManager.autoTag(item)
                clipboardManager.clipboardHistory[index].tags.append(contentsOf: tags)
            }
            return "✅ Auto-tagged all items"
        }
        
        guard let index = Int(components[1]) else {
            return "❌ Usage: auto-tag [N]"
        }
        
        if index < clipboardManager.clipboardHistory.count {
            var item = clipboardManager.clipboardHistory[index]
            let tags = clipboardManager.autoTag(item)
            item.tags.append(contentsOf: tags)
            return "✅ Auto-tagged item \(index): \(tags.joined(separator: ", "))"
        }
        
        return "❌ Invalid index"
    }
    
    private func handleSummarize(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: summarize N"
        }
        
        if index < clipboardManager.clipboardHistory.count {
            let item = clipboardManager.clipboardHistory[index]
            let summary = clipboardManager.summarize(item.content)
            return "📝 Summary: \(summary)"
        }
        
        return "❌ Invalid index"
    }
    
    private func handleTranslate(_ components: [String]) -> String {
        guard components.count > 3, let index = Int(components[1]) else {
            return "❌ Usage: translate N to LANG"
        }
        
        let targetLang = components[3]
        if index < clipboardManager.clipboardHistory.count {
            let _ = clipboardManager.clipboardHistory[index]
            // Simple placeholder - in production, use translation API
            return "🌐 Translation to \(targetLang): [Translation service not implemented]"
        }
        
        return "❌ Invalid index"
    }
    
    private func handleDetectLang(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: detect-lang N"
        }
        
        if index < clipboardManager.clipboardHistory.count {
            let item = clipboardManager.clipboardHistory[index]
            let language = clipboardManager.detectLanguage(item.content)
            return "🌍 Detected language: \(language)"
        }
        
        return "❌ Invalid index"
    }
    
    private func handleShortenURL(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: shorten-url N"
        }
        
        if index < clipboardManager.clipboardHistory.count {
            let item = clipboardManager.clipboardHistory[index]
            let shortened = clipboardManager.shortenURL(item.content)
            return "🔗 Shortened URL: \(shortened)"
        }
        
        return "❌ Invalid index"
    }
    
    private func handleExtractLinks(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: extract-links N"
        }
        
        if index < clipboardManager.clipboardHistory.count {
            let item = clipboardManager.clipboardHistory[index]
            let links = clipboardManager.extractLinks(item.content)
            return "🔗 Extracted links: \(links.joined(separator: ", "))"
        }
        
        return "❌ Invalid index"
    }
    
    // MARK: - Workflow Automation Handlers
    
    private func handleAutoCopy(_ components: [String]) -> String {
        if components.count == 1 {
            return "📋 Auto-copy rules:\n" + clipboardManager.autoRules.map { "• \($0.name): \($0.pattern) → \($0.action)" }.joined(separator: "\n")
        }
        
        if components[1] == "add" && components.count > 4 {
            let name = components[2]
            let pattern = components[3]
            let action = components[4]
            clipboardManager.addAutoRule(name: name, pattern: pattern, action: action)
            return "✅ Added auto-copy rule: \(name)"
        }
        
        return "❌ Usage: auto-copy [add NAME PATTERN ACTION]"
    }
    
    private func handleAutoPaste(_ components: [String]) -> String {
        return "✅ Auto-paste feature not implemented yet"
    }
    
    private func handleTrigger(_ components: [String]) -> String {
        return "✅ Trigger keyword feature not implemented yet"
    }
    
    private func handleRule(_ components: [String]) -> String {
        return "✅ Clipboard rules feature not implemented yet"
    }
    
    // MARK: - Time & Context Awareness Handlers
    
    private func handleStats(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: stats N"
        }
        
        if index < clipboardManager.clipboardHistory.count {
            let item = clipboardManager.clipboardHistory[index]
            let itemId = item.id.uuidString
            let stats = clipboardManager.entryStats[itemId]
            
            var result = "📊 Stats for item \(index):\n"
            result += "• Use count: \(stats?.useCount ?? 0)\n"
            result += "• Last used: \(stats?.lastUsed.formatted() ?? "Never")\n"
            result += "• Language: \(stats?.language ?? "Unknown")\n"
            result += "• Links: \(stats?.extractedLinks.count ?? 0)\n"
            result += "• Tags: \(stats?.tags.joined(separator: ", ") ?? "None")"
            
            return result
        }
        
        return "❌ Invalid index"
    }
    
    private func handleReminder(_ components: [String]) -> String {
        guard components.count > 4, let index = Int(components[1]) else {
            return "❌ Usage: reminder N \"message\" at TIME"
        }
        
        let message = components[2].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        let _ = components[4]
        
        // Simple time parsing - in production, use proper date parsing
        let scheduledTime = Date().addingTimeInterval(3600) // 1 hour from now as placeholder
        
        if index < clipboardManager.clipboardHistory.count {
            let item = clipboardManager.clipboardHistory[index]
            clipboardManager.addReminder(entryId: item.id.uuidString, message: message, scheduledTime: scheduledTime)
            return "⏰ Reminder set for item \(index): \(message)"
        }
        
        return "❌ Invalid index"
    }
    
    private func handleSchedule(_ components: [String]) -> String {
        guard components.count > 3, let index = Int(components[1]) else {
            return "❌ Usage: schedule N at TIME"
        }
        
        let _ = components[3]
        let scheduledTime = Date().addingTimeInterval(3600) // 1 hour from now as placeholder
        
        if index < clipboardManager.clipboardHistory.count {
            let item = clipboardManager.clipboardHistory[index]
            clipboardManager.schedulePaste(entryId: item.id.uuidString, scheduledTime: scheduledTime)
            return "⏰ Scheduled paste for item \(index) at \(scheduledTime.formatted())"
        }
        
        return "❌ Invalid index"
    }
    
    // MARK: - Deep Integration Handlers
    
    private func handleSend(_ components: [String]) -> String {
        return "✅ Send to app feature not implemented yet"
    }
    
    private func handleWebhook(_ components: [String]) -> String {
        return "✅ Webhook feature not implemented yet"
    }
    
    private func handleExport(_ components: [String]) -> String {
        return "✅ Export feature not implemented yet"
    }
    
    private func handleImport(_ components: [String]) -> String {
        return "✅ Import feature not implemented yet"
    }
    
    private func handleAIFormat(_ components: [String]) -> String {
        guard components.count > 1, let index = Int(components[1]) else {
            return "❌ Usage: ai-format N"
        }
        
        if index < clipboardManager.clipboardHistory.count {
            let item = clipboardManager.clipboardHistory[index]
            // Simple AI formatting placeholder
            let formatted = clipboardManager.formatJSON(item.content)
            return "🤖 AI formatted:\n\(formatted)"
        }
        
        return "❌ Invalid index"
    }
}
