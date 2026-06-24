# Blast — Codebase Guide

This document is for anyone adding to or modifying Blast. Read it before touching any file.

---

## Architecture in one sentence

A single `@Observable` view model owns an enum state machine. The view renders from it. Nothing else drives UI.

---

## State machine

`PaletteState` in `PaletteViewModel.swift` is the single source of truth. Every visible change in the UI — including animations — is a consequence of a state transition.

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

To add a new keyword, append to `keywordActions`. To add a bookmark, append to `bookmarks`. No other changes needed.

---

## Theme system

`Theme.swift` defines every color, material, radius, and spacing token. Views read from `@Environment(\.theme)`.

**To add a new preset:**
1. Add a `static let` on `Theme` with all properties filled.
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

1. Add a case to `PaletteState` if the new mode needs distinct behavior.
2. Add the corresponding `route` branch in `PaletteViewModel.route(_:)`.
3. Add a `case` to `ResultsList.body`'s switch in `ContentView.swift`.
4. Create a new row view (follow `BookmarkRow` / `ActionRow` as the pattern — `Button` wrapper, `.plain` style, `theme` from environment).
5. If tapping should open a destination, add a case to `Destination` in `PaletteViewModel.swift` and handle it in `DestinationView.pageCanvas`.

---

## Adding a new destination screen

`Destination` is defined in `PaletteViewModel.swift` (not `DestinationView.swift`) because `@Observable` macro expansion needs it in scope at compile time.

1. Add a case to `Destination`.
2. Handle it in `DestinationView.pageCanvas` with a new `Mock*View`.
3. Set `vm.destination` from whichever action triggers it.

---

## File map

| File | Responsibility |
|------|---------------|
| `PaletteViewModel.swift` | State machine, routing, all fake data, `Destination` enum |
| `ContentView.swift` | Root layout, command bar, results list, drag gesture, theme picker, row views, shimmer, toast |
| `IdleHomeView.swift` | Logo, tip chips, recent rows, `FlowLayout` |
| `DestinationView.swift` | Mock browser chrome + three canvas types (page / search / answer) |
| `Theme.swift` | `Theme` struct, presets, `EnvironmentValues` extension, `ThemePreset` enum |
| `BlastApp.swift` | Entry point only — no logic here |
| `Project.swift` | Tuist manifest — edit to change bundle ID, deployment target, or add targets |

---

## Build

```bash
brew install tuist   # first time only
tuist generate
open Blast.xcworkspace
```

Target: iOS 17+. No external dependencies. After adding or removing source files, re-run `tuist generate` before building.
