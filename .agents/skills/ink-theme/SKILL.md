---
name: ink-theme
description: >-
  Applies the Ink black-and-white SwiftUI design system from the InkTheme
  repo. Use when building or restyling iOS/SwiftUI screens, migrating
  AnAskBot AskTheme, adding voice/mic buttons, sound
  waves, outlined 44pt buttons, InkNavBar, InkSheet (list/form/confirm),
  InkDialog / InkAlert overlay, bar fill/outline actions, InkListRow, named
  type styles (display, hero, body, capital), InkSpace, or when the user
  mentions Ink, InkTheme, black/white UI, or this skill.
---

# Ink Theme

Source of truth: `/Users/qilei/Code/iOS/InkTheme`

Copy files from that app. Do not reinvent tokens, type styles, button styles, or motion.

## When to use

- New SwiftUI screens that should look like AnAskBot / Ink
- Restyling an existing iOS app to black paper, system type, stroked buttons
- Adding mic or sound-wave UI

## Copy these files

From `InkTheme/InkTheme/` into the host app (keep names):

| File | Role |
| --- | --- |
| `Theme/Ink.swift` | Color/layout tokens, fill/outline + bar buttons, `inkScreen()`, `inkStroke()`, `InkFieldSize`, `inkField()` |
| `Theme/InkAppearance.swift` | `InkAppearance`, `InkAccent`, `InkGround`, `InkRadius` (zero / sm / md / lg), `.inkAppearance(_:accent:ground:radius:)` |
| `Theme/InkAppearanceReveal.swift` | 12-point curved blob; each point expands at its own speed |
| `Theme/InkText.swift` | `InkTextStyle`, `.inkText(_:)`, `InkSpace` |
| `Theme/InkNav.swift` | `InkNavBar` — hero title + trailing actions |
| `Theme/InkBottomNav.swift` | `InkBottomNav` — icon + capital label tabs |
| `Theme/InkList.swift` | `InkListRow`, `InkListCover` — cover + title + caption + bar action |
| `Theme/InkSheet.swift` | `InkSheet`, detents, `InkSheetBody`, `InkSheetList`, `InkSheetFooter` |
| `Theme/InkDialog.swift` | Overlay `InkDialog`, `InkDialogFooter`, `InkAlert`, `.inkDialog` / `.inkAlert` |
| `Theme/InkToggle.swift` | Capsule `Toggle` style `.ink` |
| `Theme/InkCheckbox.swift` | Square `Toggle` style `.inkCheckbox` |
| `Components/VoiceButton.swift` | 72pt circular mic |
| `Components/SoundWaveView.swift` | Idle/active bars |
| `DesignSystemPlaygroundView.swift` | Optional catalog; host as a debug sheet if useful |

If the host module already defines these types, reuse them. Do not duplicate.

Xcode with a synchronized root group picks up new files automatically. Older `.pbxproj` file lists need the files added to the app target.

## Color and layout

| Token | Light | Dark |
| --- | --- | --- |
| `inkPalette.ink` | black | white |
| `inkPalette.paper` | white | `InkGround` (default black) |
| `inkPalette.accent` | follows `InkAccent` | same hue for red / blue / green; ink accent inverts with `ink` |
| `inkPalette.inverse` | white | black |

Read colors from `@Environment(\.inkPalette)` after the host root applies `.inkAppearance`. Do not use `Color.black` / `Color.white` for chrome.

