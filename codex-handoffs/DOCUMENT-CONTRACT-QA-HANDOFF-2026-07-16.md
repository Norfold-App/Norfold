# Structured-document contract QA handoff — 2026-07-16

## Scope and status

Android is authoritative. The implementation is source-complete for this contract pass and automated JVM/build gates pass. It is **not product-complete** until the installed-app, Light/Dark, adaptive, persistence, accessibility, and visible-defect checks below pass.

Implemented commits on `mission/document-contract`:

- `8d88e64` — versioned block payload envelope and unknown-block preservation
- `b5895e7` — exact structured-document backup round trips
- `08529ba` — generic owner persistence in Room schema 33
- `7b54ae4` — task Docs in the full structured editor
- `b40a654` — calendar-event Docs and calendar entry points
- `52ee825` — retired Markdown/WebView editor paths archived outside the APK

## Expected behaviors

1. Notes, tasks, and calendar events each own an independent structured document.
2. Identical block IDs under different owners never overwrite one another.
3. Task Docs opens from the task detail Docs section in the full editor.
4. Calendar-event Docs opens by tapping an event in Day, Week, or Agenda.
5. Editing a task/event document updates its title and derived plain-text description without converting the block tree to Markdown.
6. Reopening any owner preserves block IDs, order, typed payloads, layout, and canvas specification.
7. Deleting a task/event removes its owned document; deleting a workspace removes all owned documents in that workspace.
8. Backup/restore preserves note documents and non-note owner documents exactly.
9. Unknown block payloads survive load/save/backup unchanged and display a safe unsupported-block surface.
10. No Source/Render mode, WebView preview, render-cache action, or task live-Markdown editor is exposed.
11. Markdown import/export and PDF/DOCX boundaries continue to work.
12. View mode remains visually clean: edit bounds and handles appear only on hover, selection, or editing.

## Fault log

| Fault | Resolution | Verification state |
| --- | --- | --- |
| Notes owned block rows directly, preventing reuse by tasks/events | Added generic `documents` / `document_blocks` and owner types | Automated Room coverage; installed persistence pending |
| Block IDs could collide across owners | Composite `(document_id, block_id)` key | Automated collision test passes |
| Task description was a separate Markdown editor/source | Task description is now a projection of a task-owned `BlockDocument` | Automated Room coverage; IME/reopen pending |
| Calendar events had no document seam | Added event-owned documents and Day/Week/Agenda entry points | Compilation coverage; installed interaction pending |
| Backup omitted non-note structured documents | Backup V3 carries `ownedDocuments` exactly | Unit round-trip passes; installed encrypted restore pending |
| Unknown/new block kinds risked data loss | Versioned envelope plus exact `UnknownBlock.rawJson` preservation | Unit round-trip passes |
| WebView renderer and JS engines remained in the APK | Moved renderer, cache, live field, tests, and JS engines to archive | Source grep/build pass; APK inspection pending |
| Source/Render mode leaked presentation state into content | Removed `BlockRenderMode` from active block payloads and UI | Unit serialization/backup tests pass |
| Renderer retirement removed task chart visualization | Added native Compose bar projection over existing task slices | Build passes; visual/type semantics pending |
| Math/diagram engine previews depended on WebView | Added native typed-payload previews; builders remain active | Build passes; visual quality pending |

## Installed-app test matrix

Run each core case in Light and Dark on a compact phone first, then repeat the layout checks on landscape and tablet/expanded width.

### Note document

- Create a note; add paragraph, heading, checklist, table, code, math, diagram, chart, image, file, embed, and container blocks.
- Edit, reorder, duplicate, delete, undo, redo, explicitly save, leave, force-stop, and reopen.
- Confirm title, block order, stable content, ToC navigation, and clean View mode.
- Switch between Flow and bounded Document Canvas; change page/artboard size and orientation; verify clamping and export.

### Task document

- Create a task with initial description text and open Docs.
- Confirm the initial text converts once into blocks and is not duplicated on reopen.
- Add rich blocks, rename from the editor, save, return to Board/Table/Feed, and confirm the task summary is readable.
- Change status/priority/dates/files, reopen Docs, and verify the document is unchanged.
- Delete the task and verify it does not return after restart or backup/restore.

### Calendar-event document

- Create events and open them from Day, Week, and Agenda.
- Add blocks, rename, save, return to calendar, and confirm title/summary updates.
- Verify all-day and timed event cards remain compact and tappable on narrow screens.
- Delete an event, restart, and confirm both event and document are gone.

### Backup and destructive PRE_BETA reset

- Populate one note, task, and event document with overlapping block IDs and distinct payloads.
- Export an encrypted backup, perform an explicitly scoped clean install/reset on the test device, restore, and compare every block/layout.
- Confirm conflicts/recent-object summaries include task and event documents without exposing encrypted content.
- Do not distribute this build as Beta or to outside testers; the project is still PRE_BETA and prior development builds allowed destructive resets.

## Premium-feel screenshot checklist

Capture full-resolution screenshots with no debug overlays:

- Docs home and editor View/Edit in Light and Dark
- compact portrait with Gboard open and formatting controls visible
- compact landscape with no clipped title/actions
- tablet/expanded editor with sidebar ToC
- Flow and each bounded page/artboard preset
- task detail Docs entry, task-owned editor, and updated Board/Table summary
- Day, Week, and Agenda event entry plus event-owned editor
- tables, code, equation, diagram, chart, image, file, and embed blocks
- empty document, 200+ block stress document, unknown-block fallback
- save-in-progress, saved, force-stop/reopen persistence
- PDF print preview and editable DOCX export result
- backup export/restore completion and conflict summary

Reject any screenshot with clipped text, fixed-width phone assumptions, stale Markdown/Source/Preview labels, all-block edit cages in View mode, inaccessible contrast, system-bar collisions, keyboard-covered controls, uneven card rhythm, or nonfunctional tap targets.

## Accessibility and resilience

- TalkBack labels and traversal order for editor actions, block menus, task Docs, and event cards
- 200% font scale without clipped actions or unreachable dialog buttons
- switch-access/keyboard navigation for save, block actions, calendar entry, and sidebar ToC
- rotation during editing, during IME composition, and during save settlement
- process death after dirty edits and after successful save
- offline create/edit/reopen followed by encrypted sync

## Automated commands

```bash
./gradlew :apps:android:testDebugUnitTest \
  :apps:android:assembleDebug \
  :apps:android:assembleDebugAndroidTest

rg -n "MarkdownPreview|MarkdownWebView|LiveMarkdownField|RenderCache|BlockRenderMode|NoteRenderEngine" \
  apps/android/src/main apps/android/src/test apps/android/src/androidTest
```

The grep must return no active-code matches. Historical archive matches are expected.

## Required Supabase dashboard action

Before testing email signup and password recovery, update the Supabase Auth email templates:

- **Confirm signup:** show the six-digit `{{ .Token }}` in the email; keep Confirm email enabled.
- **Reset password:** show the six-digit `{{ .Token }}` in the email.

The Android flow verifies these codes in-app. Do not change it back to magic-link `signInWithOtp` behavior.
