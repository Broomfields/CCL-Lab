# Toolchain contract

Lab owns the approved baseline in [`toolchain.manifest`](../toolchain.manifest).
It is separate from repository release metadata and experiment version metadata.
Template and experiments consume this manifest from the exact published Lab
release selected by their version metadata. They do not maintain separate
copies of toolchain requirements. Their version metadata remains responsible for
experiment version, Template provenance and the exact Lab dependency as applicable.

## Manifest schema 1

The manifest is UTF-8/ASCII-compatible text with one `key=value` per line.
Empty lines and full-line comments beginning with `#` are allowed; LF and CRLF
are accepted. Whitespace around assignments, inline comments, duplicate keys,
unknown keys, missing keys and unsupported values are errors. Values are data,
never executable Lua or shell. The parser is `scripts/toolchain/manifest.lua`.

| Keys | Meaning |
| --- | --- |
| `schema` | Format version; only schema 1 is implemented. |
| `language.lua` | Source language compatibility; schema 1 supports Lua 5.1. |
| `tool.love` | Exact framework release (`major.minor`); LÖVE supplies its own runtime. |
| `tool.luajit` | Exact standalone rolling build (`2.1.build`), used by local checks. |
| `tool.luarocks` | Exact installer version (`major.minor.patch`). |
| `rock.*` | Exact package versions including rockspec revisions (`version-revision`). |
| `rocks.server` | Explicit LuaRocks registry; schema 1 uses `https://luarocks.org`. |
| `platform.setup` | Supported setup target; initially `Darwin-arm64`. |
| `prerequisite.git` | Required Git major version, not a pinned tool release. |
| `prerequisite.compiler` | Platform-provided compiler command, initially `cc`. |

All keys in the checked-in manifest are required. Schema 1 explicitly enumerates
the resolved Busted dependency closure; adding/removing dependency names requires
updating the schema/parser and its fixtures. Framework/tool versions and rocks are
approved pins; Git and the platform compiler are prerequisites, not claims of
identical compiler builds. The standalone runtime is distinct from LÖVE's bundled
runtime. Format constraints do not themselves approve a new version.

## Commands and exit status

Run from the repository root (the scripts also work from other directories):

```sh
sh scripts/toolchain.sh validate
sh scripts/toolchain.sh check
sh scripts/toolchain.sh setup
sh tests/toolchain/check.sh
```

`validate [path]` reads and checks a manifest without inspecting installed tools.
Paths passed explicitly are relative to the caller's directory.

For Template development or a generated experiment, invoke the setup entry point
from its verified vendored Lab package and name the consuming project directory:

```sh
sh vendor/lab/scripts/toolchain.sh setup --project-dir .
sh vendor/lab/scripts/toolchain.sh check --project-dir .
```

`setup` and `check` accept `--project-dir <directory>`. The directory must already
exist; relative paths are resolved against the caller's working directory. Without
this option, both commands target Lab's own checkout, preserving Lab development
behaviour. The manifest always comes from the Lab copy containing the invoked
script. The option changes only the destination/inspection tree to
`<project-dir>/.luarocks`, including the Busted launcher used by checks. A manifest
in the consuming project root is ignored. Nothing is installed inside vendored
Lab when the consuming project is explicitly selected.

Template owns the preceding bootstrap: read its declared Lab release, fetch or
restore a verified cached package into `vendor/lab`, and verify release identity
and provenance before invoking these commands. The Lab source-package contract
must include this setup entry point and its implementation/parser alongside the
manifest so consumers can reuse them. Fetching, package publication and workflow
integration remain downstream; controlled package fixtures exercise this interface
until those capabilities exist. Minimal tools needed to fetch Lab must be available
before its toolchain can be read. The current checker does not verify release
identity and does not fetch anything.

`check` checks the platform, external tools, exact selected-project rock inventory
and Busted CLI. `scripts/check-prerequisites.sh` remains a read-only alias. `setup` performs
those external checks before installing anything, refuses an unexpected existing
rock/version, then installs each missing recorded rock with `--deps-mode=none`
and an explicit registry. No dependency version is selected by a resolver during
ordinary setup. A second successful setup performs no installations. Neither
command edits the approved manifest, installs system tools, or upgrades packages.

Commands exit 0 on success and 1 on validation/setup errors. Missing LuaJIT is
reported by the shell entry point before parsing. These contract tests do not
require Busted and do not depend on the downstream local-testing task.

## External installation and restoration

Read the required versions from the manifest before installing anything. On the
supported macOS Apple Silicon target:

1. Install Apple's command-line developer tools (`xcode-select --install`) for
   `cc` and Git. Git must satisfy the manifest prerequisite.
