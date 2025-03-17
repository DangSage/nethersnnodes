
local S = minetest.get_translator(minetest.get_current_modname())

if armor.materials.diamond then
	armor:register_armor(":3d_armor:helmet_diamond", {
		description = S("Diamond Helmet"),
		inventory_image = "3d_armor_inv_helmet_diamond.png",
		groups = {armor_head=1, armor_heal=12, armor_use=200},
		armor_groups = {bludgeon=15, slash=15, pierce=15},
		damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
	})

	armor:register_armor(":3d_armor:chestplate_diamond", {
		description = S("Diamond Chestplate"),
		inventory_image = "3d_armor_inv_chestplate_diamond.png",
		groups = {armor_torso=1, armor_heal=12, armor_use=200},
		armor_groups = {bludgeon=20, slash=20, pierce=20},
		damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
	})

	armor:register_armor(":3d_armor:leggings_diamond", {
		description = S("Diamond Leggings"),
		inventory_image = "3d_armor_inv_leggings_diamond.png",
		groups = {armor_legs=1, armor_heal=12, armor_use=200},
		armor_groups = {bludgeon=20, slash=20, pierce=20},
		damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
	})

	armor:register_armor(":3d_armor:boots_diamond", {
		description = S("Diamond Boots"),
		inventory_image = "3d_armor_inv_boots_diamond.png",
		groups = {armor_feet=1, armor_heal=12, armor_use=200},
		armor_groups = {bludgeon=15, slash=15, pierce=15},
		damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
	})

	local s = "diamond"
	local m = armor.materials.diamond
	minetest.register_craft({
		output = "3d_armor:helmet_"..s,
		recipe = {
			{m, m, m},
			{m, "", m},
			{"", "", ""},
		},
	})
	minetest.register_craft({
		output = "3d_armor:chestplate_"..s,
		recipe = {
			{m, "", m},
			{m, m, m},
			{m, m, m},
		},
	})
	minetest.register_craft({
		output = "3d_armor:leggings_"..s,
		recipe = {
			{m, m, m},
			{m, "", m},
			{m, "", m},
		},
	})
	minetest.register_craft({
		output = "3d_armor:boots_"..s,
		recipe = {
			{m, "", m},
			{m, "", m},
		},
	})
end
