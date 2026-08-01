import SwiftUI

public struct OnboardingView: View {
    public init() {}
    
    public var body: some View {
        EmbeddedOnboardingView()
            .frame(width: 440, height: 120)
    }
}
