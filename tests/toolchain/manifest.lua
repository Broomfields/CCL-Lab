-- Standalone contract tests: no Busted installation required.
local root = assert(arg[1])
local parser = dofile(root .. '/scripts/toolchain/manifest.lua')
local file = assert(io.open(root .. '/toolchain.manifest'))
local baseline = file:read('*a')
file:close()
local temporary = os.tmpname()
local count = 0
local function read(text)
    local out = assert(io.open(temporary, 'w'))
    out:write(text)
    out:close()
    return parser.read(temporary)
end
local function rejects(text, expected)
    local ok, err = pcall(read, text)
    assert(not ok and tostring(err):find(expected, 1, true), tostring(err))
    count = count + 1
end
local ok, err = pcall(function()
    local approved = read(baseline)
    local crlf = read(baseline:gsub('\n', '\r\n'))
    for key, value in pairs(approved) do assert(crlf[key] == value) end
    count = count + 1
    rejects(baseline .. 'schema=1\n', 'Duplicate key')
    rejects(baseline .. 'unknown=value\n', 'unknown key')
    rejects(baseline .. 'os.execute("false")\n', 'malformed')
    rejects(baseline:gsub('schema=1', 'schema=2'), 'Unsupported')
    rejects(baseline:gsub('language.lua=5.1\n', ''), 'Missing key')
    rejects(baseline:gsub('language.lua=5.1', 'language.lua=5.4'), 'Unsupported')
    rejects(baseline:gsub('platform.setup=Darwin%-arm64', 'platform.setup=Linux-x86_64'), 'Unsupported')
    rejects(baseline:gsub('tool.love=[^\n]+', 'tool.love=latest'), 'invalid value')
    rejects(baseline:gsub('rock.busted=[^\n]+', 'rock.busted=2..3-1'), 'Invalid package version')
    rejects(baseline:gsub('tool.love=[^\n]+', 'tool.love=11.5;touch'), 'invalid value')
end)
os.remove(temporary)
assert(ok, err)
print('PASS ' .. count .. ' manifest contract cases')
