-- dnd_sheet/init.lua

-- Define the DnD stats structure
local dnd_stats = {
    strength = 1,
    dexterity = 1,
    constitution = 1,
    intelligence = 1,
    wisdom = 1,
    charisma = 1
}

-- Define the initial points to spend
local initial_points = 30

-- Function to assign DnD stats to an entity
local function assign_dnd_stats(entity)
    if entity and entity.get_luaentity then
        local luaentity = entity:get_luaentity()
        if luaentity then
            luaentity.dnd_stats = table.copy(dnd_stats)
            luaentity.dnd_points = initial_points
        end
    elseif entity and entity:is_player() then
        entity.dnd_stats = table.copy(dnd_stats)
        entity.dnd_points = initial_points
    end
end

-- Function to calculate the total points spent
local function calculate_points(stats)
    local total = 0
    for _, value in pairs(stats) do
        total = total + value
    end
    return total
end

-- Function to show the DnD stats formspec
local function show_dnd_stats_formspec(player)
    local name = player:get_player_name()
    local stats = player.dnd_stats or dnd_stats
    local points = player.dnd_points or initial_points
    local formspec = "size[8,10]" ..
        "label[0,0;Your DnD Stats]" ..
        "label[0.5,1;Strength: " .. stats.strength .. "]" ..
        "button[2,1;1,1;strength_inc;+]" ..
        "button[3,1;1,1;strength_dec;-]" ..
        "label[0.5,2;Dexterity: " .. stats.dexterity .. "]" ..
        "button[2,2;1,1;dexterity_inc;+]" ..
        "button[3,2;1,1;dexterity_dec;-]" ..
        "label[0.5,3;Constitution: " .. stats.constitution .. "]" ..
        "button[2,3;1,1;constitution_inc;+]" ..
        "button[3,3;1,1;constitution_dec;-]" ..
        "label[0.5,4;Intelligence: " .. stats.intelligence .. "]" ..
        "button[2,4;1,1;intelligence_inc;+]" ..
        "button[3,4;1,1;intelligence_dec;-]" ..
        "label[0.5,5;Wisdom: " .. stats.wisdom .. "]" ..
        "button[2,5;1,1;wisdom_inc;+]" ..
        "button[3,5;1,1;wisdom_dec;-]" ..
        "label[0.5,6;Charisma: " .. stats.charisma .. "]" ..
        "button[2,6;1,1;charisma_inc;+]" ..
        "button[3,6;1,1;charisma_dec;-]" ..
        "label[0.5,7;Points remaining: " .. points .. "]" ..
        "button_exit[3,8;2,1;save;Save]"
    minetest.show_formspec(name, "dnd_stats:form", formspec)
end

-- Handle formspec submission
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "dnd_stats:form" then
        if player and player:is_player() then
            local name = player:get_player_name()
            local stats = player.dnd_stats or dnd_stats
            local points = player.dnd_points or initial_points

            if fields.strength_inc then
                if points > 0 then
                    stats.strength = stats.strength + 1
                    points = points - 1
                end
            elseif fields.strength_dec then
                if stats.strength > 1 then
                    stats.strength = stats.strength - 1
                    points = points + 1
                end
            elseif fields.dexterity_inc then
                if points > 0 then
                    stats.dexterity = stats.dexterity + 1
                    points = points - 1
                end
            elseif fields.dexterity_dec then
                if stats.dexterity > 1 then
                    stats.dexterity = stats.dexterity - 1
                    points = points + 1
                end
            elseif fields.constitution_inc then
                if points > 0 then
                    stats.constitution = stats.constitution + 1
                    points = points - 1
                end
            elseif fields.constitution_dec then
                if stats.constitution > 1 then
                    stats.constitution = stats.constitution - 1
                    points = points + 1
                end
            elseif fields.intelligence_inc then
                if points > 0 then
                    stats.intelligence = stats.intelligence + 1
                    points = points - 1
                end
            elseif fields.intelligence_dec then
                if stats.intelligence > 1 then
                    stats.intelligence = stats.intelligence - 1
                    points = points + 1
                end
            elseif fields.wisdom_inc then
                if points > 0 then
                    stats.wisdom = stats.wisdom + 1
                    points = points - 1
                end
            elseif fields.wisdom_dec then
                if stats.wisdom > 1 then
                    stats.wisdom = stats.wisdom - 1
                    points = points + 1
                end
            elseif fields.charisma_inc then
                if points > 0 then
                    stats.charisma = stats.charisma + 1
                    points = points - 1
                end
            elseif fields.charisma_dec then
                if stats.charisma > 1 then
                    stats.charisma = stats.charisma - 1
                    points = points + 1
                end
            end

            player.dnd_stats = stats
            player.dnd_points = points
            show_dnd_stats_formspec(player)
        end
    end
end)

-- Register a globalstep to assign stats to all entities including players
minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        if not player.dnd_stats then
            assign_dnd_stats(player)
        end
    end

    for _, object in ipairs(minetest.get_objects_inside_radius(vector.new(0, 0, 0), 100)) do
        if not object:is_player() and not object:get_luaentity().dnd_stats then
            assign_dnd_stats(object)
        end
    end
end)

-- Example chat command to display a player's DnD stats
minetest.register_chatcommand("dnd_stats", {
    description = "Show your DnD stats",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if player and player.dnd_stats then
            return true, "Your DnD stats: " .. minetest.serialize(player.dnd_stats)
        else
            return false, "No DnD stats found."
        end
    end
})

-- Chat command to open the DnD stats formspec
minetest.register_chatcommand("dnd_stats_form", {
    description = "Open the DnD stats formspec",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if player then
            show_dnd_stats_formspec(player)
            return true, "Opened DnD stats formspec."
        else
            return false, "Player not found."
        end
    end
})