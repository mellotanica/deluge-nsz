#!/bin/bash

# link switch prod keys directory to the correct spot depending on the user mapping
switchdir="$(su-exec $PUID:$PGID bash -c 'cd && pwd')/.switch"
rm -rf "$switchdir"
ln -s /opt/switch "$switchdir"

if [ -z "$1" ]; then
    exec su-exec $PUID:$PGID /opt/extract.sh
else
    exec su-exec $PUID:$PGID $@
fi
