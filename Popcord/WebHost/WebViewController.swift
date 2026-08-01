import Foundation
import WebKit
import AppKit

@MainActor
public final class WebViewController: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate {
    public static let shared = WebViewController()
    
    public private(set) var webView: WKWebView!
    public let bridge = WebNotificationBridge()
    
    @Published public private(set) var currentURLString: String = ""
    @Published public private(set) var canGoBack: Bool = false
    @Published public private(set) var canGoForward: Bool = false
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var title: String = ""
    
    public var onSetPrimaryURLFromCurrent: ((String) -> Void)?
    
    override private init() {
        super.init()
        setupWebView()
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        
        // Setup Content Controller with Bridge & Performance Optimizations
        let userContentController = WKUserContentController()
        userContentController.add(bridge, contentWorld: .page, name: WebNotificationBridge.handlerName)
        userContentController.addUserScript(WebNotificationBridge.injectedUserScript)
        userContentController.addUserScript(PerformanceOptimizer.optimizationUserScript)
        configuration.userContentController = userContentController
        
        // Media permissions & inline playback performance
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.underPageBackgroundColor = .clear
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        #if DEBUG
        if #available(macOS 13.3, *) {
            webView.isInspectable = true
        }
        #endif
        
        setupBridgeCallbacks()
    }
    
    private func setupBridgeCallbacks() {
        bridge.onNotificationReceived = { title, body in
            NotificationManager.shared.postMentionNotification(
                title: title,
                body: body,
                isFocused: NSApp.isActive
            )
        }
        
        bridge.onTitleChanged = { [weak self] title in
            guard let self = self else { return }
            self.title = title
            NotificationManager.shared.updateBadgeFromTitle(title)
        }
        
        bridge.onCurrentURLChanged = { [weak self] urlString in
            guard let self = self else { return }
            self.currentURLString = urlString
        }
    }
    
    public func load(url: URL) {
        AppLogger.web.info("Loading webview URL: \(url.absoluteString)")
        webView.load(URLRequest(url: url))
    }
    
    public func reload() {
        webView.reload()
    }
    
    public func goBack() {
        if webView.canGoBack { webView.goBack() }
    }
    
    public func goForward() {
        if webView.canGoForward { webView.goForward() }
    }
    
    public func clearSession(completion: @escaping () -> Void) {
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: Date.distantPast) { [weak self] in
            Task { @MainActor in
                self?.load(url: URL(string: URLValidator.baseAppURL)!)
                completion()
            }
        }
    }
    
    // MARK: - WKNavigationDelegate
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        let scheme = url.scheme?.lowercased()
        if scheme != "http" && scheme != "https" && scheme != "about" && scheme != "blob" {
            decisionHandler(.cancel)
            return
        }
        
        let isDiscord = URLValidator.isDiscordHost(url.host)
        
        if navigationAction.navigationType == .linkActivated && !isDiscord {
            // Open external links in default macOS browser
            AppLogger.web.info("Opening external link in default browser: \(url.absoluteString)")
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
        if let url = webView.url {
            currentURLString = url.absoluteString
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        AppLogger.web.error("WebView navigation failed: \(error.localizedDescription)")
    }
    
    // MARK: - WKUIDelegate (Popups, Uploads, Camera/Mic)
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            if URLValidator.isDiscordHost(url.host) {
                webView.load(navigationAction.request)
            } else {
                NSWorkspace.shared.open(url)
            }
        }
        return nil
    }
    
    public func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = parameters.allowsDirectories
        openPanel.allowsMultipleSelection = parameters.allowsMultipleSelection
        openPanel.begin { result in
            if result == .OK {
                completionHandler(openPanel.urls)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    @available(macOS 12.0, *)
    public func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        // Automatically grant media capture permissions for Discord domains if OS permits
        if URLValidator.isDiscordHost(origin.host) {
            decisionHandler(.grant)
        } else {
            decisionHandler(.prompt)
        }
    }
    
    // MARK: - WKDownloadDelegate
    
    public func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        let downloadsDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let destinationURL = downloadsDir.appendingPathComponent(suggestedFilename)
        completionHandler(destinationURL)
    }
    
    public func downloadDidFinish(_ download: WKDownload) {
        AppLogger.web.info("Download completed successfully.")
    }
}
