import Foundation
import WebKit

public final class WebNotificationBridge: NSObject, WKScriptMessageHandler {
    public static let handlerName = "PopcordWebBridge"
    
    public var onNotificationReceived: ((_ title: String, _ body: String) -> Void)?
    public var onTitleChanged: ((_ title: String) -> Void)?
    public var onCurrentURLChanged: ((_ urlString: String) -> Void)?
    
    /// UserScript injected into WKContentWorld.page to observe Notifications and Title changes
    public static var injectedUserScript: WKUserScript {
        let jsSource = """
        (function() {
            if (window.popcordInjected) return;
            window.popcordInjected = true;
            
            // 1. Intercept Web Notifications
            var NativeNotification = window.Notification;
            function PopcordNotification(title, options) {
                options = options || {};
                try {
                    window.webkit.messageHandlers.\(handlerName).postMessage({
                        type: 'notification',
                        title: title || '',
                        body: options.body || ''
                    });
                } catch(e) {}
                if (NativeNotification) {
                    return new NativeNotification(title, options);
                }
            }
            if (NativeNotification) {
                PopcordNotification.permission = NativeNotification.permission;
                PopcordNotification.requestPermission = function(cb) {
                    return NativeNotification.requestPermission(cb);
                };
            } else {
                PopcordNotification.permission = 'granted';
                PopcordNotification.requestPermission = function(cb) {
                    if (cb) cb('granted');
                    return Promise.resolve('granted');
                };
            }
            window.Notification = PopcordNotification;
            
            // 2. Observe Document Title changes for unread mention badges
            var lastTitle = document.title;
            var titleObserver = new MutationObserver(function() {
                if (document.title !== lastTitle) {
                    lastTitle = document.title;
                    try {
                        window.webkit.messageHandlers.\(handlerName).postMessage({
                            type: 'title',
                            title: document.title
                        });
                    } catch(e) {}
                }
            });
            var titleEl = document.querySelector('title');
            if (titleEl) {
                titleObserver.observe(titleEl, { subtree: true, characterData: true, childList: true });
            }
            
            // 3. Observe location changes
            var lastHref = location.href;
            setInterval(function() {
                if (location.href !== lastHref) {
                    lastHref = location.href;
                    try {
                        window.webkit.messageHandlers.\(handlerName).postMessage({
                            type: 'url',
                            url: location.href
                        });
                    } catch(e) {}
                }
            }, 1000);
        })();
        """
        return WKUserScript(
            source: jsSource,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false,
            in: .page
        )
    }
    
    // MARK: - WKScriptMessageHandler
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any],
              let type = body["type"] as? String else { return }
        
        switch type {
        case "notification":
            let title = body["title"] as? String ?? ""
            let bodyText = body["body"] as? String ?? ""
            DispatchQueue.main.async {
                self.onNotificationReceived?(title, bodyText)
            }
        case "title":
            if let title = body["title"] as? String {
                DispatchQueue.main.async {
                    self.onTitleChanged?(title)
                }
            }
        case "url":
            if let url = body["url"] as? String {
                DispatchQueue.main.async {
                    self.onCurrentURLChanged?(url)
                }
            }
        default:
            break
        }
    }
}
