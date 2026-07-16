# Job 05 — Merge Feed + Gallery into one view (adaptive list/grid toggle)

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 18).** Do NOT start until Job 01 is merged. Shares the `TaskHeader` `when(activeView)` trailing-button hook with Jobs 04 and 06 — **extend the same `when`, don't fork it.** Satisfy the universal Definition-of-Done GATE before declaring done.

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Do it fully and exactly. No stubs.

## House rules
- Theme tokens only. Light + Dark both correct.

## Context
- Two separate Task workspace views exist: `TaskFeedView` (`ui/tasks/TasksBoardScreen.kt:2063`) and `TaskGalleryView` (`:2138`), both in the `TaskWorkspaceView` enum (`ui/tasks/TaskModels.kt:3-19`), selected via the tab `LazyRow` in `TaskHeader` (`:506-522`).
- The `TaskHeader` trailing button (`Icons.Outlined.Tune`, `:497-500`) toggles the right rail (`TaskRailPanel`). Job 04 makes this button **adaptive per view** — this job uses that same hook.
- The right rail is `TaskRailPanel` (`:2160-2270`), a `TopEnd` overlay.

The user wants Feed and Gallery to **become one view**, with the right-side header button toggling **list ⇄ grid**. **List view stays as-is** (the current Feed list). In **list mode the right sidebar/rail is not needed — hide it** when in that mode.

## Goal
### 1. One merged view
- Replace `Feed` + `Gallery` in the enum/tabs with a single view (call it `Feed`, keep the friendlier label — the user calls the list "Feed" and the grid "Gallery"; one tab now). Remove the second tab.
- The merged view holds a **display mode**: `List` (current `TaskFeedView` presentation, unchanged) or `Grid` (current `TaskGalleryView` presentation). Reuse both existing composables as the two render branches — don't rewrite them.
- Default display mode: **Grid** is fine, but persist the user's last choice (a lightweight remembered/state value; no settings-screen control needed).

### 2. Adaptive header button toggles list/grid
- Using Job 04's adaptive-trailing-button hook (`when(activeView)`), in the merged view the trailing button becomes a **list/grid toggle**: icon shows the *other* mode (grid icon when in list, list icon when in grid), tap flips the mode. Animate the swap.

### 3. Hide the right rail in list mode
- When the merged view is in **List** mode, **hide the right rail** entirely (don't render `TaskRailPanel`, and the trailing button is the list/grid toggle, not a rail toggle). In **Grid** mode, keep whatever rail behavior other views have (or also use the toggle — but at minimum: list mode = no rail).
- Make sure hiding the rail doesn't strand any rail-only actions the user needs in that view; if Filter/Sort matter in grid, keep them reachable there.

## Constraints
- Don't rewrite the Feed/Gallery item layouts — reuse them as List/Grid branches.
- Coordinate with Job 04 (shared adaptive-button hook) and Job 06 (rail redesign) so the trailing-button `when(activeView)` mapping stays coherent across all three.
- Theme tokens only; Light + Dark correct.

## Definition of Done
- [ ] Feed and Gallery are one tab with a List/Grid display mode; both presentations reused intact.
- [ ] The adaptive header button toggles list⇄grid in this view (animated), consistent with Job 04's hook.
- [ ] In List mode the right rail is hidden; no orphaned essential actions.
- [ ] Last display mode is remembered; builds clean; Light + Dark correct.
