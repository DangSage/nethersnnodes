-- init.lua

-- DnD stats are a generic table that can be used to store any kind of stats for an entity.

dnd_stats = {}
local player_stats = {}

-- Default DnD stats table
default_dnd_stats = {
    unallocated = 20,
    strength = 1,
    dexterity = 1,
    constitution = 1,
    intelligence = 1,
    wisdom = 1,
    charisma = 1,
    armor_class = 1,
    hit_points = 1,
    speed = 1,
    proficiency = {}
}

-- Initialize DnD stats for an entity if not already initialized
function initialize_dnd_stats(entity)
    if entity:is_player() then
        local name = entity:get_player_name()
        if not player_stats[name] then
            local meta = entity:get_meta()
            local saved_stats = meta:get_string("dnd_stats")
            if saved_stats and saved_stats ~= "" then
                player_stats[name] = minetest.deserialize(saved_stats)
            else
                player_stats[name] = {
                    current = table.copy(default_dnd_stats),
                    buffer = table.copy(default_dnd_stats)
                }
            end
            print("Initialized DnD stats for player:", name)
        end
    else
        local properties = entity:get_properties()
        if not properties.statsheet then
            properties.statsheet = table.copy(default_dnd_stats)
            entity:set_properties(properties)
            print("Initialized DnD stats for entity:", entity:get_luaentity().name)
        end
    end
end

-- Get a stat from the entity's DnD stats table.
function dnd_stats.get(entity, stat, use_buffer)
    use_buffer = use_buffer or false
    if entity:is_player() then
        local name = entity:get_player_name()
        local stats = player_stats[name]
        if stats then
            return use_buffer and stats.buffer[stat] or stats.current[stat]
        end
    else
        local properties = entity:get_properties()
        local statsheet = properties.statsheet
        if statsheet then
            return statsheet[stat]
        end
    end
    return nil
end

-- Set a stat in the entity's DnD stats table.
function dnd_stats.set(entity, stat, value, use_buffer)
    use_buffer = use_buffer or false
    if entity:is_player() then
        local name = entity:get_player_name()
        local stats = player_stats[name]
        if stats then
            if use_buffer then
                stats.buffer[stat] = value
            else
                stats.current[stat] = value
            end
            -- Save to metadata
            entity:get_meta():set_string("dnd_stats", minetest.serialize(stats))
        end
    else
        local properties = entity:get_properties()
        local statsheet = properties.statsheet
        if statsheet then
            statsheet[stat] = value
            entity:set_properties(properties)
        end
    end
end

-- Allocate a value to a stat in the player's DnD stats table. (allocate 1 point to a stat)
function dnd_stats.allocate(player, stat)
    local name = player:get_player_name()
    local stats = player_stats[name]
    if stats and stats.buffer.unallocated > 0 then
        stats.buffer[stat] = stats.buffer[stat] + 1
        stats.buffer.unallocated = stats.buffer.unallocated - 1
        -- Save to metadata
        player:get_meta():set_string("dnd_stats", minetest.serialize(stats))
    end
end

-- Deallocate a value from a stat in the player's DnD stats table. (deallocate 1 point from a stat)
function dnd_stats.deallocate(player, stat)
    local name = player:get_player_name()
    local stats = player_stats[name]
    if stats and stats.buffer[stat] > stats.current[stat] then
        stats.buffer[stat] = stats.buffer[stat] - 1
        stats.buffer.unallocated = stats.buffer.unallocated + 1
        -- Save to metadata
        player:get_meta():set_string("dnd_stats", minetest.serialize(stats))
    end
end

-- Apply buffered changes to the actual stats
function dnd_stats.apply_buffered_changes(player)
    local name = player:get_player_name()
    local stats = player_stats[name]
    if stats then
        stats.current = table.copy(stats.buffer)
        -- Save to metadata
        player:get_meta():set_string("dnd_stats", minetest.serialize(stats))
    end
end

-- Reset buffered changes to the actual stats (for resetting allocation)
function dnd_stats.reset_buffer(player)
    local name = player:get_player_name()
    local stats = player_stats[name]
    if stats then
        stats.buffer = table.copy(stats.current)
        -- Save to metadata
        player:get_meta():set_string("dnd_stats", minetest.serialize(stats))
    end
end

function dnd_stats.reset(entity)
    if entity:is_player() then
        local name = entity:get_player_name()
        player_stats[name] = nil
        entity:get_meta():set_string("dnd_stats", "")
    else
        local properties = entity:get_properties()
        properties.statsheet = nil
        entity:set_properties(properties)
    end
end

minetest.register_on_joinplayer(function(player)
    initialize_dnd_stats(player)
end)

-- Require the commands and page handling files
dofile(minetest.get_modpath("dnd_stats") .. "/commands.lua")
dofile(minetest.get_modpath("dnd_stats") .. "/pages.lua")