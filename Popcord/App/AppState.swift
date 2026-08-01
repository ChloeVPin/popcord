import Foundation
import Combine
import SwiftUI
import AppKit

@MainActor
public final class AppState: ObservableObject {
    public static let shared = AppState()
    
    // UserDefaults Keys
    private let widthKey = "popcord_panel_width"
    private let heightKey = "popcord_panel_height"
    private let onboardingKey = "popcord_onboarding_completed"
    private let pinnedKey = "popcord_panel_pinned"
    
    @Published public var panelWidth: CGFloat {
        didSet { UserDefaults.standard.set(Double(panelWidth), forKey: widthKey) }
    }
    
    @Published public var panelHeight: CGFloat {
        didSet { UserDefaults.standard.set(Double(panelHeight), forKey: heightKey) }
    }
    
    @Published public var onboardingCompleted: Bool {
        didSet { UserDefaults.standard.set(onboardingCompleted, forKey: onboardingKey) }
    }
    
    @Published public var isPanelPinned: Bool {
        didSet { UserDefaults.standard.set(isPanelPinned, forKey: pinnedKey) }
    }
    
    @Published public var isPanelVisible: Bool = false
    
    private init() {
        let storedW = UserDefaults.standard.double(forKey: widthKey)
        self.panelWidth = storedW > 0 ? CGFloat(storedW) : 440
        
        let storedH = UserDefaults.standard.double(forKey: heightKey)
        self.panelHeight = storedH > 0 ? CGFloat(storedH) : 620
        
        self.onboardingCompleted = UserDefaults.standard.bool(forKey: onboardingKey)
        self.isPanelPinned = UserDefaults.standard.bool(forKey: pinnedKey)
    }
    
    public func navigateToHome() {
        guard let url = URL(string: URLValidator.baseAppURL) else { return }
        WebViewController.shared.load(url: url)
    }
    
    public func resetDevOnboarding() {
        self.onboardingCompleted = false
        AppLogger.app.info("Dev: Onboarding state reset to false.")
    }
    
    public func updatePanelDimensions(width: CGFloat, height: CGFloat) {
        self.panelWidth = max(360, width)
        self.panelHeight = max(480, height)
    }
}
