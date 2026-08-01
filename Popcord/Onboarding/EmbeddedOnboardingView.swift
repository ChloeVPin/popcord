import SwiftUI

public struct EmbeddedOnboardingView: View {
    @ObservedObject private var appState = AppState.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "popcorn.fill")
                .font(.title2)
                .foregroundStyle(.indigo)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Welcome to Popcord 🍿")
                    .font(.caption.bold())
                Text("Full Discord Web in your menu bar. Log in below to get started!")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button("Dismiss") {
                withAnimation {
                    appState.onboardingCompleted = true
                }
                notificationManager.requestAuthorization()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .tint(.indigo)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.indigo.opacity(0.12))
    }
}
