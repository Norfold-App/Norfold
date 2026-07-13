# MASTER ORDER — read this before running ANY prompt in this repo

This governs **all three handoff folders**. Prompts were authored at different times and several touch the same files; run them **in the order below, one at a time**. Never run two prompts that share a file concurrently. Newer prompts intentionally **supersede** parts of older ones — where that happens it is called out explicitly so you don't build something just to delete it.

Folders:
- `tasks-board-calendar/` — foundation + task/board/calendar/sidebar (oldest).
- `notes-charts-popups/` — renderer, markdown, chart builder, diagram, note ToC, popup utility.
- `tasks-notes-overhaul/` — task-editor unification, swipe, live note editor, chart view, feed/gallery merge, rail redesign, calendar overlap+month, render cache, branding (newest).

---

## 0. Universal Definition-of-Done GATE (applies to EVERY prompt — non-negotiable)

A prompt is **not done** until all of these are true. Do not self-certify from reading code.

1. **It builds:** `./gradlew :apps:android:assembleDebug` compiles with no new errors/warnings you introduced. Paste the final build result line.
2. **It runs on the emulator:** launch the app and exercise the exact feature. For renderer/markdown/chart work, use `notes-charts-popups/RENDERER_ACCEPTANCE_TEST.md` as the fixture and verify section-by-section.
3. **Every checkbox in that prompt's "Definition of Done" is individually verified** and reported back with pass/fail — not a blanket "done."
4. **Proof of removal:** when a prompt says to delete/replace something (e.g. `CreateTaskDialog`), `grep` for the old symbol and confirm zero remaining references. Paste the grep result.
5. **Theme tokens only; Light AND Dark both checked** on device.
6. **No half-measures:** no stubs, no `TODO` left where the prompt asked for behavior, no "left as an exercise." If something is genuinely out of scope, say so explicitly in the report rather than silently skipping.
7. **Report format:** end each task with a short report: build line, DoD checklist with ✅/❌ per item, grep proofs, and anything deferred with the reason.

If you cannot satisfy a gate item, **stop and report** — do not mark the task complete.

---

## 1. Global run order (do them top-to-bottom, serially)

