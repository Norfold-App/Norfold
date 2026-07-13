# Codex — Notes/Charts/Popups handoff set

> **Read `../MASTER_ORDER.md` first.** It defines the cross-folder run order (these are steps 7–12), the shared-file ownership fences (`MarkdownWebView.kt`, `SidebarScreen.kt`, chart engine), the supersede rules, and the universal Definition-of-Done GATE every prompt must pass.

Each file below is a **self-contained Codex task**. Do them **one at a time, in order**. Several touch the same big files, so running them concurrently will collide.

`RENDERER_ACCEPTANCE_TEST.md` in this folder is the **acceptance fixture** — the note that must render 100% correctly. Import it as a note and check it section-by-section.

## Order (do NOT parallelize 01→02→04 — all edit the same renderer files)

| # | File | Scope | Main files |
|---|---|---|---|
| 01 | `01-renderer-engine-fixes.md` | Fix the broken engine blocks: code-block "pill" clipping, math not typesetting, Mermaid empty, missing error fallbacks, state-bleed bug | `BlockNoteEditorScreen.kt`, `MarkdownWebView.kt` |
| 02 | `02-markdown-full-coverage.md` | Make the renderer handle **everything** in the acceptance fixture (callouts, TOC, abbr, footnotes, wikilinks, raw HTML, table overflow, inline math/links, etc.) | `MarkdownWebView.kt`, `BlockNoteEditorScreen.kt`, `MarkdownBlockCodec.kt` |
| 03 | `03-chart-builder-fixes.md` | Fix `ChartBuilderSheet`: scroll (V+H), real preview, Title+Caption (editor + rendered), **per-item color**, and TEST every type | `ChartBuilderSheet.kt`, `ChartSpecCodec.kt`, `BlockNoteEditorScreen.kt` |
| 04 | `04-diagram-builder.md` | Give diagrams (Mermaid) a friendly builder like charts | `BlockNoteEditorScreen.kt`, new `DiagramBuilderSheet.kt` |
| 05 | `05-toc-outline-sidebar.md` | Wire the note-open sidebar button to a live Table-of-Contents from headings; tap → scroll | `SidebarScreen.kt`, `BlockNoteEditorScreen.kt` |
| 06 | `06-popup-customization-utility.md` | Centralize all popups behind one wrapper + `LocalPopupStyle`, then build a Nova-style customization settings screen | ~20 files (see the file) |
| 07 | `07-docs-editor-completion.md` | Finish the Docs editor: input-correctness bugs (transposition, autoscroll, saving-jump), floating formatting bar, turn-into, per-block Render⇄Source toggle, resize-persist, rotate-loop, **Notes→Docs rename** | `BlockNoteEditorScreen.kt` (+ wires in `01`/`02`) |

## House rules (apply to every task)
- **Theme tokens only** (`MaterialTheme.colorScheme.*`); never hardcode hues. Light + Dark both correct.
- **Reuse existing ViewModel/repo/codec calls**; don't invent persistence unless the task says to add a field.
- Compile cleanly, no leftover unused imports.
- **Actually test on the emulator** against `RENDERER_ACCEPTANCE_TEST.md` where relevant — do not declare done from reading code.

## Related earlier handoffs (repo root, different job — task/board/calendar)
`CODEX_PROMPT_1_PROPERTIES_TABLE.md`, `CODEX_PROMPT_2_BOARD_ACCENT.md`, `CODEX_PROMPT_3_SIDEBAR.md`, `CODEX_PROMPT_4_CALENDAR.md`, `CODEX_PROMPT_TASKPAGE.md`, `CODEX_PROMPT.md`. (Move them in here if you want everything in one place.)
