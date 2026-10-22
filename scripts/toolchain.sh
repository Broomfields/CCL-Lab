#!/bin/sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if ! command -v luajit >/dev/null 2>&1; then
    printf '%s\n' 'FAIL: LuaJIT is required to read toolchain.manifest; see docs/toolchain.md.' >&2
    exit 1
fi
case "${1:-}" in
setup|check)
    operation=$1
    shift
    project_dir=$repo_dir
    if [ "$#" -ne 0 ]; then
        if [ "$#" -ne 2 ] || [ "$1" != --project-dir ] || [ -z "$2" ]; then
            printf '%s\n' 'Usage: toolchain.sh setup|check [--project-dir directory]' >&2
            exit 1
        fi
        if ! project_dir=$(CDPATH= cd -P -- "$2" 2>/dev/null && pwd); then
            printf 'FAIL: project directory does not exist or is inaccessible: %s\n' "$2" >&2
            exit 1
        fi
    fi
    exec luajit "$repo_dir/scripts/toolchain/main.lua" "$repo_dir" "$operation" "$project_dir"
    ;;
*) exec luajit "$repo_dir/scripts/toolchain/main.lua" "$repo_dir" "$@" ;;
esac
