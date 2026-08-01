import Foundation
import WebKit

@MainActor
public final class PerformanceOptimizer {
    public static let shared = PerformanceOptimizer()
    
    /// Shared WKProcessPool for maximum memory reuse across web view instances
    public let sharedProcessPool = WKProcessPool()
    
    private init() {}
    
    /// UserScript injected to handle background animation throttling and memory savings
    public static var optimizationUserScript: WKUserScript {
        let jsSource = """
        (function() {
            if (window.popcordPerfInjected) return;
            window.popcordPerfInjected = true;
            
            var isHidden = false;
            
            window.addEventListener('popcord-hidden', function() {
                isHidden = true;
                // Pause background video elements when hidden to save RAM/CPU
                document.querySelectorAll('video').forEach(function(v) {
                    if (!v.paused && v.loop) {
                        v.dataset.popcordPaused = 'true';
                        v.pause();
                    }
                });
            });
            
            window.addEventListener('popcord-visible', function() {
                if (!isHidden) return;
                isHidden = false;
                // Resume video elements
                document.querySelectorAll('video[data-popcord-paused="true"]').forEach(function(v) {
                    v.play();
                    delete v.dataset.popcordPaused;
                });
            });
        })();
        """
        return WKUserScript(
            source: jsSource,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false,
            in: .page
        )
    }
    
    /// Call when Popcord popover becomes visible
    public func onPopoverShown(webView: WKWebView) {
        webView.evaluateJavaScript("window.dispatchEvent(new Event('popcord-visible'));", completionHandler: nil)
    }
    
    /// Call when Popcord popover is hidden to reduce CPU/RAM usage
    public func onPopoverHidden(webView: WKWebView) {
        webView.evaluateJavaScript("window.dispatchEvent(new Event('popcord-hidden'));", completionHandler: nil)
    }
}
