local Opac = require "getaleph"
local opac = Opac.new("https://ckis.cuni.cz/F/")



describe("Basic aleph ccl search",function()
  local results = opac:search_ccl({{SYS=187872}, "or", {SYS=123322}})
  it("Should find some records", function()
    assert.same(type(results), "table")
    assert.truthy(#results>0)
  end)

  local first = results[1]
  local marc = opac:get_record(first)
  -- for k,v in pairs(marc) do
    -- print(k,v)
  -- end
  it("Should retrieve the seleceted record", function()
    assert.same(type(marc), "table")
    -- every marc record should have this field
    assert.truthy(marc["245"])
  end)
end)
