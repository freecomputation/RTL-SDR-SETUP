#!/bin/bash
# setup-rtl-sdr.sh - one-run setup of the RTL-SDR receiver tools on a
# Debian-family host (written for the Trisquel X200; works on Ubuntu/Debian).
#
# Installs the tools the house signals programs stand benched without:
#   rtl-sdr      - rtl_power (KNELL surveys), rtl_sdr and rtl_fm (MULTIDEX
#                  real source), rtl_test, rtl_tcp
#   rtl-433      - ISM device decoding (Passband, MULTIDEX ISM desk)
#   multimon-ng  - POCSAG and friends (MULTIDEX pager desk)
# Keeps the kernel DVB driver off the dongle, then verifies the result
# against the hardware. Uses sudo for the system steps; run it as the
# normal user and type the password when asked. Safe to re-run.
set -euo pipefail

say() { printf '%s\n' "$*"; }

if ! command -v apt-get >/dev/null 2>&1; then
  say "This script is for a Debian-family host (apt-get not found). Stopping."
  exit 1
fi

say "Step 1 of 4: refreshing package lists"
sudo apt-get update

say "Step 2 of 4: installing the receiver tools (rtl-sdr, rtl-433, multimon-ng)"
sudo apt-get install -y rtl-sdr rtl-433 multimon-ng

say "Step 3 of 4: keeping the kernel DVB driver off the dongle"
BLACKLIST=/etc/modprobe.d/blacklist-rtlsdr.conf
if [ ! -f "$BLACKLIST" ]; then
  printf '%s\n' \
    'blacklist dvb_usb_rtl28xxu' \
    'blacklist rtl2832' \
    'blacklist rtl2830' | sudo tee "$BLACKLIST" >/dev/null
  say "Wrote $BLACKLIST - a reboot makes it take effect if the DVB driver is loaded now."
else
  say "$BLACKLIST already present, leaving it as it is."
fi
sudo udevadm control --reload-rules || true

say "Step 4 of 4: verification"
fail=0
for tool in rtl_power rtl_sdr rtl_fm rtl_test rtl_433 multimon-ng; do
  if command -v "$tool" >/dev/null 2>&1; then
    say "PASS - $tool is installed"
  else
    say "FAIL - $tool is missing"
    fail=1
  fi
done

if timeout 8 rtl_test -t >/tmp/rtl_test_out.txt 2>&1; then
  say "PASS - rtl_test reached the dongle"
else
  if grep -qi "found" /tmp/rtl_test_out.txt && grep -qi "FITIPOWER\|R828D\|R820T" /tmp/rtl_test_out.txt; then
    say "PASS - rtl_test found the tuner (the test itself timed out by design)"
  else
    say "CHECK - rtl_test did not confirm the dongle; its output follows."
    cat /tmp/rtl_test_out.txt
    fail=1
  fi
fi

if [ "$fail" -eq 0 ]; then
  say "Done. KNELL has rtl_power for its first survey, and MULTIDEX has rtl_sdr and rtl_fm for its real source."
else
  say "Done with failures marked above. Nothing else was changed."
  exit 1
fi
