# FIRST MISSION — Make the Docs editor render *everything*, beautifully and correctly

> **⛓ This is the FIRST thing to execute after the Phase 1 audit (see `00-START-HERE.md`).**
> It **absorbs and replaces** `notes-charts-popups/07-docs-editor-completion.md` (all of 07 is included here as Part 0) and **extends** the chart builder (`03`), diagram builder (`04`), and markdown/math coverage (`02`). Where this file and 03/04/07 overlap, **this file wins** — but do NOT re-implement the WebView render logic or markdown coverage owned by `01`/`02`; wire them in.
>
> Satisfy the universal Definition-of-Done GATE in `MASTER_ORDER.md` before declaring ANY part done.

## The one non-negotiable rule for this mission
**You must prove every fix visually.** After each Part:
1. Build: `./gradlew :apps:android:assembleDebug`.
2. Run on a **phone-sized emulator** and, where the Part is a typing/interaction fix, **actually type and interact** — reading code is NOT proof.
3. **Capture screenshots of every screen you touched** (Light AND Dark), save them under `codex-handoffs/screenshots/<part>/`, and confirm with your own eyes that nothing is misaligned, cut off, overlapping, crashing, or behaving wrong.
4. If a screenshot looks wrong, **fix it before moving on.** A green build is not success — the user-visible surface being correct is success.
5. **Commit after each Part** with a clear message, and tick that Part's DoD in `COMPLETION_STATUS.md`.

The whole point of this app is: **the document editor renders everything, in every reasonable way, without missing a beat, while staying user-friendly.** That is the selling point. Treat "user-friendly + visually correct" as the acceptance bar, not "compiles."

## Role & house rules
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Block editor = `ui/screens/BlockNoteEditorScreen.kt`; blocks in `domain/BlockDocument.kt`; engine islands via `ui/components/MarkdownWebView.kt`; chart builder `ui/components/ChartBuilderSheet.kt` + `domain/ChartSpecCodec.kt`; diagram builder `ui/components/DiagramBuilderSheet.kt`.
- Theme tokens only (`MaterialTheme.colorScheme.*`); never hardcode hues. Light + Dark both correct.
- Reuse the block model, ViewModel autosave, and the `01`/`02` render path — don't fork them.
- No stubs, no TODOs where behavior was asked for. If something is genuinely out of scope, say so explicitly in the report.

---

# PART 0 — Everything from prompt 07 (the editor completion)

Do all of `notes-charts-popups/07-docs-editor-completion.md` in full. Summary of what it covers (see that file for the detail, and honor it):
- **A. Input correctness (phone-first):** no character transposition (back each block with a single `TextFieldValue`, stable `key = block.id`, never overwrite a composing field from autosave); caret stays put and auto-scrolls above the keyboard (`BringIntoViewRequester`); the "Saving…" indicator must NOT shift layout (render as overlay).
- **B. Floating formatting bar** docked above the IME (floats above bottom with a physical keyboard), acting on the focused block/selection — turn-into, bold/italic/strike/inline-code/link, bullet/numbered/checklist, quote/divider/code/table/image, `⠿` drag-handle. Keep slash `/` for inserting new blocks; the bar formats. They coexist.
- **C. Text-family blocks are convertible rich content** (Paragraph ⇄ Heading ⇄ Bullet ⇄ Numbered ⇄ Checklist ⇄ Quote ⇄ Code ⇄ Divider) rendering inline formatting live; engine blocks (Mermaid/Chart/Math-as-image) stay discrete.
- **D. Per-block "Render ⇄ Show source" 3-dot toggle** (default Render, persisted); links clickable + AppFlowy-style editable; checklist items toggle on tap and persist.
- **E. Block bugs:** image/embed resize persists across save/reopen (E1); rotate/landscape button flips **once** and settles — no rotation loop (E2); editor top-bar action buttons sit **below** the title so long names don't clip (E3).
- **F. Rename Notes → Docs** on the user-facing surface only (labels, titles, empty states, buttons, nav) — **label-only**, no DB/route/identifier migration.

