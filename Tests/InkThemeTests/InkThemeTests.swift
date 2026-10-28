import SwiftUI
import Testing
@testable import InkTheme

struct InkThemeTests {

    @Test func tokensMatchAnAskBotDesignSystem() {
        #expect(Ink.buttonHeight == 44)
        #expect(Ink.barButtonHeight == 32)
        #expect(Ink.cornerRadius == 12)
        #expect(Ink.sheetCornerRadius == 24)
        #expect(Ink.sheetScreenInset == 20)
        #expect(Ink.sheetMediumHorizontalInset == 10)
        #expect(Ink.sheetLargeHorizontalInset == 5)
        #expect(Ink.sheetLargeVerticalInset == 10)
        #expect(Ink.sheetFullTopExtra == 40)
        #expect(Ink.sheetHandleWidth == 48)
        #expect(Ink.sheetHandleHeight == 4)
        #expect(Ink.sheetMediumFraction == 0.5)
        #expect(Ink.sheetLargeFraction == 0.88)
        #expect(Ink.dialogMaxWidth == 320)
        #expect(Ink.dialogMoveInOffset == 40)
        #expect(Ink.borderWidth == 2)
        #expect(Ink.voiceSize == 72)
        #expect(Ink.listCoverSize == 48)
        #expect(Ink.toggleWidth == 52)
        #expect(Ink.toggleHeight == 32)
        #expect(Ink.toggleKnobSize == 20)
        #expect(Ink.checkboxSize == 32)
        #expect(InkListCoverSize.small.width == 48)
        #expect(InkListCoverSize.small.height == 48)
        #expect(InkListCoverSize.medium.width == 72)
        #expect(InkListCoverSize.medium.height == 72)
        #expect(InkListCoverSize.large.width == 96)
        #expect(InkListCoverSize.large.height == 72)
        #expect(InkListCoverSize.large.width / InkListCoverSize.large.height == CGFloat(4) / 3)
        #expect(InkFieldSize.sm.height == 32)
        #expect(InkFieldSize.md.height == 44)
        #expect(InkFieldSize.sm.padding == 12)
        #expect(InkFieldSize.md.padding == 12)
        #expect(InkFieldSize.sm.font == InkTextStyle.caption.font)
        #expect(InkFieldSize.md.font == InkTextStyle.body.font)
    }

    @Test func appearanceMapsToColorScheme() {
        #expect(InkAppearance.system.colorScheme == nil)
        #expect(InkAppearance.light.colorScheme == .light)
        #expect(InkAppearance.dark.colorScheme == .dark)
        #expect(InkAppearance.storageKey == "ink.appearance")
        #expect(InkPalette.resolved(appearance: .light, system: .dark) == .light)
        #expect(InkPalette.resolved(appearance: .dark, system: .light) == .dark)
        #expect(InkPalette.resolved(appearance: .system, system: .dark) == .dark)
        #expect(InkPalette.resolved(appearance: .system, system: .light) == .light)
        #expect(InkPalette.resolved(appearance: .light, theme: .ink, system: .dark) == .light)
    }

    @Test func colorThemesOwnFullPalettes() {
        #expect(InkColorTheme.storageKey == "ink.theme")
        #expect(InkColorTheme.all.map(\.id) == ["ink", "red", "blue", "green"])
        #expect(InkColorTheme.named("red") == .red)
        #expect(InkColorTheme.named("missing") == nil)

        let lightInk = InkPalette.resolved(appearance: .light, theme: .ink, system: .dark)
        let darkInk = InkPalette.resolved(appearance: .dark, theme: .ink, system: .light)
        #expect(lightInk == .light)
        #expect(darkInk == .dark)
        #expect(lightInk.primary == lightInk.foreground)
        #expect(darkInk.primary == darkInk.foreground)
        #expect(lightInk.accent == lightInk.ink)
        #expect(darkInk.accent == darkInk.ink)
        #expect(lightInk.border == InkThemeColor.zinc200)
        #expect(darkInk.border == InkThemeColor.zinc800)
        #expect(lightInk.muted == InkThemeColor.zinc100)
        #expect(darkInk.mutedForeground == InkThemeColor.zinc400)
        #expect(InkColorTheme.red.light.border == InkColorTheme.red.light.foreground)
        #expect(InkColorTheme.red.dark.border == InkColorTheme.red.dark.foreground)

        let lightRed = InkPalette.resolved(appearance: .light, theme: .red, system: .light)
        let darkRed = InkPalette.resolved(appearance: .dark, theme: .red, system: .dark)
        #expect(lightRed == InkColorTheme.red.light)
        #expect(darkRed == InkColorTheme.red.dark)
        #expect(lightRed.foreground == .black)
        #expect(lightRed.background != .white)
        #expect(lightRed.background == InkThemeColor.redLightPaper)
        #expect(darkRed.foreground == .white)
        #expect(darkRed.background == InkThemeColor.redDarkPaper)
        #expect(lightRed.primary == darkRed.primary)
        #expect(lightRed.primary == InkThemeColor.redAccent)
        #expect(lightRed.primaryForeground == .white)
        #expect(darkRed.primaryForeground == .black)

        let lightBlue = InkPalette.resolved(appearance: .light, theme: .blue, system: .dark)
        let darkBlue = InkPalette.resolved(appearance: .dark, theme: .blue, system: .light)
        #expect(lightBlue.background == InkThemeColor.blueLightPaper)
        #expect(darkBlue.background == InkThemeColor.blueDarkPaper)
        #expect(lightBlue.primary == darkBlue.primary)

        let systemDarkGreen = InkPalette.resolved(
            appearance: .system,
            theme: .green,
            system: .dark
        )
        #expect(systemDarkGreen == InkColorTheme.green.dark)
        #expect(systemDarkGreen.background == InkThemeColor.greenDarkPaper)

        let systemLightGreen = InkPalette.resolved(
            appearance: .system,
            theme: .green,
            system: .light
        )
        #expect(systemLightGreen == InkColorTheme.green.light)
        #expect(systemLightGreen.background == InkThemeColor.greenLightPaper)
        #expect(systemLightGreen.background != .white)
    }

