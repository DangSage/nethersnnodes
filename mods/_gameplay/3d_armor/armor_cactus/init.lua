
local S = minetest.get_translator(minetest.get_current_modname())

if armor.materials.cactus then

	armor:register_armor(":3d_armor:helmet_cactus", {
		description = S("Cactus Helmet"),
		inventory_image = "3d_armor_inv_helmet_cactus.png",
		groups = {armor_head=1, armor_heal=0, armor_use=1000},
		armor_groups = { bludgeon=5, slash=5, pierce=5},
		damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
	})

	armor:register_armor(":3d_armor:chestplate_cactus", {
		description = S("Cactus Chestplate"),
		inventory_image = "3d_armor_inv_chestplate_cactus.png",
		groups = {armor_torso=1, armor_heal=0, armor_use=1000},
		armor_groups = { bludgeon=10, slash=10, pierce=10},
		damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
	})

	armor:register_armor(":3d_armor:leggings_cactus", {
		description = S("Cactus Leggings"),
		inventory_image = "3d_armor_inv_leggings_cactus.png",
		groups = {armor_legs=1, armor_heal=0, armor_use=1000},
		armor_groups = { bludgeon=10, slash=10, pierce=10},
		damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
	})

	armor:register_armor(":3d_armor:boots_cactus", {
		description = S("Cactus Boots"),
		inventory_image = "3d_armor_inv_boots_cactus.png",
		groups = {armor_feet=1, armor_heal=0, armor_use=1000},
		armor_groups = { bludgeon=5, slash=5, pierce=5},
		damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
	})
	local cactus_armor_fuel = {
		helmet = 14,
		chestplate = 16,
		leggings = 15,
		boots = 13
	}
	for armor, burn in pairs(cactus_armor_fuel) do
		minetest.register_craft({
			type = "fuel",
			recipe = "3d_armor:" .. armor .. "_cactus",
			burntime = burn,
		})
	end

	local s = "cactus"
	local m = armor.materials.cactus
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
