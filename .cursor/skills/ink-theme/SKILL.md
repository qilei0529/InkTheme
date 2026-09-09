---
name: ink-theme
description: >-
  Applies the Ink black-and-white SwiftUI design system from the InkTheme
  repo. Use when building or restyling iOS/SwiftUI screens, migrating
  AnAskBot AskTheme, adding typewriter text, voice/mic buttons, sound
  waves, outlined 44pt buttons, named type styles (display, hero, body,
  capital), InkSpace, or when the user mentions Ink, InkTheme, black/white
  UI, or this skill.
---

# Ink Theme

Source of truth: `/Users/qilei/Code/iOS/InkTheme`

Copy files from that app. Do not reinvent tokens, type styles, button styles, or motion.

## When to use

- New SwiftUI screens that should look like AnAskBot / Ink
- Restyling an existing iOS app to black paper, system type, stroked buttons
- Adding typing, mic, or sound-wave UI

## Copy these files

From `InkTheme/InkTheme/` into the host app (keep names):

| File | Role |
| --- | --- |
| `Theme/Ink.swift` | Color/layout tokens, fill/outline buttons, `inkScreen()`, `inkStroke()` |
| `Theme/InkText.swift` | `InkTextStyle`, `.inkText(_:)`, `InkSpace` |
| `Components/TypewriterText.swift` | Character-by-character English reveal (default `.hero`) |
| `Components/VoiceButton.swift` | 72pt circular mic |
| `Components/SoundWaveView.swift` | Idle/active bars |
| `DesignSystemPlaygroundView.swift` | Optional catalog; host as a debug sheet if useful |

If the host module already defines these types, reuse them. Do not duplicate.

Xcode with a synchronized root group picks up new files automatically. Older `.pbxproj` file lists need the files added to the app target.

## Color and layout

| Token | Value |
| --- | --- |
| `Ink.ink` | `Color.black` |
| `Ink.paper` | `Color.white` |
| `Ink.buttonHeight` | `44` |
| `Ink.cornerRadius` | `12` |
| `Ink.borderWidth` | `2` |
| `Ink.voiceSize` | `72` |

Accent color is black. No brand color, no SF Rounded, no extra palette.

## Type — `.inkText(_:)`

Do not use raw `.font(.system(size:))` or leftover `AskTheme.*Font`. Uppercase `capital` strings in the call site.

| Style | Scene | Size | Weight | Tracking | Color |
| --- | --- | --- | --- | --- | --- |
| `display` | Short brand (INK / ASK) | 64 | bold | 4 | ink |
| `displaySmall` | Onboarding brand line | 48 | bold | 3 | ink |
| `numeral` | Score | 56 | bold | 0 | ink |
| `hero` | English prompt, typewriter | 28 | bold | 0 | ink |
| `title` | Empty/page title | title2 (~22) | semibold | 0 | ink |
| `body` | Paragraph, field, list subtitle | body (~17) | regular | 0 | ink |
| `bodyStrong` | List title, button label, EN sample | body | semibold | 0 | ink |
| `caption` | Status, translation, helper | footnote (~13) | regular | 0 | ink 0.55 |
| `capital` | Section label | footnote | semibold | 1.2 | ink 0.45 |

Buttons use `bodyStrong` inside the button styles. Disabled opacities stay in those styles.

## Space — `InkSpace`

Label to body: `xs` (6) or `sm` (8). Sections: `section` (28). Screen inset: `xl` (20).

| Token | pt | Use |
| --- | --- | --- |
| `xxs` | 4 | Title + note in one item |
| `xs` | 6 | Label to body, wave to caption |
| `sm` | 8 | Title + subtitle, score + unit |
| `md` | 12 | Inner stack, field padding, side-by-side buttons |
| `lg` | 16 | Control rows, loading |
| `xl` | 20 | Screen inset, main column |
| `section` | 28 | Playground / major sections |

## Rules

1. Screen background: `.inkScreen()`.
2. Text: `.inkText(.body)` (and siblings). Never `.primary` / `.tint` for chrome.
3. Buttons: `.inkFillButton()` or `.inkOutlineButton()`. Min height 44, continuous corner 12.
4. Fields, cards: paper fill + `.inkStroke()`, padding `InkSpace.md`.
5. Voice: `VoiceButton` + `SoundWaveView(isActive:)`.
6. Reveal copy with `TypewriterText` (default hero, 22 cps). Replay by changing `.id`.

## Do not

- Add gray fills, shadows, materials, gradients, or colorful SF Symbols tints
- Use capsule / fully rounded buttons instead of 12pt continuous rects (mic is the only circle)
- Mix `ButtonStyle` with extra padding that breaks the 44pt height
- Port AnAskBot product code (`WordHighlighter`, Ask flow, tutors). That is not Ink.
- Invent extra type sizes (no 40pt display)

## Apply to a host screen

```swift
NavigationStack {
    VStack(alignment: .leading, spacing: InkSpace.lg) {
        Text("TITLE")
            .inkText(.capital)

        TypewriterText(text: prompt)

        TextField("Answer", text: $answer)
            .inkText(.body)
            .padding(InkSpace.md)
            .inkStroke()

        Button("Continue") { }
            .inkFillButton()
        Button("Skip") { }
            .inkOutlineButton()
    }
    .padding(InkSpace.xl)
    .inkScreen()
}
.toolbar {
    ToolbarItem(placement: .principal) {
        Text("Screen").inkText(.bodyStrong)
    }
}
```

Lists: `listRowBackground(Ink.paper)`, hide default chrome when it fights the black/white stroke language.

## Verify

- Playground Type and Space sections match the tables above
- Host screens use `.inkText` and `InkSpace`, not ad-hoc sizes
- No remaining `AskTheme` / `askFillButton` / `askOutlineButton` after a migration