| Token | Value |
| --- | --- |
| `Ink.buttonHeight` | `44` |
| `Ink.barButtonHeight` | `32` |
| `Ink.cornerRadius` | `12` (md default; fields now follow `inkRadius.button`) |
| `Ink.sheetCornerRadius` | `24` (medium and large chrome; full lerps to 0) |
| `Ink.sheetScreenInset` | `20` (medium vertical inset) |
| `Ink.sheetMediumHorizontalInset` | `10` (medium side inset) |
| `Ink.sheetLargeHorizontalInset` | `5` (large side inset; full lerps to 0) |
| `Ink.sheetLargeVerticalInset` | `10` (large vertical inset; full lerps to 0) |
| `Ink.sheetFullTopExtra` | `36` (added above safe top inside full-bleed content) |
| `Ink.sheetMediumFraction` | `0.5` |
| `Ink.sheetLargeFraction` | `0.88` |
| `Ink.dialogMaxWidth` | `320` |
| `Ink.dialogMoveInOffset` | `40` |
| `Ink.borderWidth` | `2` |
| `Ink.voiceSize` | `72` |
| `Ink.listCoverSize` | `48` |
| `Ink.toggleWidth` | `52` |
| `Ink.toggleHeight` | `32` |
| `Ink.toggleKnobSize` | `20` |
| `Ink.checkboxSize` | `32` |

`ink` inverts with appearance. Light paper is always white. Dark paper follows `InkGround`: black `#000000`, deep red `#1E080B`, deep blue `#000E1F`, deep green `#04180B`. `inverse` is the untinted partner of ink (white in light, black in dark) for fill labels.

`accent` is a separate axis: default **ink** matches `ink`. Red `#F6465D`, Blue `#0077FF`, and Green `#22C55E` are fixed in both appearances.

Use `accent` for fill button backgrounds, listening `VoiceButton` fill, `SoundWaveView` bars, **on** Ink toggles, and **on** Ink checkboxes. Use `inverse` for fill button labels, the listening mic icon, the on-toggle knob, and the checkbox hook. Keep `ink` for type, outlines, hairlines, list covers, and the off-toggle knob. Use `paper` for screens, nav, sheets, outline fills, and the off-toggle track. No SF Rounded. No extra grays.

## Appearance

Three modes, persisted on `InkAppearanceStore` under `ink.appearance`. Default is **system**.

| Mode | Effect |
| --- | --- |
| `system` | Follow iOS appearance (`preferredColorScheme` is `nil`) |
| `light` | Lock black ink on white paper |
| `dark` | Lock white ink; paper follows `InkGround` |

Host apps must hold one `InkAppearanceStore`, put it in the environment, and apply `.inkAppearance` at the `WindowGroup` root so colors invert on tap. Pass `accent`, `ground`, and `radius` from the same store:

```swift
@main
struct HostApp: App {
    @State private var appearanceStore = InkAppearanceStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appearanceStore)
                .inkAppearance(
                    appearanceStore.appearance,
                    accent: appearanceStore.accent,
                    ground: appearanceStore.ground,
                    radius: appearanceStore.radius
                )
        }
    }
}
```

Call `appearanceStore.select(.dark)` (or `.light` / `.system`) from settings. Pass the control’s window-space center as `origin` to expand a 12-point curved blob from that button. Each point has its own end radius and duration so the silhouette changes while it grows. Motion is regenerated on every switch:

```swift
appearanceStore.select(.dark, origin: buttonCenterInGlobal)
```

`origin: nil` (the default) switches instantly. Skip the reveal when Reduce Motion is on, or when the resolved ink/paper palette does not change (for example Light while the system is already light). Accent, ground, and radius changes do not play the blob.

## Accent

Four values, persisted on the same `InkAppearanceStore` under `ink.accent`. Default is **ink**. Independent of Light / Dark / System.

| Accent | Effect |
| --- | --- |
| `ink` | `palette.accent` equals `palette.ink` |
| `red` / `blue` / `green` | Fixed hue in both appearances |

```swift
appearanceStore.selectAccent(.red)
```

Switch is instant. Read fill from `@Environment(\.inkPalette).accent`.

## Ground

Four values, persisted on the same `InkAppearanceStore` under `ink.ground`. Default is **black**. Independent of accent. Light paper stays white.

| Ground | Dark paper |
| --- | --- |
| `black` | `#000000` |
| `red` | `#1E080B` |
| `blue` | `#000E1F` |
| `green` | `#04180B` |

```swift
appearanceStore.selectGround(.red)
```

Switch is instant. Read screens from `@Environment(\.inkPalette).paper`. Fill labels use `inverse`, not tinted paper.

## Radius

