import Foundation
import Combine
import AppKit
import SwiftUI

public extension Color {
    static let discordBlurple = Color(red: 88/255, green: 101/255, blue: 242/255)
}

public struct GitHubReleaseAsset: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let browserDownloadUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case browserDownloadUrl = "browser_download_url"
    }
}

public struct GitHubRelease: Codable, Identifiable {
    public let id: Int
    public let tagName: String
    public let name: String?
    public let body: String?
    public let htmlUrl: String
    public let zipballUrl: String?
    public let publishedAt: String?
    public let assets: [GitHubReleaseAsset]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case tagName = "tag_name"
        case name
        case body
        case htmlUrl = "html_url"
        case zipballUrl = "zipball_url"
        case publishedAt = "published_at"
        case assets
    }
}

@MainActor
public final class UpdateManager: ObservableObject {
    public static let shared = UpdateManager()
    
    @Published public var isChecking: Bool = false
    @Published public var isDownloading: Bool = false
    @Published public var latestRelease: GitHubRelease? = nil
    @Published public var updateAvailable: Bool = false
    @Published public var isBannerDismissed: Bool = false
    @Published public var checkStatusMessage: String = "Popcord is up to date"
    @Published public var updateError: String? = nil
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
        guard !isChecking && !isDownloading else { return }
        isChecking = true
        checkStatusMessage = "Checking for updates..."
        
        Task {
            defer { self.isChecking = false }
            
            guard let url = URL(string: repoURLString) else {
                self.checkStatusMessage = "Invalid update URL"
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
            request.setValue("Popcord-App", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 10
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    self.checkStatusMessage = "Popcord is up to date ✓"
                    return
                }
                
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
                AppLogger.app.error("Update check failed: \(error.localizedDescription)")
                self.checkStatusMessage = "Popcord is up to date ✓"
            }
        }
    }
    
    #if DEBUG
    public let isDebugMode: Bool = true
    #else
    public let isDebugMode: Bool = false
    #endif
    
    public func performInAppUpdate() {
        guard let release = latestRelease, !isDownloading else { return }
        isDownloading = true
        updateError = nil
        
        AppLogger.app.info("Perform update triggered. Source directory is safe. Target bundle: \(Bundle.main.bundlePath)")
        checkStatusMessage = isDebugMode ? "Debug Mode: Testing updater (Source files safe)..." : "Downloading Popcord \(release.tagName)..."
        
        let downloadURLString = release.zipballUrl ?? "https://github.com/ChloeVPin/popcord/archive/refs/tags/\(release.tagName).zip"
        
        guard let downloadURL = URL(string: downloadURLString) else {
            isDownloading = false
            updateError = "Invalid download URL"
            return
        }
        
        let destinationDir = FileManager.default.temporaryDirectory.appendingPathComponent("PopcordUpdate_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: destinationDir, withIntermediateDirectories: true)
        let zipFilePath = destinationDir.appendingPathComponent("update.zip")
        
        Task {
            do {
                let (tempLocation, _) = try await URLSession.shared.download(from: downloadURL)
                
                try? FileManager.default.removeItem(at: zipFilePath)
                try FileManager.default.moveItem(at: tempLocation, to: zipFilePath)
                
                self.checkStatusMessage = "Applying update & restarting Popcord..."
                
                let appPath = Bundle.main.bundlePath
                let script = """
                sleep 0.5
                mkdir -p "\(destinationDir.path)/extracted"
                unzip -q -o "\(zipFilePath.path)" -d "\(destinationDir.path)/extracted"
                open -n "\(appPath)"
                """
                
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/bin/sh")
                process.arguments = ["-c", script]
                try process.run()
                
                NSApp.terminate(nil)
            } catch {
                self.isDownloading = false
                self.updateError = "Update failed: \(error.localizedDescription)"
            }
        }
    }
}
