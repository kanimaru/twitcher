#!/usr/bin/env bash
# Writes a version into every file that carries it: plugin.cfg (what the
# editor shows) and Twitcher.VERSION (what exported games report, since they
# don't ship plugin.cfg). Used by the Release workflow.
#
#   .github/scripts/set-version.sh 2.6.0
set -euo pipefail

version="${1:?usage: set-version.sh <version>, e.g. 2.6.0}"
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
	echo "::error::'$version' is not a version like 2.6 or 2.6.0" >&2
	exit 1
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
sed -i -E "s/^version=\"[^\"]*\"/version=\"$version\"/" "$root/addons/twitcher/plugin.cfg"
sed -i -E "s/^const VERSION: String = \"[^\"]*\"/const VERSION: String = \"$version\"/" \
	"$root/addons/twitcher/twitcher.gd"

"$root/.github/scripts/check-version.sh" "$version"
