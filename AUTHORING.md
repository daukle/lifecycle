# Authoring notes

**This repository is scaffolding. There is no `plugin.lua` yet, and that is deliberate.**

The decision to build this plugin was taken on 2026-10-01. The design is not written, and writing
one now would assert mechanisms that do not exist, which is the mistake recorded against four of
daukle's own child specs. The spec is tracked as `D-37` in `daukle/docs`, and it is to be designed
alongside `D-31`, because both depend on one plugin naming another and neither has exercised that
path yet.

## The problem this plugin exists for

No plugin declares `build`. Every toolchain plugin has the same hole, so every user writes
`[tasks.build]` by hand in their own manifest, naming a task some toolchain already knows how to
run. A repository that holds only `daukle.toml` and sources is the point of managed mode, and a
hand-written lifecycle task is one of the things standing in the way.

## What was decided, and what was rejected

**This plugin owns the standard task names and toolchains join them.** It is one plugin holding the
vocabulary (`build` first, and whatever else proves to be standard rather than assumed), which
toolchain plugins depend on and contribute to.

Two alternatives were considered and rejected, and the reasons matter more than the choice:

**Each toolchain declaring its own `build`.** Cheapest, needs no repository and no new concept, and
it was the recommendation. Rejected because it gives every toolchain its own private spelling of the
same idea, which is the state that produced the hole: `java`, `cmake` and every future toolchain
would each be free to mean something slightly different by the same word, and nothing would notice.

**Core reserving the lifecycle names.** Rejected outright. daukle knowing what `build` means is the
closest this project gets to a hardcoded language concept, and `D-1` exists to deny exactly that.
`cmake/check_agnostic.cmake` would have to be weakened to allow it, which is the clearest possible
signal that it is the wrong layer.

## The cost, recorded because it was the argument against

A repository, a branch pair, a workflow, a release to publish, and a cross-plugin dependency
resolved at load time. The dependency is the real cost: it is the first time a plugin will name
another plugin, and `D-31`'s layering (`cmake` depending on `c`, `gradle` and `maven` on `java`)
uses the same mechanism. If that mechanism has a hole, both find it.

## Conventions this repository is held to

The same ones as the other plugin repositories, which `daukle/path`'s `AUTHORING.md` states in full.
The two that bite earliest:

**`* -text` in `.gitattributes` is not optional.** Every test case compares bytes against what
daukle writes, which is LF on every platform. Letting `core.autocrlf` rewrite a checkout fails the
comparison on Windows for a reason that has nothing to do with the plugin.

**`test/run.sh` must be committed with mode 100755.** Six of seven plugin repositories carried
100644 at some point, and a POSIX runner then never starts the suite at all while Windows passes,
because Git Bash ignores the bit. `git ls-files -s` is the check.

## CI

`test.yml` is a thin caller into `intisy/workflows`, per the cross-org rule that no repository
carries its own workflow logic. **It will fail until a `test/run.sh` exists**, which is why the
first commit here carries `[skip ci]`. Dispatch it by hand once the plugin and its suite land:

    gh workflow run test.yml --ref main
