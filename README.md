# Popcord 🍿

<p align="center">
  <img src="Popcord/Assets.xcassets/AppIcon.appiconset/icon_512x512.png" width="128" height="128" alt="Popcord App Icon" />
</p>

<h3 align="center">
  A Free, Native macOS Menu Bar Companion for Discord
</h3>

<p align="center">
  <a href="https://github.com/ChloeVPin/popcord/actions"><img src="https://img.shields.io/badge/build-passing-brightgreen?style=flat-square&logo=apple" alt="Build Status" /></a>
  <a href="https://developer.apple.com/macos/"><img src="https://img.shields.io/badge/platform-macOS%2014.0%2B-blue?style=flat-square&logo=apple" alt="Platform" /></a>
  <a href="https://swift.org"><img src="https://img.shields.io/badge/swift-5.0%2B-orange?style=flat-square&logo=swift" alt="Swift" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-purple?style=flat-square" alt="License" /></a>
  <a href="https://github.com/ChloeVPin/popcord/releases"><img src="https://img.shields.io/badge/updates-automatic%20in--app-5865F2?style=flat-square&logo=github" alt="Auto Updates" /></a>
</p>

---

## 🚀 Overview

**Popcord** brings your Discord messages, voice channels, and DMs straight to your macOS status bar. Built natively using **SwiftUI**, **AppKit**, and **WebKit**, Popcord lives in your menu bar and pops open instantly with a single click or keyboard shortcut.

- **Zero Bloat:** Lightweight, fast, and stays out of your workspace until you need it.
- **100% On-Device Privacy:** Direct WebKit container execution — no proxy servers, zero telemetry, no token scraping.
- **Free & Open Source:** Completely free under the MIT License.

---

## ✨ Features

- **🍿 Menu Bar Companion:** Instant popover panel hosting full Discord Web with persistent login sessions.
- **🔄 Seamless In-App Updates:** Check, download, patch, and restart automatically inside the app — no browser redirects.
- **🎨 Adaptive System Appearance:** Automatically matches your macOS Light Mode and Dark Mode preference.
- **⌨️ Global Keyboard Shortcut:** Press `⌃⌥⌘D` (customizable) to toggle Popcord from anywhere in macOS.
- **🔔 Native System Banners & Unread Badges:** Intercepts mentions to send native macOS notifications and updates a high-contrast red badge dot on your menu bar icon.
- **🎙️ Full Audio, Video & Camera Support:** Voice channels, video calls, screen sharing, and media file uploads/downloads.
- **⚙️ Native HIG Settings:** Single-line form controls following Apple’s Human Interface Guidelines.
- **📜 Rich Markdown Changelog:** View rendered release notes directly in the settings panel (`MarkdownView`).

---

## 🛠️ Toolchain & Requirements

| Requirement | Specification |
| :--- | :--- |
| **Operating System** | macOS 14.0 (Sonoma) or newer |
| **Language** | Swift 5.0+ (`@MainActor`, `async/await`, `Combine`) |
| **Frameworks** | `SwiftUI`, `AppKit`, `WebKit`, `Carbon`, `UserNotifications` |
| **Build System** | Xcode 15.0+ / `xcodebuild` |

---

## 🔨 Building from Source

```bash
# 1. Clone repository
git clone https://github.com/ChloeVPin/popcord.git
cd popcord

# 2. Build Debug binary
xcodebuild -project Popcord.xcodeproj -scheme Popcord -configuration Debug build
```

Or open `Popcord.xcodeproj` in Xcode and press `⌘R`.

---

## 🔒 Security & Entitlements

Popcord runs in Apple’s hardened runtime sandbox with explicitly scoped entitlements:

- `com.apple.security.network.client`: Secure HTTPS web connections to Discord servers.
- `com.apple.security.files.user-selected.read-write`: User-initiated file uploads and downloads.
- `com.apple.security.device.camera` & `microphone`: Hardware access for voice and video channels.

---

## 📄 License

Popcord is distributed under the **MIT License**. See [`LICENSE`](LICENSE) for details.
