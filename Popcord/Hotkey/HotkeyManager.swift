import Foundation
import AppKit
import Carbon

public struct PopcordShortcut: Codable, Equatable {
    public var keyCode: UInt32
    public var modifierFlags: UInt32
    
    public init(keyCode: UInt32, modifierFlags: UInt32) {
        self.keyCode = keyCode
        self.modifierFlags = modifierFlags
    }
    
    /// Default shortcut: ⌃⌥⌘D (Control-Option-Command-D, Carbon keyCode 2 for 'D')
    public static let defaultShortcut = PopcordShortcut(
        keyCode: UInt32(kVK_ANSI_D),
        modifierFlags: UInt32(cmdKey | optionKey | controlKey)
    )
    
    public var displayString: String {
        var str = ""
        if (modifierFlags & UInt32(controlKey)) != 0 { str += "⌃" }
        if (modifierFlags & UInt32(optionKey)) != 0 { str += "⌥" }
        if (modifierFlags & UInt32(cmdKey)) != 0 { str += "⌘" }
        if (modifierFlags & UInt32(shiftKey)) != 0 { str += "⇧" }
        str += keyName(for: keyCode)
        return str
    }
    
    private func keyName(for code: UInt32) -> String {
        switch Int(code) {
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_Z: return "Z"
        case kVK_Space: return "Space"
        default: return "Code \(code)"
        }
    }
}

@MainActor
public final class HotkeyManager: ObservableObject {
    public static let shared = HotkeyManager()
    
    @Published public var currentShortcut: PopcordShortcut {
        didSet {
            saveShortcut()
            registerGlobalHotkey()
        }
    }
    
    @Published public var isEnabled: Bool = true {
        didSet {
            if isEnabled {
                registerGlobalHotkey()
            } else {
                unregisterGlobalHotkey()
            }
        }
    }
    
    public var onHotkeyTriggered: (() -> Void)?
    
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private let shortcutKey = "popcord_global_hotkey"
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: shortcutKey),
           let decoded = try? JSONDecoder().decode(PopcordShortcut.self, from: data) {
            self.currentShortcut = decoded
        } else {
            self.currentShortcut = .defaultShortcut
        }
    }
    
    public func start() {
        registerGlobalHotkey()
    }
    
    public func registerGlobalHotkey() {
        unregisterGlobalHotkey()
        guard isEnabled else { return }
        
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x504F5043) // 'POPC'
        hotKeyID.id = 1
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        
        let status = InstallEventHandler(
            GetEventDispatcherTarget(),
            { (_, event, userData) -> OSStatus in
                guard let userData = userData else { return noErr }
                let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                DispatchQueue.main.async {
                    manager.onHotkeyTriggered?()
                }
                return noErr
            },
            1,
            &eventType,
            selfPointer,
            &eventHandlerRef
        )
        
        if status != noErr {
            AppLogger.hotkey.error("Failed to install Carbon event handler: \(status)")
            return
        }
        
        let registerStatus = RegisterEventHotKey(
            currentShortcut.keyCode,
            currentShortcut.modifierFlags,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )
        
        if registerStatus == noErr {
            AppLogger.hotkey.info("Global hotkey registered: \(self.currentShortcut.displayString)")
        } else {
            AppLogger.hotkey.error("Failed to register Carbon hotkey: \(registerStatus)")
        }
    }
    
    public func unregisterGlobalHotkey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandlerRef = eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
    }
    
    private func saveShortcut() {
        if let data = try? JSONEncoder().encode(currentShortcut) {
            UserDefaults.standard.set(data, forKey: shortcutKey)
        }
    }
}