Four values, persisted on the same `InkAppearanceStore` under `ink.radius`. Default is **md**. Independent of color axes.

| Radius | Button / Checkbox / Cover / Field | Dialog | Switch track | Switch knob |
| --- | --- | --- | --- | --- |
| `zero` | 0 | 0 | 0 | 0 |
| `sm` | 6 | 10 | 6 | 4 |
| `md` | 12 | 16 | fully rounded (`height / 2`) | same as track |
| `lg` | 16 | 20 | fully rounded (`height / 2`) | same as track |

Buttons, checkbox, list covers, and fields (`.inkStroke()` / `.inkField()`) read `@Environment(\.inkRadius).button`. Dialog cards use `.dialog` (button + 4, zero stays 0). Switch track uses `.toggle`; the knob uses `.toggleKnob` — `md`/`lg` are fully rounded, `sm` knob is 2pt tighter than the track, `zero` is square on both.

```swift
appearanceStore.selectRadius(.lg)
```

Switch is instant. At `sm` the knob is 2pt tighter than the track.

Do not invent extra dark-mode grays or materials. Dark ink is still white; only paper can be a deep hue.

## Type — `.inkText(_:)`

Do not use raw `.font(.system(size:))` or leftover `AskTheme.*Font`. Uppercase `capital` strings in the call site.

| Style | Scene | Size | Weight | Tracking | Color |
| --- | --- | --- | --- | --- | --- |
| `display` | Short brand (INK / ASK) | 64 | bold | 4 | ink |
| `displaySmall` | Onboarding brand line | 48 | bold | 3 | ink |
| `numeral` | Score | 56 | bold | 0 | ink |
| `hero` | Nav title, English prompt | 28 | bold | 0 | ink |
| `title` | Empty/page title | title2 (~22) | semibold | 0 | ink |
| `body` | Paragraph, md field, list subtitle | body (~17) | regular | 0 | ink |
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

## Bottom Nav

Pin `InkBottomNav` with a bottom safe area inset. It is chrome only — the host switches content from `selection`. Each `InkTabItem` takes an `id`, an SF Symbol `systemImage`, and a `label`. Uppercase the label at the call site.

Paper background extends under the Home Indicator. A 2pt ink hairline sits on top. Items share the width. Each item is at least 44pt tall: a 20pt semibold icon and a `capital` label, spaced `xxs`. Selected ink is full opacity. Unselected ink uses the capital opacity (0.45). Pressed opacity is 0.55. No fill, accent, or gray.

```swift
.safeAreaInset(edge: .bottom, spacing: 0) {
    InkBottomNav(
        items: [
            InkTabItem(id: .home, label: "HOME", systemImage: "house"),
            InkTabItem(id: .ask, label: "ASK", systemImage: "mic"),
        ],
        selection: $tab
    )
}
```

## List

Use `InkListRow` for cover + title + description + trailing action. Cover is `InkListCover(size:)` (default **small**), paper + the button radius + an inside ink stroke. Title `bodyStrong`, description `caption`, spacing `xxs`. Trailing actions are **bar** styles (32pt), never 44pt page buttons. Bottom hairline is 2pt ink. Last row: `showsBottomBorder: false`.

| Size | Frame |
| --- | --- |
| `small` (default) | 48 × 48 |
| `medium` | 72 × 72 |
| `large` | 96 × 72 (landscape 4:3) |

In a sheet, wrap rows in `InkSheetList` so they inset with the nav (`xl` sides, `sm` top and bottom). Hide the system separator so it does not double the hairline:

