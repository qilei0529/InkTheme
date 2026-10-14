import SwiftUI

public struct SoundWaveView: View {
    var isActive: Bool
    var barCount: Int
    @Environment(\.inkPalette) private var palette

    public init(isActive: Bool, barCount: Int = 7) {
        self.isActive = isActive
        self.barCount = barCount
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: isActive ? 1 / 30 : 1, paused: !isActive)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            HStack(alignment: .center, spacing: 5) {
                ForEach(0..<barCount, id: \.self) { index in
                    Capsule()
                        .fill(palette.accent)
                        .frame(width: 5, height: barHeight(index: index, time: t))
                }
            }
            .frame(height: 36)
        }
        .accessibilityLabel(isActive ? "Sound wave playing" : "Sound wave idle")
    }

    private func barHeight(index: Int, time: TimeInterval) -> CGFloat {
        guard isActive else { return 6 }
        let phase = Double(index) * 0.55
        let wave = (sin(time * 7 + phase) + 1) / 2
        return 6 + CGFloat(wave) * 28
    }
}
