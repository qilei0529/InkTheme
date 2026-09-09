---
name: ink-theme
description: >-
  Applies the Ink black-and-white SwiftUI design system from the InkTheme
  repo. Use when building or restyling iOS/SwiftUI screens, migrating
  AnAskBot AskTheme, adding typewriter text, voice/mic buttons, sound
  waves, outlined 44pt buttons, InkNavBar, bar fill/outline actions, named
  type styles (display, hero, body, capital), InkSpace, or when the user
  mentions Ink, InkTheme, black/white UI, or this skill.
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
| `Theme/Ink.swift` | Color/layout tokens, fill/outline + bar buttons, `inkScreen()`, `inkStroke()` |
| `Theme/InkText.swift` | `InkTextStyle`, `.inkText(_:)`, `InkSpace` |
| `Theme/InkNav.swift` | `InkNavBar` — hero title + trailing actions |
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
| `Ink.barButtonHeight` | `32` |
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
| `hero` | Nav title, English prompt, typewriter | 28 | bold | 0 | ink |
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
| `sm` | 8 | Title + subtitle, score + unit, nav padding |
| `md` | 12 | Inner stack, field padding, side-by-side buttons, bar button inset |
| `lg` | 16 | Control rows, loading |
| `xl` | 20 | Screen inset, main column, nav horizontal inset |
| `section` | 28 | Playground / major sections |

## Nav

Do not use system `.navigationTitle` + `.inline`. Hide the UIKit bar and pin `InkNavBar` (hero 28, single line, scales down).

| | Page | Bar text | Bar icon |
| --- | --- | --- | --- |
| Modifier | `.inkFillButton()` / `.inkOutlineButton()` | `.inkBarFillButton()` / `.inkBarOutlineButton()` | `.inkBarIconFillButton()` / `.inkBarIconOutlineButton()` |
| Width | Full | Hug | 32 square |
| Height | 44 | 32 | 32 |

Icon actions: `Button("Add", systemImage: "plus")` plus an **icon** style (`.iconOnly`, 15pt semibold). Do not put a `Label` / `systemImage` title on `.inkBarFillButton()` — that stacks or stretches the 32pt bar. Optional 2pt ink hairline under the bar in playground-style catalogs.

```swift
.toolbar(.hidden, for: .navigationBar)
.safeAreaInset(edge: .top) {
    InkNavBar(title: "Ask") {
        Button("Close") { }.inkBarOutlineButton()
        Button("Add", systemImage: "plus") { }.inkBarIconFillButton()
    }
}
```

## Rules

1. Screen background: `.inkScreen()`.
2. Text: `.inkText(.body)` (and siblings). Never `.primary` / `.tint` for chrome.
3. Page buttons: `.inkFillButton()` or `.inkOutlineButton()`. Min height 44.
4. Nav text: `.inkBarFillButton()` / `.inkBarOutlineButton()`. Nav icons: `.inkBarIconFillButton()` / `.inkBarIconOutlineButton()` (32 square).
5. Fields, cards: paper fill + `.inkStroke()`, padding `InkSpace.md`.
6. Voice: `VoiceButton` + `SoundWaveView(isActive:)`.
7. Reveal copy with `TypewriterText` (default hero, 22 cps). Replay by changing `.id`.

## Do not

- Add gray fills, shadows, materials, gradients, or colorful SF Symbols tints
- Use capsule / fully rounded buttons instead of 12pt continuous rects (mic is the only circle)
- Put full-width 44pt buttons in the nav bar
- Mix `ButtonStyle` with extra padding that breaks 44 / 32 heights
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
    .toolbar(.hidden, for: .navigationBar)
    .safeAreaInset(edge: .top) {
        InkNavBar(title: "Screen") {
            Button("Skip") { }.inkBarOutlineButton()
            Button("Save") { }.inkBarFillButton()
        }
    }
}
```

Lists: `listRowBackground(Ink.paper)`, hide default chrome when it fights the black/white stroke language.

## Verify

- Playground Type, Space, and Nav sections match the tables above
- Host screens use `.inkText`, `InkSpace`, and `InkNavBar`, not ad-hoc sizes or system inline titles
- No remaining `AskTheme` / `askFillButton` / `askOutlineButton` after a migration
