daukle.plugin{
  api = 1,
  uses = {},
  requires = {
    lifecycle = {
      url = "https://example.invalid/never-fetched.lua",
      sha256 = "0000000000000000000000000000000000000000000000000000000000000000",
    },
  },
}

local names = daukle.require("lifecycle:lib/names")

daukle.toolchain{
  name = "demo",
  generate = function()
    return { ["names.txt"] = "unreached\n" }
  end,
}

-- "clean" is the one name defined as doing no work a process does: daukle
-- removes what it generated from its own ledger. A toolchain that attaches a run
-- function to it has either misunderstood the name or is about to delete
-- something daukle did not write, and this is the only contract check that
-- refuses a declaration daukle itself would accept.
daukle.task(names.assert_contract(names.CLEAN, {
  name = names.qualify("demo", names.CLEAN),
  run = function(context)
    return context
  end,
}))
