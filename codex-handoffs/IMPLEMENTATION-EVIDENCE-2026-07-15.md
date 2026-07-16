# Document Model Implementation Evidence — 2026-07-15

**Verdict:** Implemented and dark-emulator-verified; not product-complete under the universal gate.

## Implemented

- Shared Flow document, bounded Document Canvas, and Infinite Canvas modes.
- Versioned canvas/page payload in the existing freeform-layout field, including legacy JSON decoding.
- A4/Letter/Legal presets, orientation swap, page add/remove, automatic minimum page count, and bounded move/resize.
- Clean canvas reading state; selection bounds and controls only when editing; tap-select → drag/resize → tap-enter interaction.
- Layer movement remains persisted and normalized.
- Exact-position bounded PDF print HTML using current unsaved session data and current page dimensions.
- Editable semantic DOCX export with XML escaping and a valid Office Open XML package.
- Unified sticky workspace/search sidebar with cross-object results and ToC preservation.
- Debug-only pre-beta destructive migration fallback; release/benchmark fallback disabled.
- Guarded, idempotent architecture/UI terminology codemod.

## Automated proof

- JDK: `/home/sheikh/.gradle/jdks/eclipse_adoptium-21-amd64-linux.2`
- `:apps:android:testDebugUnitTest :apps:android:assembleDebug` — success after final canvas selection-chrome fix.
- `:apps:android:assembleDebugAndroidTest` — success after the final automatic-page-count fix.
- Exact app/test APKs installed with Windows ADB; `AndroidJUnitRunner` reported `OK (12 tests)` in 3.219 seconds.
- Clean `:apps:android:assembleDebug` — success; all 41 tasks executed.
- Unit coverage includes legacy/versioned layout decoding, page-count calculation, backup canvas round trip, bounded-print escaping/placement, DOCX ZIP structure, and DOCX XML escaping.
- Codemod repeat dry-run: `files=0`.

## Android runtime proof

AVD: `Resizable_Experimental`, `emulator-5554`, 1080×2400. The APK was clean-installed once, then updated from the exact final debug output during iteration.

| Evidence | What it proves |
|---|---|
| `03-clean-header-flow.png` | Narrow-phone header keeps Back, workspace, title, Edit, and document kebab reachable. |
| `04-bounded-view.png` | Bounded canvas renders a clean reading state without per-block cages. |
| `06-bounded-selection-fixed.png` | Edit mode uses canvas selection/layer/resize chrome without inner flow-editor handles on every block. |
| `07-unified-sidebar-search.png` | Workspace identity and search share one sticky container above the document ToC. |
| `08-sidebar-search-results.png` | Typing replaces the sidebar body with live cross-object results. |
| `09-infinite-canvas-edit.png` | Infinite Canvas remains available and uses the same selection model without a page boundary. |
| `10-bounded-pdf-print-preview.png` | Android Print Spooler received and rendered the bounded export. |
| `11-auto-page-expansion-menu.png` | Re-entering bounded mode expanded the long fixture to four pages instead of clipping it. |
| `Rich blocks playground.docx` | Android create-document flow saved the generated DOCX; `unzip -t` reported no errors. |

ADB drag proof moved the selected heading bounds from `[63,308][882,495]` to `[63,350][882,537]`. DOCX export opened `DocumentsUI`, supplied `Rich blocks playground.docx`, saved to Downloads, was pulled back, and all four ZIP entries validated. The final bounded conversion calculated `4 pages`; Android Print Spooler then reported `Page 1 of 4` and `Page 2 of 4` in the visible preview hierarchy. Final logcat filtering found no Norfold fatal exception or Norfold ANR.

## Remaining gates

- Physical-device touch/IME/stylus checks.
- Light theme, large font, TalkBack/custom accessibility actions, Bengali/RTL, rotation, tablet/foldable.
- Arbitrary noncontiguous multi-selection, grouping, align/distribute, locking, numeric position inspector, and layers panel.
- Headers/footers, margins/guides, page thumbnails/reorder, and custom page-size UI.
- Large-document page reflow, oversize-block policy, image/font fidelity, and 100-page export stress/cancellation.
- DOCX import and round-trip fidelity. DOCX export is semantic and intentionally flattens spatial positioning; PDF is the layout-fidelity format.
- Broader Compose UI automation for the new gestures and export surfaces; the current Room/codec Android instrumentation suite passes all 12 tests.

