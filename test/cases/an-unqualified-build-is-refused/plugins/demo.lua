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

-- A bare "build" names no toolchain. daukle would refuse it too, as a task whose
-- prefix names no declared toolchain, but it refuses with a message about the
-- prefix; the contract refuses with one about what a lifecycle task IS. This
-- case pins that the contract fires first and says the more useful thing.
daukle.task(names.assert_contract(names.BUILD, {
  name = "build",
  run = function(context)
    return context
  end,
}))
