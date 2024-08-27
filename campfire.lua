--todo embers appear to be missing when campfire burns out
--todo credit the author
-- Translation support
local S = minetest.get_translator("primitive")

-- VARIABLES
primitive_campfire = {}

primitive_campfire.cooking = 1        -- nil - not cooked, 1 - cooked
primitive_campfire.limited = 1        -- nil - unlimited campfire, 1 - limited
primitive_campfire.flames_ttl = 300    -- Time in seconds until a fire burns down into embers
primitive_campfire.embers_ttl = 600    -- seconds until embers burn out completely leaving ash and an empty fireplace.
primitive_campfire.flare_up = 2       -- seconds from adding a log to embers before it flares into a fire again
primitive_campfire.log_time = primitive_campfire.flames_ttl/4;   -- How long does the log increase. In sec.

local function custom_hud(player)
	hb.init_hudbar(player, "campfire-active", 0)
	hb.init_hudbar(player, "campfire-drilling", 0)
	hb.init_hudbar(player, "campfire-cooking", 0)
	hb.init_hudbar(player, "campfire-torch", 0)
	hb.hide_hudbar(player, "campfire-drilling")
	hb.hide_hudbar(player, "campfire-active")
	hb.hide_hudbar(player, "campfire-cooking")
	hb.hide_hudbar(player, "campfire-torch")
end
hb.register_hudbar("campfire-active", 0xFFFFFF, S("Campfire"), { icon = "primitive_campfire_campfire.png", bgicon = "hbhunger_bgicon.png",  bar = "hbhunger_bar.png" }, 0, 100, false, nil, { format_value = "%.1f", format_max_value = "%d" })
hb.register_hudbar("campfire-drilling", 0xFFFFFF, S("Heat"), { icon = "primitive_campfire_campfire.png", bgicon = "hbhunger_bgicon.png",  bar = "hbhunger_bar.png" }, 0, 20, false, nil, { format_value = "%.1f", format_max_value = "%d" })
hb.register_hudbar("campfire-cooking", 0xFFFFFF, S("Cooking"), { icon = "animalia_poultry_cooked.png", bgicon = "hbhunger_bgicon.png",  bar = "hbhunger_bar.png" }, 0, 100, false, nil, { format_value = "%.1f", format_max_value = "%d" })
hb.register_hudbar("campfire-torch", 0xFFFFFF, S("Torch"), { icon = "default_torch_on_floor.png", bgicon = "hbhunger_bgicon.png",  bar = "hbhunger_bar.png" }, 0, 100, false, nil, { format_value = "%.1f", format_max_value = "%d" })

minetest.register_on_joinplayer(function(player)
	custom_hud(player)
end)

-- FUNCTIONS
local function are_positions_same(pos1, pos2)
    -- Compare the x, y, and z coordinates
    return pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z
end

local function fire_particles_on(pos) -- 3 layers of fire
	local meta = minetest.get_meta(pos)
	local id = minetest.add_particlespawner({ -- 1 layer big particles fire
		amount = 9,
		time = 1.3,
		minpos = {x = pos.x - 0.2, y = pos.y - 0.4, z = pos.z - 0.2},
		maxpos = {x = pos.x + 0.2, y = pos.y - 0.1, z = pos.z + 0.2},
		minvel = {x= 0, y= 0, z= 0},
		maxvel = {x= 0, y= 0.1, z= 0},
		minacc = {x= 0, y= 0, z= 0},
		maxacc = {x= 0, y= 0.7, z= 0},
		minexptime = 0.5,
		maxexptime = 0.7,
		minsize = 2,
		maxsize = 5,
		collisiondetection = false,
		vertical = true,
		texture = "primitive_campfire_anim_fire.png",
		animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 0.8,},
	})
	meta:set_int("layer_1", id)

	local id = minetest.add_particlespawner({ -- 2 layer smol particles fire
		amount = 1,
		time = 1.3,
		minpos = {x = pos.x - 0.1, y = pos.y, z = pos.z - 0.1},
		maxpos = {x = pos.x + 0.1, y = pos.y + 0.4, z = pos.z + 0.1},
		minvel = {x= 0, y= 0, z= 0},
		maxvel = {x= 0, y= 0.1, z= 0},
		minacc = {x= 0, y= 0, z= 0},
		maxacc = {x= 0, y= 1, z= 0},
		minexptime = 0.4,
		maxexptime = 0.6,
		minsize = 0.5,
		maxsize = 0.7,
		collisiondetection = false,
		vertical = true,
		texture = "primitive_campfire_anim_fire.png",
		animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 0.7,},
	})
	meta:set_int("layer_2", id)

	local id = minetest.add_particlespawner({ --3 layer smoke
		amount = 1,
		time = 1.3,
		minpos = {x = pos.x - 0.1, y = pos.y - 0.2, z = pos.z - 0.1},
		maxpos = {x = pos.x + 0.2, y = pos.y + 0.4, z = pos.z + 0.2},
		minvel = {x= 0, y= 0, z= 0},
		maxvel = {x= 0, y= 0.1, z= 0},
		minacc = {x= 0, y= 0, z= 0},
		maxacc = {x= 0, y= 1, z= 0},
		minexptime = 0.6,
		maxexptime = 0.8,
		minsize = 2,
		maxsize = 4,
		collisiondetection = true,
		vertical = true,
		texture = "primitive_campfire_anim_smoke.png",
		animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 0.9,},
	})
	meta:set_int("layer_3", id)