Everything below (Parts 1–7) is **new** and on top of Part 0.

---

# PART 1 — Chart builder: scroll, per-item color, combo charts, sizing, advanced source, editor cache

Builds on `03-chart-builder-fixes.md`. If 03 already shipped some of this (check the audit), verify and only fix what's broken. Files: `ChartBuilderSheet.kt`, `ChartSpecCodec.kt`, `BlockNoteEditorScreen.kt` (`EditableChartBlock` ~800).

### 1.1 Data points must scroll (currently broken)
The chart page opens, but **added data points do not scroll** — after the 3rd point it's **impossible to view or edit** the rest. Make the data-point list a properly scrollable container (`LazyColumn` with bounded height, or the sheet itself scrolls) so **any number** of points is reachable and editable. Verify with 8+ points: scroll to the last one and edit it.

### 1.2 Per-item unique color
**Each item** (each bar, dot, slice, point) must get its **own** color via a per-row color control. Store per-row color in the model, encode into the Vega-Lite spec (per-datum color / scale range), and round-trip through `decode` via the `norfold` metadata. Verify colors show in **preview AND** the committed chart.

### 1.3 Combo / multi-type charts (merge two into one)
Allow **merging chart types in one chart** — e.g. **bar + line**, **bar + scatter**. A single chart can present **multiple data series each as a different type**, adaptively (Vega-Lite `layer` / per-series `mark`). In the builder:
- Each **series** can pick its own mark type (bar / line / area / point/scatter).
- The layered result renders as one combined chart.
- **Draggable repositioning:** the user can reorder/reposition series (e.g. drag to change layer order / which axis). At minimum, drag-reorder the series list so stacking/lay order is user-controllable. (Full free-drag on the canvas is a stretch goal; series reordering is the must.)
Verify: build a bar+line combo, commit, reopen — both series and their types round-trip.

### 1.4 Visual data sizing
Expose visual-size controls that map to Vega-Lite properties:
- **Thickness** (bar width / line stroke / point size),
- **Padding** (band padding / spacing between items),
- **Orientation** — bars **vertical or horizontal** (swap x/y encoding).
Persist these in the `norfold` metadata so they round-trip. Verify each visibly changes the rendered chart.

### 1.5 Advanced button → raw code insertion
Add an **"Advanced"** control at the end of the builder that reveals a **raw spec editor** (Vega-Lite / source JSON) for power users. Edits sync back to the committed chart. (If 03's "Advanced source toggle" exists, this is the same thing — make sure it's present, labeled "Advanced", and at the end.)

### 1.6 Editor-only "Cache & reload" button (performance)
Re-rendering charts every time they scroll into view is **heavy**. Add a **cache-and-reload control that exists ONLY in the editor view** (not the read view): render once, cache the result (image/snapshot), and reuse it; the button forces a fresh re-render on demand. This complements `../tasks-notes-overhaul/08`'s render cache — coordinate with it, don't build a conflicting second cache. Verify: scrolling a doc with several charts no longer re-renders each on every appearance; the reload button visibly refreshes.

**Part 1 DoD**
- [ ] 8+ data points all reachable & editable (scroll works).
- [ ] Each item has its own color; shows in preview and committed chart; round-trips.
- [ ] Combo charts (bar+line, bar+scatter) work; per-series mark type; series reorder/drag; round-trips.
- [ ] Thickness, padding, and vertical/horizontal orientation controls work and persist.
- [ ] "Advanced" raw-spec editor at the end; edits sync and round-trip.
- [ ] Editor-only cache-&-reload button; charts don't re-render on every scroll-into-view; reload forces refresh.

---

# PART 2 — Tables: side "+ Column", stop the crash, reliable resize, editor↔saved consistency

Files: `BlockNoteEditorScreen.kt` (`NativeTable` ~1150), `MarkdownWebView.kt` (table CSS).

