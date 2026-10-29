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
        light: .light,
        dark: .dark
    )

    static let red = InkColorTheme(
        id: "red",
        title: "Red",
        swatch: InkThemeColor.redAccent,
        light: InkPalette.colored(
            background: InkThemeColor.redLightPaper,
            primary: InkThemeColor.redAccent,
            dark: false
        ),
        dark: InkPalette.colored(
            background: InkThemeColor.redDarkPaper,
            primary: InkThemeColor.redAccent,
            dark: true
        )
    )

    static let blue = InkColorTheme(
        id: "blue",
        title: "Blue",
        swatch: InkThemeColor.blueAccent,
        light: InkPalette.colored(
            background: InkThemeColor.blueLightPaper,
            primary: InkThemeColor.blueAccent,
            dark: false
        ),
        dark: InkPalette.colored(
            background: InkThemeColor.blueDarkPaper,
            primary: InkThemeColor.blueAccent,
            dark: true
        )
    )

    static let green = InkColorTheme(
        id: "green",
        title: "Green",
        swatch: InkThemeColor.greenAccent,
        light: InkPalette.colored(
            background: InkThemeColor.greenLightPaper,
            primary: InkThemeColor.greenAccent,
            dark: false
        ),
        dark: InkPalette.colored(
            background: InkThemeColor.greenDarkPaper,
            primary: InkThemeColor.greenAccent,
            dark: true
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

    // Tailwind zinc scale
    static let zinc50 = Color(red: 250 / 255, green: 250 / 255, blue: 250 / 255)
    static let zinc100 = Color(red: 244 / 255, green: 244 / 255, blue: 245 / 255)
    static let zinc200 = Color(red: 228 / 255, green: 228 / 255, blue: 231 / 255)
    static let zinc300 = Color(red: 212 / 255, green: 212 / 255, blue: 216 / 255)
    static let zinc400 = Color(red: 161 / 255, green: 161 / 255, blue: 170 / 255)
    static let zinc500 = Color(red: 113 / 255, green: 113 / 255, blue: 122 / 255)
    static let zinc800 = Color(red: 39 / 255, green: 39 / 255, blue: 42 / 255)
    static let zinc900 = Color(red: 24 / 255, green: 24 / 255, blue: 27 / 255)
    static let zinc950 = Color(red: 9 / 255, green: 9 / 255, blue: 11 / 255)
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

/// Semantic color tokens for a single appearance side (light or dark).
///
/// Prefer the shadcn-style names. Legacy `ink` / `paper` / `accent` / `inverse`
/// aliases map to `foreground` / `background` / `primary` / `primaryForeground`.
public struct InkPalette: Equatable, Sendable {
    public var background: Color
    public var foreground: Color
    public var muted: Color
    public var mutedForeground: Color
    public var border: Color
    public var primary: Color
    public var primaryForeground: Color
    public var gray: Color
    public var grayForeground: Color
    public var ring: Color
    /// Header nav and bottom bar fill.
    public var chrome: Color
    /// Elevated surfaces (cards, sheets, dialogs, fields) contrasted with `background`.
    public var panel: Color

    /// Type, scrims, off-toggle knob. Alias of `foreground`.
    public var ink: Color {
        get { foreground }
        set { foreground = newValue }
    }

    /// Screens. Alias of `background`.
    public var paper: Color {
        get { background }
        set { background = newValue }
    }

    /// Fill buttons, listening mic, on toggle / checkbox. Alias of `primary`.
    public var accent: Color {
        get { primary }
        set { primary = newValue }
    }

    /// Fill labels, on-toggle knob, checkbox hook. Alias of `primaryForeground`.
    public var inverse: Color {
        get { primaryForeground }
        set { primaryForeground = newValue }
    }

    public static let light = InkPalette(
        background: InkThemeColor.zinc50,
        foreground: .black,
        muted: InkThemeColor.zinc100,
        mutedForeground: InkThemeColor.zinc500,
        border: InkThemeColor.zinc200,
        primary: .black,
        primaryForeground: .white,
        gray: InkThemeColor.zinc100,
        grayForeground: InkThemeColor.zinc900,
        ring: .black,
        chrome: .white,
        panel: .white
    )

    public static let dark = InkPalette(
        background: .black,
        foreground: .white,
        muted: InkThemeColor.zinc800,
        mutedForeground: InkThemeColor.zinc400,
        border: InkThemeColor.zinc800,
        primary: .white,
        primaryForeground: .black,
        gray: InkThemeColor.zinc800,
        grayForeground: InkThemeColor.zinc50,
        ring: InkThemeColor.zinc300,
        chrome: .black,
        panel: InkThemeColor.zinc900
    )

    public init(
        background: Color,
        foreground: Color,
        muted: Color,
        mutedForeground: Color,
        border: Color,
        primary: Color,
        primaryForeground: Color,
        gray: Color,
        grayForeground: Color,
        ring: Color,
        chrome: Color? = nil,
        panel: Color? = nil
    ) {
        self.background = background
        self.foreground = foreground
        self.muted = muted
        self.mutedForeground = mutedForeground
        self.border = border
        self.primary = primary
        self.primaryForeground = primaryForeground
        self.gray = gray
        self.grayForeground = grayForeground
        self.ring = ring
        self.chrome = chrome ?? background
        self.panel = panel ?? background
    }

    /// Legacy initializer. Fills muted / gray / ring from zinc neutrals when omitted.
    public init(
        ink: Color,
        paper: Color,
        accent: Color,
        inverse: Color,
        border: Color? = nil,
        muted: Color? = nil,
        mutedForeground: Color? = nil,
        gray: Color? = nil,
        grayForeground: Color? = nil,
        ring: Color? = nil,
        chrome: Color? = nil,
        panel: Color? = nil
    ) {
        let resolvedBorder = border ?? ink
        self.background = paper
        self.foreground = ink
        self.muted = muted ?? paper
        self.mutedForeground = mutedForeground ?? ink
        self.border = resolvedBorder
        self.primary = accent
        self.primaryForeground = inverse
        self.gray = gray ?? paper
        self.grayForeground = grayForeground ?? ink
        self.ring = ring ?? resolvedBorder
        self.chrome = chrome ?? paper
        self.panel = panel ?? paper
    }

    /// Tinted paper theme (red / blue / green) with shared zinc neutrals.
    static func colored(background: Color, primary: Color, dark: Bool) -> InkPalette {
        if dark {
            InkPalette(
                background: background,
                foreground: .white,
                muted: InkThemeColor.zinc800,
                mutedForeground: InkThemeColor.zinc400,
                border: .white,
                primary: primary,
                primaryForeground: .black,
                gray: InkThemeColor.zinc800,
                grayForeground: InkThemeColor.zinc50,
                ring: InkThemeColor.zinc300,
                chrome: background,
                panel: InkThemeColor.zinc900
            )
        } else {
            InkPalette(
                background: background,
                foreground: .black,
                muted: InkThemeColor.zinc100,
                mutedForeground: InkThemeColor.zinc500,
                border: .black,
                primary: primary,
                primaryForeground: .white,
                gray: InkThemeColor.zinc100,
                grayForeground: InkThemeColor.zinc900,
                ring: .black,
                chrome: .white,
                panel: .white
            )
        }
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
