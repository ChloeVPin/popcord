import SwiftUI

public struct SettingsView: View {
    @State private var dummyIsPresented: Bool = true
    
    public init() {}
    
    public var body: some View {
        EmbeddedSettingsView(isPresented: $dummyIsPresented)
            .frame(width: 480, height: 420)
    }
}
