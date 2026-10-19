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
