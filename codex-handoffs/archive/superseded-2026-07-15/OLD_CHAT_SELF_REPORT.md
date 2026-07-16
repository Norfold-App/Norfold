# Old Chat Self-Report

This is a best-effort summary of work completed or changed during the previous long Codex session. The checkpoint commit also preserves any overlapping user edits that were already present in the dirty worktree.

- `apps/android/src/main/java/com/norfold/app/domain/BlockDocument.kt` - Added the typed note block tree, inline node types, and JSON serialization model.
- `apps/android/src/main/java/com/norfold/app/domain/BlockEditorSession.kt` - Added block-level split, merge, selection replacement, reordering, dirty tracking, and undo/redo operations.
- `apps/android/src/main/java/com/norfold/app/domain/MarkdownBlockCodec.kt` - Added JetBrains Markdown import/export mapping between Markdown and the typed block document.
- `apps/android/src/main/java/com/norfold/app/domain/SmartPasteCodec.kt` - Added structured paste handling for Markdown, wrapped chat replies, code, Mermaid, Math, and Vega-Lite content.
- `apps/android/src/main/java/com/norfold/app/domain/ChartSpecCodec.kt` - Added editable visual-chart state and Vega-Lite encoding/decoding.
- `apps/android/src/main/java/com/norfold/app/domain/Models.kt` - Changed notes to expose block documents as their authoritative content while retaining generated Markdown for interchange.
- `apps/android/src/main/java/com/norfold/app/domain/BackupCodec.kt` - Updated backup serialization for the revised Norfold models and task data.
- `apps/android/src/main/java/com/norfold/app/data/Entities.kt` - Added persisted note block rows, board-scoped tag identity, and related schema fields.
- `apps/android/src/main/java/com/norfold/app/data/NorfoldDatabase.kt` - Added Room migrations through schema 28, including Markdown-to-block conversion and board-scoped tag normalization.
- `apps/android/src/main/java/com/norfold/app/data/NotesDao.kt` - Added block-row persistence, focused updates, and revised search/tag queries.
- `apps/android/src/main/java/com/norfold/app/data/NotesRepository.kt` - Wired block documents, per-block saves, demo guide seeding, task properties, tags, history, backup, and restore flows.
- `apps/android/src/main/java/com/norfold/app/ui/screens/BlockNoteEditorScreen.kt` - Replaced the old page/source editor with one rendered block surface supporting view/edit, slash insertion, native blocks, engine blocks, and autosave.
- `apps/android/src/main/java/com/norfold/app/ui/components/MarkdownWebView.kt` - Reworked MathJax, Mermaid, Vega-Lite, emoji, sizing, touch handoff, and theme-aware rendering for self-sizing engine islands.
- `apps/android/src/main/java/com/norfold/app/ui/components/ChartBuilderSheet.kt` - Added the scrollable visual chart builder with editable data, labels, chart types, preview, and insertion choices.
- `apps/android/src/main/java/com/norfold/app/ui/components/EmbedMetadataResolver.kt` - Added link metadata and host-keyed favicon resolution/caching with an offline fallback.
- `apps/android/src/main/java/com/norfold/app/ui/tasks/TaskModels.kt` - Standardized the production Kanban interaction on `BoardPointer` and expanded task-view state.
- `apps/android/src/main/java/com/norfold/app/ui/tasks/TasksBoardScreen.kt` - Rebuilt the task table, rich board cards, task properties, tags, controls, and adaptive task surfaces.
- `apps/android/src/main/java/com/norfold/app/ui/screens/PlanningScreens.kt` - Added/repaired adaptive task calendar paging and date-oriented task rendering.
- `apps/android/src/main/java/com/norfold/app/ui/screens/SidebarScreen.kt` - Reworked the workspace-first nested sidebar and its note/task navigation structure.
- `apps/android/src/main/java/com/norfold/app/ui/screens/OnboardingScreen.kt` - Added the multi-stage Norfold onboarding and persisted setup flow.
- `apps/android/src/main/java/com/norfold/app/ui/NorfoldAppRoot.kt` - Updated adaptive navigation, editor routing, task-detail behavior, and destination transitions.
- `apps/android/src/main/java/com/norfold/app/ui/NorfoldTheme.kt` - Consolidated light/dark Norfold theme behavior and configurable appearance tokens.
- `apps/android/src/main/java/com/norfold/app/ui/SemanticColors.kt` - Added theme-derived semantic colors for status and data visualization instead of fixed UI hues.
- `apps/android/src/main/java/com/norfold/app/ui/screens/SettingsScreen.kt` - Reorganized settings, workspace/account restore surfaces, editor preferences, and changelog access.
- `apps/android/src/main/java/com/norfold/app/ui/screens/WorkspaceHubScreens.kt` - Revised the workspace hub/dashboard composition and live workspace summaries.
- `apps/android/src/main/assets/preview/` - Bundled offline Mermaid, MathJax, Vega, Vega-Lite, Vega Embed, and 1,913 emoji shortcode assets.
- `apps/android/schemas/com.norfold.app.data.NorfoldDatabase/26.json` - Captured the Room schema introducing block storage.
- `apps/android/schemas/com.norfold.app.data.NorfoldDatabase/27.json` - Captured the intermediate Room schema used by the editor/settings migration.
- `apps/android/schemas/com.norfold.app.data.NorfoldDatabase/28.json` - Captured the Room schema with case-insensitive board-scoped tags.
- `apps/android/src/test/java/com/norfold/app/domain/BlockDocumentFoundationTest.kt` - Added block round-trip, editing, undo/redo, smart paste, emoji, list, and stress-document tests.
- `apps/android/src/androidTest/java/com/norfold/app/data/BlockDocumentMigrationTest.kt` - Added on-device migration coverage for block storage and tag schema changes.
- `apps/android/src/androidTest/java/com/norfold/app/data/BlockDocumentRoomTest.kt` - Added on-device Room round-trip, changed-block write, guide seeding, and tag-isolation tests.
- `apps/android/src/androidTest/java/com/norfold/app/domain/MarkdownCodecAndroidCompatibilityTest.kt` - Added Android-runtime coverage for Markdown and LaTeX detection.
- `docs/` - Updated the Norfold GitHub Pages product, legal, support, download, changelog, service-setup, and UI goal documentation.
- `.github/workflows/build.yml` - Updated CI to use the repository Gradle wrapper and current Android build flow.
- `.github/workflows/pages.yml` - Removed the competing Pages workflow so branch-based `main:/docs` deployment remains authoritative.
- `supabase/config.toml` - Updated local Supabase callbacks and Norfold development configuration.
- `codex-handoffs/` - Added the master run order, per-feature implementation prompts, acceptance fixture, and ownership rules for subsequent work.

## Verification Reached

- `./gradlew :apps:android:testDebugUnitTest :apps:android:assembleDebug :apps:android:assembleDebugAndroidTest` completed successfully.
- The debug and instrumentation APKs installed on `emulator-5554`.
- Android instrumentation completed with `OK (11 tests)`.
- Light and dark renderer checks covered Math, Mermaid, Vega-Lite charts, native code blocks, task table rendering, and editor scrolling.