end

local function fire_particles_off(pos)
	local meta = minetest.get_meta(pos)
	local id_1 = meta:get_int("layer_1");
	local id_2 = meta:get_int("layer_2");
	local id_3 = meta:get_int("layer_3");
	minetest.delete_particlespawner(id_1)
	minetest.delete_particlespawner(id_2)
	minetest.delete_particlespawner(id_3)
end



local function effect(pos, texture, vlc, acc, time, size)
	local id = minetest.add_particle({
		pos = pos,
		velocity = vlc,
		acceleration = acc,
		expirationtime = time,
		size = size,
		collisiondetection = true,
		vertical = true,
		texture = texture,
	})
end


local function check_owner(player, ownerPlayer )
	if ownerPlayer and ownerPlayer ~= player:get_player_name() then
		local owner = minetest.get_player_by_name(ownerPlayer)
		hb.hide_hudbar(owner, "campfire-drilling")
		hb.hide_hudbar(owner, "campfire-active")
		hb.hide_hudbar(owner, "campfire-cooking")
		local playerMeta = player:get_meta(owner)
		playerMeta:set_string("campfire-current", nil )

	end	
end

--modified from original
local function cooking(pos, itemstack)
	local meta = minetest.get_meta(pos)
	local node = minetest.get_node(pos)
	local hasGrill = string.match(node.name, "grill") --todo deal with grill
	local method = "charring"
	if hasGrill then method = "cooking" end
	local cooked, _ = minetest.get_craft_result({method = method, width = 1, items = {itemstack}})
	local cookable = cooked.time ~= 0
	
	if cookable and primitive_campfire.cooking then
		local itemTable = cooked.item:to_table()
		if not itemTable then return end
		local eat_y = ItemStack(itemTable.name):get_definition().on_use
		local yOffset = 0.1
		if hasGrill then yOffset = 0.2 end
		if string.find(minetest.serialize(eat_y), "do_item_eat") and meta:get_int("cooked_time") == 0 then
			meta:set_int('cooked_time', cooked.time);
			meta:set_int('cooked_cur_time', 0);
			local name = itemstack:get_name()
			local texture = itemstack:get_definition().inventory_image
			
			primitive.updateHud(meta)

			effect(
				{x = pos.x, y = pos.y+yOffset, z = pos.z},
				texture,
				{x=0, y=0, z=0},
				{x=0, y=0, z=0},
				cooked.time,
				4
			)

			minetest.after(cooked.time/2, function()
				if meta:get_int("it_val") > 0 then

					local item = cooked.item:to_table().name
					minetest.after(cooked.time/2, function(item)
						
						if meta:get_int("it_val") > 0 then
							
							minetest.add_item({x=pos.x, y=pos.y+0.2, z=pos.z}, item)
							meta:set_int('cooked_time', 0);
							meta:set_int('cooked_cur_time', 0);
						else
							
							minetest.add_item({x=pos.x, y=pos.y+0.2, z=pos.z}, name)
						end
						
					end, item)
				else
					minetest.add_item({x=pos.x, y=pos.y+0.2, z=pos.z}, name)
				end
			end)

			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
				return itemstack
			end
		end
	end
