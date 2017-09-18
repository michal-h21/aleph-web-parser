local Opac = require "getaleph"
local cjson = require "cjson"

local opac = Opac.new("https://ckis.cuni.cz/F/")


local function get_konspekt(marc)
  local konspekty = {}
  for k,v in pairs(marc["072"] or {}) do
    print("xxxL",k,v)
  end
  local records = marc["072"] or {}
  for _, fields in ipairs(records) do
    for _,x in ipairs(fields.fields or {}) do
      print(x.name, x.value)
      if x.name == "a" then
        table.insert(konspekty, x.value)
      end
    end
  end
  return table.concat(konspekty, ";")
end





print(opac.base_url)


-- opac:search_query( "?func=find-c&ccl_term=SYS=1878726&local_base=CKS")

-- opac:search_query("?func=find-c&ccl_term=(wau=carlyle+or+ruskin+or+hegel)")

local results = opac:search_ccl({{SYS=187872}, "or", {SYS=123322}})



local all = {}
for _,v in ipairs(results) do print(v); table.insert(all, cjson.encode(opac:get_record(v))) end


local marc = opac:get_sysno(1175616)
-- for k,v in pairs(marc) do
-- print(k, table.concat(v.indicators or {}, ":"), table.concat(
-- print(k, #v)
-- end

local json_data = cjson.encode(marc)

table.insert(all, json_data)

local full_json = "[".. table.concat(all, ",\n") .. "]"
-- print(json_data)

-- testujeme funkčnost ukládání do json
local decoded = cjson.decode(full_json)

for _,y in ipairs(decoded) do
  print(get_konspekt(y))
end
