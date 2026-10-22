# Tests

## Toolchain checks

Run from the repository root:

```sh
sh tests/toolchain/check.sh
```

These standalone checks use LuaJIT and isolated command fixtures to exercise
manifest validation, pinned setup, failure handling, and a consuming project's
use of vendored Lab. They run offline before Busted is installed.

## Runtime specifications

Add Busted specifications named `*_spec.lua` alongside each implemented shared
behaviour. Run them from the repository root with:

```sh
.luarocks/bin/busted tests
```

Runtime specifications and LÖVE startup fixtures will accompany runtime
implementation. See the [follow-through tasks](../docs/toolchain.md#follow-through).
