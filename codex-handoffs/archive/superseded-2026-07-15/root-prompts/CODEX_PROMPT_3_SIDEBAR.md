# Codex Task 3 of 4 — Sidebar reorganization

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Do it fully and exactly. No stubs.

## House rules
- Theme tokens only, never hardcode hues. Light + Dark both correct.
- Don't touch nav graph destinations themselves — only the sidebar's ordering/labels/wiring.
- Reuse existing ViewModel methods. No invented persistence.

## File
- `apps/android/.../ui/screens/SidebarScreen.kt` → **`SidebarContent`** (lines ~206–328). The live drawer uses the hardcoded items in this composable (NOT the legacy `sectionItems()`/`sectionTitle()` at ~332–405 — leave those alone or delete if unused).

## Target structure (top to bottom of the scrolling nav)
Replace the current nav block (`SideNavItem(...)` calls at lines ~253–310) with this order:

1. **Dashboard** → `viewModel.go(Destination.WorkspaceHub)` (selected when `destination == WorkspaceHub`)
2. **Today** → Day view of calendar. Keep existing wiring: `patchSettings { it.copy(calendarDefaultView = "Day") }` then `go(Destination.Calendar)`; selected when `destination == Calendar && settings.calendarDefaultView == "Day"`.
3. **Upcoming** → Agenda view: `calendarDefaultView = "Agenda"`, same pattern.
4. **Favorites** → keep current target (`go(Destination.NotesHome)` for now).
5. **Notes** (expand/collapse header — see below)
6. **Tasks** (expand/collapse header — see below)
7. **Files** → `go(Destination.Files)`
8. **Chat** → `go(Destination.Chat)`
9. **Inbox** → `go(Destination.Inbox)`
10. divider, then pinned **Archive / Trash / Settings** (keep as-is at ~307–310).

Remove the standalone "Workspace" section label (line ~264) — the new order doesn't need it. Keep the top logo, WorkspaceSwitcher, Search, and the New Note/New Task buttons unchanged (~215–246).

## Tasks dropdown (header at ~266–274, content ~275–285)
Keep the expand/collapse header ("Tasks", chevron flips `ExpandLess`/`UnfoldMore`). Inside, list **four** items (currently only three — add Agenda):
- **Board** → `patchSettings { it.copy(taskViewMode = "Board") }; go(Destination.Tasks)`
- **Table** → `patchSettings { it.copy(taskViewMode = "Table") }; go(Destination.Tasks)`
- **Calendar** → `go(Destination.Calendar)`
- **Agenda** → `patchSettings { it.copy(calendarDefaultView = "Agenda") }; go(Destination.Calendar)` (selected when `Calendar && calendarDefaultView == "Agenda"`)

## Notes dropdown (header ~286–294, content ~295–301) — recent 3 + expand/shrink toggle
Change the Notes section to show **recent notes**, not notebooks:
- The **control next to the "Notes" label toggles expand ⇄ shrink** (same chevron: `ExpandLess` when expanded, `UnfoldMore`/`ExpandMore` when collapsed) — this already exists via `notesExpanded`; keep it.
- When expanded and NOT "show all": render the **3 most-recent notes, title only**, sorted by `updatedAt` descending: `state.notes.sortedByDescending { it.updatedAt }.take(3)`. Each row: `SideNavItem(note.title.ifBlank { "Untitled" }, Icons.Outlined.Description, selected = false) { viewModel.openNote?.. }` — use whatever existing open-note call the sidebar already uses (e.g. select + `go(Destination.NoteEditor)`); if none exists in the sidebar, fall back to `go(Destination.NotesHome)`.
- If there are more than 3 notes, show a subtle **"…" more row** beneath them. Tapping "…" flips to **show-all** (list every note). When showing all, show a **"Show less" row at the END** of the list that returns to the 3-note view.
- Keep a top-level **"All notes"** entry (first row inside the dropdown) → `go(Destination.NotesHome)`.
- Add a local state e.g. `var notesShowAll by remember { mutableStateOf(false) }`.

`state.notes` is available (used already at SidebarScreen.kt:166 as `state.notes.size`). `Note` has `title: String` and `updatedAt: Long`.

## Constraints
- Only ordering/labels/wiring in `SidebarContent`. No new destinations.
- Reuse `SideNavItem` for consistent styling. Theme tokens only.
- Don't break the selected-state highlighting logic.

## Definition of Done
- [ ] Nav order is exactly: Dashboard, Today, Upcoming, Favorites, Notes, Tasks, Files, Chat, Inbox, (divider) Archive, Trash, Settings.
- [ ] Today→Day, Upcoming→Agenda, both with correct selected states.
- [ ] Tasks dropdown lists Board, Table, Calendar, Agenda (four).
- [ ] Notes dropdown shows recent 3 note titles; ">3" shows a "…" that expands to all, with a "Show less" at the end; chevron next to "Notes" still toggles the whole section.
- [ ] Builds clean; Light + Dark correct.
