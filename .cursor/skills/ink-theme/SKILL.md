---
name: ink-theme
description: >-
  Applies the Ink black-and-white SwiftUI design system from the InkTheme
  repo. Use when building or restyling iOS/SwiftUI screens, migrating
  AnAskBot AskTheme, adding typewriter text, voice/mic buttons, sound
  waves, outlined 44pt buttons, or when the user mentions Ink, InkTheme,
  black/white UI, or this skill.
---

# Ink Theme

Source of truth: `/Users/qilei/Code/iOS/InkTheme`

Copy files from that app. Do not reinvent tokens, button styles, or motion.

## When to use

- New SwiftUI screens that should look like AnAskBot / Ink
- Restyling an existing iOS app to black paper, system type, stroked buttons
- Adding typing, mic, or sound-wave UI

## Copy these files

From `InkTheme/InkTheme/` into the host app (keep names):

| File | Role |
| --- | --- |
| `Theme/Ink.swift` | Tokens, fill/outline buttons, `inkScreen()`, `inkStroke()` |
| `Components/TypewriterText.swift` | Character-by-character English reveal |
| `Components/VoiceButton.swift` | 72pt circular mic |
| `Components/SoundWaveView.swift` | Idle/active bars |
| `DesignSystemPlaygroundView.swift` | Optional catalog; host as a debug sheet if useful |

If the host module already defines `Ink`, `TypewriterText`, `VoiceButton`, or `SoundWaveView`, reuse those types. Do not duplicate.

Xcode with a synchronized root group picks up new files automatically. Older `.pbxproj` file lists need the files added to the app target.

## Tokens (do not change)

| Token | Value |
| --- | --- |
| `Ink.ink` | `Color.black` |
| `Ink.paper` | `Color.white` |
| `Ink.buttonHeight` | `44` |
| `Ink.cornerRadius` | `12` |
| `Ink.borderWidth` | `2` |
| `Ink.voiceSize` | `72` |
| `Ink.displayFont` | system 40 bold |
| `Ink.titleFont` | `.title2` semibold |
| `Ink.bodyFont` | `.body` |
| `Ink.captionFont` | `.footnote` |

Accent color is black. No brand color, no SF Rounded, no extra palette.

Secondary text uses `Ink.ink.opacity(0.55)` or `0.45` for section labels. Disabled controls use the opacities already in `InkOutlineButtonStyle` / `InkFillButtonStyle`.

## Rules

1. Screen background: `.inkScreen()` (white, ignores safe area).
2. Primary text and icons: `Ink.ink`. Never `.primary` / `.tint` for chrome.
3. Buttons: `.inkFillButton()` (black fill) or `.inkOutlineButton()` (2pt black stroke). Min height 44, continuous corner 12.
4. Fields, cards, list-adjacent boxes: paper fill + `.inkStroke()`.
5. English hero lines: large system bold (28–64), optional `.tracking(4)` on short display words.
6. Section labels: `Ink.captionFont.weight(.semibold)`, uppercased, tracking 1.2, opacity 0.45.
7. Voice: `VoiceButton` + `SoundWaveView(isActive:)`. Do not invent a different mic.
8. Reveal copy with `TypewriterText` (default 22 cps). Replay by changing `.id`.

## Do not

- Add gray fills, shadows, materials, gradients, or colorful SF Symbols tints
- Use capsule / fully rounded buttons instead of 12pt continuous rects (mic is the only circle)
- Mix `ButtonStyle` with extra padding that breaks the 44pt height
- Port AnAskBot product code (`WordHighlighter`, Ask flow, tutors). That is not Ink.

## Apply to a host screen

```swift
NavigationStack {
    VStack(alignment: .leading, spacing: 16) {
        Text("TITLE")
            .font(Ink.captionFont.weight(.semibold))
            .tracking(1.2)
            .foregroundStyle(Ink.ink.opacity(0.45))

        TypewriterText(text: prompt, font: .system(size: 28, weight: .bold))

        TextField("Answer", text: $answer)
            .font(Ink.bodyFont)
            .foregroundStyle(Ink.ink)
            .padding(12)
            .inkStroke()

        Button("Continue") { }
            .inkFillButton()
        Button("Skip") { }
            .inkOutlineButton()
    }
    .padding(20)
    .inkScreen()
}
.toolbar {
    ToolbarItem(placement: .principal) {
        Text("Screen").foregroundStyle(Ink.ink)
    }
}
```

Lists: `listRowBackground(Ink.paper)`, hide default chrome when it fights the black/white stroke language.

## Verify

- Playground in the InkTheme app still shows type, buttons, typing, mic, wave
- Host screens use only `Ink.*` colors/fonts
- No remaining `AskTheme` / `askFillButton` / `askOutlineButton` after a migration
