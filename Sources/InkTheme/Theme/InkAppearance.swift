import SwiftUI
import UIKit

/// Host-owned list of switchable themes. Pass into `InkAppearanceStore` so Settings
/// and persistence resolve against the app catalog, not only `InkColorTheme.all`.
public struct InkAppearanceConfiguration: Sendable {
    public var themes: [InkColorTheme]
    public var defaultThemeID: String?

    public static let `default` = InkAppearanceConfiguration(themes: InkColorTheme.all)

    public init(themes: [InkColorTheme], defaultThemeID: String? = nil) {
        precondition(!themes.isEmpty, "InkAppearanceConfiguration.themes must not be empty")
        self.themes = themes
        self.defaultThemeID = defaultThemeID
    }

    public var defaultTheme: InkColorTheme {
        if let defaultThemeID, let match = themes.first(where: { $0.id == defaultThemeID }) {
            return match
        }
        return themes[0]
    }

    public func theme(id: String) -> InkColorTheme? {
        themes.first { $0.id == id }
    }
}

@Observable
@MainActor
public final class InkAppearanceStore {
    public var appearance: InkAppearance
    public var theme: InkColorTheme
    public var radius: InkRadius
    /// Themes available for switching in this host (from configuration).
    public private(set) var themes: [InkColorTheme]

    public init(configuration: InkAppearanceConfiguration = .default) {
        themes = configuration.themes
        let appearanceRaw = UserDefaults.standard.string(forKey: InkAppearance.storageKey) ?? ""
        appearance = InkAppearance(rawValue: appearanceRaw) ?? .system
        theme = Self.loadTheme(from: configuration)
        let radiusRaw = UserDefaults.standard.string(forKey: InkRadius.storageKey) ?? ""
        radius = InkRadius(rawValue: radiusRaw) ?? .md
    }

    public func select(_ appearance: InkAppearance, origin: CGPoint? = nil) {
        guard appearance != self.appearance else { return }
        guard !InkThemeReveal.inProgress else { return }

        let system = InkAppearanceTransition.currentSystemColorScheme()
        let shouldReveal = origin != nil
            && !UIAccessibility.isReduceMotionEnabled
            && InkAppearanceTransition.shouldReveal(from: self.appearance, to: appearance, system: system)

        let apply = { [self] in
            commit(appearance)
        }

        if shouldReveal, let origin {
            InkThemeReveal.play(from: origin, apply: apply)
        } else {
            apply()
        }
    }

    public func selectTheme(_ theme: InkColorTheme) {
        guard theme.id != self.theme.id else { return }
        guard themes.contains(where: { $0.id == theme.id }) else { return }
        self.theme = theme
        UserDefaults.standard.set(theme.id, forKey: InkColorTheme.storageKey)
    }

    public func selectRadius(_ radius: InkRadius) {
        guard radius != self.radius else { return }
        self.radius = radius
        UserDefaults.standard.set(radius.rawValue, forKey: InkRadius.storageKey)
    }

    private func commit(_ appearance: InkAppearance) {
        self.appearance = appearance
        UserDefaults.standard.set(appearance.rawValue, forKey: InkAppearance.storageKey)
        appearance.applyToOpenWindows()
    }

    private static func loadTheme(from configuration: InkAppearanceConfiguration) -> InkColorTheme {
        if let raw = UserDefaults.standard.string(forKey: InkColorTheme.storageKey),
           let theme = configuration.theme(id: raw) {
            return theme
        }
        // Migrate legacy `ink.accent` (ink / red / blue / green).
        if let legacy = UserDefaults.standard.string(forKey: "ink.accent"),
           let theme = configuration.theme(id: legacy) {
            UserDefaults.standard.set(theme.id, forKey: InkColorTheme.storageKey)
            return theme
        }
        return configuration.defaultTheme
    }
}

public enum InkAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    static let storageKey = "ink.appearance"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: .unspecified
        case .light: .light
        case .dark: .dark
        }
    }

    @MainActor
    func applyToOpenWindows() {
        let style = userInterfaceStyle
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = style
            }
        }
        CATransaction.commit()
    }
}

/// A complete light + dark palette. Add a new theme by defining one static and appending it to `all`.
public struct InkColorTheme: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let swatch: Color
    public let light: InkPalette
    public let dark: InkPalette

    static let storageKey = "ink.theme"

    public init(id: String, title: String, swatch: Color, light: InkPalette, dark: InkPalette) {
        self.id = id
        self.title = title
        self.swatch = swatch
        self.light = light
        self.dark = dark
    }

    public static func named(_ id: String) -> InkColorTheme? {
        all.first { $0.id == id }
    }
}

public extension InkColorTheme {
    static let ink = InkColorTheme(
        id: "ink",
        title: "Ink",
        swatch: .black,
        light: InkPalette(ink: .black, paper: .white, accent: .black, inverse: .white),
        dark: InkPalette(ink: .white, paper: .black, accent: .white, inverse: .black)
    )

    static let red = InkColorTheme(
        id: "red",
        title: "Red",
        swatch: InkThemeColor.redAccent,
        light: InkPalette(
            ink: .black,
            paper: InkThemeColor.redLightPaper,
            accent: InkThemeColor.redAccent,
            inverse: .white
        ),
        dark: InkPalette(
            ink: .white,
            paper: InkThemeColor.redDarkPaper,
            accent: InkThemeColor.redAccent,
            inverse: .black
        )
    )

    static let blue = InkColorTheme(
        id: "blue",
        title: "Blue",
        swatch: InkThemeColor.blueAccent,
        light: InkPalette(
            ink: .black,
            paper: InkThemeColor.blueLightPaper,
            accent: InkThemeColor.blueAccent,
            inverse: .white
        ),
        dark: InkPalette(
            ink: .white,
            paper: InkThemeColor.blueDarkPaper,
            accent: InkThemeColor.blueAccent,
            inverse: .black
        )
    )

