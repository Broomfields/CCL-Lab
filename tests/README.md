# Tests

Add Busted specifications named `*_spec.lua` here alongside each implemented
shared behaviour. Run from the repository root with:

```sh
.luarocks/bin/busted
```

The root [`.busted`](../.busted) configuration requires LuaJIT 2.1, discovers
`*_spec.lua` files recursively under `tests/`, and sets the project module path
so specifications can use `require("lab.time")`, for example, once implemented.
It loads Lua specifications only. Run one specification by supplying its path:

```sh
.luarocks/bin/busted tests/time_spec.lua
```

That filename is illustrative; the specification does not exist yet. See
[local development](../docs/development.md#running-busted) for setup and
[official Busted documentation](https://lunarmodules.github.io/busted/) for
assertions, hooks, spies, mocks, and command-line options.

There are no runtime specifications yet. The prerequisite checker verifies the
toolchain only; it does not claim to validate runtime behaviour or a LÖVE window.
Future integration fixtures should exercise actual LÖVE startup separately from
pure Lua specifications.
