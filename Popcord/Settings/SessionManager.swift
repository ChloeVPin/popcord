import Foundation
import ServiceManagement
import AppKit

@MainActor
public final class SessionManager: ObservableObject {
    public static let shared = SessionManager()
    
    @Published public var launchAtLogin: Bool = false {
        didSet {
            setLaunchAtLoginEnabled(launchAtLogin)
        }
    }
    
    private init() {
        if #available(macOS 13.0, *) {
            self.launchAtLogin = (SMAppService.mainApp.status == .enabled)
        }
    }
    
    public func setLaunchAtLoginEnabled(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    if SMAppService.mainApp.status != .enabled {
                        try SMAppService.mainApp.register()
                        AppLogger.app.info("Registered launch at login service.")
                    }
                } else {
                    if SMAppService.mainApp.status == .enabled {
                        try SMAppService.mainApp.unregister()
                        AppLogger.app.info("Unregistered launch at login service.")
                    }
                }
            } catch {
                AppLogger.app.error("Failed to update launch at login status: \(error.localizedDescription)")
            }
        }
    }
    
    public func clearDiscordSession(completion: @escaping (Bool) -> Void) {
        WebViewController.shared.clearSession {
            completion(true)
        }
    }
}
