---
name: ink-theme
description: >-
  Applies the Ink black-and-white SwiftUI design system from the InkTheme
  repo. Use when building or restyling iOS/SwiftUI screens, migrating
  AnAskBot AskTheme, adding typewriter text, voice/mic buttons, sound
  waves, outlined 44pt buttons, InkNavBar, InkSheet (list/form/confirm),
  bar fill/outline actions, InkListRow, named type styles (display, hero, body,
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
| `Theme/Ink.swift` | Color/layout tokens, fill/outline + bar buttons, `inkScreen()`, `inkStroke()` |
| `Theme/InkAppearance.swift` | `InkAppearance` (system / light / dark), `.inkAppearance(_:)` |
| `Theme/InkText.swift` | `InkTextStyle`, `.inkText(_:)`, `InkSpace` |
| `Theme/InkNav.swift` | `InkNavBar` — hero title + trailing actions |
| `Theme/InkList.swift` | `InkListRow`, `InkListCover` — cover + title + caption + bar action |
| `Theme/InkSheet.swift` | `InkSheet`, detents, `InkSheetBody`, `InkSheetList`, `InkSheetFooter` |
| `Components/TypewriterText.swift` | Character-by-character English reveal (default `.hero`) |
| `Components/VoiceButton.swift` | 72pt circular mic |
| `Components/SoundWaveView.swift` | Idle/active bars |
| `DesignSystemPlaygroundView.swift` | Optional catalog; host as a debug sheet if useful |

If the host module already defines these types, reuse them. Do not duplicate.

Xcode with a synchronized root group picks up new files automatically. Older `.pbxproj` file lists need the files added to the app target.

## Color and layout

| Token | Light | Dark |
| --- | --- | --- |
| `inkPalette.ink` | black | white |
| `inkPalette.paper` | white | black |

Read colors from `@Environment(\.inkPalette)` after the host root applies `.inkAppearance`. Do not use `Color.black` / `Color.white` for chrome.

| Token | Value |
| --- | --- |
| `Ink.buttonHeight` | `44` |
| `Ink.barButtonHeight` | `32` |
| `Ink.cornerRadius` | `12` |
| `Ink.sheetCornerRadius` | `24` |
| `Ink.sheetScreenInset` | `20` |
| `Ink.borderWidth` | `2` |
| `Ink.voiceSize` | `72` |
| `Ink.listCoverSize` | `48` |

Accent follows the same invert (black in light, white in dark). No brand color, no SF Rounded, no extra palette.

## Appearance

Three modes, persisted on `InkAppearanceStore` under `ink.appearance`. Default is **system**.

| Mode | Effect |
| --- | --- |
| `system` | Follow iOS appearance (`preferredColorScheme` is `nil`) |
| `light` | Lock black ink on white paper |
| `dark` | Lock white ink on black paper |

Host apps must hold one `InkAppearanceStore`, put it in the environment, and apply `.inkAppearance` at the `WindowGroup` root so colors invert on tap:

```swift
@main
struct HostApp: App {
    @State private var appearanceStore = InkAppearanceStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appearanceStore)
                .inkAppearance(appearanceStore.appearance)
        }
    }
}
```

Call `appearanceStore.select(.dark)` (or `.light` / `.system`) from settings. Read fills from `@Environment(\.inkPalette)`.

Do not invent extra dark-mode grays or materials. Dark is a strict ink/paper invert.

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

## List

Use `InkListRow` for cover + title + description + trailing action. Cover is `InkListCover` (48pt square, 12pt continuous radius, paper + `.inkStroke()`). Title `bodyStrong`, description `caption`, spacing `xxs`. Trailing actions are **bar** styles (32pt), never 44pt page buttons. Bottom hairline is 2pt ink. Last row: `showsBottomBorder: false`.

In a sheet, wrap rows in `InkSheetList` so they inset with the nav (`xl` sides, `sm` top and bottom). Hide the system separator so it does not double the hairline:

```swift
InkSheetList {
    InkListRow(title: "Pat", description: "English · A1") {
        InkListCover {
            Image(systemName: "person.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(palette.ink)
        }
    } action: {
        Button("Start") { }.inkBarFillButton()
    }
    .inkSheetListRow()
}
```

Photos go in `InkListCover` with `.resizable().scaledToFill()`. Do not mix this hairline with `.listRowSeparatorTint`.

## Sheet

Present with `.sheet { InkSheet(...) }`. Do not use system `.navigationTitle` inside a sheet. Close is `InkSheetCloseButton` (32 square, `xmark`, outline) — caller still owns dismiss.

| `InkSheetDetent` | Scene |
| --- | --- |
| `.large` | List, multi-step form (default) |
| `.medium` | Short confirm |
| `.mediumAndLarge` | Starts medium, can expand |

Chrome: **opaque** `.presentationBackground(Ink.paper)` on every detent. iOS 26/27 half sheets default to Liquid Glass (inset, translucent). Do not use `Color.clear`, `.background`, or a missing presentation background — those re-enable glass. No sheet stroke. `.medium` also lifts by `Ink.sheetScreenInset` (20) from the screen bottom. Large stays edge-attached. Visible drag indicator. Header is `InkNavBar` with `topPadding: InkSpace.xl`. Optional `InkSheetFooter`.

Field strokes use `.inkStroke()` (`strokeBorder` so the 2pt line is not clipped).

Content:

- **List:** `InkSheetList` (horizontal `xl` + vertical `sm` content margins). Rows: `InkListRow` + `InkListCover` + `.inkSheetListRow()`.
- **Form:** `InkSheetBody` (scroll, `InkSpace.xl` padding and stack). Fields: `.inkText(.body)` + `padding(InkSpace.md)` + `.inkStroke()`. Section labels `.inkText(.capital)`.
- **Confirm:** no extra scroll; `capital` + `body` with `InkSpace.sm`. Footer: fill primary, outline secondary, spacing `md`.

```swift
.sheet(isPresented: $showForm) {
    InkSheet(title: "Edit") {
        InkSheetCloseButton { showForm = false }
    } footer: {
        InkSheetFooter {
            Button("Save") { showForm = false }.inkFillButton()
        }
    } content: {
        InkSheetBody {
            Text("NAME").inkText(.capital)
            TextField("Name", text: $name)
                .inkText(.body)
                .padding(InkSpace.md)
                .inkStroke()
        }
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
7. Sheets: `InkSheet` + `InkSheetBody` / `InkSheetList` / `InkSheetFooter`. Lists: `InkListRow`. No gray grouped lists.
8. Reveal copy with `TypewriterText` (default hero, 22 cps). Replay by changing `.id`.

## Do not

- Add gray fills, shadows, materials, gradients, or colorful SF Symbols tints
- Use capsule / fully rounded buttons instead of 12pt continuous rects (mic is the only circle)
- Put full-width 44pt buttons in the nav bar
- Mix `ButtonStyle` with extra padding that breaks 44 / 32 heights
- Use inset grouped / gray list chrome in sheets
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

Lists: `InkListRow` + `listRowBackground(Ink.paper)`. Hide system separators when the row draws its own 2pt hairline.

## Verify

- Playground Appearance, Type, Space, Nav, List, and Sheet sections match the tables above
- Host app root applies `.inkAppearance` (or `.preferredColorScheme`) so Light / Dark / System works
- Host screens use `.inkText`, `InkSpace`, `InkNavBar`, `InkListRow`, and `InkSheet`, not ad-hoc sizes or system inline titles
- No remaining `AskTheme` / `askFillButton` / `askOutlineButton` after a migration
