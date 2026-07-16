# Deferred to the Settings-page work phase (do NOT build here — reference only)

The user will do a dedicated Settings-page pass **after** this Tasks/Notes overhaul. These prompts must **not hardcode** the following — read each from a settings value with a sensible default, so the settings pass only has to add the UI:

1. **Task swipe actions** — start-action / end-action per task row. Mirror the note swipe model already in the app:
   - `settings.noteSwipeStartAction` / `noteSwipeEndAction` (see `NotesViewModel.kt` ~962, `SettingsScreen.kt` ~619–621).
   - Add analogous `taskSwipeStartAction` / `taskSwipeEndAction` settings keys now (default: end = Delete, start = cycle/complete status). Prompt `02` wires the behavior; the settings UI comes later.
2. **Note-render engine mode** — a tri-state: `Auto` (choose WebView vs native by device hardware capability), `Native` (lightweight Compose), `WebView` (full MathJax). Default `Auto`. Prompt `03` reads this; do not hardcode a single renderer.
3. **Dashboard** configuration — deferred.
4. **Note-list page** configuration — deferred.
5. **Navbar** configuration — deferred.

If you add a settings key referenced above, add it to the settings data model + persistence **with a default**, but you do NOT need to build its settings-screen control in this batch.
