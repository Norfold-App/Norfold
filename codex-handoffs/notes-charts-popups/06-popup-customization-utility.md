# Codex Task 06 — App-wide Popup Customization Utility (Nova-launcher-style)

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 12).** You create the shared popup wrappers (`NorfoldDialog`/`NorfoldBottomSheet`/`NorfoldFullscreenDialog` + `LocalPopupStyle`). `../tasks-notes-overhaul/06` (rail redesign) **consumes these wrappers** — run this before it. Satisfy the universal Definition-of-Done GATE before declaring done.

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). This is a **large, two-phase** task: first **centralize** all popups behind one wrapper, then build a **settings screen** that lets the user customize popup look/behavior app-wide. Do both. Test on the emulator.

## House rules
- Theme tokens only, never hardcode hues. Light + Dark correct.
- Persist settings through the existing settings mechanism (see below). No throwaway state.
- Compile clean.

## Why this is two phases
Popups today are **fully decentralized** — ~20 hand-rolled `AlertDialog` / `ModalBottomSheet` / `Dialog` call sites, no shared component (only two thin settings-only helpers: `EditFieldDialog` / `OptionPickerDialog` in `ui/components/SettingsKit.kt` ~187/~208). There is **no single choke point** to customize. So you must create one before any "customize popups" feature can exist.

---

## PHASE 1 — Centralize popups

### 1a. Create the wrappers + config
- New file `ui/components/NorfoldPopup.kt` (or similar) with:
  - **`NorfoldDialog(...)`** — wraps Material3 `AlertDialog`/`BasicAlertDialog`, applying a shared style.
  - **`NorfoldBottomSheet(...)`** — wraps `ModalBottomSheet`, applying shared style.
  - **`NorfoldFullscreenDialog(...)`** — wraps `Dialog(usePlatformDefaultWidth=false)` for fullscreen cases.
- A **`data class PopupStyle`** capturing the customizable properties (see Phase 2 list) and a **`CompositionLocal`**: `val LocalPopupStyle = compositionLocalOf { PopupStyle() }`. Provide it high in the tree (in `NorfoldTheme` or `NorfoldAppRoot`) from the persisted settings so every wrapper reads the current style.

### 1b. Migrate every ad-hoc popup to the wrappers
Replace these call sites (found in the codebase) with the new wrappers, preserving their current content/behavior:
- `AlertDialog(...)`: `WorkspaceVisualDialog.kt:86,184`, `NorfoldAppRoot.kt:230`, `WorkspaceHubScreens.kt:800`, `PlanningScreens.kt:545,551`, `SettingsScreen.kt:385,1047`, `TasksBoardScreen.kt:2233,2947,2971,2995,3007,3022,3410`.
- `ModalBottomSheet(...)`: `ChartBuilderSheet.kt:91`, plus sheets in `SettingsKit`, `PlanningScreens`, `WorkspaceHubScreens`, `WorkspaceVisualDialog`, `TasksBoardScreen`.
- `Dialog(...)`: `EngineFullscreenDialog` (`BlockNoteEditorScreen.kt:1106`).
- Re-implement `SettingsKit`'s `EditFieldDialog`/`OptionPickerDialog` on top of `NorfoldDialog` so they inherit the style too.

> Search the whole `ui/` tree for `AlertDialog(`, `ModalBottomSheet(`, `Dialog(` to make sure none are missed. Every popup in the app must go through a wrapper after this phase.

---

## PHASE 2 — The customization settings screen

### 2a. Customizable properties (put these in `PopupStyle` + settings)
Expose a sensible, Nova-launcher-style set:
- **Corner radius** (slider, e.g. 0–32dp)
- **Dialog width** (compact / comfortable / wide) and **max width**
- **Scrim/dim opacity** (slider)
- **Background blur** behind the popup (toggle; where supported)
- **Entry/exit animation** (fade / scale / slide-up) and **speed** (fast/normal/slow)
- **Position** for dialogs (center / bottom) and **bottom-sheet peek/expand** default
- **Dismiss on tap-outside** (toggle) and **dismiss on back** (toggle)
- **Elevation/shadow** (slider or on/off)
- **Accent tint** of the popup surface (follow theme accent vs neutral)

### 2b. Persist the settings
Add these fields to the existing settings model (the app stores settings via a Room-backed settings entity + `patchSettings { ... }` in the ViewModel — follow the same pattern used by e.g. `calendarDefaultView`, `taskViewMode`, `accentColor`). Add a DB migration column-add for each new field (nullable/defaulted, matching how other settings columns were added). `LocalPopupStyle` is provided from these persisted values.

### 2c. The settings UI
Add a **"Popups" / "Dialog & Popup Style"** section to `ui/screens/SettingsScreen.kt`:
- Controls for every property in 2a (sliders, switches, segmented choices).
- A **live "Preview popup" button** that opens a sample `NorfoldDialog` using the current (unsaved) settings so the user sees changes immediately.
- A **Reset to defaults** action.

## Constraints
- Migrating popups must not change their existing content or logic — only route them through the wrapper.
- Blur/animation must degrade gracefully on older APIs (guard blur behind version checks).
- Theme tokens only; the accent-tint option still uses `colorScheme`, not hardcoded hues.
- Every new settings field needs a DB migration; do not bump/replace the schema destructively.

## Definition of Done
- [ ] `NorfoldDialog` / `NorfoldBottomSheet` / `NorfoldFullscreenDialog` + `PopupStyle` + `LocalPopupStyle` exist and are provided from persisted settings.
- [ ] EVERY `AlertDialog`/`ModalBottomSheet`/`Dialog` in `ui/` is migrated to a wrapper (grep confirms no raw usages remain outside the wrapper file).
- [ ] All popups still work exactly as before, now styled by the config.
- [ ] Settings screen has a Popups section with controls for all properties in 2a, a live preview, and reset.
- [ ] Changing a setting visibly changes popups app-wide and persists across restart (DB migration verified).
- [ ] Builds clean; Light + Dark correct.
