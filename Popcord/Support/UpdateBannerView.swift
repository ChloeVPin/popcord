import SwiftUI

extension Color {
    static let discordBlurple = Color(red: 88/255, green: 101/255, blue: 242/255)
}

public struct UpdateBannerView: View {
    @ObservedObject private var updateManager = UpdateManager.shared
    
    public init() {}
    
    public var body: some View {
        if updateManager.updateAvailable && !updateManager.isBannerDismissed, let release = updateManager.latestRelease {
            HStack(spacing: 10) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Popcord Update Available")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                    Text("\(release.name ?? release.tagName) is live on GitHub")
                        .font(.system(size: 10.5))
                        .foregroundStyle(.white.opacity(0.85))
                }
                
                Spacer()
                
                Button {
                    updateManager.openReleasePage()
                } label: {
                    Text("Update")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.white.opacity(0.2))
                        )
                }
                .buttonStyle(.plain)
                .focusable(false)
                
                Button {
                    withAnimation {
                        updateManager.dismissBanner()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(4)
                }
                .buttonStyle(.plain)
                .focusable(false)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Color.discordBlurple)
        }
    }
}
