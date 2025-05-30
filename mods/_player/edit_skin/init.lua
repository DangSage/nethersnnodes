-- Edit Skin Mod

local S = minetest.get_translator("edit_skin")
local color_to_string = minetest.colorspec_to_colorstring

edit_skin = {
	item_names = {"base", "footwear", "eye", "mouth", "bottom", "top", "hair", "headwear"},
	tab_names = {"template", "base", "headwear", "hair", "eye", "mouth", "top", "bottom", "footwear"},
	tab_descriptions = {
		template = S("Presets"),
		base = S("Base"),
		footwear = S("Shoes"),
		eye = S("Eyes"),
		mouth = S("Mouth"),
		bottom = S("Bottom"),
		top = S("Top"),
		hair = S("Hair"),
		headwear = S("Headwear")
	},
	steve = {}, -- Stores skin values for Steve skin
	alex = {}, -- Stores skin values for Alex skin
	base = {}, -- List of base textures

	-- Base color (ARGB) is separate to keep the number of junk nodes registered in check
	base_color = {
		0xfff5c584,
		0xffe3ad6c,
		0xffd8a06b,
		0xffc99669,
		0xffb17050,
		0xff9a6a40,
		0xff9a581e,
		0xff8d471d,
		0xff613915,
		-- weird colors below

		0xffc21c1c,
		0xffae2ad3,
		0xff178c32,
		0xff449acc,
		0xffd0672a,
		0xffe3dd26,
		0xff666666,
		0xffeeeeee,
		0xff151515,
	},
	color = {
		0xff613915, -- 1 Dark brown Steve hair, Alex bottom
		0xff97491b, -- 2 Medium brown
		0xffb17050, -- 3 Light brown
		0xffe2bc7b, -- 4 Beige
		0xff706662, -- 5 Gray
		0xff151515, -- 6 Black
		0xffc21c1c, -- 7 Red
		0xff178c32, -- 8 Green Alex top
		0xffae2ad3, -- 9 Plum
		0xffebe8e4, -- 10 White
		0xffe3dd26, -- 11 Yellow
		0xff449acc, -- 12 Light blue Steve top
		0xff124d87, -- 13 Dark blue Steve bottom
		0xfffc0eb3, -- 14 Pink
		0xffd0672a, -- 15 Orange Alex hair
	},
	footwear = {},
	mouth = {},
	eye = {},
	bottom = {},
	top = {},
	hair = {},
	headwear = {},
	masks = {},
	preview_rotations = {},
	ranks = {},
	player_skins = {},
	player_formspecs = {},
	restricted_to_player = {},
	restricted_to_admin = {},
}

minetest.register_privilege("edit_skin_admin", {
	description = S("Allows access to restricted skin items."),
	give_to_singleplayer = true,
	give_to_admin = true,
})

function edit_skin.register_item(item)
	assert(edit_skin[item.type], "Skin item type " .. item.type .. " does not exist.")
	local texture = item.texture or "blank.png"
	if item.steve then
		edit_skin.steve[item.type] = texture
	end
	
	if item.alex then
		edit_skin.alex[item.type] = texture
	end
	
	if item.restricted_to_admin then
		edit_skin.restricted_to_admin[texture] = true
	end
	
	if item.for_player then
		edit_skin.restricted_to_player[texture] = {}
		if type(item.for_player) == "string" then
			edit_skin.restricted_to_player[texture][item.for_player] = true
		else
			for i, name in pairs(item.for_player) do
				edit_skin.restricted_to_player[texture][name] = true
			end
		end
	end
	
	table.insert(edit_skin[item.type], texture)
	edit_skin.masks[texture] = item.mask
	edit_skin.preview_rotations[texture] = item.preview_rotation
	edit_skin.ranks[texture] = item.rank
end

function edit_skin.save(player)
	if not player:is_player() then return end
	local skin = edit_skin.player_skins[player]
	if not skin then return end
	player:get_meta():set_string("edit_skin:skin", minetest.serialize(skin))
end

minetest.register_chatcommand("skin", {
	description = S("Open skin configuration screen."),
	privs = {},
	func = function(name, param) edit_skin.show_formspec(minetest.get_player_by_name(name)) end
})

