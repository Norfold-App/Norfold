# Norfold User Job — Current Development Guide

**Current release stage:** `PRE_BETA`  
**Audience:** Product owner, hands-on tester, and anyone providing references or acceptance feedback  
**Companion:** [`AGENT-JOB.md`](AGENT-JOB.md)

## 1. What the user owns right now

The user's job is to define the product outcome, provide real-world judgment, protect credentials and valuable data, and test the parts that an emulator or source review cannot prove. The agent owns implementation and technical verification; the user does not need to diagnose code.

For each work session, give the agent one target area and the outcome that matters. Good examples are “make the bounded Docs editor comfortable for resumes,” “finish Docs organization,” or “remove all visible defects from the task detail screen.” References and opinions are evidence, not rigid pixel-copy orders unless explicitly stated.

## 2. Pre-beta data rule

Norfold is currently pre-beta. Development databases and emulator/device test data are disposable while schemas and product models are still changing.

- Do not store the only copy of valuable notes in a development build.
- Export or back up anything worth keeping before installing a new development APK.
- Expect the agent to clear app data or reinstall cleanly after incompatible schema changes.
- A clean reset means the old local database, settings, cached attachments, sessions, and test content may be erased.
- Cloud snapshots created by development builds should also be treated as test data unless separately protected.

The first time the project is declared **Beta**, **release candidate**, or intended for outside testers, tell the agent explicitly. The agent must then warn that the current pre-beta policy allowed destructive resets and ask permission to establish the migration baseline. From that point forward, destructive production fallback is forbidden and schema migrations, upgrade fixtures, backup compatibility, and rollback tests become release gates.

Recommended phrase:

> This is now a Beta release. Activate the migration gate, explain the data risk, and prepare the first stable upgrade baseline before distribution.

## 3. Before asking an agent to implement a feature

Provide what is available; missing minor details should not block work.

1. Name one target surface or workflow.
2. Describe the user's job-to-be-done in plain language.
3. Attach screenshots, recordings, sample documents, or competitor references when visual behavior matters.
4. Identify anything that must be preserved.
5. Say whether alternative implementations should remain available as experiments.
6. Identify the device or screen class that matters most.
7. Mention any real failure already observed and how to reproduce it.

Do not put passwords, OAuth secrets, signing keys, recovery keys, service-role keys, or registrar credentials in chat, source files, screenshots, or the repository. The user owns Play Console, domain registrar, DNS, Supabase, Google Cloud, billing, and legal account access. Supply public identifiers or redacted evidence only when sufficient.

## 4. How to give useful feedback

Separate feedback into three kinds:

- **Defect:** Something is broken, clipped, confusing, inconsistent, inaccessible, or visually uncomfortable.
- **Required outcome:** A capability or behavior the product must provide.
- **Idea/reference:** A possible solution worth comparing, not automatically the final design.

For a visible defect, include:

- Screen and mode.
- Light or Dark theme.
- Device/orientation and font scale if relevant.
- Exact actions taken.
- What happened.
- What should have happened.
- Screenshot or short recording with the affected area visible.

Example:

> Docs, bounded view mode, phone portrait, Dark. Open a saved document and do not select anything. Every text block still has a permanent card outline. The document should read as one clean composition; bounds should appear only when the block is selected or editing is active.

The agent must analyze the cause and choose the most coherent fix. The user does not need to prescribe a specific Composable, database table, or gesture API.

## 5. Canvas/editor evaluation job

During pre-beta, Norfold should expose both Docs surfaces so the owner can compare them with real content:

1. **Flow:** Writing-first, semantic, reflowing documents.
2. **Bounded Document Canvas:** A defined A4/Letter/custom page or artboard with direct positioning and reliable document export.

Test the same representative content in each surface:

- A long class note with headings, lists, tables, images, and links.
- A one-page resume.
- A multi-page proposal or report.
- Mixed English/Bengali text.

Judge each surface on writing comfort, selection clarity, move/resize behavior, visual calm, phone usability, export fidelity, editability after conversion, performance, and whether the mode's purpose is obvious.

For the Bounded Document Canvas, test PDF plus both editable and layout-faithful document export paths. The separate workspace Infinite Canvas is retired and is not an evaluation surface. Report any feature that cannot survive document conversion, such as free rotation, overlap, nested groups, or unsupported fonts.

## 6. Required manual test pass for a targeted area

When the agent says an area is ready for user verification, use a real phone when possible and cover:

- Fresh install or clean reset.
- Normal create, edit, save, close, reopen, and delete paths.
- Back, cancel, undo, redo, and accidental-tap recovery.
- Light and Dark themes.
- Portrait and landscape.
- Keyboard open/closed; long text and rapid typing.
- Offline mode, reconnect, and visible save/sync state.
- Large font and display scaling.
- Long labels, empty data, partial data, and large data.
- Rotation/process recreation where the workflow holds unsaved state.
- Import/export/open/share destinations when relevant.
- No permanent edit bounds, handles, or block cages in view mode.

For tablet/foldable/desktop-class work, add split-screen, resizing, mouse/keyboard, and wide-panel checks. For accessibility-sensitive controls, add TalkBack or request agent-recorded semantic evidence if a full manual pass is not available.

## 7. Search and sidebar acceptance

Search and navigation should appear as one coherent sticky block at the top of the sidebar, but remain semantically distinct:

- Workspace identity/switcher at the top.
- One prominent search/command field immediately below it.
- Navigation content below the field in the same visual container.
- Typing replaces the navigation body with grouped search/command results.
- Clearing or closing search restores the exact prior navigation/scroll/expanded state.
- Global Spotlight remains available outside the sidebar.

The user should test reachability, visual hierarchy, keyboard focus, result opening, Back behavior, no-results state, and whether the combined block remains useful rather than cramped on a narrow phone.

## 8. Decisions the user must eventually make

The agent can recommend defaults, but the owner must decide:

- Final product and domain name after trademark/availability checks.
- Proprietary versus open-source license.
- Free, one-time Pro, subscription, and Team boundaries.
- Whether hosted realtime sync is a launch goal.
- Cloud retention/deletion periods.
- Which document formats are launch requirements: PDF, DOCX, ODT, HTML, Markdown, and Norfold package.
- The acceptable fidelity/editability tradeoff for DOCX export.
- Which experimental editor surface becomes the default after comparison.
- When `PRE_BETA` changes to `BETA`.

## 9. What the user should expect from an agent

An agent should finish one targeted area deeply, preserve unrelated work, run proportionate automated tests, install and inspect the app when visual behavior is involved, record evidence, and report limitations honestly. “Implemented,” “builds,” and “complete” are different claims. Complete is allowed only after the hard acceptance gates in `AGENT-JOB.md` pass.

If the agent finds an unfixable or design-level limitation, it may continue independent work in the same target first, then report the limitation with evidence, impact, and the least harmful alternatives.
