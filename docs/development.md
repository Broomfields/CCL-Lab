# Local development

## Toolchain and setup

The approved baseline lives in [`toolchain.manifest`](../toolchain.manifest).
See the [toolchain contract](toolchain.md) for the schema, exact-version setup,
external installation instructions, platform support, and upgrade policy.

After installing the recorded external tools and setting `LUAJIT_PREFIX`:

```sh
sh scripts/toolchain.sh setup
sh scripts/check-prerequisites.sh
sh tests/toolchain/check.sh
```

For a macOS application bundle, set
`LOVE_BIN=/Applications/love.app/Contents/MacOS/love` when running setup/checks.
Setup installs only missing recorded rocks into the ignored `.luarocks` tree.
For consumers of a vendored Lab package, the [toolchain contract](toolchain.md)
explains how to target the consuming project while using Lab's manifest.
It never upgrades the manifest or system tools. Checks are read-only.

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

See [external installation and restoration](toolchain.md#external-installation-and-restoration).
Do not use a global Busted launcher or reuse a dependency tree built for a
different interpreter. Passing checks establishes prerequisite availability;
graphics/audio startup and runtime integration require separate future checks.

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