    @Test func paletteBorderDefaultsToInkAndAcceptsOverride() {
        let soft = Color(red: 226 / 255, green: 232 / 255, blue: 240 / 255)
        let custom = InkPalette(
            ink: .black,
            paper: .white,
            accent: .black,
            inverse: .white,
            border: soft
        )
        #expect(custom.border == soft)
        #expect(custom.border != custom.foreground)
        #expect(InkPalette.light.border == InkThemeColor.zinc200)
        #expect(InkPalette.light.primary == InkPalette.light.foreground)
    }

    @Test @MainActor func appearanceConfigurationOwnsSwitchableThemes() {
        let soft = Color(red: 226 / 255, green: 232 / 255, blue: 240 / 255)
        let hostOnly = InkColorTheme(
            id: "host",
            title: "Host",
            swatch: soft,
            light: InkPalette(
                ink: .black,
                paper: .white,
                accent: .black,
                inverse: .white,
                border: soft
            ),
            dark: InkPalette(
                ink: .white,
                paper: .black,
                accent: .white,
                inverse: .black,
                border: soft
            )
        )
        let configuration = InkAppearanceConfiguration(
            themes: [hostOnly],
            defaultThemeID: "host"
        )
        #expect(configuration.defaultTheme == hostOnly)
        #expect(configuration.theme(id: "host") == hostOnly)
        #expect(configuration.theme(id: "red") == nil)

        let store = InkAppearanceStore(configuration: configuration)
        #expect(store.themes.map(\.id) == ["host"])
        #expect(store.theme.id == "host")
        store.selectTheme(.red)
        #expect(store.theme.id == "host")
    }

    @Test func radiusTokensMatchSpec() {
        #expect(InkRadius.storageKey == "ink.radius")
        #expect(InkRadius.zero.value == 0)
        #expect(InkRadius.sm.value == 6)
        #expect(InkRadius.md.value == 12)
        #expect(InkRadius.lg.value == 16)
        #expect(InkRadius.zero.button == 0)
        #expect(InkRadius.sm.button == 6)
        #expect(InkRadius.md.button == 12)
        #expect(InkRadius.lg.button == 16)
        #expect(InkRadius.zero.dialog == 0)
        #expect(InkRadius.sm.dialog == 10)
        #expect(InkRadius.md.dialog == 16)
        #expect(InkRadius.lg.dialog == 20)
        #expect(InkRadius.zero.toggle == 0)
        #expect(InkRadius.sm.toggle == 6)
        #expect(InkRadius.md.toggle == Ink.toggleHeight / 2)
        #expect(InkRadius.lg.toggle == Ink.toggleHeight / 2)
        #expect(InkRadius.zero.toggleKnob == 0)
        #expect(InkRadius.sm.toggleKnob == 4)
        #expect(InkRadius.md.toggleKnob == InkRadius.md.toggle)
        #expect(InkRadius.lg.toggleKnob == InkRadius.lg.toggle)
    }

    @Test func appearanceRevealSkipsWhenPaletteUnchanged() {
        #expect(InkAppearanceTransition.shouldReveal(from: .light, to: .light, system: .dark) == false)
        #expect(InkAppearanceTransition.shouldReveal(from: .light, to: .system, system: .light) == false)
        #expect(InkAppearanceTransition.shouldReveal(from: .dark, to: .system, system: .dark) == false)
        #expect(InkAppearanceTransition.shouldReveal(from: .light, to: .dark, system: .light) == true)
        #expect(InkAppearanceTransition.shouldReveal(from: .light, to: .system, system: .dark) == true)
        #expect(InkAppearanceTransition.shouldReveal(from: .system, to: .light, system: .dark) == true)
    }

