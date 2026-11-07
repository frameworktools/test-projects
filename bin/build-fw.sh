#!/bin/sh
# Build the fw command-line tool from a framework-cli checkout into bin/fw.
# The version comes from the checkout's latest tag, as in a release build.
# Your shell has an `fw` function that shadows it, so call ./bin/fw directly.
set -e
here="$(cd "$(dirname "$0")" && pwd)"
src="${FRAMEWORK_CLI:-$here/../../framework-cli}"
cd "$src"
version="$(git describe --tags --always --dirty | sed 's/^v//')"
commit="$(git rev-parse --short HEAD)"
date="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
pkg=github.com/frameworktools/framework-cli/internal/cli
go build -ldflags "-X $pkg.version=$version -X $pkg.commit=$commit -X $pkg.date=$date" \
  -o "$here/fw" ./cmd/fw
"$here/fw" --version
