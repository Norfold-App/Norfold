# START HERE — Norfold current execution entrypoint

**Release stage:** `PRE_BETA`

**Latest implementation evidence:** `IMPLEMENTATION-EVIDENCE-2026-07-15.md`
**Terminology migration contract:** `TERMINOLOGY-MIGRATION.md`

Read in this order:

1. Root `AGENTS.md`.
2. [`AGENT-JOB.md`](AGENT-JOB.md).
3. [`USER-JOB.md`](USER-JOB.md).
4. [`NORFOLD-CURRENT-STATE-AND-PRODUCT-SPECIFICATION.md`](NORFOLD-CURRENT-STATE-AND-PRODUCT-SPECIFICATION.md).
5. [`COMPLETION_STATUS.md`](COMPLETION_STATUS.md).
6. [`MASTER_ORDER.md`](MASTER_ORDER.md) and the checklist for the selected target.

The repository may contain substantial user changes. Inspect `git status`, preserve unrelated work, and do not create a checkpoint commit unless the user or active handoff authorizes it.

Current product decisions (the critical wiring contract is the newest authority):

- Retain Flow and Bounded Document Canvas over shared Docs content/commands.
- The separate workspace Infinite Canvas is retired and must not be exposed or revived.
- During pre-beta, explicitly scoped development data may be reset instead of migrated.
- A Beta/release-candidate/outside-tester instruction activates the warning-and-permission migration protocol in `AGENT-JOB.md`.
- Search and sidebar form one coherent sticky top block while keeping search and navigation semantically distinct.
- Finish one target area deeply and do not call it complete until the hard interaction and visible-quality gates pass.

Historical prompts describe useful requirements but are not proof of completion. Use current source, installed-app evidence, and `COMPLETION_STATUS.md` to establish truth.
