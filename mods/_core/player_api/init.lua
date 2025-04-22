dofile(minetest.get_modpath("player_api") .. "/api.lua")

-- Default player appearance
player_api.register_model("character.b3d", {
	animation_speed = 30,
	textures = {"character.png"},
	animations = {
		-- Standard animations.
		stand = {x = 0, y = 79},
		sneak_stand = {
			x = 221, y = 222, eye_height = 1.3, override_local = true,
			collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.3, 0.3}
		},
		sit = {
			x = 81, y = 160, eye_height = 0.9, override_local = true,
			collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.0, 0.3}
		},
		lay = {
			x = 162, y = 166, eye_height = 0.3, override_local = true,
			collisionbox = {-0.6, 0.0, -0.6, 0.6, 0.3, 0.6}
		},

		walk = {x = 168, y = 187},
		sneak_walk = {
			x = 223, y = 243, eye_height = 1.3, override_local = true, animation_speed = 15,
			collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.3, 0.3}
		},


		mine = {x = 189, y = 198},
		walk_mine = {x = 200, y = 219},
		sneak_mine = {
			x = 244, y = 253, eye_height = 1.3, override_local = true, animation_speed = 15,
			collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.3, 0.3}
		},
		sneak_walk_mine = {
			x = 254, y = 273, eye_height = 1.3, override_local = true, animation_speed = 15,
			collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.3, 0.3}
		},
	},
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
	stepheight = 0.6,
	eye_height = 1.75,
	use_texture_alpha = "blend",
})

-- Update appearance when the player joins
minetest.register_on_joinplayer(function(player)
	player_api.set_model(player, "character.b3d")
end)
