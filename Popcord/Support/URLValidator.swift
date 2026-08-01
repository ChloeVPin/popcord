import Foundation

public struct URLValidator {
    public static let baseAppURL = "https://discord.com/app"
    public static let meURL = "https://discord.com/channels/@me"
    
    private static let validHosts: Set<String> = [
        "discord.com",
        "ptb.discord.com",
        "canary.discord.com",
        "discordapp.com",
        "www.discord.com"
    ]
    
    /// Checks if a given host is an allowed Discord host for navigation inside the WebView.
    public static func isDiscordHost(_ host: String?) -> Bool {
        guard let host = host?.lowercased() else { return false }
        if validHosts.contains(host) { return true }
        if host.endsWithAny(suffixes: [".discord.com", ".discord.gg", ".discordapp.com", ".discord.media"]) {
            return true
        }
        return false
    }
}

private extension String {
    func endsWithAny(suffixes: [String]) -> Bool {
        suffixes.contains { self.hasSuffix($0) }
    }
}
