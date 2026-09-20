#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

EXTRA_FLAGS=()
if [[ ${ALLOW_REMOTE_ACCESS:-} == "yes" ]]; then
	EXTRA_FLAGS+=(--bind-all)
fi

exec \
	/app/start-engine \
	--cache-dir /home/appuser/.ACEStream/cache \
	--cache-limit 1 \
	--client-console \
	"${EXTRA_FLAGS[@]}" \
	"$@"
