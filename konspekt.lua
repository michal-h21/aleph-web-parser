local htmlparser = require "htmlparser"
local rprint     = require "rprint"
local tidy       = require "tidy"
local sysno = arg[1]


-- local htmlfile = io.open("test.html", "r")
-- local text = htmlfile:read("*all")
-- htmlfile:close()
local text = tidy.tidy_file("test.html")
text = tidy.strip_comments(text)
text = tidy.strip_scripts(text)
local dom = htmlparser.parse(text)

local function print_children(node, level)
  local level = level or 0
  local indent = string.rep("  ", level)
  print(indent .. node.name)
  print(indent .. "id:     " .. tostring(node.id))
  print(indent .. "classes:" .. table.concat(node.classes, " "))
  print(indent .."content: " .. node:getcontent())
  print(indent .. "text:   " .. node:gettext())
  -- for k,v in pairs(node) do print(k, tostring(v)) end
  for x,y in ipairs(node.nodes) do
    print_children(y, level + 1)
  end
end
    


local tbl = dom:select("#fullbody")
if #tbl > 0 then
  -- we habe only one element with id #fullbody
  local el = tbl[1]
  -- process table rows
  for k,v in ipairs(el.nodes) do
    print "--------------------------------"
    print_children(v)
    -- print(k, v.name)
    
    -- rprint(v.nodes)
    -- local td = v:select("td")
    -- if #td > 0 then
    --   print(k, td[1]:getcontent())
    --   for x,y in ipairs(td[1].nodes) do
    --     print(x, y.name)
    --   end
    -- end
    break
  end
end