end

local function add_log(pos, itemstack)
	local meta = minetest.get_meta(pos)
	local name = itemstack:get_name()
	if itemstack:get_definition().groups.log == 1 then
		local it_val = meta:get_int("it_val") + (primitive_campfire.log_time);
		it_val = math.min(it_val, 305) --limit to a little more than max display value
		meta:set_int('it_val', it_val);
		effect(
			pos,
			"primitive_campfire_log.png",
			{x=0, y=-1, z=0},
			{x=0, y=0, z=0},
			1,
			6
		)
		primitive.updateHud(meta)
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
			return itemstack
		end
		return true
	end
end

local function burn_out(pos, node)
	--todo deal with logs and embers
	if string.find(node.name, "embers") then
		minetest.set_node(pos, {name = string.gsub(node.name, "_with_embers", "")})
		minetest.add_item(pos, "primitive:ash")
	else
		fire_particles_off(pos)
		minetest.set_node(pos, {name = string.gsub(node.name, "campfire_active", "fireplace_with_embers")})
	end
end

-- NODES

local sbox = {
	type = 'fixed',
	fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16},
}

local grille_sbox = {
	type = "fixed",
	fixed = { -8/16, -8/16, -8/16, 8/16, 2/16, 8/16 },
}

local grille_cbox = {
	type = "fixed",
	fixed = {
		{ -8/16,  1/16, -8/16,  8/16, 2/16,  8/16 },
		{ -8/16, -8/16, -8/16, -7/16, 1/16, -7/16 },
		{  8/16, -8/16,  8/16,  7/16, 1/16,  7/16 },
		{  8/16, -8/16, -8/16,  7/16, 1/16, -7/16 },
		{ -8/16, -8/16,  8/16, -7/16, 1/16,  7/16 }
	}
}

minetest.register_node('primitive:fireplace', {
	description = S("Fireplace"),
	drawtype = 'mesh',
	mesh = 'primitive_contained_campfire.obj',
	tiles = {
		"default_stone.png",
		"primitive_campfire_empty_tile.png",
		"primitive_campfire_empty_tile.png",
		"primitive_campfire_empty_tile.png"
	},
	walkable = false,
	buildable_to = false,
	sunlight_propagates = false,
	paramtype = 'light',
	groups = {dig_immediate=3, flammable=0, not_in_creative_inventory=1},
	is_ground_content = false,
	selection_box = sbox,
	sounds = default.node_sound_stone_defaults(),
	drop = {max_items = 3, items = {{items = {"stairs:slab_cobble 3"}}}},

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = itemstack:get_name()
		local a=add_log(pos, itemstack)
		if a then
			minetest.swap_node(pos, {name = "primitive:campfire"})
		elseif name == "primitive:grille" then
			itemstack:take_item()
			minetest.swap_node(pos, {name = "primitive:fireplace_with_grille"})
		end
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		-- meta:set_string('infotext', S("Fireplace"));
		meta:set_int("it_val", 0)
		meta:set_int("em_val", 0)
	end,
})


