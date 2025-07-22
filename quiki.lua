addon.author = "MisterZimbu"
addon.name = "Quiki"
addon.version = "1.0"
addon.desc = "Provides a quick command line interface to access the Horizon FFXI wiki."

require('common');

default_tokens = {
    base_url = "https://horizonffxi.wiki"
}

generic_craft_lookup = {}
generic_craft_lookup[0] = "$BASE_URL/Category:$CRAFT/Amateur"
generic_craft_lookup[11] = "$BASE_URL/Category:$CRAFT/Recruit"
generic_craft_lookup[21] = "$BASE_URL/Category:$CRAFT/Initiate"
generic_craft_lookup[31] = "$BASE_URL/Category:$CRAFT/Novice"
generic_craft_lookup[41] = "$BASE_URL/Category:$CRAFT/Apprentice"
generic_craft_lookup[51] = "$BASE_URL/Category:$CRAFT/Journeyman"
generic_craft_lookup[61] = "$BASE_URL/Category:$CRAFT/Craftsman"
generic_craft_lookup[71] = "$BASE_URL/Category:$CRAFT/Artisan"
generic_craft_lookup[81] = "$BASE_URL/Category:$CRAFT/Adept"
generic_craft_lookup[91] = "$BASE_URL/Category:$CRAFT/Veteran"

function lookup_level(array, level)
    local result = nil
    local resultLevel = 0
    for k,v in pairs(array) do
        -- I HATE LUA
        if k <= level and k >= resultLevel then
            result = v
            resultLevel = k
        end
    end
    return result
end

function table_combine(table1, table2)
    local result = {}
    for k,v in pairs(table1) do
        result[k] = v
    end
    for k,v in pairs(table2) do
        result[k] = v
    end
    return result
end

function replace_tokens(str, tokens)
    local all_tokens = table_combine(default_tokens, tokens)
    local result = str
    for k,v in pairs(all_tokens) do
        local pattern = "%$" .. string.upper(k)
        result = string.gsub(result, pattern, v)
    end
    return result
end

function print_array(arrayName, array)
    print(arrayName .. ":")
    if not array then
        print(arrayName .. "is nil")
    end

    for k,v in pairs(array) do
        print(arrayName .. "." .. k .. " = " .. v)
    end
end

function command_help()
    print("Quiki - Alt-tab is for chumps.")
    print("----------------------------------------")
    print("/wiki help - This message.")
    print("/wiki <craft> <level> - Opens the wiki page for crafts of the level specified (e.g., ''/wiki cooking 16'' opens the 11-20 cooking recipe list)")
    print("/wiki <something else> - Opens the wiki page named <something else>")
end

function command_craft(craft, levelArgs)
    local url = "$BASE_URL/Category:$CRAFT"
    --print_array("command_craft.levelArgs", levelArgs)

    local numArg = nil
    if #levelArgs > 0 then
        numArg = tonumber(levelArgs[1])
    end

    if numArg then
        -- print("Looking up level " .. numArg)
        url = lookup_level(generic_craft_lookup, numArg)
    end

    -- print("Before: " .. url)
    url = replace_tokens(url, { craft = craft })
    -- print("After: " .. url)
    return url            
end

function command_default(command, args)
    local strArgs = ""
    if #args > 0 then
        -- "/wiki Multiple Word Search" => "https://horizonxi.wiki/Multiple_Word_Search"
        strArgs = table.concat(args, "_")
        url = "$BASE_URL/$COMMAND_$ARGS"
    else
        url = "$BASE_URL/$COMMAND"
    end

    url = replace_tokens(url, {
        command = command,
        args = strArgs
    })
    return url
end

wiki_commands = {
    default = command_default,
    help = command_help,
    cooking = command_craft,
    alchemy = command_craft,
    bonecraft = command_craft,
    clothcraft = command_craft,
    fishing = command_craft,
    goldsmithing = comamnd_craft,
    leathercraft = command_craft,
    smithing = command_craft,
    woodworking = command_craft
}

ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args();

    if (#args == 0 or (not args[1]:any('/wiki') and not args[1]:any('/quiki'))) then
        return
    end

    if (#args == 1) then
        ashita.misc.open_url("https://horizonffxi.wiki/")
    else
        local command = args[2]
        local shiftedArgs = {}

        -- print_array("args", args)
        for k in pairs(args) do
            if k >= 3 then
                shiftedArgs[k-2] = args[k]
            end
        end
        -- print_array("shiftedArgs", shiftedArgs)

        local command_func = wiki_commands[command] or command_default
        local url = command_func(command, shiftedArgs)

        if url then
            ashita.misc.open_url(url)
        end
    end
end);