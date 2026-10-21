#!/bin/sh
# Backward-compatible, read-only entry point; run from any directory.
set -eu
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec sh "$script_dir/toolchain.sh" check
