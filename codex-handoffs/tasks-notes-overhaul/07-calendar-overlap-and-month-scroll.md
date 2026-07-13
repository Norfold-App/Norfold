# Job 07 — Fix calendar header overlap + Month view side-by-side scrolling

> **⛓ RUN ORDER — see `../MASTER_ORDER.md` (step 20).** Do NOT start until `../tasks-board-calendar/CODEX_PROMPT_4_CALENDAR.md` is merged — **reuse the pager helper it built** for the Month view; do NOT re-touch Day/Week. You own only the header-overlap fix + Month. Satisfy the universal Definition-of-Done GATE before declaring done.

> Companion to `../tasks-board-calendar/CODEX_PROMPT_4_CALENDAR.md` (Day/Week smooth scroll + adaptive Week grid). This job handles the **overlap bug** and **Month view**. If both run, do the Week-grid prompt's structural work first, then this.

## Role
Editing Norfold Android (Compose/Material3, `com.norfold.app`, `apps/android`). Do it fully and exactly. No stubs.

## House rules
- Theme tokens only. Light + Dark both correct.

## Problem A — the floating sidebar button overlaps the calendar header
- The canonical calendar is `CalendarWorkspaceScreen` (`ui/screens/PlanningScreens.kt:211-289`). Its header row shows `MMMM yyyy` (`:222`) with a "New event" `IconButton` (`:223`).
- The floating `CompactSidebarButton` (`ui/NorfoldAppRoot.kt:415-417`, def `:434-439`, `zIndex(4f)`) sits **top-left** and **overlaps the month/year header row** (this is the overlap the user reported for calendar view).
- Content is already `.padding(padding)` from the root `Scaffold` (`NorfoldAppRoot.kt:405`) so the **bottom nav does not** overlap cells — the only overlap is that top-left floating button vs the header.

### Fix A
- Inset the calendar header so nothing sits under the floating sidebar button: give the header row a leading start padding equal to the button's footprint (button size + margin, ~56dp) so `MMMM yyyy` and the New-event control clear it. Do this for **all** calendar modes' headers (Month/Week/Day/Agenda), and check the other screens that show the same floating button for the same collision (Notes/Tasks headers) — if they already clear it, leave them; if they overlap, apply the same inset.
- Prefer the padding/inset fix over z-index games so the button stays tappable and nothing hides behind it. Verify at small widths.

## Problem B — Month view should scroll side-by-side like Week
- Current **Month** = `MonthPanel` (`PlanningScreens.kt:406-430`) inside a `LazyColumn` (`:266-281`): a fixed 6×7 grid, cells `weight(1f).height(72.dp)` (`:419`), up to 3 event dots, plus a bottom `Spacer(96.dp)` (`:280`). It does **not** page/scroll between months smoothly.
- The user wants Month to get the **same side-by-side smooth scrolling as Week** (from the Week-grid prompt): swipe horizontally to move to the previous/next month with a smooth continuous feel (a pager of month grids, not a hard snap), while the month/year label + weekday header stay put.

### Fix B
- Wrap the month grid in a horizontally-swipeable pager of consecutive months (e.g. `HorizontalPager` over a wide symmetric month range around today, or the same mechanism the Week view uses so they feel identical). Swiping left/right moves months smoothly; the `MMMM yyyy` header updates to the visible month; the weekday header row stays fixed.
- Keep the 6×7 grid, event dots, and cell tap-to-select. Keep the bottom clearance. `selectedDate` stays in sync with the visible month + tapped day.
- Reuse whatever pager/animation approach the Week grid uses (`../tasks-board-calendar/CODEX_PROMPT_4_CALENDAR.md`) so Month and Week share the same smooth-scroll feel and, ideally, the same helper.

## Constraints
- Don't regress Day/Week/Agenda or the mode segmented control (`:242-251`), or Today→Day / Upcoming→Agenda entry points.
- Theme tokens only; Light + Dark correct.

## Definition of Done
- [ ] The floating sidebar button no longer overlaps the calendar header in any mode (header inset clears it); other screens checked for the same collision.
- [ ] Month view swipes between months smoothly side-by-side (pager), header label follows, weekday row + grid + dots + tap-select intact.
- [ ] Month and Week share the same smooth-scroll feel/helper.
- [ ] No regression to Day/Week/Agenda or entry points; builds clean; Light + Dark correct.
