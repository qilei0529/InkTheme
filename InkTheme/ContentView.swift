import SwiftUI

struct ContentView: View {
    var body: some View {
        DesignSystemPlaygroundView()
    }
}

#Preview {
    ContentView()
        .environment(InkAppearanceStore())
        .inkAppearance(.system, accent: .ink, ground: .black, radius: .md)
        .inkKeyboardBar()
}
