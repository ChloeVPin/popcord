# Popcord 🍿

> **A Native macOS Menu Bar Companion for Discord**  
> Click or hit the global hotkey (`⌃⌥⌘D`) to open a small, resizable native panel hosting full Discord Web, deep-linked directly to your primary channel.

---

## Features

- **Menu Bar Companion:** Instant access to full Discord Web from a compact native popover panel.
- **Primary Channel Deep-Linking:** Automatically lands on your primary guild channel or DM when shown.
- **Global Hotkey:** Rebindable global shortcut (`⌃⌥⌘D` default) to toggle show/hide from any application.
- **Native Notifications & Badge:** Intercepts WebKit notifications and title unreads to present macOS system banners and a red menu bar icon badge.
- **Full Discord Capabilities:** Video/voice channels, media capture (mic/camera), file uploads/downloads, popups, and persistent login sessions.
- **Privacy & Security:** Runs 100% on-device inside WebKit; no account system or token-scraping proxy server.
- **Modular Licensing:** Integrated 14-day trial and Keychain-backed one-time paid license gate ($9).

---

## Toolchain & Requirements

- **Platform Target:** macOS 14.0+ (`MACOSX_DEPLOYMENT_TARGET = 14.0`)
- **Verified Toolchain:** Xcode 27.0 / Xcode 26.6 Baseline (Build 27A5218g), Apple Swift 6.4 Compiler with Swift 6 Concurrency support.
- **Dependencies:** Built cleanly with native macOS frameworks (`WebKit`, `AppKit`, `SwiftUI`, `Carbon`, `UserNotifications`, `ServiceManagement`, `Security`).

---

## How to Build & Run

### 1. Xcode Build Command Line
```bash
# Clone or navigate to directory
cd /path/to/popcord

# Build Debug target
xcodebuild -project Popcord.xcodeproj -scheme Popcord -configuration Debug build
```

### 2. Open in Xcode
1. Open `Popcord.xcodeproj` in Xcode.
2. Select target **Popcord** and destination **My Mac**.
3. Press `⌘R` to build and run.

---

## Distribution, Entitlements & Notarization

Popcord is configured with distribution-ready sandboxed entitlements:
- `com.apple.security.network.client` (Network client)
- `com.apple.security.files.user-selected.read-write` (File upload/download)
- `com.apple.security.device.camera` & `microphone` (Voice & video support)

### Notarization & Direct Distribution
For direct Developer ID distribution outside the Mac App Store:
```bash
# Archive build
xcodebuild -project Popcord.xcodeproj -scheme Popcord -configuration Release archive -archivePath ./build/Popcord.xcarchive

# Notarize via notarytool
xcrun notarytool submit ./build/Popcord.zip --keychain-profile "DeveloperID" --wait
```

---

## Authoritative Documentation & References

- [Apple Human Interface Guidelines - Menus & Status Items](https://developer.apple.com/design/human-interface-guidelines/the-menu-bar/)
- [WebKit WKWebView Documentation](https://developer.apple.com/documentation/webkit/wkwebview)
- [Apple ServiceManagement SMAppService](https://developer.apple.com/documentation/servicemanagement/smappservice)
- [Discord Developer Terms of Service](https://support-dev.discord.com/hc/en-us/articles/8563934450327-Discord-Developer-Terms-of-Service)
