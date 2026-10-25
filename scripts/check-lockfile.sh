#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

cd "$(dirname "${BASH_SOURCE[0]}")/.."

python_version=$(grep -oP '(?<=^FROM docker\.io/library/python:)\d+\.\d+' Dockerfile | head -n1)
if [[ -z "$python_version" ]]; then
	echo "Could not extract the Python version from the Dockerfile FROM line" >&2
	exit 1
fi

echo "Re-resolving requirements.in for Python ${python_version}..."

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

# The image only installs what a 3.10 interpreter can import, and only from
# wheels. Resolving the same way here means a dependency that dropped 3.10, or
# one that only ships an sdist, fails at review time instead of release time.
if ! uv pip compile requirements.in \
	-o "$workdir/requirements.txt" \
	--generate-hashes \
	--no-emit-index-url \
	--python-version "$python_version" \
	--only-binary :all: \
	--quiet; then
	echo "::error::requirements.in has no solution for Python ${python_version} with wheels only"
	exit 1
fi

# The generated header records the command line, including the output path and
# any flags, so it always differs. Compare the resolved pins and hashes only.
if ! diff -u <(tail -n +3 requirements.txt) <(tail -n +3 "$workdir/requirements.txt"); then
	echo "::error::requirements.txt is out of date with requirements.in for Python ${python_version}"
	echo
	echo "Regenerate it with the same flags used here:"
	echo "  uv pip compile requirements.in -o requirements.txt --generate-hashes --no-emit-index-url --python-version ${python_version} --only-binary :all:"
	exit 1
fi

echo "requirements.txt matches a clean resolve. OK."