### 2.1 "+ Column" goes to the SIDE, not below — and it currently CRASHES
The **"+ Column"** affordance must sit on the **right side** of the table (AppFlowy style — a thin add-column strip down the right edge), not below the table. **It currently crashes the app** — find the crash (paste the stack trace in your report) and fix it so adding a column never crashes. Keep an **"+ Row"** affordance at the bottom.

### 2.2 Column/row resize dragging must actually work
The drag-to-resize handles **don't work perfectly**. Make column resize (and row height where applicable) drag smoothly and land where dropped. Verify by dragging several columns to different widths.

### 2.3 Editor ↔ saved consistency
The table looks different **in the editor vs after it's saved**. The rendered (saved/read) table and the editing table must match — same widths, alignment, and content. Persist column widths in the block model and re-apply on render. Verify: set widths → save → reopen → identical.

### 2.4 Wide tables scroll horizontally
(From `02`.) Wide tables scroll horizontally instead of bleeding off the edge, in **both** native and WebView tables.

**Part 2 DoD**
- [ ] "+ Column" is a right-side AppFlowy-style strip; "+ Row" at bottom; **adding a column never crashes** (old crash traced & fixed).
- [ ] Column resize drags smoothly and persists.
- [ ] Editor and saved/rendered table are visually identical after save/reopen.
- [ ] Wide tables scroll horizontally in native + WebView.

---

# PART 3 — Link embeds get the site's icon; no raw URL in the saved view

Files: `EmbedMetadataResolver.kt`, `BlockNoteEditorScreen.kt` embed/link blocks, `MarkdownWebView.kt`.

Currently, embedding a link **doesn't fetch the page's favicon/icon**, and the **raw URL leaks into the saved notes/read view**. Fix:
- When a link is embedded as a **link/bookmark card**, resolve and show the **site favicon** (and title/description if available) — a proper embed card, not bare text.
- In the **saved/read view**, show the **card**, not the raw `https://…` string. A plain inline link stays a clickable link (owned by `02`); an **embed** renders as a card with icon.
- Handle failure gracefully (no icon available → a sensible fallback glyph, never a broken image).

**Part 3 DoD**
- [ ] Embedded links show the real site favicon + title in a card.
- [ ] The saved/read view shows the card, not a raw URL string.
- [ ] Missing-icon fallback is clean; no broken-image placeholder.

---

# PART 4 — Math: a visual equation bar (no raw code)

Files: `MarkdownWebView.kt` (KaTeX/MathJax typeset path, owned by `02` — reuse), `BlockNoteEditorScreen.kt` (MathBlock + inline math), a new small builder e.g. `ui/components/MathBuilderSheet.kt`.

Writing math should **not** require typing raw LaTeX. Give the user a **visual math input bar / equation palette** (like the reference image the user shared) that lets them insert **any kind of math visually**:
- A palette of common structures — fraction, exponent/superscript, subscript, root, integral, sum/product, matrix, Greek letters, common operators/relations.
- Tapping a template inserts it and positions the caret in the next slot; a **live typeset preview** updates as they build.
- Keep an **"Advanced" raw-LaTeX** field for power users (the two stay in sync), but the **default experience is visual.**
- Works for both **block math** and **inline `$…$`** insertion. Typesetting itself is `02`'s KaTeX path — wire it in; don't reimplement.

**Part 4 DoD**
- [ ] A visual math bar/palette inserts fractions, powers, roots, sums/integrals, Greek, matrices without typing LaTeX.
- [ ] Live typeset preview while building.
- [ ] Advanced raw-LaTeX toggle stays in sync.
- [ ] Both block and inline math insertion work and render typeset.

---

# PART 5 — Mermaid: visual builder, per-box color, custom shapes, nested (no raw code)

Builds on `04-diagram-builder.md`. Files: `DiagramBuilderSheet.kt`, `MarkdownWebView.kt` (Mermaid render), `BlockNoteEditorScreen.kt` (`MermaidBlock`).