function edit_skin.compile_skin(skin)
	if not skin then return "blank.png" end

	local ranks = {}
	local layers = {}
	for i, item in ipairs(edit_skin.item_names) do
		local texture = skin[item]
		local layer = ""
		local rank = edit_skin.ranks[texture] or i * 10
		if texture and texture ~= "blank.png" then
			if skin[item .. "_color"] and edit_skin.masks[texture] then
				local color = color_to_string(skin[item .. "_color"])
				layer = "(" .. edit_skin.masks[texture] .. "^[colorize:" .. color .. ":alpha)"
			end
			if #layer > 0 then layer = layer .. "^" end
			layer = layer .. texture
			layers[rank] = layer
			table.insert(ranks, rank)
		end
	end
	table.sort(ranks)
	local output = ""
	for i, rank in ipairs(ranks) do
		if #output > 0 then output = output .. "^" end
		output = output .. layers[rank]
	end
	return output
end

function edit_skin.update_player_skin(player)
	local output = edit_skin.compile_skin(edit_skin.player_skins[player])

	player_api.set_texture(player, 1, output)
	
	-- Set player first person hand node
	local base = edit_skin.player_skins[player].base
	local base_color = edit_skin.player_skins[player].base_color
	local node_id = base:gsub(".png$", "") .. color_to_string(base_color):gsub("#", "")
	player:get_inventory():set_stack("hand", 1, "edit_skin:" .. node_id)
	
	for i = 1, #edit_skin.registered_on_set_skins do
		edit_skin.registered_on_set_skins[i](player)
	end
	
	local name = player:get_player_name()
	if minetest.global_exists("armor") and
		armor.textures and armor.textures[name]
	then
		armor.textures[name].skin = output
		armor.update_player_visuals(armor, player)
	end
	
	if minetest.global_exists("i3") then i3.set_fs(player) end
end

