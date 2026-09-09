import SwiftUI
import UIKit

@Observable
@MainActor
final class InkAppearanceStore {
    var appearance: InkAppearance
    var accent: InkAccent

    init() {
        let appearanceRaw = UserDefaults.standard.string(forKey: InkAppearance.storageKey) ?? ""
        appearance = InkAppearance(rawValue: appearanceRaw) ?? .system
        let accentRaw = UserDefaults.standard.string(forKey: InkAccent.storageKey) ?? ""
        accent = InkAccent(rawValue: accentRaw) ?? .ink
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

struct InkPalette: Equatable {
    var ink: Color
    var paper: Color
    var accent: Color

    static let light = InkPalette(ink: .black, paper: .white, accent: .black)
    static let dark = InkPalette(ink: .white, paper: .black, accent: .white)

    static func resolved(
        appearance: InkAppearance,
        accent: InkAccent = .ink,
        system: ColorScheme
    ) -> InkPalette {
        let base: InkPalette = switch appearance {
        case .light:
            .light
        case .dark:
            .dark
        case .system:
            system == .dark ? .dark : .light
        }
        return InkPalette(ink: base.ink, paper: base.paper, accent: accent.resolved(against: base.ink))
    }
}

private struct InkPaletteKey: EnvironmentKey {
    static let defaultValue = InkPalette.light
}

extension EnvironmentValues {
    var inkPalette: InkPalette {
        get { self[InkPaletteKey.self] }
        set { self[InkPaletteKey.self] = newValue }
    }
}

extension View {
    func inkAppearance(_ preference: InkAppearance, accent: InkAccent = .ink) -> some View {
        modifier(InkAppearanceModifier(preference: preference, accent: accent))
    }
}

private struct InkAppearanceModifier: ViewModifier {
    var preference: InkAppearance
    var accent: InkAccent
    @Environment(\.colorScheme) private var systemColorScheme

    func body(content: Content) -> some View {
        let palette = InkPalette.resolved(
            appearance: preference,
            accent: accent,
            system: systemColorScheme
        )
        Group {
            if let scheme = preference.colorScheme {
                content
                    .environment(\.inkPalette, palette)
                    .environment(\.colorScheme, scheme)
                    .preferredColorScheme(scheme)
            } else {
                content
                    .environment(\.inkPalette, palette)
                    .preferredColorScheme(nil)
            }
        }
        .onAppear { preference.applyToOpenWindows() }
        .onChange(of: preference) { _, newValue in
            newValue.applyToOpenWindows()
        }
    }
}
