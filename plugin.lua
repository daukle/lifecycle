--- daukle/lifecycle: the standard task names, and what each one promises.
---
--- This plugin registers NOTHING. It declares no toolchain, no language, no
--- source and no task, and it is the first plugin in this org that does not: it
--- is a library distributed as a plugin, and daukle's acquisition makes no
--- distinction. A toolchain depends on it for the vocabulary and declares its
--- own tasks with it.
---
--- It requires nothing either, deliberately. A toolchain requires lifecycle, so
--- lifecycle requiring a toolchain would be a cycle, and the only way to be sure
--- there is never one is to be a leaf.
daukle.plugin{
  api = 1,
  uses = {},
  exports = { "lib/names" },
}
