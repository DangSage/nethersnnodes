-- mods/default/tools.lua

-- support for MT game translation.
local S = default.get_translator

-- The hand
-- Override the hand item registered in the engine in builtin/game/register.lua
minetest.override_item("", {
	wield_scale = {x=1,y=1,z=2.5},
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {
			crumbly = {times={[2]=3.00, [3]=0.70}, uses=0, maxlevel=1},
			snappy = {times={[3]=0.40}, uses=0, maxlevel=1},
			oddly_breakable_by_hand = {times={[1]=3.50,[2]=2.00,[3]=0.70}, uses=0}
		},
		damage_groups = {bludgeon=1, slash=1, pierce=1},
	}
})

--
-- Picks
--

minetest.register_tool("default:pick_wood", {
	description = S("Wooden Pickaxe"),
	inventory_image = "default_tool_woodpick.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			cracky = {times={[3]=1.60}, uses=10, maxlevel=1},
		},
		damage_groups = {bludgeon=2, slash=1, pierce=2},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {pickaxe = 1, flammable = 2}
})

minetest.register_tool("default:pick_stone", {
	description = S("Stone Pickaxe"),
	inventory_image = "default_tool_stonepick.png",
	tool_capabilities = {
		full_punch_interval = 1.3,
		max_drop_level=0,
		groupcaps={
			cracky = {times={[2]=2.0, [3]=1.00}, uses=20, maxlevel=1},
		},
		damage_groups = {bludgeon=2, slash=1, pierce=3},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {pickaxe = 1}
})

minetest.register_tool("default:pick_bronze", {
	description = S("Bronze Pickaxe"),
	inventory_image = "default_tool_bronzepick.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=4.50, [2]=1.80, [3]=0.90}, uses=20, maxlevel=2},
		},
		damage_groups = {bludgeon=2, slash=1, pierce=4},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {pickaxe = 1}
})

minetest.register_tool("default:pick_steel", {
	description = S("Steel Pickaxe"),
	inventory_image = "default_tool_steelpick.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=20, maxlevel=2},
		},
		damage_groups = {bludgeon=2, slash=1, pierce=4},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {pickaxe = 1}
})

minetest.register_tool("default:pick_diamond", {
	description = S("Diamond Pickaxe"),
	inventory_image = "default_tool_diamondpick.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3},
		},
		damage_groups = {bludgeon=2, slash=1, pierce=5},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {pickaxe = 1}
})

--
-- Shovels
--

minetest.register_tool("default:shovel_wood", {
	description = S("Wooden Shovel"),
	inventory_image = "default_tool_woodshovel.png",
	wield_image = "default_tool_woodshovel.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			crumbly = {times={[1]=3.00, [2]=1.60, [3]=0.60}, uses=10, maxlevel=1},
		},
		damage_groups = {bludgeon=2, slash=1, pierce=1},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {shovel = 1, flammable = 2}
})

minetest.register_tool("default:shovel_stone", {
	description = S("Stone Shovel"),
	inventory_image = "default_tool_stoneshovel.png",
	wield_image = "default_tool_stoneshovel.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.4,
		max_drop_level=0,
		groupcaps={
			crumbly = {times={[1]=1.80, [2]=1.20, [3]=0.50}, uses=20, maxlevel=1},
		},
		damage_groups = {bludgeon=2, slash=1, pierce=1},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {shovel = 1}
})

minetest.register_tool("default:shovel_bronze", {
	description = S("Bronze Shovel"),
	inventory_image = "default_tool_bronzeshovel.png",
	wield_image = "default_tool_bronzeshovel.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.1,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.65, [2]=1.05, [3]=0.45}, uses=25, maxlevel=2},
		},
		damage_groups = {bludgeon=3, slash=1, pierce=1},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {shovel = 1}
})

minetest.register_tool("default:shovel_steel", {
	description = S("Steel Shovel"),
	inventory_image = "default_tool_steelshovel.png",
	wield_image = "default_tool_steelshovel.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.1,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.50, [2]=0.90, [3]=0.40}, uses=30, maxlevel=2},
		},
		damage_groups = {bludgeon=3, slash=1, pierce=1},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {shovel = 1}
})

minetest.register_tool("default:shovel_diamond", {
	description = S("Diamond Shovel"),
	inventory_image = "default_tool_diamondshovel.png",
	wield_image = "default_tool_diamondshovel.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.10, [2]=0.50, [3]=0.30}, uses=30, maxlevel=3},
		},
		damage_groups = {bludgeon=4, slash=1, pierce=1},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {shovel = 1}
})

--
-- Axes
--

