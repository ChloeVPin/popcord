import AppKit
import SwiftUI

public final class PopcordPanel: NSPanel {
    public init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .resizable, .nonactivatingPanel, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        
        self.isFloatingPanel = true
        self.level = .statusBar
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        self.isMovableByWindowBackground = true
        self.minSize = NSSize(width: 360, height: 480)
        self.maxSize = NSSize(width: 1400, height: 1200)
        self.isReleasedWhenClosed = false
        self.hidesOnDeactivate = false
        self.showsResizeIndicator = true
    }
    
    public override var canBecomeKey: Bool { true }
    public override var canBecomeMain: Bool { true }
    
    public override func cancelOperation(_ sender: Any?) {
        if !AppState.shared.isPanelPinned {
            orderOut(nil)
            AppState.shared.isPanelVisible = false
        }
    }
}
