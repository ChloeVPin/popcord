import SwiftUI
import WebKit

public struct DiscordWebView: NSViewRepresentable {
    public init() {}
    
    public func makeNSView(context: Context) -> WKWebView {
        return WebViewController.shared.webView
    }
    
    public func updateNSView(_ nsView: WKWebView, context: Context) {
        // WebView persistent state is retained by WebViewController
    }
}