    static let green = InkColorTheme(
        id: "green",
        title: "Green",
        swatch: InkThemeColor.greenAccent,
        light: InkPalette(
            ink: .black,
            paper: InkThemeColor.greenLightPaper,
            accent: InkThemeColor.greenAccent,
            inverse: .white
        ),
        dark: InkPalette(
            ink: .white,
            paper: InkThemeColor.greenDarkPaper,
            accent: InkThemeColor.greenAccent,
            inverse: .black
        )
    )

    public static let all: [InkColorTheme] = [.ink, .red, .blue, .green]
}

enum InkThemeColor {
    static let redAccent = Color(red: 246 / 255, green: 70 / 255, blue: 93 / 255)
    static let blueAccent = Color(red: 0, green: 119 / 255, blue: 1)
    static let greenAccent = Color(red: 34 / 255, green: 197 / 255, blue: 94 / 255)

    static let redLightPaper = Color(red: 255 / 255, green: 245 / 255, blue: 246 / 255)
    static let blueLightPaper = Color(red: 245 / 255, green: 249 / 255, blue: 255 / 255)
    static let greenLightPaper = Color(red: 243 / 255, green: 251 / 255, blue: 246 / 255)

    static let redDarkPaper = Color(red: 30 / 255, green: 8 / 255, blue: 11 / 255)
    static let blueDarkPaper = Color(red: 0, green: 14 / 255, blue: 31 / 255)
    static let greenDarkPaper = Color(red: 4 / 255, green: 24 / 255, blue: 11 / 255)
}

public enum InkRadius: String, CaseIterable, Identifiable, Sendable {
    case zero
    case sm
    case md
    case lg

    static let storageKey = "ink.radius"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .zero: "Zero"
        case .sm: "Sm"
        case .md: "Md"
        case .lg: "Lg"
        }
    }

    public var value: CGFloat {
        switch self {
        case .zero: 0
        case .sm: 6
        case .md: 12
        case .lg: 16
        }
    }

    public var button: CGFloat { value }

    /// Dialog card. Zero stays square; otherwise 4pt looser than buttons.
    public var dialog: CGFloat {
        switch self {
        case .zero: 0
        case .sm, .md, .lg: value + 4
        }
    }

    /// Switch track. `md` and `lg` are fully rounded; `sm` and `zero` use `value`.
    public var toggle: CGFloat {
        switch self {
        case .md, .lg: Ink.toggleHeight / 2
        case .zero, .sm: value
        }
    }

    /// Switch knob. At `sm`, 2pt tighter than the track so the inner corner sits inside the stroke.
    public var toggleKnob: CGFloat {
        switch self {
        case .sm: max(0, toggle - 2)
        case .zero, .md, .lg: toggle
        }
    }
}

public struct InkPalette: Equatable, Sendable {
    public var ink: Color
    public var paper: Color
    public var accent: Color
    public var inverse: Color
    /// Outlines, hairlines, and field strokes. Defaults to `ink` when omitted.
    public var border: Color

    public static let light = InkPalette(ink: .black, paper: .white, accent: .black, inverse: .white)
    public static let dark = InkPalette(ink: .white, paper: .black, accent: .white, inverse: .black)

    public init(
        ink: Color,
        paper: Color,
        accent: Color,
        inverse: Color,
        border: Color? = nil
    ) {
        self.ink = ink
        self.paper = paper
        self.accent = accent
        self.inverse = inverse
        self.border = border ?? ink
    }

    public static func resolved(
        appearance: InkAppearance,
        theme: InkColorTheme = .ink,
        system: ColorScheme
    ) -> InkPalette {
        let isDark: Bool = switch appearance {
        case .light:
            false
        case .dark:
            true
        case .system:
            system == .dark
        }
        return isDark ? theme.dark : theme.light
    }
}

private struct InkPaletteKey: EnvironmentKey {
    static let defaultValue = InkPalette.light
}

private struct InkRadiusKey: EnvironmentKey {
    static let defaultValue = InkRadius.md
}

extension EnvironmentValues {
    public var inkPalette: InkPalette {
        get { self[InkPaletteKey.self] }
        set { self[InkPaletteKey.self] = newValue }
    }

    public var inkRadius: InkRadius {
        get { self[InkRadiusKey.self] }
        set { self[InkRadiusKey.self] = newValue }
    }
}

extension View {
    public func inkAppearance(
        _ preference: InkAppearance,
        theme: InkColorTheme = .ink,
        radius: InkRadius = .md
    ) -> some View {
        modifier(
            InkAppearanceModifier(
                preference: preference,
                theme: theme,
                radius: radius
            )
        )
    }
}

private struct InkAppearanceModifier: ViewModifier {
    var preference: InkAppearance
    var theme: InkColorTheme
    var radius: InkRadius
    @Environment(\.colorScheme) private var systemColorScheme

    func body(content: Content) -> some View {
        let palette = InkPalette.resolved(
            appearance: preference,
            theme: theme,
            system: systemColorScheme
        )
        Group {
            if let scheme = preference.colorScheme {
                content
                    .environment(\.inkPalette, palette)
                    .environment(\.inkRadius, radius)
                    .environment(\.colorScheme, scheme)
                    .preferredColorScheme(scheme)
            } else {
                content
                    .environment(\.inkPalette, palette)
                    .environment(\.inkRadius, radius)
                    .preferredColorScheme(nil)
            }
        }
        .onAppear { preference.applyToOpenWindows() }
        .onChange(of: preference) { _, newValue in
            newValue.applyToOpenWindows()
        }
    }
}
