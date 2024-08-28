local TORCH_BURN_TIME_MINS = 20
--floor/default
local torch = minetest.registered_nodes["default:torch"]
local torch_def = table.copy(torch)
local groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1}

--unlit torches
torch_def.description = "Torch (unlit)"
torch_def.inventory_image = "primitive_torches_torch_on_floor_unlit.png"
torch_def.groups = groups
torch_def.tiles = {"primitive_torches_torch_on_floor_unlit.png"}
torch_def.light_source = 0
torch_def.drop = "primitive:torch_unlit"
torch_def.floodable = true
torch_def.on_flood = function() return false end
torch_def.on_place = function(itemstack, placer, pointed_thing)
	minetest.log("prim place")
    local under = pointed_thing.under
    local node = minetest.get_node(under)
    local def = minetest.registered_nodes[node.name]
    if def and def.on_rightclick and
        not (placer and placer:is_player() and
        placer:get_player_control().sneak) then
        return def.on_rightclick(under, node, placer, itemstack,
            pointed_thing) or itemstack
    end

    local above = pointed_thing.above
    local wdir = minetest.dir_to_wallmounted(vector.subtract(under, above))
    local fakestack = itemstack
    if wdir == 0 then
        fakestack:set_name("primitive:torch_ceiling_unlit")
    elseif wdir == 1 then
        fakestack:set_name("primitive:torch_unlit")
    else
        fakestack:set_name("primitive:torch_wall_unlit")
    end
    itemstack = minetest.item_place(fakestack, placer, pointed_thing, wdir)
    itemstack:set_name("primitive:torch_unlit")
    return itemstack
end
minetest.register_node("primitive:torch_unlit", torch_def)

local groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1, torch=1, not_in_creative_inventory=1}

--wall (unlit)
local wall_torch = minetest.registered_nodes["default:torch_wall"]
local wall_torch_def = table.copy(wall_torch)
wall_torch_def.groups = groups
wall_torch_def.light_source = 0
wall_torch_def.floodable = false
wall_torch_def.drop = "primitive:torch_unlit"
wall_torch_def.tiles ={"primitive_torches_torch_on_floor_unlit.png"}
minetest.register_node("primitive:torch_wall_unlit", wall_torch_def)

--ceiling(unlit)
local ceil_torch = minetest.registered_nodes["default:torch_ceiling"]
local ceil_torch_def = table.copy(ceil_torch)
ceil_torch_def.groups = groups
ceil_torch_def.light_source = 0
ceil_torch_def.floodable = false
ceil_torch_def.drop = "primitive:torch_unlit"
ceil_torch_def.tiles = {"primitive_torches_torch_on_floor_unlit.png"}
minetest.register_node("primitive:torch_ceiling_unlit", ceil_torch_def)

--extinguished
local unlit_torch = minetest.registered_nodes["primitive:torch_unlit"]
local unlit_torch_def = table.copy(unlit_torch)
unlit_torch_def.description = "Torch (entinguished)"
unlit_torch_def.tiles ={"primitive_torches_torch_on_floor_extinguished.png"}
unlit_torch_def.drop = ""
unlit_torch_def.groups = groups
unlit_torch_def.floodable = true
unlit_torch_def.on_flood = function() return false end
unlit_torch_def.on_place = function(itemstack, placer, pointed_thing)
	minetest.log("place")
	return itemstack 
	end
minetest.register_node("primitive:torch_extinguished", unlit_torch_def)

local unlit_wall_torch = minetest.registered_nodes["primitive:torch_wall_unlit"]
local unlit_wall_torch_def = table.copy(unlit_wall_torch)
unlit_wall_torch_def.tiles ={"primitive_torches_torch_on_floor_extinguished.png"}
unlit_wall_torch_def.drop = ""
unlit_wall_torch_def.groups = groups
minetest.register_node("primitive:torch_wall_extinguished", unlit_wall_torch_def)

local unlit_ceil_torch = minetest.registered_nodes["primitive:torch_ceiling_unlit"]
local unlit_ceil_torch_def = table.copy(unlit_ceil_torch)
unlit_ceil_torch_def.tiles ={"primitive_torches_torch_on_floor_extinguished.png"}
unlit_ceil_torch_def.drop = ""
unlit_ceil_torch_def.groups = groups
minetest.register_node("primitive:torch_ceiling_extinguished", unlit_ceil_torch_def)


--recipes
minetest.clear_craft({
    output = "default:torch"
})

