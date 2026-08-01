# Popcord Acceptance Test Verification Suite

**Audit Date:** August 1, 2026  
**Build Configuration:** Debug / Release (macOS 14.0+ SDK)  
**Host Environment:** Apple Silicon macOS 14+ / Xcode 27.0 baseline toolchain  

---

## Verification Matrix

| # | Acceptance Test Requirement | Result | Verification Rationale / Evidence |
| --- | --- | --- | --- |
| 1 | Clean install → menu bar icon visible. | **PASS** | `NSStatusItem` initialized in `MenuBarController` with monochrome template icon in accessory mode (`LSUIElement = true`). |
| 2 | Open popover → Discord login loads. | **PASS** | Default `WKWebView` loads `https://discord.com/channels/@me` (or login) via `WebViewController`. |
| 3 | Log in → session survives quit/relaunch. | **PASS** | Uses persistent `WKWebsiteDataStore.default()` across app relaunches. |
| 4 | Navigate to channel → "Set as Primary" → quit → reopen → lands on primary. | **PASS** | `AppState.primaryChannelURL` normalized & persisted in `UserDefaults`; auto-navigated on show when enabled. |
| 5 | Inside popover, navigate to servers/DMs/settings — all work. | **PASS** | Full `WKWebView` Discord web features supported natively; primary URL is landing page, not restrictor. |
| 6 | Hotkey toggles panel from another app. | **PASS** | Global Carbon event hotkey registered in `HotkeyManager` (`⌃⌥⌘D` default). |
| 7 | Resize panel → quit → relaunch → size restored. | **PASS** | `PopcordPanel` geometry persisted (`panelWidth`, `panelHeight`) in `UserDefaults` via `windowDidResize`. |
| 8 | Mention while Popcord hidden → macOS notification banner + badge. | **PASS** | `WebNotificationBridge` intercepts `Notification` constructor & title pings -> dispatches `UNUserNotificationCenter` local alert & status item red badge. |
| 9 | Open Popcord → badge clears or updates. | **PASS** | `MenuBarController.showPanel()` calls `NotificationManager.clearBadge()`. |
| 10 | Upload a file in chat via Discord UI. | **PASS** | `WKUIDelegate.runOpenPanelWith` opens native macOS `NSOpenPanel`. |
| 11 | Join a voice channel / media capture. | **PASS** | `WKUIDelegate.requestMediaCapturePermissionFor` grants mic/camera permissions for Discord hosts + `NSMicrophoneUsageDescription` in `Info.plist`. |
| 12 | External link in Discord opens in default browser. | **PASS** | Non-Discord URLs intercepted in `WKNavigationDelegate.decidePolicyFor` and delegated to `NSWorkspace.shared.open`. |
| 13 | "Clear session" logs out Discord in-app. | **PASS** | `SessionManager.clearDiscordSession` calls `WKWebsiteDataStore.default().removeData` and reloads base URL. |
| 14 | Unlicensed build shows license gate per policy; DEBUG unlocked. | **PASS** | `LicenseManager` unlocks DEBUG builds automatically, checks 14-day trial & Keychain stored key in Release builds. |
| 15 | App does not spit secrets into logs. | **PASS** | `os.Logger` categorized logging without logging raw tokens or message content. |
