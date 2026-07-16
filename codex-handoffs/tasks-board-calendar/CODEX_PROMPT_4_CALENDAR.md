# Codex Task 4 of 4 — Unify the calendar + infinite smooth scroll (Day & Week)

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 6).** You own the calendar unification + **Day/Week smooth scroll + the pager mechanism** in `PlanningScreens.kt`. `../tasks-notes-overhaul/07` (later) **reuses your pager** for the header-overlap fix + Month view — leave those to it and make the pager helper reusable. Satisfy the universal Definition-of-Done GATE before declaring done.

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Do it fully and exactly. No stubs.

## House rules
- Theme tokens only, never hardcode hues. Light + Dark both correct.
- Don't touch nav graph or DB. Reuse existing ViewModel methods.

## The problem
There are **two** separate calendar implementations, and both scroll **period-by-period (paged)** instead of smoothly:
1. `apps/android/.../ui/screens/PlanningScreens.kt` → **`CalendarWorkspaceScreen`** (line ~213). This is what `Destination.Calendar` shows (used by both the sidebar "Calendar" and "Tasks ▸ Calendar"). It has Month/Week/Day/Agenda modes driven by an `AnimatedContent` that slides one period per swipe (lines ~239–286).
2. `apps/android/.../ui/tasks/TasksBoardScreen.kt` → **`TaskCalendarView`** (line ~1730). A second, in-tasks-workspace calendar (Week/Month), also paged via `detectHorizontalDragGestures` shifting ±7 days / ±1 month (lines ~1762–1780).

