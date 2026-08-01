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
            // Native macOS Bar Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 13, weight: .bold))
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
                            .frame(width: 20, height: 20)
                        Image(systemName: "xmark")
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .focusable(false)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Material.bar)
            
            Divider()
                .opacity(0.4)
            
            // 100% Native macOS HIG Form Settings Layout
            Form {
                Section("Shortcuts & System") {
                    LabeledContent("Global Hotkey") {
                        Text(hotkeyManager.currentShortcut.displayString)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .fill(Color.primary.opacity(0.08))
                            )
                    }
                    
                    Toggle("Launch at Login", isOn: $sessionManager.launchAtLogin)
                        .tint(Color.discordBlurple)
                        .focusable(false)
                }
                
                Section("Notifications & Badges") {
                    Toggle("Mention Notifications", isOn: $notificationManager.enableMentionNotifications)
                        .tint(Color.discordBlurple)
                        .focusable(false)
                    
                    Toggle("Menu Bar Red Badge", isOn: $notificationManager.showMenuBarBadge)
                        .tint(Color.discordBlurple)
                        .focusable(false)
                }
                
                Section("Updates") {
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Popcord \(updateManager.currentVersion)")
                                .font(.system(size: 12, weight: .semibold))
                            Text(updateManager.checkStatusMessage)
                                .font(.system(size: 10.5))
                                .foregroundStyle(updateManager.updateAvailable ? Color.discordBlurple : .secondary)
                        }
                        
                        Spacer()
                        
                        if updateManager.updateAvailable {
                            Button(updateManager.isDownloading ? "Updating..." : "Update Now") {
                                updateManager.performInAppUpdate()
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
                                }
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .focusable(false)
                        }
                    }
                    
                    if let release = updateManager.latestRelease {
                        DisclosureGroup(isExpanded: $showingChangelog) {
                            if let body = release.body {
                                ScrollView {
                                    MarkdownView(markdown: body)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 4)
                                }
                                .frame(maxHeight: 110)
                            }
                        } label: {
                            Text("Release Notes (\(release.tagName))")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color.discordBlurple)
                        }
                    }
                }
                
                Section("Session & Privacy") {
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Discord Web Session")
                                .font(.system(size: 12, weight: .medium))
                            Text("100% Free & Open Source")
                                .font(.system(size: 10.5))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(role: .destructive) {
                            isClearingSession = true
                            sessionManager.clearDiscordSession { _ in
                                isClearingSession = false
                                sessionMessage = "Cleared ✓"
                            }
                        } label: {
                            if isClearingSession {
                                ProgressView().controlSize(.small)
                            } else {
                                Text(sessionMessage ?? "Clear Session")
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .focusable(false)
                    }
                }
            }
            .formStyle(.grouped)
        }
        .background(Material.regular)
        .onAppear {
            if updateManager.lastCheckedDate == nil {
                updateManager.checkForUpdates()
            }
        }
    }
}
