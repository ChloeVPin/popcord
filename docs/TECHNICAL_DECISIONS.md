# Technical Decisions and Architecture Rationale

## 1. UI Shell: Utility NSPanel vs. MenuBarExtra Popover

**Decision:** Use a custom borderless utility `NSPanel` anchored directly beneath the `NSStatusItem` rather than a standard SwiftUI `MenuBarExtra(.popover)`.

**Rationale:**
- Full Discord Web is a rich web application with WebGL, WebRTC, popup windows, file drop target requirements, and context menus.
- Standard popovers automatically dismiss when clicking file dialogs or losing focus during complex operations (e.g. system media permission prompts).
- An `NSPanel` with `.nonactivatingPanel` style mask allows Popcord to stay anchored, handle resizability, preserve smooth focus transitions, and support a explicit pin/unpin toggle.

## 2. Notification Observation: Content-World JS Bridge

**Decision:** Combine native WebKit permission overrides with a lightweight `WKUserScript` injected into `WKContentWorld.page` listening to `window.Notification`.

**Rationale:**
- macOS `WKWebView` does not always expose a direct Web Notification permission delegate callback for third-party web domains.
- The content-world script intercepts `new Notification(title, options)` calls from Discord's client-side code and sends a structured message via `WKScriptMessageHandler`.
- This strategy extracts zero message content or token data—only title and ping context—passing it to `UNUserNotificationCenter` for native macOS banner delivery.

## 3. URL Handling & Security

**Decision:** Strict host validation for Discord domain variants (`discord.com`, `ptb.discord.com`, `canary.discord.com`, `discordapp.com`).

**Rationale:**
- Prevents open redirect attacks within the webview.
- Any navigation attempt outside official Discord hosts automatically opens in the user's default macOS browser via `NSWorkspace.shared.open(url)`.

## 4. Single Persistent Web View Engine

**Decision:** Instantiate a single `WKWebView` instance tied to `AppState` during application startup and keep it alive in memory across panel show/hide toggles.

**Rationale:**
- Prevents re-loading Discord Web (which can take 1-3 seconds and consume bandwidth) every time the hotkey or menu bar item is clicked.
- Toggling simply hides or shows the host `NSPanel`.
