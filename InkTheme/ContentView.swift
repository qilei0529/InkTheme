import InkTheme
import SwiftUI

struct ContentView: View {
    var body: some View {
        DesignSystemPlaygroundView()
    }
}

#Preview {
    ContentView()
        .environment(InkAppearanceStore())
        .inkAppearance(.system, theme: .ink, radius: .md)
        .inkKeyboardBar()
}
