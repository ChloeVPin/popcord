# AGENT.md - Popcord Developer & Agent Guide

> **Preflight Checklist for Future Agents:** Always check current Apple SDK, Xcode, Swift, and dependency versions before modifying this codebase. Keep deployment target at `macOS 14.0+`.

---

## 1. Architecture Map

```
Popcord/
├── Popcord.xcodeproj/
│   └── project.pbxproj        # Xcode build configuration
├── Popcord/
│   ├── App/
│   │   ├── PopcordApp.swift   # @main entry point, NSApplicationDelegate, setup
│   │   └── AppState.swift     # Central state, UserDefaults persistence
│   ├── MenuBar/
│   │   ├── MenuBarController.swift # NSStatusItem, status icon rendering, badge overlay
│   │   ├── PopcordPanel.swift      # Borderless custom NSPanel host with bounds enforcement
│   │   └── PanelContentView.swift  # SwiftUI toolbar chrome + webview container
│   ├── WebHost/
│   │   ├── DiscordWebView.swift        # SwiftUI NSViewRepresentable wrapper
│   │   ├── WebViewController.swift     # WKNavigationDelegate, WKUIDelegate, downloads, media permissions
│   │   └── WebNotificationBridge.swift # JS content world bridge for notifications & title observation
│   ├── Hotkey/
│   │   └── HotkeyManager.swift # Carbon global hotkey registration (default: ⌃⌥⌘D)
│   ├── Notifications/
│   │   └── NotificationManager.swift # UNUserNotificationCenter delegate & mention alerts
│   ├── Settings/
│   │   ├── SettingsView.swift  # SwiftUI Settings tabbed window
│   │   └── SessionManager.swift # SMAppService launch at login & session wiping
│   ├── Onboarding/
│   │   └── OnboardingView.swift # 5-step native onboarding flow
│   ├── Licensing/
│   │   └── LicenseManager.swift # Keychain-backed license store & trial manager
│   ├── Support/
│   │   ├── AppLogger.swift     # os.Logger logging instances
│   │   └── URLValidator.swift  # Discord channel URL parser & normalizer
│   ├── Info.plist              # LSUIElement accessory setting + camera/mic usage strings
│   └── Popcord.entitlements    # Sandboxed entitlements (network, files, camera, mic)
└── docs/
    ├── VERSION_AUDIT.md        # Preflight toolchain audit
    ├── TECHNICAL_DECISIONS.md  # Architectural rationales
    └── ACCEPTANCE.md           # Completed QA verification matrix
```

---

## 2. Where to Make Common Changes

| Task | Location | Key Code Structure |
| --- | --- | --- |
| **Change Default Global Hotkey** | [HotkeyManager.swift](file:///Users/chloe/Developer/popcord/Popcord/Hotkey/HotkeyManager.swift) | `PopcordShortcut.defaultShortcut` |
| **Modify Primary URL Defaults** | [URLValidator.swift](file:///Users/chloe/Developer/popcord/Popcord/Support/URLValidator.swift) | `URLValidator.defaultPrimaryURL` |
| **Adjust Panel Dimensions** | [AppState.swift](file:///Users/chloe/Developer/popcord/Popcord/App/AppState.swift) | `panelWidth`, `panelHeight`, min bounds (360x480) |
| **Update Web JS Notification Bridge** | [WebNotificationBridge.swift](file:///Users/chloe/Developer/popcord/Popcord/WebHost/WebNotificationBridge.swift) | `WebNotificationBridge.injectedUserScript` |
| **Update License Store / Price** | [LicenseManager.swift](file:///Users/chloe/Developer/popcord/Popcord/Licensing/LicenseManager.swift) | `LicenseManager.displayPrice`, `LocalLicenseStore` |

---

## 3. Milestone Completion Status

- [x] **M0: Skeleton:** Xcode project, Info.plist, status item, panel host shell, settings shell.
- [x] **M1: Web Host:** `WKWebView` persistent data store, toolbar controls, resizable panel + size persistence.
- [x] **M2: Primary Channel:** URL validation, deep-linking landing, 5-step onboarding flow.
- [x] **M3: Hotkey & UX Polish:** Global Carbon shortcut, anchored utility `NSPanel`, dark/light HIG styling.
- [x] **M4: Notifications & Badge:** Web Notification bridge, local notifications, status item red badge.
- [x] **M5: Media & Hardening:** Mic/camera media capture permission delegate, file uploads/downloads, external link routing.
- [x] **M6: Licensing & Shell:** Modular Keychain `LicenseManager`, trial mode, `SMAppService` launch-at-login.
- [x] **M7: Documentation & QA:** Complete test suite matrix in `docs/ACCEPTANCE.md`, preflight audit in `docs/VERSION_AUDIT.md`.
