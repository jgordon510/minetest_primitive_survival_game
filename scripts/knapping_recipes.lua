--knapping recipes
knapping.register_recipe({
	input = "primitive:flint",	
	output = "primitive:knife_head",		
	recipe = {
		{0, 0, 0, 1, 0, 0, 0, 0},
		{0, 0, 0, 1, 0, 0, 0, 0},
		{0, 0, 0, 1, 1, 0, 0, 0},
		{0, 0, 0, 1, 1, 0, 0, 0},
		{0, 0, 0, 1, 1, 1, 0, 0},
		{0, 0, 0, 1, 1, 1, 0, 0},
		{0, 0, 0, 1, 1, 1, 0, 0},
		{0, 0, 0, 1, 1, 0, 0, 0}
		},
	texture = "primitive_tech_iron.png", 
})

knapping.register_recipe({
	input = "primitive:flint",		
	output = "primitive:hatchet_head",	
	recipe = {
		{0, 0, 0, 0, 0, 0, 0, 0}, 
		{1, 1, 1, 0, 0, 0, 0, 0}, 
		{1, 1, 1, 1, 1, 1, 1, 0}, 
		{0, 1, 1, 1, 1, 1, 1, 1}, 
		{0, 1, 1, 1, 1, 1, 1, 1}, 
		{1, 1, 1, 1, 1, 1, 1, 0}, 
		{1, 1, 1, 0, 0, 0, 0, 0}, 
		{0, 0, 0, 0, 0, 0, 0, 0}
		},
	texture = "primitive_tech_iron.png", 
})

knapping.register_recipe({
	input = "primitive:flint",	
	output = "primitive:hoe_head",		
	recipe = {
		{0, 0, 0, 0, 0, 0, 0, 0}, 
		{1, 1, 0, 0, 0, 0, 1, 1}, 
		{1, 1, 1, 0, 0, 1, 1, 1}, 
		{1, 1, 1, 1, 1, 1, 1, 1}, 
		{1, 1, 1, 1, 1, 1, 1, 1}, 
		{1, 1, 1, 0, 0, 1, 1, 1}, 
		{1, 1, 0, 0, 0, 0, 1, 1}, 
		{0, 0, 0, 0, 0, 0, 0, 0}
		},
	texture = "primitive_tech_iron.png",
})

knapping.register_recipe({
	input = "primitive:flint",		
	output = "primitive:spear_head",	
	recipe = {
		{0, 0, 0, 0, 1, 0, 0, 0}, 
		{0, 0, 0, 0, 1, 0, 0, 0}, 
		{0, 0, 0, 0, 1, 1, 0, 0}, 
		{0, 0, 0, 0, 1, 1, 0, 0}, 
		{0, 0, 0, 0, 1, 1, 0, 0}, 
		{0, 0, 0, 0, 1, 1, 0, 0}, 
		{0, 0, 0, 0, 1, 1, 1, 0}, 
		{0, 0, 0, 0, 1, 1, 1, 0}
		},
	texture = "primitive_tech_iron.png", 
})

knapping.register_recipe({
	input = "primitive:flint",		
	output = "primitive:shovel_head",		
	recipe = {
		{0, 0, 1, 1, 1, 1, 0, 0}, 
		{0, 1, 1, 1, 1, 1, 1, 0}, 
		{0, 1, 1, 1, 1, 1, 1, 0}, 
		{0, 1, 1, 1, 1, 1, 1, 0}, 
		{0, 1, 1, 1, 1, 1, 1, 0}, 
		{0, 1, 1, 1, 1, 1, 1, 0}, 
		{0, 1, 1, 1, 1, 1, 1, 0}, 
		{0, 1, 1, 1, 1, 1, 1, 0}
		},
	texture = "primitive_tech_iron.png",
})

--knapping recipe outputs
minetest.register_node("primitive:knife_head", {
    description = "Knife Head",
    tiles = {
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.0625, -0.5, -0.4375, 0, -0.4375, 0.4375}, -- NodeBox2
			{0, -0.5, -0.4375, 0.0625, -0.4375, 0.3125}, -- NodeBox3
			{0.0625, -0.5, -0.25, 0.125, -0.4375, 0.1875}, -- NodeBox4
			{0.125, -0.5, -0.25, 0.1875, -0.4375, 0.0625}, -- NodeBox5
			{-0.125, -0.5, -0.25, -0.0625, -0.4375, 0.1875}, -- NodeBox6
			{-0.1875, -0.5, -0.25, -0.125, -0.4375, -0.0625}, -- NodeBox7
		}
	}
})

minetest.register_node("primitive:hatchet_head", {
    description = "Hatchet Head",
    tiles = {
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1875, -0.125, -0.4375, 0.1875}, -- NodeBox6
			{-0.125, -0.5, -0.25, 0.5, -0.4375, 0.25}, -- NodeBox9
		}
	}
})

minetest.register_node("primitive:spear_head", {
    description = "Spear Head",
    tiles = {
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.0625, -0.5, 0.25, 0.0625, -0.4375, 0.5}, -- NodeBox6
			{-0.125, -0.5, -0.1875, 0.125, -0.4375, 0.25}, -- NodeBox10
			{-0.1875, -0.5, -0.5, 0.1875, -0.4375, -0.1875}, -- NodeBox11
		}
	}
})

minetest.register_node("primitive:shovel_head", {
    description = "Shovel Head",
    tiles = {
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.5, -0.5, 0.1875, -0.4375, 0.5}, -- NodeBox3
			{-0.375, -0.5, -0.4375, -0.1875, -0.4375, 0.375}, -- NodeBox4
			{0.1875, -0.5, -0.4375, 0.3125, -0.4375, 0.375}, -- NodeBox5
		}
	}
})

minetest.register_node("primitive:hoe_head", {
    description = "Hoe Head",
    tiles = {
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png",
		"primitive_tech_iron.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1875, -0.125, -0.4375, 0.1875}, -- NodeBox6
			{0.125, -0.5, -0.1875, 0.5, -0.4375, 0.1875}, -- NodeBox7
			{-0.1875, -0.4375, -0.125, 0.1875, -0.375, 0.125}, -- NodeBox8
		}
	}
})