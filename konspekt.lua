local htmlparser = require "htmlparser"
local sysno = arg[1]

local htmlfile = io.open("test.html", "r")
local text = htmlfile:read("*all")
htmlfile:close()
local dom = htmlparser.parse(text)


local tbl = dom:select("#fullbody")
if #tbl > 0 then
  -- we habe only one element with id #fullbody
  local el = tbl[1]
  -- process table rows
  for k,v in ipairs(el.nodes) do
    print(k, v.name)
    local td = v:select("td")
    if #td > 0 then
      print(k, td[1]:getcontent())
      for x,y in ipairs(td[1].nodes) do
        print(x, y.name)
      end
    end
  end
end



