# Codex task — Norfold (Android): rebuild the editor on a block model, rich rendering, visual chart builder, smart paste, AppFlowy tables/tags/sidebar, and demo content

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 1).** **Idempotency guard:** much of this may already exist in the codebase — verify each piece against its own DoD and repair/complete only what is missing or broken. Do NOT rebuild working implementations from scratch. Satisfy the universal Definition-of-Done GATE in `../MASTER_ORDER.md` before declaring done.

## Role & rules
- App: **Norfold**, Jetpack Compose + Material3, package `com.norfold.app`, repo `/home/sheikh/GitHub/Libre-Notes`, module `apps/android`.
- **The reference screenshots are the source of truth. Match them 100%, even if doing so temporarily breaks unrelated behavior — fix the fallout only *after* the visual/behavioral match is exact.**
- Accent color is theme-driven from Settings. **Never hardcode hues** — read `MaterialTheme.colorScheme` tokens. Light and Dark only.
- **Norfold is for everyone, not just coders.** Every "code-ish" surface (markdown source, chart spec, mermaid, math TeX) must have a friendly *visual* path as its primary face. Raw code survives only as (a) a per-block advanced affordance that will later hide behind an **"Advanced (for developers)"** toggle, and (b) import/export. There is **no whole-document raw-markdown editor** anymore.

## Reference images
- Problems to fix: `Downloads/Update/*.png`
- AppFlowy behaviors to copy: `Downloads/Update_2/*.png` (sidebar = `Screenshot (143).png`)
- Visual targets: `Downloads/Zielorya/*.png` — especially `Table view of tasks (2).png`, `Board_view_Plan_Adaptive.png`, `Opening a task from board-view.png`, `Notes Preview.png`.

## Starting state — already done, do NOT redo
- Tasks page views no longer cropped; calendar week/month horizontal swipe with month roll-over; task detail shows a grouped **"Main properties"** card with popup editors; global hamburger hides when task detail is open (`taskDetailOpen` in `NorfoldAppRoot.kt`). Build on this.

---

## Area 0 — Block-model editor (FOUNDATION — build and stabilize this FIRST)
Everything else is a block type or a renderer hanging off this. If it isn't built first, the rest gets redone.

### 0.1 Single source of truth = a typed block tree
Notes are **no longer markdown strings.** A note is `Document = List<Block>`. Markdown becomes an import/export *format*, never the storage.

```
Block (sealed):
  Paragraph, Heading(level), BulletList, NumberedList, TodoList, Quote, Callout,
  Divider, CodeBlock(lang), Table,
  Image(src, caption, layout),        // "chart as image" flattens here; non-editable
  FileBlock(name, mime, size, uri),
  Embed(url, cachedMeta{title,desc,faviconPath}),
  Chart(spec: VegaLiteSpec),          // the visual builder's serialized form
  Math(tex, display), Mermaid(code)
Inline: Text, Bold, Italic, Strikethrough, InlineCode, Link, Emoji, InlineMath, Tag/Mention
```

### 0.2 Storage migration
Replace the markdown-string note field with **serialized block JSON** (Room schema migration + version bump). On first launch, **auto-convert existing markdown notes → block trees** using the parser in 0.6. **Do NOT keep a raw-markdown fallback field** — the block tree is the sole representation after migration.

### 0.3 One surface, not Page + Preview
Collapse the two modes into a single document surface:
- **Default = View (rendered) mode.**
- **Double-tap anywhere on the page → Edit mode** for the whole document; tap outside / back gesture → return to View. (Global double-tap is the chosen interaction — not per-block tap.)
- Both modes render from the **same block list** via one shared contract, so View and Edit **cannot drift**:
  ```kotlin
  @Composable fun RenderBlock(block: Block, mode: View | Edit)
  ```
  File blocks, embed cards, images, and the per-embed toolbar live in shared block chrome, identical in both modes.

### 0.4 Rendering strategy (hybrid)
- **Structural blocks** (paragraph, heading, lists, quote, callout, table, file block, embed card, image, divider) → **native Compose**. This is what delivers the 100% AppFlowy screenshot match and true editability.
- **Engine blocks** (Math, Mermaid, Chart) → each is a **small self-sizing WebView *island*** embedded as one block, shared by View and Edit. **Stop letting one giant WebView own the whole document.** Lazily mount islands near the viewport and recycle them so long notes stay light.

### 0.5 Editor mechanics (block editing)
- Slash `/` menu is the **primary insert model** for every block type (heading, lists, table, file, image, chart, math, mermaid, embed, callout, divider).
- **Enter** splits a block; **Backspace at block start** merges into the previous block; selection may span blocks.
- Left-edge block handle `⠿`: **drag to reorder**, click for **duplicate / delete / turn-into**.
- **Undo/redo operates on block operations** (insert/delete/move/edit), not keystrokes.
- **Auto-save:** debounced (~500ms after last edit) persist of the block tree, per-block dirty flags so only changed blocks are written. No save button.