minetest.register_craft({
	output = "primitive:torch_unlit 4",
	recipe = {
		{"default:coal_lump"},
		{"group:stick"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "primitive:torch_unlit",
	burntime = 6,
})


--lighting other torch
controls.register_on_hold(function(player, key, time)
	local playerName = player:get_player_name()
	local creative = minetest.is_creative_enabled(playerName)
	if (key ~= "RMB" and key ~= "zoom")  then
		return
	end
	local wielditem = player:get_wielded_item()
	local name = wielditem:get_name()
	if not (name =="default:torch") then
		return
	end
	local pointed_thing = primitive.get_pointed_thing(player)
	local pointed_thing_pos = minetest.get_pointed_thing_position(pointed_thing)
	if not pointed_thing_pos then
		return
	end

	local pointed_node = minetest.get_node(pointed_thing_pos)
	
	local pointed_node_name = pointed_node.name

	if not (pointed_node_name == "primitive:torch_unlit" or pointed_node_name == "primitive:torch_ceiling_unlit" or pointed_node_name == "primitive:torch_wall_unlit") then
		return
	end

	local meta = minetest.get_meta(pointed_thing_pos)
    meta:set_string("player", playerName)
	if meta:get_int("heating_torch_done") == 1 then
		return
	end
	local heat = meta:get_int("torch_heat_val")
    meta:set_int("heating_torch", 1)
	meta:set_int("torch_heat_val", heat + 10)
	primitive.updateHud(meta)
	if heat < 500 then return end

	if meta:get_int("heating_torch") == 1 then
		meta:set_int("heating_torch", 0)
		meta:set_int("heating_torch_done", 1)
		minetest.sound_play("primitive_fire_flint_and_steel",{pos = pointed_thing_pos, gain = 0.5, max_hear_distance = 8})

        local p = minetest.get_node(pointed_thing_pos).param2
        local torchName = "default:torch"
        if pointed_node_name == "primitive:torch_ceiling_unlit" then
            torchName ="default:torch_ceiling" 

        end
        if pointed_node_name == "primitive:torch_wall_unlit" then
            torchName = "default:torch_wall"
            
        end
        minetest.set_node(pointed_thing_pos, {name=torchName, param2=p})
        meta:set_int("torch_heat_val", 0 )
        meta:set_string("player", playerName)
        meta:set_int("burntime", 1000)
	end
	meta:set_int("torch_heat_val", 0)
    primitive.updateHud(meta)
end)

controls.register_on_release(function(player, key, time)
	local playerName = player:get_player_name()
	local creative = minetest.is_creative_enabled(playerName)
	if (key ~= "RMB" and key ~= "zoom")  then
		return
	end

	local wielditem = player:get_wielded_item()
	local name = wielditem:get_name()

	if not (name =="default:torch") then
		return
	end

	local pointed_thing = primitive.get_pointed_thing(player)
	
	local pointed_thing_pos = minetest.get_pointed_thing_position(pointed_thing)
	if not pointed_thing_pos then
		return
	end
    local meta = minetest.get_meta(pointed_thing_pos)
    primitive.updateHud(meta)

	local pointed_node = minetest.get_node(pointed_thing_pos)
	
	local pointed_node_name = pointed_node.name

    if not(string.match(pointed_node_name, "torch")) then
        return
    end
	
	if meta:get_int("heating_torch_done") == 1 then
		meta:set_int("torch_heat_val", 0)
	end
	meta:set_int("heating_torch_done", 0)
	meta:set_int("heating_torch", 0)
    primitive.updateHud(meta)
	
end)


--abms unlit - clears the torch heat when partially lit from another torch
minetest.register_abm({
	nodenames = {
		"primitive:torch_unlit",
		"primitive:torch_ceiling_unlit",
        "primitive:torch_wall_unlit"
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
		if not (#fpos > 0) then
			local meta = minetest.get_meta(pos)
			

			if meta:get_int("heating_torch") == 0 then
				local heat = meta:get_int("torch_heat_val")
				if heat > 0 then
					heat = heat - 50
					heat = math.max(heat, 0)
					meta:set_int("torch_heat_val", heat )
					
					meta:set_int("heating_torch_done", 0)
                    primitive.updateHud(meta)
				end
			end
            
		end
	end
})

--abms lit
--makes torches burn out over time
minetest.register_abm({
	nodenames = {
		"default:torch_wall",
		"default:torch_ceiling",
        "default:torch"
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
		if not (#fpos > 0) then
			local meta = minetest.get_meta(pos)
            local burntime = meta:get_int("burntime")
            
            if burntime == 0 then
                burntime = 1000
            end
            burntime = burntime - 1000/(60*TORCH_BURN_TIME_MINS)
            meta:set_int("burntime", burntime)
            if burntime <= 0 then
                --fixme
                
                local p = minetest.get_node(pos).param2
                local pointed_node_name = node.name
                local torchName = "primitive:torch_extinguished"
                if pointed_node_name == "default:torch_ceiling" then
                    torchName ="primitive:torch_ceiling_extinguished"

                end
                if pointed_node_name == "default:torch_wall" then
                    torchName = "primitive:torch_wall_extinguished"
                    
                end
                minetest.set_node(pos, {name=torchName, param2=p})
            end
		end
	end
})

--light torch to torch
controls.register_on_hold(function(player, key, time)
	local playerName = player:get_player_name()
	local creative = minetest.is_creative_enabled(playerName)
	if (key ~= "RMB" and key ~= "zoom")  then
		return
	end
	local wielditem = player:get_wielded_item()
	local name = wielditem:get_name()

	if not (name =="primitive:torch_unlit") then
		return
	end

	

	local pointed_thing = primitive.get_pointed_thing(player)
	
	local pointed_thing_pos =minetest.get_pointed_thing_position(pointed_thing)
	if not pointed_thing_pos then
		return
	end
	local pointed_node = minetest.get_node(pointed_thing_pos)
	
	local pointed_node_name = pointed_node.name

	if not (pointed_node_name == "primitive:campfire_active") then
		return
	end

	local meta = minetest.get_meta(pointed_thing_pos)
	if meta:get_int("heating_torch_done") == 1 then
		return
	end
	local heat = meta:get_int("torch_heat_val")
	meta:set_int("heating_torch", 1)
	local count = wielditem:get_count()
	
	count = 11 - math.min(10, count)
	meta:set_int("torch_heat_val", heat + count)
	primitive.updateHud(meta)
	if heat < 500 then return end
	if meta:get_int("heating_torch") == 1 then
		meta:set_int("heating_torch", 0)
		meta:set_int("heating_torch_done", 1)
		minetest.sound_play("primitive_fire_flint_and_steel",{pos = pointed_thing_pos, gain = 0.5, max_hear_distance = 8})
		player:set_wielded_item("default:torch " .. wielditem:get_count())
	end
	meta:set_int("torch_heat_val", 0)
end)

controls.register_on_release(function(player, key, time)
	local playerName = player:get_player_name()
	local creative = minetest.is_creative_enabled(playerName)
	if (key ~= "RMB" and key ~= "zoom")  then
		return
	end
	local wielditem = player:get_wielded_item()
	local name = wielditem:get_name()
	
	if not (name =="primitive:torch_unlit" or name == "default:torch") then
		return
	end
	local pointed_thing = primitive.get_pointed_thing(player)
	
	local pointed_thing_pos = minetest.get_pointed_thing_position(pointed_thing)
	if not pointed_thing_pos then
		return
	end
	local pointed_node = minetest.get_node(pointed_thing_pos)
	local pointed_node_name = pointed_node.name

	if not (pointed_node_name == "primitive:campfire_active") then
		return
	end
	
	local meta = minetest.get_meta(pointed_thing_pos)
	if meta:get_int("heating_torch_done") == 1 then
		meta:set_int("torch_heat_val", 0)
	end
	meta:set_int("heating_torch_done", 0)
	meta:set_int("heating_torch", 0)
	
end)

minetest.register_globalstep(function()
	for _, player in pairs(minetest.get_connected_players()) do
		local pos           = player:get_pos()
		local node_check = minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z})
		local nc_draw = minetest.registered_nodes[node_check.name].drawtype
		if nc_draw == "liquid" or nc_draw == "flowingliquid" then
			local inv = player:get_inventory()
			local main = inv:get_list("main")
			local found = false
			for _, stack in pairs(main) do
				if stack:get_name() == "default:torch" then
					minetest.log("dousing torch")
					local n = stack:get_count()
					stack:replace("primitive:torch_unlit " .. n)
					found = true
				end
			end
			inv:set_list("main", main)
			local offhand = inv:get_list("offhand")
			if offhand[1]:get_name() == "default:torch" then
				local n = offhand[1]:get_count()
				offhand[1]:replace("primitive:torch_unlit " .. n)
				found = true
			end
			inv:set_list("offhand", offhand)
			if found then
				minetest.sound_play("primitive_torch_douse", {
					pos = pos,
					gain = 0.5,
					max_hear_distance = 5,
				}, true)
			end
		end
	end
end)

for _, item in pairs(minetest.registered_items) do
	if string.match(item.name, "default:torch") then
		minetest.override_item(item.name, {
			on_flood = function(pos, oldnode, newnode)
				local p = minetest.get_node(pos).param2
				minetest.set_node(pos, {name="primitive:torch_extinguished", param2=p})
				minetest.add_item(pos, ItemStack("primitive:torch_extinguished 1"))
				minetest.sound_play("primitive_torch_douse", {
					pos = pos,
					gain = 0.5,
					max_hear_distance = 5,
				}, true)
				return false
			end,
			floodable=true
		})
	end
end
