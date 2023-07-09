-- Called on the request path.

local expected_username = "fooname"
local expected_password = "validpassword"

-- borrow from: https://devforum.roblox.com/t/base64-encoding-and-decoding-in-lua/1719860
local function decode_base64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local function parser(auth)
    local prefix = "basic "
    if string.len(auth) < string.len(prefix) or string.lower(string.sub(auth, 1, #prefix)) ~= prefix then
        return "", "", false
    end

        local str = decode_base64(string.sub(auth, #prefix +1))
    local pos = string.find(str, ":", 1, true)
    if not pos then
        return "", "", false
    end

    username = string.sub(str, 1, pos - 1)
    password = string.sub(str, pos + 1)
        return username, password, true
end

local function fail(request_handle, message)
    request_handle:respond({ [":status"] = "403" }, message)
end

function envoy_on_request(request_handle)
    local headers = request_handle:headers()
        local auth = headers:get("authorization")
    if not auth then
        fail(request_handle, "missing auth header")
    end

    local username, password, ok = parser(auth)
    if not ok then
        fail(request_handle, "invalid auth header")
        return
    end

    if username == expected_username and password == expected_password then
        return
    end

    fail(request_handle, "invalid username or password")
end

-- Called on the response path.
function envoy_on_response(response_handle)
  -- Do something.
end
