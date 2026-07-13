#!/usr/bin/env bash
# keep-awake.sh — WSL host keep-awake + low-battery auto-sleep guard.
#
# WHAT IT DOES (one process, no agent babysitting it):
#   • Every 60s nudges Windows with a harmless F15 keypress so the host never sleeps while work runs.
#   • Every 120s checks host battery. If < 20% AND not charging, it forces the Windows host to sleep.
#     (Reconnect the charger to wake it; work resumes from the last commit.)
#
# USAGE (Codex starts it once at mission start, stops it at mission end):
#   nohup bash codex-handoffs/keep-awake.sh > codex-handoffs/coordination/keep-awake.out 2>&1 &
#   echo $! > codex-handoffs/coordination/keep-awake.pid      # remember the PID
#   ...work...
#   kill "$(cat codex-handoffs/coordination/keep-awake.pid)"  # stop it when done
#
# NOTES:
#   • WSL only — sleep/battery are Windows' job, driven via powershell.exe interop.
#   • Desktop (no battery): the battery check finds nothing and simply never triggers sleep. Keep-awake still works.
#   • It changes NO Windows power settings, so there is nothing to restore — stopping the process is the full cleanup.

set -u
THRESHOLD=20          # percent; at or below this (and unplugged) -> sleep the host
KEEPALIVE_EVERY=60    # seconds between anti-sleep nudges
BATTERY_EVERY=120     # seconds between battery checks

# Fail fast if PowerShell interop isn't available.
if ! powershell.exe -NoProfile -Command "exit 0" >/dev/null 2>&1; then
  echo "ERROR: powershell.exe interop not reachable from WSL. Cannot manage host power." >&2
  exit 1
fi

echo "keep-awake.sh started (pid $$). Threshold ${THRESHOLD}%. Ctrl-C or kill to stop."

last_batt_check=0

# Send the anti-sleep nudge immediately, then loop.
while true; do
  # --- keep the host awake ---
  powershell.exe -NoProfile -Command "\$w = New-Object -ComObject WScript.Shell; \$w.SendKeys('{F15}')" >/dev/null 2>&1

  # --- battery check on its own slower cadence ---
  now=$(date +%s)
  if [ $((now - last_batt_check)) -ge "$BATTERY_EVERY" ]; then
    last_batt_check=$now
    cap=$(powershell.exe -NoProfile -Command "(Get-CimInstance Win32_Battery).EstimatedChargeRemaining" 2>/dev/null | tr -dc '0-9')
    st=$(powershell.exe  -NoProfile -Command "(Get-CimInstance Win32_Battery).BatteryStatus" 2>/dev/null | tr -dc '0-9')
    # BatteryStatus: 2 = AC/charging. Empty cap = no battery (desktop) -> skip.
    if [ -n "$cap" ] && [ "$cap" -lt "$THRESHOLD" ] && [ "$st" != "2" ]; then
      echo "$(date -Is) low battery ${cap}% and unplugged -> suspending Windows host."
      powershell.exe -NoProfile -Command "rundll32.exe powrprof.dll,SetSuspendState 0,1,0" >/dev/null 2>&1
      # After the host wakes (charger reconnected), resume nudging. Give it a moment to settle.
      sleep 15
    fi
  fi

  sleep "$KEEPALIVE_EVERY"
done
