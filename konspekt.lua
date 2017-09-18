local htmlparser = require "htmlparser"
local rprint     = require "rprint"
local tidy       = require "refmanager.tidy"
local fs         = require "luarocks.fs.lua"
local dir        = require "luarocks.dir"
local lpackage   = require "luarocks.repos"


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
  -- print(indent .. "id:     " .. tostring(node.id))
  -- print(indent .. "classes:" .. table.concat(node.classes, " "))
  print(indent .."content: " .. node:getcontent())
  -- print(indent .. "text:   " .. node:gettext())
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
    -- break
  end
  -- end
end


for k,v in pairs(fs.list_dir()) do
  print("fs", k,v)
end

print("dir name", dir.dir_name("/usr/local/bin/env"))

local manif = require "luarocks.manif"
local search = require "luarocks.search"
local cfg  = require "luarocks.cfg"

print(cfg.rocks_provided["lua-refmanager"])
for k,v in pairs(cfg.rocks_provided) do print("provided", k,v) end

-- local query = search.make_query("lpeg")
-- local result = search.search_repos(query)
-- print("result", #result)
-- for k,v in pairs(result) do print("search", k,v) end
-- for k,v in pairs() do
--   print("version",k, tostring(v))
-- end

