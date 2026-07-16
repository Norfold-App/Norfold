# Norfold Critical App Wiring and Premium UX Execution Contract

**Status:** AUTHORITATIVE — READY FOR IMPLEMENTATION  
**Release stage:** PRE_BETA  
**Written:** 2026-07-15  
**Primary target:** Android  
**Authority:** This file records the newest direct product decisions. It supersedes older handoffs, AGENTS.md clauses, diagrams, acceptance notes, and implementation assumptions wherever they conflict with this file.

## 0. Read this first

This is not an ideas list and not permission to ship mock controls. It is the implementation contract for turning the current broad prototype into a coherent, wired application.

The next implementation agent must:

1. Read root AGENTS.md, codex-handoffs/AGENT-JOB.md, this file, and codex-handoffs/MASTER_ORDER.md.
2. Treat this file as newer than the Canvas decisions in those files.
3. Inspect the current dirty worktree and preserve unrelated user work.
4. Code the coherent feature tranche first. Use focused compilation/static checks while coding so breakage does not compound.
5. After the tranche is integrated, run the complete build, automated tests, device tests, visual inspection, and defect-repair loop.
6. Never report complete merely because source exists or an APK builds.

## 1. Final product decisions

### 1.1 Workspace Canvas is retired

The standalone workspace Infinite Canvas / Canvas destination is out of the product. Do not redesign it, preserve it as a hidden experiment, route to it, or reuse its name for the document editor.

Required cleanup:

- Remove Canvas from compact navigation, expanded navigation, sidebar, command palette, dashboard quick actions, adaptive FAB routing, search commands, templates, destinations, object-type choices, empty states, and user-facing copy.
- Remove unreachable Canvas UI implementation and its exclusive tests/assets once references are proven absent.
- Remove or deprecate Canvas-only persistence only when safe for the current PRE_BETA schema. Current development data may be reset on an explicitly identified emulator/test device.
- Keep general reusable primitives only when another active feature demonstrably uses them.
- Update root AGENTS.md and codex-handoffs/AGENT-JOB.md before feature implementation so later agents do not revive the retired surface.
- Produce search proof for CanvasBoardScreen, CanvasNode, Destination.Canvas, and visible “Canvas” navigation labels. Any retained technical symbol must have a documented non-Canvas consumer.

The user's complaint about a cramped “grid” and defective dragging applies to active reorderable surfaces such as document blocks, Tasks Board/Table/List, and dashboard cards. It is not permission to restore Canvas.

### 1.2 Tasks Calendar belongs to Tasks

Calendar is a Tasks workspace view, not a separate navigation island. Selecting Calendar must keep the Tasks shell, search/filter context, board/workspace context, and Back behavior.

### 1.3 Document typography belongs to the document editor

Remove editor font family and editor font size from global Settings. Global Settings may keep an app-interface typography preference only if it actually changes the app UI. Document font, size, styles, paragraph formatting, and page formatting belong to the selection-aware editor toolbar and the document style model used by edit, preview, and export.

### 1.4 Cloud configuration is not cloud proof

Google, Firebase, and Supabase source/configuration may be present. “Configured,” “authenticated,” “authorized,” “synced,” and “runtime verified” are separate states. UI and completion reports must not collapse them into one green check.

### 1.5 PRE_BETA migration rule

Development data is disposable only on an explicitly scoped emulator or test device. Prefer the correct schema and a clean reset over spending time on arbitrary pre-beta migrations.

If the user says Beta, beta testing, release candidate, outside testers, public test, or production distribution, immediately show this warning before release work:

> Beta gate detected. Previous development builds allowed destructive data resets and do not promise upgrade compatibility. Before distribution, Norfold needs a frozen baseline schema plus migration, backup/restore, rollback, and upgrade testing. May I activate the Beta migration gate and implement that work?

Do not clear a physical device, user cloud data, shared service, or unspecified target without explicit permission.

## 2. Evidence baseline

### 2.1 Stable reference assets

All visual evidence is copied to:

codex-handoffs/reference-images/critical-wiring-2026-07-15/

