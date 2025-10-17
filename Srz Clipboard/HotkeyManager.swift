//
//  HotkeyManager.swift
//  Srz Clipboard
//
//  Created by Md Sohag Islam on 18/10/25.
//

import Foundation
import Carbon
import AppKit
import SwiftUI
import Combine

extension OSType {
    init(fourCharCode: String) {
        precondition(fourCharCode.count == 4)
        var result: UInt32 = 0
        for char in fourCharCode.utf8 {
            result = (result << 8) + UInt32(char)
        }
        self = result
    }
}

class HotkeyManager: ObservableObject {
    private var hotkeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    
    var onHotkeyPressed: (() -> Void)?
    
    init() {
        setupHotkey()
    }
    
    deinit {
        unregisterHotkey()
    }
    
                private func setupHotkey() {
                    // Register Cmd+Alt+V hotkey
                    let keyCode = UInt32(kVK_ANSI_V) // V key
                    let modifiers = UInt32(cmdKey | optionKey)
                    
                    var hotkeyID = EventHotKeyID()
                    hotkeyID.signature = OSType(fourCharCode: "htk1")
                    hotkeyID.id = 1
                    
                    let status = RegisterEventHotKey(
                        keyCode,
                        modifiers,
                        hotkeyID,
                        GetApplicationEventTarget(),
                        0,
                        &hotkeyRef
                    )
                    
                    print("Hotkey registration status: \(status)")
                    if status == noErr {
                        print("Hotkey registered successfully")
                        installEventHandler()
                    } else {
                        print("Failed to register hotkey with error: \(status)")
                    }
                }
    
    private func installEventHandler() {
        let eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        
        let installStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, theEvent, userData) -> OSStatus in
                print("Hotkey pressed!")
                if let hotkeyManager = Unmanaged<HotkeyManager>.fromOpaque(userData!).takeUnretainedValue() as HotkeyManager? {
                    DispatchQueue.main.async {
                        print("Calling hotkey action")
                        hotkeyManager.onHotkeyPressed?()
                    }
                }
                return noErr
            },
            1,
            [eventType],
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
        
        print("Event handler install status: \(installStatus)")
    }
    
    private func unregisterHotkey() {
        if let hotkeyRef = hotkeyRef {
            UnregisterEventHotKey(hotkeyRef)
        }
        
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }
    
    func setHotkeyAction(_ action: @escaping () -> Void) {
        onHotkeyPressed = action
    }
}
