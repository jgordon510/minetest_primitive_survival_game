minetest.log("decorations")
minetest.register_node("primitive:flint",{
	tiles = {"primitive_tech_iron.png"},
	description = "Flint",
	pointable = true,
	diggable = true,
	groups = {oddly_breakable_by_hand = 1, cracky = 1, falling_node = 1},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.1875, 0.125, -0.375, 0.1875}, -- NodeBox1
			{-0.25, -0.5, -0.25, 0.0625, -0.4375, 0.125}, -- NodeBox2
			{-0.125, -0.5, -0.0625, 0.1875, -0.4375, 0.25}, -- NodeBox3
		}
	}
})


local cbox = {
	type = "fixed",
	fixed = {-5/16, -8/16, -6/16, 5/16, -1/32, 5/16},
}
minetest.register_node("primitive:coal",{
	tiles = {"default_coal_block.png"},
	description = "Coal",
	pointable = true,
	diggable = true,
	groups = {oddly_breakable_by_hand = 1, cracky = 1, falling_node = 1, not_in_creative_inventory = 1},
	drawtype = "mesh",
	paramtype = "light",
	drop = 'default:coal_lump',
	mesh = "primitive_rock_piles_large_1.obj",
	paramtype2 = "facedir",
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5},
	},
	collision_box = cbox,
	sunlight_propagates = true
})

minetest.register_node("primitive:copper",{
	tiles = {"default_copper_block.png"},
	description = "Copper",
	pointable = true,
	diggable = true,
	groups = {oddly_breakable_by_hand = 1, cracky = 1, falling_node = 1, not_in_creative_inventory = 1},
	drawtype = "mesh",
	paramtype = "light",
	drop = 'default:copper_lump',
	mesh = "primitive_rock_piles_medium_1.obj",
	paramtype2 = "facedir",
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5},
	},
	collision_box = cbox,
	sunlight_propagates = true
})

minetest.register_node("primitive:tin",{
	tiles = {"default_tin_block.png"},
	description = "Tin",
	pointable = true,
	diggable = true,
	groups = {oddly_breakable_by_hand = 1, cracky = 1, falling_node = 1, not_in_creative_inventory = 1},
	drawtype = "mesh",
	paramtype = "light",
	drop = 'default:tin_lump',
	mesh = "primitive_rock_piles_small_1.obj",
	paramtype2 = "facedir",
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5},
	},
	collision_box = cbox,
	sunlight_propagates = true
})




local flint_place_on = {"default:permafrost","default:permafrost_with_stones","default:permafrost_with_moss","default:desert_sand"}
for i, node in pairs(minetest.registered_nodes) do
    if string.match(node.name, "dirt") then 
        table.insert(flint_place_on, node.name)
    end
end

minetest.register_decoration({
    deco_type = "simple",
    place_on = flint_place_on,
    biomes = minetest.registered_biomes,
	sidelen = 80,
    --fill_ratio = 0.0025,
	noise_params = {
		offset = 0,
		scale = 0.00125,  --0.0028125,
		spread = {
			y = 25,
			z = 25,
			x = 25
		},
		seed = 0,
		octaves = 6,  --9
		persist = 0.9,
		flags = "absvalue",
		lacunarity = 10
	},
    y_max = 200,
    y_min = 1,
    decoration = "primitive:flint",
})

minetest.register_decoration({
    deco_type = "simple",
    place_on = flint_place_on,
    biomes = minetest.registered_biomes,
	sidelen = 80,
    fill_ratio = 0.00025,
    y_max = 200,
    y_min = 1,
    decoration = "primitive:coal",
})

local stoneNodes = {}
for i, node in pairs(minetest.registered_nodes) do
	if string.match(node.name, "stone") then
		table.insert(stoneNodes, node.name)
	end
end

minetest.register_decoration({
    deco_type = "simple",
    place_on = {"default:stone_with_coal"}, --stoneNodes,
	sidelen = 80,
	noise_params = {
		offset = 0,
		scale = 0.4,  --0.0028125,
		spread = {
			y = 25,
			z = 25,
			x = 25
		},
		seed = 0,
		octaves = 6,  --9
		persist = 0.9,
		flags = "absvalue",
		lacunarity = 10
	},
	--fill_ratio = 0.90025,
    decoration = "primitive:coal",
	flags = "all_floors",
	param2 = 0,
	param2_max = 3,
	y_min = -80, --  -16
	y_max = -5  -- 48
})

minetest.register_decoration({
    deco_type = "simple",
    place_on = stoneNodes,
	sidelen = 80,
	noise_params = {
		offset = 0,
		scale = 0.005,  --0.0028125,
		spread = {
			y = 25,
			z = 25,
			x = 25
		},
		seed = 0,
		octaves = 6,  --9
		persist = 0.9,
		flags = "absvalue",
		lacunarity = 10
	},
	--fill_ratio = 0.90025,
    decoration = "primitive:copper",
	flags = "all_floors",
	param2 = 0,
	param2_max = 3,
	y_min = -80, --  -16
	y_max = -10  -- 48
})

minetest.register_decoration({
    deco_type = "simple",
    place_on = stoneNodes,
	sidelen = 80,
	noise_params = {
		offset = 0,
		scale = 0.01,  --0.0028125,
		spread = {
			y = 25,
			z = 25,
			x = 25
		},
		seed = 0,
		octaves = 6,  --9
		persist = 0.9,
		flags = "absvalue",
		lacunarity = 10
	},
	--fill_ratio = 0.90025,
    decoration = "primitive:tin",
	flags = "all_floors",
	param2 = 0,
	param2_max = 3,
	y_min = -120, --  -16
	y_max = -30  -- 48
})