| File | Meaning |
|---|---|
| navbar-dashboard-reference.jpeg | Target qualities for modular dashboard cards, floating glass navigation, central Create action, top search/alerts/more controls |
| editor-floating-toolbar-reference.jpeg | Target qualities for an IME-anchored, horizontally scrollable, expandable formatting toolbar |
| chat-current-defect.jpeg | Current Chat defect: oversized empty-state presentation and weak composer hierarchy |
| problem-01-task-table.jpg | Table is cramped, clipped, horizontally broken, and does not use the working page area |
| problem-02-task-list.jpg | View tabs clip; task content/drag affordances overlap text; layout hierarchy is noisy |
| problem-03-workspace-visual-dialog.jpg | Oversized modal, wrapping tab labels, clipped cover carousel, weak narrow-screen adaptation |
| problem-04-workspace-visual-saved.jpg | Saved result does not visibly match the selected icon shown in the preceding dialog; persistence/rendering must be verified |
| problem-05-account-sync.jpg | Configuration/status hierarchy is confusing, Sync Now is duplicated, most actions are disabled without enough guided recovery |
| problem-06-diagnostics.jpg | Baseline example of a comparatively clean single-purpose Settings subpage; still requires behavior verification |
| problem-07-task-date-sheet.jpg | Due-date sheet supports date range/all-day/reminder but exposes no exact start/end time |

### 2.2 Confirmed source findings

These are facts from the current source, not assumptions:

- AppSettings contains appFont and uiDensityCompact, but NorfoldTheme uses a fixed FontFamily.SansSerif typography and does not consume either field. Those Settings controls are currently false promises.
- editorFontSize is reused by global Appearance and Editor settings as a normalized slider rather than a typed document size. It is not a sufficient single source of truth for edit, preview, and export.
- TasksBoardScreen reacts to the Calendar view by resetting taskViewMode to Board and navigating to Destination.Calendar. This directly causes the navigation break reported by the user.
- TagsScreen can create a tag and route a tag click through Search, but this does not prove the Docs Tags entry, filtering, editing, deletion, counts, and persistence flow work.
- FloatingFormattingToolbar is already a LazyRow and has basic block/inline actions, but it has no expanded control surface, document typography model, selection-state reflection, or Word-class formatting groups.
- Security Settings directly toggles requireBiometricOnOpen without requiring a configured vault or launching biometric enrollment.
- The current biometric success path unlocks a Boolean UI state; it does not demonstrate a CryptoObject-backed key unwrap.
- Sync Now exists in more than one place and has only an in-flight guard. It has no user-visible cooldown against repeated completed requests.
- Supabase dependencies/client/auth exist. The profiles table has display_name but no canonical unique handle column or claim transaction.
- Firebase Messaging dependency, plugin condition, manifest service, and messaging service exist. Runtime token delivery/registration is not proven by source presence.
- Google identity uses Credential Manager, Drive uses AuthorizationClient, and Drive snapshots target appDataFolder. Device consent, redirect, token refresh, restore, and failure recovery still need runtime proof.

### 2.3 Current cloud truth table

| Capability | Present in source | Required proof before “working” |
|---|---|---|
| Google identity | Credential Manager and Google ID-token bridge to Supabase | Sign in, cancel, no-account recovery, token refresh, sign out, revoked access, process recreation, debug and release fingerprints |
| Google Drive restore/sync | AuthorizationClient and appDataFolder sync store | Consent, create chain, Sync Now, remote restore after reinstall, conflict path, expired authorization, offline recovery |
| Supabase | Client modules, Auth, PostgREST, Realtime, Storage, Functions, schema/functions | Actual project connection, session restore, RLS denial/allow cases, profile creation, unique handle claim, error mapping |
| Firebase | google-services plugin when file exists, Messaging dependency/service | Install-specific token, permission flow, backend registration, foreground/background receipt, token rotation, signed-build behavior |

Do not print or commit OAuth client secrets, service-role keys, private signing material, or downloaded credential JSON. Android must use public client identifiers only. Rotate any secret previously pasted into chat or logs.

## 3. Product-wide wiring invariant

Every interactive control must complete this chain:

UI intent → validated typed command → domain state → persistence or authorized remote mutation → observable success/error state → process/relaunch restoration → test evidence

A control fails this contract if it only:

- changes local composable state;
- writes a setting that no consumer reads;
- changes a label without changing behavior;
- shows a green “Ready” state from configuration strings;
- calls a coroutine without single-flight/error/retry behavior;
- loses its result on Back, rotation, process death, or reopen;
- hides failure behind a generic Snackbar;
- has no accessible name/state/action.

Build a small shared mutation model instead of inventing one-off Booleans:

- Idle
- Validating
- AwaitingSystemAction
- Working
- Succeeded with timestamp/result
- Failed with typed, user-actionable reason
- CoolingDown until timestamp

Network and destructive actions require idempotency where possible. All async actions must prevent duplicate execution, survive recomposition, and expose retry.

## 4. Implementation streams

### Stream A — Contract cleanup and Canvas removal

1. Update contradictory active docs first.
2. Remove Canvas routes and visible entry points.
3. Remove the feature implementation and exclusive model/storage only after reference analysis.
4. Update backup/snapshot codecs and schema for the current PRE_BETA baseline.
5. Clean-install on an explicitly named emulator after incompatible schema changes.
6. Preserve graph/backlink/shared-object primitives that serve Docs, Tasks, Files, Chat, or Activity.

Acceptance:

- No user can navigate to or create a workspace Canvas.
- No empty Canvas route remains.
- Search/command/sidebar/nav do not advertise it.
- Build/tests and clean-install pass.
- Grep/search proof is recorded.

### Stream B — Functional Settings architecture

Create a Settings behavior inventory before editing. For every row record:

- displayed control and current key;
- real consumer;
- validation/bounds;
- immediate preview versus committed save;
- process-death expectation;
- error/permission flow;
- test.

Required corrections:

- appFont must map to real bundled/downloadable font families and change MaterialTheme typography, or the setting must be removed;
- uiDensityCompact must change spacing/component density without breaking 48dp touch targets, or it must be removed;
- slider previews update smoothly in memory, commit on gesture finish/debounce, clamp to a meaningful typed range, and avoid a database write per pointer sample;
- reset-to-default and current numeric/semantic value must be visible;
- unavailable features show why and offer the next action;
- Settings subpages use one header/back pattern and do not sit awkwardly above the global nav;
- selected workspace/profile images must render from the saved URI after reopen, with persisted URI permission and fallback/error states;
- workspace visual modal must fit narrow phones, keep actions reachable above IME/system bars, and give carousels visible scroll affordance.

Global app typography:

- Keep a restrained UI font set with verified licenses and real Android resources.
- Include a high-quality sans default, readable serif, and mono option only if each is actually bundled/resolvable.
- Verify Latin and Bengali fallback, bold/italic weights, numerals, emoji, large font scale, and missing-glyph behavior.
- A font label must never silently fall back to the same system font while pretending it changed.

Remove from Settings:

- document/editor font family;
- document/editor font size.

Retain only editor behavior defaults that truly make sense globally, such as default view mode, Markdown visibility, tab width, paste conversion, gesture behavior, and accessibility defaults.

### Stream C — Profile, onboarding, and globally unique handle

The setup handle and Profile handle are the same canonical identity field.

#### Handle rules

- Display as @handle.
- Normalize with Unicode-aware policy decided once, then store a lowercase canonical value.
- Initial recommended grammar: 3–30 characters, ASCII lowercase letters/digits/underscore, begins with a letter, no consecutive underscores.
- Maintain reserved, offensive, product, support, and impersonation-sensitive names server-side.
- Show availability only after normalization and debounce.
- Never claim global availability from an offline/local lookup.
- Preserve a display name separately from the handle.

#### Server model

Add a Supabase migration that gives profiles a canonical handle with a database UNIQUE constraint. Prefer CITEXT or a normalized generated/validated value, not a client-only lowercase convention.

Implement an atomic security-definer RPC or transactional update to claim/change a handle:

- authenticated user can claim only their profile;
- unique violation maps to “That handle is already taken”;
- reserved name maps to a distinct error;
- request is idempotent;
- RLS prevents reading private profile fields;
- a minimal public profile projection exposes only fields required for handle lookup/mentions;
- handle changes have a reasonable cooldown and audit record if collaboration ships.

Offline behavior:

- Setup may save a clearly labeled provisional local handle while offline.
- Collaboration/mentions remain unavailable until the server confirms it.
- On conflict after reconnect, guide the user to choose another handle; never silently append random digits.

Acceptance:

- Two accounts racing for the same normalized handle produce exactly one winner.
- Case variants collide.
- Onboarding result appears in Profile after relaunch.
- Cancel/error/offline/retry states are explicit.
- No service-role key is present in the APK.

### Stream D — Guided Vault and biometric security

Replace independent toggles with a state machine:

- NotConfigured
- Configuring
- ReadyUnlocked
- ReadyLocked
- Unlocking
- EnrollmentRequired
- KeyInvalidated
- RecoveryRequired
- Error

#### Vault setup

The Vault status row opens a guided flow explaining:

1. what is protected;
2. what the passphrase/PIN does;
3. recovery and loss implications;
4. confirmation/re-entry;
5. successful setup;
6. optional biometric quick unlock.

Validate strength without forcing arbitrary complexity rules. Rate-limit failed unlock attempts. Never log secrets. Clear secret char arrays where practical. Disable/change flows require re-authentication.

#### Biometric behavior

When the user enables Biometric unlock:

1. If Vault is not configured, show “Set up Vault first” and route into Vault setup.
2. Check BiometricManager with the same authenticator policy used by the prompt.
3. If none is enrolled, launch Settings.ACTION_BIOMETRIC_ENROLL with allowed authenticators.
4. If hardware is unavailable, explain the condition without switching the toggle on.
5. If enrolled, authenticate once and only then save enabled state.
6. On later unlocks, use an Android Keystore key and BiometricPrompt CryptoObject to unwrap the Vault key or protected material.
7. Handle lockout, cancellation, enrollment change/key invalidation, OS credential removal, and fallback recovery.

Biometrics are not the encryption secret. A successful callback must not merely flip locked=false without cryptographically authorizing key access.

Other security settings:

- App lock on exit and auto-lock timeout must be tied to lifecycle/background timestamps and process restore.
- Protect screenshots must update FLAG_SECURE immediately and after activity recreation.
- Backup/sync key behavior and recovery consequences must be explained.
- Add unit tests for state transitions and instrumented tests for system-action routing where hardware can be simulated.

Official reference: https://developer.android.com/identity/sign-in/biometric-auth

### Stream E — Sync Now and cloud status

Create one canonical Sync status/control component and reuse it. Remove the duplicated Sync Now buttons shown in problem-05-account-sync.jpg.

Sync Now requirements:

- enabled only for a valid configured chain;
- if identity/Drive authorization is missing, offer the exact prerequisite action;
- single-flight;
- visible progress and last attempted/succeeded time;
- 15-second default cooldown after completion, represented by a monotonic deadline;
- cooldown button text explains remaining time;
- offline failure does not consume a long cooldown;
- repeated taps cannot launch concurrent snapshot creation/uploads;
- timeout with cancellation-safe cleanup;
- typed errors for authorization revoked, wrong sync secret, network unavailable, conflict, corrupt remote snapshot, quota, and unknown server failure;
- retry and conflict-review paths;
- background sync and manual sync use the same coordinator/lock.

Do not store a raw sync passphrase indefinitely. If a session secret is retained, define its lifetime and secure storage strategy.

Acceptance:

- Tap-spam creates one operation.
- Recomposition/rotation does not duplicate it.
- App relaunch shows accurate last success and failure state.
- Reinstall plus Google restore works on a test account.
- Conflict resolution is exercised, not only compiled.

### Stream F — Unified Tasks workspace

Tasks owns these internal views:

- Table
- Board
- Feed
- Calendar
- Chart
- List
- Timeline
- Matrix

Do not navigate to a standalone Calendar destination when switching views. Replace the current LaunchedEffect redirect with a shared Tasks shell and view-local content.

Shared shell state:

- active workspace/board;
- query;
- filters;
- sort;
- selected date/range;
- view;
- focused/selected task;
- scroll/restoration state.

Back order:

1. dismiss picker/sheet;
2. close task detail;
3. clear transient selection;
4. return from a drilled calendar date to the previous Calendar level;
5. return to the previously selected Tasks view only if the user entered a temporary detail mode;
6. leave Tasks.

#### Table

- Use the entire content viewport like Board.
- Pin meaningful identity columns; scroll the remaining columns deliberately.
- Avoid the current tiny centered spreadsheet island.
- Provide row/column headers, column resize/reorder where useful, readable minimum widths, and a clear horizontal-scroll affordance.
- Cell editing must not overlap drag handles or action menus.
- Narrow phones get a purposeful row-detail adaptation rather than illegible squeezed columns.

#### Board/List drag and layout