### 0.6 Parser
Pin **`org.intellij.markdown`** (JetBrains, pure-Kotlin, GFM flavor). Use it only to parse **markdown → AST → map to our Block model** (import/paste) and to serialize **blocks → markdown** (export/copy). Do **not** hand-roll inline markdown parsing. Own the block schema; borrow the inline tokenizer.

### 0.7 Search/indexing
Search now runs over **text extracted from the block tree**, not a raw markdown string. Update the indexer accordingly.

### 0.8 Definition of Done — HARD GATE (do not start Area 0.9 or later until ALL pass)
**Area 0 is NOT complete until every item below is demonstrably true.** Cross-block editing and the migration are where block editors usually break — treat any failure here as blocking, not a "fix later." Where a case is testable, write an instrumented/unit test for it and keep it green.

**Model & storage**
- [ ] A note round-trips losslessly: block tree → JSON → Room → reload → identical block tree (add a test).
- [ ] Migration converts a corpus of real existing markdown notes (headings, nested lists, tables, code fences, links, images) into correct blocks with **zero data loss**; run it on a copy of actual seeded/demo notes, not just toy input.
- [ ] Export blocks → markdown → re-import produces an equivalent tree (round-trip stable).

**Cross-block editing (the hard part — verify each by hand AND with a test)**
- [ ] **Enter** in the middle of a paragraph splits it into two blocks; text before stays, text after moves to the new block; cursor lands at the start of the new block.
- [ ] **Enter** at the end of a block creates an empty block below with the cursor in it.
- [ ] **Backspace at offset 0** of a block merges it into the previous block; cursor sits exactly at the former join point; block types resolve sensibly (e.g. empty list item → paragraph, then merges).
- [ ] **Backspace at offset 0 of the first block** is a no-op (no crash, no lost block).
- [ ] Selecting across **two or more blocks** and typing/deleting replaces the whole selection correctly and leaves one consistent block structure.
- [ ] Splitting/merging preserves **inline formatting** (bold/italic/link spans don't get dropped or duplicated at the boundary).
- [ ] List semantics: Enter in a list makes a new item; Enter on an empty item exits the list to a paragraph.

**Interaction, autosave, undo**
- [ ] Double-tap enters Edit; tapping outside / back gesture returns to View; **View and Edit show byte-identical structure** (no drift) for the same note.
- [ ] Autosave persists within ~500ms of the last edit with **no save button**; killing the app after edits and reopening shows the latest state.
- [ ] Only changed blocks are written (per-block dirty flags verified — e.g. editing one block in a 50-block note doesn't rewrite all 50).
- [ ] **Undo/redo** reverses and reapplies each of: insert block, delete block, move/reorder block, edit block text, split, merge — as discrete AST operations, in correct order, without corrupting the tree.

**Blocks & robustness**
- [ ] Slash `/` inserts every block type; `⠿` handle drags to reorder and offers duplicate/delete/turn-into.
- [ ] A document with 200+ blocks including several engine islands (math/mermaid/chart) scrolls smoothly; islands lazily mount near the viewport and are recycled (no jank, no OOM).
- [ ] No crash on: empty document, document of a single empty paragraph, deleting the last remaining block (auto-replaces with one empty paragraph), rapid Enter/Backspace mashing.

**Sign-off:** Area 0 is done only when the above pass on a real device/emulator AND the automated tests for round-trip, migration, split, and merge are green. Report the checklist status explicitly before moving to Area 0.9.

---

## Area 0.9 — Smart paste & auto-import (versatility feature)
The app should turn pasted content into visual blocks automatically — this is a headline feature, not just migration plumbing.

- **Paste markdown → real blocks.** Pasting markdown text parses (via 0.6) into the proper block tree (headings, lists, tables, code, etc.), not a plain paragraph.
- **Paste a fenced code block → the right engine block.** ```` ```mermaid ```` → Mermaid block, math → Math block, a chart spec → Chart block, other languages → CodeBlock.
- **Language auto-detection** for pasted/unlabeled code fences (detect the language and set `CodeBlock.lang`; route mermaid/math/chart to their engine blocks).
- **Chat-app wrapper handling.** LLM/chat replies are often the *entire message* wrapped in an outer ```` ```markdown … ``` ```` (or ```` ```md ````) fence. Detect this pattern and **unwrap the outer fence**, then parse the inner content as markdown into blocks — instead of showing one giant code block. Handle nested/mismatched fences gracefully.

---

## Area 1 — Rich engine-block rendering
Files: `ui/components/MarkdownWebView.kt` (now the per-island renderer), assets under `apps/android/src/main/assets/preview/` (`marked.min.js`, `mermaid.min.js`, `tex-svg.js`), engine-block composables.

1.1 **Math renders raw** — the `window.MathJax` delimiter config uses a `$d` placeholder + escaped `\(` / `\[` that are malformed after Kotlin string-templating + `trimIndent`. Rewrite it as valid runtime JS typesetting via `tex-svg.js`. Support `$…$`, `$$…$$`, `\(…\)`, `\[…\]`, `\frac`, `\sum`, `\int`, `bmatrix`, `cases`, `aligned`/`align`, `\mathbb`, `\vec`, `\tag`, `\newcommand`. Typeset **after** mermaid runs.
1.2 **Mermaid** — ensure `.mermaid` divs get `mermaid.run()` after DOM insert; on parse failure fall back to raw code in `<pre>`, don't blank.
1.3 **Emoji shortcodes** — `:rocket:` → Unicode via the **full ~1800 GitHub shortcode set** bundled as an offline JSON asset; skip inside code.
1.4 **Per-embed toolbar + horizontal scroll** — above every image / chart / mermaid / math / code / table block: **Hide-Show, Full-screen, Landscape** button row; wide embeds get a consistent horizontal-scroll container for thin phone screens.
1.5 **Rich link/embed cards with site favicon** (AppFlowy-style) in the single surface: a bare URL → inline card with title, description, favicon. **Fetch favicons over the network and cache to a host-keyed disk cache**; bundled generic icon as offline fallback (offline is supported, not required). Reuse the file-attachment card style.
1.6 **WhatsApp-style live emoji in Edit mode** — `:-)` → 🙂 inline; single **Backspace reverts to text**; offset/cursor-safe mid-line; also live-expand `:shortcode:`.

---

## Area 1.5 — Visual chart / graph / plot builder
Files: `ui/screens/EditorScreen.kt` (slash menu), a new `ui/components/ChartBuilderSheet.kt`, chart island renderer.

- Slash commands **`/chart` `/plot` `/graph` `/histogram`** (+ aliases `/draw-graph`, `/plot-something`) open a **visual bottom-sheet builder**: chart type (bar, line, pie, scatter, histogram, area, multi-series…), a small editable **data grid** (add/edit/delete rows), axis labels, title, legend, colors (default from theme).
- Confirm → user chooses placement:
  1. **As image** — flatten to a static `Image` block, non-editable afterward.
  2. **As code** — insert a **Chart block** whose serialized **Vega-Lite** spec re-hydrates the builder when reopened, so it stays editable from the page.
- Chart blocks render as real charts in the single surface via the bundled JS renderer, with the 1.4 toolbar + horizontal scroll.
- **Pin the chart spec format to Vega-Lite** (most capable — real histograms, scatter, multi-series). The builder is the primary editor; the Vega-Lite spec is just its serialized form and will later hide behind the Advanced toggle.

---

## Area 2 — AppFlowy tables, `#tag` wiring, demo content
Files: `ui/tasks/TasksBoardScreen.kt`, `data/NotesRepository.kt`, tag entities/DAO.

2.1 **Tasks Table view** — match `Table view of tasks (2).png` exactly: columns Name, Status + Tags, Checklist %, Due, Notes, Files, Priority + Assignee; each cell opens the shared popup editors. Give **markdown/table blocks** the same AppFlowy grid look (header shading, cell borders, row hover).
2.2 **`#tag`** — search-or-create popover on `#`: filter existing, create on the fly, **unique per board (case-insensitive, `#` stripped)**, colored pills; back with existing `TagEntity` / `getOrCreateTag` / `setTags`; Tasks board scope `board_view_plan_adaptive`.
2.3 **Demo content — a detailed in-app guide.** Seed (first-run / empty-DB guard like `applyWorkspaceTemplate`) a rich **"Norfold Guide"** notebook + demo Board/Table/Calendar that doubles as onboarding and **exercises every feature**: block editing, slash menu, math, mermaid, a Vega-Lite chart, emoji (shortcodes + live), embed cards, tables, tags, file blocks, and smart-paste examples. It should read like a real product tour, not lorem ipsum.

---

## Area 3 — Nested "Study Hub" sidebar
Files: `ui/screens/SidebarScreen.kt`, `NorfoldAppRoot.kt`, `WorkspaceEntity`.

Match `Update_2/Screenshot (143).png` 100%:
- Workspace switcher showing **workspace logo/icon + name** (from `WorkspaceEntity` icon/palette).
- Search + New page row; quick items (Inbox / Today / Upcoming / Favorites).
- A **collapsible, nested tree** — pages inside pages (a database node expands to Tasks / Board / Calendar / Notes / Resources; a "Subjects" node holds nested subject pages). Nesting is the core ask.
- Lower section: Notes / Books / Archive / Trash, then the account row.

---

## Acceptance
- Notes are stored as block trees; existing markdown auto-migrated; no whole-document raw editor remains.
- One surface: View by default, double-tap → Edit, autosaved; View and Edit render from the same blocks and never drift.
- Smart paste turns markdown / fenced code / chat-app ```` ```markdown ```` -wrapped replies into proper visual blocks with language auto-detection.
- Math, mermaid, emoji (shortcodes + WhatsApp-style), embed cards with cached favicons, and the Vega-Lite chart builder all render with the per-block toolbar + horizontal scroll.
- Tasks Table, markdown tables, and `#tag` pills match the AppFlowy screenshots; nested sidebar matches `Screenshot (143).png`.
- The seeded "Norfold Guide" demonstrates every feature on first run.
- Every reference screenshot is reproduced 1:1 before any "fix what it broke" cleanup.

**Order of work: Area 0 → 0.9 → 1 → 1.5 → 2 → 3.** Stabilize the block model before anything renders on top of it.
