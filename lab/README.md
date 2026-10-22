# Lab source

Shared runtime modules belong here. The initial module boundaries follow the
[developer architecture](https://github.com/Broomfields/CCL-Docs/blob/main/developer-architecture.md#2-repositories-and-source-structure):

| Module or folder | Responsibility |
|---|---|
| `runtime.lua` | Application lifecycle and experiment coordination. |
| `camera.lua` | Viewport and coordinate transforms. |
| `input.lua` | Input routing. |
| `time.lua` | Simulation timing and stepping. |
| `drawing.lua` | Shared drawing services. |
| `ui/` | Controls and presentation. |
| `debug/` | Inspection and diagnostics. |

The five Lua files are empty placeholders matching the architecture's initial
layout. They do not yet expose a runtime API and should not be required by an
application until implemented. Domain models and state remain experiment-owned.

Add implementation and behaviour tests together as components are developed.
