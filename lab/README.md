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

Implementation is tracked separately:

| File or folder | Implementation task |
|---|---|
| `runtime.lua` | [#4: Minimal application integration](https://github.com/Broomfields/CCL-Lab/issues/4), then [#6: Lifecycle and clock](https://github.com/Broomfields/CCL-Lab/issues/6). |
| `time.lua` | [#6: Lifecycle and clock](https://github.com/Broomfields/CCL-Lab/issues/6). |
| `camera.lua` | [#9: Camera](https://github.com/Broomfields/CCL-Lab/issues/9). |
| `input.lua` | [#13: Input handling](https://github.com/Broomfields/CCL-Lab/issues/13). |
| `drawing.lua` | [#16: Drawing and shaders](https://github.com/Broomfields/CCL-Lab/issues/16). |
| `ui/` | [#10: Application layout](https://github.com/Broomfields/CCL-Lab/issues/10), followed by the controls and tab tasks. |
| `debug/` | [#19: Debugging and inspection](https://github.com/Broomfields/CCL-Lab/issues/19). |

These tasks specify behaviour rather than exact filenames. Add implementation
and behaviour tests together; choose additional filenames as those components
are developed.
