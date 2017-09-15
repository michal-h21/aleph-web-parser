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

--- Get HTML content form an URL, cleaned using HTML Tidy and stripped of script tags comments.
-- @param url
-- @return HTML code
function Opac:get_clean_www(url)
  local www = self.www
  -- local ht = self:get_www(url)
  -- -- local tidyed = tidy.tidy(ht)
  -- local uncomment = tidy.strip_comments(ht)
  -- local unscript = tidy.strip_scripts(uncomment)
  -- return unscript
  return www:url(url):clean():get_body()
end

--- Build new URL for Aleph using the session number
-- @param new to be fetched
-- @return correct url
function Opac:build_url(new)
  local new = new
  if new:match("^http") then
    new = new:match("(%?.*)$")
  end
  if new:sub(1,1)~="?" then
    new = "?" .. new
  end
  return self.base_url .. new
end


--- Find links to records for results 
-- @param body HTML string with search results
-- @return Table with links to records
function Opac:get_result(body)
  -- the HTML page with results is invalid mess, it breaks HTML tidy and parser
  -- so we must extract only the relevant table using regex, it can be then 
  -- processed using DOM
  local result_table =  body:match("(<table[^>]-short%-a%-table.-</table>)")
  print(result_table)
  local www = self.www
  local dom = www:string(result_table):get_dom()
  local urls = {}
  for _, row in ipairs(dom:select("tr")) do
    -- uppercase elements and attributes. really?
    -- another Aleph madness
    local links = row:select("td A")
    if #links > 0 then
      print(links[1].attributes[ "HREF" ])
    end
    -- the anchor is only in the first table column
    -- 
  end
  return urls
end



--- Search using URL
-- @param query URL to be searched 
-- @return table with search results URLs
function Opac:search_query(query)
  -- http://ckis.cuni.cz/F/?func=find-c&ccl_term=SYS+%3D+1878726&local_base=%70%65%64%66
  local new = self:build_url(query)
  local body = self:get_clean_www(new)
  local result_table = self:get_result(body)
  return result_table
end

--- Build CCL query
-- @param options Table with CCL fields
-- It should look like: {{SYS=187872}, "or", {SYS=123322}}
function Opac:build_ccl_query(options)
  local query = {}
  local logical 
  for _, object in ipairs(options) do
    -- string object can be and, or, not
    if type(object) == "string" then
      logical = object
    elseif type(object) == "table" then
      -- keys should be CCL code, value can be string or table with multiple values which will be joined using "or"
      for k,v in pairs(object) do
        local values
        if type(v) == "table" then
          values = table.concat(v, "+")
        else
          values = v
        end
        local current_query = string.format("(%s=%s)", k, values)
        query[#query+1] = logical
        query[#query+1] = current_query
        logical = "and"
      end
    end

  end
  return table.concat(query, "+")
  -- https://ckis.cuni.cz/F/KA1TUX3X6RLRUDJ8CB4C7I5UQVAFSEHR8D2EMCCT9RR9YJU8ME-46290?func=find-c&ccl_term=(wau=carlyle+or+ruskin+or+hegel)+and+(wti=kultur?)&adjacent=N&local_base=CKS&x=42&y=11&filter_code_1=WLN&filter_request_1=&filter_code_2=WYR&filter_request_2=&filter_code_3=WYR&filter_request_3=&filter_code_4=WFM&filter_request_4=&filter_code_5=WSL&filter_request_5=

end

--- Search using CCL table query
function Opac:search_ccl(query)
  local ccl = self:build_ccl_query(query)
  local search = string.format("?func=find-c&ccl_term=%s", ccl)
  return self:search_query(search)
end


local opac = Opac.new("https://ckis.cuni.cz/F/")
-- local opac = Opac.new("https://ckis.cuni.cz:443/F/9VQ26UBEQBE7N7NY8FKVBD9THK99QQNS5XIXGVTBXUUGCHRTIH-37482?func=find-c&ccl_term=sys=1878726&adjacent=N&local_base=CKS&x=0&y=0&filter_code_1=WLN&filter_request_1=&filter_code_2=WYR&filter_request_2=&filter_code_3=WYR&filter_request_3=&filter_code_4=WFM&filter_request_4=&filter_code_5=WSL&filter_request_5=")



print(opac.base_url)


-- opac:search( "?func=find-c&ccl_term=SYS=1878726&local_base=CKS&x=0&y=0&filter_code_1=WLN&filter_request_1=&filter_code_2=WYR&filter_request_2=&filter_code_3=WYR&filter_request_3=&filter_code_4=WFM&filter_request_4=&filter_code_5=WSL&filter_request_5=")
opac:search_query( "?func=find-c&ccl_term=SYS=1878726&local_base=CKS")

opac:search_query("?func=find-c&ccl_term=(wau=carlyle+or+ruskin+or+hegel)")

opac:search_ccl({{SYS=187872}, "or", {SYS=123322}})

-- opac:search( "?func=find-c&ccl_term=SYS=1878726&local_base=CKS&x=0&y=0&filter_code_1=WLN&filter_request_1=&filter_code_2=WYR&filter_request_2=&filter_code_3=WYR&filter_request_3=&filter_code_4=WFM&filter_request_4=&filter_code_5=WSL&filter_request_5=")
-- https://ckis.cuni.cz/F/AJG1KRKT2RSVJMN1QACVQ4XGH2XFLIYNV7ND836QU1UU362IAB-35717?func=find-c&ccl_term=sys=1878726&adjacent=N&local_base=CKS&x=0&y=0&filter_code_1=WLN&filter_request_1=&filter_code_2=WYR&filter_request_2=&filter_code_3=WYR&filter_request_3=&filter_code_4=WFM&filter_request_4=&filter_code_5=WSL&filter_request_5=
-- https://ckis.cuni.cz:443/F/9VQ26UBEQBE7N7NY8FKVBD9THK99QQNS5XIXGVTBXUUGCHRTIH-37482?func=find-c&ccl_term=sys=1878726&adjacent=N&local_base=CKS&x=0&y=0&filter_code_1=WLN&filter_request_1=&filter_code_2=WYR&filter_request_2=&filter_code_3=WYR&filter_request_3=&filter_code_4=WFM&filter_request_4=&filter_code_5=WSL&filter_request_5=

-- https://ckis.cuni.cz/F/279MX193TS7VJI8AXC8SFBGE95YKSIEESXU6VAUD6TQN7LHTVQ-61760?func=find-d&find_code=WAU&request=helus&adjacent1=N&find_code=WTI&request=psychologie&adjacent2=N&find_code=WRD&request=&adjacent3=N&local_base=CKS&x=0&y=0&filter_code_1=WLN&filter_request_1=&filter_code_2=WYR&filter_request_2=&filter_code_3=WYR&filter_request_3=&filter_code_4=WFM&filter_request_4=&filter_code_5=WSL&filter_request_5=
