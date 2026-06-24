# Blast

> A single-field command bar for iOS that opens, searches, and answers — built to showcase animation, gesture, and UI-state craft.

<!-- Replace with a 5-second simulator recording -->
![demo](assets/demo.gif)

---

## What it does

One text field does triple duty depending on what you type:

| Input | Mode | Result |
|-------|------|--------|
| Prefix-matches a bookmark | **Navigation** | Rows filter live; tap to open |
| Starts with `yt `, `g `, or `gh ` | **Action** | Top row becomes a contextual shortcut |
| 3+ words or ends in `?` | **Ask** | Accent shifts, shimmer runs, stub answer appears |

Tapping any result opens a mock destination screen — a fake browser chrome with a simulated page-load progress bar and mode-appropriate content (search results, bookmark page, or an AI answer card).

---

## Technical highlights

These are the things worth looking at in the code:

**Explicit state machine** (`PaletteViewModel.swift`)  
`PaletteState` is a single enum with eight cases. Every transition — including the intro animation and drag-to-dismiss — flows through it. No scattered booleans.

**Spring-only motion** (`ContentView.swift`)  
Every animated property uses `.spring(response:dampingFraction:)`. The values were tuned by feel. No `.easeInOut` anywhere.

**Drag-to-dismiss with velocity** (`ContentView.swift` → `dismissGesture`)  
A fast flick dismisses at ~25% drag distance; a slow drag needs ~55%. Both thresholds are derived from the actual screen height via `onGeometryChange`. Rubber-band resistance is applied past the top edge.

**Interruptible present/dismiss** (`PaletteViewModel.swift`)  
The bar starts at `.dismissed`, animates to `.idle` after the first frame renders, and resets cleanly after dismiss — background never goes black mid-transition.

**Mode morph** (`CommandBar` in `ContentView.swift`)  
Navigation → ask transition animates the accent color, border, icon, and hint text together using value-tracked implicit animations. The shift is deliberate and reads as intentional.

**Staggered idle home** (`IdleHomeView.swift`)  
Logo, tip chips, and recent rows each animate in on a staggered delay using a single `appeared` boolean and per-element `.animation(.spring.delay(...))`. The `FlowLayout` wraps chips to any width without `GeometryReader`.

**Theme system** (`Theme.swift`)  
A `Theme` struct holds every color, material, radius, and padding token. Three presets (Midnight, Carbon, Sunset) are injectable via `EnvironmentValues`. Switching themes cross-fades with a spring.

**`@Observable` + `@MainActor`** throughout  
No `ObservableObject`, no `@StateObject`, no `@Published`. The view model is a plain `@Observable` class owned via `@State`.

---

## Running it

Requires [Tuist](https://tuist.io) and Xcode 16+.

```bash
brew install tuist
tuist generate
open Blast.xcworkspace
```

Run on any iOS 17+ simulator. Enable the software keyboard via **I/O → Keyboard → Toggle Software Keyboard** to use the bar.

---

## Project structure

```
Sources/Blast/
├── BlastApp.swift          # Entry point
├── PaletteViewModel.swift  # State machine, routing, all fake data
├── ContentView.swift       # Command bar, results list, drag gesture, theme picker
├── IdleHomeView.swift      # Logo, tip chips, recent rows — shown when input is empty
├── DestinationView.swift   # Mock browser screen (page / search / answer)
└── Theme.swift             # Theme struct, three presets, EnvironmentValues extension
Project.swift               # Tuist project manifest
Tuist.swift                 # Tuist config
```

No third-party dependencies. No networking. No persistence. The interaction is the product.

---

## What's faked

- Bookmarks and history: 12 hardcoded entries
- Keyword actions: `yt`, `g`, `gh` mapped to static URL templates
- Ask mode: 1.2s shimmer delay, then one of four canned stub answers
- Destination screens: mock chrome + skeleton content, no web view
