#!/bin/sh
# Read-only checks; run from any directory.
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
failed=0

check_version() {
    label=$1
    expected=$2
    shift 2
    if output=$("$@" 2>&1); then
        case "$output" in
            *"$expected"*) printf 'OK   %s: %s\n' "$label" "$output" ;;
            *) printf 'FAIL %s: expected %s; got %s\n' "$label" "$expected" "$output"; failed=1 ;;
        esac
    else
        printf 'FAIL %s: %s\n' "$label" "$output"
        failed=1
    fi
}

check_version Git 'git version 2.' git --version
check_version LuaJIT 'LuaJIT 2.1' luajit -e 'assert(_VERSION == "Lua 5.1"); print(jit.version)'
check_version LOVE 'LOVE 11.5 ' "${LOVE_BIN:-love}" --version
check_version LuaRocks 'luarocks 3.' luarocks --version
check_version Busted '2.3.0' "$repo_dir/.luarocks/bin/busted" --version

if [ "$failed" -ne 0 ]; then
    printf '\nSee docs/development.md for installation and troubleshooting.\n'
    exit 1
fi
printf '\nAll prerequisite checks passed.\n'