- Remove overlapping Norfold/drag glyphs visible in problem-02-task-list.jpg.
- Use long-press lift, clear elevated preview, live drop indicator, edge auto-scroll, haptic pickup/drop, cancellation, undo, and accessible move actions.
- Board drag must support horizontal column auto-scroll plus vertical list auto-scroll.
- Process pointer movement at frame cadence; do not quantize to a tiny grid.
- Preserve task identity and sort order atomically after drop.
- Moving one card must not trigger full-board recomposition/jank.

#### Calendar and exact time

Task scheduling model must support:

- all-day;
- start date and optional exact start time;
- end date and optional exact end time;
- timezone;
- due-only tasks;
- validation that end is not before start;
- reminder relative to start/due;
- recurrence-ready representation, even if recurrence UI is staged later.

The sheet in problem-07-task-date-sheet.jpg must expose Start time and End time when All day is off. Use locale-aware date/time pickers, display the timezone, and preserve timestamps through Tasks, Calendar, backup, sync, conflict reports, and export.

Task editor:

- top actions and Save remain reachable;
- property rows align on narrow phones;
- sheets respect IME/navigation insets;
- no control is hidden under another sheet or nav bar;
- exact time is visible on task cards and Calendar where relevant.

### Stream G — Premium adaptive navigation and dashboard

Use navbar-dashboard-reference.jpeg for qualities, not for telecom content.

Compact phone structure:

- floating rounded dock above the system navigation inset;
- primary destinations: Home, Docs, Tasks, Chat;
- raised center Create orb;
- no Canvas item;
- Create action adapts to current section but always labels the resulting action before destructive/ambiguous creation;
- active destination gets a shape/color/label treatment, not color alone;
- badges are reserved for meaningful unread/error states;
- long-press may expose destination quick actions with accessibility equivalents.

The Menu/sidebar remains reachable from screen headers or an explicit dock affordance on surfaces that need it. Do not strand Settings, Files, Activity, Search, or account controls.

Adaptive behavior:

- phone dock;
- medium navigation rail or compact drawer;
- expanded navigation rail/sidebar;
- NavigationSuite-style destination mapping so behavior stays consistent;
- edge-to-edge and IME/system insets;
- landscape/fold/tablet layout tests.

Dashboard qualities from the reference:

- a coherent top identity/search/notifications/more block;
- modular cards with real workspace data;
- quick actions tied to working commands;
- card hierarchy and subtle tinted surfaces;
- no fake balances, fake analytics, or decorative controls;
- reorder only if persistence and accessible move actions are complete.

#### Navigation motion

- center Create orb uses a short spring lift/press and optional shape morph into its action sheet;
- selected indicator uses interruptible spring movement;
- destination content uses fade-through/shared-axis based on relationship;
- detail cards may use shared bounds when technically safe;
- drawer/dock transitions preserve spatial continuity;
- haptics only on meaningful selection/create/drag confirmation;
- reduce-motion replaces transforms with short fades or snaps;
- animations never delay input or mask loading.

Official adaptive/motion references:

- https://developer.android.com/develop/ui/compose/build-adaptive-apps
- https://developer.android.com/develop/ui/compose/animation/introduction
- https://developer.android.com/develop/ui/compose/animation/shared-elements
- https://developer.android.com/develop/ui/compose/animation/quick-guide

### Stream H — Docs tags end-to-end

The Docs Tags action must open a working tags surface and support:

- view all tags with counts;
- create;
- assign/remove from one document;
- multi-select assignment;
- filter Docs by tag;
- rename;
- delete with explicit choice to remove assignments;
- normalized duplicate prevention;
- empty, loading, and error states;
- search integration;
- persistence, backup, sync, restore, and conflict behavior;
- Back restoration to the prior Docs list/query/scroll position.

A tag chip that only sends text to Search is not completion.

Tests must prove create → assign → close → relaunch → filter → rename → sync snapshot → remove.

### Stream I — Smooth document block reordering

Document block movement is pick-up-and-move, not a workspace Canvas.

Required behavior:

- drag handle appears for the focused/selected block without permanently boxing every block;
- long-press or handle pickup;
- full vertical document range, not a small local grid;
- auto-scroll near top/bottom with speed based on edge proximity;
- drop slots between blocks and around containers;
- nested/container rules are explicit;
- 60/120 Hz friendly pointer sampling with state updates limited to changed targets;
- no database write per frame;
- commit one atomic command on drop;
- cancellation restores original order;
- undo/redo;
- haptic pickup/drop;
- TalkBack custom actions Move before/after/into/out of;
- large document stress test.