    @Test func appearanceRevealCoversWindowFromOrigin() {
        let bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        #expect(InkThemeReveal.coveringRadius(origin: .zero, bounds: bounds) == hypot(100, 100))
        #expect(InkThemeReveal.coveringRadius(origin: CGPoint(x: 50, y: 50), bounds: bounds) == hypot(50, 50))
    }

    @Test func blobMotionExpandsTwelvePointsIndependently() {
        var first = SeededGenerator(seed: 7)
        var second = SeededGenerator(seed: 99)
        let bounds = CGRect(x: 0, y: 0, width: 200, height: 400)
        let origin = CGPoint(x: 40, y: 80)
        let a = InkBlobMotion.random(origin: origin, bounds: bounds, using: &first)
        let b = InkBlobMotion.random(origin: origin, bounds: bounds, using: &second)

        #expect(a.startRadii.count == InkBlobShape.pointCount)
        #expect(a.endRadii.count == InkBlobShape.pointCount)
        #expect(a.durations.count == InkBlobShape.pointCount)
        #expect(a != b)
        #expect(a.maxDuration >= a.durations.min() ?? 0)

        let atStart = a.radii(at: 0)
        let atEnd = a.radii(at: a.maxDuration)
        for index in 0..<InkBlobShape.pointCount {
            #expect(abs(atStart[index] - a.startRadii[index]) < 0.0001)
            #expect(abs(atEnd[index] - a.endRadii[index]) < 0.0001)
            #expect(a.endRadii[index] > a.startRadii[index])
        }

        let path = InkBlobShape.bezierPath(center: origin, radii: atStart, handleScales: a.handleScales)
        #expect(path.isEmpty == false)
    }

    @Test func textStylesMatchSpec() {
        #expect(InkTextStyle.display.pointSize == 64)
        #expect(InkTextStyle.display.tracking == 4)
        #expect(InkTextStyle.display.inkOpacity == 1)

        #expect(InkTextStyle.displaySmall.pointSize == 48)
        #expect(InkTextStyle.displaySmall.tracking == 3)

        #expect(InkTextStyle.numeral.pointSize == 56)
        #expect(InkTextStyle.numeral.tracking == 0)

        #expect(InkTextStyle.hero.pointSize == InkType.x3l)
        #expect(InkTextStyle.hero.size == 28)
        #expect(InkTextStyle.hero.tracking == 0)
        #expect(InkTextStyle.hero.inkOpacity == 1)

        #expect(InkTextStyle.title.size == InkType.x2l)
        #expect(InkTextStyle.body.size == InkType.lg)
        #expect(InkTextStyle.bodyStrong.size == InkType.lg)
        #expect(InkTextStyle.caption.size == InkType.sm)
        #expect(InkTextStyle.caption.inkOpacity == 0.55)
        #expect(InkTextStyle.caption.tracking == 0)

        #expect(InkTextStyle.capital.size == InkType.sm)
        #expect(InkTextStyle.capital.tracking == 1.2)
        #expect(InkTextStyle.capital.inkOpacity == 0.45)

        #expect(InkTextStyle.title.textStyle == .title2)
        #expect(InkTextStyle.body.textStyle == .body)
        #expect(InkTextStyle.caption.textStyle == .footnote)
    }

