local test = [[
<!DOCTYPE html>
<html>
<body>
<table id="fullbody" cellspacing=2 border=0 width="100%"> 
<!-- end filename: full-set-head-ill-nobor --> 

<!-- filename: full-999-body --> 
 <tr> 
  <td class=td1 id=bold valign=top nowrap>Číslo zázn.</td> 
  <td class=td1 align=left >001605176</td> 
 </tr> 
<!-- filename: full-999-body --> 

<!-- filename: full-999-body --> 
 </tr> 
</table>
</body>
</html>
]]

-- local htmlparser = require "htmlparser"
-- local tidy       = require "refmanager.tidy"
-- local http       = require "refmanager.http"
local html       = require "refmanager.html"
-- local strip_scripts  = tidy.strip_scripts
-- local strip_comments = tidy.strip_comments

-- local testf = io.open("test-tidy.html", "r")
-- local testf = io.open("test.html", "r")
-- local test = testf:read("*all")
-- local test = tidy.tidy_file("test.html")
-- test = strip_comments(test)
-- test = strip_scripts(test)
local www = html.new()
local dom = www:file("test.html"):clean():get_dom()
-- local dom = www:file("uff.html"):clean():get_dom()

-- test = test:gsub("<!%-%-.-%-%->", "")
-- test = test:gsub("<script.-</script>", "")
-- print(test)
-- testf:close()

-- local dom = htmlparser.parse(test)

local selected = dom:select("#fullbody")

if #selected > 0 then
  local fullbody = selected[1]

  for _, td in ipairs(fullbody.nodes) do
    for _,node in ipairs(td.nodes) do
      print(node.name)
      print("content: " .. node:getcontent())
      -- print("text:   " .. node:gettext())
    end
  end
end

-- local www = http.new("https://www.csfd.cz/film/8365-vyvoleny/prehled/")
-- for k,v in pairs(www) do print(k, tostring(v)) end
-- www:go()

local dom = www:url("https://www.csfd.cz/film/8365-vyvoleny/prehled/"):clean():get_dom()
local selected = dom:select("title")
print(selected[1]:getcontent())

-- print(www:get_body())
