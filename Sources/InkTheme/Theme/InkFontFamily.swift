import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Host-owned typeface for Ink text roles. Default is the system font.
///
/// Custom families map PostScript / registered face names to weights. Missing
/// faces fall back to the nearest available weight, then to system.
public struct InkFontFamily: Sendable, Equatable {
    public enum Kind: Sendable, Equatable {
        case system
        case custom(faces: Faces)
    }

    /// Registered face names for common Ink weights.
    public struct Faces: Sendable, Equatable {
        public var regular: String
        public var medium: String?
        public var semibold: String?
        public var bold: String?

        public init(
            regular: String,
            medium: String? = nil,
            semibold: String? = nil,
            bold: String? = nil
        ) {
            self.regular = regular
            self.medium = medium
            self.semibold = semibold
            self.bold = bold
        }
    }

    public var kind: Kind

    public static let system = InkFontFamily(kind: .system)

    public static func custom(
        regular: String,
        medium: String? = nil,
        semibold: String? = nil,
        bold: String? = nil
    ) -> InkFontFamily {
        InkFontFamily(
            kind: .custom(
                faces: Faces(
                    regular: regular,
                    medium: medium,
                    semibold: semibold,
                    bold: bold
                )
            )
        )
    }

    public init(kind: Kind) {
        self.kind = kind
    }

    public func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch kind {
        case .system:
            return Font.system(size: size, weight: weight, design: .default)
        case .custom(let faces):
            let name = faces.resolvedName(for: weight)
            #if canImport(UIKit)
            if UIFont(name: name, size: size) != nil {
                return Font.custom(name, size: size)
            }
            #endif
            return Font.system(size: size, weight: weight, design: .default)
        }
    }

    #if canImport(UIKit)
    public func uiFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        switch kind {
        case .system:
            return UIFont.systemFont(ofSize: size, weight: weight)
        case .custom(let faces):
            let name = faces.resolvedName(for: Font.Weight(uiWeight: weight))
            if let font = UIFont(name: name, size: size) {
                return font
            }
            return UIFont.systemFont(ofSize: size, weight: weight)
        }
    }
    #endif
}

extension InkFontFamily.Faces {
    func resolvedName(for weight: Font.Weight) -> String {
        let rank = Self.rank(weight)
        let candidates: [(Int, String?)] = [
            (0, regular),
            (1, medium),
            (2, semibold),
            (3, bold),
        ]
        let available = candidates.compactMap { entry -> (Int, String)? in
            guard let name = entry.1 else { return nil }
            return (entry.0, name)
        }
        guard !available.isEmpty else { return regular }
        return available.min(by: { abs($0.0 - rank) < abs($1.0 - rank) })?.1 ?? regular
    }

    private static func rank(_ weight: Font.Weight) -> Int {
        switch weight {
        case .ultraLight, .thin, .light, .regular: 0
        case .medium: 1
        case .semibold: 2
        case .bold, .heavy, .black: 3
        default: 0
        }
    }
}

#if canImport(UIKit)
private extension Font.Weight {
    init(uiWeight: UIFont.Weight) {
        switch uiWeight {
        case .ultraLight: self = .ultraLight
        case .thin: self = .thin
        case .light: self = .light
        case .regular: self = .regular
        case .medium: self = .medium
        case .semibold: self = .semibold
        case .bold: self = .bold
        case .heavy: self = .heavy
        case .black: self = .black
        default: self = .regular
        }
    }
}
#endif

private struct InkFontFamilyKey: EnvironmentKey {
    static let defaultValue = InkFontFamily.system
}

extension EnvironmentValues {
    public var inkFontFamily: InkFontFamily {
        get { self[InkFontFamilyKey.self] }
        set { self[InkFontFamilyKey.self] = newValue }
    }
}

extension View {
    /// Apply the host `inkFontFamily` at an explicit size / weight (for non-role text).
    public func inkFont(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        modifier(InkFontModifier(size: size, weight: weight))
    }
}

private struct InkFontModifier: ViewModifier {
    var size: CGFloat
    var weight: Font.Weight
    @Environment(\.inkFontFamily) private var fontFamily

    func body(content: Content) -> some View {
        content.font(fontFamily.font(size: size, weight: weight))
    }
}
