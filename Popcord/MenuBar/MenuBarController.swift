import AppKit
import SwiftUI
import Combine

@MainActor
public final class MenuBarController: NSObject, NSWindowDelegate {
    public static let shared = MenuBarController()
    
    private var statusItem: NSStatusItem!
    private var panel: PopcordPanel!
    private var globalEventMonitor: Any?
    
    public override init() {
        super.init()
    }
    
    public func setup(contentView: AnyView) {
        setupStatusItem()
        setupPanel(contentView: contentView)
        setupNotificationObserver()
        setupGlobalMonitor()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = createPopcordIcon(badgeCount: 0)
            button.target = self
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.toolTip = "Popcord"
        }
    }
    
    private func setupPanel(contentView: AnyView) {
        let state = AppState.shared
        let rect = NSRect(x: 0, y: 0, width: state.panelWidth, height: state.panelHeight)
        panel = PopcordPanel(contentRect: rect)
        panel.delegate = self
        
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.autoresizingMask = [.width, .height]
        panel.contentView = hostingView
    }
    
    private func setupGlobalMonitor() {
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self, self.panel.isVisible else { return }
            let mouseLocation = NSEvent.mouseLocation
            if !self.panel.frame.contains(mouseLocation) {
                if let button = self.statusItem.button, button.window != nil {
                    let buttonFrameInScreen = button.window!.convertToScreen(button.frame)
                    if buttonFrameInScreen.contains(mouseLocation) {
                        return
                    }
                }
                self.hidePanel()
            }
        }
    }
    
    private func setupNotificationObserver() {
        NotificationManager.shared.onBadgeCountChanged = { [weak self] count in
            guard let self = self else { return }
            self.updateStatusItemBadge(count: count)
        }
        
        NotificationManager.shared.onNotificationClicked = { [weak self] in
            guard let self = self else { return }
            self.showPanel()
        }
    }
    
    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            showContextMenu(sender)
        } else {
            togglePanel()
        }
    }
    
    public func togglePanel() {
        if panel.isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }
    
    public func showPanel() {
        guard let button = statusItem.button else { return }
        
        NotificationManager.shared.clearBadge()
        
        let buttonFrame = button.window?.convertToScreen(button.frame) ?? NSRect.zero
        let panelSize = panel.frame.size
        let screenFrame = button.window?.screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? NSRect.zero
        
        let panelX = min(max(screenFrame.minX, buttonFrame.midX - panelSize.width / 2), screenFrame.maxX - panelSize.width)
        let panelY = buttonFrame.minY - panelSize.height - 4
        
        panel.setFrameOrigin(NSPoint(x: panelX, y: panelY))
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        panel.makeFirstResponder(WebViewController.shared.webView)
        
        AppState.shared.isPanelVisible = true
        PerformanceOptimizer.shared.onPopoverShown(webView: WebViewController.shared.webView)
    }
    
    public func hidePanel() {
        if panel.isVisible {
            panel.orderOut(nil)
            AppState.shared.isPanelVisible = false
            PerformanceOptimizer.shared.onPopoverHidden(webView: WebViewController.shared.webView)
        }
    }
    
    private func updateStatusItemBadge(count: Int) {
        if let button = statusItem.button {
            button.image = createPopcordIcon(badgeCount: NotificationManager.shared.showMenuBarBadge ? count : 0)
        }
    }
    
    private func createPopcordIcon(badgeCount: Int) -> NSImage {
        let size = NSSize(width: 22, height: 22)
        
        guard let sfSymbol = NSImage(systemSymbolName: "bubble.left.and.bubble.right.fill", accessibilityDescription: "Popcord") else {
            return NSImage(size: size)
        }
        
        let image = NSImage(size: size)
        image.lockFocus()
        
        let context = NSGraphicsContext.current?.cgContext
        context?.saveGState()
        
        let symbolRect = NSRect(x: 2, y: 3, width: 18, height: 16)
        sfSymbol.draw(in: symbolRect)
        
        if badgeCount > 0 {
            let badgeRect = NSRect(x: 13, y: 13, width: 8, height: 8)
            NSColor.systemRed.set()
            let badgePath = NSBezierPath(ovalIn: badgeRect)
            badgePath.fill()
        }
        
        context?.restoreGState()
        image.unlockFocus()
        image.isTemplate = (badgeCount == 0)
        return image
    }
    
    private func showContextMenu(_ sender: NSStatusBarButton) {
        let menu = NSMenu()
        
        let openItem = NSMenuItem(title: "Open Popcord", action: #selector(contextOpen), keyEquivalent: "")
        openItem.target = self
        menu.addItem(openItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit Popcord", action: #selector(contextQuit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
    
    @objc private func contextOpen() {
        showPanel()
    }
    
    @objc private func contextQuit() {
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: - NSWindowDelegate
    
    public func windowDidResize(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == panel {
            AppState.shared.updatePanelDimensions(width: window.frame.width, height: window.frame.height)
        }
    }
}
