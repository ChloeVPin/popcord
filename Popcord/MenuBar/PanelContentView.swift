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
                    // Navigation
                    HStack(spacing: 4) {
                        Button {
                            webVC.goBack()
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        .disabled(!webVC.canGoBack)
                        .focusable(false)
                        .help("Back")
                        
                        Button {
                            webVC.goForward()
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                        .disabled(!webVC.canGoForward)
                        .focusable(false)
                        .help("Forward")
                        
                        Button {
                            webVC.reload()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .focusable(false)
                        .help("Reload")
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                        .frame(height: 14)
                    
                    // Home (Discord App Base)
                    Button {
                        appState.navigateToHome()
                    } label: {
                        Image(systemName: "house.fill")
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                    .help("Discord Home")
                    
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
                                .foregroundStyle(showingSettings ? .indigo : .primary)
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
    }
}
