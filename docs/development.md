# Local development

## Selected toolchain

| Component | Baseline | Purpose |
|---|---|---|
| Lua language | Lua 5.1 | Source compatibility. Avoid Lua 5.2–5.5-only syntax and standard-library APIs. |
| LÖVE | 11.5 | Target application framework; uses its bundled Lua runtime. |
| Standalone LuaJIT | 2.1 | Run headless Lua checks and Busted using the Lua 5.1 language baseline. |
| LuaRocks | 3.x (verified with 3.13.0) | Install local test dependencies for Lua 5.1/LuaJIT. |
| Busted | 2.3.0-1 | Standard test framework; CLI reports 2.3.0. |
| Git | 2.x | Source control. |
| POSIX shell and C build tools | Platform supplied | Development scripts and compilation of LuaRocks dependencies. |

LÖVE 11.5 is the initial project target, not a promise of compatibility with
other releases. LuaJIT 2.1 uses rolling releases; the standalone build verified
on 19 October 2026 is `2.1.1787165859`. A standalone `lua` command may point to a
newer language version and is not used for Lab checks.

Sources: [LÖVE 11.5 release](https://github.com/love2d/love/releases/tag/11.5),
[LuaJIT compatibility](https://luajit.org/extensions.html),
[LuaJIT version policy](https://luajit.org/status.html), and
[Busted 2.3.0-1](https://luarocks.org/modules/lunarmodules/busted/2.3.0-1).

## Setup

1. Install Git, LÖVE 11.5, LuaJIT 2.1, LuaRocks 3.x, and your platform's C build
   tools. On macOS, the command-line developer tools provide the compiler;
   LuaJIT and LuaRocks can be installed with Homebrew. Obtain LÖVE 11.5 from
   the release linked above. Ensure `git`, `luajit`, `luarocks`, and `love` are
   on `PATH`. On Windows, use a POSIX shell with these tools accessible.
2. Clone the repository and enter it:

   ```sh
   git clone https://github.com/Broomfields/CCL-Lab.git
   cd CCL-Lab
   ```

3. Install Busted for LuaJIT into the ignored repository-local tree. Set
   `LUAJIT_PREFIX` to the installation prefix containing LuaJIT's `bin`,
   `include`, and `lib` directories. For Homebrew on macOS:

   ```sh
   LUAJIT_PREFIX="$(brew --prefix luajit)"
   luarocks --lua-version=5.1 --lua-dir="$LUAJIT_PREFIX" --tree=.luarocks install busted 2.3.0-1
   ```

   On other systems, substitute your LuaJIT prefix (commonly `/usr` or
   `/usr/local`). LuaJIT development headers are required. LuaRocks resolves
   Busted's transitive dependencies at installation time; this is not a lockfile.

4. Verify prerequisites:

   ```sh
   sh scripts/check-prerequisites.sh
   ```

   If LÖVE is installed as a macOS application without a `love` command:

   ```sh
   LOVE_BIN=/Applications/love.app/Contents/MacOS/love sh scripts/check-prerequisites.sh
   ```

The checker reports every missing, incompatible, or failing tool and exits
nonzero if any check fails. It does not install or modify anything.

## Running Busted

After installing the local dependencies in step 3, run from the repository root:

```sh
.luarocks/bin/busted
```

The checked-in [`.busted`](../.busted) requires LuaJIT 2.1, limits
discovery to `tests/**/*_spec.lua`, and configures module lookup from the
repository root. The local LuaRocks executable uses the interpreter selected
during installation; the configuration rejects an incompatible runtime. Use
the local executable so tests load the repository's dependencies rather than
a global Busted installation. Do not add Busted's `--lua` option: restarting
the interpreter discards the local module paths set by the LuaRocks wrapper.

There are currently no specifications. Busted reports zero successes and exits
nonzero when it finds no test files; this is not a passing runtime test suite.
Add specifications as behaviour is implemented. These headless tests run in
standalone LuaJIT, without LÖVE's `love` global or a graphics window.

See [test instructions](../tests/README.md) for naming and running individual
specifications. The [official Busted documentation](https://lunarmodules.github.io/busted/)
covers installation, CLI options, `.busted` tasks, assertions, and test hooks;
the [Busted source and releases](https://github.com/lunarmodules/busted) provide
version-specific details.

## Working on Lab

Follow the [coding standards](https://github.com/Broomfields/CCL-Docs/blob/main/coding-standards.md).
Use Lua 5.1-compatible source, explicit dependencies, and behaviour-focused
Busted specifications. See [source responsibilities](../lab/README.md) and
[test instructions](../tests/README.md).

This repository is a library skeleton. It has no `main.lua`, runnable experiment,
or runtime test suite yet; `love .` is not a supported launch command. Runtime
implementation, fixtures, and CI/release workflows will follow separately.

Develop on a short-lived branch and integrate through a reviewed PR. The
[PR contract](https://github.com/Broomfields/CCL-Docs/blob/main/developer-architecture.md#13-releases-and-deployment)
requires Summary, Release Notes, and Migration sections and exactly one
release-intent label. Repository-only setup uses `release:none`.

## Troubleshooting

- A global `busted` can reference a removed Lua interpreter or modules installed
  for a different Lua version. Use `.luarocks/bin/busted` and reinstall
  the local tree for Lua 5.1 using step 3 after moving the checkout or LuaJIT.
- Lua 5.4/5.5 rocks are not interchangeable with LuaJIT's Lua 5.1 modules. Keep
  the `--lua-version=5.1` and `--lua-dir` options together during installation.
- Missing headers or compiler errors during installation require the platform's
  LuaJIT development package and C build tools.
- Passing version checks verifies the CLI prerequisites only. Graphics, audio,
  and platform packaging need separate integration checks when implemented.

## Initial verification

Verified on macOS Apple Silicon on 19 October 2026 with Git 2.55.0, LÖVE 11.5,
LuaJIT 2.1.1787165859, LuaRocks 3.13.0, and locally installed Busted 2.3.0-1:

- The documented local Busted installation completed, including native dependencies.
- The prerequisite checker passed from the repository root and another directory.
- An unavailable `LOVE_BIN` produced a diagnostic and exit status 1 while still
  checking the remaining tools.
- A temporary Busted toolchain probe passed under Lua 5.1/LuaJIT and loaded the
  native `lfs` and `system` dependencies.
- Shell syntax, Git whitespace checks, and generated-file ignore rules passed.

This verifies the development prerequisites on this machine. Other operating
systems and LÖVE graphics/audio startup have not yet been validated.
