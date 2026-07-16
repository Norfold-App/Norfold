# Job 03 — Live markdown+LaTeX Note editor for tasks (adaptive engine)

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 16).** Do NOT start until Job 01 (unified editor) and Job 08 (render cache) are merged — this fills the Notes card that `../tasks-board-calendar/CODEX_PROMPT_TASKPAGE.md` styled, and uses Job 08's cache. Adds `noteRenderEngine` setting (default now; settings UI deferred). Satisfy the universal Definition-of-Done GATE before declaring done.

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Do it fully and exactly. No stubs.

## House rules
- Theme tokens only. Light + Dark both correct.
- **Do not hardcode the render engine.** Read the mode from settings (see below + `SETTINGS_BACKLOG.md`).

## Context — current state
The task **Note** field is plain text with no live render:
- Editor input: `TaskNotesSection` (`ui/tasks/TasksBoardScreen.kt:2922-2971`) → `FocusedTaskPropertyDialog` → `TextPropertyEditor` (`:3235-3272`): a plain multiline `OutlinedTextField` with markdown-*insert* chips (Checklist/Table/Divider/Link, `:3255-3260`) — it inserts markdown source, does **not** render as you type.
- A rendered **preview** exists only after save: `PropertyPreviewCard` (`:3210-3232`) renders `Text`-type markdown via the WebView `MarkdownPreview` (`ui/components/MarkdownWebView.kt:29`).
- There is **no** live editor and **no** keyboard-docked formatting toolbar anywhere (the block editor's `DocumentRangeToolbar` at `BlockNoteEditorScreen.kt:376` is a block-replace bar, not a formatting bar).

The user wants the task Note field to **render markdown + LaTeX in real time as you type**, be **easy to edit**, and have a **formatting bar that docks to the keyboard (IME) or floats near the bottom (slightly floaty) when a physical keyboard is used** — "kinda like the initial note editor (page view)" which no longer exists, so build it fresh and lightweight.

## Goal — a lightweight live Note editor
Build a reusable composable, e.g. `LiveMarkdownField` (new file `ui/components/LiveMarkdownField.kt`), and use it for the task Note field (replace the plain `TextPropertyEditor` text path for Note; keep the insert chips).

### 1. Real-time rendering, adaptive engine (DO NOT hardcode)
Add a settings value `noteRenderEngine: Auto | Native | WebView` (default `Auto`) — add the key to the settings model + persistence with a default; the settings-screen control is deferred (`SETTINGS_BACKLOG.md`). Selection logic:
- **Native** — a lightweight pure-Compose markdown renderer (fast, no WebView). LaTeX support is best-effort (see hybrid note below).
- **WebView** — reuse the existing `MarkdownPreview` engine (`MarkdownWebView.kt`) for full md + MathJax LaTeX fidelity.
- **Auto** — choose per **device hardware capability** (e.g. RAM / API level / whether the device handles a debounced WebView smoothly). Pick a concrete, documented heuristic — do not just always pick one. On low-capability devices fall back to Native; on capable devices use WebView (or the hybrid). Comment the heuristic clearly.
- Hybrid detail: in Native mode, if the text contains LaTeX (`$...$`, `$$...$$`), you may spin up the WebView **only** for the math spans; if that's too complex, Native mode may render math as raw source with a note — but Auto on a capable device must give full LaTeX.

Rendering must be **debounced** (e.g. ~150–250ms after typing stops) so keystrokes stay smooth. Coordinate caching with **Job 08** (`08-render-cache-and-rerender.md`) — reuse its cache so re-opening a note doesn't re-render from scratch.

### 2. Layout — edit + live render
- Provide an **inline live render** (render appears as you type) — pick the cleaner of: (a) a single field that renders in place, or (b) an edit area with a live preview directly beneath. Given "easy to edit" + "real time", prefer a compact editor with the rendered result shown live below/beside; a small toggle to focus edit-only is fine.
- Keep the existing markdown-insert chips (Checklist/Table/Divider/Link) available.

### 3. Formatting bar that tracks the keyboard
- A slim formatting toolbar (Bold, Italic, Heading, List, Checklist, Link, Code, Math — reasonable set) that:
  - **Docks directly above the software keyboard** using `WindowInsets.ime` (imePadding / ime-aware offset) so it sits flush on the keyboard.
  - When **no software keyboard is up** (physical keyboard / IME hidden), it **floats near the bottom**, slightly above the bottom edge (the "a bit floaty" ask) — not flush to the very bottom.
  - Animate the transition so it follows the keyboard show/hide smoothly.
- Toolbar actions wrap the current selection / insert at cursor in the live field.

## Constraints
- Engine is settings-driven (`noteRenderEngine`), never a hardcoded single renderer.
- Debounced; typing must stay smooth even in WebView mode.
- Theme tokens only; Light + Dark correct; correct IME + nav-bar insets.
- Reuse Job 08's render cache; don't build a second caching layer.

## Definition of Done
- [ ] `LiveMarkdownField` renders markdown + LaTeX live (debounced) and is used for the task Note field.
- [ ] Engine chosen from `noteRenderEngine` (Auto/Native/WebView); Auto uses a documented hardware heuristic; nothing hardcoded.
- [ ] Formatting bar docks to the IME when the keyboard is up and floats slightly above the bottom when it isn't; follows keyboard animation.
- [ ] Existing insert chips still work; typing stays smooth.
- [ ] Uses Job 08's cache; Light + Dark correct; builds clean.

## Reminder to the human
Introduces `noteRenderEngine` setting — its **settings-screen toggle is deferred** to the Settings pass (`SETTINGS_BACKLOG.md`).
