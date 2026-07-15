# Norfold — Master Manual Test Checklist

Extends `DOCS-TEST-CHECKLIST.md` (run that file's sections 1–6 first — they cover the Docs editor,
drag & drop, Overlap mode, and the Table of Contents). This file covers everything else shipped in
the backlog close-out marathon on `mission/first` (codex steps 4, 5, 6, 7, 8, 9, 12a, 13–21, one
commit per step, 2026-07-14/15). Run on the emulator or a device, Light **and** Dark theme where noted.

Build & install:

```bash
export JAVA_HOME=/home/sheikh/.gradle/jdks/eclipse_adoptium-21-amd64-linux.2
export ANDROID_SDK_ROOT=/home/sheikh/android-sdk
export ANDROID_HOME=/home/sheikh/android-sdk
./gradlew :apps:android:installDebug
```

Legend: each line is one check. Mark ✅ / ❌ and note anything odd next to the line.

---

## 1. Docs editor baseline (prerequisite)

- [ ] Run **all six sections of `DOCS-TEST-CHECKLIST.md`** and fill in its result log. Anything ❌ there blocks the rest.

## 2. Popup wrappers (step 12a, Phase 1)

Behavior should be identical to before — this batch was a mechanical migration.

- [ ] Open a handful of dialogs across the app (delete confirmations, goal/event create, settings dialogs, workspace visual dialog) → all render and dismiss normally.
- [ ] Open a handful of bottom sheets (chart builder, task Filter/Sort/Boards, settings pickers) → sheets open, scroll, and dismiss normally.
- [ ] Fullscreen engine dialog in the Docs editor still opens/closes.
- [ ] No dialog appears unstyled/double-scrimmed in Dark theme.

## 3. Sidebar (step 4)

- [ ] Open the sidebar → order is: Dashboard, Today, Upcoming, Favorites, **Notes**, **Tasks**, Files, Chat, Inbox, divider, Archive, Trash, Settings. No "Workspace" label.
- [ ] Inside a Doc, the **"On this page"** ToC block still appears at the top of the nav (above Dashboard).
- [ ] **Notes** row: tapping the label goes to All notes; tapping the chevron expands → "All notes" + the 3 most recently updated notes (untitled ones show "Untitled").
- [ ] With more than 3 notes, an **"…"** row appears → tap shows all notes; **"Show less"** collapses back to 3.
- [ ] Tapping a recent note opens that note in the editor.
- [ ] **Tasks** row: chevron expands → Board, Table, Calendar, Agenda. Board/Table open the Tasks workspace in that view; Calendar opens Calendar; Agenda opens Calendar in Agenda mode.
- [ ] **Today** opens Calendar in Day view; **Upcoming** opens Calendar in Agenda view; the selected row highlights accordingly.
- [ ] Study Planner section now only lists Docs and Resources (no duplicate Board/Table/Calendar); Subjects section unchanged.
- [ ] Dark theme: selection pill + indicator look right.

## 4. Task page scrim (step 5 leftover)

- [ ] Open a task (AdaptiveTaskPage) in **Dark theme** → the dimmed backdrop matches other overlays (no pure-black mismatch).

## 5. Markdown, render engines, render cache (steps 7, 8, 13)

