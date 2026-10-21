-- Data only: never source or evaluate manifest contents.
local M = {}
local required = {
    schema = '^1$',
    ['language.lua'] = '^5%.1$',
    ['tool.love'] = '^%d+%.%d+$',
    ['tool.luajit'] = '^2%.1%.%d+$',
    ['tool.luarocks'] = '^%d+%.%d+%.%d+$',
    ['platform.setup'] = '^Darwin%-arm64$',
    ['prerequisite.git'] = '^2$',
    ['prerequisite.compiler'] = '^cc$',
    ['rocks.server'] = '^https://luarocks%.org$'
}
local rocks = { 'busted', 'dkjson', 'lua-term', 'lua_cliargs',
    'luafilesystem', 'luassert', 'luasystem', 'mediator_lua', 'penlight', 'say' }
for _, name in ipairs(rocks) do
    required['rock.' .. name] = '^%d+[%d%.]*%-%d+$'
end

function M.read(path)
    local file, err = io.open(path, 'r')
    if not file then error('Cannot read manifest ' .. path .. ': ' .. err, 0) end
    local contents = file:read('*a')
    file:close()
    local result, line_number = {}, 0
    for line in (contents .. '\n'):gmatch('(.-)\n') do
        line_number = line_number + 1
        line = line:gsub('\r$', '')
        if line ~= '' and not line:match('^#') then
            local key, value = line:match('^([%w_.-]+)=([^%s]+)$')
            if not key or not required[key] then
                error(path .. ':' .. line_number .. ': malformed or unknown key', 0)
            end
            if result[key] then error('Duplicate key: ' .. key, 0) end
            if not value:match(required[key]) then
                error('Unsupported or invalid value for ' .. key .. ': ' .. value, 0)
            end
            if key:match('^rock%.') and (value:find('..', 1, true) or value:find('.-', 1, true)) then
                error('Invalid package version for ' .. key, 0)
            end
            result[key] = value
        end
    end
    for key in pairs(required) do
        if not result[key] then error('Missing key: ' .. key, 0) end
    end
    return result
end

function M.compare(left, right)
    local differences = {}
    for key, value in pairs(left) do
        if value ~= right[key] then differences[#differences + 1] = key end
    end
    table.sort(differences)
    return differences
end

M.rocks = rocks
return M
