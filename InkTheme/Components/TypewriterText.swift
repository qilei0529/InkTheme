import SwiftUI

struct TypewriterText: View {
    let text: String
    var font: Font = Ink.displayFont
    var charactersPerSecond: Double = 22
    var onFinished: (() -> Void)?

    @State private var visibleCount = 0
    @State private var runID = UUID()

    var body: some View {
        Text(String(text.prefix(visibleCount)))
            .font(font)
            .foregroundStyle(Ink.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentTransition(.interpolate)
            .task(id: runID) {
                await type()
            }
    }

    private func type() async {
        visibleCount = 0
        guard !text.isEmpty else {
            onFinished?()
            return
        }
        let interval = 1.0 / max(charactersPerSecond, 1)
        for index in 1...text.count {
            try? await Task.sleep(for: .seconds(interval))
            if Task.isCancelled { return }
            visibleCount = index
        }
        onFinished?()
    }
}