## Goals
1. **One shared calendar.** `CalendarWorkspaceScreen` is the canonical one. Build the new adaptive Week view (see "Week view" section below) into it. You may reuse the 7-day-strip scaffolding from `TaskCalendarView`'s week layout (`CalendarWeekView` at ~1823) as a starting point, then **remove/retire `TaskCalendarView`** (and route the Tasks-workspace "Calendar" view to `Destination.Calendar` / `CalendarWorkspaceScreen` instead of the local one). If the Tasks screen currently renders `TaskCalendarView` inline (dispatched around line ~358), replace that with a navigation to `Destination.Calendar` or a direct call to the shared composable — do not keep two.
2. **Infinite smooth scrolling for Day view.** The Day view must scroll **continuously and vertically across day/month boundaries** — scrolling past the end of one day flows into the next day, and it crosses month boundaries naturally (Jul 31 → Aug 1). Replace the paged `AnimatedContent` swipe for Day with a real scroll:
   - Use a `LazyColumn` with a large symmetric day range around today (e.g. `-180..+180` days, or an unbounded feel via a big window), each day rendered as a labeled section (date header + that day's hour timeline / events).
   - Keep `selectedDate`/`calendarDefaultView` in sync as the user scrolls (update selected to the top-most visible day), but the motion itself is smooth, not one-day-per-swipe.
3. **Week view = the adaptive time-grid (see next section).** This SUPERSEDES the earlier "vertical list of week strips" idea. One week is visible at a time with a fixed header; the hours scroll vertically; horizontal swipe moves to the previous/next week smoothly (continuous feel, no jarring page snap).
4. **Month & Agenda** can stay as they are (Month = grid, Agenda = list) — this task is about Day and Week.

## Week view — layout + adaptive hour rail (build this exactly)

Match the reference mockup (`/mnt/c/Users/sheik/Downloads/Zielorya/Calendar view in Tasks.png`). **Three stacked regions; only the bottom one scrolls vertically:**

```
┌───────────────────────────────────────────────┐
│ 📅 July 2026              [ Week | Month ]     │  ← FIXED. Never scrolls.
├─────┬─────┬─────┬─────┬─────┬─────┬─────────────┤
│ Sun │ Mon │ Tue │ Wed │ Thu │ Fri │ Sat        │  ← STICKY day-header row.
│  5  │  6  │  7  │  8  │  9  │ 10  │ [11]       │     Selected day pill-highlighted.
├─────┴─────┴─────┴─────┴─────┴─────┴─────────────┤
│  ▓▓▓ Draft roadmap ▓▓▓▓▓▓▓▓                    │  ← MULTI-DAY BARS band.
│      ▓▓▓ Polish workspace ▓▓▓▓▓▓▓              │     Sticky + compact.
├─────┬─────┬─────┬─────┬─────┬─────┬──────┬──────┤
│rail │     │     │     │     │     │      │       ← TIMED GRID: 7 day columns ×
│ …   │  ●  │     │     │  ●  │     │      │          adaptive hour bands.
└─────┴─────┴─────┴─────┴─────┴─────┴──────┴──────┘     Scrolls vertically; rail scrolls in lockstep.
```

Region A — **fixed chrome:** the `July 2026` label + `Week/Month` segmented toggle. Does not move when the grid scrolls.

Region B — **sticky day-header row:** `Sun 5 … Sat 11`. Tapping a day selects it (drives the day-detail list below the calendar — the existing "Saturday, July 11 · 5 tasks" section). Sticky so it stays visible while hours scroll.

Region C1 — **multi-day / all-day bars:** tasks that have a date *range* but **no clock time** (e.g. Draft roadmap Jul 5–17) render as horizontal capsules spanning their day columns (Gantt-style), colored by task accent. Kept compact and sticky directly under the day headers. Overflow beyond ~3 rows collapses to a "+N more" affordance.

Region C2 — **timed grid (the scrolling body):** tasks that have an assigned clock time are placed as chips in their `(day column, hour band)` cell. A **thin hour rail** labels the bands. **The rail and grid are one vertical scroll** so labels always line up.

### The adaptive hour rail — algorithm (this is the core; do NOT render a flat uniform 24h axis)

Build the bands from the timed tasks actually present in the visible week:

1. Collect every timed task's start (and end, if present) across the 7 days → minutes-of-day.
2. **Collapse empty stretches:** any maximal run of consecutive hours with **zero** tasks becomes **one thin band** labeled as a range (`12–6 AM`, `5–11 PM`), rendered at a small fixed height (~24dp).
3. **Expand busy stretches:** hours that contain task starts get fine bands, each normal height (~56dp), labeled by start hour (`9 AM`, `10 AM`).
4. **Band boundaries snap to real task times** — dividers land where tasks begin, not on a fixed 3-hour grid. (This is why "those hours change" — they're derived, not hardcoded.)
5. **Density sets granularity.** Let `maxPerDay` = the greatest count of timed tasks in any single day of the visible week:
   - `maxPerDay ≤ 2` → coarse 3-hour bands (light week fits on screen, minimal/no scroll).
   - `3–5` → 2-hour bands around active periods.
   - `≥ 6` → 1-hour bands across the busy window so overlapping chips get vertical room; grid grows taller and scrolls.
   This is the "adaptive compactness": compact when light, expands only where a day is dense.
6. If a week has **no** timed tasks at all, show a single compact "No timed tasks" band (still show the multi-day bars above).

### Rail side
Default the hour rail to the **LEFT** edge (matches Google/Outlook/Apple Calendar convention). The user floated "right" — keep it a single alignment constant so flipping to the right edge is a one-line change. Add a `// TODO(rail-side)` comment at that constant.

### Week navigation
Horizontal swipe on the grid body = previous/next week, animated smoothly (no hard page snap). Vertical scroll moves through the hour bands. Keep `selectedDate` and the day-detail list in sync with the visible week + selected day.

Keep it simple: "goes to next/previous month's day view" should fall out naturally from a continuous day list — you do NOT need infinite paging engines, just a wide `LazyColumn` range that feels endless.

## Details to preserve
- Events come from `planningEvents(state, accent, mutedAccent)` (PlanningScreens.kt ~298) — keep using it; filter per day/week as the current `DayTimeline`/`WeekPanel` do.
- The segmented control (Month/Week/Day/Agenda) at ~227 stays; selecting a mode still writes `calendarDefaultView` via `patchSettings`.
- `Today`→Day and `Upcoming`→Agenda entry points (sidebar) must still land on the right mode.
- Tapping a task/event still calls the existing open/click handler.

## Constraints
- Theme tokens only.
- No two calendars after this — `TaskCalendarView` retired.
- Don't regress Month/Agenda.

## Definition of Done
- [ ] Only one calendar implementation remains; `TaskCalendarView` is gone and the Tasks workspace routes to the shared calendar.
- [ ] Week view matches the mockup: fixed `July 2026`+toggle, sticky day-header row, sticky multi-day bars band, vertically-scrolling timed grid.
- [ ] The hour rail is adaptive — empty stretches collapse to thin range bands, busy stretches expand, boundaries snap to task times, granularity scales with `maxPerDay`.
- [ ] Rail defaults to the left, behind a single alignment constant with a `// TODO(rail-side)`.
- [ ] Horizontal swipe changes week smoothly; vertical scroll moves through hours; `selectedDate` + day-detail list stay in sync.
- [ ] Day view scrolls smoothly and continuously across days and months (no one-day-per-swipe paging).
- [ ] Month + Agenda still work; mode switching + Today/Upcoming entry points still work.
- [ ] Builds clean; Light + Dark correct.
