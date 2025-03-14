-- game_commands/init.lua

-- Load support for MT game translation.
local S = minetest.get_translator("game_commands")


minetest.register_chatcommand("killme", {
	description = S("Kill yourself to respawn"),
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if player then
			if minetest.settings:get_bool("enable_damage") then
				player:set_hp(0)
				return true
			else
				for _, callback in pairs(minetest.registered_on_respawnplayers) do
					if callback(player) then
						return true
					end
				end

				-- There doesn't seem to be a way to get a default spawn pos
				-- from the lua API
				return false, S("No static_spawnpoint defined")
			end
		else
			-- Show error message if used when not logged in, eg: from IRC mod
			return false, S("You need to be online to be killed!")
		end
	end
})

-- ============== SET NODE

minetest.register_privilege("setblock", {
	description = "Player can use place and setblock command.",
	give_to_singleplayer= false,
})

local function split (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

minetest.register_chatcommand("place", {
	params = "<x> <y> <x> <nodename>",
	description = "Place block",
	privs = {setblock = true},
	func = function(name, param)
        splited = split(param," ")
        if not(tonumber(splited[1]) and tonumber(splited[2]) and tonumber(splited[3])) then
            return false, "Pos error: please give int!"
        end
        x,y,z,node = tonumber(splited[1]),tonumber(splited[2]),tonumber(splited[3]),splited[4]
        if node == "ignore" then
            return false, "You can't place \"ignore\"!"
        end
        if minetest.registered_nodes[node] then
            minetest.place_node({x=x, y=y, z=z}, {name=node})
            return true, "Setted node "..node.." at "..tostring(x)..tostring(y)..tostring(z)
        else
            return false, "Cannot place a unknown node."
        end
	end,
})

minetest.register_chatcommand("place_here", {
    params = "<node>",
    privs = {setblock = true},
    description = "Place block at player's pos",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player is not online."
        end
        if param == "ignore" then
            return false, "You can't place \"ignore\"!"
        end
        if minetest.registered_nodes[param] then
            minetest.place_node(player:get_pos(), {name=param})
            return true, "Placed node "..param.." at "..tostring(math.floor(player:get_pos().x))..","..tostring(math.floor(player:get_pos().y))..","..tostring(math.floor(player:get_pos().z))
        else
            return false, "Cannot place a unknown node."
        end
	end,
})

-- minetest.set_node

minetest.register_chatcommand("setblock", {
	params = "<x> <y> <x> <nodename>",
    	privs = {setblock = true},
	description = "Set a block",
	func = function(name, param)
        splited = split(param," ")
        if not(tonumber(splited[1]) and tonumber(splited[2]) and tonumber(splited[3])) then
            return false, "Pos error: please give int!"
        end
        x,y,z,node = tonumber(splited[1]),tonumber(splited[2]),tonumber(splited[3]),splited[4]
        if node == "ignore" then
            return false, "You can't set \"ignore\"!"
        end
        if minetest.registered_nodes[node] then
            minetest.set_node({x=x, y=y, z=z}, {name=node})
            return true, "Setted node "..node.." at "..tostring(x)..tostring(y)..tostring(z)
        else
            return false, "Cannot set a unknown node."
        end
	end,
})

minetest.register_chatcommand("setblock_here", {
    params = "<node>",
    privs = {setblock = true},
    description = "Set a block at player's pos",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player is not online."
        end
        if param == "ignore" then
            return false, "You can't set \"ignore\"!"
        end
        if minetest.registered_nodes[param] then
            minetest.set_node(player:get_pos(), {name=param})
            return true, "Setted node "..param.." at "..tostring(math.floor(player:get_pos().x))..","..tostring(math.floor(player:get_pos().y))..","..tostring(math.floor(player:get_pos().z))
        else
            return false, "Cannot set a unknown node."
        end
	end,
})

-- toggle time progression "stoptime", relies on settime default privilege
minetest.register_chatcommand("stoptime", {
    description = "Toggle time progression",
    privs = {settime = true},
    func = function(name)
        if minetest.settings:get_bool("time_speed") then
            minetest.settings:set("time_speed", "0")
            return true, "Time progression stopped."
        else
            minetest.settings:set("time_speed", "72")
            return true, "Time progression started."
        end
    end,
})