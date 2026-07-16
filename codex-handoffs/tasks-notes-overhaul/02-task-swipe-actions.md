# Job 02 — Swipe actions on task rows (configurable, mirroring notes)

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 15).** Do NOT start until Job 01 (unified task rows) is merged. Adds `taskSwipe*` settings keys (defaults now; settings UI deferred). Satisfy the universal Definition-of-Done GATE before declaring done.

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Do it fully and exactly. No stubs.

## House rules
- Theme tokens only. Light + Dark both correct.
- **Do not hardcode the actions** — read them from settings with defaults. See `SETTINGS_BACKLOG.md`.

## Context — the pattern to mirror
Notes already have configurable swipe actions:
- `SwipeToDismissBox` in `NoteCard`, `ui/screens/NotesHomeScreen.kt`: state `:227-236`, box `:237-260`.
- Direction → action mapped from `settings.noteSwipeStartAction` / `noteSwipeEndAction`.
- Settings UI at `SettingsScreen.kt:619-621`; VM support `NotesViewModel.kt:962`.

Tasks currently have **no** swipe-to-dismiss — `TasksBoardScreen.kt` only uses `detectHorizontalDragGestures` (`:21`) for Kanban drag-and-drop. **Do not break that drag-and-drop** (it's on the board card drag, a different gesture surface from list rows).

## Goal
Add configurable swipe actions to task **rows in list-style views** (Table view rows, Feed/Gallery list rows — wherever tasks render as a swipeable row, NOT the Kanban board columns where horizontal drag = move-between-columns).

1. Wrap task list rows in a `SwipeToDismissBox` styled like `NoteCard`'s (`NotesHomeScreen.kt:237-260`) — same reveal backgrounds, same threshold feel.
2. **Two directions, two actions**, read from new settings keys `taskSwipeStartAction` / `taskSwipeEndAction` (add them to the settings model + persistence with defaults; the settings-screen control comes in the later Settings pass — see `SETTINGS_BACKLOG.md`). Supported actions, at minimum:
   - **Delete** (default for end/left→right per note parity).
   - **Change status / "replace with"** — reveals a quick status picker (To do / Doing / Done) or cycles status; this is the user's "replace with". Default for start.
   - (Optional, if cheap) Complete-toggle, Duplicate — include if the note action enum already offers analogous options; otherwise Delete + status is enough.
3. Delete must be **undoable** (snackbar with Undo) if the note delete is — match note behavior exactly; reuse the same VM delete/restore methods for tasks if they exist, else the existing task delete + a re-insert.
4. Wire through the existing task ViewModel methods (delete, set-status). Do not add new persistence layers.

## Where NOT to add swipe
- Kanban board cards (horizontal drag already means move-between-columns). Leave those.
- The Calendar views.

## Constraints
- Actions come from settings, not constants.
- Don't regress Kanban drag-and-drop or row tap-to-open (tap still opens the unified editor from Job 01).
- Theme tokens only; Light + Dark correct.

## Definition of Done
- [ ] Task list rows swipe with `SwipeToDismissBox`, visuals matching `NoteCard`.
- [ ] Start/end actions read from `taskSwipeStartAction`/`taskSwipeEndAction` settings (defaults set; no hardcoded action).
- [ ] "Replace with" = status change/picker works; Delete works and is undoable if notes' is.
- [ ] Kanban drag-and-drop and row tap-to-open still work.
- [ ] Builds clean; Light + Dark correct.

## Reminder to the human
This job introduces `taskSwipeStartAction`/`taskSwipeEndAction`. The **settings-screen control for them is deliberately deferred** to the Settings pass (`SETTINGS_BACKLOG.md`).
