# Codex Task 07 — Finish the Docs editor: floating toolbar, input correctness, per-block render toggle, rename Notes→Docs

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 22).** Depends on: step 1 (`CODEX_PROMPT.md` block model), steps 7–8 (`01`/`02` renderer + markdown coverage — they OWN `MarkdownWebView.kt` render logic, clickable links, and inline-math typesetting), and ideally step 13 (`../tasks-notes-overhaul/08` render cache). This prompt is the **editor UX + input-correctness + rename** layer on top — it must NOT re-implement the WebView render logic or the markdown coverage owned by `01`/`02`; it WIRES them into the native editing surface and adds the interactions/toggles below. Satisfy the universal Definition-of-Done GATE before declaring done.

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). The note editor is now block-based (`ui/screens/BlockNoteEditorScreen.kt:183`; blocks in `domain/BlockDocument.kt`; engine islands via `ui/components/MarkdownWebView.kt`). Do this fully and exactly, test on a **phone-sized** emulator (the input bugs are phone-first). No stubs.

## House rules
- Theme tokens only (`MaterialTheme.colorScheme.*`); never hardcode hues. Light + Dark both correct.
- Reuse the existing block model, ViewModel autosave, and the `01`/`02` render path. Don't fork them.
- **Do not declare done from reading code** — the input bugs only reproduce on device while typing.

## Framing — why this exists
The note editor is feature-rich but **not yet usable enough to call "done."** Typing is buggy, the old page-view editor's floating formatting bar is gone, several block interactions are dead, and text is treated as "just plain text" instead of a convertible rich block. This task makes the editor **correct and pleasant**, then renames the feature **Notes → Docs** (it has outgrown "notes").

---

## Part A — Input correctness (HIGHEST PRIORITY; phone-first). Fix each, verify on device.

### A1. Character transposition ("hello" → "helol")
**Symptom:** typing fast occasionally reorders/misplaces a character.
**Root cause to fix:** the block text field is almost certainly backed by a `String` state whose value is **re-assigned from external state (autosave / recomposition) while the IME is mid-composition**, dropping or reordering composing characters; and/or the block `LazyColumn` items aren't stably keyed, so the focused field recomposes and resets.
**Fix:**
- Back each editable block with a single **`TextFieldValue`** (text + selection + composition) as the source of truth for the focused field. Never overwrite the focused field's value from an external/async update (autosave reads the value; it must not push a new value back into a field that's being composed).
- Give every block a **stable key** in the `LazyColumn` (`key = block.id`) so editing one block doesn't recompose/reset others.
- Debounce autosave off the current value **without** re-emitting that value into the field. Verify: hold a key / type a fast burst → no transposition, no dropped chars.

### A2. Cursor position + auto-scroll while typing
**Symptom:** cursor doesn't stay where the user put it; the view doesn't scroll as typed lines push content up, so you type under the keyboard.
**Fix:**
- The caret must stay exactly where the user placed it (comes free once A1 uses `TextFieldValue` and stops resetting).
- **Auto-scroll to the caret:** use `BringIntoViewRequester` (or bring-the-cursor-rect-into-view) on the focused block so that as new lines are added/wrapped, the caret stays visible **above** the keyboard. Combine with the existing `.imePadding()` (`BlockNoteEditorScreen.kt:274`). Verify: type many lines at the bottom of a long doc → the line you're typing stays visible above the IME the whole time.

### A3. "Saving…" indicator shifts the layout (very annoying)
**Symptom:** while typing, the "saving…" status appears **inline** and pushes the editor/preview blocks up a bit, then back.
**Fix:** the save-status indicator must be **non-layout-affecting** — render it as an overlay (e.g. a small pill in the top bar, a fading status in a fixed-height slot, or an overlay aligned to a corner) that does **not** participate in the block list's layout. The block list must not move when saving state toggles. Verify: type continuously → zero vertical jump.

---

## Part B — The floating formatting toolbar (bring the bar back; keep slash)

Reference: the user's bar screenshot — a rounded floating bar containing: **⠿ drag-handle**, **T** (paragraph/heading), **T͞T** (heading size cycle), **B**, **I**, **bullet list**, **numbered list**, **checklist**, … (more via overflow).

**Decision (do exactly this):** keep BOTH input models — **slash `/` inserts new blocks**; the **floating bar formats/transforms the current block or selection.** They are complementary, not redundant. Do not remove slash.

