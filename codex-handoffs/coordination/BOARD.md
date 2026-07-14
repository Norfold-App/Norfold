# FIRST-MISSION Coordination Board

## Blockers requiring user action

None currently.

## Mission runtime

- Integration branch: `mission/first`
- Checkpoint: `9820db5 checkpoint: add first mission handoff protocol`
- Keep-awake PID: `13542` (live persistent WSL guard; verified after PID `9805` exited; use `kill 13542` with SIGTERM for final cleanup)
- Emulator route: invoke Windows ADB from WSL at `/mnt/c/Users/sheik/AppData/Local/Android/Sdk/platform-tools/adb.exe`
- Emulator: `emulator-5554`, Android 17, physical display `1080x2400`, density `420`
- Linux ADB note: `/home/sheikh/android-sdk/platform-tools/adb` is present but currently sees no devices.

## Work state

| Part | Owner | Status | Light screenshot | Dark screenshot |
|---|---|---|---|---|
| Phase 1 audit | A1 | Complete (`4572ae9`) | N/A | N/A |
| 0 — Foundation | A1 (+ A3R final proof audit) | Complete: unit tests + debug APK green (`fe0584c`); installed phone QA passed; canonical 221-block fixture restored; every interaction proof independently inspected | `screenshots/part-0/light/` | `screenshots/part-0/dark/` |
| 1 — Chart | A1 | Pending | Pending | Pending |
| 2 — Table | A4 | Pending | Pending | Pending |
| 3 — Embed | A4 | Pending | Pending | Pending |
| 4 — Math | A3R (replacement for A2) | Builder + inline detector + 10 focused tests complete (`73c539b`, `ebef97f`, `0ad110e`); hotspot hook and emulator proof pending literal Phase-A release | Pending | Pending |
| 5 — Mermaid | A4R (replacing A3) | Builder + 10 focused codec tests complete through `59f7cfc`; editor hook staged behind Part4, build and emulator proof pending literal Phase-A release | Pending | Pending |
| 6 — Rich text everywhere | Unclaimed | Pending | Pending | Pending |
| 7 — Discovered gaps | Unclaimed | Pending | Pending | Pending |
