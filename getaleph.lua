-- získat MARC záznam z OPACu Alephu
--
local html = require "refmanager.html"

-- we need to get a session ID first
--
local Opac = {}
Opac.__index = Opac

--- @tparam table server_url Opac base url
function Opac.new(server_url)
  local self = setmetatable({}, Opac)
  self.server = server_url
  local www = html.new()

  local initialize = www:url(server_url):get_body()
  self.base_url   = initialize:match("url=(http.-)'")
  self.www = www
  return self
end

function Opac:search(query)
  -- http://ckis.cuni.cz/F/?func=find-c&ccl_term=SYS+%3D+1878726&local_base=%70%65%64%66
  local base = self.base_url
  local www  = self.www
  local new = base .. query
  print(www:url(new):clean():get_body())
end
  



local opac = Opac.new("https://ckis.cuni.cz/F/")


print(opac.base_url)


opac:search( "?func=find-c&ccl_term=SYS+%3D+1878726&local_base=%70%65%64%66")
-- https://ckis.cuni.cz/F/279MX193TS7VJI8AXC8SFBGE95YKSIEESXU6VAUD6TQN7LHTVQ-61760?func=find-d&find_code=WAU&request=helus&adjacent1=N&find_code=WTI&request=psychologie&adjacent2=N&find_code=WRD&request=&adjacent3=N&local_base=CKS&x=0&y=0&filter_code_1=WLN&filter_request_1=&filter_code_2=WYR&filter_request_2=&filter_code_3=WYR&filter_request_3=&filter_code_4=WFM&filter_request_4=&filter_code_5=WSL&filter_request_5=