1. Build a slim **floating formatting bar** that:
   - **Docks directly above the software keyboard** using `WindowInsets.ime` / `imePadding`, and **floats slightly above the bottom** when no software keyboard is shown (physical keyboard). Follows the keyboard show/hide animation. (This is the same behavior spec'd for the task Note field in `../tasks-notes-overhaul/03`; if that shipped, reuse its component — do not build a second one.)
   - Acts on the **focused block / active selection**.
2. Controls (at minimum): **turn-into** (paragraph, H1–H3), **bold, italic, strikethrough, inline code, link**, **bullet / numbered / checklist**, **quote, divider, code block, table, image**. Overflow menu for the rest. The leftmost **⠿** is the drag-handle affordance for reordering the current block.
3. It must **not fight slash** — slash still opens the insert menu; the bar never blocks typing. If the existing `DocumentRangeToolbar` (`BlockNoteEditorScreen.kt:376`, used ~253–272) is the "replace selected blocks" bar, keep its function but this new formatting bar is separate and primary for text formatting.

---

## Part C — Blocks are convertible rich content, not plain text

The user's ask: "text shouldn't just be plain text — it should be text, heading, bullet/numbered list, quote, divider, code, table, image all in one, easily buildable," while engine blocks that become images (mermaid, chart, math-as-image) stay **separate and unique.**

1. **Text-family blocks are freely convertible** via **turn-into** (from the bar and the ⠿ menu): Paragraph ⇄ Heading(1–6) ⇄ Bullet ⇄ Numbered ⇄ Checklist ⇄ Quote ⇄ Code ⇄ Divider. Converting preserves inline content where meaningful. Table and Image are insertable block types in the same family surface.
2. **Text-family blocks render their inline formatting richly and live** (bold/italic/strike/code/link) as the old page-view renderer did — not as raw markers. (Inline rendering + clickable links + inline math are OWNED by `02`; here, ensure the **native editing surface actually uses that path** so what you see while editing matches the rendered result.)
3. **Engine blocks stay discrete and unique** — Mermaid, Chart, and math-rendered-as-image are their own block types and are **not** part of the text-family turn-into set. You cannot "turn a paragraph into a mermaid diagram" via the text bar; those come from slash / their builders only.

---

## Part D — Per-block render behavior + the 3-dot menu "render as" toggle

1. **LaTeX / math and other engine content should read inline / user-readable by default** — a formula shows as a real typeset formula, not raw `$...$`. Inline `$…$` inside a paragraph typesets inline (this typesetting is owned by `02`; wire it in).
2. **Add a per-block 3-dot (overflow) menu option: "Render" ⇄ "Show source".**
   - **Render** = show the human-readable rendered result (typeset math, rendered mermaid, formatted table…).
   - **Show source** = show the raw text/source, monospaced, for editing/copying.
   - Applies to math and, where it makes sense, other engine/text blocks ("same should apply for other things too"). Default = Render. Persist the per-block choice so it survives reload.
3. **Links are clickable** (tapping opens/handles the URL) — this is `02`'s job for the render path; ensure it's wired in the editor's rendered view, and that link **editing** is AppFlowy-style (tap a link to edit its text/URL in a small popup, paste-URL-on-selection wraps it, bare URL can become a link/embed card). If AppFlowy-style link behavior isn't there yet, add it here.
4. **Checklist items are clickable** — tapping a todo checkbox toggles its checked state in the rendered/editing view and persists. Currently they don't respond; make them interactive.

---

## Part E — Concrete block bugs

### E1. Resize doesn't persist after save
Dragging an image/embed's size in the editor preview is lost on reload — the dragged width/height isn't written to the block model. **Fix:** persist the block's size (add/use size/layout fields on the `Image`/embed block) and re-apply it on render so a resized block keeps its size after save/reopen.

### E2. Rotate/landscape button infinite loop
The per-embed toolbar's **rotate/landscape** button (from the per-block toolbar, e.g. on a Mermaid block) sends the app into an **endless portrait⇄landscape rotation loop.** **Fix:** the orientation control must set a **stable orientation flag** (a discrete state the block honors), not trigger a recomposition that re-fires the rotation. Guard against re-entrancy; toggling it once must settle in the chosen orientation and stop. Verify: tap it → it flips once and stays.

### E3. Top action buttons clip long titles
In the Docs editor top bar, the row of action buttons sits **beside/over the title**, clipping long document names. **Move the action buttons to a row *below* the title** so the title gets full width and long names don't clip. (Match the intent in the screenshot the user referenced.)

---

## Part F — Rename Notes → Docs

The feature has outgrown "Notes." Rename the **user-facing** surface to **Docs**:
- Update user-facing strings/labels: nav ("Notes" tab/section → "Docs"), screen titles, empty states ("No notes yet" → "No docs yet"), buttons ("New note" → "New doc"), and the bottom-nav label.
- Keep internal identifiers/route names/DB tables as-is if renaming them is risky — this is a **label** change, not a data migration. Do a sweep so no user-facing "Note(s)" remains where it should read "Doc(s)"; leave code identifiers alone unless trivial and safe.

---

## Constraints
- Don't re-implement the WebView render logic or markdown coverage — that's `01`/`02`. Wire them in and add interactions/toggles.
- Don't regress autosave, slash insert, drag-reorder, or engine-block rendering.
- Theme tokens only; Light + Dark correct; correct IME/nav-bar insets.

## Definition of Done (verify each on a phone emulator — do not self-certify from code)
- [ ] Fast typing never transposes/drops characters; caret stays put (A1).
- [ ] The typed line auto-scrolls to stay above the keyboard in a long doc (A2).
- [ ] Saving status never shifts the block layout (A3).
- [ ] A floating formatting bar docks to the IME (floats above bottom without a soft keyboard), formats/transforms the focused block, and coexists with slash (B).
- [ ] Text-family blocks convert freely via turn-into and render inline formatting live; engine blocks remain discrete (C).
- [ ] Math/inline math renders readable by default; a per-block 3-dot "Render ⇄ Show source" toggle exists and persists (D1–D2).
- [ ] Links are clickable and AppFlowy-style editable; checklist items toggle on tap and persist (D3–D4).
- [ ] Image/embed resize persists across save/reopen (E1).
- [ ] The rotate/landscape button flips once and settles — no rotation loop (E2).
- [ ] Editor top-bar action buttons sit below the title; long names don't clip (E3).
- [ ] User-facing "Notes" reads "Docs" across nav, titles, empty states, and buttons (F).
- [ ] Builds clean (`./gradlew :apps:android:assembleDebug`); Light + Dark correct. Report the checklist status explicitly.
