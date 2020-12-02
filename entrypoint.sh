#!/bin/bash

# link switch prod keys directory to the correct spot depending on the user mapping
ln -s /opt/switch "$(su-exec $PUID:$PGID bash -c 'cd && pwd')/.switch"

if [ -z "$1" ]; then
    exec su-exec $PUID:$PGID /opt/extract.sh
else
    exec su-exec $PUID:$PGID $@
fi