Do not label this editor complete until the remaining applicable gates pass.

## Critical app-wiring delta — 2026-07-15

- Retired only the standalone workspace Canvas: its route, object model, persistence tables, backup/sync fields, permissions, commands, and visible entry points are gone. Docs Flow and bounded Document Canvas remain.
- Reworked the compact shell into Home / Docs / raised Create / Tasks / Chat and verified the dock on a 1080×2400 emulator.
- Unified Calendar into the Tasks view switcher. Legacy Calendar deep links render the same Tasks surface; dashboard/sidebar/object actions now open Tasks in Calendar mode.
- Added exact task start/end time editing when All day is off and kept the same task object across Board, Table, Feed, Calendar, and Chart.
- Added working Docs tag assignment/removal/filter/rename/delete wiring.
- Added an expandable, horizontally scrollable Docs formatting toolbar above the IME with editor-owned type family/scale controls and common block/inline actions.
- Added a floating, expandable chat composer with scrollable quick actions and verified its keyboard inset behavior.
- Wired application font, scale, and compact density to the actual Compose theme/density consumers; removed document font/size rows from Settings.
- Added Vault-first biometric guidance, enrollment routing, lifecycle auto-lock, unlock failure throttling, and immediate screenshot protection wiring.
- Upgraded biometric unlock from a UI-only success callback to an Android Keystore AES/GCM verifier bound to `BIOMETRIC_STRONG`; Vault unlock now requires successful decryption through `BiometricPrompt.CryptoObject`, and invalidated enrollment is cleared safely.
- Added manual Sync now only to the canonical Sync Settings page. It validates the configured chain before consuming the monotonic 15-second guard, exposes the remaining cooldown in the button label, and does not penalize likely offline failures.
- Added atomic Supabase handle claiming and a case-insensitive unique handle migration; the remote migration must be deployed before online uniqueness is production-ready.

### Runtime evidence

Evidence is stored under `codex-handoffs/device-evidence/`:

- `norfold-hub-clean-2026-07-15.png`
- `norfold-sidebar-no-canvas-2026-07-15.png`
- `norfold-docs-2026-07-15.png`
- `norfold-doc-editor-2026-07-15.png`
- `norfold-doc-edit-mode-2026-07-15.png`
- `norfold-editor-toolbar-keyboard-2026-07-15.png`
- `norfold-editor-toolbar-expanded-2026-07-15.png`
- `norfold-tasks-board-2026-07-15.png`
- `norfold-tasks-table-fixed-2026-07-15.png`
- `norfold-tasks-calendar-integrated-2026-07-15.png`
- `norfold-settings-2026-07-15.png`
- `norfold-chat-composer-2026-07-15.png`
- `norfold-chat-keyboard-2026-07-15.png`
- `norfold-sync-settings-final-crypto-2026-07-15.png`
- `norfold-security-vault-first-crypto-2026-07-15.png`

After the Keystore and canonical Sync changes, the combined JDK 21 gate `testDebugUnitTest assembleDebug assembleDebugAndroidTest` passed (77 tasks). The exact rebuilt app/test APKs were installed with Windows ADB and the connected runner passed all 12 Room/document instrumentation tests in 5.653 seconds. WSL Gradle cannot discover the Windows-hosted emulator through its separate ADB daemon, so the exact packaged app/test APKs were installed and run with Windows ADB instead.

The final `lintDebug` gate also completed successfully. Its report contains no errors (57 warnings and 9 hints); the warning backlog remains non-blocking technical debt and must be reviewed again before beta/release hardening.

The final device pass visibly verified that an unconfigured Sync now action is disabled, a Set up sync route is present, and Account & Restore no longer owns a duplicate Sync now button. It also verified that attempting biometric unlock without a Vault opens the Vault setup path and reports `Set up the Vault before enabling biometric unlock`. Authentication-bound encryption/decryption still requires a physical device or emulator with a fingerprint enrolled; keep that as a release gate rather than claiming hardware proof from this AVD.

The device pass discovered and fixed a visible Table defect: `TaskSwipeRow` painted the disabled action name `None` behind every row, which clipped into the index cells. The fixed screenshot shows clean numeric row indices.

Gitleaks reported only client-distributed/public configuration in ignored/generated BuildConfig, `google-services.json`, and ignored `norfold.properties`. The web OAuth client secret supplied in chat is not present in the repository or APK configuration and must remain server-side.
