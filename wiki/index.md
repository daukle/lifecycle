# daukle/lifecycle

The standard task **vocabulary**. It declares no toolchain, no language and no source: it exists to
be required by plugins that do, so that `build` means one thing across every toolchain.

## Why it exists

No toolchain declared `build`. Every toolchain had the same hole, so every user wrote
`[tasks.build]` by hand, naming a task some toolchain already knew how to run. A repository holding
only `daukle.toml` and sources is the point of managed mode, and a hand-written lifecycle task was
one of the things in the way.

## Requiring it

```lua
daukle.plugin{
  api = 1,
  uses = { "provision", "exec" },
  requires = {
    lifecycle = {
      url = "https://github.com/daukle/lifecycle/releases/download/1.0.0/plugin.lua",
      sha256 = "...",
    },
  },
}

local names = daukle.require("lifecycle:lib/names")
```

`daukle/cmake` is the plugin that does this today.

## Two alternatives were rejected, and the reasons matter more than the choice

**Each toolchain declaring its own `build`** was the cheapest option and was rejected: it gives
every toolchain a private spelling of the same idea, which is the state that produced the hole.

**Core reserving the lifecycle names** was rejected outright. daukle knowing what `build` means is
the closest this project could get to a hardcoded language concept, and the whole design exists to
deny that. A check in core's own suite refuses it, which is the clearest possible signal that it is
the wrong layer.
