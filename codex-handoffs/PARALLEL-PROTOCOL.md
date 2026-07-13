# PARALLEL PROTOCOL — how 4 agents run FIRST-MISSION without colliding

You are one of **up to 4 agents** working the same repo at the same time. This file is the law for how you coordinate. Read it fully before touching code. The goal: **finish every Part of `FIRST-MISSION.md` perfectly, in parallel, with zero clobbering and zero deadlock.**

The techniques here are standard concurrency patterns applied to a shared repo: an **append-only coordination log** (blackboard), **`mkdir`-based mutex locks** (atomic on POSIX — `mkdir` fails if the dir exists, so exactly one agent wins), a **single-holder lease** for the one shared emulator, and **work-stealing** so a blocked agent goes and does other useful work instead of idling.

---

## 0. First agent bootstraps, everyone else waits 10s then joins
The **first** agent to start creates the coordination area (idempotent — if it exists, skip):
```
mkdir -p codex-handoffs/coordination/locks
touch    codex-handoffs/coordination/AGENT_LOG.md
touch    codex-handoffs/coordination/BOARD.md
```
Then every agent **claims an identity**: pick the lowest free id A1/A2/A3/A4 by checking the log, and append a join line (see §3). Re-read the log before assuming an id is free.

---

## 1. The lock primitive (use this for EVERY shared resource)
**Acquire** a lock named `<R>`:
```
mkdir codex-handoffs/coordination/locks/<R>   # SUCCESS = you own it. FAILS = someone else holds it.
echo "<your-id> | $(date -Is) | <what you're doing>" > codex-handoffs/coordination/locks/<R>/holder
```
**Release**:
```
rm -rf codex-handoffs/coordination/locks/<R>
```
**Rules:**
- Never edit a locked resource you don't hold. Never `rm` a lock you don't own **unless** it's stale.
- **Stale lock:** if `holder` is older than **20 minutes** AND that agent has posted nothing to the log since, you may reclaim it — but first append a `RECLAIM` line to the log naming the resource and the dead holder, then take it.
- **Hold locks briefly.** Make the smallest edit, commit, release. Don't hold a hotspot lock while you think.
- **Heartbeat:** while holding any lock, append a `HEARTBEAT` log line at least every ~10 min so others can tell you're alive.

