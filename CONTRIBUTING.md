<div align="center">

# Contributing to Popcord

<p><strong>Guidelines for Bug Fixes, Code Quality, and Pull Requests</strong></p>

[![Contributing Welcome](https://img.shields.io/badge/contributions-welcome-00C853?style=flat-square)](https://github.com/ChloeVPin/popcord/issues)
[![Swift Concurrency](https://img.shields.io/badge/Swift-Strict_Concurrency-orange?style=flat-square&logo=swift&logoColor=white)](https://swift.org)
[![macOS HIG](https://img.shields.io/badge/Design-macOS_HIG-007ACC?style=flat-square&logo=apple&logoColor=white)](https://developer.apple.com/design/human-interface-guidelines/)

</div>

---

## Engineering & Design Principles

Before submitting code, please review Popcord's core engineering principles:

- **Native macOS First:** Adhere strictly to Apple's Human Interface Guidelines (HIG). Use native SwiftUI form controls, system materials, and AppKit integration.
- **Strict Concurrency Compliance:** All asynchronous operations must strictly conform to Swift `@MainActor` and `async/await` patterns. Avoid untyped background dispatch queues.
- **Privacy & Security Guarantee:** Zero telemetry, zero analytics tracking, and zero third-party proxy servers. Network requests flow directly between Apple WebKit and Discord.
- **Zero Slop UI:** Keep settings compact, single-line form rows, and fully responsive to system Light Mode and Dark Mode preferences.

---

## Development Environment Setup

### 1. Requirements

- **Operating System:** macOS 14.0 (Sonoma) or newer.
- **Developer Tools:** Xcode 15.0+ (with Command Line Tools installed).

### 2. Clone & Compile

```bash
# Clone the repository
git clone https://github.com/ChloeVPin/popcord.git
cd popcord

# Build the Debug scheme via command line
xcodebuild -project Popcord.xcodeproj -scheme Popcord -configuration Debug build
```

Or open `Popcord.xcodeproj` directly in Xcode and execute `Cmd + R`.

---

## Pull Request Workflow

1. **Create a Feature Branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Verify Local Build Success:**
   Before pushing, ensure that your build compiles with **0 warnings**:
   ```bash
   xcodebuild -project Popcord.xcodeproj -scheme Popcord -configuration Debug build
   ```

3. **Commit Message Format:**
   Use clear, imperative commit titles:
   - `Add global hotkey recorder option to settings`
   - `Fix status bar unread badge color contrast in light mode`
   - `Refactor WebViewController navigation callbacks to async/await`

4. **Submit your Pull Request:**
   Push your branch (`git push origin feature/your-feature-name`) and submit a Pull Request against `main`. GitHub Actions CI will automatically run verification builds.

---

## Reporting Issues

When opening an Issue on GitHub, please include:
- Your exact **macOS version** (e.g., macOS 14.5 or macOS 15.0).
- Xcode version if reporting a compilation error.
- Clear step-by-step reproduction instructions.
- Relevant system log output from macOS Console or Xcode debugger.

Thank you for contributing to Popcord!
