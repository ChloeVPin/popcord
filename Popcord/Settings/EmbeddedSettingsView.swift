import SwiftUI

public struct EmbeddedSettingsView: View {
    @ObservedObject private var appState = AppState.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    @ObservedObject private var hotkeyManager = HotkeyManager.shared
    @ObservedObject private var sessionManager = SessionManager.shared
    @ObservedObject private var updateManager = UpdateManager.shared
    
    @Binding var isPresented: Bool
    
    @State private var isClearingSession: Bool = false
    @State private var sessionMessage: String? = nil
    @State private var showingChangelog: Bool = false
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Clean macOS Bar Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.discordBlurple)
                    Text("Settings")
                        .font(.system(size: 13, weight: .bold))
                }
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPresented = false
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.primary.opacity(0.08))
                            .frame(width: 22, height: 22)
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .focusable(false)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Material.bar)
            
            Divider()
                .opacity(0.4)
            
            // Settings Content
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 16) {
                    // 1. General & Shortcut Group
                    SettingsGroupCard(title: "Shortcuts & System") {
                        SettingRow(
                            icon: "keyboard",
                            title: "Global Hotkey",
                            subtitle: "Show or hide Popcord from anywhere"
                        ) {
                            Text(hotkeyManager.currentShortcut.displayString)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .fill(Color.primary.opacity(0.06))
                                )
                        }
                        
                        Divider().padding(.leading, 42).opacity(0.2)
                        
                        SettingRow(
                            icon: "arrow.up.forward.app",
                            title: "Launch at Login",
                            subtitle: "Start Popcord automatically on macOS login"
                        ) {
                            Toggle("", isOn: $sessionManager.launchAtLogin)
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .controlSize(.small)
                                .tint(Color.discordBlurple)
                                .focusable(false)
                        }
                    }
                    
                    // 2. Notifications Group
                    SettingsGroupCard(title: "Notifications & Badges") {
                        SettingRow(
                            icon: "bell",
                            title: "Mention Notifications",
                            subtitle: "Show macOS notification banners for pings"
                        ) {
                            Toggle("", isOn: $notificationManager.enableMentionNotifications)
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .controlSize(.small)
                                .tint(Color.discordBlurple)
                                .focusable(false)
                        }
                        
                        Divider().padding(.leading, 42).opacity(0.2)
                        
                        SettingRow(
                            icon: "circle.dot",
                            title: "Menu Bar Badge",
                            subtitle: "Display red dot on status icon for unread pings"
                        ) {
                            Toggle("", isOn: $notificationManager.showMenuBarBadge)
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .controlSize(.small)
                                .tint(Color.discordBlurple)
                                .focusable(false)
                        }
                    }
                    
                    // 3. Software Updates & Release Notes Card
                    SettingsGroupCard(title: "Updates") {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Text("Popcord")
                                            .font(.system(size: 13, weight: .bold))
                                        Text(updateManager.currentVersion)
                                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                                            .foregroundStyle(.secondary)
                                    }
                                    Text(updateManager.checkStatusMessage)
                                        .font(.system(size: 11))
                                        .foregroundStyle(updateManager.updateAvailable ? Color.discordBlurple : .secondary)
                                }
                                
                                Spacer()
                                
                                if updateManager.updateAvailable {
                                    Button {
                                        updateManager.performInAppUpdate()
                                    } label: {
                                        if updateManager.isDownloading {
                                            ProgressView().controlSize(.small)
                                        } else {
                                            Text("Update Now")
                                                .font(.system(size: 11, weight: .bold))
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(Color.discordBlurple)
                                    .controlSize(.small)
                                    .focusable(false)
                                } else {
                                    Button {
                                        updateManager.checkForUpdates()
                                    } label: {
                                        if updateManager.isChecking {
                                            ProgressView().controlSize(.small)
                                        } else {
                                            Text("Check Now")
                                                .font(.system(size: 11, weight: .medium))
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .focusable(false)
                                }
                            }
                            
                            if let release = updateManager.latestRelease {
                                Divider().opacity(0.2)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Latest Release: \(release.name ?? release.tagName)")
                                            .font(.system(size: 12, weight: .semibold))
                                        Spacer()
                                        Button {
                                            withAnimation(.easeInOut) {
                                                showingChangelog.toggle()
                                            }
                                        } label: {
                                            Text(showingChangelog ? "Hide Notes" : "View Changelog")
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundStyle(Color.discordBlurple)
                                        }
                                        .buttonStyle(.plain)
                                        .focusable(false)
                                    }
                                    
                                    if showingChangelog, let body = release.body {
                                        ScrollView {
                                            Text(LocalizedStringKey(body))
                                                .font(.system(size: 11.5))
                                                .foregroundStyle(.primary.opacity(0.9))
                                                .lineSpacing(3)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(10)
                                        }
                                        .frame(maxHeight: 120)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                .fill(Color.primary.opacity(0.04))
                                        )
                                    }
                                }
                            }
                        }
                        .padding(12)
                    }
                    
                    // 4. Session & Privacy
                    SettingsGroupCard(title: "Session & Privacy") {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "lock.shield")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                                Text("100% Free & Open Source. Session cookies stay local on your Mac.")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Divider().opacity(0.2)
                            
                            HStack {
                                Button(role: .destructive) {
                                    isClearingSession = true
                                    sessionManager.clearDiscordSession { _ in
                                        isClearingSession = false
                                        sessionMessage = "Session cleared ✓"
                                    }
                                } label: {
                                    if isClearingSession {
                                        ProgressView().controlSize(.small)
                                    } else {
                                        Label("Clear Discord Web Session", systemImage: "trash")
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .focusable(false)
                                
                                Spacer()
                                
                                if let msg = sessionMessage {
                                    Text(msg)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                        .padding(12)
                    }
                }
                .padding(14)
            }
        }
        .background(Material.regular)
        .onAppear {
            if updateManager.lastCheckedDate == nil {
                updateManager.checkForUpdates()
            }
        }
    }
}

// MARK: - Clean Helper Components

private struct SettingsGroupCard<Content: View>: View {
    let title: String?
    let content: Content
    
    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title = title {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            }
            
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
            )
        }
    }
}

private struct SettingRow<Control: View>: View {
    let icon: String
    let title: String
    let subtitle: String?
    let control: Control
    
    init(icon: String, title: String, subtitle: String? = nil, @ViewBuilder control: () -> Control) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.control = control()
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.discordBlurple)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 10.5))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            control
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
    }
}
