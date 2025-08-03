local utils = {}
function utils.path_basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

function utils.string_startswith(str, start)
  return string.sub(str, 1, string.len(start)) == start
end

local function detect_host_os()
  -- package.config:sub(1,1) returns '\' for windows and '/' for *nix.
  if package.config:sub(1,1) == '\\' then
    return 'windows'
  else
    -- uname should be available on *nix systems.
    local check = io.popen('uname -s')
    local result
    if check then
      result = check:read('*l'); check:close()
    end

    if result == 'Darwin' then
      return 'macos'
    else
      return 'linux'
    end
  end
end

utils.host_os     = detect_host_os()
return utils
