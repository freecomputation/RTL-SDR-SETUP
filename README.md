# RTL-SDR-SETUP

One-run setup of the RTL-SDR receiver tools on a Debian-family host (written for Trisquel; works on Ubuntu and Debian).

## What it installs

- rtl-sdr - the rtl_sdr, rtl_fm, rtl_power, rtl_tcp and rtl_test tools and the librtlsdr library they run on
- rtl-433 - decoding of ISM-band devices on 315, 433, 868 and 915 MHz
- multimon-ng - POCSAG, FLEX and related paging and signalling decodes

The script also keeps the kernel DVB driver off the dongle with a modprobe blacklist entry, reloads the udev rules, and finishes by verifying every tool it installed and testing the dongle itself with rtl_test. Each check prints PASS or FAIL in plain words.

## Running it

Clone the repo or copy the script to the host, then run it as the normal user:

    ./setup-rtl-sdr.sh

The system steps use sudo and the script asks for the password when needed. It is safe to re-run: installed packages are left alone, the blacklist file is written only if absent, and the verification runs every time.
