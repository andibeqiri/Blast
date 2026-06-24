# Blast — Codebase Guide

This document is for anyone adding to or modifying Blast. Read it before touching any file.

---

## Architecture in one sentence

A single `@Observable` view model owns an enum state machine. The view renders from it. Nothing else drives UI.

---

## State machine

`PaletteState` in `Models/PaletteState.swift` is the single source of truth. Every visible change in the UI — including animations — is a consequence of a state transition.

```swift
enum PaletteState: Equatable {
    case dismissed    // Pre-launch only. Background is transparent.
    case presenting   // Reserved, not currently used.
    case idle         // Empty input. IdleHomeView is visible.
    case filtering(String)  // Input matches a bookmark.
    case action(String)     // Input starts with a keyword token.
    case asking(String)     // Input reads like a question.
    case thinking(String)   // Fake LLM in-flight.
    case dismissing   // Bar is animating out. Resets to .idle after ~480ms.
}
```

**Rules:**
- Never scatter `Bool` flags across the view. Add a state case instead.
- `dismissing` always self-heals to `idle` — `dismiss()` schedules the reset. Do not add a path that leaves state permanently at `dismissing` or `dismissed`.
- Routing logic lives in `PaletteViewModel.route(_:)`, not in any view.

---

## Routing rules

`route(_:)` is called on every keystroke. It maps the current input string to a state. The priority order is fixed:

1. **Keyword action** — input starts with a known token + space (`yt `, `g `, `gh `). Keyword map is `keywordActions` in the view model.
2. **Navigation** — input contains `.` or prefix-matches a bookmark title/url. Bookmark list is `bookmarks` in the view model.
3. **Ask** — input ends in `?` or has 3+ words.
4. **Default** — filtering with no matches (user is mid-type).

To add a new keyword, append to `keywordActions` in `Features/Palette/PaletteViewModel.swift`. To add a bookmark, append to `bookmarks`. No other changes needed.

---

## Theme system

`UI/Theme/Theme.swift` defines every color, material, radius, and spacing token. Colors are specified as hex strings via `Color(hex:)`. Views read from `@Environment(\.theme)`.

**To add a new preset:**
1. Add a `static let` on `Theme` with all properties filled using hex values.
2. Add a case to `ThemePreset` and wire it to the new `Theme` instance.
3. Add a `preview: Color` for the picker dot.

**Never hardcode colors in views.** Use `theme.navigationAccent`, `theme.askAccent`, `theme.primaryText`, etc. If a new semantic color is needed, add it to the `Theme` struct first.

---

## Animation rules

- **Springs only.** Use `.spring(response:dampingFraction:)` for every motion. No `.easeInOut`, no `.linear` except for shimmer loops.
- **Always pass `value:`** to `.animation(_:value:)`. The no-value form is banned.
- **Use `withAnimation` for gestures and events; use `.animation(_:value:)` for state-driven changes.** Don't mix them on the same property.
- Haptics fire via `.sensoryFeedback(_:trigger:)` — never `UIImpactFeedbackGenerator` directly.

---

## Adding a new result row type

1. Add a case to `Models/PaletteState.swift` if the new mode needs distinct behavior.
2. Add the corresponding `route` branch in `Features/Palette/PaletteViewModel.swift`.
3. Add a `case` to the switch in `Features/Results/ResultsList.swift`.
4. Create a new `*Row.swift` file in `Features/Results/` (follow `BookmarkRow` / `ActionRow` as the pattern — `Button` wrapper, `.plain` style, `theme` from environment).
5. If tapping should open a destination, add a case to `Models/Destination.swift` and handle it in `Features/Destination/DestinationView.swift` (`pageCanvas`).

---

## Adding a new destination screen

`Destination` lives in `Models/Destination.swift`.

1. Add a case to `Destination`.
2. Handle it in `DestinationView.pageCanvas` with a new `Mock*View` inside `Features/Destination/DestinationView.swift`.
3. Set `vm.destination` from whichever action triggers it.

---

## Adding a new feature

New features go in `Features/<FeatureName>/`. Each feature folder owns its views and any feature-specific sub-components. Shared, reusable UI pieces that aren't tied to a single feature live in `UI/Components/`.

---

## File map

```
Sources/Blast/
├── App/
│   ├── BlastApp.swift          Entry point only — no logic here
│   └── ContentView.swift       Root layout, drag gesture, palette panel coordinator
├── Features/
│   ├── Destination/
│   │   └── DestinationView.swift   Mock browser chrome + page/search/answer canvases
│   ├── Home/
│   │   └── IdleHomeView.swift      Logo, tip chips, recent rows, FlowLayout
│   ├── Palette/
│   │   ├── CommandBar.swift        Text field + mode icon + clear button
│   │   └── PaletteViewModel.swift  State machine, routing, all fake data
│   └── Results/
│       ├── ActionRow.swift         Keyword-action result row
│       ├── AskRow.swift            Ask / thinking / answer result row
│       ├── BookmarkRow.swift       Bookmark navigation result row
│       └── ResultsList.swift       Scroll container that switches between row types
├── Models/
│   ├── Bookmark.swift          Bookmark data model
│   ├── Destination.swift       Destination enum (page / search / answer)
│   ├── KeywordAction.swift     Keyword action data model
│   └── PaletteState.swift      PaletteState enum — the state machine cases
└── UI/
    ├── Components/
    │   ├── ShimmerView.swift   Animated shimmer used during thinking state
    │   ├── ThemePicker.swift   Floating theme-switcher widget
    │   └── ToastView.swift     Ephemeral top-of-screen message
    └── Theme/
        └── Theme.swift         Theme struct, hex Color init, presets, ThemePreset enum
```

`Project.swift` — Tuist manifest. Edit to change bundle ID, deployment target, or add targets.

---

## Build

```bash
mise install   # installs Tuist (version pinned in .mise.toml)
tuist generate
open Blast.xcworkspace
```

Target: iOS 17+. No external dependencies. After adding or removing source files, re-run `tuist generate` before building.
