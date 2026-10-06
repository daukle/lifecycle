## What this plugin is

A **vocabulary**, and the only plugin in this organization that is one. It declares no toolchain, no
language and no source, provisions nothing and runs nothing: it exports `lib/names`, the standard
task names, so that `build` means the same thing in every toolchain that requires it.

Core deliberately does not know what `build` means. That is the closest this project could come to a
hardcoded language concept, and `cmake/check_agnostic.cmake` in core refuses it outright. Putting
the vocabulary in a plugin is what lets core stay ignorant without every toolchain inventing its own
spelling of the same word.

## It was the first plugin to depend on another plugin

Before this repository existed, no plugin named another. The whole cost of the decision was that
dependency: a url, a digest, and a module resolved at load time.

**It has been paid three times over and the mechanism held.** `daukle/cmake` requires this plugin
and `daukle/c`; `daukle/gradle` requires `daukle/java` and reads its JDK table. What this repository
proved first is now how layering works across the organization.

## Requiring it gives you the names, not a task

Acquiring a dependency does not run its entry chunk, so a plugin that requires this one gets the
table and no `lifecycle:` task of its own. The layering is of knowledge rather than of capability,
which is the same rule `daukle/c` is held to as a base.

**The alias is not always the repository name.** Core refuses a one-letter alias, because a letter
before a colon is a Windows drive letter, which is why `daukle/cmake` requires `daukle/c` as `cc`.

## Where the rest is

Why the hole existed, how to write the `requires` entry, and the two alternatives that were rejected
are in this repository's `wiki/index.md`, rendered at <https://daukle.github.io/guide/>.
`AUTHORING.md` is the measured detail for anyone changing the plugin.
