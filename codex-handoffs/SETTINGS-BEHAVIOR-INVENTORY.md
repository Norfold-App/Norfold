# Settings behavior inventory

Updated: 2026-07-15

This is the acceptance inventory for Norfold Settings. A row is not complete merely because it renders: its value must reach the named consumer, persist when applicable, survive process restart, and expose disabled/error guidance.

## Product boundaries

- App typography belongs in **Appearance** and changes the application chrome.
- Document typography belongs in the Docs editor's expandable keyboard toolbar. Editor font family and size must not be duplicated in Settings.
- The standalone workspace Canvas is retired. Docs Flow and the bounded Document Canvas remain.
- Pre-beta emulator/development data may be reset. If the owner says Beta, release candidate, outside testing, or production, stop and activate the migration warning/gate in `AGENT-JOB.md` before release work.
- OAuth client secrets never belong in Android resources, BuildConfig, Gradle properties, source, logs, diagnostics, backups, or screenshots. Android uses the public Android client ID.

## Inventory

| Section / control | Source of truth | Required consumer and behavior | Persistence / proof |
|---|---|---|---|
| Profile: full/public name | `AppSettings` through `DocsViewModel.patchSettings` | Workspace header, profile surfaces, activity attribution | Room settings; relaunch check |
| Profile: `@handle` | canonical normalized handle; Supabase `claim_profile_handle` when signed in | Lowercase uniqueness, grammar validation, collision rejection; local pre-auth handle remains provisional | unique lower-case DB index/RPC plus UI error |
| Workspace identity/visuals | `AppSettings` workspace fields | Hub, Docs header, sidebar, picker previews | Room plus encrypted snapshot |
| Appearance: theme/palette | `themeMode`, `accentScheme` | Material color scheme and system bars | relaunch plus light/dark screenshots |
| Appearance: app font | `appFontFamily` | `NorfoldTheme` Material typography only | relaunch and visibly different chrome |
| Appearance: app size | `uiScale` | Compose density and font scale together | slider change plus relaunch |
| Appearance: compact density | `uiDensityCompact` | tighter application spacing without silently shrinking document content | compact phone screenshot |
| Editor: document surface | editor interaction setting | selection/edit affordances in Flow/Document Canvas | editor interaction test |
| Editor: line width | editor layout setting | Flow writing-column width | reopen document check |
| Editor: tab size | editor setting | code/source indentation behavior | source edit test |
| Editor: line numbers, bracket pairing, paste conversion | editor settings | corresponding source/editor behavior | focused behavior tests |
| Editor font family/size | Docs editor toolbar, persisted editor preferences | active edit and preview text; controls show current value | keyboard-toolbar screenshot and reopen; no duplicate Settings row |
| Vault status/password | vault settings plus encrypted verifier | setup, update, lock, unlock, disable; minimum six characters; rate-limited failures | clean setup, lock/relaunch/unlock |
| Biometric unlock | Vault prerequisite plus Android biometric capability | disabled guidance until Vault exists; enrollment settings when hardware has no enrolled credential; authenticate only after setup | emulator/physical-device flow |
| Auto lock / lock on exit | lifecycle events and monotonic timeout | background/foreground lock transition | timed background test |
| Protect screenshots/recents | `blockScreenshots` | immediate `FLAG_SECURE` application/removal | screenshot allowed/blocked test |
| Account & Restore: providers | sync provider/chain/session state | create, restore, reconnect and revoke flows with actionable errors | provider-specific device test |
| Sync Settings: Sync now | `DocsViewModel.syncConfiguredNow` -> `syncNow` | one in-flight request; 15-second anti-spam cooldown; provider/session guidance; last-sync status | repeated-tap test and relaunch status |
| Sync on exit | `autoSync` plus unlocked session key | lifecycle-triggered sync only when configured/unlocked | background test |
| Backup & Import | repository snapshot codecs | encrypted export/restore plus Markdown import; every active Room object included | round-trip tests |
| Conflict Resolution | structured conflict report | local/remote summaries and explicit resolution; never silently overwrite | conflict fixture/device test |
| Permissions | active workspace permission fields | creation/actions disabled with explanation | permission matrix test |
| Diagnostics | local diagnostics store | redacted view/share/clear; no credentials or document secrets | secret scan and share test |

## Current verification state

- JDK 21 unit tests and debug assembly pass.
- The Android instrumentation APK packages successfully.
- Windows-hosted ADB executed the instrumentation runner on `emulator-5554`: `OK (12 tests)`.
- On-device checks cover the Settings index, absence of editor font/size rows, Vault-first biometric guidance, the premium dock, integrated Tasks Calendar, full-page task Table, Docs reading/edit states, expandable editor toolbar, and chat composer/IME layout.
- The task Table swipe background defect discovered during QA was fixed; disabled swipe actions no longer paint `None` behind row numbers.
- Physical biometric enrollment/authentication, provider consent, real remote sync, cooldown countdown presentation, accessibility, rotation, tablet/foldable, and large-font coverage remain release gates.

