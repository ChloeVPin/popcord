import Foundation
import UserNotifications
import AppKit

@MainActor
public final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationManager()
    
    @Published public private(set) var isAuthorized: Bool = false
    @Published public var enableMentionNotifications: Bool = true {
        didSet { UserDefaults.standard.set(enableMentionNotifications, forKey: "popcord_enable_notifications") }
    }
    @Published public var showMenuBarBadge: Bool = true {
        didSet { UserDefaults.standard.set(showMenuBarBadge, forKey: "popcord_show_badge") }
    }
    @Published public var suppressWhenFocused: Bool = false {
        didSet { UserDefaults.standard.set(suppressWhenFocused, forKey: "popcord_suppress_focused") }
    }
    
    public var onNotificationClicked: (() -> Void)?
    public var onBadgeCountChanged: ((Int) -> Void)?
    
    @Published public private(set) var unreadCount: Int = 0 {
        didSet {
            onBadgeCountChanged?(unreadCount)
        }
    }
    
    override private init() {
        super.init()
        self.enableMentionNotifications = UserDefaults.standard.object(forKey: "popcord_enable_notifications") as? Bool ?? true
        self.showMenuBarBadge = UserDefaults.standard.object(forKey: "popcord_show_badge") as? Bool ?? true
        self.suppressWhenFocused = UserDefaults.standard.object(forKey: "popcord_suppress_focused") as? Bool ?? false
        
        UNUserNotificationCenter.current().delegate = self
        checkAuthorization()
    }
    
    public func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            Task { @MainActor in
                self.isAuthorized = granted
                if let error = error {
                    AppLogger.notify.error("Notification authorization error: \(error.localizedDescription)")
                } else {
                    AppLogger.notify.info("Notification authorization status: \(granted)")
                }
            }
        }
    }
    
    public func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                self.isAuthorized = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    public func postMentionNotification(title: String, body: String, isFocused: Bool) {
        if suppressWhenFocused && isFocused { return }
        
        incrementBadge()
        
        guard enableMentionNotifications else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title.isEmpty ? "Popcord Mention" : title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                AppLogger.notify.error("Failed to schedule local notification: \(error.localizedDescription)")
            }
        }
    }
    
    public func incrementBadge() {
        unreadCount += 1
    }
    
    public func clearBadge() {
        unreadCount = 0
    }
    
    public func updateBadgeFromTitle(_ title: String) {
        // Discord title format example: "(3) Discord | #general | Guild" or "(1) Discord"
        if let firstParen = title.firstIndex(of: "("),
           let secondParen = title.firstIndex(of: ")"),
           firstParen < secondParen {
            let countString = title[title.index(after: firstParen)..<secondParen]
            if let count = Int(countString) {
                unreadCount = count
                return
            }
        }
        if !title.contains("(") {
            // No unread indicator in title
            // Note: Don't clear immediately if explicit mention notifications were logged, but update if 0
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    public nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
    
    public nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Task { @MainActor in
            self.onNotificationClicked?()
        }
        completionHandler()
    }
}
