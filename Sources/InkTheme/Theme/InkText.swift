import SwiftUI

public enum InkSpace {
    public static let xxs: CGFloat = 4
    public static let xs: CGFloat = 6
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 20
    public static let section: CGFloat = 28
}

/// Type size ladder (pt), parallel to ``InkSpace``.
///
/// Prefer ``InkTextStyle`` for role (weight / tracking / opacity). Use ``InkType`` /
/// ``InkTypeToken`` when you only need a size step, e.g. `.inkText(.body, size: .md)`.
public enum InkType {
    public static let xxs: CGFloat = 10
    public static let xs: CGFloat = 12
    public static let sm: CGFloat = 13
    public static let md: CGFloat = 15
    public static let lg: CGFloat = 17
    public static let xl: CGFloat = 20
    public static let x2l: CGFloat = 22
    public static let x3l: CGFloat = 28
}

public enum InkTypeToken: String, CaseIterable, Identifiable, Sendable {
    case xxs, xs, sm, md, lg, xl, x2l, x3l

    public var id: String { rawValue }

    public var value: CGFloat {
        switch self {
        case .xxs: InkType.xxs
        case .xs: InkType.xs
        case .sm: InkType.sm
        case .md: InkType.md
        case .lg: InkType.lg
        case .xl: InkType.xl
        case .x2l: InkType.x2l
        case .x3l: InkType.x3l
        }
    }

    public var usage: String {
        switch self {
        case .xxs: "micro labels, dense chrome"
        case .xs: "compact secondary"
        case .sm: "caption / capital"
        case .md: "emphasized caption, secondary body"
        case .lg: "body"
        case .xl: "large body, subheads"
        case .x2l: "title"
        case .x3l: "hero"
        }
    }
}

public enum InkTextStyle: String, CaseIterable, Identifiable {
    case display
    case displaySmall
    case numeral
    case hero
    case title
    case body
    case bodyStrong
    case caption
    case capital

    public var id: String { rawValue }

    /// Default point size for this role (aligned with ``InkType`` where applicable).
    public var size: CGFloat {
        switch self {
        case .display: 64
        case .displaySmall: 48
        case .numeral: 56
        case .hero: InkType.x3l
        case .title: InkType.x2l
        case .body, .bodyStrong: InkType.lg
        case .caption, .capital: InkType.sm
        }
    }

    public var weight: Font.Weight {
        switch self {
        case .display, .displaySmall, .numeral, .hero:
            .bold
        case .title, .bodyStrong, .capital:
            .semibold
        case .body, .caption:
            .regular
        }
    }

    /// System-font fallback when no ``EnvironmentValues/inkFontFamily`` is available.
    /// Prefer ``View/inkText`` / ``View/inkFont(size:weight:)`` so custom families apply.
    public var font: Font {
        font(size: nil)
    }

    /// Role font using the system typeface. Pass ``InkTypeToken`` or a raw `pointSize`
    /// to override the ladder size while keeping weight / tracking / opacity.
    /// Prefer environment-aware modifiers when the host sets ``InkFontFamily``.
    public func font(size: InkTypeToken? = nil, pointSize: CGFloat? = nil) -> Font {
        font(family: .system, size: size, pointSize: pointSize)
    }

    /// Role font resolved against a host ``InkFontFamily``.
    public func font(
        family: InkFontFamily,
        size: InkTypeToken? = nil,
        pointSize: CGFloat? = nil
    ) -> Font {
        let resolved = pointSize ?? size?.value ?? self.size
        return family.font(size: resolved, weight: weight)
    }

    public var tracking: CGFloat {
        switch self {
        case .display: 4
        case .displaySmall: 3
        case .capital: 1.2
        default: 0
        }
    }

    public var inkOpacity: Double {
        switch self {
        case .caption: 0.55
        case .capital: 0.45
        default: 1
        }
    }

    public var pointSize: CGFloat? {
        size
    }

    public var textStyle: Font.TextStyle? {
        switch self {
        case .title: .title2
        case .body, .bodyStrong: .body
        case .caption, .capital: .footnote
        default: nil
        }
    }

    public var spec: String {
        switch self {
        case .display: "display · 64 bold · track 4"
        case .displaySmall: "displaySmall · 48 bold · track 3"
        case .numeral: "numeral · 56 bold"
        case .hero: "hero · x3l \(Int(InkType.x3l)) bold"
        case .title: "title · x2l \(Int(InkType.x2l)) semibold"
        case .body: "body · lg \(Int(InkType.lg)) regular"
        case .bodyStrong: "bodyStrong · lg \(Int(InkType.lg)) semibold"
        case .caption: "caption · sm \(Int(InkType.sm)) · ink 0.55"
        case .capital: "capital · sm \(Int(InkType.sm)) semibold · track 1.2 · ink 0.45"
        }
    }

    public var sample: String {
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

public enum InkSpaceToken: String, CaseIterable, Identifiable {
    case xxs, xs, sm, md, lg, xl, section

    public var id: String { rawValue }

    public var value: CGFloat {
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

    public var usage: String {
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
    public func inkText(_ style: InkTextStyle) -> some View {
        modifier(InkTextModifier(style: style, size: nil, pointSize: nil))
    }

    /// Role style with an ``InkTypeToken`` size override (weight / tracking / opacity stay).
    public func inkText(_ style: InkTextStyle, size: InkTypeToken) -> some View {
        modifier(InkTextModifier(style: style, size: size, pointSize: nil))
    }

    /// Role style with a raw point-size override.
    public func inkText(_ style: InkTextStyle, pointSize: CGFloat) -> some View {
        modifier(InkTextModifier(style: style, size: nil, pointSize: pointSize))
    }
}

private struct InkTextModifier: ViewModifier {
    var style: InkTextStyle
    var size: InkTypeToken?
    var pointSize: CGFloat?
    @Environment(\.inkPalette) private var palette
    @Environment(\.inkFontFamily) private var fontFamily

    func body(content: Content) -> some View {
        content
            .font(style.font(family: fontFamily, size: size, pointSize: pointSize))
            .tracking(style.tracking)
            .foregroundStyle(palette.ink.opacity(style.inkOpacity))
    }
}
