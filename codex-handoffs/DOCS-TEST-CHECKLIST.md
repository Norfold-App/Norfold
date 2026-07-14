# Docs Editor — Manual Test Checklist

Covers everything shipped for Docs on `mission/first` (uncommitted as of 2026-07-14): block editing,
drag & drop with lift/placeholder feedback, per-doc Reflow/Overlap modes, and the Table of Contents
(sidebar + bottom sheet). Run on the emulator or a device, Light **and** Dark theme where noted.

Build & install:

```bash
export JAVA_HOME=/home/sheikh/.gradle/jdks/eclipse_adoptium-21-amd64-linux.2
export ANDROID_SDK_ROOT=/home/sheikh/android-sdk
export ANDROID_HOME=/home/sheikh/android-sdk
./gradlew :apps:android:installDebug
```

Legend: each line is one check. Mark ✅ / ❌ and note anything odd next to the line.

---

## 1. Baseline sanity (5 min)

- [ ] Open any Doc → header shows title, action row (Edit, Star, Pin, Lock, Outline, 3-dot), Save chip.
- [ ] A **mode chip** sits beside the title: `Reflow` (grey) on an untouched doc.
- [ ] Double-tap the body → enters edit mode. Single-tap empty background → exits edit mode.
- [ ] Type fast for ~10 seconds → chip cycles `Saving…` → `Saved · N words`, no dropped characters.
- [ ] Close the doc, reopen → content persisted.

## 2. Reflow drag & drop (the animation must feel good)

Setup: a doc with 6+ blocks (mix paragraphs, a heading, an image, a list).

- [ ] Long-press a block in edit mode → block **lifts**: shrinks slightly, casts a shadow, floats under your finger.
- [ ] While dragging, a **dashed placeholder slot** (with pulsing chevrons) shows where the block will land.
- [ ] The placeholder **moves with your finger**, and neighboring blocks **slide smoothly** out of the way (no teleporting/jumping).
- [ ] Drop → block lands where the placeholder was; order persists after reopening the doc.
- [ ] Abort a drag (drag out and release awkwardly / cancel) → everything snaps back, no duplicate or lost block.
- [ ] Drag a block onto the **left or right edge** of another → forms side-by-side columns (nested container).
- [ ] Drag a block out of a container → container collapses cleanly when emptied.
- [ ] Repeat one lift-and-drop in **Dark theme** → shadow/placeholder colors look right.

## 3. Document settings menu (per-doc mode toggle)

- [ ] Tap the **3-dot** icon in the action row → dropdown titled **Document settings** with two options:
      **Reflow** ("Blocks push down and adapt to new space") and
      **Free overlap** ("Allow overlapping blocks — permit blocks to be dropped on top of existing content").
- [ ] A check mark marks the current mode.
- [ ] Select **Free overlap** → menu closes, mode chip flips to **Overlap On** (colored), body switches to the freeform canvas.
- [ ] Close the doc entirely, reopen → still in Overlap mode (remembered per doc).
- [ ] Open a **different** doc → it is still Reflow (setting is per-document, not global).

## 4. Free overlap canvas

Enter Overlap mode on a doc that already has several blocks.

**First entry / seeding**
- [ ] Existing blocks appear stacked down the page (cascade), none overlapping, none missing.

**Move (edit mode)**
- [ ] Each block shows a border + two handles: **layers icon** (top-right) and **drag handle**, plus a round **resize dot** (bottom-right).
- [ ] Drag via the drag handle → block moves **anywhere** — freely, no grid snapping-to-columns, no pushing other blocks.
- [ ] Drag a block **on top of an image** → it sits over the image (this is the overlay feature — no special action needed).
- [ ] While moving, when an edge or center lines up with another block, a **dashed snap guide line** appears and the block gently snaps to it.
- [ ] Release → block stays put (no snap-back flicker), and position survives close + reopen.

**Resize**
- [ ] Drag the corner dot → block resizes; can't go below a small minimum size.
- [ ] Resized dimensions survive reopen.

**Layers**
- [ ] Overlap two blocks. Tap the layers icon on the bottom one → menu shows **"Layer n of m"** + Bring to front / Bring forward / Send backward / Send to back.
- [ ] **Bring to front** → it immediately renders above the other block.
- [ ] **Send to back** → it goes behind. Z-order survives reopen.

**Canvas behavior**
- [ ] Canvas scrolls vertically when blocks extend past the screen.
- [ ] Tap empty canvas → exits edit mode; double-tap → re-enters.
- [ ] Text inside a block is still editable (tap into it) — handles don't steal typing.

**Round trip**
- [ ] Switch back to **Reflow** via the 3-dot menu → blocks return to the stacked list (original document order, nothing lost).
- [ ] Switch to Overlap again → your freeform positions are still there (layout is kept, not wiped).

## 5. Table of Contents

Setup: a doc with headings at several levels, including **one heading inside a callout or column container**.

**Sidebar ToC**
- [ ] Open the doc. On a wide screen (or via the ☰ menu button on phone) the sidebar shows an **"On this page"** section listing the headings, indented by level.
- [ ] The heading nested inside the callout/container **appears in the list** too.
- [ ] Tap a heading → editor **scrolls to that block**; on phone the sidebar drawer closes itself.
- [ ] Works in **view mode and edit mode**.
- [ ] In **Overlap mode**, tapping a ToC heading pans the canvas to that block's position.
- [ ] Doc with no headings → section shows "No headings yet" (not blank/crash).

**Bottom-sheet Outline (kept alongside)**
- [ ] Tap the Outline icon in the header → bottom sheet lists the same headings (nested ones included).
- [ ] Tapping an entry scrolls (Reflow) / pans (Overlap) and closes the sheet.

## 6. Regression sweep (10 min)

- [ ] Undo/Redo still work after drag reorders and mode switches.
- [ ] Star / Pin / Lock buttons still work; locked doc behaves as before.
- [ ] Rotate the device in both modes → no crash, layout settles.
- [ ] Markdown blocks (table, code, chart, mermaid, math, embed) render fine inside Overlap-mode blocks.
- [ ] Backup/export a note and re-import → overlap mode + positions come back (BackupCodec cells 14/15).
- [ ] Full pass of section 4's "Move" checks in **Dark theme**.

---

## Result log

| # | Area | Result (✅/❌) | Notes |
|---|------|--------------|-------|
| 1 | Baseline | | |
| 2 | Reflow drag & drop | | |
| 3 | Settings menu + chip | | |
| 4 | Overlap canvas | | |
| 5 | Table of Contents | | |
| 6 | Regressions | | |

When done: report ❌ lines back to Claude with a one-line description each (screenshot if visual).
If everything passes → say **"commit"**.
