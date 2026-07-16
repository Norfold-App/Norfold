# Norfold Agent Job — Authoritative Execution Contract

**Current release stage:** `PRE_BETA`  
**Authority:** Applies to every agent implementing, reviewing, testing, or documenting Norfold  
**Product definition:** [`NORFOLD-CURRENT-STATE-AND-PRODUCT-SPECIFICATION.md`](NORFOLD-CURRENT-STATE-AND-PRODUCT-SPECIFICATION.md)  
**User responsibilities:** [`USER-JOB.md`](USER-JOB.md)

## 1. Mission

Finish one target area at a time until it is functionally correct, visually clean, durable within the current release stage, and proven at the interaction level. Do not optimize for checked boxes, source volume, or the appearance of progress. Optimize for a product surface the user can actually trust.

User comments, opinions, screenshots, and competitor references are product evidence. Analyze the underlying need and conflicts before acting. Do not blindly stack every referenced control into Norfold. When two ideas remain plausible, keep both as explicit pre-beta experiments over shared domain primitives so the owner can compare them without maintaining two unrelated engines.

## 2. Required reading order

Before implementation:

1. Root `AGENTS.md`.
2. This file.
3. `USER-JOB.md`.
4. `NORFOLD-CURRENT-STATE-AND-PRODUCT-SPECIFICATION.md`.
5. `COMPLETION_STATUS.md` and the target's active acceptance checklist.
6. Relevant source, tests, stored screenshots, and architecture graph.

`MASTER_ORDER.md` still supplies the universal hard gate and dependency history. Older prompts are historical requirements, not proof that the current product is complete. Newer direct user decisions and this contract supersede conflicting old product assumptions.

## 3. Release-stage and migration gate

### Current rule: PRE_BETA

- Development data is disposable.
- Do not spend work preserving arbitrary old development schemas unless the user explicitly requests it.
- For incompatible Room/domain changes, create the correct current schema and use a clean install or destructive reset on emulator/test devices.
- Never clear data on an unspecified physical device, shared environment, production service, or user-owned cloud location without explicit authorization.
- Current-schema persistence, backup encoding, sync snapshot inclusion, clean-install tests, and round-trip tests still matter. “No migration work” does not mean “no persistence tests.”
- Before clearing a development device, state the package and target and capture/export anything the user asked to retain.

### Beta trigger

Treat any explicit statement such as **Beta**, **beta testing**, **release candidate**, **outside testers**, or **production distribution** as a release-stage trigger.

Immediately notify the user:

> Beta gate detected. Previous development builds allowed destructive data resets and do not promise upgrade compatibility. Before distribution, Norfold needs a frozen baseline schema plus migration, backup/restore, rollback, and upgrade testing. May I activate the Beta migration gate and implement that work?

Do not silently activate or skip the gate. If permitted:

1. Update `Current release stage` in root `AGENTS.md`, this file, and `USER-JOB.md` to `BETA`.
2. Freeze and document the first supported schema/snapshot baseline.
3. Remove destructive production fallback.
4. Inventory every Room table and serialized snapshot field.
5. Add migration and upgrade fixtures from every distributed beta version.
6. Test clean install, sequential upgrade, direct supported upgrade, backup restore, encrypted sync restore, process death, rollback/failed migration, and data integrity.
7. Record the supported upgrade window and evidence in `COMPLETION_STATUS.md` and release notes.

Before the first external beta, old internal development versions may still reset rather than migrate unless the owner requests preservation. From the first distributed beta onward, every shipped schema change requires a migration.

## 4. Docs architecture and retired workspace Canvas

The separate workspace Infinite Canvas is retired. Remove its destination, nodes, connectors, commands, persistence, backup/sync fields, and user-facing copy. Do not preserve it as a hidden experiment. Norfold Docs retains two surfaces over one block document:

| Surface | Purpose | Boundary | Export/conversion promise |
|---|---|---|---|
| Flow | Writing and semantic documents. | Reflowing width; pages are derived. | Best editable DOCX/ODT/HTML/Markdown path; deterministic PDF pagination. |
| Bounded Document Canvas | Resumes, letters, proposals, forms, designed reports. | Defined A4/Letter/custom pages or artboards. | Exact PDF; editable document export with explicit fidelity limits; Norfold-native round trip. |

Flow and Bounded Document Canvas use stable block IDs, content, attachments, links, comments, history, styles, typed commands, and selection semantics. Layout is a mode-specific projection. Do not fork content into unrelated storage models.

### Conversion rules

- Flow → Bounded: paginate into editable frames and pages; preserve reading order and semantic styles.
- Bounded → Flow: derive reading order and report overlap, rotation, absolute-position, group, connector, and font losses before committing.
- Bounded → PDF: layout-faithful output from the same page engine as preview.
- Bounded → DOCX/ODT: offer `Editable` and `Layout faithful` profiles; never imply both are perfect when the target format cannot preserve the same structure.
- Every conversion is previewable, cancellable, and one undoable command while pre-beta experiments are in the app.

### Visual-state rule

