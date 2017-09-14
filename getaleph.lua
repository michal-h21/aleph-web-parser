-- získat MARC záznam z OPACu Alephu
--
local html = require "refmanager.html"
local tidy = require "refmanager.tidy"

-- we need to get a session ID first
--
local Opac = {}
Opac.__index = Opac

--- @tparam table server_url Opac base url
function Opac.new(server_url)
  local self = setmetatable({}, Opac)
  self.server = server_url
  local www = html.new()
  self.www = www
  -- we must load the Aleph landing page first, to obtain the
  -- session id
  local initialize = self:get_www(server_url)
  -- print(initialize)
  -- then we must load the search form, which will give us ID for searching
  local form_url   = self:get_sessionnumber(initialize)
  local search_form = self:get_www(form_url) 
  self.base_url = self:get_search_url(search_form)
  return self
end

--- Find base url with session number on basic Aleph page
-- @param body HTML code of the Aleph landing page
-- @return url of the search form
function Opac:get_sessionnumber(body)
  return body:match("url=(http.-)'")
end


--- Get base url from Aleph search form
-- @param body HTML code of the search form
-- @return base url
function Opac:get_search_url(body)
  return body:match('action="(.-)"')
end

--- Get HTML content from an URL
-- @param url
-- @return HTML code
function Opac:get_www(url)
  local www = self.www
  return www:url(url):get_body()
end

--- Get HTML content form an URL, cleaned using HTML Tidy and stripped of <script> tags comments.
-- @param url
-- @return HTML code
function Opac:get_clean_www(url)
  local www = self.www
  local ht = self:get_www(url)
  -- local tidyed = tidy.tidy(ht)
  local uncomment = tidy.strip_comments(ht)
  local unscript = tidy.strip_scripts(uncomment)
  return unscript
  -- return www:url(url):clean():get_body()
end

function Opac:search(query)
  -- http://ckis.cuni.cz/F/?func=find-c&ccl_term=SYS+%3D+1878726&local_base=%70%65%64%66
  local base = self.base_url
  local new = base .. query
  local body = self:get_clean_www(new)
  print(body)
end






local opac = Opac.new("https://ckis.cuni.cz/F/")
-- local opac = Opac.new("https://ckis.cuni.cz:443/F/9VQ26UBEQBE7N7NY8FKVBD9THK99QQNS5XIXGVTBXUUGCHRTIH-37482?func=find-c&ccl_term=sys=1878726&adjacent=N&local_base=CKS&x=0&y=0&filter_code_1=WLN&filter_request_1=&filter_code_2=WYR&filter_request_2=&filter_code_3=WYR&filter_request_3=&filter_code_4=WFM&filter_request_4=&filter_code_5=WSL&filter_request_5=")



print(opac.base_url)


opac:search( "?func=find-c&ccl_term=SYS=1878726&local_base=CKS&x=0&y=0&filter_code_1=WLN&filter_request_1=&filter_code_2=WYR&filter_request_2=&filter_code_3=WYR&filter_request_3=&filter_code_4=WFM&filter_request_4=&filter_code_5=WSL&filter_request_5=")
-- opac:search( "?func=find-c&ccl_term=SYS=1878726&local_base=CKS&x=0&y=0&filter_code_1=WLN&filter_request_1=&filter_code_2=WYR&filter_request_2=&filter_code_3=WYR&filter_request_3=&filter_code_4=WFM&filter_request_4=&filter_code_5=WSL&filter_request_5=")
-- https://ckis.cuni.cz/F/AJG1KRKT2RSVJMN1QACVQ4XGH2XFLIYNV7ND836QU1UU362IAB-35717?func=find-c&ccl_term=sys=1878726&adjacent=N&local_base=CKS&x=0&y=0&filter_code_1=WLN&filter_request_1=&filter_code_2=WYR&filter_request_2=&filter_code_3=WYR&filter_request_3=&filter_code_4=WFM&filter_request_4=&filter_code_5=WSL&filter_request_5=
-- https://ckis.cuni.cz:443/F/9VQ26UBEQBE7N7NY8FKVBD9THK99QQNS5XIXGVTBXUUGCHRTIH-37482?func=find-c&ccl_term=sys=1878726&adjacent=N&local_base=CKS&x=0&y=0&filter_code_1=WLN&filter_request_1=&filter_code_2=WYR&filter_request_2=&filter_code_3=WYR&filter_request_3=&filter_code_4=WFM&filter_request_4=&filter_code_5=WSL&filter_request_5=

-- https://ckis.cuni.cz/F/279MX193TS7VJI8AXC8SFBGE95YKSIEESXU6VAUD6TQN7LHTVQ-61760?func=find-d&find_code=WAU&request=helus&adjacent1=N&find_code=WTI&request=psychologie&adjacent2=N&find_code=WRD&request=&adjacent3=N&local_base=CKS&x=0&y=0&filter_code_1=WLN&filter_request_1=&filter_code_2=WYR&filter_request_2=&filter_code_3=WYR&filter_request_3=&filter_code_4=WFM&filter_request_4=&filter_code_5=WSL&filter_request_5=
