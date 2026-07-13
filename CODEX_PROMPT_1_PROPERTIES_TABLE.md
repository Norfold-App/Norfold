# Codex Task 1 of 4 — Value-driven properties + Create-task popup + Add-property picker + AppFlowy table restyle

## Role
You are editing the Norfold Android app (Jetpack Compose + Material3, package `com.norfold.app`, module `apps/android`). Do this task **exactly**, end to end. Do not half-do it, do not stub, do not leave TODOs. Match the described behavior 100%.

## House rules (same as CODEX_PROMPT.md — do not violate)
- **Theme-driven color only.** Never hardcode hues. Use `MaterialTheme.colorScheme.*` tokens. Light + Dark must both look right.
- **Do not touch** navigation graph, database schema, or unrelated screens except where this task explicitly says to.
- **Reuse existing ViewModel calls** — do not invent new persistence. The methods you need already exist (listed below).
- Compile cleanly. No unused imports left behind.

## The core idea (read this twice)
Properties must be **value-driven**: a property renders in a view **only when a task actually has a value for it** (or the user has explicitly added it). Empty = invisible, in the table AND on cards. Nothing is forced on the user up front. This is the AppFlowy/Notion model.

## Files you will edit
- `apps/android/src/main/java/com/norfold/app/ui/tasks/TasksBoardScreen.kt` (table = `TaskDatabaseTable` at line ~918; column enum `TaskTableColumn` at line ~186)
- You MAY add new `private` composables in that same file for the popups. Prefer keeping everything in this one file.

## Existing hooks you MUST reuse (already implemented — do not rewrite)
- `viewModel.createTaskProperty(boardId: Long, name: String, type: TaskPropertyType)`
- `viewModel.deleteTaskProperty(property: TaskPropertyDefinition)`
- `viewModel.updateTaskPropertyDefinition(property, name, type, hiddenWhenEmpty, optionsJson)`
- `viewModel.setTaskPropertyValue(task, property, value)`
- `viewModel.addTaskToColumn(title: String, column: TaskColumnItem)`
- `TaskPropertyType` enum (domain/Models.kt): `Name, Status, Checklist, DueDate, Text, FilesMedia, Assignee, Labels, Priority, CreatedAt, LastModified, Numbers, Select, Multiselect, Date, Person, Url, …`
- `TaskPropertyDefinition` has `hiddenWhenEmpty: Boolean` and `type: TaskPropertyType` already.

## Deltas

### 1. Value-driven column visibility (the heart)
In `TaskDatabaseTable`, the header currently renders **all** `TaskTableColumn.entries` unconditionally (line ~954). Change it so a column is shown only if **at least one task has a value** for its backing property, OR the property is not `hiddenWhenEmpty`. Concretely:
- Compute, once per recomposition, the set of `TaskTableColumn` that are "in use": a column is in use if any task has a non-empty `TaskPropertyValue` for its `propertyFor(column)` (use the existing `propertyFor` helper at line ~1207 and `propertyValues`), OR any checklist/file exists for it, OR the property's `hiddenWhenEmpty == false`.
- **Always keep `TaskTableColumn.Name` visible** (the title column is mandatory).
- Render only in-use columns in both the sticky header and each data row. Width math (`tableWidth`) must sum only visible columns + the index column.
- Same rule applies to card rendering if cards show property chips — an empty property shows nothing.

### 2. Create-task popup
Right now "New task" just inserts a blank row (footer at line ~1014, and `addTaskToColumn`). Replace the bare insert with a **popup dialog** that opens when the user taps the New-task footer (and reuse it for the board/sidebar create path if trivial — but scope here is the table).
- The dialog is a centered floating card (`Dialog` / `AlertDialog`-style surface, rounded 16.dp, not full-screen), dismiss on tap-outside.
- It shows a **title text field** plus the **common property set**: Start, End, Due, Note, Checklist, **Status, Priority**. These are shown as light, fillable rows.
- Empty common fields still follow the value-driven rule elsewhere — but inside THIS create dialog they're offered so the user can fill them at creation.
- A **"+ Add property"** entry opens the Add-property picker (delta 3).
- Confirm → create the task via `addTaskToColumn`, then persist any filled values via `setTaskPropertyValue`. Cancel/tap-outside → nothing created.

### 3. Add-property picker (floating, multi-select) + confirm
A reusable `private @Composable` popup:
- Tapping the **`+` "Add property"** cell (table header, currently line ~957) OR the create-dialog's "+ Add property" opens a **floating card** — comfortable centered size, list inside is **scrollable**, **tap-outside closes**.
- The list = all addable `TaskPropertyType`s not already active. **Multi-select** (checkboxes / toggle rows) — the user can pick several at once.
- A "Continue" button opens a **second confirmation popup** listing the selected properties, each removable, with **Add** / **Cancel**. Add commits each via `viewModel.createTaskProperty(boardId, type.defaultLabel-or-name, type)`.
- boardId comes from `columns.firstOrNull()?.boardId ?: 1L` (same as the current add-property onClick).

### 4. AppFlowy table restyle (match the reference the user provided)
Restyle `TaskDatabaseTable` + `TaskTableHeaderCell` to the clean AppFlowy grid look:
- Header cells: small **type icon + label** in muted `onSurfaceVariant`, thin `outlineVariant` borders, no heavy fills.
- Trailing header cell = **`+ New property`** (icon + the literal text "New property"), light, not a bare icon — opens the picker from delta 3.
- Footer row = **`+ New page`**-style row (keep wording **"New task"**), full width, subtle, accent icon.
- Cells: generous padding, single thin separators, selected cell gets a subtle accent ring (not a fill).
- Keep the row-number index column.

## Constraints
- No schema/migration changes — `hiddenWhenEmpty` and all needed fields already exist.
- No new ViewModel methods — reuse the ones listed.
- Theme tokens only. Verify Light + Dark.

## Definition of Done (check every box)
- [ ] Empty properties do NOT appear as table columns; they appear only once a task has a value (Name always shown).
- [ ] Table width/layout recomputes from visible columns only (no ghost empty columns, no clipping).
- [ ] Tapping New-task opens a centered create popup with title + common set + "+ Add property"; confirm creates & persists, cancel creates nothing.
- [ ] "+ Add property" opens a scrollable, tap-outside-closing floating picker with multi-select, then a confirm popup (add/remove) before committing.
- [ ] Header shows "+ New property" (text, not bare icon); footer shows the "New task" add row; grid matches the AppFlowy light look.
- [ ] Builds clean; Light + Dark both correct; no hardcoded colors.
