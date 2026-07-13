# Job 01 — Unify task create/edit on the board-style editor

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 14).** Do NOT start until `../tasks-board-calendar/CODEX_PROMPT_1_PROPERTIES_TABLE.md` and `../tasks-board-calendar/CODEX_PROMPT_TASKPAGE.md` are merged. This is the sanctioned place to change `AdaptiveTaskPage`'s signature and to **DELETE `CreateTaskDialog`** — grep-verify zero remaining references as your proof. Satisfy the universal Definition-of-Done GATE before declaring done.

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Do it fully and exactly. No stubs.

## House rules
- Theme tokens only, never hardcode hues. Light + Dark both correct.
- Don't fork implementations — one editor path after this.

## The problem
There are **two** task-editing surfaces with different looks:
1. **`AdaptiveTaskPage`** (`ui/tasks/TasksBoardScreen.kt:2322`–~2456) — the rich board-style editor. Opened for *editing* an existing task from every view (`editingTask = it` set at the Board dispatch `:326`, rendered at `:434`). Full-black scrim overlay (`zIndex(20f)`); on phones fills the screen, on width > 720dp becomes a right-docked 540dp panel (`:2345-2352`); `.imePadding()`/`.navigationBarsPadding()` at `:2353`. Content is a `LazyColumn` of cards: back/star/**Save** header + inline-editable title (`:2364-2428`), `TaskColorPalette`, main-property cards (Status/Priority/Dates/Assignee), Notes, checklist, files, comments.
2. **`CreateTaskDialog`** (`TasksBoardScreen.kt:1189`–1311) — a compact `Dialog` (max 620×720dp) used by the **Table view** to *create* tasks. Fields: Title (`:1218`), Dates Start/End/Due (`:1227-1231`), Note (`:1233`), Checklist (`:1240`), Status chips (`:1248-1256`), Priority chips (`:1257-1265`), "Add property" (`:1266-1276`). Invoked from `TaskDatabaseTable`: state at `:1000`, "New task" button `:1134`, render `:1162`.

The user wants **the board-view editor look to be the default everywhere**, including new-task creation.

## Goal — one editor, board style, for both create and edit
1. Make `AdaptiveTaskPage` support a **create mode** (new, unsaved task) in addition to edit mode. Add a `mode: TaskEditorMode` (or a nullable `existingTask` → null means create) parameter:
   - Create mode starts from a blank/default task draft (respect any pre-seeded fields the caller passes — e.g. Table view creating into a specific board/status/date should pre-fill those, exactly like `CreateTaskDialog` did).
   - Header title reads "New task" in create mode, the task title inline field otherwise. **Save** persists via the existing create path (whatever `CreateTaskDialog`'s confirm called — trace it from `:1189`–1311 and reuse that ViewModel method); edit mode keeps its current save.
   - Back/dismiss in create mode discards the draft (confirm-on-dirty is a nice-to-have, not required).
2. **Route every "new task" entry point to `AdaptiveTaskPage` in create mode** and **delete `CreateTaskDialog`** and its now-dead state:
   - `TaskDatabaseTable` "New task" button (`:1134`) → open the editor in create mode instead of showing the dialog. Remove the dialog state at `:1000` and the render at `:1162`.
   - Any other "+ Add task" / new-task affordances (search the file for the create call) route the same way.
3. Preserve the adaptive presentation: phone = full-screen overlay, wide (>720dp) = right-docked 540dp panel. Create mode uses the same responsive rules.
4. Keep pre-seed parity: whatever context the Table/Board passed to `CreateTaskDialog` (target board, default status, default dates) must still pre-fill in create mode.

## Constraints
- Do NOT keep `CreateTaskDialog` around "just in case" — remove it. One editor.
- Don't regress edit mode, the Save flow, the color palette, checklist, files, comments.
- Theme tokens only; Light + Dark correct; IME + nav-bar padding preserved.

## Definition of Done
- [ ] `AdaptiveTaskPage` handles both create (blank/seeded draft) and edit.
- [ ] Every new-task entry point opens the board-style editor; `CreateTaskDialog` is deleted with no dangling references.
- [ ] Table-view context (board/status/dates) still pre-fills on create.
- [ ] Responsive full-screen vs 540dp panel behavior intact for both modes.
- [ ] Save/create persists through the existing ViewModel method; edit unaffected.
- [ ] Builds clean; Light + Dark correct.
