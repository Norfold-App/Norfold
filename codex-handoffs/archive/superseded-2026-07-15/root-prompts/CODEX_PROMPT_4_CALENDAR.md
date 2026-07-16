# Codex Task 4 of 4 — Unify the calendar + infinite smooth scroll (Day & Week)

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
1. **One shared calendar.** `CalendarWorkspaceScreen` is the canonical one. The **Week view inside it should behave like the Tasks-page week view** (`TaskCalendarView`'s week layout — the horizontal 7-day strip with per-day task counts, `CalendarWeekView` at ~1823). Port that week presentation into the canonical calendar, then **remove/retire `TaskCalendarView`** (and route the Tasks-workspace "Calendar" view to `Destination.Calendar` / `CalendarWorkspaceScreen` instead of the local one). If the Tasks screen currently renders `TaskCalendarView` inline (dispatched around line ~358), replace that with a navigation to `Destination.Calendar` or a direct call to the shared composable — do not keep two.
2. **Infinite smooth scrolling for Day view.** The Day view must scroll **continuously and vertically across day/month boundaries** — scrolling past the end of one day flows into the next day, and it crosses month boundaries naturally (Jul 31 → Aug 1). Replace the paged `AnimatedContent` swipe for Day with a real scroll:
   - Use a `LazyColumn` with a large symmetric day range around today (e.g. `-180..+180` days, or an unbounded feel via a big window), each day rendered as a labeled section (date header + that day's hour timeline / events).
   - Keep `selectedDate`/`calendarDefaultView` in sync as the user scrolls (update selected to the top-most visible day), but the motion itself is smooth, not one-day-per-swipe.
3. **Infinite smooth scrolling for Week view.** Same idea, week granularity: a smooth vertical (or horizontally-paged-but-smooth) list of consecutive weeks using the Tasks-page week strip presentation, flowing across months. Prefer a `LazyColumn`/`LazyRow` of week strips so it scrolls continuously rather than one week per gesture.
4. **Month & Agenda** can stay as they are (Month = grid, Agenda = list) — this task is about Day and Week.

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
- [ ] The canonical Week view uses the Tasks-page week strip presentation.
- [ ] Day view scrolls smoothly and continuously across days and months (no one-day-per-swipe paging).
- [ ] Week view scrolls smoothly/continuously across weeks and months.
- [ ] Month + Agenda still work; mode switching + Today/Upcoming entry points still work.
- [ ] Builds clean; Light + Dark correct.