View mode must render a clean composition. Do not permanently encase every block. Bounds, handles, snap guides, resize dots, layer badges, and edit chrome appear only for hover where supported, selection, multi-selection, or editing. Locked or linked status may use a quiet semantic indicator only when it conveys necessary information.

## 5. Unified search/sidebar direction

Implement one visually unified sticky navigation/search block at the sidebar top, not one overloaded control.

- Workspace switcher/identity, search/command field, and navigation share a coherent container.
- Search retains a real input role; navigation remains a browsable hierarchy.
- While querying, grouped search/command results replace the sidebar body below the sticky header.
- Clearing search restores the prior expanded groups, selection, and scroll position.
- Back first exits result/detail state, then closes search/sidebar according to platform conventions.
- Global Spotlight remains a first-class surface and uses the same search index/command registry.
- Compact phone, tablet, desktop, keyboard, TalkBack, empty, loading, error, and long-result states require proof.

This improves visibility and reduces duplicate top controls without hiding navigation behind search or making one ambiguous field do both jobs.

## 6. Target-area execution loop

### A. Establish truth

- Read the current implementation and tests; use the architecture graph or symbolic tools for relationships.
- Inspect `git status` and preserve unrelated user changes.
- Reproduce the defect or capture the current surface before editing.
- Define the target area's user jobs, invariants, edge cases, and visible acceptance states.
- Identify conflicts between old prompts, current code, references, and new user direction.

### B. Design the smallest coherent system

- Fix root causes and shared primitives before patching repeated symptoms.
- Reuse typed domain commands and persistence boundaries.
- Keep phone, tablet, desktop-class, accessibility, offline, and process-death behavior in the design.
- If two product ideas need comparison, expose them as named Labs choices backed by shared data and commands.
- Do not widen into unrelated features; moving among files is allowed when required to finish the same workflow correctly.

### C. Implement completely

- No stubs, placeholder behavior, swallowed errors, or unfinished production branches.
- Preserve all unrelated work in a dirty tree.
- Add defensive error handling around storage, URIs, export, network, identity, and hardware constraints.
- Make compound edits atomic and undoable.
- Keep current-schema backup/sync representation correct even during pre-beta resets.
- Update active documentation when the product contract changes.

### D. Prove it

At minimum for Android UI work:

1. Relevant unit tests.
2. `:apps:android:testDebugUnitTest`.
3. `:apps:android:assembleDebug` with the required JDK environment.
4. Relevant instrumentation tests on an emulator/device.
5. Install the exact built APK.
6. Perform the actual gestures, typing, saving, reopening, Back/cancel, undo/redo, and failure paths.
7. Inspect screenshots at original resolution in Light and Dark.
8. Check narrow phone, rotation/landscape, large font, and keyboard.
9. Check tablet/desktop-class behavior when the target is adaptive.
10. Run accessibility semantics/TalkBack checks for custom interactions.
11. Re-run focused tests after the final visual fix.

Add target-specific stress, persistence, import/export, offline, process death, and performance tests. A successful build is evidence only for compilation.

## 7. Hard completion gate

Do not say **complete**, **fully functional**, **finished**, **production-ready**, or mark an acceptance item Done unless all applicable conditions pass:

- Every target user job works through the final persisted/reopened outcome.
- No known visible defect remains in the target surface.
- View mode is visually calm and free of editing cages/chrome.
- No clipping, overlap, unreachable action, stale state, or ambiguous navigation remains at tested sizes.
- Empty, loading, error, long-content, and partially populated states are handled.
- Light and Dark proof exists.
- Phone plus applicable tablet/desktop proof exists.
- Keyboard/IME, Back, rotation, process recreation, undo/redo, and accessibility behavior pass where applicable.
- Automated tests and build pass after the final change.
- Data survives the current release-stage persistence contract.
- Removed/renamed behavior has search/grep proof.
- Limitations are documented accurately.

If a gate cannot be run, report the feature as `Implemented, unverified: <missing proof>`, never Done.

## 8. Defect and limitation handling

The agent may skip a blocked subproblem temporarily and work on independent parts of the same target. It may also edit several files or layers to eliminate the root cause. It must not hide the skipped item or substitute unrelated work.

After all safe independent work is done, report each unresolved limitation with:

- Reproduction/evidence.
- Root cause or best-supported hypothesis.
- User impact and affected modes/formats/devices.
- What was attempted.
- Why the limitation cannot be resolved in the current scope.
- Options with tradeoffs and a recommended decision.

Design-level failures—mode semantics, irreversible data loss, format fidelity, account promise, license, billing, or release architecture—require user direction before locking in a divergent solution.

## 9. Reporting contract

Every completed work report contains:

- Exact target and outcome.
- Files changed.
- Tests/builds run and exact result.
- Device/emulator and interaction proof.
- Light/Dark/adaptive/accessibility coverage.
- Data reset or migration behavior.
- Known limitations and unverified items.
- Commit hashes if commits were requested or required by the active handoff.

Never bury a failed test, missing device, skipped scenario, or destructive reset in a general success statement.