minetest.register_tool("default:axe_wood", {
	description = S("Wooden Axe"),
	inventory_image = "default_tool_woodaxe.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=0,
		groupcaps={
			choppy = {times={[2]=3.00, [3]=1.60}, uses=10, maxlevel=1},
		},
		damage_groups = {bludgeon=2, slash=1, pierce=2},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {axe = 1, flammable = 2}
})

minetest.register_tool("default:axe_stone", {
	description = S("Stone Axe"),
	inventory_image = "default_tool_stoneaxe.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			choppy={times={[1]=3.00, [2]=2.00, [3]=1.30}, uses=20, maxlevel=1},
		},
		damage_groups = {bludgeon=3, slash=1, pierce=3},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {axe = 1}
})

minetest.register_tool("default:axe_bronze", {
	description = S("Bronze Axe"),
	inventory_image = "default_tool_bronzeaxe.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.75, [2]=1.70, [3]=1.15}, uses=20, maxlevel=2},
		},
		damage_groups = {bludgeon=4, slash=1, pierce=4},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {axe = 1}
})

minetest.register_tool("default:axe_steel", {
	description = S("Steel Axe"),
	inventory_image = "default_tool_steelaxe.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.50, [2]=1.40, [3]=1.00}, uses=20, maxlevel=2},
		},
		damage_groups = {bludgeon=4, slash=1, pierce=4},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {axe = 1}
})

minetest.register_tool("default:axe_diamond", {
	description = S("Diamond Axe"),
	inventory_image = "default_tool_diamondaxe.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=30, maxlevel=3},
		},
		damage_groups = {bludgeon=5, slash=1, pierce=7},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {axe = 1}
})

--
-- Swords
--

minetest.register_tool("default:dirk_wood", {
	description = S("Wooden Dirk"),
	inventory_image = "default_tool_wood_dirk.png",
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.6, [3]=0.40}, uses=10, maxlevel=1},
		},
		damage_groups = {bludgeon=1, slash=2, pierce=1},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1, flammable = 2}
})

minetest.register_tool("default:dirk_stone", {
	description = S("Stone Dirk"),
	inventory_image = "default_tool_stone_dirk.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.4, [3]=0.40}, uses=20, maxlevel=1},
		},
		damage_groups = {bludgeon=1, slash=4, pierce=2},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1}
})

minetest.register_tool("default:dirk_bronze", {
	description = S("Bronze Dirk"),
	inventory_image = "default_tool_bronze_dirk.png",
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=2.75, [2]=1.30, [3]=0.375}, uses=25, maxlevel=2},
		},
		damage_groups = {bludgeon=1, slash=6, pierce=3},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1}
})

minetest.register_tool("default:dirk_steel", {
	description = S("Steel Dirk"),
	inventory_image = "default_tool_steel_dirk.png",
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=2.5, [2]=1.20, [3]=0.35}, uses=30, maxlevel=2},
		},
		damage_groups = {bludgeon=1, slash=6, pierce=4},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1}
})

minetest.register_tool("default:dirk_diamond", {
	description = S("Diamond Dirk"),
	inventory_image = "default_tool_diamond_dirk.png",
	tool_capabilities = {
		full_punch_interval = 0.7,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=40, maxlevel=3},
		},
		damage_groups = {bludgeon=1, slash=8, pierce=4},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1}
})

minetest.register_tool("default:dirk_obsidian", {
	description = S("Obsidian Dirk"),
	inventory_image = "default_tool_obsidian_dirk.png",
	tool_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=40, maxlevel=3},
		},
		damage_groups = {bludgeon=1, slash=7, pierce=3},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1}
})

--
-- Register Craft Recipies
--

local craft_ingreds = {
	wood = "group:wood",
	stone = "group:stone",
	steel = "default:steel_ingot",
	bronze = "default:bronze_ingot",
	mese = "default:mese_crystal",
	diamond = "default:diamond"
}

for name, mat in pairs(craft_ingreds) do
	minetest.register_craft({
		output = "default:pick_".. name,
		recipe = {
			{mat, mat, mat},
			{"", "group:stick", ""},
			{"", "group:stick", ""}
		}
	})

	minetest.register_craft({
		output = "default:shovel_".. name,
		recipe = {
			{mat},
			{"group:stick"},
			{"group:stick"}
		}
	})

	minetest.register_craft({
		output = "default:axe_".. name,
		recipe = {
			{mat, mat},
			{mat, "group:stick"},
			{"", "group:stick"}
		}
	})

	minetest.register_craft({
		output = "default:dirk_".. name,
		recipe = {
			{mat},
			{mat},
			{"group:stick"}
		}
	})
end

minetest.register_craft({
	type = "fuel",
	recipe = "default:pick_wood",
	burntime = 6,
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:shovel_wood",
	burntime = 4,
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:axe_wood",
	burntime = 6,
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:dirk_wood",
	burntime = 5,
})
