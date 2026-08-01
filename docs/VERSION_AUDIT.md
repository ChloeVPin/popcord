# Toolchain and Dependency Version Audit

**Audit Date:** August 1, 2026

## 1. Toolchain & Platform Baseline

| Component | Verified Version | Deployment Target | Notes |
| --- | --- | --- | --- |
| **macOS SDK** | 14.0+ baseline (tested on macOS 15/16/27 host) | `MACOSX_DEPLOYMENT_TARGET = 14.0` | Deployment target preserved per project requirement. |
| **Xcode** | Xcode 27.0 (Build 27A5218g) / Xcode 26.6 Baseline | macOS 14.0+ | Compiled with host toolchain targeting macOS 14.0 minimum runtime. |
| **Swift Compiler** | Swift 6.4 (swiftlang-6.4.0.25.4) | Swift 6 Concurrency | Swift 6 language mode enabled. |

## 2. API Availability & Deprecation Checks

| API / Feature | Chosen Solution | Deprecated Alternative Avoided |
| --- | --- | --- |
| **Login Items** | `SMAppService.mainApp` | `SMLoginItemSetEnabled` (Deprecated) |
| **Notarization** | `xcrun notarytool` | `altool` (Deprecated) |
| **Global Hotkey** | Carbon `RegisterEventHotKey` / `KeyboardShortcuts` native bridge | Accessibility Event Taps (Avoided due to privacy overhead) |
| **Session Storage** | `WKWebsiteDataStore.default()` | Deprecated legacy WebKit storage APIs |
| **Web JS Bridge** | `WKUserScript` with `WKContentWorld.page` | Global scope pollution or token scraping |

## 3. Discord Policy & Integration Posture

- **Embed Strategy:** Official Discord Web client (`https://discord.com/app`) hosted in `WKWebView`.
- **Auth Model:** Direct browser session inside WKWebView; no credential scraping or token extraction.
- **External Links:** Safe URL matching delegating to default macOS browser via `NSWorkspace`.
- **Media Capture:** Native WebKit media authorization delegate for microphone and camera.