2. Obtain the exact LÖVE release from [official releases](https://github.com/love2d/love/releases).
   For the application bundle, set `LOVE_BIN=/Applications/love.app/Contents/MacOS/love`.
3. Install the exact standalone LuaJIT build, including development headers and
   libraries, and the exact LuaRocks version. See [LuaJIT installation](https://luajit.org/install.html)
   and [LuaRocks releases](https://github.com/luarocks/luarocks/releases).
   Existing Homebrew installations are usable only when the checker confirms the
   recorded versions; an unqualified `brew install` or upgrade is not a pinned
   provisioning recipe. No automatic system-tool provisioning is supplied here.
4. Put `luajit`, `luarocks`, `git` and `cc` on PATH. Set `LUAJIT_PREFIX` to the
   approved installation containing `bin`, `include` and `lib`. For an existing
   verified Homebrew installation, `brew --prefix luajit` locates that prefix.
5. Run `sh scripts/toolchain.sh setup`, then `sh scripts/toolchain.sh check`.

Linux, Windows and Intel macOS are not yet supported by this setup entry point.
Supporting them requires a recorded platform recipe and fresh validation, not
silently relaxing the platform gate.

An interrupted ordinary setup can leave successfully installed approved rocks in
the selected project's `.luarocks`; correct the reported problem and rerun it.
The approved manifest is unchanged. If inventory checks detect unapproved or multiple package versions,
preserve/rename the old `.luarocks` directory and create a fresh tree with setup.
Do not reuse a tree from another interpreter, machine, or checkout location:
LuaRocks launchers and native modules can embed paths. There is no automatic
removal of an existing environment. Dependency setup needs network access to the
recorded registry and package source hosts; a missing pinned package is an error,
never a reason to substitute the latest version.

## Resolution and reproducibility limits

The `rock.*` entries record the full dependency inventory of the existing verified
local Busted environment, including native `luafilesystem`, `lua-term` and
`luasystem`. The initial inventory was captured from the verified macOS Apple
Silicon development environment and checked with a fresh installation in a
temporary dependency tree. Setup pins those package revisions and disables
transitive resolution; it does not assert byte-for-byte builds.

Registry assets, source tags, compiler/SDK versions and external-tool installation
recipes are not fully content-addressed by this foundation. There is no
installer-enforced source lock. Future immutable
reproduction must record and verify source/archive digests, complete platform
build inputs and any changed transitive closure. Never describe top-level pins
alone as full reproducibility. Package licences remain with their packages.

## Explicit upgrade contract (execution deferred)

`sh scripts/toolchain.sh upgrade` currently fails without changing anything and
points to [Lab #3](https://github.com/Broomfields/CCL-Lab/issues/3). It must not
pretend that prerequisite checks approve a candidate runtime.

The downstream implementation must:

1. Start only at a maintainer's request; resolve stable candidate versions and
   their complete dependency closure in an isolated environment.
2. Record exact Lab/Template candidate revisions, platform/build provenance and
   tool versions. Run applicable checks there, extending them with a fresh
   application and actual LÖVE startup when the runtime fixture exists.
3. On failure, preserve the approved Lab manifest, declared dependency metadata
   and working environment.
   On success, prepare reviewable edits and optional linked draft PRs. Never
   automatically approve, merge or publish them.
4. Require maintainer application testing and review of the exact tested pair;
   changed candidates invalidate previous evidence.
5. Publish Lab first. Template then adopts that exact published release and
   rechecks the real clean-fetch path before its own release.

Every subsequent approved tool-version change, including development tools and
resolved rocks, requires Lab major release intent and a subsequent Template major
release adopting it. Repository major numbers need not match. Latest releases may
temporarily differ; each pairing consumes its declared Lab release's manifest.
This initial recording of the already selected baseline is repository setup
(`release:none`), not an upgrade.

Changing the selected Lab release does not delete the consuming project's rock
tree. Setup/check validates that existing tree against the newly selected manifest
and reports incompatible versions; it does not silently replace them. Restoration
is explicit, as described above.

The foundation does not implement full Busted suites, runtime integration,
GitHub Actions, upgrade orchestration, application metadata, fetching or release
assets. Those remain in [local testing #2](https://github.com/Broomfields/CCL-Lab/issues/2),
[validation #3](https://github.com/Broomfields/CCL-Lab/issues/3),
[runtime fixture #4](https://github.com/Broomfields/CCL-Lab/issues/4), and
[source releases #5](https://github.com/Broomfields/CCL-Lab/issues/5), plus the
existing version-metadata and dependency-fetch tasks. No dependency cycle through
those tasks is required to finish this foundation.