minetest.register_node('primitive:campfire', {
	description = S("Campfire"),
	drawtype = 'mesh',
	mesh = 'primitive_campfire.obj',
	tiles = {
		"default_stone.png",
		"default_wood.png",
		"primitive_campfire_empty_tile.png",
		"primitive_campfire_empty_tile.png"
	},
	inventory_image = "primitive_campfire_campfire.png",
	walkable = false,
	buildable_to = false,
	sunlight_propagates = true,
	groups = {dig_immediate=3, flammable=0},
	is_ground_content = false,
	paramtype = 'light',
	selection_box = sbox,
	sounds = default.node_sound_stone_defaults(),

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("it_val", 0)
		meta:set_int("em_val", 0)
		meta:set_int("heat_val", 0)
		meta:set_int("torch_heat_val", 0)
		-- meta:set_string('infotext', S("Campfire"));
	end,
	

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local itemname = itemstack:get_name()
		local offHandName = player:get_inventory():get_stack("offhand", 1):get_name()
		if itemname == "primitive:bowdrill" or offHandName == "primitive:bowdrill" then
			
			local playerMeta = player:get_meta()
			local posKey = pos.x .. ":" .. pos.y .. ":" .. pos.z 
			playerMeta:set_string("campfire-current", posKey )
			minetest.sound_play("fire_flint_and_steel",{pos = pos, gain = 0.5, max_hear_distance = 8})
			
			local id = minetest.add_particle({
				pos = {x = pos.x, y = pos.y, z = pos.z},
				velocity = {x=0, y=0.1, z=0},
				acceleration = {x=0, y=0, z=0},
				expirationtime = 2,
				size = 4,
				collisiondetection = true,
				vertical = true,
				texture = "primitive_campfire_anim_smoke.png",
				animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 2.5,},
			})
			local meta = minetest.get_meta(pos)
			local ownerPlayer = meta:get_string("player")
			check_owner(player, ownerPlayer)
			
			meta:set_string("player", player:get_player_name())
			
			local heat = meta:get_int("heat_val")
			meta:set_int("drilling", 1)
			meta:set_int("heat_val", heat + 1)
			minetest.after(4, function()
				local heat = meta:get_int("heat_val")
				meta:set_int("heat_val", heat - 1)
				primitive.updateHud(meta)
				if heat-1 <= 0 then
					meta:set_int("drilling", 0)
				end
			end)
			primitive.updateHud(meta)
			itemstack:add_wear_by_uses(100)
			if heat < 20 then return end
			meta:set_int("heat_val", 0)
			minetest.set_node(pos, {name = 'primitive:campfire_active'})
			local meta = minetest.get_meta(pos) --unnecessary?
			meta:set_string("player", player:get_player_name())
			
		elseif itemname == "primitive:grille" then
			itemstack:take_item()
			minetest.swap_node(pos, {name = "primitive:campfire_with_grille"})
		end
	end,
})

minetest.register_node('primitive:campfire_active', {
	description = S("Active campfire"),
	drawtype = 'mesh',
	mesh = 'primitive_campfire.obj',
	tiles = {
		"default_stone.png",
		"default_wood.png",
		"primitive_campfire_empty_tile.png",
		"primitive_campfire_empty_tile.png"
	},
	inventory_image = "primitive_campfire_campfire.png",
	walkable = false,
	buildable_to = false,
	sunlight_propagates = true,
	groups = {oddly_breakable_by_hand=3, flammable=0, not_in_creative_inventory=1, igniter=1},
	is_ground_content = false,
	paramtype = 'none',
	light_source = 13,
	damage_per_second = 3,
	drop = "primitive:campfire",
	sounds = default.node_sound_stone_defaults(),
	selection_box = sbox,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = itemstack:get_name()
		local a=add_log(pos, itemstack)
		local meta = minetest.get_meta(pos)
		local ownerPlayer = meta:get_string("player")
		check_owner(player, ownerPlayer)
		meta:set_string("player", player:get_player_name())
		primitive.updateHud(meta)
		if not a then
			if name == "primitive:grille" then
				itemstack:take_item()
				minetest.swap_node(pos, {name = "primitive:campfire_active_with_grille"})
			else
				return cooking(pos, itemstack)
			end
		end
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int('it_val', primitive_campfire.flames_ttl)
		meta:set_int("em_val", 0)
		primitive.updateHud(meta)
		minetest.get_node_timer(pos):start(2)
	end,

	on_destruct = function(pos, oldnode, oldmetadata, digger)
		fire_particles_off(pos)
		local meta = minetest.get_meta(pos)
		local handle = meta:get_int("handle")
		minetest.sound_stop(handle)
	end,
	on_update = function()

	end

})

