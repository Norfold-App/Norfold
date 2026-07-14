#!/usr/bin/env bash
# keep-awake.sh — WSL host keep-awake + low-battery auto-sleep guard.
#
# WHAT IT DOES (one detached process; NO agent watches it):
#   • On start: sets the Windows SLEEP timeout to "Never" (both AC and DC), so the host
#     will not auto-sleep while work runs. The original sleep values are saved first.
#   • Leaves the SCREEN / display timeout exactly as-is — only sleep is changed.
#   • Every 120s checks host battery. If < 20% AND unplugged, it FORCES the host to sleep
#     (unconditional). Reconnect the charger to wake it; work resumes from the last commit.
#   • On stop (kill / Ctrl-C / exit): RESTORES the original sleep timeout it saved. Nothing
#     is left changed.
#
# USAGE (Codex starts it once at mission start, stops it at mission end):
#   nohup bash codex-handoffs/keep-awake.sh > codex-handoffs/coordination/keep-awake.out 2>&1 &
#   echo $! > codex-handoffs/coordination/keep-awake.pid      # remember the PID
#   ...work...
#   kill "$(cat codex-handoffs/coordination/keep-awake.pid)"  # stop it -> auto-restores sleep setting
#
# NOTES:
#   • WSL only — sleep/battery are Windows' job, driven via powercfg.exe / powershell.exe interop.
#   • Desktop (no battery): the battery check finds nothing and simply never force-sleeps.
#   • `kill` sends SIGTERM, which our trap catches to restore the original setting. Do NOT `kill -9`
#     (SIGKILL can't be trapped and would leave sleep on "Never"). If that happens, re-run the
#     restore manually — the saved values are printed to keep-awake.out at startup.

set -u
THRESHOLD=20          # percent; below this (and unplugged) -> force sleep the host
BATTERY_EVERY=120     # seconds between battery checks

# --- preflight: powercfg.exe must be reachable from WSL ---
if ! powercfg.exe /list >/dev/null 2>&1; then
  echo "ERROR: powercfg.exe not reachable from WSL. Cannot manage host power." >&2
  exit 1
fi

# --- capture the CURRENT sleep timeout so we can restore it later ---
# powercfg reports the standby (sleep) idle index in hex seconds, per power source.
query_sleep() {  # $1 = "AC" | "DC"  -> prints hex value like 0x00000384 (empty on failure)
  powercfg.exe /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 2>/dev/null \
    | grep -i "Current $1 Power Setting Index" \
    | grep -oiE "0x[0-9a-f]+" \
    | head -n1 \
    | tr -d '\r'
}

orig_ac="$(query_sleep AC)"
orig_dc="$(query_sleep DC)"

restore_sleep() {
  # Put the saved sleep timeouts back and re-activate the scheme.
  if [ -n "${orig_ac:-}" ]; then
    powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE "$orig_ac" >/dev/null 2>&1
  fi
  if [ -n "${orig_dc:-}" ]; then
    powercfg.exe /setdcvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE "$orig_dc" >/dev/null 2>&1
  fi
  powercfg.exe /setactive SCHEME_CURRENT >/dev/null 2>&1
  echo "$(date -Is) restored sleep timeout (AC=${orig_ac:-unknown}, DC=${orig_dc:-unknown})."
}
trap 'restore_sleep; exit 0' TERM INT EXIT

# --- set SLEEP to Never (0 = never). Screen/display timeout is deliberately NOT touched. ---
powercfg.exe /change standby-timeout-ac 0 >/dev/null 2>&1
powercfg.exe /change standby-timeout-dc 0 >/dev/null 2>&1

echo "keep-awake.sh started (pid $$). Sleep set to Never; screen timeout untouched."
echo "  saved original sleep index -> AC=${orig_ac:-unknown} DC=${orig_dc:-unknown}"
echo "  force-sleep threshold: ${THRESHOLD}% when unplugged. Stop with: kill $$"

# --- battery guard loop ---
while true; do
  cap=$(powershell.exe -NoProfile -Command "(Get-CimInstance Win32_Battery).EstimatedChargeRemaining" 2>/dev/null | tr -dc '0-9')
  st=$(powershell.exe  -NoProfile -Command "(Get-CimInstance Win32_Battery).BatteryStatus" 2>/dev/null | tr -dc '0-9')
  # BatteryStatus: 2 = AC/charging. Empty cap = no battery (desktop) -> skip.
  if [ -n "$cap" ] && [ "$cap" -lt "$THRESHOLD" ] && [ "$st" != "2" ]; then
    echo "$(date -Is) low battery ${cap}% and unplugged -> suspending Windows host."
    powershell.exe -NoProfile -Command "rundll32.exe powrprof.dll,SetSuspendState 0,1,0" >/dev/null 2>&1
    sleep 15   # let the host settle after it wakes (charger reconnected)
  fi
  sleep "$BATTERY_EVERY"
done
