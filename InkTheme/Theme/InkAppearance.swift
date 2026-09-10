import SwiftUI
import UIKit

@Observable
@MainActor
final class InkAppearanceStore {
    var appearance: InkAppearance
    var accent: InkAccent
    var ground: InkGround
    var radius: InkRadius

    init() {
        let appearanceRaw = UserDefaults.standard.string(forKey: InkAppearance.storageKey) ?? ""
        appearance = InkAppearance(rawValue: appearanceRaw) ?? .system
        let accentRaw = UserDefaults.standard.string(forKey: InkAccent.storageKey) ?? ""
        accent = InkAccent(rawValue: accentRaw) ?? .ink
        let groundRaw = UserDefaults.standard.string(forKey: InkGround.storageKey) ?? ""
        ground = InkGround(rawValue: groundRaw) ?? .black
        let radiusRaw = UserDefaults.standard.string(forKey: InkRadius.storageKey) ?? ""
        radius = InkRadius(rawValue: radiusRaw) ?? .md
    }

    func select(_ appearance: InkAppearance, origin: CGPoint? = nil) {
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

    func selectAccent(_ accent: InkAccent) {
        guard accent != self.accent else { return }
        self.accent = accent
        UserDefaults.standard.set(accent.rawValue, forKey: InkAccent.storageKey)
    }

    func selectGround(_ ground: InkGround) {
        guard ground != self.ground else { return }
        self.ground = ground
        UserDefaults.standard.set(ground.rawValue, forKey: InkGround.storageKey)
    }

    func selectRadius(_ radius: InkRadius) {
        guard radius != self.radius else { return }
        self.radius = radius
        UserDefaults.standard.set(radius.rawValue, forKey: InkRadius.storageKey)
    }

    private func commit(_ appearance: InkAppearance) {
        self.appearance = appearance
        UserDefaults.standard.set(appearance.rawValue, forKey: InkAppearance.storageKey)
        appearance.applyToOpenWindows()
    }
}

enum InkAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    static let storageKey = "ink.appearance"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
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

    func applyToOpenWindows() {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = userInterfaceStyle
            }
        }
    }
}

enum InkAccent: String, CaseIterable, Identifiable {
    case ink
    case red
    case blue
    case green

    static let storageKey = "ink.accent"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ink: "Ink"
        case .red: "Red"
        case .blue: "Blue"
        case .green: "Green"
        }
    }

    func resolved(against ink: Color) -> Color {
        switch self {
        case .ink:
            ink
        case .red:
            Color(red: 246 / 255, green: 70 / 255, blue: 93 / 255)
        case .blue:
            Color(red: 0, green: 119 / 255, blue: 1)
        case .green:
            Color(red: 34 / 255, green: 197 / 255, blue: 94 / 255)
        }
    }
}

enum InkGround: String, CaseIterable, Identifiable {
    case black
    case red
    case blue
    case green

    static let storageKey = "ink.ground"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .black: "Black"
        case .red: "Red"
        case .blue: "Blue"
        case .green: "Green"
        }
    }

    var color: Color {
        switch self {
        case .black:
            .black
        case .red:
            Color(red: 30 / 255, green: 8 / 255, blue: 11 / 255)
        case .blue:
            Color(red: 0, green: 14 / 255, blue: 31 / 255)
        case .green:
            Color(red: 4 / 255, green: 24 / 255, blue: 11 / 255)
        }
    }
}

enum InkRadius: String, CaseIterable, Identifiable {
    case zero
    case sm
    case md
    case lg

    static let storageKey = "ink.radius"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .zero: "Zero"
        case .sm: "Sm"
        case .md: "Md"
        case .lg: "Lg"
        }
    }

    var value: CGFloat {
        switch self {
        case .zero: 0
        case .sm: 6
        case .md: 12
        case .lg: 16
        }
    }

    var button: CGFloat { value }

    /// Switch track. `md` and `lg` are fully rounded; `sm` and `zero` use `value`.
    var toggle: CGFloat {
        switch self {
        case .md, .lg: Ink.toggleHeight / 2
        case .zero, .sm: value
        }
    }

    /// Switch knob. At `sm`, 2pt tighter than the track so the inner corner sits inside the stroke.
    var toggleKnob: CGFloat {
        switch self {
        case .sm: max(0, toggle - 2)
        case .zero, .md, .lg: toggle
        }
    }
}

struct InkPalette: Equatable {
    var ink: Color
    var paper: Color
    var accent: Color
    var inverse: Color

    static let light = InkPalette(ink: .black, paper: .white, accent: .black, inverse: .white)
    static let dark = InkPalette(ink: .white, paper: .black, accent: .white, inverse: .black)

    static func resolved(
        appearance: InkAppearance,
        accent: InkAccent = .ink,
        ground: InkGround = .black,
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
        let ink: Color = isDark ? .white : .black
        let paper: Color = isDark ? ground.color : .white
        let inverse: Color = isDark ? .black : .white
        return InkPalette(
            ink: ink,
            paper: paper,
            accent: accent.resolved(against: ink),
            inverse: inverse
        )
    }
}

private struct InkPaletteKey: EnvironmentKey {
    static let defaultValue = InkPalette.light
}

private struct InkRadiusKey: EnvironmentKey {
    static let defaultValue = InkRadius.md
}

extension EnvironmentValues {
    var inkPalette: InkPalette {
        get { self[InkPaletteKey.self] }
        set { self[InkPaletteKey.self] = newValue }
    }

    var inkRadius: InkRadius {
        get { self[InkRadiusKey.self] }
        set { self[InkRadiusKey.self] = newValue }
    }
}

extension View {
    func inkAppearance(
        _ preference: InkAppearance,
        accent: InkAccent = .ink,
        ground: InkGround = .black,
        radius: InkRadius = .md
    ) -> some View {
        modifier(
            InkAppearanceModifier(
                preference: preference,
                accent: accent,
                ground: ground,
                radius: radius
            )
        )
    }
}

private struct InkAppearanceModifier: ViewModifier {
    var preference: InkAppearance
    var accent: InkAccent
    var ground: InkGround
    var radius: InkRadius
    @Environment(\.colorScheme) private var systemColorScheme

    func body(content: Content) -> some View {
        let palette = InkPalette.resolved(
            appearance: preference,
            accent: accent,
            ground: ground,
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
