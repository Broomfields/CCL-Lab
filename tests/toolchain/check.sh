#!/bin/sh
# Isolated command fixtures; no network or installation in the working tree.
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
real_luajit=$(command -v luajit)
luajit "$root/tests/toolchain/manifest.lua" "$root"
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT HUP INT TERM
mkdir -p "$fixture/repo with spaces/scripts" "$fixture/bin" "$fixture/prefix/bin"
cp -R "$root/scripts/toolchain" "$fixture/repo with spaces/scripts/"
cp "$root/scripts/toolchain.sh" "$fixture/repo with spaces/scripts/"
cp "$root/toolchain.manifest" "$fixture/repo with spaces/"
repo="$fixture/repo with spaces"
export CCL_TEST_REPO="$repo" CCL_TEST_LOG="$fixture/installs" CCL_TEST_REAL_LUAJIT="$real_luajit"
export PATH="$fixture/bin:$PATH" LUAJIT_PREFIX="$fixture/prefix" LOVE_BIN="$fixture/bin/love"
cat > "$fixture/bin/luajit" <<'MOCK'
#!/bin/sh
if [ "$1" = -e ] && [ "${CCL_TEST_BAD_JIT:-}" = yes ]; then
    printf '%s\n' 'LuaJIT 2.1.0'
else
    exec "$CCL_TEST_REAL_LUAJIT" "$@"
fi
MOCK
cp "$fixture/bin/luajit" "$fixture/prefix/bin/luajit"
cat > "$fixture/bin/uname" <<'MOCK'
#!/bin/sh
case "$1" in
-s) printf '%s\n' "${CCL_TEST_SYSTEM:-Darwin}" ;;
-m) printf '%s\n' arm64 ;;
esac
MOCK
cat > "$fixture/bin/love" <<'MOCK'
#!/bin/sh
sed -n 's/^tool.love=/LOVE /p' "$CCL_TEST_REPO/toolchain.manifest"
MOCK
cat > "$fixture/bin/git" <<'MOCK'
#!/bin/sh
printf '%s\n' 'git version 2.0.0'
MOCK
cat > "$fixture/bin/cc" <<'MOCK'
#!/bin/sh
printf '%s\n' 'fixture compiler'
MOCK
cat > "$fixture/bin/luarocks" <<'MOCK'
#!/bin/sh
case "$*" in
--version) sed -n 's/^tool.luarocks=/luarocks /p' "$CCL_TEST_REPO/toolchain.manifest" ;;
*'list --porcelain')
    if [ "${CCL_TEST_BAD_ROCK:-}" = yes ]; then printf 'busted\t0.0.0-1\tinstalled\tfixture\n'; fi
    if [ -f "$CCL_TEST_LOG" ]; then
        awk '{print $1 "\t" $2 "\tinstalled\tfixture"}' "$CCL_TEST_LOG"
    fi ;;
*)
    case "$*" in
    *'--only-server=https://luarocks.org'*'--deps-mode=none') ;;
    *) exit 90 ;;
    esac
    while [ "$1" != install ]; do shift; done
    shift
    expected=$(sed -n "s/^rock\.$1=//p" "$CCL_TEST_REPO/toolchain.manifest")
    [ "$2" = "$expected" ] || exit 91
    [ "${CCL_TEST_INSTALL_FAIL:-}" != yes ] || exit 92
    printf '%s %s\n' "$1" "$2" >> "$CCL_TEST_LOG"
    mkdir -p "$CCL_TEST_REPO/.luarocks/bin"
    cat > "$CCL_TEST_REPO/.luarocks/bin/busted" <<'BUSTED'
#!/bin/sh
sed -n 's/^rock.busted=\(.*\)-[0-9]*$/\1/p' "$CCL_TEST_REPO/toolchain.manifest"
BUSTED
    chmod +x "$CCL_TEST_REPO/.luarocks/bin/busted"
    ;;
esac
MOCK
chmod +x "$fixture/bin/"* "$fixture/prefix/bin/luajit"
fail() {
    if sh "$repo/scripts/toolchain.sh" "$@" > "$fixture/output" 2>&1; then
        printf 'Unexpected success: %s\n' "$*" >&2
        exit 1
    fi
}
fail check
(CCL_TEST_BAD_JIT=yes fail setup)
(CCL_TEST_SYSTEM=Linux fail setup)
(CCL_TEST_BAD_ROCK=yes fail setup)
(LOVE_BIN=/nonexistent/ccl-love fail setup)
[ ! -f "$CCL_TEST_LOG" ]
(CCL_TEST_INSTALL_FAIL=yes fail setup)
[ ! -f "$CCL_TEST_LOG" ]
sh "$repo/scripts/toolchain.sh" setup
cp "$CCL_TEST_LOG" "$fixture/first-installs"
sh "$repo/scripts/toolchain.sh" setup
cmp "$CCL_TEST_LOG" "$fixture/first-installs"
sh "$repo/scripts/toolchain.sh" check
sh "$repo/scripts/toolchain.sh" compare "$root/toolchain.manifest" "$repo/toolchain.manifest"
fail upgrade
cmp "$root/toolchain.manifest" "$repo/toolchain.manifest"
sed 's/^tool.love=.*/tool.love=99.0/' "$root/toolchain.manifest" > "$fixture/different.manifest"
fail compare "$root/toolchain.manifest" "$fixture/different.manifest"
fail validate "$fixture/missing.manifest"
printf '%s\n' 'PASS command fixtures: pinned setup, repeat setup, failures, comparison and upgrade refusal'
