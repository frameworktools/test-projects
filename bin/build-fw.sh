#!/bin/sh
# Build the fw command-line tool from a framework-cli checkout into bin/fw.
# Your shell has an `fw` function that shadows it, so call ./bin/fw directly.
set -e
here="$(cd "$(dirname "$0")" && pwd)"
src="${FRAMEWORK_CLI:-$here/../../framework-cli}"
(cd "$src" && go build -o "$here/fw" ./cmd/fw)
"$here/fw" --version
