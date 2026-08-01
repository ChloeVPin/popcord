import Foundation
import os

/// Centralized logger using unified logging (`os.Logger`).
public enum AppLogger {
    public static let app = Logger(subsystem: "com.chloe.popcord", category: "app")
    public static let web = Logger(subsystem: "com.chloe.popcord", category: "web")
    public static let notify = Logger(subsystem: "com.chloe.popcord", category: "notify")
    public static let hotkey = Logger(subsystem: "com.chloe.popcord", category: "hotkey")
    public static let license = Logger(subsystem: "com.chloe.popcord", category: "license")
}