```swift
InkSheetList {
    InkListRow(title: "Pat", description: "English · A1") {
        InkListCover(size: .medium) {
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

## Field

Use `.inkField()` on `TextField` / `TextEditor`. Paper fill, radius-token clip, 2pt `strokeBorder`. Size is independent of the radius picker. `sm` uses footnote at full ink — not caption opacity.

| Size | Height | Horizontal inset | Type | Scene |
| --- | --- | --- | --- | --- |
| `md` (default) | 44 | 12 (`InkSpace.md`) | body | Forms, full-width answers |
| `sm` | 32 | 12 (`InkSpace.md`) | footnote | Compact rows next to a 32pt bar action |

```swift
TextField("Name", text: $name).inkField()
TextField("Search", text: $query).inkField(size: .sm)
```

## Sheet

Present with `.inkSheet { InkSheet(...) }` on the host screen (attach high enough to cover nav). Do **not** use system `.sheet` — it cannot own radius, inset, or a 2pt stroke, and iOS 26/27 half sheets become glass. Do not use system `.navigationTitle` inside a sheet. Close is `InkSheetCloseButton` (32 square, `xmark`, outline) — caller still owns dismiss.

| `InkSheetDetent` | Height (full-screen frame `H`) | Scene |
| --- | --- | --- |
| `.medium` | `H * 0.5` | Short confirm |
| `.large` | `H * 0.88` | List / form with margin (default) |
| `.full` | `H` | Edge-to-edge |
| `.mediumAndLarge` | `0.5 H` ↔ `0.88 H` | Confirm that can grow, still floated |
| `.largeAndFull` | `0.88 H` ↔ `H` | Tall sheet that can go full-bleed |
| `.mediumAndFull` | `0.5 H` ↔ `0.88 H` ↔ `H` | Confirm that can grow through large into full |

Chrome: overlay card on an ink scrim (`palette.ink.opacity(0.45)`). Three chrome stops (lerp with height when multiple detents):

| Stop | Outer gap (screen → card) | Corner radius | Content safe area |
| --- | --- | --- | --- |
| Medium | safe area + `10` side / `20` vertical | `24` (`0` when radius token is `zero`) | none |
| Large | safe area + `5` side / `10` vertical | `24` (same as medium) | none |
| Full | `0` (full-bleed paper) | `0` | pad content by safe area; top also adds `sheetFullTopExtra` (`36`) |

Card is opaque `paper` with a 2pt ink `strokeBorder`. Bottom-aligned; the overlay geometry ignores safe area so full paper can fill the screen while content keeps safe insets. Appear and dismiss both travel the sheet height (`Y + h`); appear ease-out, dismiss ease-in, no fade. Skip motion when Reduce Motion is on. Visible ink grabber (2pt capsule) + `InkNavBar`. Drag **only** the grabber and nav to move detents or dismiss — do not attach drag to `InkSheetBody` / `InkSheetList`. Optional `InkSheetFooter`.

Content:

- **List:** `InkSheetList` (horizontal `xl` + vertical `sm` content margins). Rows: `InkListRow` + `InkListCover` + `.inkSheetListRow()`.
- **Form:** `InkSheetBody` (scroll, `InkSpace.xl` padding and stack). Fields: `.inkField()`. Section labels `.inkText(.capital)`.
- **Confirm:** no extra scroll; `capital` + `body` with `InkSpace.sm`. Footer: fill primary, outline secondary, spacing `md`.

```swift
.inkSheet(isPresented: $showForm) {
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
                .inkField()
        }
    }
}
```

## Dialog

Present with `.inkDialog` / `.inkAlert` on the host screen (attach high enough to cover nav). Do **not** use system `.alert` or `.confirmationDialog`. Overlay sits centered on an ink scrim — not a bottom sheet.

| | Scene |
| --- | --- |
| `InkAlert` via `.inkAlert` | Confirm / delete — title + optional message + 1–2 actions |
| `InkDialog` via `.inkDialog` | Custom body (field, copy, etc.) + optional close + footer |

Chrome: scrim `palette.ink.opacity(0.45)` (no material / gray). Card is opaque `paper`, corner radius `inkRadius.dialog` (button + 4; zero stays square), 2pt ink `strokeBorder`, max width `Ink.dialogMaxWidth` (320), horizontal inset `Ink.sheetScreenInset` (20). Title uses `.inkText(.title)` (not hero). Close reuses `InkSheetCloseButton`. Footer is `InkDialogFooter` — stacked 44pt fill / outline, spacing `md`, no hairline. Appear with a 40pt Y move-in (`Ink.dialogMoveInOffset`); dismiss is instant; no fade. Skip the move when Reduce Motion is on. Buttons and fields inside still follow `inkRadius.button`.

Backdrop: custom dialog defaults to `dismissOnBackdrop: true`. Alert uses `false` — user must tap an action. Caller still owns dismiss (`isPresented = false`).

```swift
.inkAlert(
    isPresented: $showDelete,
    title: "Delete",
    message: "This cannot be undone.",
    primary: "Delete",
    secondary: "Cancel"
) {
    // primary
}

