-- Adds an infotext to the player HUD showing the player's stats

hud_stats = {}  -- HUD elements for the character sheet details

local function generate_hud_text(entity)
    local stats = {
        strength = "STR",
        dexterity = "DEX",
        constitution = "CON",
        intelligence = "INT",
        wisdom = "WIS",
        charisma = "CHA",
        unallocated = "Free"
    }
    local text = ""
    for stat, label in pairs(stats) do
        local value
        if entity:is_player() then
            value = tostring(dnd_stats.get(entity, stat, true) or 0)
        else
            value = tostring(entity:get_meta():get_int(stat) or 0)
        end
        text = text .. label .. ": " .. value .. "\n"
    end
    return text
end

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        -- Update the HUD text for the players self
        if hud_stats[name] then
            if player:get_player_control().sneak then
                local hud_id = hud_stats[name]
                local hud_text = generate_hud_text(player)
                player:hud_change(hud_id, "text", hud_text)
            else
                player:hud_change(hud_stats[name], "text", "")
            end
        end
    end
end)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local hud_id = player:hud_add({
        type = "text",
        position = {x = 0.9, y = 0},
        offset = {x = 0, y = 0},
        text = "",
        alignment = {x = 0, y = 2},
        scale = {x = 100, y = 100},
        number = 0xFFFFFF
    })
    hud_stats[name] = hud_id
end)
