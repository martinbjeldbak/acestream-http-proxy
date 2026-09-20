#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

version=$(grep -oP '(?<=^ENV VERSION=")[^"]+' Dockerfile)
if [[ -z "$version" ]]; then
    echo "Could not extract VERSION from Dockerfile" >&2
    exit 1
fi

echo "Checking requirements.in against the acestream_${version} tarball..."

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

curl -fsSL "https://download.acestream.media/linux/acestream_${version}.tar.gz" \
    | tar xzf - -C "$tmpdir" requirements.txt

upstream=$(grep -vE '^[[:space:]]*(#|$)' "$tmpdir/requirements.txt" | sort -u)
ours=$(grep -vE '^[[:space:]]*(#|$)' requirements.in | sort -u)

if [[ "$upstream" != "$ours" ]]; then
    cp "$tmpdir/requirements.txt" ./upstream-requirements.txt
    echo "::error::requirements.in is out of sync with acestream_${version}'s requirements.txt"
    diff <(echo "$ours") <(echo "$upstream") \
        --label "requirements.in (ours)" --label "upstream (acestream_${version})" || true
    echo
    echo "Saved upstream's requirements.txt to ./upstream-requirements.txt for reference."
    echo "Update requirements.in to match it, then regenerate requirements.txt:"
    echo "  uv pip compile requirements.in -o requirements.txt --generate-hashes"
    exit 1
fi

echo "requirements.in matches upstream. OK."
