# Local development

Lab currently contains the library skeleton and toolchain setup. Runnable
applications, runtime tests, and CI/release workflows are planned in the
[follow-through tasks](toolchain.md#follow-through).

## Setup

Follow the [external installation steps](toolchain.md#external-installation) for
the approved tools, then run:

```sh
sh scripts/toolchain.sh setup
sh scripts/check-prerequisites.sh
sh tests/toolchain/check.sh
```

The [toolchain contract](toolchain.md) defines the manifest, supported platform,
consuming-project setup, dependency restoration, and upgrade policy.

## Working on Lab

Follow the [coding standards](https://github.com/Broomfields/CCL-Docs/blob/main/coding-standards.md).
Use source compatible with the Lua language version in
[`toolchain.manifest`](../toolchain.manifest), explicit dependencies, and
behaviour-focused Busted specifications. See [source responsibilities](../lab/README.md) and
[test instructions](../tests/README.md).

Develop on a short-lived branch and integrate through a reviewed PR. The
[PR contract](https://github.com/Broomfields/CCL-Docs/blob/main/developer-architecture.md#13-releases-and-deployment)
requires Summary, Release Notes, and Migration sections, plus exactly one
release-intent label. Repository-only setup uses `release:none`.
