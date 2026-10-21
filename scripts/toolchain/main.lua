local root = assert(arg[1])
local manifest = dofile(root .. '/scripts/toolchain/manifest.lua')
local function quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end
local function run(arguments)
    local quoted = {}
    for _, value in ipairs(arguments) do quoted[#quoted + 1] = quote(value) end
    local pipe = assert(io.popen(table.concat(quoted, ' ') ..
        ' 2>&1; result=$?; printf "\\n__CCL_STATUS__%s\\n" "$result"'))
    local output = pipe:read('*a')
    pipe:close()
    local body, status = output:match('^(.*)\n__CCL_STATUS__(%d+)\n$')
    return tonumber(status) == 0, body or output
end
local function require_command(arguments)
    local ok, output = run(arguments)
    if not ok then error(output, 0) end
    return output
end
local function external_checks(values)
    local failed = false
    local function check(label, arguments, pattern, expected)
        local ok, output = run(arguments)
        local actual = output:match(pattern)
        if ok and actual == expected then
            print('OK   ' .. label .. ': ' .. actual)
        else
            io.stderr:write('FAIL ' .. label .. ': expected ' .. expected .. '; got ' .. output .. '\n')
            failed = true
        end
    end
    local system, architecture = values['platform.setup']:match('^(.-)%-(.+)$')
    check('platform', {'uname', '-s'}, '^(%S+)', system)
    check('architecture', {'uname', '-m'}, '^(%S+)', architecture)
    check('Lua language', {'luajit', '-e', 'print(_VERSION)'}, '^Lua (%S+)', values['language.lua'])
    check('LuaJIT', {'luajit', '-e', 'print(jit.version)'}, '^LuaJIT (%S+)', values['tool.luajit'])
    check('LOVE', {os.getenv('LOVE_BIN') or 'love', '--version'}, '^LOVE (%S+)', values['tool.love'])
    check('LuaRocks', {'luarocks', '--version'}, 'luarocks (%S+)', values['tool.luarocks'])
    check('Git', {'git', '--version'}, '^git version (%d+)%.', values['prerequisite.git'])
    local compiler_ok, compiler_output = run({values['prerequisite.compiler'], '--version'})
    if not compiler_ok then
        failed = true
        io.stderr:write('FAIL C compiler: ' .. compiler_output .. '\n')
    end
    if failed then error('External prerequisites failed. See docs/toolchain.md; nothing installed.', 0) end
end
local function rock_arguments(values)
    return {'luarocks', '--lua-version=' .. values['language.lua'], '--tree=' .. root .. '/.luarocks'}
end
local function installed_rocks(values)
    local arguments = rock_arguments(values)
    arguments[#arguments + 1] = 'list'
    arguments[#arguments + 1] = '--porcelain'
    local output = require_command(arguments)
    local installed = {}
    for line in output:gmatch('[^\n]+') do
        local name, version, status = line:match('^(%S+)%s+(%S+)%s+(%S+)')
        if not name or status ~= 'installed' then error('Unexpected rock inventory: ' .. line, 0) end
        if installed[name] or values['rock.' .. name] ~= version then
            error('Unexpected installed rock/version: ' .. name .. ' ' .. version ..
                '. Preserve this tree and restore a clean approved tree; see docs/toolchain.md.', 0)
        end
        installed[name] = version
    end
    return installed
end
local function check_rocks(values)
    local installed = installed_rocks(values)
    for _, name in ipairs(manifest.rocks) do
        if installed[name] ~= values['rock.' .. name] then
            error('Missing local rock: ' .. name .. '. Run sh scripts/toolchain.sh setup.', 0)
        end
    end
    local output = require_command({root .. '/.luarocks/bin/busted', '--version'})
    local expected = values['rock.busted']:match('^(.*)%-%d+$')
    if output:match('^(%S+)') ~= expected then error('Local Busted CLI version mismatch', 0) end
    print('OK   local rock inventory and Busted CLI')
end
local function setup(values)
    external_checks(values)
    local installed = installed_rocks(values)
    local missing = false
    for _, name in ipairs(manifest.rocks) do
        if not installed[name] then missing = true end
    end
    if not missing then check_rocks(values); return end
    local prefix = os.getenv('LUAJIT_PREFIX')
    if not prefix or prefix == '' then
        error('Set LUAJIT_PREFIX to the approved LuaJIT prefix with bin, include and lib; see docs/toolchain.md.', 0)
    end
    local version = require_command({prefix .. '/bin/luajit', '-e', 'print(jit.version)'})
    if version:match('^LuaJIT (%S+)') ~= values['tool.luajit'] then
        error('LUAJIT_PREFIX does not contain the approved LuaJIT build', 0)
    end
    for _, name in ipairs(manifest.rocks) do
        if not installed[name] then
            local arguments = rock_arguments(values)
            arguments[#arguments + 1] = '--lua-dir=' .. prefix
            arguments[#arguments + 1] = '--only-server=' .. values['rocks.server']
            arguments[#arguments + 1] = 'install'
            arguments[#arguments + 1] = name
            arguments[#arguments + 1] = values['rock.' .. name]
            arguments[#arguments + 1] = '--deps-mode=none'
            print('Installing recorded rock: ' .. name .. ' ' .. values['rock.' .. name])
            local ok, output = run(arguments)
            if not ok then
                error(output .. '\nSetup stopped; earlier local installs may remain. Fix the error and rerun setup. Manifest unchanged.', 0)
            end
        end
    end
    check_rocks(values)
end
local function main()
    local command = arg[2]
    if command == 'validate' and not arg[4] then
        manifest.read(arg[3] or root .. '/toolchain.manifest')
        print('OK   manifest')
    elseif command == 'compare' and arg[3] and arg[4] and not arg[5] then
        local differences = manifest.compare(manifest.read(arg[3]), manifest.read(arg[4]))
        if #differences > 0 then error('Manifest mismatch: ' .. table.concat(differences, ', '), 0) end
        print('OK   identical approved manifests')
    elseif command == 'upgrade' then
        error('Upgrade execution is not implemented. See docs/toolchain.md and CCL-Lab#3. Approved state unchanged.', 0)
    elseif (command == 'setup' or command == 'check') and not arg[3] then
        local values = manifest.read(root .. '/toolchain.manifest')
        if command == 'setup' then setup(values)
        else external_checks(values); check_rocks(values) end
    else
        error('Usage: sh scripts/toolchain.sh validate [manifest] | compare <Lab manifest> <Template manifest> | check | setup | upgrade', 0)
    end
end
local ok, err = pcall(main)
if not ok then io.stderr:write('FAIL ' .. tostring(err) .. '\n'); os.exit(1) end
