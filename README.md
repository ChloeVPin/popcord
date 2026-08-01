<div align="center">

# Popcord

<br />

<img src="docs/logo.png" width="128" height="128" alt="Popcord Logo" />

<br />
<br />

<p><strong>Native macOS Menu Bar Companion for Discord</strong></p>

<p align="center">
  <a href="https://github.com/ChloeVPin/popcord/actions"><img src="https://img.shields.io/github/actions/workflow/status/ChloeVPin/popcord/ci.yml?branch=main" alt="CI Status" /></a>
  <a href="https://developer.apple.com/macos/"><img src="https://img.shields.io/badge/platform-macOS_14.0+-007ACC?logo=apple&logoColor=white" alt="Platform" /></a>
  <a href="https://swift.org"><img src="https://img.shields.io/badge/swift-5.0+-F05138?logo=swift&logoColor=white" alt="Swift" /></a>
  <a href="https://github.com/ChloeVPin/popcord/blob/main/LICENSE"><img src="https://img.shields.io/github/license/ChloeVPin/popcord?color=7C4DFF" alt="License" /></a>
  <a href="https://github.com/ChloeVPin/popcord/releases"><img src="https://img.shields.io/github/v/release/ChloeVPin/popcord?color=5865F2&label=release" alt="Release" /></a>
</p>

</div>

---

## Architecture & Update Scope

Popcord operates as a lightweight, native macOS host wrapper around Apple's WebKit framework.

- **Native App Shell Updates:** In-app update checks and automatic patching apply exclusively to Popcord's native Swift companion (menu bar integration, global hotkeys, notification bridges, and window management).
- **Discord Live Web Updates:** Discord updates automatically in real-time within the WebKit process. Popcord does not intercept, modify, or proxy Discord's web application assets.
- **Zero Proxy / Zero Telemetry:** Requests flow directly between WebKit and Discord servers with zero intermediary proxies, data collection, or token scraping.

---

## Core Capabilities

| Feature | Technical Implementation |
| :--- | :--- |
| **Menu Bar Companion** | Native `NSStatusItem` & custom `NSPanel` popover window |
| **In-App Auto-Updates** | Direct background release extraction and automatic app relaunch |
| **Adaptive System Theme** | Dynamic light/dark mode adaptation via SwiftUI and WebKit appearance |
| **Global Keyboard Shortcut** | Carbon Event Manager hotkey listener (`Control + Option + Command + D`) |
| **Native Notifications** | Intercepts WebKit notifications to dispatch macOS system alerts |
| **Unread Indicator** | High-contrast status bar unread badge dot |
| **Media Hardware Support** | Full WebCore audio, video, camera, and microphone entitlement access |
| **HIG Form Interface** | Single-line grouped SwiftUI settings layout |

---

## Build System Requirements

- **Operating System:** macOS 14.0 (Sonoma) or newer
- **Developer Tools:** Xcode 15.0+ or `xcodebuild`
- **SDK Target:** macOS 14.0+ (`MACOSX_DEPLOYMENT_TARGET = 14.0`)
- **Framework Dependencies:** `SwiftUI`, `AppKit`, `WebKit`, `Carbon`, `UserNotifications`

---

## Building & Compiling

Clone the repository and build using `xcodebuild`:

```bash
git clone https://github.com/ChloeVPin/popcord.git
cd popcord
xcodebuild -project Popcord.xcodeproj -scheme Popcord -configuration Debug build
```

To run directly from Xcode, open `Popcord.xcodeproj` and execute `Product -> Run` (`Cmd + R`).

---

## Security & Sandbox Entitlements

Popcord is signed with Apple's hardened runtime sandbox entitlements:

- `com.apple.security.network.client`: Outbound HTTPS connections to Discord.
- `com.apple.security.files.user-selected.read-write`: User file attachment transfers.
- `com.apple.security.device.camera`: Camera access for Discord video channels.
- `com.apple.security.device.microphone`: Microphone access for Discord voice channels.

---

## License

Popcord is open source software licensed under the [MIT License](LICENSE).
