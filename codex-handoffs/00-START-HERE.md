# START HERE — authoritative session instruction for Codex

**This file is absolute for this session. Follow it top-to-bottom. It overrides any ad-hoc instruction.**

You are working in the Norfold Android repo (`com.norfold.app`, module `apps/android`). There is currently **no record of what has already been completed** — all prior work is uncommitted on top of a single "Initial Norfold release" commit. Your first job is to fix that, then do one focused piece of work. Commit at every phase boundary.

Notes on git: the repo is private on GitHub — that does **not** affect committing (commits are local). Do **not** push unless a remote + auth are already configured and I ask you to; leave commits local otherwise.

---

## Phase 0 — Checkpoint the current state (do this first, before anything else)
1. `git status` to see the working tree.
2. Commit the current state as a baseline so there's a diff boundary:
   `git add -A && git commit -m "checkpoint: uncommitted working state before status audit"`
3. Confirm it committed (`git log --oneline -3`).

## Phase 1 — Build a completion tracker (so future work is legible)
1. Read `codex-handoffs/MASTER_ORDER.md` in full (run order, ownership fences, and the universal Definition-of-Done GATE).
2. For **each of the 22 steps**, audit the **current code** against that prompt's own "Definition of Done." Keep it targeted — only inspect the files each prompt names; do NOT exhaustively re-read the whole app.
3. Run `./gradlew :apps:android:assembleDebug` once and record whether the current tree builds.
4. Create `codex-handoffs/COMPLETION_STATUS.md` — a table with columns: **Step | Prompt | Status (Done / Partial / Not started / Unknown) | Evidence (file:symbol you checked) | Gaps remaining**. Be honest: mark **Partial** wherever the DoD is not fully met, and list exactly what's missing. Put the build result at the top.
5. Commit: `git add -A && git commit -m "docs: add COMPLETION_STATUS audit of handoff prompts"`.

## Phase 2 — Do the Docs-editor completion pass
1. Read `codex-handoffs/notes-charts-popups/07-docs-editor-completion.md` in full, including its ⛓ banner and the universal GATE it references.
2. Check its dependencies (steps 1, 7, 8) against your `COMPLETION_STATUS.md`. If a dependency is only **Partial** in a way that blocks 07, note it in the status doc and do the minimum needed to unblock — or, if it's a big gap, **pause and report** instead of guessing.
3. Implement `07` **fully** — no stubs, no TODOs. The input bugs (character transposition, no auto-scroll, saving-jump) are phone-first: **test on a phone-sized emulator by actually typing**, not by reading code.
4. Update `COMPLETION_STATUS.md`: mark step 22 with its result and any deferrals.
5. Commit the work in small, logical commits with clear messages (e.g. `fix(docs): stop character transposition while typing`, `feat(docs): floating formatting toolbar`, `refactor: rename user-facing Notes -> Docs`).

---

## Absolute rules
- **Commit at each phase boundary and after each logical unit of work.** Never leave a large uncommitted pile again.
- **Satisfy the universal Definition-of-Done GATE** in `MASTER_ORDER.md` for anything you implement: it must build (`assembleDebug`), run on the emulator, have every DoD checkbox individually verified, and `grep`-prove any deletion/rename.
- **Do not self-certify from reading code.** Verify on device.
- **Report at the end of each phase:** what you committed (hashes + messages), the build result line, and the DoD checklist with ✅/❌ per item. For Phase 1, the report is the `COMPLETION_STATUS.md` summary.
- If you get blocked or a dependency isn't really done, **stop and report** — do not mark things complete to move on.
