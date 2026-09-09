import SwiftUI
import Testing
@testable import InkTheme

struct InkThemeTests {

    @Test func tokensMatchAnAskBotDesignSystem() {
        #expect(Ink.buttonHeight == 44)
        #expect(Ink.cornerRadius == 12)
        #expect(Ink.borderWidth == 2)
        #expect(Ink.voiceSize == 72)
        #expect(Ink.ink == Color.black)
        #expect(Ink.paper == Color.white)
    }
}
