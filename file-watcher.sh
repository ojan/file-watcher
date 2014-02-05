#!/bin/bash

# Send a metric to statsd from bash
#
# Useful for:
#   deploy scripts (http://codeascraft.etsy.com/2010/12/08/track-every-release/)
#   init scripts
#   sending metrics via crontab one-liners
#   sprinkling in existing bash scripts.
#
# netcat options: 
#   -w timeout If a connection and stdin are idle for more than timeout seconds, then the connection is silently closed.  
#   -u         Use UDP instead of the default option of TCP.     
#
#echo "deploys.test.myservice:1|c" | nc -w 1 -u 001.graphite 8125

# ------------ CONFIGURATION ---------
INOTIFYWAIT=`which inotifywait`
LOGGER=`which logger`
NC=`which nc`
NC_CONFIG="-w 1 -u 001.graphite 8125"

# ------ FUNCTIONS ----------------
message() {

case "${event}" in
        CREATE)
                ${LOGGER} --id --priority daemon.notice --tag fs-watcher "the file ${file} inside ${dir} has been created"
		echo "file-watcher.file.create:1|c" | ${NC} ${NC_CONFIG}
                ;;
	CREATE:ISDIR)
		${LOGGER} --id --priority daemon.notice --tag fs-watcher "the directory ${dir}${file} has been created"
		echo "file-watcher.directory.create:1|c" | ${NC} ${NC_CONFIG}
		;;
	DELETE:ISDIR)
                ${LOGGER} --id --priority daemon.notice --tag fs-watcher "the directory ${dir}${file} has been deleted"
                echo "file-watcher.directory.delete:1|c" | ${NC} ${NC_CONFIG}
		;;
        DELETE)
                ${LOGGER} --id --priority daemon.notice --tag fs-watcher "the file ${file} inside ${dir} has been deleted"
                echo "file-watcher.file.delete:1|c" | ${NC} ${NC_CONFIG}
		;;
        MODIFY)
                ${LOGGER} --id --priority daemon.notice --tag fs-watcher "the file ${file} inside ${dir} has been modified"
                echo "file-watcher.file.modify:1|c" | ${NC} ${NC_CONFIG}
		;;
        MOVED_FROM)
                ${LOGGER} --id --priority daemon.notice --tag fs-watcher "the file ${file} has been moved FROM ${dir} directory"
                echo "file-watcher.file.moved_from:1|c" | ${NC} ${NC_CONFIG}
		;;
        MOVED_TO)
                ${LOGGER} --id --priority daemon.notice --tag fs-watcher "the file ${file} has been moved TO ${dir} directory"
                echo "file-watcher.file.moved_to:1|c" | ${NC} ${NC_CONFIG}
		;;
	esac

	}

# ------- MAIN ------------

${INOTIFYWAIT} -mr --format '%w %f %:e' -e create -e modify -e delete -e moved_to -e moved_from $1 | while read dir file event; do 
	message
done
