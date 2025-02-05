-- commands.lua

-- Ensure DnD stats are initialized for each player on join
minetest.register_on_joinplayer(function(player)
    initialize_dnd_stats(player)
end)

-- Chat command to set a player's DnD stat
minetest.register_chatcommand("set_dnd_stat", {
    params = "<player> <stat> <value>",
    description = "Set a player's DnD stat.",
    privs = {server = true},
    func = function(name, param)
        local player_name, stat, value = param:match("^(%S+)%s+(%S+)%s+(%S+)$")
        local player = minetest.get_player_by_name(player_name)
        if player and default_dnd_stats[stat] then
            dnd_stats.set(player, stat, tonumber(value))
            return true, "Set " .. player_name .. "'s " .. stat .. " to " .. value
        else
            return false, "Invalid parameters or player not found. Usage: /set_dnd_stat <player> <stat> <value>"
        end
    end
})

-- Set stat multiple stats at once for a player
minetest.register_chatcommand("set_dnd_stats", {
    params = "<player> <stat1> <value1> <stat2> <value2> ...",
    description = "Set multiple DnD stats for a player.",
    privs = {server = true},
    func = function(name, param)
        local player_name = param:match("^(%S+)")
        local player = minetest.get_player_by_name(player_name)
        if player then
            local args = param:sub(player_name:len() + 2):split(" ")
            if #args % 2 == 0 then
                for i = 1, #args, 2 do
                    local stat, value = args[i], tonumber(args[i + 1])
                    if default_dnd_stats[stat] then
                        dnd_stats.set(player, stat, value)
                    else
                        return false, "Invalid stat: " .. stat
                    end
                end
                return true, "Set DnD stats for " .. player_name
            else
                return false, "Invalid number of arguments. Usage: /set_dnd_stats <player> <stat1> <value1> <stat2> <value2> ..."
            end
        else
            return false, "Player not found. Usage: /set_dnd_stats <player> <stat1> <value1> <stat2> <value2> ..."
        end
    end
})

-- Chat command to get a player's DnD stat
minetest.register_chatcommand("get_dnd_stat", {
    params = "<player> <stat>",
    description = "Get a player's DnD stat.",
    privs = {server = true},
    func = function(name, param)
        local player_name, stat = param:match("^(%S+)%s+(%S+)$")
        local player = minetest.get_player_by_name(player_name)
        if player and default_dnd_stats[stat] then
            local value = dnd_stats.get(player, stat)
            if value then
                return true, player_name .. "'s " .. stat .. " is " .. value
            else
                return false, "Stat " .. stat .. " not found for player " .. player_name
            end
        else
            return false, "Invalid parameters or player not found. Usage: /get_dnd_stat <player> <stat>"
        end
    end
})

-- Reset player's DnD stats to the default values
minetest.register_chatcommand("reset_sheet", {
    params = "<player>",
    description = "Reset a player's DnD stats to the default values.",
    privs = {server = true},
    func = function(name, param)
        local player_name = param:match("^(%S+)$")
        if not player_name then
            return false, "Invalid parameters. Usage: /reset_sheet <player>"
        end
        local player = minetest.get_player_by_name(player_name)
        if player then
            dnd_stats.reset(player)
            sfinv.set_page(player, "dnd_stats:stats")
            return true, "Reset DnD stats for " .. player_name
        else
            return false, "Player not found. Usage: /reset_sheet <player>"
        end
    end
})