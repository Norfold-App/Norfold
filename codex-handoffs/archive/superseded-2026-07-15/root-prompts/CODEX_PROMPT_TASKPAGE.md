# Codex task — Norfold (Android): make the Task detail page match `Opening a task from board-view.png` 100%

## Role & rules
- App: **Norfold**, Jetpack Compose + Material3, package `com.norfold.app`, repo `/home/sheikh/GitHub/Libre-Notes`, module `apps/android`.
- **The reference screenshot is the source of truth. Match it 100%.** If a match temporarily breaks unrelated styling, fix the fallout *after* the visual match is exact — do not compromise the match to keep old styling.
- **Never hardcode hues.** Accent is theme-driven — read `MaterialTheme.colorScheme` tokens (`primary`, `surface`, `surfaceVariant`, `onSurfaceVariant`, `outlineVariant`, `primaryContainer`). Support Light and Dark only.
- **Do NOT restructure the data layer, view model, or navigation.** This is a *layout/visual* pass on one composable and its helpers. Reuse every existing `viewModel.*` call verbatim — persistence already works; only the presentation is off.
- **Scope is exactly ONE screen: the task detail sheet.** Do not touch the board/table/calendar/other views, onboarding, theme files, or branding. Do not rename public composables or change their call sites.

## The one file you edit
`apps/android/src/main/java/com/norfold/app/ui/tasks/TasksBoardScreen.kt`
- Target composable: **`AdaptiveTaskPage`** (currently ~line 2147) and its private helpers:
  `TaskColorPalette`, `ColorSwatch`, `MainPropertiesCard`, `MainPropertyRow`, `MainPropertyEditDialog`, `TaskFilesSection`, and the inline Details/Comments/Delete `item {}` blocks.
- These are all **private helpers in this same file** — you may freely refactor their *internals* and add new private helpers. Keep `AdaptiveTaskPage`'s signature and the `editingTask?.let { AdaptiveTaskPage(...) }` call site at ~line 393 unchanged.

## Reference image (source of truth)
`/mnt/c/Users/sheik/Downloads/Zielorya/Opening a task from board-view.png`
(Windows path from repo host: `Downloads/Zielorya/Opening a task from board-view.png`.)
Read it first. Every element below is described *as it appears there*. Also cross-check `Board_view_Plan_Adaptive.png` for the shared accent + card language.

---

## Starting state — already correct, do NOT redo
The detail sheet ALREADY has: full-screen sheet on phones / right side-panel on tablets; a grouped **Main properties** card with popup editors (`MainPropertyEditDialog`); a color palette; a Files section; a Details card; Comments; Delete. **The structure is right — the styling and a few groupings are wrong.** Fix the deltas below; don't rebuild from scratch.

---

## Deltas to fix (each maps to a visible element in the screenshot)

