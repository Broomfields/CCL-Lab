# Tests

Add Busted specifications named `*_spec.lua` here alongside each implemented
shared behaviour. Run from the repository root with:

```sh
.luarocks/bin/busted tests
```

There are no runtime specifications yet. The prerequisite checker verifies the
toolchain only; it does not claim to validate runtime behaviour or a LÖVE window.
Future integration fixtures should exercise actual LÖVE startup separately from
pure Lua specifications.

## Toolchain foundation checks

Run `sh tests/toolchain/check.sh` for standalone manifest and setup-command
contract tests, including consuming a vendored Lab manifest with a separate
project dependency directory. These use LuaJIT and isolated command fixtures, require no Busted
installation or network, and do not claim runtime compatibility.
