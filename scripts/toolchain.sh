#!/bin/sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if ! command -v luajit >/dev/null 2>&1; then
    printf '%s\n' 'FAIL: LuaJIT is required to read toolchain.manifest; see docs/toolchain.md.' >&2
    exit 1
fi
exec luajit "$repo_dir/scripts/toolchain/main.lua" "$repo_dir" "$@"
