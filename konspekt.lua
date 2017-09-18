local Opac = require "getaleph"
local cjson = require "cjson"

local opac = Opac.new("https://ckis.cuni.cz/F/")



print(opac.base_url)


-- opac:search_query( "?func=find-c&ccl_term=SYS=1878726&local_base=CKS")

-- opac:search_query("?func=find-c&ccl_term=(wau=carlyle+or+ruskin+or+hegel)")

local results = opac:search_ccl({{SYS=187872}, "or", {SYS=123322}})



local all = {}
for _,v in ipairs(results) do print(v); table.insert(all, cjson.encode(opac:get_record(v))) end


local marc = opac:get_sysno(1175616)
for k,v in pairs(marc) do
  -- print(k, table.concat(v.indicators or {}, ":"), table.concat(
  print(k, #v)
end

local json_data = cjson.encode(marc)

table.insert(all, json_data)

local full_json = "[".. table.concat(all, ",\n") .. "]"
print(json_data)

print(#cjson.decode(full_json))

