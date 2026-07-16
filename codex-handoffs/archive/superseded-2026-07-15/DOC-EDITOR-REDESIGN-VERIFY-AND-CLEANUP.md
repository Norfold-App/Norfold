# Doc-editor redesign — on-device verification + handoff-doc cleanup

**Audience:** Codex. Run this top-to-bottom, one phase at a time. The universal
Definition-of-Done GATE in `MASTER_ORDER.md` applies to every item below — do not
self-certify from reading code; verify on an emulator/device, Light AND Dark.

**Context:** Claude implemented the full 3-phase document-editor redesign
(plan: header slim-down + sidebar-ToC, outline interactions, canvas selection/zoom,
paginated Page view + PDF export). All code is written and building green
(`testDebugUnitTest` + `assembleDebug`, JDK 21). What is NOT done: on-device
manual verification, and running the instrumented Room tests. Your job is to
verify — not re-implement. If something fails, fix the smallest thing that makes
it pass, or stop and report if the gap is large.

## Environment (from build-env)
```
export JAVA_HOME=/home/sheikh/.gradle/jdks/eclipse_adoptium-21-amd64-linux.2
export ANDROID_SDK_ROOT=/home/sheikh/android-sdk
export ANDROID_HOME=/home/sheikh/android-sdk
./gradlew :apps:android:testDebugUnitTest :apps:android:assembleDebug
```
JDK 25 breaks unit tests — always use the JDK 21 path above.

## Standing rules (absolute)
- **Never delete a file outright.** Anything replaced/retired moves to
  `codex-handoffs/archive/` first (this includes the .md cleanup in Phase C).
- **Never touch `TaskDragPlanner.kt`.**
- `apps/web/` is a static mock — out of scope.
- Commit at each phase boundary with clear messages.

---

## Phase A — Build baseline + automated tests
1. `git status`; if there is uncommitted work, checkpoint-commit it first.
2. Run the unit tests + assemble command above. Paste the result line.
3. Run the instrumented tests on an emulator:
   `./gradlew :apps:android:connectedDebugAndroidTest`
   (these include the Room persistence tests, e.g. `BlockDocumentRoomTest` —
   they were only compile-checked, never executed on device). Paste results.

## Phase B — Manual verification on a phone-sized emulator

Key implementation facts so you know what "correct" looks like:
- All doc mutations go through `BlockEditorSession` (undo/redo + 500ms debounced
  autosave). Persistence stores `"reflow"`/`"overlap"` — UI labels are
  "Page" / "Infinite page" and must never leak into storage.
- Paginated view is a session-local, read-only render path *within* Page mode
  (not a third mode, not persisted). The reflow list is the only editing surface.
- Main file: `apps/android/src/main/java/com/norfold/app/ui/screens/BlockNoteEditorScreen.kt`;
  domain: `DocPagination.kt`, `MarkdownExporter.printHtml`.

### B1. Header + sidebar ToC (Phase 1 of the plan)
- [ ] Open a doc (compact + expanded window): header shows only back/menu/title/
      edit/undo-redo + a top-right kebab (doc-settings menu). No old bottom-sheet Outline.
- [ ] Sidebar shows the doc's ToC while a doc is open; heading tap scrolls (Page
      mode) / pans to the block (Infinite page).
- [ ] Kebab menu reads "Page" / "Infinite page" and switching actually changes layout.
- [ ] Close and reopen an old note saved before the redesign: mode decodes correctly.

### B2. Sidebar-ToC outline interactions (Phase 2)
- [ ] Caret collapse/expand hides/shows child headings.
- [ ] Long-press a section → delete / duplicate / move: doc mutates, undo works,
      change persists after leaving and reopening the note.
- [ ] Drag a top-level section to reorder → its whole block range moves and the
      editor reflects it immediately.
- [ ] Heading filter/search narrows the list.

### B3. Infinite-page canvas: selection + gestures (Phase 3b)
- [ ] No six-dot move handle and no always-visible resize dot anywhere.
- [ ] In edit mode: tap a block → selects it (does NOT focus its content).
      Drag anywhere on the selected block → moves it, snap guides appear,
      position persists after app restart.
- [ ] Tap the selected block again → enters it for editing (keyboard/content focus).
- [ ] Resize handle (bottom-right dot) and layer menu (top-right Layers icon)
      appear ONLY on the selected/entered block. Layer menu items (bring to
      front/forward/backward/back) reorder correctly and the order persists.
- [ ] Pinch-zoom (should clamp 0.5×–2.5×, anchored at the pinch centroid) and
      two-finger pan work; block interactions still hit the right block while zoomed.

### B4. Paginated view + PDF export (Phase 3c)
- [ ] In Page mode, kebab → "Paginated view": doc renders as A4 page cards with
      "n / total" page numbers. Toggle only appears in Page mode.
- [ ] Blocks never split across pages; an oversized block (e.g. a huge code block)
      gets its own page and is clipped, not bleeding into the gap.
- [ ] Double-tap the paginated background → drops into edit mode showing the
      normal reflow list.
- [ ] Sidebar-ToC tap while paginated → exits the preview and lands on the right block.
- [ ] Kebab → "Export PDF": system print dialog opens; save as PDF; open the PDF —
      A4, sensible margins, headings not orphaned at page bottoms, code/quote
      blocks not split, title rendered and HTML-escaped.
- [ ] Export includes unsaved edits (type something, export immediately without
      waiting for autosave).
- [ ] All of the above in Light AND Dark theme.

Fix small failures directly (commit each fix separately); stop and report if a
failure implies a design problem.

## Phase C — Archive stale handoff .md files
1. Read `COMPLETION_STATUS.md` and skim each .md in `codex-handoffs/` root,
   `tasks-board-calendar/`, `notes-charts-popups/`, `tasks-notes-overhaul/`.
2. A file is archivable ONLY if everything it asks for is verifiably done
   (per COMPLETION_STATUS.md or your own grep/emulator check) AND it carries no
   still-relevant reference material. When unsure, leave it in place.
3. **Do NOT archive:** `MASTER_ORDER.md`, `COMPLETION_STATUS.md`,
   `PARALLEL-PROTOCOL.md`, this file, anything under `coordination/` or
   `archive/`, and `tasks-notes-overhaul/SETTINGS_BACKLOG.md` (that phase is
   still pending — it comes AFTER this overhaul).
4. Move (never delete) archivable files to
   `codex-handoffs/archive/<original-name>` (prefix with the source folder if
   names collide, e.g. `notes-charts-popups--05-toc-outline-sidebar.md`).
5. Update `COMPLETION_STATUS.md` with one line per archived file: what it was,
   why it's considered complete, where it moved.
6. Commit: `docs: archive completed handoff prompts`.

## Final report
- Build + unit test line, connectedAndroidTest result.
- B1–B4 checklists with ✅/❌ per item; any fixes made (commit hashes).
- List of archived .md files and list of files deliberately kept, with reasons.
- Anything deferred and why.
