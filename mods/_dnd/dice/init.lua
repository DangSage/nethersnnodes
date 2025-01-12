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

local hex_colors = {
    d4 = "ff0000",
    d6 = "00ff00",
    d8 = "0000ff",
    d10 = "ff00ff",
    d12 = "00ffff",
    d20 = "ffff00"
}

local last_interaction = {}

-- user options
local show_roll_messages = minetest.settings:get_bool("dnd_dice.show_roll_messages", true)
local show_last_roll = minetest.settings:get_bool("dnd_dice.show_last_roll", true)
local roll_cooldown = tonumber(minetest.settings:get("dnd_dice.roll_cooldown")) or 2

local hud_ids = {}

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

-- store last roll as a value on the player as a modifier
function dnd_dice.store_last_roll(player, dice, result)
    local name = player:get_player_name()
    local meta = player:get_meta()
    meta:set_int("dnd_dice_last_roll", result)
end

function dnd_dice.roll_msg(name, dice, result)
    if show_roll_messages then
        minetest.chat_send_all(name .. minetest.colorize("#aaaaaa"," rolled (" .. dice .. ") a ") ..
            minetest.colorize("#ffa600", tostring(result)))
    end
end

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    hud_ids[name] = player:hud_add({
        hud_elem_type = "text",
        position = {x = 0.5, y = 0.525},
        offset = {x = 0, y = 0},
        text = "",
        alignment = {x = 0, y = 0},
        scale = {x = 100, y = 100},
        number = 0xFFFFFF
    })
end)

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local meta = player:get_meta()
        local last_roll = meta:get_int("dnd_dice_last_roll")
        if show_last_roll and last_roll > 0 and player:get_player_control().sneak then
            player:hud_change(hud_ids[name], "text", "Last roll: " .. minetest.colorize("#ffa600", tostring(last_roll)))
        else
            player:hud_change(hud_ids[name], "text", "")
        end
    end
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    if hud_ids[name] then
        player:hud_remove(hud_ids[name])
        hud_ids[name] = nil
    end
end)

minetest.register_chatcommand("roll", {
    params = "[<name>] <dice>",
    description = "Roll any number of a variable number of dice, with optional constant parsing." ..
        "Examples: /roll 2d6 or /roll 1d20 or /roll 3d4+2 or /roll 2d8+6d8+4",
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

        for dice_expr in dice_param:gmatch("[^%+]+") do
            local num_dice, dice_type = dice_expr:match("(%d+)d(%d+)")
            if num_dice and dice_type then
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
            else
                local constant = tonumber(dice_expr)
                if constant then
                    total = total + constant
                    if not first then
                        result_string = result_string .. "+"
                    end
                    result_string = result_string .. constant
                    first = false
                else
                    valid = false
                    minetest.chat_send_player(name, "Invalid dice expression: " .. dice_expr)
                    break
                end
            end
        end

        if valid then
            local message = roll_name .. minetest.colorize("#aaaaaa",
                " rolled " .. dice_param .. ": " .. result_string .. " = ") ..
                minetest.colorize("#ffa600", tostring(total))
            if show_roll_messages then
                minetest.chat_send_all(message)
            end
            local player = minetest.get_player_by_name(name)
            if player then
                dnd_dice.store_last_roll(player, dice_param, total)
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
        description = "Di (" .. dice .. ")",
        drawtype = "mesh",
        mesh = dice .. ".obj",
        use_texture_alpha = "clip",
        tiles = {
            "dice_base.png^[colorize:#" .. hex_colors[dice] ..
            ":100".."^[combine:128x128:0,0=dice_" .. sides .. ".png",
        },
        collision_box = { type = "fixed", fixed = {0,0,0,0,0,0} },
        selection_box = _collision,
        paramtype = "light",
        paramtype2 = "facedir",
        groups = {oddly_breakable_by_hand = 3},
        drop = "dnd_dice:" .. dice,
        on_place = minetest.rotate_node,
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            local player_name = clicker:get_player_name()
            local current_time = minetest.get_gametime()
            
            if last_interaction[player_name] and current_time - last_interaction[player_name][1] < roll_cooldown then
                return  -- Prevent spamming
            end
            
            local result, err = dnd_dice.roll(dice, 1)
            if result then
                -- player sounds
                minetest.sound_play("default_dig_snappy", {to_player = player_name, gain = 0.25})
                dnd_dice.roll_msg(player_name, dice, result)
                dnd_dice.store_last_roll(clicker, dice, result)
                last_interaction[player_name] = {current_time, result}
                -- Store the result in node metadata
                local meta = minetest.get_meta(pos)
                meta:set_int("dice_result", result)
                -- Update the node to trigger a visual update and rotate it a bit
                meta:set_string("infotext", "Di (" .. tostring(dice) .. ") rolled on " .. tostring(result))
                local node = minetest.get_node(pos)
                node.param2 = (node.param2 + 1) % 4  -- Rotate the node
                minetest.swap_node(pos, {
                    name = "dnd_dice:" .. dice,
                    param2 = node.param2
                })
                minetest.get_node_timer(pos):start(0.1)
            else
                minetest.chat_send_player(player_name, err)
            end
        end
    })
end
