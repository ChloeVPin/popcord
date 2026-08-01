# Contributing to Popcord 🍿

Thank you for your interest in contributing to **Popcord**! We welcome bug fixes, performance improvements, and feature proposals.

---

## 🛠️ Development Setup

1. **Requirements:**
   - macOS 14.0 (Sonoma) or newer.
   - Xcode 15.0+ or Xcode 16.0+ command line tools.

2. **Clone & Build:**
   ```bash
   git clone https://github.com/ChloeVPin/popcord.git
   cd popcord
   xcodebuild -project Popcord.xcodeproj -scheme Popcord -configuration Debug build
   ```

3. **Code Style & Architecture Guidelines:**
   - **Strict Swift Conventions:** Clean, modern Swift using `@MainActor`, `async/await`, and `Combine`/`ObservableObject`.
   - **Apple HIG:** Adhere to Apple's macOS Human Interface Guidelines.
   - **Zero Slop:** Keep UI clean, compact, single-line form rows, and responsive to system Light/Dark mode.
   - **Privacy First:** No analytics, tracking pixels, or third-party server proxies.

---

## 🚀 Submitting Pull Requests

1. Fork the repository and create a feature branch (`git checkout -b feature/awesome-thing`).
2. Verify that your build succeeds cleanly: `xcodebuild -project Popcord.xcodeproj -scheme Popcord -configuration Debug build`.
3. Commit your changes with clear, descriptive messages.
4. Push to your branch and open a Pull Request.

Thank you for helping make Popcord the ultimate native Discord menu bar app for macOS!
