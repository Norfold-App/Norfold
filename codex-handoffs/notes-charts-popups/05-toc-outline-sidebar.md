# Codex Task 05 — Wire the note-open sidebar button to a live Table of Contents (outline)

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 11).** Runs AFTER `../tasks-board-calendar/CODEX_PROMPT_3_SIDEBAR.md` (which owns the LEFT nav structure). You own ONLY the **note-open ToC branch** of `SidebarScreen.kt` + heading anchors in `BlockNoteEditorScreen.kt` — do NOT restructure the nav list. Satisfy the universal Definition-of-Done GATE before declaring done.

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Do this fully. Test on the emulator.

## House rules
- Theme tokens only; Light + Dark correct.
- Reuse the block model + editor scroll state. No schema changes.
- Compile clean.

## Goal
When a note is open, the sidebar (context panel) should show a **Table of Contents / outline** built from the note's headings, and **tapping a heading scrolls the editor to it**. This is a big usability win for long notes. There is currently **no ToC wiring** in the codebase.

## Files
- `ui/screens/SidebarScreen.kt` — the sidebar/drawer. When the active destination is the note editor (`Destination.NoteEditor`), render the ToC here (there's a legacy per-destination `sectionItems()` mechanism, but the live drawer uses `SidebarContent`; add a ToC section shown only when a note is open).
- `ui/screens/BlockNoteEditorScreen.kt` — the editor. Headings are `HeadingBlock` (`domain/BlockDocument.kt` ~26, has `level` 1–6 + inline text). The editor renders blocks in a scrollable list — you'll need its `LazyListState` (or an equivalent scroll target per block) to scroll to a heading.

## What to build
1. **Generate the outline** from the open note's `BlockDocument`: walk the blocks, collect every `HeadingBlock` as `(blockId, level, plainText)`. Plain text = flatten the heading's inline nodes to a string.
2. **Render the ToC in the sidebar** when a note is open:
   - A titled "Contents" / "Outline" section.
   - One row per heading, **indented by `level`** (H1 flush, H2 indented once, etc.), title truncated to one line.
   - Highlight the heading currently in view (optional but nice) as the user scrolls.
   - Empty state: if the note has no headings, show a subtle "No headings yet" (or hide the section).
3. **Tap → scroll**: tapping a ToC row scrolls the editor to that heading's block. Use the editor's `LazyListState.animateScrollToItem(index)` for the heading's block index (thread the state or a scroll callback from the editor to where the sidebar can call it — e.g. via the ViewModel or a shared scroll-request state). Close the drawer after tapping on compact screens.
4. **Live updates**: the ToC reflects heading edits (add/remove/rename a heading → ToC updates). Since it derives from the block list, recomposition should handle this — just make sure the outline is computed from current state, not a stale snapshot.
5. **The "sidebar button shown when a note is open"**: ensure the affordance that surfaces this (the button the user referred to) actually opens/shows this ToC. If that button exists but is unwired, wire it here; if it doesn't exist, add a clear ToC entry in the note-open sidebar.

## Constraints
- Only wire ToC/outline behavior — don't restructure the sidebar's other sections.
- Scrolling must target the correct block even as blocks are added/removed (compute index from current blocks at tap time).
- Theme tokens only.

## Definition of Done
- [ ] Opening a note shows a Contents/Outline section in the sidebar listing its headings, indented by level.
- [ ] Tapping a heading scrolls the editor to that heading (animated), and closes the drawer on compact screens.
- [ ] The outline updates live as headings are added/edited/removed.
- [ ] Notes with no headings show a graceful empty state (or the section hides).
- [ ] Builds clean; Light + Dark correct.