    @Test func typeTokensMatchSpec() {
        #expect(InkType.xxs == 10)
        #expect(InkType.xs == 12)
        #expect(InkType.sm == 13)
        #expect(InkType.md == 15)
        #expect(InkType.lg == 17)
        #expect(InkType.xl == 20)
        #expect(InkType.x2l == 22)
        #expect(InkType.x3l == 28)
        #expect(InkTypeToken.md.value == 15)
        #expect(InkTypeToken.x3l.value == 28)
        #expect(InkTypeToken.allCases.map(\.rawValue) == [
            "xxs", "xs", "sm", "md", "lg", "xl", "x2l", "x3l",
        ])
    }

    @Test func spaceTokensMatchSpec() {
        #expect(InkSpace.xxs == 4)
        #expect(InkSpace.xs == 6)
        #expect(InkSpace.sm == 8)
        #expect(InkSpace.md == 12)
        #expect(InkSpace.lg == 16)
        #expect(InkSpace.xl == 20)
        #expect(InkSpace.section == 28)
    }

    @Test func sheetDetentsMatchSpec() {
        #expect(InkSheetDetent.medium.allowedHeights(available: 400) == [200])
        #expect(InkSheetDetent.large.allowedHeights(available: 400) == [352])
        #expect(InkSheetDetent.full.allowedHeights(available: 400) == [400])
        #expect(InkSheetDetent.mediumAndLarge.allowedHeights(available: 400) == [200, 352])
        #expect(InkSheetDetent.largeAndFull.allowedHeights(available: 400) == [352, 400])
        #expect(InkSheetDetent.mediumAndFull.allowedHeights(available: 400) == [200, 352, 400])
        #expect(InkSheetDetent.medium.initialHeight(available: 400) == 200)
        #expect(InkSheetDetent.large.initialHeight(available: 400) == 352)
        #expect(InkSheetDetent.full.initialHeight(available: 400) == 400)
        #expect(InkSheetDetent.mediumAndFull.initialHeight(available: 400) == 200)
    }

    @Test func sheetChromeProgressEndpoints() {
        #expect(InkSheetDetent.medium.chromeProgress(height: 200, available: 400) == 0)
        #expect(InkSheetDetent.large.chromeProgress(height: 352, available: 400) == 0.5)
        #expect(InkSheetDetent.full.chromeProgress(height: 400, available: 400) == 1)
        #expect(InkSheetDetent.mediumAndFull.chromeProgress(height: 200, available: 400) == 0)
        #expect(InkSheetDetent.mediumAndFull.chromeProgress(height: 352, available: 400) == 0.5)
        #expect(InkSheetDetent.mediumAndFull.chromeProgress(height: 400, available: 400) == 1)
        #expect(InkSheetDetent.mediumAndLarge.chromeProgress(height: 352, available: 400) == 0.5)
        #expect(InkSheetDetent.largeAndFull.chromeProgress(height: 352, available: 400) == 0.5)
        #expect(InkSheetDetent.largeAndFull.chromeProgress(height: 400, available: 400) == 1)
    }

    @Test func sheetChromeInsetsAndRadius() {
        #expect(InkSheetChrome.horizontalInset(progress: 0) == 10)
        #expect(InkSheetChrome.horizontalInset(progress: 0.5) == 5)
        #expect(InkSheetChrome.horizontalInset(progress: 1) == 0)
        #expect(InkSheetChrome.verticalInset(progress: 0) == 20)
        #expect(InkSheetChrome.verticalInset(progress: 0.5) == 10)
        #expect(InkSheetChrome.verticalInset(progress: 1) == 0)
        #expect(InkSheetChrome.cornerRadius(progress: 0, radius: .md) == 24)
        #expect(InkSheetChrome.cornerRadius(progress: 0.5, radius: .md) == 24)
        #expect(InkSheetChrome.cornerRadius(progress: 1, radius: .md) == 0)
        #expect(InkSheetChrome.cornerRadius(progress: 0, radius: .zero) == 0)
        #expect(InkSheetChrome.cornerRadius(progress: 0.75, radius: .md) == 12)
        #expect(InkSheetChrome.strokeOpacity(progress: 0) == 1)
        #expect(InkSheetChrome.strokeOpacity(progress: 0.5) == 1)
        #expect(InkSheetChrome.strokeOpacity(progress: 0.75) == 0.5)
        #expect(InkSheetChrome.strokeOpacity(progress: 1) == 0)
    }

    @Test func sheetChromeRespectsSafeArea() {
        let safe = EdgeInsets(top: 59, leading: 0, bottom: 34, trailing: 0)

        let mediumOuter = InkSheetChrome.outerInsets(progress: 0, safe: safe)
        #expect(mediumOuter.top == 79)
        #expect(mediumOuter.bottom == 54)
        #expect(mediumOuter.leading == 10)
        #expect(mediumOuter.trailing == 10)

        let largeOuter = InkSheetChrome.outerInsets(progress: 0.5, safe: safe)
        #expect(largeOuter.top == 69)
        #expect(largeOuter.bottom == 44)
        #expect(largeOuter.leading == 5)
        #expect(largeOuter.trailing == 5)

        let fullOuter = InkSheetChrome.outerInsets(progress: 1, safe: safe)
        #expect(fullOuter.top == 0)
        #expect(fullOuter.bottom == 0)
        #expect(fullOuter.leading == 0)
        #expect(fullOuter.trailing == 0)

        let mediumContent = InkSheetChrome.contentSafeInsets(progress: 0, safe: safe)
        #expect(mediumContent.top == 0)
        #expect(mediumContent.bottom == 0)

        let largeContent = InkSheetChrome.contentSafeInsets(progress: 0.5, safe: safe)
        #expect(largeContent.top == 0)
        #expect(largeContent.bottom == 0)

        let fullContent = InkSheetChrome.contentSafeInsets(progress: 1, safe: safe)
        #expect(fullContent.top == 95)
        #expect(fullContent.bottom == 34)
    }
}

private struct SeededGenerator: RandomNumberGenerator {
    var seed: UInt64

    mutating func next() -> UInt64 {
        seed = seed &* 6_364_136_223_846_793_005 &+ 1
        return seed
    }
}
