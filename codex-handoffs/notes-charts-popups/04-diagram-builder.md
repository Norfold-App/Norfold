# Codex Task 04 — Diagram builder (make Mermaid diagrams as easy as charts)

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 10).** Runs after `01` (Mermaid must render first). Adds a new `DiagramBuilderSheet.kt` + a Mermaid insert path in `BlockNoteEditorScreen.kt`. Satisfy the universal Definition-of-Done GATE before declaring done.

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Do this fully. Test on the emulator.

> Do **Task 01 first** (Mermaid must actually render before a builder is useful).

## House rules
- Theme tokens only; Light + Dark correct.
- Reuse the existing `MermaidBlock` + WebView renderer. No schema changes needed (Mermaid stores raw `code`).
- Compile clean.

## Why
Charts have a friendly interactive builder (`ChartBuilderSheet`), but **diagrams (Mermaid) have none** — the user must type raw `graph TD` syntax into a monospace field, which is not user-friendly. The user explicitly wants "Graph, Charts, **Diagram**" all easy to generate. This task gives diagrams a guided builder.

## Files
- `ui/screens/BlockNoteEditorScreen.kt` — `MermaidBlock` dispatch (rendered via `EditableEngineCard`); insert flow (Chart special-cases opening a sheet at ~342–345 — mirror that pattern for Mermaid).
- New file: `ui/components/DiagramBuilderSheet.kt` (mirror `ChartBuilderSheet.kt`'s structure/styling).
- `domain/BlockDocument.kt` — `MermaidBlock` (~137–140), default `"graph TD\n A[Start] --> B[Done]"`.

## What to build — a guided Diagram builder (`ModalBottomSheet`)
Mirror the chart builder's UX. It does NOT need to be a full visual graph editor — a **template + form + live preview** is the target:

1. **Diagram-type chips** (horizontally scrollable): **Flowchart, Sequence, Class, State, Pie, Gantt, Mindmap** (offer the types this Mermaid build actually supports; ones it can't render should not be offered, or should warn).
2. **Live preview** — reuse the same Mermaid WebView render path so the user sees the real diagram update as they edit.
3. **Guided inputs per type** (keep it simple):
   - **Flowchart:** a list of **nodes** (id + label) and **edges** (from → to + optional label + direction), plus a direction toggle (TD/LR). Generate the `graph` syntax from the form.
   - **Sequence:** a list of **participants** and **messages** (from → to + text + solid/dashed). Generate `sequenceDiagram`.
   - For the other types, a **starter template** the user edits (see delta 5) is acceptable for v1.
4. **"Advanced source" toggle** — like the chart builder, expose the raw Mermaid text for power users; edits there sync back.
5. **Template picker** — a small gallery of ready-made starter diagrams per type (so a user can start from a working example, not a blank field). Selecting one fills the form + source.
6. **Entry points:** open this sheet from the `/`-insert "Diagram/Mermaid" item (and typing `diagram`, `flowchart`, `mermaid`, `sequence`), the same way Chart opens `ChartBuilderSheet`. Editing an existing `MermaidBlock` reopens the sheet seeded from its code.
7. **Commit** writes a `MermaidBlock(code = generatedMermaid)`.

## Constraints
- Generated Mermaid must be valid for the bundled mermaid version (test each offered type actually renders — Task 01's fallback covers failures, but the builder should only offer types that work).
- Keep raw-source editing available; form and source stay in sync.
- Match `ChartBuilderSheet` styling so the two builders feel like siblings.

## Definition of Done
- [ ] `/`-insert "Diagram" (and keyword matches) opens the diagram builder, not a blank raw-text block.
- [ ] Flowchart + Sequence have working guided forms that generate valid Mermaid; other offered types have working starter templates.
- [ ] Live preview shows the real diagram updating as the user edits.
- [ ] Advanced-source toggle works and stays in sync with the form.
- [ ] Editing an existing diagram reopens the builder seeded from its code.
- [ ] Every offered diagram type renders on the emulator.
- [ ] Builds clean; Light + Dark correct.
