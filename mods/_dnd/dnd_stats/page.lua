-- Contains the sfinv page for the player's stats and all GUI interactions with it.

local allocated_color = "#00FF00" -- Green for allocated
local non_allocated_color = "#FFFFFF" -- Normal text color

-- Function to create the sfinv page for the player's stats
local function create_sfinv_page(player)
    local name = player:get_player_name()
    initialize_dnd_stats(player)
    
    local function get_label_color(stat)
        local current_value = dnd_stats.get(player, stat, false) or 0
        local buffer_value = dnd_stats.get(player, stat, true) or 0
        return buffer_value > current_value and allocated_color or non_allocated_color
    end

    local formspec = "size[8,9]" ..
                     "label[0,0;D&D Stat Sheet for " .. name .. "]" ..
                     "label[0,1;" .. minetest.colorize(get_label_color("strength"), "Strength: " .. (dnd_stats.get(player, "strength", true) or 0)) .. "]" ..
                     "button[2,1;1,0.5;strength_add;+]" ..
                     "button[3,1;1,0.5;strength_sub;-]" ..
                     "label[0,1.5;" .. minetest.colorize(get_label_color("dexterity"), "Dexterity: " .. (dnd_stats.get(player, "dexterity", true) or 0)) .. "]" ..
                     "button[2,1.5;1,0.5;dexterity_add;+]" ..
                     "button[3,1.5;1,0.5;dexterity_sub;-]" ..
                     "label[0,2;" .. minetest.colorize(get_label_color("constitution"), "Constitution: " .. (dnd_stats.get(player, "constitution", true) or 0)) .. "]" ..
                     "button[2,2;1,0.5;constitution_add;+]" ..
                     "button[3,2;1,0.5;constitution_sub;-]" ..
                     "label[4,1;" .. minetest.colorize(get_label_color("intelligence"), "Intelligence: " .. (dnd_stats.get(player, "intelligence", true) or 0)) .. "]" ..
                     "button[6,1;1,0.5;intelligence_add;+]" ..
                     "button[7,1;1,0.5;intelligence_sub;-]" ..
                     "label[4,1.5;" .. minetest.colorize(get_label_color("wisdom"), "Wisdom: " .. (dnd_stats.get(player, "wisdom", true) or 0)) .. "]" ..
                     "button[6,1.5;1,0.5;wisdom_add;+]" ..
                     "button[7,1.5;1,0.5;wisdom_sub;-]" ..
                     "label[4,2;" .. minetest.colorize(get_label_color("charisma"), "Charisma: " .. (dnd_stats.get(player, "charisma", true) or 0)) .. "]" ..
                     "button[6,2;1,0.5;charisma_add;+]" ..
                     "button[7,2;1,0.5;charisma_sub;-]" ..
                     "label[0,3;Armor Class: " .. (dnd_stats.get(player, "armor_class", true) or 0) .. "]" ..
                     "label[0,3.5;Hit Points: " .. (dnd_stats.get(player, "hit_points", true) or 0) .. "]" ..
                     "label[4,3;Speed: " .. (dnd_stats.get(player, "speed", true) or 0) .. "]" ..
                     "label[0,8;Unallocated Points: " .. (dnd_stats.get(player, "unallocated", true) or 0) .. " / " .. (dnd_stats.get(player, "unallocated", false) or 0) .. "]" ..
                     "button[4,8.5;2,0.5;reset;Reset Allocated Points]" ..
                     "button[0,8.5;2,0.5;confirm;Confirm]"
    return formspec
end


-- Register the sfinv page
sfinv.register_page("dnd_stats:stats", {
    title = "Character Sheet",
    get = function(self, player, context)
        return sfinv.make_formspec(player, context, create_sfinv_page(player), false)
    end,

    on_player_receive_fields = function(self, player, context, fields)
        local name = player:get_player_name()
        for stat, _ in pairs(default_dnd_stats) do
            if fields[stat .. "_add"] then
                dnd_stats.allocate(player, stat)
            elseif fields[stat .. "_sub"] then
                dnd_stats.deallocate(player, stat)
            end
        end
        if fields.confirm then
            dnd_stats.apply_buffered_changes(player)
        elseif fields.reset then
            dnd_stats.reset_buffer(player)
        end
        -- Update the formspec
        sfinv.set_page(player, "dnd_stats:stats")
    end
})