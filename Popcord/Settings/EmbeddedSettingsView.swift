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
            // Modern macOS Bar Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.indigo)
                    Text("Popcord Settings")
                        .font(.system(size: 14, weight: .bold))
                }
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPresented = false
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.primary.opacity(0.1))
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
            .padding(.vertical, 12)
            .background(Material.bar)
            
            Divider()
                .opacity(0.4)
            
            // Content
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    // 1. General & Shortcut Group
                    SettingsGroupCard(title: "Shortcuts & System") {
                        SettingRow(
                            icon: "keyboard.fill",
                            iconColor: .orange,
                            title: "Global Toggle Hotkey",
                            subtitle: "Press from any app to show/hide Popcord"
                        ) {
                            Text(hotkeyManager.currentShortcut.displayString)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(Color.primary.opacity(0.08))
                                )
                        }
                        
                        Divider().padding(.leading, 46).opacity(0.3)
                        
                        SettingRow(
                            icon: "arrow.up.forward.app.fill",
                            iconColor: .indigo,
                            title: "Launch at Login",
                            subtitle: "Automatically start Popcord in status bar"
                        ) {
                            Toggle("", isOn: $sessionManager.launchAtLogin)
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .controlSize(.small)
                                .focusable(false)
                        }
                    }
                    
                    // 2. Notifications Group
                    SettingsGroupCard(title: "Notifications & Badges") {
                        SettingRow(
                            icon: "bell.badge.fill",
                            iconColor: .red,
                            title: "Mention Notifications",
                            subtitle: "macOS banners when you receive a ping"
                        ) {
                            Toggle("", isOn: $notificationManager.enableMentionNotifications)
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .controlSize(.small)
                                .focusable(false)
                        }
                        
                        Divider().padding(.leading, 46).opacity(0.3)
                        
                        SettingRow(
                            icon: "circle.fill",
                            iconColor: .pink,
                            title: "Menu Bar Red Badge",
                            subtitle: "Show unread mention dot on menu bar icon"
                        ) {
                            Toggle("", isOn: $notificationManager.showMenuBarBadge)
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .controlSize(.small)
                                .focusable(false)
                        }
                    }
                    
                    // 3. Software Updates & Release Notes Card
                    SettingsGroupCard(title: "Updates & Changelog") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Text("Popcord")
                                            .font(.system(size: 13, weight: .bold))
                                        Text(updateManager.currentVersion)
                                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                            .foregroundStyle(.secondary)
                                    }
                                    Text(updateManager.checkStatusMessage)
                                        .font(.system(size: 11))
                                        .foregroundStyle(updateManager.updateAvailable ? .blue : .secondary)
                                }
                                
                                Spacer()
                                
                                Button {
                                    updateManager.checkForUpdates()
                                } label: {
                                    if updateManager.isChecking {
                                        ProgressView().controlSize(.small)
                                    } else {
                                        Label("Check for Updates", systemImage: "arrow.clockwise")
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.indigo)
                                .controlSize(.small)
                                .focusable(false)
                            }
                            
                            if let release = updateManager.latestRelease {
                                Divider().opacity(0.3)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Latest Release: \(release.name ?? release.tagName)")
                                            .font(.system(size: 12, weight: .bold))
                                        Spacer()
                                        Button {
                                            withAnimation(.easeInOut) {
                                                showingChangelog.toggle()
                                            }
                                        } label: {
                                            Text(showingChangelog ? "Hide Notes" : "View Changelog")
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundStyle(.indigo)
                                        }
                                        .buttonStyle(.plain)
                                        .focusable(false)
                                    }
                                    
                                    if showingChangelog, let body = release.body {
                                        ScrollView {
                                            Text(body)
                                                .font(.system(size: 11, design: .monospaced))
                                                .foregroundStyle(.primary.opacity(0.85))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(10)
                                        }
                                        .frame(maxHeight: 120)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(Color.primary.opacity(0.04))
                                        )
                                    }
                                    
                                    HStack {
                                        Button {
                                            updateManager.openReleasePage()
                                        } label: {
                                            Label(updateManager.updateAvailable ? "Download Release on GitHub" : "View on GitHub", systemImage: "arrow.up.right.square")
                                                .font(.system(size: 11, weight: .medium))
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                        .focusable(false)
                                    }
                                }
                            }
                        }
                        .padding(14)
                    }
                    
                    // 4. Session & Privacy
                    SettingsGroupCard(title: "Discord Web Session") {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 10) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.green)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Private & Secure")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text("Popcord is 100% free software. Session cookies stay inside WebKit on your Mac.")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.bottom, 4)
                            
                            Divider().opacity(0.3)
                            
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
                                        Label("Clear Discord Web Session", systemImage: "trash.fill")
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
                        .padding(14)
                    }
                }
                .padding(16)
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

// MARK: - Modern macOS Settings Helper Components

private struct SettingsGroupCard<Content: View>: View {
    let title: String?
    let content: Content
    
    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title = title {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 6)
            }
            
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
            )
        }
    }
}

private struct SettingRow<Control: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let control: Control
    
    init(icon: String, iconColor: Color, title: String, subtitle: String? = nil, @ViewBuilder control: () -> Control) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.control = control()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(iconColor.gradient)
                    .frame(width: 26, height: 26)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
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
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