minetest.register_on_joinplayer(function(player)
	local function table_get_random(t)
		return t[math.random(#t)]
	end
	local skin = player:get_meta():get_string("edit_skin:skin")
	if skin then
		skin = minetest.deserialize(skin)
	end
	if skin then
		edit_skin.player_skins[player] = skin
	else
		if math.random() > 0.5 then
			skin = table.copy(edit_skin.steve)
		else
			skin = table.copy(edit_skin.alex)
		end
		edit_skin.player_skins[player] = skin
		edit_skin.save(player)
	end
	
	edit_skin.player_formspecs[player] = {
		active_tab = "template",
		page_num = 1,
		has_admin_priv = minetest.check_player_privs(player, "edit_skin_admin"),
	}
	
	player:get_inventory():set_size("hand", 1)
	
	edit_skin.update_player_skin(player)

	if minetest.global_exists("inventory_plus") and inventory_plus.register_button then
		inventory_plus.register_button(player, "edit_skin", S("Edit Skin"))
	end
	
	 -- Needed for 3D Armor + sfinv
	if minetest.global_exists("armor") then
		minetest.after(0.01, function()
			if player:is_player() then
				edit_skin.update_player_skin(player)
			end
		end)
	end
end)

minetest.register_on_leaveplayer(function(player)
	player:get_inventory():set_size("hand", 0)
	edit_skin.player_skins[player] = nil
	edit_skin.player_formspecs[player] = nil
end)

minetest.register_on_shutdown(function()
	for _, player in pairs(minetest.get_connected_players()) do
		player:get_inventory():set_size("hand", 0)
	end
end)

edit_skin.registered_on_set_skins = {}

function edit_skin.register_on_set_skin(func)
	table.insert(edit_skin.registered_on_set_skins, func)
end

function edit_skin.show_formspec(player)
	local formspec_data = edit_skin.player_formspecs[player]
	local has_admin_priv = minetest.check_player_privs(player, "edit_skin_admin")
	if has_admin_priv ~= formspec_data.has_admin_priv then
		formspec_data.has_admin_priv = has_admin_priv
		for i, name in pairs(edit_skin.item_names) do
			formspec_data[name] = nil
		end
	end
	local active_tab = formspec_data.active_tab
	local page_num = formspec_data.page_num
	local skin = edit_skin.player_skins[player]
	local formspec = "formspec_version[3]size[14.2,11]"
	for i, tab in pairs(edit_skin.tab_names) do
		if tab == active_tab then
			formspec = formspec ..
				"style[" .. tab .. ";bgcolor=green]"
		end
		
		local y = 0.3 + (i - 1) * 0.8
		formspec = formspec ..
			"style[" .. tab .. ";content_offset=16,0]" ..
			"button[0.3," .. y .. ";2,0.8;" .. tab .. ";" .. edit_skin.tab_descriptions[tab] .. "]" ..
			"image[0.4," .. y + 0.1 .. ";0.6,0.6;edit_skin_icons.png^[verticalframe:9:" .. i - 1 .. "]"
	end
	
	local mesh = player:get_properties().mesh or ""
	local textures = player_api.get_textures(player)
	textures[2] = "blank.png" -- Clear out the armor

	formspec = formspec ..
		"image[9.25,0.5;4.5,7;edit_skin_bg.png]" ..
		"model[10,1.2;3,6;player_mesh;" .. mesh .. ";" ..
		table.concat(textures, ",") ..
		";0,180;false;true;0,0]"
	
	if active_tab == "template" then
		formspec = formspec ..
			"model[3,2;2,4;player_mesh;" .. mesh .. ";" ..
			edit_skin.compile_skin(edit_skin.steve) ..
			",blank.png,blank.png;0,180;false;true;0,0]" ..

			"button[3,6.2;2,0.8;steve;" .. S("Select") .. "]" ..

			"model[5.5,2;2,4;player_mesh;" .. mesh .. ";" ..
			edit_skin.compile_skin(edit_skin.alex) ..
			",blank.png,blank.png;0,180;false;true;0,0]" ..
			
			"button[5.5,6.2;2,0.8;alex;" .. S("Select") .. "]"
			
	else
		formspec = formspec ..
			"style_type[button,image_button;border=false;bgcolor=#00000000]"
		
		if not formspec_data[active_tab] then edit_skin.filter_active_tab(player) end
		local textures = formspec_data[active_tab]
		local page_start = (page_num - 1) * 16 + 1
		local page_end = math.min(page_start + 16 - 1, #textures)
		
		for j = page_start, page_end do
			local i = j - page_start + 1
			local texture = textures[j]
			local preview = edit_skin.masks[skin.base] .. "^[colorize:gray^" .. skin.base
			local color = color_to_string(skin[active_tab .. "_color"])
			local mask = edit_skin.masks[texture]
			if color and mask then
				preview = preview .. "^(" .. mask .. "^[colorize:" .. color .. ":alpha)"
			end
			preview = preview .. "^" .. texture
			
			local mesh = "edit_skin_head.obj"
			if active_tab == "top" then
				mesh = "edit_skin_top.obj"
			elseif active_tab == "bottom" or active_tab == "footwear" then
				mesh = "edit_skin_bottom.obj"
			end
			
			local rot_x = -10
			local rot_y = 25
			if edit_skin.preview_rotations[texture] then
				rot_x = edit_skin.preview_rotations[texture].x
				rot_y = edit_skin.preview_rotations[texture].y
			end
			
			i = i - 1
			local x = 2.5 + i % 4 * 1.6
			local y = 0.3 + math.floor(i / 4) * 1.6
			formspec = formspec ..
				"model[" .. x .. "," .. y ..
				";1.5,1.5;" .. mesh .. ";" .. mesh .. ";" ..
				preview ..
				";" .. rot_x .. "," .. rot_y .. ";false;false;0,0]"
			
			if skin[active_tab] == texture then
				formspec = formspec ..
					"style[" .. texture ..
					";bgcolor=;bgimg=edit_skin_select_overlay.png;" ..
					"bgimg_pressed=edit_skin_select_overlay.png;bgimg_middle=14,14]"
			end
			
			formspec = formspec .. "button[" .. x .. "," .. y .. ";1.5,1.5;" .. texture .. ";]"
		end
	end
	
	if skin[active_tab .. "_color"] then
		local colors = edit_skin.color
		if active_tab == "base" then colors = edit_skin.base_color end
		
		local tab_color = active_tab .. "_color"
		local selected_color = skin[tab_color]
		for i, colorspec in pairs(colors) do
			local color = color_to_string(colorspec)
			i = i - 1
			local x = 2.5 + i % 6 * 0.9
			local y = 8 + math.floor(i / 6) * 0.9
			formspec = formspec ..
				"image_button[" .. x .. "," .. y ..
				";0.8,0.8;blank.png^[noalpha^[colorize:" ..
				color .. ":alpha;" .. colorspec .. ";]"
			
			if selected_color == colorspec then
				formspec = formspec ..
					"style[" .. color ..
					";bgcolor=;bgimg=edit_skin_select_overlay.png;bgimg_middle=14,14]" ..
					"button[" .. x .. "," .. y .. ";0.8,0.8;" .. color .. ";]"
			end
		end

		if not (active_tab == "base") then
		-- Bitwise Operations !?!?!
		local red = math.floor(selected_color / 0x10000) - 0xff00
		local green = math.floor(selected_color / 0x100) - 0xff0000 - red * 0x100
		local blue = selected_color - 0xff000000 - red * 0x10000 - green * 0x100
		formspec = formspec ..
			"container[9,8]" ..
			"scrollbaroptions[min=0;max=255;smallstep=1]" ..
			
			"box[0.25,0;4.49,0.38;red]" ..
			"scrollbar[0.25,0;4.5,0.4;horizontal;red;" .. red .."]" ..
			"label[2,0.6;".. "Red: " .. red .."]" ..

			"box[0.25,1;4.49,0.38;green]" ..
			"scrollbar[0.25,1;4.5,0.4;horizontal;green;" .. green .."]" ..
			"label[2,1.6;".. "Green: " .. green .."]" ..
			
			"box[0.25,2;4.49,0.38;blue]" ..
			"scrollbar[0.25,2;4.5,0.4;horizontal;blue;" .. blue .."]" ..
			"label[2,2.6;".. "Blue: " .. blue .."]" ..
			
			"container_end[]"
		end
	end
	
	local page_count = 1
	if edit_skin[active_tab] then
		page_count = math.ceil(#formspec_data[active_tab] / 16)
	end
	
	if page_num > 1 then
		formspec = formspec ..
			"image_button[2.5,6.7;1,1;edit_skin_arrow.png^[transformFX;previous_page;]"
	end
	
	if page_num < page_count then
		formspec = formspec ..
			"image_button[7.8,6.7;1,1;edit_skin_arrow.png;next_page;]"
	end
	
	if page_count > 1 then
		formspec = formspec ..
			"label[5.3,7.2;" .. page_num .. " / " .. page_count .. "]"
	end

	minetest.show_formspec(player:get_player_name(), "edit_skin:edit_skin", formspec)
end

function edit_skin.filter_active_tab(player)
	local formspec_data = edit_skin.player_formspecs[player]
	local active_tab = formspec_data.active_tab
	local admin_priv = formspec_data.has_admin_priv
	local name = player:get_player_name()
	formspec_data[active_tab] = {}
	local textures = formspec_data[active_tab]
	for i, texture in pairs(edit_skin[active_tab]) do
		if admin_priv or not edit_skin.restricted_to_admin[texture] then
			local restriction = edit_skin.restricted_to_player[texture]
			if restriction then
				if restriction[name] then
					table.insert(textures, texture)
				end
			else
				table.insert(textures, texture)
			end
		end
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "edit_skin:edit_skin" then return false end
	
	local formspec_data = edit_skin.player_formspecs[player]
	local active_tab = formspec_data.active_tab
	
	-- Cancel formspec resend after scrollbar move
	if formspec_data.form_send_job then
		formspec_data.form_send_job:cancel()
	end
	
	if fields.quit then
		edit_skin.save(player)
		return true
	end

	if fields.alex then
		edit_skin.player_skins[player] = table.copy(edit_skin.alex)
		edit_skin.update_player_skin(player)
		edit_skin.show_formspec(player)
		return true
	elseif fields.steve then
		edit_skin.player_skins[player] = table.copy(edit_skin.steve)
		edit_skin.update_player_skin(player)
		edit_skin.show_formspec(player)
		return true
	end
	
	for i, tab in pairs(edit_skin.tab_names) do
		if fields[tab] then
			formspec_data.active_tab = tab
			formspec_data.page_num = 1
			edit_skin.show_formspec(player)
			return true
		end
	end
	
	local skin = edit_skin.player_skins[player]
	if not skin then return true end
	
	if fields.next_page then
		local page_num = formspec_data.page_num
		page_num = page_num + 1
		local page_count = math.ceil(#formspec_data[active_tab] / 16)
		if page_num > page_count then
			page_num = page_count
		end
		formspec_data.page_num = page_num
		edit_skin.show_formspec(player)
		return true
	elseif fields.previous_page then
		local page_num = formspec_data.page_num
		page_num = page_num - 1
		if page_num < 1 then page_num = 1 end
		formspec_data.page_num = page_num
		edit_skin.show_formspec(player)
		return true
	end
	
	if
		skin[active_tab .. "_color"] and (
			fields.red and fields.red:find("^CHG") or
			fields.green and fields.green:find("^CHG") or
			fields.blue and fields.blue:find("^CHG")
		)
	then
		local red = fields.red:gsub("%a%a%a:", "")
		local green = fields.green:gsub("%a%a%a:", "")
		local blue = fields.blue:gsub("%a%a%a:", "")
		red = tonumber(red) or 0
		green = tonumber(green) or 0
		blue = tonumber(blue) or 0
		
		local color = 0xff000000 + red * 0x10000 + green * 0x100 + blue
		if color >= 0 and color <= 0xffffffff then
			-- Delay updating the formspec to avoid breaking scrollbar dragging
			formspec_data.form_send_job = minetest.after(0.1, function()
				if player and player:is_player() then
					skin[active_tab .. "_color"] = color
					edit_skin.update_player_skin(player)
					edit_skin.show_formspec(player)
					formspec_data.form_send_job = nil
				end
			end)
			return true
		end
	end
	
	local field
	for f, value in pairs(fields) do
		if value == "" then
			field = f
			break
		end
	end
	
	-- See if field is a texture
	if field and edit_skin[active_tab] then
		for i, texture in pairs(formspec_data[active_tab]) do
			if texture == field then
				skin[active_tab] = texture
				edit_skin.update_player_skin(player)
				edit_skin.show_formspec(player)
				return true
			end
		end
	end
		
	-- See if field is a color
	local number = tonumber(field)
	if number and skin[active_tab .. "_color"] then
		local color = math.floor(number)
		if color and color >= 0 and color <= 0xffffffff then
			skin[active_tab .. "_color"] = color
			edit_skin.update_player_skin(player)
			edit_skin.show_formspec(player)
			return true
		end
	end

	return true
end)

local function init()
	local f = io.open(minetest.get_modpath("edit_skin") .. "/list.json")
	assert(f, "Can't open the file list.json")
	local data = f:read("*all")
	assert(data, "Can't read data from list.json")
	local json, error = minetest.parse_json(data)
	assert(json, error)
	f:close()
	
	for _, item in pairs(json) do
		edit_skin.register_item(item)
	end
	edit_skin.steve.base_color = edit_skin.base_color[1]
	edit_skin.steve.hair_color = edit_skin.color[1]
	edit_skin.steve.top_color = edit_skin.color[12]
	edit_skin.steve.bottom_color = edit_skin.color[13]
	edit_skin.steve.hair = edit_skin.hair[2]
	edit_skin.steve.eye = edit_skin.eye[1]
	edit_skin.steve.mouth = edit_skin.mouth[1]
	edit_skin.steve.top = edit_skin.top[1]
	edit_skin.steve.bottom = edit_skin.bottom[1]

	edit_skin.alex.base_color = edit_skin.base_color[1]
	edit_skin.alex.hair_color = edit_skin.color[15]
	edit_skin.alex.top_color = edit_skin.color[8]
	edit_skin.alex.bottom_color = edit_skin.color[1]
	edit_skin.alex.hair = edit_skin.hair[1]
	edit_skin.alex.eye = edit_skin.eye[1]
	edit_skin.alex.mouth = edit_skin.mouth[1]
	edit_skin.alex.top = edit_skin.top[1]
	edit_skin.alex.bottom = edit_skin.bottom[1]
	
	-- Register junk first person hand nodes
	local function make_texture(base, colorspec)
		local output = ""
		if edit_skin.masks[base] then
			output = edit_skin.masks[base] ..
				"^[colorize:" .. color_to_string(colorspec) .. ":alpha"
		end
		if #output > 0 then output = output .. "^" end
		output = output .. base
		return output
	end

	for _, base in pairs(edit_skin.base) do
		for _, base_color in pairs(edit_skin.base_color) do
			local id = base:gsub(".png$", "") .. color_to_string(base_color):gsub("#", "")
			minetest.register_node("edit_skin:" .. id, {
				drawtype = "mesh",
				groups = { not_in_creative_inventory = 1 },
				tiles = { make_texture(base, base_color) },
				use_texture_alpha = "clip",
				mesh = "edit_skin_hand.obj",
			})
		end
	end

	minetest.after(0, function()
		local hand_def = minetest.registered_items[""]
		local range = hand_def and hand_def.range
		for _, base in pairs(edit_skin.base) do
			for _, base_color in pairs(edit_skin.base_color) do
				local id = base:gsub(".png$", "") .. color_to_string(base_color):gsub("#", "")
				minetest.override_item("edit_skin:" .. id, {range = range})
			end
		end
	end)
	
	if minetest.global_exists("i3") then
		i3.new_tab("edit_skin", {
			description = S("Edit Skin"),
			--image = "edit_skin_button.png", -- Icon covers label
			access = function(player, data) return true end,
	
			formspec = function(player, data, fs) end,

			fields = function(player, data, fields)
				i3.set_tab(player, "inventory")
				edit_skin.show_formspec(player)
			end,
		})
	end
	if minetest.global_exists("sfinv_buttons") then
		sfinv_buttons.register_button("edit_skin", {
			title = S("Edit Skin"),
			action = function(player) edit_skin.show_formspec(player) end,
			tooltip = S("Open skin configuration screen."),
			image = "edit_skin_button.png",
		})
	elseif minetest.global_exists("sfinv") then
		sfinv.register_page("edit_skin", {
			title = S("Edit Skin"),
			get = function(self, player, context) return "" end,
			on_enter = function(self, player, context)
				sfinv.contexts[player:get_player_name()].page = sfinv.get_homepage_name(player)
				edit_skin.show_formspec(player)
			end
		})
	end
	if minetest.global_exists("unified_inventory") then
		unified_inventory.register_button("edit_skin", {
			type = "image",
			image = "edit_skin_button.png",
			tooltip = S("Edit Skin"),
			action = function(player)
				edit_skin.show_formspec(player)
			end,
		})
	end
	if minetest.global_exists("armor") and armor.get_player_skin then
		armor.get_player_skin = function(armor, name)
			return edit_skin.compile_skin(edit_skin.player_skins[minetest.get_player_by_name(name)])
		end
	end

	if minetest.global_exists("inventory_plus") then
		minetest.register_on_player_receive_fields(function(player, formname, fields)
			if formname == "" and fields.edit_skin then
				edit_skin.show_formspec(player)
				return true
			end
			return false
		end)
	end
	if minetest.global_exists("smart_inventory") then
		smart_inventory.register_page({
			name = "skin_edit",
			icon = "edit_skin_button.png",
			tooltip = S("Edit Skin"),
			smartfs_callback = function(state) return end,
			sequence = 100,
			on_button_click  = function(state)
				local player = minetest.get_player_by_name(state.location.rootState.location.player)
				edit_skin.show_formspec(player)
			end,
			is_visible_func  = function(state) return true end,
        })
	end
end

init()
