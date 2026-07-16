# Codex Task 2 of 4 — Board "New column" + remove per-column "+" + accent-default column colors

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Do it fully and exactly. No stubs, no TODOs.

## House rules
- Theme tokens only, never hardcode hues. Light + Dark both correct.
- Don't touch nav graph or unrelated screens.
- Reuse existing ViewModel/repo methods (listed). No invented persistence.

## Files
- `apps/android/.../ui/tasks/TasksBoardScreen.kt` (board = `AdaptiveTaskBoard`/`TaskKanbanColumn`, lines ~600–812)
- `apps/android/.../data/NotesRepository.kt` (seed colors ~818–925; `createTaskColumn` ~831)

## Deltas

### 1. Make "+ New group" a working "+ New column"
At `TasksBoardScreen.kt:626–634` there is a trailing board card that reads **"+ New group"** and is **dead** (a `Surface`+`Text` with no click handler). Fix it:
- Rename the label to **"+ New column"**.
- Make the whole card `clickable` → open a small inline text field / dialog for the column name, then call **`viewModel.createTaskColumn(boardId, name)`** (already exists at NotesViewModel ~536). Get `boardId` from the columns list (`columns.firstOrNull()?.boardId`).
- Style it as a proper dashed/tonal "add" card consistent with the board, not black 20sp text.

### 2. Remove the per-column "+" add-task icon
In `TaskKanbanColumn` header (line ~730) there is:
`IconButton(onClick = { composerVisible = true }) { Icon(Icons.Outlined.Add, "Add task") }`
**Remove this IconButton.** The bottom **"Add task"** pill (lines ~797–808) already covers adding a task to the column, so the header "+" is redundant. Keep the overflow menu (`MoreVert`) and the count.

### 3. Accent-default column colors (Option B: follow accent until user overrides)
Currently columns are seeded with hardcoded hues — To do `0xFF9D7BFF` (purple), Doing `0xFF4FACFE` (blue), Done `0xFF56CC98` (green) — in `NotesRepository.kt` at `createTaskBoard` (~818), `ensureDefaultTaskColumns` (~896), `ensureTaskColumnForStatus` (~923), and default param of `createTaskColumn` (~831). The board draws these directly via `Color(column.color)` (e.g. `TasksBoardScreen.kt:726, 801, 804, 806`), so the board stays purple/blue/green regardless of the user's accent.

Desired: **a column with no user-chosen color follows the app accent; once the user picks a custom color it sticks.**
- Introduce a sentinel meaning "no custom color / inherit accent." Simplest: treat color value `0L` (or add a nullable, but `0L` avoids schema change) as "inherit."
- Change the seed calls so default columns are created with the **inherit sentinel** (`0L`), NOT the hardcoded hues.
- Keep `createTaskColumn`'s ability to accept an explicit color for when the user DOES choose one (column rename/color menu path).
- In the board UI, replace every `Color(column.color)` with a helper like:
  `val columnColor = if (column.color == 0L) MaterialTheme.colorScheme.primary else Color(column.color)`
  and use `columnColor` for the dot (line ~726) and the Add-task pill tint/border/text (lines ~801/804/806). Do the same anywhere else `Color(column.color)` is used for board/status rendering (e.g. compact grouped table dot ~1245, status dialog dots ~1349).
- If there is a column color-picker menu, ensure choosing a swatch writes a real color and choosing "default/reset" writes the `0L` sentinel.

## Constraints
- No DB migration (reuse the existing `color: Long`; `0L` = inherit).
- Existing user data: columns already seeded with the old hues keep them — that's acceptable (they were "chosen" defaults). Only NEW boards/columns use the inherit sentinel. (If trivial, you may also map the three legacy default hues to the sentinel, but do not risk overwriting genuine user colors.)
- Theme tokens only for the inherited path.

## Definition of Done
- [ ] Board trailing card reads "+ New column", is clickable, and actually creates a column via `createTaskColumn`.
- [ ] The per-column header "+" add-task icon is gone; bottom "Add task" pill still works.
- [ ] New boards/columns have no hardcoded hue; their color follows `colorScheme.primary` until the user picks one.
- [ ] User-picked column colors persist and override the accent.
- [ ] All former `Color(column.color)` board usages honor the inherit sentinel.
- [ ] Builds clean; Light + Dark correct.
