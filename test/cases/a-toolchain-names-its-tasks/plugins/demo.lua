daukle.plugin{
  api = 1,
  uses = {},
  requires = {
    -- The url and digest are what a published lifecycle would be pinned by. The
    -- manifest overrides this alias with a path, so neither is ever fetched, and
    -- the digest is a placeholder rather than a wrong pin: an override replaces
    -- the whole entry.
    lifecycle = {
      url = "https://example.invalid/never-fetched.lua",
      sha256 = "0000000000000000000000000000000000000000000000000000000000000000",
    },
  },
}

local names = daukle.require("lifecycle:lib/names")

daukle.toolchain{
  name = "demo",
  -- The generated file carries what the vocabulary answered, so the expected
  -- bytes fail if qualify returns anything else, if the module resolves to the
  -- wrong artifact, or if it comes back empty.
  generate = function(toolchain)
    return {
      ["names.txt"] = names.qualify("demo", names.BUILD) .. "\n"
        .. names.qualify("demo", names.TEST) .. "\n"
        .. names.CONTRACTS[names.TEST].after .. "\n"
        .. tostring(names.CONTRACTS[names.CLEAN].runs) .. "\n"
        .. "project " .. toolchain.project .. "\n",
    }
  end,
}

daukle.task(names.assert_contract(names.BUILD, {
  name = names.qualify("demo", names.BUILD),
  run = function(context)
    return context
  end,
}))
