
local S = minetest.get_translator(minetest.get_current_modname())

if armor.materials.gold then
	armor:register_armor(":3d_armor:helmet_gold", {
		description = S("Gold Helmet"),
		inventory_image = "3d_armor_inv_helmet_gold.png",
		groups = {armor_head=1, armor_heal=6, armor_use=300,
			physics_speed=-0.02, physics_gravity=0.02},
		armor_groups = {bludgeon=10, slash=10, pierce=10},
		damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
	})

	armor:register_armor(":3d_armor:chestplate_gold", {
		description = S("Gold Chestplate"),
		inventory_image = "3d_armor_inv_chestplate_gold.png",
		groups = {armor_torso=1, armor_heal=6, armor_use=300,
			physics_speed=-0.05, physics_gravity=0.05},
		armor_groups = {bludgeon=15, slash=15, pierce=15},
		damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
	})

	armor:register_armor(":3d_armor:leggings_gold", {
		description = S("Gold Leggings"),
		inventory_image = "3d_armor_inv_leggings_gold.png",
		groups = {armor_legs=1, armor_heal=6, armor_use=300,
			physics_speed=-0.04, physics_gravity=0.04},
		armor_groups = {bludgeon=15, slash=15, pierce=15},
		damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
	})

	armor:register_armor(":3d_armor:boots_gold", {
		description = S("Gold Boots"),
		inventory_image = "3d_armor_inv_boots_gold.png",
		groups = {armor_feet=1, armor_heal=6, armor_use=300,
			physics_speed=-0.02, physics_gravity=0.02},
		armor_groups = {bludgeon=10, slash=10, pierce=10},
		damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
	})

	local s = "gold"
	local m = armor.materials.gold
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
