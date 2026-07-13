# Codex Handoffs — Tasks/Notes UI Overhaul (batch 3)

> **Read `../MASTER_ORDER.md` first.** It defines the cross-folder run order (these are steps 13–21), the shared-file ownership fences, the supersede rules, and the universal Definition-of-Done GATE every prompt must pass.

Precise, self-contained handoff prompts for the Norfold Android app (`com.norfold.app`, module `apps/android`). One file = one job. **Do the job fully and exactly — no stubs, no half-measures.** All paths in the prompts are relative to `apps/android/src/main/java/com/norfold/app/` unless stated otherwise.

## House rules (apply to every file here)
- **Theme tokens only** (`MaterialTheme.colorScheme.*`). Never hardcode hues. Light + Dark both correct.
- **Nothing hardcoded that the user called out as configurable** — see `SETTINGS_BACKLOG.md`. Where a behavior is destined for settings, read it from a settings value with a sensible default now; do not bake a constant.
- Reuse existing ViewModel methods and existing composables; don't fork parallel implementations.
- Builds clean before you call it done. See `../tasks-board-calendar/` and `../notes-charts-popups/` for prior batches and shared conventions.

## Collision status
As of **2026-07-13** the user confirmed Codex is **done** editing `AnimatedLogo.kt`, `BrandPalettes.kt`, `NorfoldTheme.kt`, `NorfoldAppRoot.kt`, and the block-editor set. These prompts may touch them freely.

## Jobs & suggested run order
Files that share source files are marked; run those serially to avoid merge pain.

| # | File | Touches | Notes |
|---|------|---------|-------|
| 01 | `01-task-editor-unification.md` | `TasksBoardScreen.kt` | Retire `CreateTaskDialog`; all create/edit → `AdaptiveTaskPage`. **Do first** — 02/05/06 build on the unified editor. |
| 02 | `02-task-swipe-actions.md` | `TasksBoardScreen.kt`, settings | Configurable swipe (mirror note swipe infra). After 01. |
| 03 | `03-task-note-live-editor.md` | `TasksBoardScreen.kt`, new editor component | Live md+LaTeX Note field, adaptive engine + settings toggle. After 01. |
| 04 | `04-tasks-chart-view.md` | `TasksBoardScreen.kt`, `TaskModels.kt`, chart engine | New Chart workspace view, shared chart engine, adaptive header button. |
| 05 | `05-feed-gallery-merge.md` | `TasksBoardScreen.kt`, `TaskModels.kt` | Merge Feed+Gallery, adaptive list/grid toggle, hide rail in list. |
| 06 | `06-right-rail-redesign.md` | `TasksBoardScreen.kt` | `TaskRailPanel` → list rows + popup editors. After 01 (reuses its popup style). |
| 07 | `07-calendar-overlap-and-month-scroll.md` | `PlanningScreens.kt`, `NorfoldAppRoot.kt` | Fix sidebar-button overlap; Month gets Week-style side-by-side scroll. Companion to `../tasks-board-calendar/CODEX_PROMPT_4_CALENDAR.md`. |
| 08 | `08-render-cache-and-rerender.md` | `MarkdownWebView.kt`, engine callers | Cache rendered output; auto re-render on edit; manual + "re-render all" buttons. Cross-cutting — feeds 03/04 and the `notes-charts-popups` batch. |
| 09 | `09-branding-adaptive-icon.md` | `res/`, `AnimatedLogo.kt` | Adopt staged brand glyph as adaptive launcher foreground + in-app logo. |

Note 04 and 08 are related (chart view wants the cache from 08). If splitting across Codex runs, do **08 before 04**.
