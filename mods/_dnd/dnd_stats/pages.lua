-- All UI elements related to stats and char sheets

hud_stats = {}  -- HUD elements for the character sheet details

local colors = {
    W = "#FFFFFF", -- Normal text color
    GR = "#303030", -- Gray for gray
    BL = "#000000", -- Gray for gray
    R = "#FF0000", -- Red for strength
    G = "#00FF00", -- Green for dexterity
    B = "#0000FF", -- Blue for intelligence
    M = "#FF00FF", -- Magenta for Constitution
    Y = "#FFFF00", -- Yellow for charisma
    C = "#00FFFF" -- Cyan for wisdom
}

-- ======================================================================= SFINV Formspec Page for Stats
-- Function to create the sfinv page for the player's stats
local function create_sfinv_page(player)
    local name = player:get_player_name()
    initialize_dnd_stats(player)
    
    local function get_label_color(stat)
        local current_value = dnd_stats.get(player, stat, false) or 0
        local buffer_value = dnd_stats.get(player, stat, true) or 0
        return buffer_value > current_value and colors.G or colors.W
    end

    local function get_button_color(stat, action)
        local unallocated = dnd_stats.get(player, "unallocated", true) or 0
        local current_value = dnd_stats.get(player, stat, false) or 0
        local buffer_value = dnd_stats.get(player, stat, true) or 0
        if action == "add" then
            return unallocated > 0 and colors.G or colors.GR
        elseif action == "sub" then
            return buffer_value > current_value and colors.R or colors.GR
        end
    end

    local formspec = "size[8,9]" ..
                     "label[0,0;D&D Stat Sheet for " .. name .. "]" ..
                     "label[0,1;" .. minetest.colorize(get_label_color("strength"), "Strength: " .. (dnd_stats.get(player, "strength", true) or 0)) .. "]" ..
                     "button[2,1;1,0.5;strength_add;" .. minetest.colorize(get_button_color("strength", "add"), "+") .. "]" ..
                     "button[3,1;1,0.5;strength_sub;" .. minetest.colorize(get_button_color("strength", "sub"), "-") .. "]" ..
                     "label[0,1.5;" .. minetest.colorize(get_label_color("dexterity"), "Dexterity: " .. (dnd_stats.get(player, "dexterity", true) or 0)) .. "]" ..
                     "button[2,1.5;1,0.5;dexterity_add;" .. minetest.colorize(get_button_color("dexterity", "add"), "+") .. "]" ..
                     "button[3,1.5;1,0.5;dexterity_sub;" .. minetest.colorize(get_button_color("dexterity", "sub"), "-") .. "]" ..
                     "label[0,2;" .. minetest.colorize(get_label_color("constitution"), "Constitution: " .. (dnd_stats.get(player, "constitution", true) or 0)) .. "]" ..
                     "button[2,2;1,0.5;constitution_add;" .. minetest.colorize(get_button_color("constitution", "add"), "+") .. "]" ..
                     "button[3,2;1,0.5;constitution_sub;" .. minetest.colorize(get_button_color("constitution", "sub"), "-") .. "]" ..
                     "label[4,1;" .. minetest.colorize(get_label_color("intelligence"), "Intelligence: " .. (dnd_stats.get(player, "intelligence", true) or 0)) .. "]" ..
                     "button[6,1;1,0.5;intelligence_add;" .. minetest.colorize(get_button_color("intelligence", "add"), "+") .. "]" ..
                     "button[7,1;1,0.5;intelligence_sub;" .. minetest.colorize(get_button_color("intelligence", "sub"), "-") .. "]" ..
                     "label[4,1.5;" .. minetest.colorize(get_label_color("wisdom"), "Wisdom: " .. (dnd_stats.get(player, "wisdom", true) or 0)) .. "]" ..
                     "button[6,1.5;1,0.5;wisdom_add;" .. minetest.colorize(get_button_color("wisdom", "add"), "+") .. "]" ..
                     "button[7,1.5;1,0.5;wisdom_sub;" .. minetest.colorize(get_button_color("wisdom", "sub"), "-") .. "]" ..
                     "label[4,2;" .. minetest.colorize(get_label_color("charisma"), "Charisma: " .. (dnd_stats.get(player, "charisma", true) or 0)) .. "]" ..
                     "button[6,2;1,0.5;charisma_add;" .. minetest.colorize(get_button_color("charisma", "add"), "+") .. "]" ..
                     "button[7,2;1,0.5;charisma_sub;" .. minetest.colorize(get_button_color("charisma", "sub"), "-") .. "]" ..
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

-- ======================================================================= Sneak HUD

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local meta = player:get_meta()
        if hud_stats[name] then
            if player:get_player_control().sneak then
                local hud_id = hud_stats[name]
                    local strength = minetest.colorize(colors.R, tostring(dnd_stats.get(player, "strength", true) or 0))
                    local dexterity = minetest.colorize(colors.G, tostring(dnd_stats.get(player, "dexterity", true) or 0))
                    local constitution = minetest.colorize(colors.M, tostring(dnd_stats.get(player, "constitution", true) or 0))
                    local intelligence = minetest.colorize(colors.B, tostring(dnd_stats.get(player, "intelligence", true) or 0))
                    local wisdom = minetest.colorize(colors.C, tostring(dnd_stats.get(player, "wisdom", true) or 0))
                    local charisma = minetest.colorize(colors.Y, tostring(dnd_stats.get(player, "charisma", true) or 0))
                    local unallocated = minetest.colorize(colors.W, tostring(dnd_stats.get(player, "unallocated", true) or 0))
                    player:hud_change(hud_id, "text", "STRENGTH: " .. strength .. "\n" ..
                        "DEXTERITY: " .. dexterity .. "\n" ..
                        "CONSTITUTION: " .. constitution .. "\n" ..
                        "INTELLIGENCE: " .. intelligence .. "\n" ..
                        "WISDOM: " .. wisdom .. "\n" ..
                        "CHARISMA: " .. charisma .. "\n\n" ..
                        "UNALLOCATED: " .. unallocated)
            else
                player:hud_change(hud_stats[name], "text", "")
            end
        end
    end
end)


minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local hud_id = player:hud_add({
        hud_elem_type = "text",
        position = {x = 0.9, y = 0},
        offset = {x = 0, y = 0},
        text = "",
        alignment = {x = 0, y = 2},
        scale = {x = 100, y = 100},
        number = 0xFFFFFF
    })
    hud_stats[name] = hud_id
end)