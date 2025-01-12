-- Dnd Dice are going to be generic rolls that can be used for any kind of dice roll

dnd_dice = {}

math.randomseed(os.time())

di_type = {
    d4 = 4,
    d6 = 6,
    d8 = 8,
    d10 = 10,
    d12 = 12,
    d20 = 20
}

local last_interaction = {}

-- user options
local show_roll_messages = minetest.settings:get_bool("dnd_dice.show_roll_messages", true)
local show_last_roll = minetest.settings:get_bool("dnd_dice.show_last_roll", true)
local roll_cooldown = tonumber(minetest.settings:get("dnd_dice.roll_cooldown")) or 2


-- =================================== dice rolling
-- function to generically roll as many dice as you want of any type of dice
function dnd_dice.roll(dice_type, num_dice)
    local total = 0
    local sides = di_type[dice_type]
    if not sides then
        return nil, "Invalid dice type: " .. dice_type
    end
    for i = 1, num_dice do
        total = total + math.random(1, sides)
    end
    return total
end

local hud_ids = {}

function dnd_dice.roll_msg(name, dice, result)
    if show_roll_messages then
        minetest.chat_send_all(name .. " placed and rolled (" .. dice .. ") a " .. minetest.colorize("#ffa600", tostring(result)))
    end
end

function dnd_dice.roll_hud(player, dice, result)
    local name = player:get_player_name()
    if player then
        -- Remove previous HUD if it exists
        if hud_ids[name] then
            player:hud_remove(hud_ids[name])
        end
        -- Add new HUD
        local hud_id = player:hud_add({
            hud_elem_type = "text",
            position = {x = 0.5, y = 0.5},
            offset = {x = 0, y = 0},
            text = "Last roll: " .. minetest.colorize("#ffa600", tostring(result)),
            number = 0xFFFFFF,
            alignment = {x = 0, y = 5},
            scale = {x = 100, y = 100},
            size = {x = 0, y = 0},
            z_index = 0
        })
        hud_ids[name] = hud_id
    end
end

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    if hud_ids[name] then
        player:hud_remove(hud_ids[name])
        hud_ids[name] = nil
    end
end)


-- command to roll any number of a variable number of dice, with as many constants as you want
-- for example, /roll 2d6 or /roll 1d20 or /roll 3d4+2 or /roll 2d8+6d8
minetest.register_chatcommand("roll", {
    params = "[<name>] <dice>",
    description = "Roll any number of a variable number of dice, with optional constant parsing. Examples: /roll 2d6 or /roll 1d20 or /roll 3d4+2 or /roll 2d8+6d8",
    privs = {interact = true},
    func = function(name, param)
        local total = 0
        local result_string = ""
        local valid = true
        local first = true
        local roll_name, dice_param = param:match("^(%S+)%s+(.+)$")
        
        if not dice_param then
            dice_param = param
            roll_name = name
        end

        for num_dice, dice_type in dice_param:gmatch("(%d+)d(%d+)") do
            local dice_key = "d" .. dice_type
            local result, err = dnd_dice.roll(dice_key, tonumber(num_dice))

            if result then
                total = total + result
                if not first then
                    result_string = result_string .. "+"
                end
                result_string = result_string .. result
                first = false
            else
                valid = false
                minetest.chat_send_player(name, err)
                break
            end
        end

        -- Add constant values to the result
        for constant in dice_param:gmatch("%+(%d+)") do
            total = total + tonumber(constant)
            result_string = result_string .. "+" .. constant
        end

        if valid then
            local message = roll_name .. " rolled " .. dice_param .. ": " .. result_string .. " = " .. minetest.colorize("#ffa600", tostring(total))
            if show_roll_messages then
                minetest.chat_send_all(message)
            end
            if show_last_roll then
                dnd_dice.roll_hud(minetest.get_player_by_name(name), dice_param, total)
            end
            return true
        else
            return false, "Invalid dice roll command"
        end
    end
})



-- =================================== dice nodes
local _collision = {
    type = "fixed",
    fixed = {-0.28, -0.5, -0.28, 0.28, 0.0575, 0.28}
}

for dice, sides in pairs(di_type) do
    minetest.register_node("dnd_dice:" .. dice, {
        description = "DnD " .. dice,
        drawtype = "mesh",
        mesh = dice .. ".obj",
        tiles = {"dice_base.png^[combine:128x128:0,0=dice_" .. sides .. ".png"},
        collision_box = { type = "fixed", fixed = {0,0,0,0,0,0} },
        selection_box = _collision,
        paramtype = "light",
        paramtype2 = "facedir",
        light_source = 5,
        groups = {oddly_breakable_by_hand = 3},
        on_place = minetest.rotate_node,
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            local player_name = clicker:get_player_name()
            local current_time = minetest.get_gametime()
            
            if last_interaction[player_name] and current_time - last_interaction[player_name] < roll_cooldown then
                return  -- Prevent spamming
            end
            
            local result, err = dnd_dice.roll(dice, 1)
            if result then
                dnd_dice.roll_msg(player_name, dice, result)
                if show_last_roll then
                    dnd_dice.roll_hud(clicker, dice, result)
                end
                last_interaction[player_name] = current_time
                -- Update the node texture to show the result
                minetest.swap_node(pos, {
                    name = node.name,
                    param2 = node.param2,
                    tiles = {"dice_base.png^[combine:128x128:0,0=dice_" .. result .. ".png"}
                })
            else
                minetest.chat_send_player(player_name, err)
            end
        end
    })
end
