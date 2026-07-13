# Job 08 — Render cache + re-render controls for the engine (cross-cutting)

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 13).** Do NOT start until `../notes-charts-popups/01-renderer-engine-fixes.md` and `02-markdown-full-coverage.md` are merged. You **wrap** their render logic with a cache — do NOT rewrite or remove their per-renderer try/catch. Jobs 03 and 04 depend on this cache. Satisfy the universal Definition-of-Done GATE before declaring done.

> Do this **before** Job 04 and before the `notes-charts-popups` renderer work if runs overlap — those depend on the cache.

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Do it fully and exactly. No stubs.

## Context
The heavy renderer is the WebView `MarkdownPreview` (`ui/components/MarkdownWebView.kt:29`, `buildHtml` ~105) used for code/math/chart/mermaid engine blocks and note/task previews. Every mount re-runs marked.js + MathJax + mermaid/vega from scratch, so previews feel slow and flicker ("Rendering…") on every open. The user wants:
- **Cache once rendered** so re-previewing the same content is instant.
- **Auto re-render when the source is edited.**
- **A manual "render again" button** on a block/preview.
- **A comfortable "re-render all" button** somewhere sensible.

## Goal
### 1. Render cache
- Introduce a render cache keyed by a **stable hash of (engine type + source + theme mode + relevant render options)**. Value = the rendered artifact the WebView produces (rendered HTML/SVG, or a snapshot bitmap if that's what's displayed — pick what `MarkdownPreview` can restore cheaply).
- On mount, if the key hits, show the cached result immediately (no "Rendering…" flash). On miss, render and populate.
- Cache scope: in-memory LRU at minimum (bounded, e.g. by count/size). Persisting across app launches is a bonus, not required — if you persist, invalidate on app/theme/asset version change.
- **Invalidate the entry when the source changes** (hash changes ⇒ new key ⇒ re-render). Theme switch (Light/Dark) is part of the key so both variants can coexist.

### 2. Auto re-render on edit
- When an engine block's source is edited, it re-renders automatically (debounced), replacing its cache entry. No manual step needed for the common case.

### 3. Manual controls
- **Per-block "render again"** affordance (small icon button on the engine card / preview) that forces a re-render and refreshes the cache entry — for when a render got stuck or an external asset changed.
- **"Re-render all"** action placed somewhere comfortable and discoverable (e.g. an overflow menu in the note editor top bar, and/or the Tasks chart view header). It clears the cache and re-renders visible engine content. Don't hide it deep; don't make it a scary primary button either.

## Constraints
- The cache must not leak memory (bounded LRU).
- Must not break existing per-renderer error handling from the `notes-charts-popups` batch (`01-renderer-engine-fixes.md`) — coordinate: caching wraps the render, it doesn't replace the try/catch.
- Theme tokens only for the buttons; Light + Dark correct.

## Definition of Done
- [ ] A bounded render cache keyed by content+engine+theme; hits render instantly with no "Rendering…" flash.
- [ ] Editing source auto-re-renders (debounced) and updates the cache.
- [ ] Per-block "render again" button forces a refresh.
- [ ] A discoverable "re-render all" action exists in a comfortable location.
- [ ] No memory leak; existing engine error handling intact; builds clean; Light + Dark correct.
