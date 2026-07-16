# Job 06 — Redesign the right rail (Filter / Sort / New board) as list rows + popups

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 19).** Do NOT start until Job 01 (unified editor / property-card style) and `../notes-charts-popups/06-popup-customization-utility.md` (popup wrappers) are merged — reuse both. Coheres with the shared `TaskHeader` button hook (Jobs 04/05). Satisfy the universal Definition-of-Done GATE before declaring done.

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Do it fully and exactly. No stubs.

## House rules
- Theme tokens only. Light + Dark both correct.

## Context
The right rail is `TaskRailPanel` (`ui/tasks/TasksBoardScreen.kt:2160`–2270), a `TopEnd` overlay opened by the header `Tune` button (`:497-500`; call-site align `:392-432`). Today its actions are a **row of `TextButton` tabs** — Filter / Sort / New / Settings (`:2199-2205`) — with the body swapped by `when(tab)`:
- Filter tab = `FilterChips` (`:2209-2219`)
- Sort tab = `AssistChip`s (`:2220-2222`)
- New tab = "New board" `OutlinedTextField` + "Create board" `Button` (`:2223-2229`)

The user finds this cramped and wants it redesigned: **a vertical list — Filter, Sort, New board — styled like the board-view task editor** (the `AdaptiveTaskPage` property cards), where **tapping each row opens a popup to edit it**. The user explicitly asked me to "plan a better user-friendly way to represent them in the popup."

## Goal
### 1. Rail becomes a list of rows (board-editor styling)
- Replace the `TextButton` tab row + `when(tab)` body with a **vertical list of tappable rows**, each styled like the property cards in `AdaptiveTaskPage` (`:2364`+): an icon + label + a compact **summary of the current value** on the right (e.g. "Filter · 2 active", "Sort · Due ↑", "Boards · 3"). Same card look, radius, spacing, token colors.
- Rows: **Filter**, **Sort**, **New board / Boards**. (Keep a Settings row/entry if it was doing something real; otherwise drop it — confirm nothing depends on it.)

### 2. Tapping a row opens a popup editor
- Use the popup utility from `../notes-charts-popups/06-popup-customization-utility.md` (`NorfoldBottomSheet` / `NorfoldDialog`) so these match the app-wide popup styling. If that utility isn't merged yet, use a `ModalBottomSheet` styled to match and leave a `// TODO: adopt NorfoldBottomSheet` note.
- **Filter popup** — friendlier than raw chips: group filters by property (Status, Priority, Tag, Assignee, Date range) with labeled sections and multi-select chips/toggles; a clear "Reset filters" and an active-count. Applying updates the board live.
- **Sort popup** — a list of sortable fields (Due, Priority, Status, Created, Title, custom) with an **ascending/descending** toggle per choice; single active sort highlighted. Optional secondary sort is a bonus.
- **Boards popup** — list existing boards (rename/select/delete if those exist) **and** the "New board" name field + Create button (moved out of the cramped tab into a roomy sheet). Creating selects the new board.
- Each popup reuses the existing ViewModel filter/sort/board methods — don't add new persistence.

### 3. Keep it coherent with the adaptive header button
- The `Tune` header button still opens this rail in most views. Coordinate with Job 04/05: in Chart view the button is the chart control, in the merged Feed list mode the rail is hidden. Keep the `when(activeView)` mapping in one place.

## Constraints
- Reuse existing filter/sort/board VM methods and the popup utility; theme tokens only; Light + Dark correct.
- Don't lose any current capability (every chip/sort/board action still reachable, just better organized).

## Definition of Done
- [ ] The rail is a vertical list of board-editor-styled rows (Filter / Sort / Boards) each showing a current-value summary.
- [ ] Tapping a row opens a well-organized popup (Filter grouped by property; Sort with asc/desc; Boards list + create) via the app popup utility.
- [ ] Applying in any popup updates the board live through existing VM methods; nothing regresses.
- [ ] Coheres with the adaptive header button across views; builds clean; Light + Dark correct.
