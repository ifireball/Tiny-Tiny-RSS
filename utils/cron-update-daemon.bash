#!/usr/bin/env bash
# cron-update-daemon.bash - Run and monitor TT-RSS update_daemon2.php from CRON
#   This script is meant to allow using the TT-RSS update daemon on web hosts
#   that don't allow direct shell access but let you run your own CRON jobs.
#   This script checks to see of the update daemon is running, and starts it if
#   it isn't. The script also sets things up to store daemon output in a log
#   file and make cron send you the few last lines from it if the daemon is
#   down so you can figure out why it was shut down.
#

set -e +m

die() {
	ERROR=1
	case "$1" in
		-[0-9]*) ERROR=${1#-}; shift;;
	esac
	echo "$@" 1>&2
	exit $ERROR
}

# Try to use the 'dirname' command and fall back to bash hacks if we can't
DIRNAME='/usr/bin/dirname'
if test -x $DIRNAME ; then
	dirname() {
		$DIRNAME "$@"
	}
else
	dirname() {
		if [[ "${1%/*}" == "$1" ]]; then
			echo .
		else
			echo "${1%/*}"
		fi
	}
fi

SCRIPT_DIR="$(dirname "$0")"
SCRIPT_NAME="cron-update-daemon"
CONF_FILE="$SCRIPT_DIR/${SCRIPT_NAME}.conf"

# Default Configuration values
# ----------------------------
# Most default values place things in relation to where this script is run
# from, so if you place it in a directory beneath the main TT-RSS directory,
# you may not need a configuration file. But you can use the configuration to
# override or fix everything

LOG_FILE="$SCRIPT_DIR/../logs/tt-rss-update-daemon.log"
PID_FILE="$SCRIPT_DIR/../lock/${SCRIPT_NAME}.pid"
NICE_LEVEL=10
LOG_LINES=10

PHP="/usr/bin/php"
NOHUP="/usr/bin/nohup"
NICE="/usr/bin/nice"
TAIL="/usr/bin/tail"
PS="/bin/ps"
CAT="/bin/cat"

DAEMON="$SCRIPT_DIR/../update_daemon2.php"

# Source the configuration file if it exists
test -r "$CONF_FILE" && source "$CONF_FILE"

RUN_DIR="$(dirname "$DAEMON")"

# Check to see if we have everything we need
for CMD in $PHP $NOHUP $NICE $TAIL $PS; do
	test -x $CMD || die -2 "Cannot find required command: $CMD"
done

test -r "$DAEMON" || die "TT-RSS update daemon not found at $DAEMON"

# Check to see if daemon is aleady running, exit if it does
test -r "$PID_FILE" &&
	(( OLD_PID="$($CAT "$PID_FILE")" )) > /dev/null 2>&1 &&
	$PS $OLD_PID > /dev/null 2>&1 &&
	exit 0

echo "No TT-RSS updae daemon found running"

# Try to output last lines from last deaomn run log
if [[ -r "$LOG_FILE" ]]; then
	echo "Following are last lines from daemon log:"
	$TAIL -n "$LOG_LINES" "$LOG_FILE"
	echo
fi

echo "Invoking TT-RSS update daemon..."
cd "$RUN_DIR"
$NOHUP $NICE -n $NICE_LEVEL $PHP "$DAEMON" >> "$LOG_FILE" 2>&1 < /dev/null &
NEW_PID=$!
echo "TT-RSS update daemon started at pid: $NEW_PID"
echo $NEW_PID > "$PID_FILE"

exit 0


