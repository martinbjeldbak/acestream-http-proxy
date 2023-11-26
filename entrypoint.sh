#!/bin/sh

set -e
#
# Start acestream in the background
/opt/acestream/start-engine --client-console &
#
# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
