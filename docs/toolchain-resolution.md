# Initial dependency resolution record

Captured on 21 October 2026 from the repository-local tree used for the existing
19 October prerequisite verification, on macOS Apple Silicon. Approved tool and
package versions are in `toolchain.manifest`; this is historical provenance.

The table records SHA-256 hashes of installed rockspecs, not source archives or
compiled binaries. The original source download hashes were not retained. These
hashes are audit evidence and are not checked by setup. Installation uses the
registry named in the manifest and each rockspec's upstream source definition.
The complete installed dependency inventory was inspected with LuaRocks using
the manifest's language version and `.luarocks` tree.

| Package | Resolved revision | Installed rockspec SHA-256 |
| --- | --- | --- |
| `busted` | `2.3.0-1` | `242c883e122ab3c0cb3118e729a68b5056dea9c4dce3260c45de813cc00cc4b5` |
| `dkjson` | `2.11-1` | `5139b907b8f5d39301c7f0b8e50a09ac1d05a38619863664c2f74cd01cd66f3a` |
| `lua-term` | `0.8-1` | `401fdb79f234a0904805d68cf9afb3b904fc7539347fe6432d0c6ad487a4489c` |
| `lua_cliargs` | `3.0.2-1` | `eea2551e3fca79b4643a62bca7136ca4d7ae5c892c744c632ab3617563b2e3be` |
| `luafilesystem` | `1.9.0-1` | `32bbfb40a23a10063a8f332b874556019232e4a01e9bcd9c0cfb422118e2e1c9` |
| `luassert` | `1.9.0-1` | `ad33ef17f18afe33271ffab8c1bc1308604510b5a1f8972f1de3821406c87fae` |
| `luasystem` | `0.7.1-1` | `9f7a67f86df6268e5b1cab30b753303c1f4a08129f0b3de935104b3fff541682` |
| `mediator_lua` | `1.1.2-0` | `751debefe0aa00fa93c0ae6371922055289e9948b0231d1430c214118fdb3f3b` |
| `penlight` | `1.15.0-1` | `6e5b77b2a973fbbe94f1102d3ed7ef12ac38f9500223dd131479fe7d37109554` |
| `say` | `1.4.1-3` | `5852add6259eca33bd03c486d0a517f2d912f49bccaa854cf02281520bae2b46` |

The platform compiler and SDK are external prerequisites. Future resolution
records should retain source checksums, compiler/SDK identity, architecture,
installation commands and results, and all licences alongside their dependency
artifacts. The source-release package for Lab does not bundle these development
tools or its local test dependencies.
