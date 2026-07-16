# Job 09 — Adopt the new brand glyph as adaptive launcher icon + in-app logo

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 21).** Standalone — shares no code file with other prompts; may run anytime. Uses the staged `brand/` glyph assets as the single source of truth. Satisfy the universal Definition-of-Done GATE before declaring done.

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Do it fully and exactly. No stubs.

## House rules
- Theme tokens only in UI. Light + Dark both correct.

## Source assets (use these — staged, already in the repo)
The user chose the **staged brand glyphs** as the master:
- `brand/norfold-glyph.png` — black glyph on transparent (with the green accent dot).
- `brand/norfold-glyph-white.png` — white recolor for dark surfaces (green dot kept).
- `brand/norfold-glyph-small.png`, `brand/norfold-icon-tile.png`, `brand/norfold-lockup.png`.
- Web copies exist under `docs/assets/`.

## Current state
- Launcher icon is **adaptive-only** (no PNG raster; `mipmap-*dpi` dirs are empty). `AndroidManifest.xml:11/14` → `@mipmap/ic_launcher(_round)`; `res/mipmap-anydpi-v26/ic_launcher.xml` references `foreground=@drawable/norfold_icon_foreground`, `background=@drawable/ic_launcher_background` (+ `drawable-night/`), `monochrome=@drawable/norfold_icon_monochrome`.
- In-app "N" mark: `branding/AnimatedLogo.kt:22-44` (`AnimatedNorfoldLogo`) is just `Text("N")` on a gradient tile — not a real drawable. (User confirmed Codex is done editing this file — safe to change.)
- Notification glyph: `res/drawable/ic_norfold_notification.xml`.

## Goal
### 1. Adaptive launcher icon from the glyph
- Produce a proper **adaptive icon foreground** from the staged glyph:
  - Convert `brand/norfold-glyph.png` (or the tile) into the foreground layer. Best: a vector `norfold_icon_foreground.xml`; if the glyph can't be cleanly vectorized, place correctly-sized raster foregrounds in `mipmap-mdpi…xxxhdpi` and reference them — do not leave the raster dirs empty if you go raster.
  - Respect the adaptive-icon **safe zone** (glyph within the inner ~66dp of the 108dp canvas) so launcher masking doesn't clip it.
  - Keep/refresh `norfold_icon_monochrome` for themed icons (Android 13+), derived from the glyph silhouette.
  - Background layer: keep the branded background (`ic_launcher_background` + `drawable-night`) consistent with the glyph; ensure contrast in both.
- Verify round + square + themed + monochrome masks all look right.

### 2. In-app logo backed by the glyph
- Replace the `Text("N")` in `AnimatedLogo.kt` with the actual glyph drawable so the in-app mark matches the launcher. Use **`norfold-glyph-white.png` on dark surfaces** and the black glyph on light (the source is black-on-transparent), driven by theme — do not hardcode; pick by `isSystemInDarkTheme()` / color scheme.
- Keep any existing animation wrapper; just swap the content from text to the glyph image. Ensure it scales crisply at the sizes it's used (onboarding, headers, empty states).

### 3. Consistency sweep
- Point other in-app brand marks (empty-state logos, onboarding, notification glyph if it differs from the new mark) at the same source so the identity is uniform. Flag any place still drawing an old/ad-hoc "N".

## Constraints
- Use the staged `brand/` assets as the single source of truth; don't invent a new logo.
- Light/dark variants chosen at runtime, not hardcoded.
- Don't break the manifest icon references or the build.

## Definition of Done
- [ ] Adaptive launcher icon renders the glyph correctly across round/square/themed/monochrome masks, within the safe zone; no empty raster dirs if raster is used.
- [ ] In-app `AnimatedLogo` shows the real glyph (white on dark, black on light by theme), not `Text("N")`.
- [ ] Other brand marks point at the same source; no stray old "N".
- [ ] Builds/installs clean; icon looks right on device in Light + Dark.