minetest.register_node('primitive:fireplace_with_embers', {
	description = S("Fireplace with embers"),
	drawtype = 'mesh',
	mesh = 'primitive_campfire.obj',
	tiles = {
		"default_stone.png",
		"primitive_campfire_empty_tile.png",
		"primitive_campfire_empty_tile.png",
		{
			name = "primitive_campfire_anim_embers.png",
			animation = {
				type="vertical_frames",
				aspect_w=16,
				aspect_h=16,
				length=2
			}
		}
	},
	walkable = false,
	buildable_to = false,
	sunlight_propagates = false,
	paramtype = 'light',
	light_source = 5,
	groups = {dig_immediate=3, flammable=0, not_in_creative_inventory=1},
	is_ground_content = false,
	selection_box = sbox,
	sounds = default.node_sound_stone_defaults(),
	drop = {max_items = 3, items = {{items = {"stairs:slab_cobble 3"}}}},

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = itemstack:get_name()
		local a=add_log(pos, itemstack)
		if a then
			minetest.swap_node(pos, {name = "primitive:campfire"})
			minetest.after(primitive_campfire.flare_up, function()
				if minetest.get_meta(pos):get_int("it_val") > 0 then
					minetest.swap_node(pos, {name="primitive:campfire_active"})
				end
			end)
		elseif name == "primitive:grille" then
			itemstack:take_item()
			minetest.swap_node(pos, {name = "primitive:fireplace_with_embers_with_grille"})
		end
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("it_val", 0)
		meta:set_int("em_val", primitive_campfire.embers_ttl)
		--meta:set_string('infotext', S("Fireplace with embers"));
	end,
})

minetest.register_node('primitive:fireplace_with_embers_with_grille', {
	description = S("Fireplace with embers and grille"),
	drawtype = 'mesh',
	mesh = 'primitive_contained_campfire.obj',
	tiles = {
		"default_stone.png",
		"primitive_campfire_empty_tile.png",
		"default_steel_block.png",
		{
			name = "primitive_campfire_anim_embers.png",
			animation = {
				type="vertical_frames",
				aspect_w=16,
				aspect_h=16,
				length=2
			}
		}
	},
	walkable = false,
	buildable_to = false,
	sunlight_propagates = false,
	paramtype = 'light',
	light_source = 5,
	groups = {dig_immediate=3, flammable=0, not_in_creative_inventory=1},
	is_ground_content = false,
	selection_box = grille_sbox,
	node_box = grille_cbox,
	sounds = default.node_sound_stone_defaults(),
	drop = {
		max_items = 4,
		items = {
			{
				items = {"stairs:slab_cobble 3"},
				items = {"primitive:grille 1"}
			}
		}
	},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = itemstack:get_name()
		local a=add_log(pos, itemstack)
		if a then
			minetest.swap_node(pos, {name = "primitive:campfire_with_grille"})
			minetest.after(primitive_campfire.flare_up, function()
				if minetest.get_meta(pos):get_int("it_val") > 0 then
					minetest.swap_node(pos, {name="primitive:campfire_active_with_grille"})
				end
			end)
		end
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("it_val", 0)
		meta:set_int("em_val", primitive_campfire.embers_ttl)
		--meta:set_string('infotext', S("Fireplace with embers"));
	end,
})

