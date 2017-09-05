-- support for HTML tidy
-- command line app is used instead of the library, because I cannot get it to work
--
-- convert options string to table
local function get_options(options)
  local t = {}
  if type(options) == "string" then
    for match in options:gmatch("([^%s]+)") do
      t[#t+1] = match -- we want to keep the ordering 
    end
  end
  -- we also want to enable fast lookup of the options
  for _, key in ipairs(t) do 
    t[key] = true
  end
  return t
end

local function build_options(options)
  return table.concat(options, " ")
end

local function tidy(s, options)
  -- we cannot get read/write pipe in Lua, so we need to save the parsed string to temporary file
  local tmpname = os.tmpname()
  local f = io.open(tmpname, "w")
  f:write(s)
  f:close()
  local result = tidy_file(tmpname)
  os.remove(tmpname)
  return result
end

-- return tmpfilename and the redirection string
local function make_stderr()
  local stderr = os.tmpname()
  local redirection = string.format("2> %s", newfile)
  return stderr, redirection
end


-- options will be passed to tidy command. they can be passed as string or table
local function tidy_file(filename,options)
  local options = options or ""
  options = get_options(options)
  if not options["-q"] and not options["--quiet"] then
    table.insert(options, "-q")
  end
  local option_string = build_options(options)
  local stderr, redirection = make_stderr()
  local command = string.format("tidy %s %s %s",option_string, filename, redirection)
  local tidy = io.popen(command, "r")
  local result = tidy:read("*all")
  tidy:close()
  -- remove the temporary file with stderr
  os.remove(stderr)
  return result
end

local M = {
  tidy = tidy,
  tidy_file = tidy_file
}

if _TEST then
  M._get_options = get_options
  M._build_options = build_options
end

return M
