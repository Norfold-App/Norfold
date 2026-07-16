# Codex Task 01 — Fix the broken engine blocks (code / math / mermaid rendering)

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 7).** You own the engine **render logic** in `MarkdownWebView.kt`. `../tasks-notes-overhaul/08` (later) wraps it with a render cache — **keep your per-renderer try/catch intact** so 08 can build on it, don't merge them away. Runs before `02` (same file). Satisfy the universal Definition-of-Done GATE before declaring done.

## Role
Editing the Norfold Android app (Jetpack Compose + Material3, package `com.norfold.app`, module `apps/android`). Do this fully and exactly. **Test on the emulator** — do not declare done from reading code.

## House rules
- Theme tokens only, never hardcode hues. Light + Dark both correct.
- Reuse existing structures. No schema changes unless stated.
- Compile clean.

## Background — how rendering works (so you don't break the good parts)
The editor is **block-based** (`domain/BlockDocument.kt`). Most blocks render natively in Compose. Only four "engine" block types — **Code, Math, Chart, Mermaid** — render through a hidden WebView (`ui/components/MarkdownWebView.kt` → composable `MarkdownPreview`) running marked.js + MathJax (`tex-svg.js`) + mermaid.min.js + vega-embed from `src/main/assets/preview/`. The shared card that hosts all four is **`EditableEngineCard`** in `ui/screens/BlockNoteEditorScreen.kt` (~line 1017–1089).

**What currently works:** native Vega-Lite charts and scatter render correctly.
**What's broken (reproduce with `RENDERER_ACCEPTANCE_TEST.md` imported as a note):**
- **Every fenced code block renders as a narrow, vertically-centered "pill" with text clipped to 1–2 characters per line** — unreadable, with huge dead whitespace on both sides. This is the #1 bug.
- **All LaTeX math is shown as raw source** — `$$…$$`, `$…$`, `\(…\)`, `\[…\]`, matrices, cases, mhchem — nothing typesets (sections 12–13 of the fixture).
- **Mermaid diagrams render as empty pills** — no nodes, no error (section 11, 19).

## Likely root causes (verify, then fix properly)
1. **Stuck deferred-mount placeholder.** `DeferredEnginePreview` (~1126–1147) waits ~300ms and only mounts the WebView when the list isn't scrolling, showing a "Rendering…" placeholder otherwise. In a note with **many** engine blocks (the fixture has dozens), blocks appear to get stuck as that placeholder pill and never mount/resolve. Confirm whether the "pill" is this placeholder never resolving.
2. **WebView not sized to full width / content height** — the clipped-to-1-char symptom means the WebView (or its container) is collapsing to a tiny width. Ensure each engine WebView lays out at full card width and reports content height back (JS `document.body.scrollHeight` → Kotlin height) so the card grows to fit.
3. **One failing renderer aborts the JS chain.** MathJax typeset is triggered manually *after* mermaid/vega settle (`MarkdownWebView.kt` ~281–283) with `startup:{typeset:false}`. If mermaid throws on an unsupported diagram (e.g. `xychart-beta`, `quadrant-chart`, `gantt`) the promise chain can break so **MathJax never typesets and code never highlights**. Wrap **each** renderer (marked/highlight, mermaid, vega, MathJax) in its own try/catch so one failure can't abort the others.

## Deltas
1. **Fix the code-block pill/clipping.** Code fences must render full-width, wrapping or horizontally scrollable, readable, with the card growing to content height. No centered pill, no 1-char clipping.
2. **Fix math typesetting.** Block math (`MathBlock`, wrapped as `$$…$$` at BlockNoteEditorScreen ~657) must actually render via MathJax. Make the typeset call resilient (independent try/catch; typeset even if mermaid/vega failed). Verify matrices, cases, aligned, mhchem from fixture §13 render.
3. **Fix Mermaid rendering.** Supported diagram types must render. For diagram types this mermaid build does NOT support (xychart-beta, quadrant, gantt if unsupported), do NOT show a blank pill — fall back to delta 4.
4. **Add a graceful fallback for any engine block that fails/unsupported.** Instead of a blank box, show the **raw source in a readable code style** plus a small muted "Couldn't render (unsupported or error)" line. A user must never see an empty mystery box.
5. **Fix the state-bleed bug.** `EditableEngineCard`'s `hidden`/`fullScreen`/`landscape` are keyed on the **label string** (`remember(label)` / `rememberSaveable(label)` ~1028–1032), so two blocks with the same label ("Code", "Math") share state. **Key these on the block's stable id instead.**
6. **Fix the resize-handle overlap.** The `DragIndicator` resize handle (~1057) is overlaid at `BottomEnd` on top of the text field and can steal taps/cover the cursor. Give it a dedicated gutter/row so it doesn't overlap editable text.
7. **Guard the many-WebView cost.** If dozens of engine blocks tank scroll/memory, keep the deferred-mount idea but ensure blocks reliably resolve to their rendered state once mounted (they must not get stuck as placeholders). A pooled/single reusable WebView or an on-first-visible mount that never reverts is acceptable — pick the approach that makes the fixture render reliably.

## Definition of Done (test against `RENDERER_ACCEPTANCE_TEST.md`)
- [ ] Every fenced code block (§5) renders full-width and fully readable — no pill, no clipping.
- [ ] All display + inline math (§12–13) typesets, including matrices/cases/aligned/mhchem.
- [ ] Supported Mermaid diagrams (§11) render; unsupported ones show the raw-source fallback (delta 4), never a blank pill.
- [ ] No engine block ever shows an empty mystery box — unsupported/failed → raw source + muted note.
- [ ] Two same-labeled blocks no longer share fullscreen/hidden state.
- [ ] Resize handle no longer overlaps text.
- [ ] The fixture note scrolls smoothly with all its engine blocks; nothing stuck on "Rendering…".
- [ ] Builds clean; Light + Dark correct.