Use high-level semantics where possible and low-level pointer input only where needed. Official pointer reference:

https://developer.android.com/develop/ui/compose/touch-input/pointer-input

### Stream J — Expandable, selection-aware document formatting bar

The bar in editor-floating-toolbar-reference.jpeg is the layout reference:

- floats immediately above the IME;
- horizontally scrollable compact row;
- clear expansion affordance;
- expanded mode becomes a bounded second row or bottom sheet, never covers the selection unnecessarily;
- keeps keyboard focus/cursor;
- selection-aware active states;
- block-aware controls;
- remembers last group per session;
- collapses smoothly;
- works in portrait, landscape, split screen, tablet, hardware keyboard, and large font.

The current basic LazyRow is a starting point, not completion.

#### Single document style model

Do not independently style edit, preview, PDF, and DOCX.

Introduce typed document styles:

- DocumentTheme
- CharacterStyle
- ParagraphStyle
- ListStyle
- TableStyle
- PageStyle
- SectionStyle
- MediaStyle

Markdown remains an interchange/source representation where appropriate, but unsupported rich formatting must have a loss-aware native representation. Exporters must report fidelity losses rather than silently discard them.

#### Core launch formatting

- font family from a licensed, resolvable catalog;
- typed font size in points/sp with presets and direct entry;
- increase/decrease size;
- bold, italic, underline, strikethrough;
- text color and highlight;
- clear formatting;
- title, subtitle, normal, Heading 1–6, quote, code;
- left, center, right, justify;
- line spacing and paragraph before/after;
- indent/outdent;
- bullets, numbering, checklist, multilevel list;
- link;
- undo/redo;
- find/replace;
- word/character count;
- insert table, image, file, divider, page break;
- image alt text and caption;
- format painter/copy style.

#### Advanced document formatting

- superscript/subscript;
- case conversion;
- letter spacing;
- tabs;
- borders/shading;
- table row/column insert/delete, header row, alignment, widths, borders, shading, merge/split where export-safe;
- media crop/fit/alignment/wrap/order;
- page size, margins, orientation, columns;
- section breaks;
- headers, footers, page numbers;
- footnotes/endnotes;
- equations and symbols;
- bookmarks and internal links;
- table of contents from semantic headings;
- citations/bibliography;
- comments and mentions;
- version history;
- suggestion/track-changes model;
- spellcheck, document language, autocorrect controls;
- accessibility checker;
- templates/themes and reusable named styles.

#### Later collaboration/publishing tier

- realtime coauthoring;
- granular suggestions/accept/reject;
- reactions;
- approval workflows;
- mail merge;
- forms/fields;
- reusable components;
- brand kits;
- interactive charts/embeds;
- presentation conversion;
- public web publishing.

Do not implement the entire advanced/later list as shallow buttons. Implement the Core tier completely over the shared style model, then advance feature groups only when edit/preview/export/undo/persistence tests exist.

Reference baselines:

- Microsoft Word features: https://support.microsoft.com/en-us/office/word-features-comparison-web-vs-desktop-3e863ce3-e82c-4211-8f97-5b33c36c55f8
- Word styles: https://support.microsoft.com/en-us/office/use-styles-in-word-for-the-web-ec9b0f9e-a4ae-43a1-b861-dd50747410bb
- Word change tracking: https://support.microsoft.com/en-us/word/training/track-changes-in-word
- Word accessibility: https://support.microsoft.com/en-us/accessibility/word/make-your-word-documents-accessible-to-people-with-disabilities
- Canva Docs collaboration/visual-doc ideas: https://www.canva.com/newsroom/news/canva-docs/

### Stream K — Chat surface and contextual composer tools

Chat is not a document editor. It may reuse the same expandable toolbar shell, motion tokens, and keyboard/inset infrastructure, but its action registry is context-specific.

Fix:

- reduce the oversized empty-state hero on compact phones;
- keep the composer visually attached to conversation content and immediately above the IME;
- add an expandable horizontal action bar for attachment, photo/file, mention, link, document/task reference, lightweight bold/italic/code/list, emoji, and voice if implemented;
- allow multiline growth to a bounded height, then internal scroll;
- make send state, upload progress, retry, cancel, and failed attachments visible;
- group messages cleanly and keep timestamps/status readable;
- scroll to latest without fighting a user reading history;
- support keyboard open/close, predictive Back, rotation, and navigation bars;
- use compact prompt chips rather than a dominant empty page;
- preserve draft across temporary navigation/process recreation where reasonable.

