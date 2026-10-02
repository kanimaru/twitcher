#!/usr/bin/env bash
# Verifies that plugin.cfg and Twitcher.VERSION carry the same version and,
# when one is given, that both equal it (e.g. the tag being pushed).
#
#   .github/scripts/check-version.sh            # the two files must agree
#   .github/scripts/check-version.sh 2.6.0      # ... and both must be 2.6.0
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cfg_file="$root/addons/twitcher/plugin.cfg"
gd_file="$root/addons/twitcher/twitcher.gd"

cfg_version="$(sed -nE 's/^version="([^"]*)".*/\1/p' "$cfg_file")"
gd_version="$(sed -nE 's/^const VERSION: String = "([^"]*)".*/\1/p' "$gd_file")"
expected="${1:-$cfg_version}"

status=0
if [[ -z "$cfg_version" ]]; then
	echo "::error file=addons/twitcher/plugin.cfg::no version=\"...\" line found" >&2
	status=1
fi
if [[ -z "$gd_version" ]]; then
	echo "::error file=addons/twitcher/twitcher.gd::no 'const VERSION: String = \"...\"' line found" >&2
	status=1
fi
if [[ "$cfg_version" != "$expected" ]]; then
	echo "::error file=addons/twitcher/plugin.cfg::version is '$cfg_version', expected '$expected'" >&2
	status=1
fi
if [[ "$gd_version" != "$expected" ]]; then
	echo "::error file=addons/twitcher/twitcher.gd::Twitcher.VERSION is '$gd_version', expected '$expected'" >&2
	status=1
fi

if [[ "$status" -eq 0 ]]; then
	echo "version $expected: plugin.cfg and Twitcher.VERSION agree"
fi
exit "$status"
