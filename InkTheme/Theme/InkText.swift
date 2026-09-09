import SwiftUI

enum InkSpace {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 6
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let section: CGFloat = 28
}

enum InkTextStyle: String, CaseIterable, Identifiable {
    case display
    case displaySmall
    case numeral
    case hero
    case title
    case body
    case bodyStrong
    case caption
    case capital

    var id: String { rawValue }

    var font: Font {
        switch self {
        case .display:
            Font.system(size: 64, weight: .bold, design: .default)
        case .displaySmall:
            Font.system(size: 48, weight: .bold, design: .default)
        case .numeral:
            Font.system(size: 56, weight: .bold, design: .default)
        case .hero:
            Font.system(size: 28, weight: .bold, design: .default)
        case .title:
            Font.system(.title2, design: .default).weight(.semibold)
        case .body:
            Font.system(.body, design: .default)
        case .bodyStrong:
            Font.system(.body, design: .default).weight(.semibold)
        case .caption:
            Font.system(.footnote, design: .default)
        case .capital:
            Font.system(.footnote, design: .default).weight(.semibold)
        }
    }

    var tracking: CGFloat {
        switch self {
        case .display: 4
        case .displaySmall: 3
        case .capital: 1.2
        default: 0
        }
    }

    var inkOpacity: Double {
        switch self {
        case .caption: 0.55
        case .capital: 0.45
        default: 1
        }
    }

    var pointSize: CGFloat? {
        switch self {
        case .display: 64
        case .displaySmall: 48
        case .numeral: 56
        case .hero: 28
        default: nil
        }
    }

    var textStyle: Font.TextStyle? {
        switch self {
        case .title: .title2
        case .body, .bodyStrong: .body
        case .caption, .capital: .footnote
        default: nil
        }
    }

    var spec: String {
        switch self {
        case .display: "display · 64 bold · track 4"
        case .displaySmall: "displaySmall · 48 bold · track 3"
        case .numeral: "numeral · 56 bold"
        case .hero: "hero · 28 bold"
        case .title: "title · title2 semibold"
        case .body: "body · body regular"
        case .bodyStrong: "bodyStrong · body semibold"
        case .caption: "caption · footnote · ink 0.55"
        case .capital: "capital · footnote semibold · track 1.2 · ink 0.45"
        }
    }

    var sample: String {
        switch self {
        case .display: "INK"
        case .displaySmall: "ASK"
        case .numeral: "3"
        case .hero: "Could you stay a bit later?"
        case .title: "Nothing here yet"
        case .body: "Apple system font on white paper."
        case .bodyStrong: "Next item"
        case .caption: "Listening…"
        case .capital: "GRAMMAR HINT"
        }
    }
}

enum InkSpaceToken: String, CaseIterable, Identifiable {
    case xxs, xs, sm, md, lg, xl, section

    var id: String { rawValue }

    var value: CGFloat {
        switch self {
        case .xxs: InkSpace.xxs
        case .xs: InkSpace.xs
        case .sm: InkSpace.sm
        case .md: InkSpace.md
        case .lg: InkSpace.lg
        case .xl: InkSpace.xl
        case .section: InkSpace.section
        }
    }

    var usage: String {
        switch self {
        case .xxs: "title + note in one row item"
        case .xs: "label to body, wave to caption"
        case .sm: "title + subtitle, score + unit"
        case .md: "stack inside a block, field padding, side-by-side buttons"
        case .lg: "control rows, loading"
        case .xl: "screen inset, main column"
        case .section: "playground / major sections"
        }
    }
}

extension View {
    func inkText(_ style: InkTextStyle) -> some View {
        modifier(InkTextModifier(style: style))
    }
}

private struct InkTextModifier: ViewModifier {
    var style: InkTextStyle
    @Environment(\.inkPalette) private var palette

    func body(content: Content) -> some View {
        content
            .font(style.font)
            .tracking(style.tracking)
            .foregroundStyle(palette.ink.opacity(style.inkOpacity))
    }
}
