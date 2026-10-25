#!/bin/bash
set -euo pipefail

engine_flags=()
if [[ ${ALLOW_REMOTE_ACCESS:-} == "yes" ]]; then
	engine_flags+=(--bind-all)
fi

# EXTRA_FLAGS is a space separated list of engine options, so split it into
# separate arguments instead of passing it through as a single (unusable) one.
if [[ -n ${EXTRA_FLAGS:-} ]]; then
	read -r -a user_flags <<<"${EXTRA_FLAGS}"
	engine_flags+=("${user_flags[@]}")
fi

exec \
	/app/start-engine \
	--cache-dir /home/appuser/.ACEStream/cache \
	--cache-limit 1 \
	--client-console \
	"${engine_flags[@]}" \
	"$@"