.inkDialog(isPresented: $showEdit) {
    InkDialog(title: "Rename") {
        InkSheetCloseButton { showEdit = false }
    } footer: {
        InkDialogFooter {
            Button("Save") { showEdit = false }.inkFillButton()
        }
    } content: {
        Text("NAME").inkText(.capital)
        TextField("Name", text: $name).inkField()
    }
}
```

## Rules

1. Screen background: `.inkScreen()`.
2. Text: `.inkText(.body)` (and siblings). Never `.primary` / `.tint` for chrome.
3. Page buttons: `.inkFillButton()` or `.inkOutlineButton()`. Min height 44.
4. Nav text: `.inkBarFillButton()` / `.inkBarOutlineButton()`. Nav icons: `.inkBarIconFillButton()` / `.inkBarIconOutlineButton()` (32 square).
5. Fields: `.inkField()` (md 44, body) or `.inkField(size: .sm)` (32, footnote, full ink). Cards: paper fill + `.inkStroke()`. Corners follow the radius token.
6. Voice: `VoiceButton` + `SoundWaveView(isActive:)`.
7. Toggle: `Toggle(...).toggleStyle(.ink)`. Off paper + ink stroke; on accent fill + ink stroke.
8. Checkbox: `Toggle(...).toggleStyle(.inkCheckbox)`. 32 square; off 6% ink + waiting inverse hook + ink stroke; on accent fill + ink stroke. Tap pops the hook bigger then back.
9. Sheets: `.inkSheet` + `InkSheet` + `InkSheetBody` / `InkSheetList` / `InkSheetFooter`. Lists: `InkListRow`. No system `.sheet`. No gray grouped lists.
10. Dialogs: `InkDialog` / `InkAlert` via `.inkDialog` / `.inkAlert`. No system `.alert`.
11. Bottom nav: `InkBottomNav` with `InkTabItem` (icon + capital label). Pin with `.safeAreaInset(edge: .bottom)`. No system tab bar.

## Do not

- Add gray fills, shadows, materials, gradients, or colorful SF Symbols tints
- Use capsule / fully rounded buttons instead of radius-token rects (circle is only the mic)
- Put full-width 44pt buttons in the nav bar
- Mix `ButtonStyle` with extra padding that breaks 44 / 32 heights
- Use inset grouped / gray list chrome in sheets
- Use system `.sheet` instead of `.inkSheet` / `InkSheet`
- Use system `.alert` / `.confirmationDialog` instead of `InkAlert` / `InkDialog`
- Port AnAskBot product code (`WordHighlighter`, Ask flow, tutors). That is not Ink.
- Invent extra type sizes (no 40pt display)

## Apply to a host screen

```swift
NavigationStack {
    VStack(alignment: .leading, spacing: InkSpace.lg) {
        Text("TITLE")
            .inkText(.capital)

        Text(prompt)
            .inkText(.hero)

        TextField("Answer", text: $answer)
            .inkField()

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

- Playground Appearance, Accent, Paper, Radius, Type, Space, Nav, Bottom Nav, List, Field, Sheet, and Dialog sections match the tables above
- Host app root applies `.inkAppearance(store.appearance, accent: store.accent, ground: store.ground, radius: store.radius)` so Light / Dark / System, accent, dark paper, and radius work
- Host screens use `.inkText`, `InkSpace`, `InkNavBar`, `InkListRow`, `.inkSheet` / `InkSheet`, and `InkDialog` / `InkAlert`, not ad-hoc sizes or system inline titles / alerts / sheets
- No remaining `AskTheme` / `askFillButton` / `askOutlineButton` after a migration
