--- The standard task names, and what a task of each name promises.
---
--- This module computes and holds tables. It registers nothing and it cannot:
--- a module reached across a plugin boundary gets a daukle table holding exactly
--- "require", so daukle.task is not reachable from here. That is why this plugin
--- is a vocabulary rather than a mechanism, and the spec records the two core
--- changes the stronger shape would need, neither of which is worth the problem.
--- See D-37.

--- The names. Spelled once, so two toolchains cannot drift to "build" and
--- "compile" without someone editing this line.
local BUILD = "build"
local TEST = "test"
local RUN = "run"
local CLEAN = "clean"

--- What a name promises. This is the part that actually stops two toolchains
--- meaning different things by one word, and it is prose plus a check rather
--- than a mechanism.
---
--- runs: whether a task of this name starts a process. A name that does not run
--- must be declarable by a plugin holding no exec grant at all, which is why it
--- is a field rather than an assumption: "clean" is the one that differs.
---
--- after: the name a task of this name may assume has already run, or nil. It is
--- a statement about MEANING, not an edge. daukle takes its edges from dependsOn
--- and this module cannot add one, so a toolchain writes dependsOn itself; the
--- field exists so that two toolchains agree on what they are ordering.
local CONTRACTS = {
  [BUILD] = {
    runs = true,
    after = nil,
    means = "produce the toolchain's primary output from the sources the manifest names",
  },
  [TEST] = {
    runs = true,
    after = BUILD,
    means = "run the project's tests against what build produced",
  },
  [RUN] = {
    runs = true,
    after = BUILD,
    means = "start what build produced, as a user would",
  },
  [CLEAN] = {
    runs = false,
    after = nil,
    means = "remove what this toolchain generated, and nothing a person wrote",
  },
}

--- The qualified name daukle expects, "<toolchain>:<name>". Spelled here so a
--- toolchain writes qualify("cmake", names.BUILD) rather than concatenating,
--- which is where a stray space or a second colon gets in.
local function qualify(toolchain, name)
  if type(toolchain) ~= "string" or toolchain == "" then
    error("daukle/lifecycle: qualify needs a toolchain name", 0)
  end
  if string.find(toolchain, ":", 1, true) ~= nil then
    error("daukle/lifecycle: the toolchain name \"" .. toolchain .. "\" already holds a colon", 0)
  end
  if CONTRACTS[name] == nil then
    error("daukle/lifecycle: \"" .. tostring(name) .. "\" is not a lifecycle name", 0)
  end
  return toolchain .. ":" .. name
end

--- Raises if a declaration does not keep the promise its name makes. A toolchain
--- calls it on its own declaration before handing that table to daukle.task, so
--- a mistake names the contract rather than arriving as a daukle refusal about a
--- field.
---
--- It checks what it can see, and the list is short on purpose. A task
--- declaration takes exactly name, partOf, dependsOn and run; there is no "from"
--- key, which the first draft of this module asserted there was. The toolchain a
--- task belongs to is the prefix of its own name, and whether that toolchain was
--- declared is daukle's check, not this one's: a library module cannot read the
--- registry.
local function assert_contract(name, declaration)
  local contract = CONTRACTS[name]
  if contract == nil then
    error("daukle/lifecycle: \"" .. tostring(name) .. "\" is not a lifecycle name", 0)
  end
  if type(declaration) ~= "table" then
    error("daukle/lifecycle: " .. name .. " needs a declaration table", 0)
  end

  local qualified = declaration.name
  if type(qualified) ~= "string" then
    error("daukle/lifecycle: " .. name .. " needs a name string", 0)
  end
  local colon = string.find(qualified, ":", 1, true)
  if colon == nil then
    error("daukle/lifecycle: \"" .. qualified .. "\" must be qualified as \"<toolchain>:"
          .. name .. "\", because a lifecycle task acts on one toolchain's output", 0)
  end
  if string.sub(qualified, colon + 1) ~= name then
    error("daukle/lifecycle: \"" .. qualified .. "\" was checked against the contract for \""
          .. name .. "\", which is not the name after its colon", 0)
  end

  if contract.runs and type(declaration.run) ~= "function" then
    error("daukle/lifecycle: " .. name .. " must carry a run function, because it is defined as "
          .. contract.means, 0)
  end
  if not contract.runs and declaration.run ~= nil then
    error("daukle/lifecycle: " .. name .. " may not carry a run function: it is defined as "
          .. contract.means .. ", which daukle does itself", 0)
  end
  return declaration
end

return {
  BUILD = BUILD,
  TEST = TEST,
  RUN = RUN,
  CLEAN = CLEAN,
  CONTRACTS = CONTRACTS,
  qualify = qualify,
  assert_contract = assert_contract,
}
