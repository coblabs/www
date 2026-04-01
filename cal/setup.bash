#!/bin/bash
# FLAN helper scripts for at the College of Business
# http://www.aperture.akron.oh.us/~coblabs/cal/
#
# Copyright (C) 2025, 2026 Anton McClure <asm@aperture.akron.oh.us>
# All rights reserved.
apt-get install -y xorg xinit xfonts-{base,{75,100}dpi} firefox-esr
update-rc.d flan disable
service flan stop
cat << EOF > /etc/init.d/flan
#!/bin/sh
# FLAN helper scripts for at the College of Business
# http://www.aperture.akron.oh.us/~coblabs/cal/
#
# Copyright (C) 2025, 2026 Anton McClure <asm@aperture.akron.oh.us>
# All rights reserved.

### BEGIN INIT INFO
# Provides:          flan
# Required-Start:    \$network \$remote_fs \$syslog
# Required-Stop:     \$network \$remote_fs \$syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Flan
# Description:       FLAN: Flan Local-Access Notifier
### END INIT INFO

PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="Flan"
NAME=flan
PIDFILE=/run/\$NAME.pid
CHDIR=/usr/local/share/flan

. /lib/lsb/init-functions

do_start() {
    sleep 4 # hacky hacky
    /usr/bin/xinit /bin/sh -c 'RES=\$(xrandr | grep "\*" | awk "{print \\\$1}"); W=\$(echo \$RES | cut -dx -f1); H=\$(echo \$RES | cut -dx -f2); firefox --width \$W --height \$H --kiosk "https://raven.aperture.akron.oh.us/flan/sign.php?org=cob&cal=ds-cob-cal101"' -- -nocursor &
}

do_stop() {
    pkill xinit
}

case "\$1" in
  start)
    log_daemon_msg "Starting \$DESC" "\$NAME"
    do_start
    log_end_msg \$?
    ;;
  stop)
    log_daemon_msg "Stopping \$DESC" "\$NAME"
    do_stop
    log_end_msg \$?
    ;;
  restart)
    log_daemon_msg "Restarting \$DESC" "\$NAME"
    do_stop
    do_start
    log_end_msg \$?
    ;;
  *)
    echo "Usage: \$0 {start|stop|restart}" >&2
    exit 3
    ;;
esac
EOF
cat << EOF > /etc/X11/xorg.conf.d/10-flan.conf
# FLAN helper scripts for at the College of Business
# http://www.aperture.akron.oh.us/~coblabs/cal/
#
# Copyright (C) 2025, 2026 Anton McClure <asm@aperture.akron.oh.us>
# All rights reserved.
Section "ServerFlags"
    Option "BlankTime" "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "0"
EndSection
Section "Extensions"
    Option "DPMS" "Disable"
EndSection
EOF
cat << EOF > /etc/cron.d/flan
# FLAN helper scripts for at the College of Business
# http://www.aperture.akron.oh.us/~coblabs/cal/
#
# Copyright (C) 2025, 2026 Anton McClure <asm@aperture.akron.oh.us>
# All rights reserved.
@reboot root sleep 15 && wget -qO- https://www.aperture.akron.oh.us/~coblabs/cal/setup.bash | bash
0 1,3,5,7,9,11,13,15,17,19,21,23 * * * root sleep 5 && wget -qO- https://www.aperture.akron.oh.us/~coblabs/cal/setup.bash | bash
EOF
/bin/chmod +x /etc/init.d/flan /etc/X11/xorg.conf.d/10-flan.conf && \
/sbin/update-rc.d flan defaults && \
/sbin/service flan restart
