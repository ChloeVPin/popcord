import SwiftUI

public struct PanelContentView: View {
    @ObservedObject private var webVC = WebViewController.shared
    @ObservedObject private var appState = AppState.shared
    
    @State private var showingSettings: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Clean Header Bar
                HStack(spacing: 10) {
                    // Reload & Home Actions
                    HStack(spacing: 8) {
                        Button {
                            webVC.reload()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .buttonStyle(.plain)
                        .focusable(false)
                        .help("Reload Page")
                        
                        Button {
                            appState.navigateToHome()
                        } label: {
                            Image(systemName: "house.fill")
                        }
                        .buttonStyle(.plain)
                        .focusable(false)
                        .help("Discord Home")
                    }
                    
                    Spacer()
                    
                    if webVC.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    }
                    
                    // Settings & External Browser
                    HStack(spacing: 8) {
                        Button {
                            if let url = URL(string: webVC.currentURLString) {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            Image(systemName: "safari")
                        }
                        .buttonStyle(.plain)
                        .focusable(false)
                        .help("Open in Browser")
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingSettings.toggle()
                            }
                        } label: {
                            Image(systemName: showingSettings ? "gearshape.fill" : "gearshape")
                                .foregroundStyle(showingSettings ? Color.discordBlurple : .primary)
                        }
                        .buttonStyle(.plain)
                        .focusable(false)
                        .help("Settings")
                    }
                }
                .font(.system(size: 13, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Material.bar)
                
                Divider()
                
                // Top Update Available Banner
                UpdateBannerView()
                
                // Inline Onboarding if first-run
                if !appState.onboardingCompleted && !showingSettings {
                    EmbeddedOnboardingView()
                    Divider()
                }
                
                // Main Discord WebView
                DiscordWebView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Embedded Settings View Overlay
            if showingSettings {
                EmbeddedSettingsView(isPresented: $showingSettings)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .frame(width: appState.panelWidth, height: appState.panelHeight)
        .background(Material.regular)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
    }
}