minetest.register_node('primitive:fireplace_with_grille', {
	description = S("Fireplace with grille"),
	drawtype = 'mesh',
	mesh = 'primitive_contained_campfire.obj',
	tiles = {
		"default_stone.png",
		"primitive_campfire_empty_tile.png",
		"default_steel_block.png",
		"primitive_campfire_empty_tile.png"
	},
	buildable_to = false,
	sunlight_propagates = false,
	paramtype = 'light',
	groups = {dig_immediate=3, flammable=0, not_in_creative_inventory=1},
	is_ground_content = false,
	selection_box = grille_sbox,
	node_box = grille_cbox,
	sounds = default.node_sound_stone_defaults(),
	drop = {
		max_items = 4,
		items = {
			{
				items = {"stairs:slab_cobble 3"},
				items = {"primitive:grille 1"}
			}
		}
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("it_val", 0)
		meta:set_int("em_val", 0)
		--meta:set_string('infotext', S("Fireplace"));
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = itemstack:get_name()
		local a=add_log(pos, itemstack)
		if a then
			minetest.swap_node(pos, {name = "primitive:campfire_with_grille"})
		end
	end,
})

minetest.register_node('primitive:campfire_with_grille', {
	description = S("Campfire with grille"),
	drawtype = 'mesh',
	mesh = 'primitive_contained_campfire.obj',
	tiles = {
		"default_stone.png",
		"default_wood.png",
		"default_steel_block.png",
		"primitive_campfire_empty_tile.png"
	},
	inventory_image = "primitive_campfire_campfire.png",
	buildable_to = false,
	sunlight_propagates = true,
	groups = {dig_immediate=3, flammable=0, not_in_creative_inventory=1},
	is_ground_content = false,
	paramtype = 'light',
	selection_box = grille_sbox,
	node_box = grille_cbox,
	sounds = default.node_sound_stone_defaults(),

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("it_val", 0)
		meta:set_int("em_val", 0)
		--meta:set_string('infotext', S("Campfire"));
	end,

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local offHandName = player:get_inventory():get_stack("offhand", 1):get_name()
		if itemname == "primitive:bowdrill" or offHandName == "primitive:bowdrill"  then
			minetest.sound_play("fire_flint_and_steel",{pos = pos, gain = 0.5, max_hear_distance = 8})
			
			local id = minetest.add_particle({
				pos = {x = pos.x, y = pos.y, z = pos.z},
				velocity = {x=0, y=0.1, z=0},
				acceleration = {x=0, y=0, z=0},
				expirationtime = 2,
				size = 4,
				collisiondetection = true,
				vertical = true,
				texture = "primitive_campfire_anim_smoke.png",
				animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 2.5,},
			})
			local meta = minetest.get_meta(pos)
			local heat = meta:get_int("heat_val")
			meta:set_int("drilling", 1)
			meta:set_int("heat_val", heat + 1)
			minetest.after(4, function()
				local heat = meta:get_int("heat_val")
				meta:set_int("heat_val", heat - 1)
				primitive.updateHud(meta)
				if heat-1 <= 0 then
					meta:set_int("drilling", 0)
				end
			end)
			primitive.updateHud(meta)
			itemstack:add_wear_by_uses(20)
			if heat < 20 then return end
			meta:set_int("heat_val", 0)
			minetest.set_node(pos, {name = 'primitive:campfire_active_with_grille'})
		end
	end,
	drop = {
		max_items = 4,
		items = {
			{
				items = {"primitive:campfire 1"},
				items = {"primitive:grille 1"}
			}
		}
	},
})

minetest.register_node('primitive:campfire_active_with_grille', {
	description = S("Active campfire with grille"),
	drawtype = 'mesh',
	mesh = 'primitive_contained_campfire.obj',
	tiles = {
		"default_stone.png",
		"default_wood.png",
		"default_steel_block.png",
		"primitive_campfire_empty_tile.png"
	},
	inventory_image = "primitive_campfire_campfire.png",
	buildable_to = false,
	sunlight_propagates = true,
	groups = {oddly_breakable_by_hand=3, flammable=0, not_in_creative_inventory=1, igniter=1},
	is_ground_content = false,
	paramtype = 'none',
	light_source = 13,
	damage_per_second = 3,
	drop = {
		max_items = 4,
		items = {
			{
				items = {"primitive:campfire 1"},
				items = {"primitive:grille 1"}
			}
		}
	},
	sounds = default.node_sound_stone_defaults(),
	selection_box = grille_sbox,
	node_box = grille_cbox,

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = itemstack:get_name()
		local a=add_log(pos, itemstack)
		if not a then
			return cooking(pos, itemstack)
		end
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int('it_val', primitive_campfire.flames_ttl);
		meta:set_int("em_val", 0)
		primitive.updateHud(meta)
		minetest.get_node_timer(pos):start(2)
	end,

	on_destruct = function(pos, oldnode, oldmetadata, digger)
		fire_particles_off(pos)
		local meta = minetest.get_meta(pos)
		local handle = meta:get_int("handle")
		minetest.sound_stop(handle)
	end,

	on_timer = function(pos) -- Every 6 seconds play sound fire_small
		local meta = minetest.get_meta(pos)
		local handle = minetest.sound_play("primitive_fire_small",{pos=pos, max_hear_distance = 18, loop=false, gain=0.1})
		meta:set_int("handle", handle)
		minetest.get_node_timer(pos):start(6)
	end,
})

-- ABMs

minetest.register_abm({
	nodenames = {
		"primitive:fireplace_with_embers",
		"primitive:fireplace_with_embers_with_grille"
	},
	interval = 1.0, -- Run every second
	chance = 1, -- Select every node
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos)
		local em_val = meta:get_int("em_val")
		meta:set_int("em_val", em_val - 1)
		if em_val <= 0 then
			burn_out(pos, node)
		end
		

	end
})




