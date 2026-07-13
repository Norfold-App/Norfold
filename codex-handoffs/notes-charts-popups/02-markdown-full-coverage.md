# Codex Task 02 — Full markdown/LaTeX coverage (render the entire acceptance fixture)

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 8).** Runs AFTER `01` (same `MarkdownWebView.kt`). `../tasks-notes-overhaul/08` (later) wraps this render path with a cache — keep the render logic self-contained. Satisfy the universal Definition-of-Done GATE before declaring done.

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Do this fully. **Test on the emulator** against `RENDERER_ACCEPTANCE_TEST.md` (in this folder) — every section must render correctly.

> Do **Task 01 first** (it fixes the code/math/mermaid engine). This task is the coverage/polish layer on top.

## House rules
- Theme tokens only; Light + Dark correct.
- Reuse the existing pipelines. No schema changes.
- Compile clean.

## Context — two render paths (important)
1. **Native inline** for normal paragraphs/headings/lists: text is stored as `List<InlineNode>` and rendered by `inlineAnnotated(...)` in `BlockNoteEditorScreen.kt` (~1658–1674). Here **inline links are NOT tappable** and **inline `$math$` is only styled serif, not typeset** (~1667).
2. **WebView markdown** (`MarkdownWebView.kt` `buildHtml` ~105–288) via marked.js — used by the engine blocks. It already handles footnotes (~174–195), emoji shortcodes (~196–212), GFM tables, blockquotes, links.

The goal: the app renders **everything** in the fixture. Where a feature is missing, add it in whichever path is correct.

## Import the fixture as a note
The `MarkdownBlockCodec` (`domain/MarkdownBlockCodec.kt`, org.intellij.markdown GFM) imports markdown → blocks. Ensure importing `RENDERER_ACCEPTANCE_TEST.md` produces the right block types (headings→HeadingBlock, fences→CodeBlock/MermaidBlock/ChartBlock, `$$`→MathBlock, tables→TableBlock, etc.). Fix import mapping gaps as you find them.

## Coverage checklist — fix each failing case (section numbers refer to the fixture)
Currently BROKEN or missing (from a full-document review):
- **§1 Emphasis extras:** `==highlight==`, `H~2~O` subscript, `E=mc^2^` superscript, hard-break via trailing backslash, escaped chars should drop the backslash (`\$5` must show `$5`, `\*` shows `*`).
- **§2 Definition lists** (`Term` / `: definition`) — currently unsupported.
- **§3 Links/Footnotes:** inline links must be **tappable** in native paragraphs; **bare autolinks** (`https://…` with no brackets, §18) must linkify; reference-style links; footnotes must work in normal notes (not only the WebView path).
- **§8 Raw HTML:** decide and implement a consistent policy. Minimum: render common inline HTML — `<u>`, `<kbd>`, `<strong>`, `<sub>`, `<sup>`, `<img width height>`, `<details>/<summary>` — and decode HTML entities (`&mdash; &copy; &nbsp;`). Do not show raw tags literally in a way that looks broken.
- **§9 Admonitions/Callouts:** `> [!NOTE]`, `> [!WARNING]`, `> [!TIP]` must render as styled callout boxes (icon + tinted border), NOT literal `>` text. Note: there's already a native `CalloutBlock` type — map these to it on import, or style them in the WebView.
- **§12 Inline math** inside paragraphs must actually typeset (not serif-only). Route inline `$…$` / `\(…\)` through a math renderer.
- **§16 Abbreviations** (`*[HTML]: …`) — render as `<abbr>` with the expansion (tooltip/underline), not a literal blue link.
- **§17 `[TOC]` marker** — generate an inline table of contents from the document headings (this complements Task 05's sidebar ToC; here it's the in-body `[TOC]` marker).
- **§18 edge cases:** tilde code fences `~~~`, loose/multi-paragraph list items, lazy blockquote continuation, inline footnotes `^[…]`, image sizing (`=100x50` and `<img width height>`), Obsidian wikilinks `[[Page]]` / `[[Page|Alias]]`, `%% comment %%` hidden, nested emphasis, escaped pipe in table cells.
- **§6 Tables:** wide tables must **scroll horizontally** instead of bleeding off the right edge. Fix in both the WebView CSS and the native `NativeTable` (`BlockNoteEditorScreen.kt` ~1150).
- **§18 syntax highlighting consistency:** literal HTML shouldn't get random link-colored fragments (e.g. `#ccc`).

## Reasonable scope note
Some fixture items are legitimately out-of-scope to fully execute (Graphviz DOT, PlantUML, Desmos, TikZ, matplotlib/ggplot code *execution*). For those, the **Task 01 raw-source fallback** is the correct behavior — show the code readably with a muted "preview not supported" note. Do NOT leave them as blank boxes. Everything else in the checklist above must render properly.

## Definition of Done
- [ ] Importing `RENDERER_ACCEPTANCE_TEST.md` yields correct block types.
- [ ] Every checklist item above renders correctly (verify section by section on the emulator).
- [ ] Inline links are tappable; inline math typesets; escaped chars strip their backslash.
- [ ] Callouts, abbreviations, definition lists, wikilinks, `[TOC]`, highlight/sub/sup all render.
- [ ] Wide tables scroll horizontally in both native and WebView tables.
- [ ] Unsupported render-engines (DOT/PlantUML/Desmos/TikZ/exec code) fall back to readable raw source, never blank.
- [ ] Builds clean; Light + Dark correct.
