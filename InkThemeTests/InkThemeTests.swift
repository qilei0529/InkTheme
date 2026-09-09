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