| # | Folder / file | Depends on | Owns (this prompt is the sole editor of) | Supersede note |
|---|---|---|---|---|
| 1 | `tasks-board-calendar/CODEX_PROMPT.md` | — | Block model, engine-island rendering, chart builder, tables/tags, nested sidebar, demo content | **Idempotency guard:** much of this may already exist. Do NOT rebuild working pieces from scratch — verify each against its DoD and only build/repair what's missing or broken. "Build on this" (its own words). |
| 2 | `tasks-board-calendar/CODEX_PROMPT_1_PROPERTIES_TABLE.md` | 1 | Value-driven columns, Add-property picker, AppFlowy table restyle | **Delta 2 (create-task popup) is SUPERSEDED by `tasks-notes-overhaul/01`.** If you are running the overhaul batch too, you MAY skip delta 2 (the popup gets deleted at step 14). Deltas 1, 3, 4 still stand. |
| 3 | `tasks-board-calendar/CODEX_PROMPT_2_BOARD_ACCENT.md` | 1 | Board "New column", per-column "+" removal, accent-inherit column colors | Standalone; no conflicts. |
| 4 | `tasks-board-calendar/CODEX_PROMPT_3_SIDEBAR.md` | 1 | LEFT nav drawer structure/order/wiring in `SidebarContent` | Shares `SidebarScreen.kt` with `notes-charts-popups/05`. CP3 owns the nav list; 05 owns the note-open ToC branch. CP3 runs first. |
| 5 | `tasks-board-calendar/CODEX_PROMPT_TASKPAGE.md` | 1 | `AdaptiveTaskPage` **visual/layout** match (styling of cards, headers, Notes-as-own-card) | **Keeps the signature unchanged. `tasks-notes-overhaul/01` will LATER add a create-mode param + new call sites — that is expected and allowed at step 14, not here.** Do the visual pass only. |
| 6 | `tasks-board-calendar/CODEX_PROMPT_4_CALENDAR.md` | 1 | Calendar unification, Day/Week smooth scroll, **adaptive Week time-grid** | Shares `PlanningScreens.kt` with `tasks-notes-overhaul/07`. CP4 owns Day/Week + the pager mechanism; 07 owns the overlap fix + Month. CP4 runs first; 07 reuses CP4's pager. |
| 7 | `notes-charts-popups/01-renderer-engine-fixes.md` | 1 | Engine-block fixes in `MarkdownWebView.kt` + `BlockNoteEditorScreen.kt` (pill clip, math typeset, mermaid, error fallbacks, state-bleed) | Shares `MarkdownWebView.kt` with 02 and `tasks-notes-overhaul/08`. 01 owns the render logic; 08 later wraps it with a cache. |
| 8 | `notes-charts-popups/02-markdown-full-coverage.md` | 7 | Full markdown feature coverage in `MarkdownWebView.kt` | Runs after 01 (same file). |
| 9 | `notes-charts-popups/03-chart-builder-fixes.md` | 1 | `ChartBuilderSheet.kt` + `ChartSpecCodec.kt` (scroll, preview, title/caption, per-item color) | `tasks-notes-overhaul/04` (Tasks chart view) reuses this engine/codec. 03 runs first. |
| 10 | `notes-charts-popups/04-diagram-builder.md` | 7 | `DiagramBuilderSheet.kt` (new) + Mermaid insert path | Standalone once 01 is in. |
| 11 | `notes-charts-popups/05-toc-outline-sidebar.md` | 4 | The **note-open ToC branch** of `SidebarScreen.kt` + heading anchors in `BlockNoteEditorScreen.kt` | Runs after CP3 (step 4) so the nav structure exists first. Do NOT restructure the nav list — that's CP3's. |
| 12 | `notes-charts-popups/06-popup-customization-utility.md` | — | `NorfoldDialog`/`NorfoldBottomSheet`/`NorfoldFullscreenDialog` + `LocalPopupStyle` + popup settings | `tasks-notes-overhaul/06` (rail) consumes these wrappers. 12 runs before step 19. |
| 13 | `tasks-notes-overhaul/08-render-cache-and-rerender.md` | 7, 8 | Render cache + re-render controls wrapping `MarkdownWebView.kt` | Wraps 01/02's render logic; must not replace their error handling. Needed by 16 and 17. |
| 14 | `tasks-notes-overhaul/01-task-editor-unification.md` | 2, 5 | `AdaptiveTaskPage` create-mode + routing; **deletes `CreateTaskDialog`** | Supersedes CP1 delta 2. This is where `AdaptiveTaskPage`'s signature may change. |
| 15 | `tasks-notes-overhaul/02-task-swipe-actions.md` | 14 | Task-row `SwipeToDismissBox` + `taskSwipe*` settings keys | After 14 (unified rows). |
| 16 | `tasks-notes-overhaul/03-task-note-live-editor.md` | 14, 13 | `LiveMarkdownField` + task Note field + `noteRenderEngine` setting + IME toolbar | Fills the Notes card TASKPAGE(5) styled; uses 13's cache. |
| 17 | `tasks-notes-overhaul/04-tasks-chart-view.md` | 13, 9 | New Tasks `Chart` view + adaptive header button (chart branch) | Reuses 03's chart engine + 13's cache. |
| 18 | `tasks-notes-overhaul/05-feed-gallery-merge.md` | 14 | Merged Feed/Gallery view + adaptive header button (list/grid branch) | Shares the `when(activeView)` header-button hook with 17 & 19 — keep that mapping in ONE place. |
| 19 | `tasks-notes-overhaul/06-right-rail-redesign.md` | 14, 12 | `TaskRailPanel` → list rows + popups | Uses 12's popup wrappers. |
| 20 | `tasks-notes-overhaul/07-calendar-overlap-and-month-scroll.md` | 6 | Calendar header overlap fix + Month pager | Reuses CP4's pager helper; don't re-touch Day/Week. |
| 21 | `tasks-notes-overhaul/09-branding-adaptive-icon.md` | — | Adaptive launcher icon + in-app logo from staged `brand/` glyph | Standalone; run anytime. |
| 22 | `notes-charts-popups/07-docs-editor-completion.md` | 1, 7, 8, (13) | Docs-editor UX layer: input correctness, floating toolbar, turn-into, per-block render toggle, block-bug fixes, **Notes→Docs rename** | The editor **completion/polish pass**. Does NOT re-implement `MarkdownWebView.kt` render logic or `02`'s markdown coverage — it wires them into the native editing surface. Can run any time after step 8; after step 13 if you want the render toggle to share the cache. |

