#!/bin/sh
# Re-assert the fan setpoint when the machine wakes up.
#
# omend already recovers on its own: it rewrites the setpoint every ten
# seconds, so a controller that was reset by suspend is corrected within that.
# Ten seconds of the EC doing whatever it likes is not dangerous, but it is
# visible - the fans go quiet on a warm machine and then come back - and there
# is no reason to wait when systemd will tell us the moment it happens.
#
# Installed as /usr/lib/systemd/system-sleep/omen. Runs as root, with the
# arguments systemd gives: "post" means we have just woken up.
case "$1" in
  post)
    # Re-read the configuration, which also makes the daemon forget what it
    # thinks the hardware is set to and write it again.
    /usr/bin/omenctl reload >/dev/null 2>&1 || true
    ;;
esac
