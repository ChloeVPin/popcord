import SwiftUI

public struct UpdateBannerView: View {
    @ObservedObject private var updateManager = UpdateManager.shared
    
    public init() {}
    
    public var body: some View {
        if updateManager.updateAvailable && !updateManager.isBannerDismissed, let release = updateManager.latestRelease {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.yellow)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Popcord Update Available!")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                    Text("\(release.name ?? release.tagName) is now live on GitHub")
                        .font(.system(size: 10.5))
                        .foregroundStyle(.white.opacity(0.85))
                }
                
                Spacer()
                
                Button {
                    updateManager.openReleasePage()
                } label: {
                    Text("Update Now")
                        .font(.system(size: 11, weight: .bold))
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
                .controlSize(.small)
                .focusable(false)
                
                Button {
                    withAnimation {
                        updateManager.dismissBanner()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(4)
                }
                .buttonStyle(.plain)
                .focusable(false)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.9), Color.indigo.opacity(0.9)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
}
