# Codex Task 03 — Fix the Chart Builder (scroll, preview, title+caption, per-item color, TEST it)

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 9).** You own `ChartBuilderSheet.kt` + `ChartSpecCodec.kt`. `../tasks-notes-overhaul/04` (the Tasks Chart view, later) **reuses this exact engine/codec** — get the codec round-trip solid so it can. Satisfy the universal Definition-of-Done GATE before declaring done.

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Do this fully and **actually test every chart type on the emulator** — the current builder is essentially untested. Do not declare done from reading code.

## House rules
- Theme tokens only; Light + Dark correct.
- Reuse the existing codec. You MAY add fields to the builder model + `norfold` metadata block.
- Compile clean.

## Files
- `ui/components/ChartBuilderSheet.kt` (the `ModalBottomSheet` builder, ~71–160; `VisualChartComposer` live preview ~162–246; data grid ~110–121; legend ~122–124; color ~125–129; placement ~130–136; `Create` ~139–155; `renderChartImage` ~248–294)
- `domain/ChartSpecCodec.kt` (`encode` ~52–78, `decode` ~80–118, per-type ~120–154, `ChartType` enum ~18–25; builder metadata stashed under a `"norfold"` key)
- `ui/screens/BlockNoteEditorScreen.kt` (`EditableChartBlock` ~800–827 renders the stored chart via WebView vega-embed; entry points ~337–345, insert match ~1582)

## The problems (observed on device — see the two builder screenshots)
1. **The sheet does not scroll.** The bottom controls — the **"As image" / "As editable chart"** radios — are **cut off** below the fold and unreachable. The whole sheet content must scroll vertically.
2. **The data grid does not scroll.** It's a fixed ~210dp box and the **"Series" column is clipped off the right edge**. Data rows must scroll (vertical for many rows, horizontal so Series isn't clipped) — or better, redesign the row so all fields fit without horizontal clipping.
3. **Not a proper preview.** The live preview doesn't reflect what the final rendered chart looks like (title/caption/legend/colors). Make the preview an accurate representation of the committed chart.
4. **Title and Caption are not shown** — neither visually in the preview NOR in the final rendered chart. There is **no Caption field at all**. Add a **Caption** field, and make **Title + Caption render** both in the builder preview and in the committed/rendered chart block.
5. **Color picker is global, not per-item.** The 7 swatches currently recolor the **entire chart**. The user needs to **define the color of each item/data row individually** (each pie slice / bar / point its own color). Keep an optional global/default palette, but every data row must have its own color control.

## Deltas
1. **Make the sheet scrollable** (wrap the content in a scroll container / `LazyColumn`) so every control including the placement radios is reachable on all screen sizes.
2. **Fix the data grid**: make rows scroll and ensure the Series field is never clipped. Consider a per-row layout that wraps (Label / Value on row 1, Series / Color on row 2) so nothing clips on narrow screens. Add a clear per-row **Delete** and keep **"+ Add row"**.
3. **Add per-row color**: each data row gets its own color swatch/picker; store it in the builder model and encode it into the Vega-Lite spec (per-datum color / scale range) so pie slices, bars, and points render in their assigned colors. Round-trip it through `decode` via the `norfold` metadata.
4. **Add a Caption field** and render **Title + Caption** in: (a) the builder live preview, and (b) the committed chart (in `EditableChartBlock` / the Vega spec `title`+ a caption line below). Persist caption in the `norfold` metadata so it round-trips on "Edit chart".
5. **Make the preview accurate** — it must show title, caption, legend on/off, and per-item colors exactly as the committed chart will.
6. **Test every chart type end to end**: Bar, Line, Pie, Scatter, Histogram, Area — for each: create → see correct live preview → commit as editable chart → verify it renders correctly in the note → reopen "Edit chart" and confirm all fields (title, caption, axes, rows, per-row colors, legend) round-trip. Also verify the **"As image"** path (`renderChartImage`) produces a correct PNG including title/caption/colors.

## Constraints
- Don't break the existing Vega-Lite round-trip; extend it. Keep the "Advanced source" JSON toggle working.
- Per-item colors and caption must survive save/reload (persisted in the spec, not just in-memory).

## Definition of Done
- [ ] Entire sheet scrolls; the As-image/As-editable radios are always reachable.
- [ ] Data rows scroll; Series field never clipped; per-row Delete + Add row work.
- [ ] Each data row has its own color, and that color shows in preview AND rendered chart (slices/bars/points).
- [ ] Title + Caption fields exist and render in both preview and committed chart; both round-trip on edit.
- [ ] Preview accurately matches the committed chart.
- [ ] All 6 chart types verified create→render→edit→round-trip on the emulator; "As image" export verified.
- [ ] Builds clean; Light + Dark correct.
