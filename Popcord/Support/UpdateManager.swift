import Foundation
import Combine
import AppKit

public struct GitHubRelease: Codable, Identifiable {
    public let id: Int
    public let tagName: String
    public let name: String?
    public let body: String?
    public let htmlUrl: String
    public let publishedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case tagName = "tag_name"
        case name
        case body
        case htmlUrl = "html_url"
        case publishedAt = "published_at"
    }
}

@MainActor
public final class UpdateManager: ObservableObject {
    public static let shared = UpdateManager()
    
    @Published public var isChecking: Bool = false
    @Published public var latestRelease: GitHubRelease? = nil
    @Published public var updateAvailable: Bool = false
    @Published public var isBannerDismissed: Bool = false
    @Published public var checkStatusMessage: String = "Popcord is up to date"
    @Published public var lastCheckedDate: Date? = nil
    
    public var currentVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(version) (\(build))"
    }
    
    public let repoURLString = "https://api.github.com/repos/ChloeVPin/popcord/releases/latest"
    
    private init() {}
    
    public func dismissBanner() {
        isBannerDismissed = true
    }
    
    public func checkForUpdates() {
        guard !isChecking else { return }
        isChecking = true
        checkStatusMessage = "Checking for updates..."
        
        guard let url = URL(string: repoURLString) else {
            isChecking = false
            checkStatusMessage = "Invalid update URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("Popcord-App", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 10
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            Task { @MainActor in
                guard let self = self else { return }
                self.isChecking = false
                self.lastCheckedDate = Date()
                
                if let error = error {
                    AppLogger.app.error("Update check failed: \(error.localizedDescription)")
                    self.checkStatusMessage = "Popcord is up to date ✓"
                    return
                }
                
                guard let data = data,
                      let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    self.checkStatusMessage = "Popcord is up to date ✓"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let release = try decoder.decode(GitHubRelease.self, from: data)
                    self.latestRelease = release
                    
                    let remoteVersion = release.tagName.replacingOccurrences(of: "v", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    let currentVersionClean = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0").trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if remoteVersion.compare(currentVersionClean, options: .numeric) == .orderedDescending {
                        self.updateAvailable = true
                        self.isBannerDismissed = false
                        self.checkStatusMessage = "New Update Available: \(release.tagName)!"
                    } else {
                        self.updateAvailable = false
                        self.checkStatusMessage = "Popcord is up to date ✓"
                    }
                } catch {
                    AppLogger.app.error("Failed to parse release JSON: \(error)")
                    self.checkStatusMessage = "Popcord is up to date ✓"
                }
            }
        }.resume()
    }
    
    public func openReleasePage() {
        if let urlString = latestRelease?.htmlUrl, let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        } else if let fallbackURL = URL(string: "https://github.com/ChloeVPin/popcord/releases") {
            NSWorkspace.shared.open(fallbackURL)
        }
    }
}
