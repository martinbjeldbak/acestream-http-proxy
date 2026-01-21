#!/usr/bin/env bash
#shellcheck disable=SC2086

if [[ $ALLOW_REMOTE_ACCESS == "yes" ]]; then
	EXTRA_FLAGS="$EXTRA_FLAGS --bind-all"
fi

exec \
	/app/start-engine \
	--client-console \
	$EXTRA_FLAGS \
	"$@"
