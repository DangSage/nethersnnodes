-- Dnd Dice are going to be generic rolls that can be used for any kind of dice roll

dnd_dice = {}

math.randomseed(os.time())

di_type = {
    D4 = 4,
    D6 = 6,
    D8 = 8,
    D10 = 10,
    D12 = 12,
    D20 = 20
}

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

-- command to roll any number of any type of dice in the form /roll 2d6 or /roll 1d20 or variable number of dice /roll 3d4+2 or /roll 2d8+6d8
-- optionally, a name can be included in the form /roll <name> 2d6
minetest.register_chatcommand("roll", {
    params = "[<name>] <dice>",
    description = "Roll any number of any type of dice in the form /roll 2d6 or /roll 1d20 or variable number of dice /roll 3d4+2 or /roll 2d8+6d8. Optionally, include a name in the form /roll <name> 2d6",
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
            local dice_key = "D" .. dice_type
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
            minetest.chat_send_all(message)
            return true
        else
            return false, "Invalid dice roll command"
        end
    end
})