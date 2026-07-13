# Job 04 — New Tasks "Chart" view (shared engine, adaptive header button)

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 17).** Do NOT start until `08-render-cache-and-rerender.md` and `../notes-charts-popups/03-chart-builder-fixes.md` are merged — this reuses **both** (the render cache and the `ChartSpecCodec`/engine). Extend the shared `TaskHeader` `when(activeView)` button hook, don't fork it. Satisfy the universal Definition-of-Done GATE before declaring done.

> Depends on **Job 08** (render cache) — do 08 first if runs are separate.

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Do it fully and exactly. No stubs.

## House rules
- Theme tokens only. Light + Dark both correct.
- Reuse the **existing chart engine** — do not build a second charting stack.

## Context
- Task workspace views live in the `TaskWorkspaceView` enum (`ui/tasks/TaskModels.kt:3-19`) and are selected by the tab `LazyRow` in `TaskHeader` (`ui/tasks/TasksBoardScreen.kt:506-522`). Existing views include Board, Table, Feed, Gallery, Calendar.
- The chart rendering engine already exists for notes: Vega-Lite specs rendered via `MarkdownPreview`/vega-embed, authored by `ChartBuilderSheet` (`ui/components/ChartBuilderSheet.kt`), round-tripped by `ChartSpecCodec` (`domain/ChartSpecCodec.kt`). The `notes-charts-popups/03-chart-builder-fixes.md` job fixes that builder.
- The `TaskHeader` search bar's right-side button is an `IconButton` with `Icons.Outlined.Tune` (`TasksBoardScreen.kt:497-500`) that toggles the right rail. The user wants this **right-side button to be adaptive per view** — in the Chart view it should offer **chart-type switching (bar, histogram, pie, and every other logical type)**.

## Goal
### 1. Add a `Chart` workspace view
- Add `Chart` to `TaskWorkspaceView` (`TaskModels.kt`) and to the tab row (`TaskHeader` `:506-522`) beside Board/Table/Feed(→Gallery merge, Job 05)/Calendar.
- Render it as a new `TaskChartView` composable in `TasksBoardScreen.kt`.

### 2. Chart the task data — flexible group-by ANY property
- The user chose **flexible group-by any property**. The chart view lets the user pick:
  - **Group-by field** — any task property: Status, Priority, Tag, Assignee, Due date (bucketed), or any custom property.
  - **Measure** — count of tasks (default) or sum of a numeric property.
  - **Chart type** — bar, stacked bar, histogram, pie/donut, line (over time when grouped by date), and any other logical type the engine supports. Guard nonsensical combos (e.g. pie needs a categorical group-by) with a friendly hint rather than a crash.
- Build the Vega-Lite spec from the current board's tasks using the **same engine/codec** as the note chart builder (`ChartSpecCodec` + `MarkdownPreview`/vega). Reuse; do not reimplement charting.
- Respect the current filters/board scope (chart what's visible).

### 3. Adaptive right-side header button
- Make the `TaskHeader` trailing `IconButton` (`:497-500`) **adaptive to the active view**:
  - In most views: current behavior (toggle the right rail / `Tune`).
  - In **Chart view**: it becomes the **chart-type / config** control — icon reflects chart type (e.g. bar-chart icon), tap opens a chart-type + group-by picker (a menu or the `NorfoldBottomSheet` from the popup utility). Switching type/group-by live-updates the chart.
- Keep the mechanism general (a small `when(activeView)` mapping the trailing button's icon + action) so other views can later customize it too (Job 05 uses the same hook for list/grid).

### 4. Caching + re-render
- Use **Job 08's render cache** so switching back to a previously-rendered chart is instant. Re-render automatically when group-by/type/data changes. Surface the "re-render" affordance (Job 08) here too.

## Constraints
- Reuse the existing chart engine + codec; theme tokens only; Light + Dark correct.
- No crash on empty data or degenerate group-by — show an empty state.

## Definition of Done
- [ ] `Chart` is a selectable Tasks workspace view rendering a chart of the current tasks.
- [ ] User can group by any property, choose measure, and switch chart type (bar/histogram/pie/…); invalid combos are guarded gracefully.
- [ ] Charts render through the existing Vega engine/codec (no parallel stack).
- [ ] The header trailing button is adaptive: chart-type control in Chart view, rail toggle elsewhere.
- [ ] Uses Job 08 cache; empty state handled; builds clean; Light + Dark correct.
