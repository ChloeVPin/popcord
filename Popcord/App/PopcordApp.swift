import SwiftUI
import AppKit

@main
struct PopcordApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // No extra window scenes created - everything runs 100% inside the menu bar attached NSPopover!
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Run strictly in menu bar accessory mode without Dock icon clutter
        NSApp.setActivationPolicy(.accessory)
        
        // 1. Setup Menu Bar Status Item & Attached Popover
        MenuBarController.shared.setup(contentView: AnyView(PanelContentView()))
        
        // 2. Setup Global Hotkey Callback
        HotkeyManager.shared.onHotkeyTriggered = {
            Task { @MainActor in
                MenuBarController.shared.togglePanel()
            }
        }
        HotkeyManager.shared.start()
        
        // 3. Check Notification Authorization
        NotificationManager.shared.checkAuthorization()
        
        // 4. Initial Navigation to Discord Home
        AppState.shared.navigateToHome()
        
        // 5. Automatically check for updates on launch
        UpdateManager.shared.checkForUpdates()
    }
}