Motion:

- composer expands with animateContentSize or a coordinated Transition;
- sent message uses short placement/fade, not a theatrical animation;
- attachment progress is determinate when possible;
- retry/error state never pulses indefinitely;
- reduce-motion honored.

### Stream L — Visual quality and animation system

Create reusable motion tokens instead of arbitrary values in each screen.

Recommended starting ranges, to tune on device:

- press/selection feedback: 80–140 ms;
- small enter/exit: 140–220 ms;
- container/detail transition: 220–320 ms;
- spring: medium-low stiffness with damping that avoids bounce loops;
- no routine interaction should wait for animation completion;
- no indefinite decorative animation in normal content.

Use:

- AnimatedContent for meaningful state replacement;
- AnimatedVisibility for action groups/empty states;
- animateContentSize for bounded expansion;
- Transition for synchronized shape/color/elevation;
- sharedBounds only where identity continuity is real and limitations are understood;
- animateItem for list placement;
- Animatable/decay for direct manipulation and settling.

Requirements:

- all animation is interruptible;
- direct manipulation tracks the finger without tween lag;
- no layout clipping during transitions;
- text uses animated text motion only when needed;
- reduce-motion is a first-class branch;
- TalkBack focus does not jump due to animation;
- jank/performance checked on a mid-range device profile.

## 5. Execution order

This order respects the user's instruction to implement the coherent product before the final full test/fix campaign without allowing weeks of uncompilable code.

### Phase 0 — Truth and contract

- Checkpoint the dirty tree without absorbing unrelated changes.
- Update contradictory active docs.
- Preserve before screenshots.
- Remove Canvas from the product contract and routes.
- Create the behavior/setting inventory.
- Record service configuration versus runtime status.

### Phase 1 — Shared foundations

- typed mutation/cooldown/error state;
- document style model and command/undo boundary;
- motion tokens and reduce-motion routing;
- adaptive navigation destination model;
- Tasks shared shell/view state;
- security state machine;
- profile/handle domain and Supabase migration.

Focused compilation and relevant unit tests are allowed and required during implementation. Do not run the entire final suite after every small edit.

### Phase 2 — End-to-end feature coding

Implement in dependency order:

1. Settings consumers and typography cleanup;
2. profile/onboarding/handle claim;
3. Vault/biometric setup;
4. sync coordinator and canonical status UI;
5. Tasks shell, Calendar integration, full-page Table, task times, drag repair;
6. navigation/dashboard;
7. Docs Tags;
8. document block reorder and Core formatting toolbar;
9. Chat composer/empty-state polish;
10. cloud status/error surfaces.

Commit at coherent phase boundaries only if the active workflow requests commits. Never commit credential files.

### Phase 3 — Integration compile gate

- format/static analysis;
- focused unit tests;
- assemble debug;
- fix all compile/resource/manifest failures;
- inspect dependency/version compatibility;
- run secret and vulnerability scans without printing secrets.

### Phase 4 — Full automated proof

- all Android unit tests;
- lint/detekt/ktlint as configured;
- assembleDebug;
- instrumentation tests;
- clean-install current PRE_BETA schema;
- reinstall/restore scenarios;
- screenshot/golden tests if introduced.

### Phase 5 — Emulator/device defect loop

Install the exact APK built in Phase 4. Test every acceptance case in:

- Light and Dark;
- narrow phone;
- large font/display scale;
- landscape/split screen;
- tablet/desktop-class layout;
- keyboard open/closed;
- offline/slow/error network;
- process death/relaunch;
- TalkBack/accessibility actions;
- reduced motion.

Compare original-resolution screenshots with the stored references. Fix each visible defect and rerun focused tests after the last visual change.

### Phase 6 — Cloud and hardware proof

Use test accounts/devices:

- duplicate handle race;
- Google sign-in and revoke;
- Drive create/sync/restore/conflict;
- Firebase token and foreground/background notification;
- biometric enrolled/not enrolled/lockout/key invalidated;
- Vault recovery and wrong-secret paths.

### Phase 7 — Completion report

Report:

- exact files/areas changed;
- service migrations/functions deployed or still local;
- build/test commands and results;
- device identities/profiles and interactions exercised;
- Light/Dark/adaptive/accessibility proof;
- grep removal proof;
- data reset performed and exact target;
- known limitations;
- commit hashes where required.

