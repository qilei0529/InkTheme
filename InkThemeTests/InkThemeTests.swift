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
        #expect(InkPalette.resolved(appearance: .light, accent: .ink, system: .dark) == .light)
    }

    @Test func accentIsIndependentOfAppearance() {
        #expect(InkAccent.storageKey == "ink.accent")
        #expect(InkAccent.allCases.map(\.rawValue) == ["ink", "red", "blue", "green"])

        let lightInk = InkPalette.resolved(appearance: .light, accent: .ink, system: .dark)
        let darkInk = InkPalette.resolved(appearance: .dark, accent: .ink, system: .light)
        #expect(lightInk.accent == lightInk.ink)
        #expect(darkInk.accent == darkInk.ink)

        let lightRed = InkPalette.resolved(appearance: .light, accent: .red, system: .light)
        let darkRed = InkPalette.resolved(appearance: .dark, accent: .red, system: .dark)
        #expect(lightRed.ink == .black)
        #expect(lightRed.paper == .white)
        #expect(darkRed.ink == .white)
        #expect(darkRed.paper == .black)
        #expect(lightRed.accent == darkRed.accent)
        #expect(lightRed.accent != lightRed.ink)

        let lightBlue = InkPalette.resolved(appearance: .light, accent: .blue, system: .dark)
        let darkBlue = InkPalette.resolved(appearance: .dark, accent: .blue, system: .light)
        #expect(lightBlue.accent == darkBlue.accent)
        #expect(lightBlue.paper == .white)
        #expect(darkBlue.paper == .black)
    }

    @Test func groundTintsDarkPaperOnly() {
        #expect(InkGround.storageKey == "ink.ground")
        #expect(InkGround.allCases.map(\.rawValue) == ["black", "red", "blue", "green"])

        let lightRedGround = InkPalette.resolved(
            appearance: .light,
            ground: .red,
            system: .dark
        )
        #expect(lightRedGround == .light)
        #expect(lightRedGround.paper == .white)
        #expect(lightRedGround.inverse == .white)

        let darkBlack = InkPalette.resolved(appearance: .dark, ground: .black, system: .light)
        #expect(darkBlack == .dark)
        #expect(darkBlack.inverse == .black)

        let darkRed = InkPalette.resolved(appearance: .dark, ground: .red, system: .light)
        #expect(darkRed.ink == .white)
        #expect(darkRed.paper == InkGround.red.color)
        #expect(darkRed.inverse == .black)
        #expect(darkRed.paper != darkBlack.paper)

        let systemDarkGreen = InkPalette.resolved(
            appearance: .system,
            ground: .green,
            system: .dark
        )
        #expect(systemDarkGreen.paper == InkGround.green.color)
        #expect(systemDarkGreen.inverse == .black)

        let systemLightGreen = InkPalette.resolved(
            appearance: .system,
            ground: .green,
            system: .light
        )
        #expect(systemLightGreen.paper == .white)
        #expect(systemLightGreen.inverse == .white)
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

        #expect(InkTextStyle.hero.pointSize == 28)
        #expect(InkTextStyle.hero.tracking == 0)
        #expect(InkTextStyle.hero.inkOpacity == 1)

        #expect(InkTextStyle.title.textStyle == .title2)
        #expect(InkTextStyle.body.textStyle == .body)
        #expect(InkTextStyle.bodyStrong.textStyle == .body)
        #expect(InkTextStyle.caption.textStyle == .footnote)
        #expect(InkTextStyle.caption.inkOpacity == 0.55)
        #expect(InkTextStyle.caption.tracking == 0)

        #expect(InkTextStyle.capital.textStyle == .footnote)
        #expect(InkTextStyle.capital.tracking == 1.2)
        #expect(InkTextStyle.capital.inkOpacity == 0.45)
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
        #expect(InkSheetDetent.large.presentationDetents == [.large])
        #expect(InkSheetDetent.medium.presentationDetents == [.medium])
        #expect(InkSheetDetent.mediumAndLarge.presentationDetents == [.medium, .large])
    }
}

private struct SeededGenerator: RandomNumberGenerator {
    var seed: UInt64

    mutating func next() -> UInt64 {
        seed = seed &* 6_364_136_223_846_793_005 &+ 1
        return seed
    }
}
