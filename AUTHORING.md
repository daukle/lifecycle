# Authoring notes

`plugin.lua` plus `lib/names.lua` is the whole plugin. It is published as a release asset, an
uncompressed tar of the two files, and acquired by a `[plugins]` entry naming
`daukle/lifecycle@<range>`. It is more often **required by another plugin** than declared directly:
`daukle/cmake` requires it and reads `lifecycle:lib/names`.

**This file said "there is no `plugin.lua` yet, and that is deliberate" until 2026-10-05**, which
was true when `D-37` was opened on 2026-10-01 and false from the moment the plugin was built and
released as `1.0.0`. It is recorded rather than quietly deleted because it is this organization's
most-repeated lesson aimed at itself: **a document describing what does not exist yet does not
notice when it does.** Nothing in a green suite catches it, and the repository was green
throughout.

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
resolved at load time. The dependency was the real cost: it was the first time a plugin named
another plugin.

**It has since been paid three times over and the mechanism held.** `daukle/cmake` requires this
plugin AND `daukle/c`; `daukle/gradle` requires `daukle/java` and reads its `lib/jdks`. The one
thing that surprised a reader is that **the alias is not the repository name**: `cmake` requires
`daukle/c` as `cc`, because core refuses a one-letter alias, a letter before a colon being a
Windows drive letter.

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
carries its own workflow logic. The suite exists and runs green on all three runners; a push
triggers it, and `gh workflow run test.yml --ref main` re-runs it without a commit.

`publish.yml` is the second thin caller: **a tag push is the whole release mechanism**, building
the tar and creating the release.
