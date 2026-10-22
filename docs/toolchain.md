# Toolchain contract

Lab owns the approved toolchain in [`toolchain.manifest`](../toolchain.manifest).
Template and experiments consume that manifest from their exact declared Lab
release. Application version metadata records the experiment version, Template
provenance, and selected Lab release.

## Manifest schema 1

The parser in `scripts/toolchain/manifest.lua` reads data-only text with one
`key=value` per line. It accepts blank lines, full-line comments beginning with
`#`, and LF or CRLF line endings. It rejects whitespace around assignments,
inline comments, duplicate or unknown keys, missing keys, and unsupported values.

| Keys | Meaning |
| --- | --- |
| `schema` | Format version. Only schema 1 is implemented. |
| `language.lua` | Required Lua language version for source compatibility. |
| `tool.love` | Exact framework release (`major.minor`), including its bundled runtime. |
| `tool.luajit` | Exact standalone rolling build for local checks. |
| `tool.luarocks` | Exact installer version (`major.minor.patch`). |
| `rock.*` | Exact package versions, including rockspec revisions (`version-revision`). |
| `rocks.server` | Package registry. Schema 1 uses `https://luarocks.org`. |
| `platform.setup` | Supported setup target, initially `Darwin-arm64`. |
| `prerequisite.git` | Required Git major version. |
| `prerequisite.compiler` | Platform-provided compiler command, initially `cc`. |

All keys in the manifest are required. Adding or removing dependency names
requires updating the parser and its fixtures. Version approval follows the
[upgrade contract](#upgrades).

## Commands

Run these commands from the repository root:

```sh
sh scripts/toolchain.sh validate
sh scripts/toolchain.sh setup
sh scripts/toolchain.sh check
```

| Command | Behaviour |
| --- | --- |
| `validate [path]` | Validates the supplied manifest, defaulting to Lab's manifest. |
| `setup [--project-dir directory]` | Checks external prerequisites and the existing rock inventory, then installs missing recorded rocks. |
| `check [--project-dir directory]` | Checks the platform, external tools, exact rock inventory, and local Busted CLI. |
| `upgrade` | Exits with an error until the upgrade workflow is implemented. |

`validate` and `check` are read-only. `setup` preserves the manifest and system
tools. It installs from the recorded registry with `--deps-mode=none`, using the
recorded version of every dependency. Repeating a successful setup skips all
installations. `scripts/check-prerequisites.sh` remains an alias for Lab's check.

Commands exit 0 on success and 1 on validation or setup errors. The shell entry
point reports missing LuaJIT before parsing. Scripts can be invoked from other
working directories by supplying their paths.

### Consuming projects

After verifying the declared Lab package, Template or an experiment can run:

```sh
sh vendor/lab/scripts/toolchain.sh setup --project-dir .
sh vendor/lab/scripts/toolchain.sh check --project-dir .
```

The manifest comes from the Lab copy containing the invoked script. The project
directory determines the `.luarocks` tree and Busted launcher used by setup and
checks. It must already exist and defaults to Lab's checkout. Explicit relative
paths are resolved from the caller's working directory.

Template's bootstrap reads the release declaration, fetches Lab or restores a
verified cache into `vendor/lab`, and verifies its identity and provenance.
The tools needed for this fetch must be available before Lab's manifest can be
read. The published Lab package must include the manifest, setup entry point,
implementation, and parser in the layout those scripts expect.

## External installation

Setup currently supports macOS Apple Silicon. Each additional platform needs an
installation recipe and validation before its platform check can be enabled.

Read the required versions from the manifest, then:

1. Install Apple's command-line developer tools (`xcode-select --install`) for
   `cc` and Git. Git must satisfy the manifest prerequisite.
2. Obtain the recorded LÖVE release from [official releases](https://github.com/love2d/love/releases).
   For an application bundle, set `LOVE_BIN=/Applications/love.app/Contents/MacOS/love`.
3. Install the recorded standalone LuaJIT build, including development headers
   and libraries, and the recorded LuaRocks version. See [LuaJIT installation](https://luajit.org/install.html)
   and [LuaRocks releases](https://github.com/luarocks/luarocks/releases).
   Existing Homebrew installations are usable when their versions pass the checker.
4. Put `luajit`, `luarocks`, `git`, and `cc` on PATH. Set `LUAJIT_PREFIX` to the
   approved installation containing `bin`, `include`, and `lib`. For Homebrew,
   `brew --prefix luajit` locates that prefix.
5. Run `sh scripts/toolchain.sh setup`, then `sh scripts/toolchain.sh check`.

Dependency installation needs network access to the recorded registry and package
source hosts. An unavailable pinned package causes setup to fail.

## Restoring dependencies

An interrupted setup can leave successfully installed rocks in the project's
`.luarocks` directory. Correct the reported problem and rerun setup.

Setup rejects unexpected or multiple installed package versions. To restore the
approved environment, rename the existing `.luarocks` directory and run setup to
create a fresh tree. Rebuild the tree after changing interpreter, machine, or
checkout location because launchers and native modules can embed paths.

Selecting another Lab release preserves the project's installed dependencies.
Setup checks them against the selected manifest and reports any version mismatch.
Use the same restoration process when the required versions change.

## Reproducibility

The manifest records Busted and its complete dependency set, including the
native `luafilesystem`, `lua-term`, and `luasystem` packages.

The current guarantee is package-version pinning. Byte-for-byte reproduction
would also require verified source/archive hashes and complete platform build
inputs, including compiler and SDK versions. Package licences remain with their
packages.

## Upgrades

The upgrade workflow must:

1. Start at a maintainer's request and resolve stable candidate versions with
   their complete dependency set in an isolated environment.
2. Record exact Lab and Template revisions, platform/build provenance, and tool
   versions. Run the available checks, including a fresh application and LÖVE
   startup once the runtime fixture exists.
3. Preserve the approved Lab manifest, dependency declarations, and working
   environment on failure. On success, prepare reviewable edits and optional
   linked draft PRs.
4. Require maintainer application testing and approval of the tested pair.
   Candidate changes require fresh checks and review. Merging and publication
   remain maintainer-controlled.
5. Publish Lab first. Template then adopts that exact release and verifies the
   clean-fetch path before its own release.

Every approved tool-version change, including development tools and resolved
rocks, requires a Lab major release and a subsequent Template major release.
Each repository advances its own version sequence. Template can continue using
its declared Lab release while a newer Lab release awaits adoption.

Recording the initial approved baseline uses `release:none`.

## Follow-through

| Work | Owner |
| --- | --- |
| Full Busted setup and local validation | [Lab #2](https://github.com/Broomfields/CCL-Lab/issues/2) |
| CI and isolated upgrade execution | [Lab #3](https://github.com/Broomfields/CCL-Lab/issues/3) |
| Runtime fixture and LÖVE startup checks | [Lab #4](https://github.com/Broomfields/CCL-Lab/issues/4) |
| Source packages and release/fetch verification | [Lab #5](https://github.com/Broomfields/CCL-Lab/issues/5) |
| Release declarations and dependency fetching | Existing version-metadata and dependency-fetch tasks |

Controlled package fixtures exercise the consumption interface until fetching
and published releases are available. Foundation checks establish manifest and
setup behaviour. Runtime compatibility requires the later integration checks.
These downstream tasks can build on the foundation without blocking its completion.