Diagrams should be built **visually like the chart editor**, not by typing raw `graph TD`:
- **Define connections in text boxes:** rows of **from → to** (with optional edge label), and a node list — the builder generates valid Mermaid. (04 spec'd this for Flowchart/Sequence; make it real and solid.)
- **Per-box color:** each node can be assigned its **own color** (generate Mermaid `style`/`classDef` per node). Verify colors render.
- **Custom node shapes:** let the user pick a node's shape — at minimum **circle, squircle (rounded), diamond** (map to Mermaid shapes: `((circle))`, `(rounded)`, `{diamond}`; squircle = rounded-rect styling). Offer these per node.
- **Live preview** reuses the real Mermaid WebView path.
- Keep an **Advanced raw-source** toggle in sync.

> Note on "nested quoting" also lives in Part 6 — don't confuse it with nested diagrams. Here, ensure sub-structures (subgraphs) at least don't break; full subgraph UI is a stretch goal, per-box color + shapes + connection boxes are the must.

**Part 5 DoD**
- [ ] Flowchart built entirely from from→to boxes + node list; generates valid Mermaid.
- [ ] Per-node color works and renders.
- [ ] Node shape picker (circle, squircle/rounded, diamond) works and renders.
- [ ] Live preview + Advanced raw-source in sync; editing an existing diagram reseeds the builder.

---

# PART 6 — Rich text everywhere + nested quotes + render-everything sweep

The user: *"Currently most text fields are text-only. I want those to be more than just text — LaTeX, math, and other capabilities wired fully. The document editor should render everything in every possible way without missing a beat while staying user-friendly."*

### 6.1 Nested quotes
Blockquotes render, but **nested quoting** (a quote inside a quote, `>>`) must work — both rendering and, ideally, creating via the bar (increase/decrease quote depth). Verify multi-level nesting renders correctly.

### 6.2 Rich text in text fields (not just the main editor)
Audit the app's **text fields** that are currently plain-text-only (task Note field, description fields, etc. — grep for `TextField`/`BasicTextField` usages that hold user prose) and, where it makes sense, route their **display** through the rich render path so **inline formatting, links, LaTeX/math** render instead of showing raw markers. Editing can stay plain; **rendering must be rich.** List which fields you upgraded in your report. (Don't blindly convert search boxes / single-line inputs — use judgment; prose fields only.)

### 6.3 Render-everything final sweep
Re-run the `notes-charts-popups/RENDERER_ACCEPTANCE_TEST.md` fixture end-to-end and confirm the document editor renders every supported case correctly (unsupported engines fall back to readable source per `02`, never blank). This is the "without missing a beat" acceptance.

**Part 6 DoD**
- [ ] Nested quotes render (and depth is adjustable from the bar).
- [ ] Identified prose text fields render rich content (inline formatting / links / math), not raw markers — list them.
- [ ] Full acceptance fixture passes section-by-section; no blank boxes.

---

# PART 7 — Anything the user missed (fill the gaps toward "renders everything")

The user asked you to **"add more if I missed."** With the selling point in mind (render everything, every way, user-friendly), if during the work you find an obvious gap that blocks "renders everything without missing a beat" — e.g. a common block type that has no builder, a render that only works one direction, an interaction that's discoverable-but-dead — **note it in `COMPLETION_STATUS.md` under a "Discovered gaps" heading with a recommendation**, and fix the small/safe ones. Do NOT silently expand scope on large ones — list them for the user to approve.

---

## Global constraints
- Don't re-implement WebView render logic / markdown coverage — that's `01`/`02`; wire them in.
- Don't regress autosave, slash-insert, drag-reorder, or engine-block rendering.
- Everything visual: verified on a **phone emulator**, Light + Dark, with screenshots saved under `codex-handoffs/screenshots/`.
- Commit after each Part; update `COMPLETION_STATUS.md` per Part; if blocked, **stop and report** — don't mark done.

## Final report (end of mission)
For each Part: the build line, the DoD checklist with ✅/❌ per item, the screenshot folder path, any grep proofs (rename/removal), the traced table crash, and anything deferred with the reason.