### Resources that MUST be locked
| Lock name | Protects |
|---|---|
| `EMULATOR` | the single running emulator (only one agent drives it at a time — screenshots, typing, interaction) |
| `FILE-BlockNoteEditorScreen` | any edit to `ui/screens/BlockNoteEditorScreen.kt` (the #1 collision hotspot) |
| `FILE-MarkdownWebView` | any edit to `ui/components/MarkdownWebView.kt` (#2 hotspot) |
| `BUILD` | running `./gradlew` (avoid two concurrent Gradle daemons thrashing) — acquire, build, release |

Builder files (`ChartBuilderSheet.kt`, `ChartSpecCodec.kt`, `DiagramBuilderSheet.kt`, new `MathBuilderSheet.kt`, `EmbedMetadataResolver.kt`) are **single-owner by lane** (§2) — no lock needed as long as you only touch your lane's files.

---

## 2. Lane assignment — who does what (minimizes file overlap)

### PHASE A — FOUNDATION (serial, ONE agent, everyone else blocked on it)
**Part 0** rewrites the core of `BlockNoteEditorScreen.kt` (input correctness, floating bar, turn-into, top bar, rename). Everything else builds on it, so it lands FIRST.
- **A1 owns Phase A.** A1 holds `FILE-BlockNoteEditorScreen` for the structural work, does all of Part 0, tests on the emulator, commits, then posts **`PHASE-A DONE`** to the log and releases the lock.
- **A2/A3/A4 during Phase A:** do NOT touch the two hotspot files. Do prep that's safe and independent: A2 scaffolds `MathBuilderSheet.kt` (Part 4) in isolation; A3 scaffolds Mermaid form logic in `DiagramBuilderSheet.kt` (Part 5); A4 works `EmbedMetadataResolver.kt` favicon fetch (Part 3) — all pure new/isolated code, no hotspot edits, no emulator needed yet (unit-test / preview-compose your pieces). Commit your scaffolds. When you need a hotspot edit or the emulator, **wait for `PHASE-A DONE`**.

### PHASE B — BUILDERS (parallel, after `PHASE-A DONE`)
Each lane owns its files; the tiny "insert-dispatch hook" each needs inside a hotspot file is done under that file's lock (grab, add ~10 lines, commit, release).
| Lane | Part(s) | Owns (edit freely) | Hotspot hook (under lock) |
|---|---|---|---|
| **A1** | **Part 1 — Chart** | `ChartBuilderSheet.kt`, `ChartSpecCodec.kt` | `EditableChartBlock` + insert path in `BlockNoteEditorScreen` |
| **A2** | **Part 4 — Math** | `MathBuilderSheet.kt` (new) | Math insert path in `BlockNoteEditorScreen`; typeset in `MarkdownWebView` |
| **A3** | **Part 5 — Mermaid** | `DiagramBuilderSheet.kt` | Mermaid insert path in `BlockNoteEditorScreen`; render in `MarkdownWebView` |
| **A4** | **Part 2 — Table** + **Part 3 — Embed** | `EmbedMetadataResolver.kt` | `NativeTable` region in `BlockNoteEditorScreen`; table CSS + embed card in `MarkdownWebView` |

### PHASE C — BROAD (after Phase B lands)
- **Part 6** (rich text everywhere, nested quotes) touches many files — whoever finishes their Phase-B lane first claims Part 6 by posting `CLAIM Part6` to the log (first claim wins).
- **Part 7** (discovered-gaps sweep) — the next free agent claims it. Log gaps into `COMPLETION_STATUS.md` under "Discovered gaps."
- Remaining agents run **emulator verification passes** (screenshots, Light+Dark) for Parts that are code-done but not yet visually proven.

---

## 3. The shared log — `coordination/AGENT_LOG.md` (append-only, NEVER rewrite)
Every meaningful action = one appended line. Use real timestamps (`date -Is`). Format:
```
<ISO-time> | <agent-id> | <TYPE> | <message>
```
TYPES you must use:
- `JOIN` / `LEAVE` — identity claim / graceful exit
- `LOCK <R>` / `UNLOCK <R>` / `RECLAIM <R>` — resource ownership changes
- `EMU-REQUEST` — "I want the emulator next" (queue politely, FIFO by request time)
- `EMU-HANDOFF` — "I'm done with the emulator, it's free" (release `EMULATOR` right after)
- `NEED <file/thing> from <agent>` — you're waiting on someone; then **go do other work** (§4)
- `PART <n> DONE` / `PHASE-A DONE` — completion signals others may depend on
- `HEARTBEAT` — alive + what you're on
- `BLOCKED <reason>` — genuine blocker needing the user; keep going elsewhere if possible

`coordination/BOARD.md` is the at-a-glance state: a table of Part → owner → status → screenshot path. Update your own rows; append to it, don't clobber others' rows (if two of you must edit BOARD.md at once, lock `FILE-BOARD`).

**The emulator handshake you described, concretely:** agent holding `EMULATOR` does its screenshots; another agent that needs shots posts `EMU-REQUEST` and switches to other work; when the holder finishes it posts `EMU-HANDOFF` + `UNLOCK EMULATOR`; the earliest `EMU-REQUEST`er then acquires `EMULATOR` and drives.

---

## 4. Deadlock / blocking rule — NEVER idle, steal work instead
If a resource you need is locked or you're waiting on another agent:
1. Post `NEED …` to the log.
2. **Immediately switch to any available work that doesn't need that resource** — a different Part in your phase, writing tests, prepping the next lane's isolated code, or an emulator-free code task. There is always non-blocked work until the very end.
3. Only truly wait (poll the log every ~60s) if *every* remaining task needs the one locked resource. That should be rare.
This guarantees forward progress: a lock contention never stalls the whole team.

---

## 5. Git model (avoid stepping on commits)
- Work on a shared integration branch `mission/first` (A1 creates it off the checkpoint commit; others check it out). Commit **small and often**, per logical unit, prefixed with your id and Part: `A3 Part5: per-node color in diagram builder`.
- **Pull/rebase before you start each new unit** so you're on top of others' commits. If two agents share a working tree (single checkout), the file-locks in §1 are what actually prevent clobbering — respect them religiously; git alone won't save you.
- Never force-push. Never `git reset --hard` shared history. Don't push to origin at all unless the user says so.

---

## 6. Definition of "done for the whole mission" (the only stop condition)
You may NOT stop while any of these is false:
- Every Part 0–7 has its DoD **fully ticked** in `COMPLETION_STATUS.md`, each item marked ✅ **with a screenshot path** proving it on a phone emulator (Light + Dark).
- `./gradlew :apps:android:assembleDebug` is green on `mission/first`.
- No `BLOCKED` line in the log is still unresolved (or, if it needs the user, it's clearly summarized at the top of `BOARD.md`).
If you finish your lane and everything above is already true → post `LEAVE`, stop. If it's not all true → **claim the next unfinished thing** (unproven screenshots, an untested Part, a discovered gap) and keep going. Nobody stops while work remains.

---

## 7. Keep-alive & battery safety — ONE script, started once by A1, stopped at the very end
Do NOT dedicate an agent to power management. There is a single self-contained script: **`codex-handoffs/keep-awake.sh`**. It keeps the Windows host awake (harmless F15 nudge every 60s) and, unconditionally, **sleeps the host if battery drops below 20% while unplugged**. It changes no Windows power settings, so stopping it is the only cleanup.

**Start it once, at mission start (A1):**
```
nohup bash codex-handoffs/keep-awake.sh > codex-handoffs/coordination/keep-awake.out 2>&1 &
echo $! > codex-handoffs/coordination/keep-awake.pid
```
Record that PID line in `BOARD.md` too. It's WSL-only and drives Windows via `powershell.exe`; the script self-checks that interop works and exits with an error if not (if it errors, note it in the log and continue — the mission still runs, the host just won't be force-kept-awake).

**Because the host can sleep at any moment under 20%,** every agent must **commit work frequently** (you already do, per §5) — an unplugged low battery will suspend the machine without warning, and only committed work survives cleanly. On wake (charger reconnected), re-read `AGENT_LOG.md` and continue.

**Stop it at the very end (mission fully done):**
```
kill "$(cat codex-handoffs/coordination/keep-awake.pid)"
```
Log it as `SYS | keep-awake stopped`. Nothing else to restore.

---

## 8. Screenshot proof still applies to every agent
`FIRST-MISSION.md`'s rule is per-agent: a green build is not success. Your Part isn't done until you (or the agent you handed the emulator to) have **screenshots, Light + Dark, saved under `codex-handoffs/screenshots/<part>/`**, and someone eyeballed them for misalignment/clipping/overlap/crash/wrong behavior. Wire the screenshot into the `COMPLETION_STATUS.md` tick.
