# Blast

A single-screen iOS demo: a one-field command bar that routes what you type to **open**, **search**, or **ask**. Built to showcase animation, gesture, and UI-state craft. Backend is entirely faked; the interaction is the product.

## Skills to use

This machine has two globally installed agent skills. Use them.

- **swiftui-expert-skill** (`~/.agents/skills/swiftui-expert-skill`) — consult for all SwiftUI layout, animation, and state patterns. This is the primary skill for this build; the entire deliverable is SwiftUI craft.
- **swift-concurrency** (`~/.agents/skills/swift-concurrency`) — consult for the fake async work (the "thinking…" delay in ask mode) and any `Task`/actor usage. Keep concurrency minimal here, but do it correctly per the skill rather than ad hoc.

## Purpose / context

Portfolio piece for an iOS role at a mobile-browser company. Reviewers will play with it for ~20 seconds and look for: smooth interruptible animation, a clean explicit state machine, gesture handling that feels right, and the "last 10%" polish (haptics, spring tuning, keyboard tracking). Do not build a real browser or a real LLM call. Hardcode everything behind the bar.

## Scope discipline

- One screen. The command bar IS the app.
- Target: 1–2 Swift files. Resist growth.
- No networking. No persistence. No external dependencies.
- iOS 17+ (use `@Observable`, modern SwiftUI animation APIs).
- A README with a 5-second simulator GIF at the top is part of the deliverable. No GIF = no signal.

## The core interaction

A search/command field pinned near the bottom of the screen (thumb-reachable), with a results list above it that updates live as the user types. One field does triple duty depending on input:

1. **Navigation mode** — input matches hardcoded bookmarks/history. Rows filter live. Tapping a row "opens" it (show a toast / placeholder, e.g. "Opening github.com").
2. **Action mode** — input starts with a known keyword (`yt`, `g`, `gh`). Top row becomes an action: e.g. `yt cats` → "Search YouTube for 'cats'". Return executes (toast).
3. **Ask mode** — input is neither a URL-ish string nor a known keyword; it reads like a question. Accent color shifts, hint changes to "↵ to ask", return triggers a fake "thinking…" shimmer then a canned stub answer.

The morph between navigation and ask mode is the headline craft moment. Make it animated and deliberate.

## State machine (single source of truth)

Model state explicitly. Do not scatter booleans across the view.

```swift
enum PaletteState: Equatable {
    case dismissed
    case presenting          // animating in
    case idle                // empty input, showing default suggestions
    case filtering(String)   // navigation mode
    case action(String)      // keyword-routed action mode
    case asking(String)      // LLM/ask mode
    case thinking(String)    // fake LLM in-flight
    case dismissing
}
```

Drive transitions from an `@Observable` view model. Input changes and gestures mutate state; the view renders from it. Routing logic (which mode a given string maps to) lives in the view model, not the view.

### Routing rules (keep simple, deterministic)

- Empty → `.idle`
- Starts with known keyword token (`yt `, `g `, `gh `) → `.action`
- Looks like a domain/bookmark match (contains `.`, or prefix-matches a hardcoded entry) → `.filtering`
- Otherwise, if it ends in `?` or has 3+ words → `.asking`
- Tune thresholds by feel; correctness matters less than the transition feeling intentional.

## The last-10% details (these are what get the callback)

- **Springs, not easing.** Use `.spring(response:dampingFraction:)` everywhere motion happens. Tune `response` and `dampingFraction` by hand until it feels right. No `.easeInOut`.
- **Rows slide, don't pop.** Stable `id`s on result rows + `.animation` so reordering animates positionally.
- **Drag-to-dismiss with velocity.** Dragging the bar down dismisses. A fast flick dismisses even at ~30% drag distance; a slow drag needs ~60%. Rubber-band resistance past the top edge.
- **Interruptibility.** Grabbing the bar mid-present must cancel cleanly and hand control to the finger — not queue or stutter. This is the senior signal; get it right.
- **Mode morph.** Navigation → ask transition animates accent color + hint text together, not as a hard swap.
- **Haptics.** `UIImpactFeedbackGenerator` on mode switch (light) and on execute (medium). Cheap, large perceived-polish payoff.
- **Keyboard tracking.** The bar tracks the keyboard frame so it sits just above it without jank.

## What to fake (do not build)

- Bookmarks/history: a hardcoded array of ~12 entries (title + fake URL + SF Symbol).
- Keyword actions: a small static map (`yt` → YouTube search, `g` → Google, `gh` → GitHub).
- Ask mode: on return, show a shimmer placeholder for ~1.2s, then a hardcoded stub answer string.
- "Opening" / "Searching": a transient toast or overlay. No real web view needed (a placeholder `Text` is fine).

## Build order (suggested)

1. Static layout: field + results list, no animation. Get the look right.
2. View model + `PaletteState` + routing logic. Wire input → state → rendered rows.
3. Present/dismiss animation with springs.
4. Drag-to-dismiss with velocity + rubber-banding + interruptibility.
5. Mode morph (color + hint) between navigation and ask.
6. Haptics + keyboard tracking.
7. Polish pass: tune every spring by feel. Timebox this — "good and shipped" beats "perfect and on your machine."
8. README + GIF.

## Anti-goals

- No real browser engine, web view content, or networking.
- No settings screen, onboarding, or multi-screen navigation.
- No third-party animation libraries — native SwiftUI only (the point is to show you can do it).
- Do not over-architect. This is a demo, not a framework.