Create a Doc and paste a fixture with: headings, `**bold**`, `~~strike~~`, `==highlight==`, `H~2~O`, `x^2^`,
a table, fenced code (both ``` and `~~~`), `$inline math$`, a mermaid block, a Vega chart block,
`[TOC]`, `Term\n: definition`, `[[WikiPage]]`, `[[WikiPage|Alias]]`, `%%hidden comment%%`,
`*[HTML]: HyperText Markup Language` + a sentence containing HTML, a `> quote > nested quote`,
`^[inline footnote]`, `<u>underline</u> <kbd>Ctrl</kbd> <details><summary>more</summary>hi</details>`.

- [ ] Rendered view: highlight/sub/sup, table (scrolls horizontally), both fence styles, callouts, footnotes render.
- [ ] `[TOC]` renders a generated heading list (WebView and native render modes).
- [ ] Wikilinks render as styled links; `%%comments%%` are stripped; abbreviation shows as `<abbr>` in WebView.
- [ ] Nested quote renders as nested (indented) quotes, not flattened text.
- [ ] Inline `$math$` in native mode renders code-styled (not serif body text).
- [ ] Break a mermaid/Vega/math block deliberately (bad syntax) → a muted error note appears instead of a blank box; no block stays stuck on "Rendering…".
- [ ] Per-block **render again** icon on an engine card re-renders that block.
- [ ] 3-dot Document settings → **Re-render all** re-renders every engine block.
- [ ] Scroll away from a rendered chart and back → it reappears instantly (cache hit — no "Rendering…" flash).
- [ ] Dark theme: rendered markdown + engine blocks recolor correctly.

## 6. Chart builder (step 9)

- [ ] Insert a chart block → builder sheet opens; the data grid **scrolls vertically** when there are many rows; the Series column is never clipped.
- [ ] Each row has a **color swatch** → set different colors on two rows → preview reflects them.
- [ ] Set a **Caption** → it appears in the live preview, in the committed chart, and in the exported PNG.
- [ ] Commit, reopen the chart for editing → per-row colors and caption round-trip.
- [ ] Create one of each chart type (bar, line, pie, donut, area, scatter as available) → all render.

## 7. Tasks workspace (steps 14, 15, 16, 17, 18, 19)

**Editor unification (14)**
- [ ] Table view "New task" and Kanban column "+ Add task" both open the full task page in create mode (header "New task") — no old small dialog anywhere.
- [ ] Creating from a column pre-seeds that column/status; Save creates the task with its properties.

**Swipe actions (15)**
- [ ] In Table view, swipe a task row toward the end → default action completes the task (undoable); swipe from the start edge → the configured start action.
- [ ] Delete via swipe shows a snackbar with **Undo**; undo restores the task.
- [ ] Long-press drag and tap-to-open still work on the same rows; Kanban cards and Calendar are NOT swipeable.

**Live markdown field (16)**
- [ ] Open a task's Text/Note property → editing shows the field + formatting toolbar + live preview underneath (updates ~0.2s after typing stops).
- [ ] With the keyboard open the toolbar is a docked strip; dismiss the keyboard → it becomes a floating pill.
- [ ] Bold/Italic/Heading/List/Checklist/Link/Code/Math buttons wrap the selection or insert at the caret; Link selects the `url` placeholder.
- [ ] Table and Divider chips insert their snippets.
- [ ] Plain prose previews natively; content with a table/fence/math/image switches to the WebView renderer (Auto engine).
- [ ] Cancel restores the original text; Save persists.

**Chart view (17)**
- [ ] Tasks → Chart tab shows a real chart (not progress bars). Header chart icon opens the config sheet.
- [ ] Change group-by (Status/Priority/Tag/Assignee/Due) and type (bar/stacked/pie/donut/line) → chart updates.
- [ ] Invalid combos show a friendly hint; a board with no tasks shows an empty state.
- [ ] Chart respects the active filters and selected board.

**Feed merge (18)**
- [ ] There is no Gallery tab. Feed's header icon toggles **list ⇄ grid** with an animation; mode is remembered across app restarts.
- [ ] In List mode the right rail is hidden entirely.

**Right rail (19)**
- [ ] In Table/Feed the rail shows vertical summary rows: "Filter · N active", "Sort · <field>", "Boards".
- [ ] Filter row opens a bottom sheet with grouped multi-select chips + Reset; results apply live.
- [ ] Sort row opens a sheet: pick field + asc/desc; a single active sort.
- [ ] Boards row opens a sheet: switch, rename, and create boards. (Board **delete** is intentionally absent — no existing backend method.)

## 8. Calendar (steps 6, 20)

**Header inset (20)**
- [ ] On a phone-width screen, the Calendar header ("Calendar" + icon) sits clear of the floating ☰ sidebar button — no overlap in any view mode.

**Month pager (20)**
- [ ] Month view: swipe left/right → previous/next month pages smoothly; the month label in the header follows the settled page.
- [ ] Chevron buttons still work and animate the pager.
- [ ] Grid stays 6×7 with event dots; tapping a day selects it and opens Day view (as before).

**Week rebuild (6)**
- [ ] Week view: fixed month label + view toggle on top; a 7-day header row; tapping a day selects it.
- [ ] All-day and multi-day tasks appear as **capsules** spanning their days under the day header (max 3 lanes, then "+N more").
- [ ] Below, the timed grid: thin hour rail on the left + 7 day columns scrolling **together** vertically.
- [ ] Hours with no tasks are collapsed into thin bands; hours with tasks are tall bands whose labels match the tasks' start hours; with many tasks in a day the rail gets finer-grained.
- [ ] A week with no timed tasks shows "No timed tasks" (all-day capsules still show).
- [ ] Horizontal swipe pages to the previous/next week; the header month label follows.
- [ ] Tapping an event chip (timed or capsule) opens the task's detail.
- [ ] Month/Day/Agenda views are unchanged and still work.
- [ ] Dark theme: week grid borders/chips look right.

## 9. Branding (step 21)

- [ ] App icon on the launcher shows the real Norfold glyph on the indigo gradient (not a plain "N"); circular and squircle masks both look centered.
- [ ] Android 13+ themed-icon mode: the monochrome glyph renders (long-press home → wallpaper & style → themed icons).
- [ ] Splash screen shows the glyph.
- [ ] Onboarding/logo tiles in-app show the glyph (dark tile → white glyph); no leftover text "N" tiles anywhere.
- [ ] A test notification (if reachable) shows the glyph as the status-bar small icon.

## 10. Migration & regression sweep

- [ ] Upgrade-in-place from a build before this marathon (or with existing data): app opens, tasks/notes/settings intact (Room v29→v30→v31 column adds).
- [ ] If the task view was previously "Gallery", it opens as Feed (grid) without crashing.
- [ ] Unit suite green: `./gradlew :apps:android:testDebugUnitTest` (JDK 21).
- [ ] Rotate the device on Tasks, Calendar Week, and a Doc → no crash, layout settles.
- [ ] Kanban drag & drop still works (TaskDragPlanner untouched).

---

## Result log

| # | Area | Result (✅/❌) | Notes |
|---|------|--------------|-------|
| 1 | Docs editor (DOCS-TEST-CHECKLIST) | | |
| 2 | Popup wrappers | | |
| 3 | Sidebar | | |
| 4 | Task page scrim | | |
| 5 | Markdown / engines / cache | | |
| 6 | Chart builder | | |
| 7 | Tasks workspace | | |
| 8 | Calendar | | |
| 9 | Branding | | |
| 10 | Migration & regressions | | |

When done: report ❌ lines back to Claude with a one-line description each (screenshot if visual).
If everything passes → say so, and the COMPLETION_STATUS rows can be advanced past "Partial".