### 1. Header row
Current: back button is a `surfaceVariant` **circle**; subtitle reads `"From this board"`; there's a Save button.
Fix to match:
- Back button: **white rounded-square** (not circle) — `RoundedCornerShape(14.dp)`, `color = surface`, subtle shadow/elevation, 44–48.dp, back arrow centered.
- Title: keep `headlineMedium` Black weight.
- Subtitle: `"From "` in `onSurfaceVariant` + **the board name in `primary`** (accent), e.g. `From ` + **Default board**. Pass the board name in (the selected board's `name`) instead of the literal `"From this board"`. If the board name isn't already available inside `AdaptiveTaskPage`, thread it through from the call site (`selectedBoard?.name`) as a new `boardName: String` parameter — that call site is in the same file.
- Star: keep outline/filled toggle (already correct).
- Save: **filled accent pill**, `RoundedCornerShape(20.dp)`, `containerColor = primary`, white label — visually the boldest control in the header. (Behavior stays `onDismiss`.)

### 2. Color card  ← currently a bare row, must become a card
Wrap `TaskColorPalette` in a **card**: `Surface`, `RoundedCornerShape(18.dp)`, `color = surface`, `fillMaxWidth`, inner padding 14.dp. Inside: `"Color"` label (bold) on the left, swatches in a row.
- The **selected** swatch shows a **white check glyph centered inside the filled circle** (see the first purple swatch in the ref), not just a ring. Keep the current `ColorSwatch` selection border logic but add an `Icon(Icons.Filled.Check)` (or checkmark) overlay when `selected`.
- Swatch order/colors: keep the existing `TaskAccentPalette`.

### 3. Main properties card
Current: header has icon + title but **no collapse chevron**; value shown as a plain surface + `ExpandMore`.
Fix:
- Header: property-tune icon + `"Main properties"` bold, and a **collapse chevron on the far right** (`ExpandLess` when expanded). Make the card **collapsible** — tapping the header toggles a `remember { mutableStateOf(true) }`; collapsed hides the rows. (Checklist card gets the same treatment, item 4.)
- Each `MainPropertyRow`: the value on the right must read as a **bordered dropdown pill** — `Surface` with `border = BorderStroke(1.dp, outlineVariant)`, `RoundedCornerShape(10.dp)`, value text + a **down chevron INSIDE the pill on its right edge**. Remove the separate trailing `ExpandMore` that sits outside the pill.
- **Labels row**: render the actual label values as **colored chips** (reuse the chip look from `TinyMeta`/`AssistChip` used elsewhere in this file), followed by the dropdown chevron — not as one comma-joined string.
- **Due date row**: when empty show `"No date set"` with a trailing **calendar icon** (`Icons.Outlined.Event`) inside the pill.
- Row order top-to-bottom per ref: **Status, Assignee, Priority, Labels, Due date.** Sort `mainProperties` to this order (fall back to existing sortOrder for anything else).

### 4. Checklist card
Match the ref exactly:
- Header: checkbox icon + `"Checklist"` bold, then **`done/total` in accent** (e.g. `1/3`), a **mini progress bar** filling the header's right third, and a **collapse chevron**.
- Items: leading `Checkbox`; when checked, the label is **struck through** + `onSurfaceVariant`; each row has a **round assignee avatar on the far right** (reuse `AssigneeAvatar`; use the task assignee as placeholder — do not invent a new data field).
- Footer: an `"Add a new item"` `OutlinedTextField` + an **`Add` pill button** (tonal), matching the ref's rounded input + button.
- This currently renders through `TaskPropertyBlock` / `ChecklistPropertyEditor`. You may add a dedicated checklist-card composable for the detail page, but **reuse the existing checklist view-model calls** (add/toggle/reorder item) — do not add new persistence.

### 5. Notes  ← must be its OWN card, not a Main-properties row
The `Text`/Notes property currently falls into the Main properties card. In the ref, **Notes is a separate card** below Checklist: header `Tt` icon + `"Notes"` bold, then a bordered box showing the note text with a **pencil edit icon** on its right. Pull the `TaskPropertyType.Text` "notes" property out of `mainProperties` and render it as its own card (tapping opens the existing text editor dialog).

### 6. Files & media card
Current empty state is a plain `"No files attached"` line. Match the ref's **dashed empty state**:
- Card header: paperclip icon + `"Files & media"` bold, `"Attach"` **outlined pill** on the right.
- Empty state: a **dashed-border rounded box** (`RoundedCornerShape(16.dp)`, dashed `outlineVariant` stroke) containing a paperclip badge + `"No files attached"` (bold) + `"Attach files or images to this task"` (`onSurfaceVariant`), with an `"Attach"` pill. Use a dashed stroke (`Stroke(pathEffect = PathEffect.dashPathEffect(...))` via `drawBehind`, or a dashed `border`).
- Non-empty: keep the current per-file rows.

### 7. Details card
Add a leading **calendar icon** next to the `"Details"` title so it matches the other card headers. Keep the Created at / Last modified rows (right-aligned values) — those are already correct.

### 8. "New property" button
Make it a **full-width dashed button** (`RoundedCornerShape(16.dp)`, dashed `outlineVariant` border, centered `+ New property` in `primary`), not a bare left-aligned `TextButton`.

### 9. Comments
- Header: **chat icon** (`Icons.Outlined.ChatBubbleOutline` or similar) + `"Comments"` bold.
- Reply row: `"Add a reply..."` field + a **circular send button showing a paper-plane** (`Icons.AutoMirrored.Outlined.Send`) tinted `primary`, not the current `Add` icon.

### 10. Delete
Replace the current `Delete + Done` row with a **single centered red control**: trash icon + `"Delete task"` in `error` color, horizontally centered, no `Done` button (the header Save already dismisses). Keep the `onDelete` behavior.

---

## Spacing / card language (apply consistently)
- Every section is a **card**: `Surface`, `RoundedCornerShape(18.dp)`, `color = surface`, `fillMaxWidth`, inner padding ~14.dp, vertical gap between cards ~14.dp (the `LazyColumn` already uses `spacedBy(14.dp)` — keep it).
- Card header pattern is uniform: **leading accent icon + bold title on the left**, optional trailing control (chevron / count / action pill) on the right.
- Icons in headers tinted `primary`; secondary text `onSurfaceVariant`; borders `outlineVariant`.

## Constraints (do not break these)
- Keep the tablet side-panel vs phone full-screen branch (`sidePanel`), `BackHandler`, `navigationBarsPadding`, `imePadding`, and `zIndex(20f)` scrim exactly as-is.
- Keep the `LazyColumn` item structure; you may split/merge `item {}` blocks but every section must stay lazy.
- All existing `viewModel.*` calls stay identical. **No Room/schema/migration/model changes.** No new dependencies.
- Do not edit any other file. If you truly need the board name and it isn't reachable, add ONE `boardName: String = ""` parameter to `AdaptiveTaskPage` and pass `selectedBoard?.name ?: ""` at the single call site — nothing else.

## Definition of done
- Task detail sheet visually matches `Opening a task from board-view.png` element-for-element: white rounded-square back button, accent board-name subtitle, filled Save pill, Color card with checked swatch, collapsible Main properties with dropdown-pill values + label chips, Checklist card with `x/y` + progress + per-item avatars + Add row, standalone Notes card, dashed Files empty state, Details card with calendar icon, dashed New-property button, Comments with chat + paper-plane, centered red Delete task.
- `./gradlew :apps:android:assembleDebug` compiles. Light and Dark both look right. No hardcoded colors. No changes outside `TasksBoardScreen.kt` (except the optional one-line `boardName` thread-through).
