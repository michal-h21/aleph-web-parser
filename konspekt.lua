local Opac = require "getaleph"
local cjson = require "cjson"
local serpent = require "serpent"

local filename = "marcdata.json"
local opac = Opac.new("https://ckis.cuni.cz/F/")


local function get_konspekt(marc)
  local konspekty = {}
  local records = marc["072"] or {}
  for _, fields in ipairs(records) do
    for _,x in ipairs(fields.fields or {}) do
      -- print(x.name, x.value)
      if x.name == "a" then
        table.insert(konspekty, x.value)
      end
    end
  end
  return table.concat(konspekty, ";")
end

local function get_sysno(rec)
  local sys = rec["SYS"][1] or {}
  local fields = sys.fields or {}
  local sysno = fields[1].value
  return sysno
end

local function load_json(filename)
  local f = io.open(filename, "r")
  if f then
    local data = f:read("*all")
    f:close()
    return cjson.decode(data)
  end
  return {}
end

local function save_json(filename, data)
  local full_json = "[".. table.concat(data, ",\n") .. "]"
  local f = io.open(filename, "w")
  f:write(full_json)
  f:close()
end




-- print(opac.base_url)


-- opac:search_query( "?func=find-c&ccl_term=SYS=1878726&local_base=CKS")

-- opac:search_query("?func=find-c&ccl_term=(wau=carlyle+or+ruskin+or+hegel)")

-- local results = opac:search_ccl({{SYS=187872}, "or", {SYS=123322}})



local jsons = {}
local saved = load_json(filename)

local sysnos = {}

for i, rec in ipairs(saved) do
  local sysno = get_sysno(rec)
  -- save json encoded record for efficient saving
  table.insert(jsons, cjson.encode(rec))
  sysnos[sysno] = i
end

for line in io.lines() do
  local sysno = line:match("([0-9]+)")
  local saved_record = sysnos[sysno]
  local record = {}
  if not saved_record then
    record = opac:get_sysno(sysno)
    table.insert(jsons, cjson.encode(record))
    table.insert(saved, record)
    os.execute("sleep .4")
  else
    record = saved[saved_record]
  end
  save_json(filename, jsons)
end

-- for _,v in ipairs(results) do print(v); table.insert(all, cjson.encode(opac:get_record(v))) end

for _, rec in ipairs(saved) do
  print(get_sysno(rec), get_konspekt(rec))
end

-- print "get"
-- local marc = opac:get_sysno(1175616)
-- for k,v in pairs(marc) do
  -- print(k, table.concat(v.indicators or {}, ":"), table.concat(
  -- print(k, #v)
-- end

-- print "uff"

-- local json_data = cjson.encode(marc)

-- table.insert(jsons, json_data)

-- save_json(filename, jsons)

-- testujeme funkčnost ukládání do json
-- local decoded = cjson.decode(full_json)


-- for _,y in ipairs(decoded) do
  -- print(get_konspekt(y))
-- end

