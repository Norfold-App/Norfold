# QA handoff — document-contract mission (PR #2) + premium-feel audit

**Date:** 2026-07-16
**Scope:** Everything merged in PR #2 (`mission/document-contract`) plus the Phase 0 auth work: generic document storage, task Docs in the full structured editor, calendar-event docs, markdown-webview retirement, Backup V3, and the in-app 6-digit email verification flow.
**Nothing in this mission has been manually tested yet. You are the first tester.**

## How to report

This is not a pass/fail checklist run. For every surface you touch:

1. **Screenshot every state** you reach — normal, empty, loading, error, keyboard-open. Save to `codex-handoffs/screenshots/qa-document-contract/` with descriptive names (`task-docs-editor-open.png`, `auth-code-entry-error.png`).
2. **Log every fault** in `codex-handoffs/QA-DOCUMENT-CONTRACT-FINDINGS.md` — one row per finding: surface, steps to reproduce, expected, actual, severity (crash / data loss / broken / ugly / friction), screenshot ref.
3. **Log behavior notes** even when nothing is broken: anything that felt slow, abrupt, silent, confusing, or cheap. "It worked but felt X" is a valid and wanted finding.
4. Do **not** fix anything during the QA pass. Record first; fixes are a separate mission so we can prioritize.

## A. Functional surfaces to exercise

### A1. Email auth (Supabase is fully configured — real emails send)
- Fresh signup → 6-digit code arrives from "Norfold" → enter code in-app → lands in the app signed in.
- Wrong code, expired code (wait >60 min or fake it), code resend (note: resends within 30 s are silently rate-limited server-side — observe what the UI does).
- Sign out → sign back in with email+password only (no code should be required).
- Sign-in with an unverified account → should route back to code entry.
- Forgot password → recovery code → new password → old password rejected, new one works.
- Weak password at signup (Supabase requires 8+ chars with upper/lower/digit/symbol) → observe the error message the user sees. Verbatim server errors are a finding.
- Kill the app mid-flow at every step and relaunch — where do you land?

### A2. Notes in the structured editor
- Create, edit, close, reopen — everything persists exactly (block order, formatting, layout mode).
- Every block kind: paragraph, headings, bullet/numbered/todo lists, quote, callout, container/columns, divider, code, table, image, file, embed, chart, math, mermaid.
- Freeform/canvas layout: place blocks, restart app, placements survive.
- Markdown is retired as a mode: confirm no webview preview or source-mode remnants are reachable anywhere. Import/export of markdown files should still work (lossy is expected — note *how* lossy).

### A3. Task Docs
- Open a task → Docs → the full block editor opens (same editor as notes, not a text field).
- A task that had an old plain-text description: first open converts it into blocks once; the text must not be lost or duplicated.
- Edit the doc → the task's description/summary shown on cards and lists updates as a plain-text projection.
- Delete the task → doc goes with it; no orphan rows, no crash.

### A4. Calendar-event docs
- Open an event from Day, Week, and Agenda views → attach/open its doc → edit → reopen from a different view, same content.
- Event description on calendar cards stays a derived summary.
- Delete the event → doc gone.

### A5. Backup & restore (V3)
- Full backup → wipe data (or fresh install) → restore → notes, tasks + their docs, events + their docs, freeform placements, boards, goals all intact. Block IDs must survive: freeform layouts must not collapse or orphan.
- Encrypted backup round trip with a passphrase.
- Restore a V1/V2-era file if any exists → must be *rejected cleanly with a readable message*, not crash or half-import.
- Google Drive sync and folder-provider sync use the same codec — run one cycle of each if configured.

### A6. Cross-cutting
- Workspace deletion clears note/task/event docs without crashing.
- Global search finds content typed into task docs and event docs, not just notes.
- Rotation, split-screen, compact vs expanded width on every screen above.

## B. Premium-feel audit (research-backed criteria)

Grade every surface in section A against these. Each miss is a logged finding, severity "friction" or "ugly". Sources: Material 3 motion guidance, Android haptics guidelines, Nielsen Norman Group.

1. **Destructive actions.** Deleting a note/task/event/block: is it undoable via snackbar? A confirm dialog for routine deletes is a finding; a *silent, unrecoverable* delete is a severe finding.
2. **Haptics.** Long-press pickups, drag reorders/snaps, toggle/complete actions, save/confirm moments — is there appropriate subtle haptic feedback, or nothing? Buzzy/harsh haptics are worse than none — note those too.
3. **Empty states.** Every list you can make empty (notes, tasks, board columns, calendar day, search results, filtered views): designed message + call to action, or blank void? Does "No results" flash *before* content loads?
4. **Loading states.** Auth buttons during network calls: inline progress and disabled, or frozen/tappable? Anything showing a spinner for sub-second work? Long operations (restore, sync) — progress shown?
5. **Motion.** List insert/delete/reorder: animated or teleporting? Sheets, menus, screen transitions: eased/springy or instant cuts? Predictive back?
6. **Sync/offline feedback.** Any indication of syncing / synced / offline / failed? Silent sync failure is a severe finding.
7. **Error copy.** Every error you can trigger: does it say what happened and what to do, in plain language — or is it a raw exception/server string?
8. **Editor feel.** Keyboard: does the toolbar sit above the IME, does content stay visible while typing (ime insets)? Selection/drag feedback in the editor? Autosave: quiet and trustworthy, or noisy/unclear?
9. **Resend-code button.** Should show a cooldown (server enforces 30 s). If it looks tappable and silently does nothing, log it.

## C. Known items — do not report as new

- Password policy errors surface Supabase's raw message (already on the fix list).
- Resend cooldown UI does not exist yet (log observed behavior, but it is a known gap).
- Backup V1 files are intentionally unsupported (pre-beta, no migration promised). Only *how* the rejection is presented is in scope.
- The web app is a visual prototype; out of scope entirely.

## Exit criteria

QA is complete when: findings file exists with every fault and behavior note, screenshots cover every A-surface in every reachable state, and each B-criterion has been graded per surface. Deliver findings ranked: crash / data loss → broken → ugly → friction.