## 6. Hard acceptance matrix

| Area | Required observable proof |
|---|---|
| Canvas retirement | No route/entry/create action; exclusive source removed; search proof |
| App font | Each offered UI font visibly changes UI, survives relaunch, has glyph fallback |
| Sliders | Smooth preview, bounded value, debounced/finish commit, relaunch restoration, real consumer |
| Handle | Onboarding/Profile consistency; atomic unique collision; offline/provisional flow |
| Vault | Guided setup, lock/unlock, wrong secret, recovery explanation, lifecycle auto-lock |
| Biometrics | Vault prerequisite, enrollment launch, prompt, cryptographic key use, invalidation recovery |
| Sync Now | One canonical control, single-flight, cooldown, status, retry, restore/conflict proof |
| Tasks Table | Full working viewport, usable horizontal adaptation, no clipping/overlap |
| Tasks Calendar | Same Tasks shell and state; no navigation island |
| Task time | Exact start/end/timezone persists and appears in Calendar/cards |
| Task drag | Free smooth movement, two-axis board auto-scroll, atomic order, undo, accessible moves |
| Navbar | Reference-quality floating dock, Create orb, adaptive layouts, no stranded destinations |
| Docs Tags | Create/assign/filter/rename/delete/relaunch/sync |
| Doc reorder | Full-document auto-scroll, drop indicator, undo, large-doc performance |
| Formatting bar | IME anchored, scrollable, expandable, selection-aware, Core features persist and export |
| Chat | Compact empty state, expandable contextual bar, robust IME/draft/send/error behavior |
| Cloud | Config/auth/authorization/sync/push states accurately distinguished and exercised |

## 7. Test inventory that must exist

### Unit/domain

- settings reducer/validation and slider commit behavior;
- font mapping/fallback selection;
- handle normalization/reserved/collision error mapping;
- Vault state transitions and key invalidation mapping;
- sync cooldown/single-flight/timeout;
- task timestamp/timezone validation;
- Tasks view-state restoration;
- tag normalization and assignment;
- document style commands, undo/redo, Markdown loss reporting;
- drag reorder command and cancellation;
- backup/snapshot round-trip for every new field.

### Instrumentation/UI

- biometric enrollment intent routing and Vault prerequisite;
- FLAG_SECURE recreation;
- Settings control → relaunch behavior;
- Tasks Calendar stays in Tasks;
- exact time picker with All day on/off;
- Table and Board at compact widths;
- tag create/assign/filter;
- toolbar survives IME and keeps selection;
- block and task drag auto-scroll;
- bottom dock insets and destination state;
- Chat composer with Gboard-like IME behavior;
- process recreation for active mutations.

### Cloud integration

- Supabase RLS and handle RPC;
- Credential Manager sign-in;
- AuthorizationClient Drive access;
- appDataFolder restore;
- Firebase registration/rotation;
- failure injection for offline, 401/403, conflict, quota, and corrupt snapshot.

## 8. Completion language

Do not use complete, fully functional, production-ready, finished, or Done until all applicable hard gates pass.

Allowed truthful states:

- Designed — contract exists, no implementation claim.
- Implemented, unverified — source exists but required proof is missing.
- Verified on emulator — list exact device/profile and gaps.
- Verified on physical device — list device/OS and gaps.
- Done — all applicable automated, device, visual, persistence, accessibility, security, and cloud gates passed after the final fix.

If a limitation cannot be fixed, finish all independent in-scope work first, then report:

- reproduction;
- root cause;
- user impact;
- attempts;
- reason it remains;
- options/tradeoffs;
- recommended decision.

Never silently downgrade behavior, retain a fake control, or call configuration “working.”

## 9. First command for the implementation agent

Start by reconciling the authoritative contract:

1. update root AGENTS.md and codex-handoffs/AGENT-JOB.md to retire Canvas;
2. inventory the dirty tree and capture a checkpoint;
3. create the source/settings wiring matrix;
4. implement Phase 0 and Phase 1;
5. continue autonomously through the execution order;
6. stop only for a design-level conflict, new external authority, missing service access that cannot be simulated, or an irreversible operation outside the authorized PRE_BETA test scope.

The goal is not to make every screen look busy. The goal is a calm, premium application in which every visible control does exactly what it promises.