--update campfires
minetest.register_abm({
	nodenames = {
		"primitive:campfire_active",
		"primitive:campfire_active_with_grille"
	},
	interval = 1.0, -- Run every second
	chance = 1, -- Select every node
	catch_up = false,

	action = function(pos, node, active_object_count, active_object_count_wider)
		local fpos, num = minetest.find_nodes_in_area(
			{x=pos.x-1, y=pos.y, z=pos.z-1},
			{x=pos.x+1, y=pos.y+1, z=pos.z+1},
			{"group:water"}
		)
		if #fpos > 0 then
			if string.find(node.name, "embers") then
				burn_out(pos, node)
			else
				minetest.set_node(pos, {name = string.gsub(node.name, "_active", "")})
			end
			minetest.sound_play("fire_extinguish_flame",{pos = pos, max_hear_distance = 16, gain = 0.15})
		else
			local meta = minetest.get_meta(pos)
			local it_val = meta:get_int("it_val") - 1;

			if primitive_campfire.limited and primitive_campfire.flames_ttl > 0 then
				if it_val <= 0 then
					burn_out(pos, node)
					return
				end
				meta:set_int('it_val', it_val);
			end

			if primitive_campfire.cooking then
				if meta:get_int('cooked_cur_time') <= meta:get_int('cooked_time') then
					meta:set_int('cooked_cur_time', meta:get_int('cooked_cur_time') + 1);
				else
					meta:set_int('cooked_time', 0);
					meta:set_int('cooked_cur_time', 0);
				end
			end
			
			fire_particles_on(pos)
			
			local playerName = meta:get_string("player")
			local player = minetest.get_player_by_name(playerName)
			if not player then
				return
			end
			local playerMeta = player:get_meta()
			local pointedThing = primitive.get_pointed_thing(player)
			
			--show the campfire we last looked at
			--todo test the fix I did here
			--it used to round poinedthing.intersection_point to get the pos
			if pointedThing and  pointedThing.intersection_point then
				local intersection = minetest.get_pointed_thing_position(pointedThing)
				if are_positions_same(pos, intersection) then
					local posKey = pos.x .. ":" .. pos.y .. ":" .. pos.z 
					playerMeta:set_string("campfire-current", posKey )
				end
			end
			local posKey = pos.x .. ":" .. pos.y .. ":" .. pos.z 
			if playerMeta:get_string("campfire-current") == posKey then
				primitive.updateHud(meta)
			end
			
			--make torch lighting wear down over time
			if meta:get_int("heating_torch") == 0 then
				local heat = meta:get_int("torch_heat_val")
				if heat > 0 then
					heat = heat - 10
					heat = math.max(heat, 0)
					meta:set_int("torch_heat_val", heat )
					primitive.updateHud(meta)
					meta:set_int("heating_torch_done", 0)
				end
			end
		end
	end
})

-- CRAFTS

if minetest.get_modpath("basic_materials") then
	minetest.register_craft({
		output = "primitive:grille",
		recipe = {
			{"basic_materials:steel_bar", "", "basic_materials:steel_bar"},
			{"", "basic_materials:steel_wire", ""},
			{"basic_materials:steel_bar", "", "basic_materials:steel_bar"}
		}
	})
else
	minetest.register_craft({
		output = "primitive:grille",
		recipe = {
			{"default:steel_ingot", "", "default:steel_ingot"},
			{"", "xpanes:bar_flat", ""},
			{"default:steel_ingot", "", "default:steel_ingot"}
		}
	})
end

minetest.register_craft({
	output = "primitive:campfire",
	recipe = {
		{'', 'group:log', ''},
		{'primitive:flint','group:log', 'primitive:flint'},
		{'', 'primitive:flint', ''},
	}
})

-- ITEMS

minetest.register_craftitem("primitive:grille", {
	description = S("Metal Grille"),
	inventory_image = "primitive_campfire_grille.png"
})

minetest.register_craftitem("primitive:ash", {
	description = S("Ash"),
	inventory_image = "primitive_campfire_ash.png"
})