---

## 2. Shared-file ownership (the anti-collision map)

Two prompts may edit the same file ONLY if separated in the order above. Within a shared file, each prompt owns a region; **do not edit another prompt's region.**

- **`TasksBoardScreen.kt`** — touched by CP1, CP2, TASKPAGE, and overhaul 01/02/03/04/05/06. This is the hottest file. Run these strictly serially (never parallel). Ownership:
  - CP1 → table (`TaskDatabaseTable`) columns/picker/restyle.
  - CP2 → board (`AdaptiveTaskBoard`/`TaskKanbanColumn`) column + colors.
  - TASKPAGE → `AdaptiveTaskPage` visuals.
  - overhaul/01 → `AdaptiveTaskPage` create-mode + new-task routing; removes `CreateTaskDialog`.
  - overhaul/02 → list-row swipe wrappers.
  - overhaul/03 → Note field inside the task editor.
  - overhaul/04 → new `TaskChartView` + `TaskHeader` trailing-button (chart branch).
  - overhaul/05 → merged Feed/Gallery + `TaskHeader` trailing-button (list/grid branch).
  - overhaul/06 → `TaskRailPanel`.
  - **The `TaskHeader` trailing button `when(activeView)` mapping is shared by 04/05/06 — the FIRST of them to run creates it; the others extend the same `when`, they do not fork it.**
- **`MarkdownWebView.kt`** — np/01 (render fixes) → np/02 (coverage) → overhaul/08 (cache wrapper). Serial. 08 wraps, never rewrites, 01/02's per-renderer try/catch.
- **`PlanningScreens.kt`** (calendar) — CP4 (Day/Week + pager) → overhaul/07 (overlap fix + Month). 07 reuses CP4's pager helper.
- **`SidebarScreen.kt`** — CP3 (left nav structure) → np/05 (note-open ToC branch). Different regions; CP3 first.
- **`BlockNoteEditorScreen.kt`** — np/01, np/02, np/04, np/05, and np/07 all touch it; serial per order. Each owns its feature (engine fixes / coverage / diagram insert / heading anchors / editor-UX + input-correctness + toolbar). np/07 is the completion pass and runs last of these — it wires in the others' render path, it does not rewrite it.
- **`NorfoldAppRoot.kt`** — overhaul/07 (sidebar-button inset). If any other prompt touches it, that prompt runs first.
- **Popup wrappers (`NorfoldDialog`/`NorfoldBottomSheet`)** — created by np/06; consumed by overhaul/06 and CP1/TASKPAGE popups may later adopt them (optional `// TODO: adopt NorfoldBottomSheet`).

---

## 3. Direct contradictions & their resolution (so nothing is built-then-deleted blindly)

1. **Create-task popup:** CP1 delta 2 builds `CreateTaskDialog`; overhaul/01 deletes it and routes new-task through `AdaptiveTaskPage`. **Resolution:** if running both batches, skip CP1 delta 2. If CP1 already ran, overhaul/01 removes the dialog (grep-verify zero refs).
2. **`AdaptiveTaskPage` signature:** TASKPAGE says keep it unchanged; overhaul/01 adds a create-mode param + call sites. **Resolution:** TASKPAGE (step 5) is visual-only and keeps the signature; overhaul/01 (step 14) is the sanctioned place to change it. Order guarantees no clash.
3. **Notes rendering in the task editor:** TASKPAGE(5) makes Notes its own styled card; overhaul/03 puts the live `LiveMarkdownField` inside that card. **Resolution:** styling first (5), behavior later (16). Same card, sequential.
4. **Calendar file:** CP4 vs overhaul/07 — resolved by ownership split in §2.
5. **Left sidebar:** CP3 vs np/05 — resolved by region split in §2.
6. **Renderer file:** np/01+02 vs overhaul/08 — 08 wraps, doesn't rewrite.

---

## 4. Concurrency rule

If you (or multiple Codex runs) work in parallel, you may only run prompts **that share no file** at the same time. Safe parallel groups (given prerequisites met): {CP2}, {np/04}, {overhaul/09} are largely independent. Everything touching `TasksBoardScreen.kt`, `MarkdownWebView.kt`, `PlanningScreens.kt`, `SidebarScreen.kt`, or `BlockNoteEditorScreen.kt` must be serialized per §1.
