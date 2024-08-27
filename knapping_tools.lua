minetest.register_tool("primitive:knife", {
	description = "Stone Knife",
	inventory_image = "knife.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			grass={times={[1]=6 }, uses=20, maxlevel=1},
			dry_grass={times={[1]=6 }, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=2},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1},
})

local hatchet_times = {}
for i = 3, 15 do
	hatchet_times[i] = 4 + (15-i)*1
end
minetest.register_tool("primitive:hatchet", {
	description = "Stone Hatchet",
	inventory_image = "hatchet.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			choppy={times=hatchet_times, uses=50, maxlevel=0	},
		},
		damage_groups = {choppy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {axe = 1},
})

minetest.register_tool("primitive:hoe", {
	description = "Stone Hoe",
	inventory_image = "hoe.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.4, [3]=0.40}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=4}, --todo add damage groups for all stone tools?
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {hoe = 1},
})

minetest.register_tool("primitive:spear", {
	description = "Stone Spear",
	inventory_image = "spear.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.4, [3]=0.40}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {spear = 1},
})

minetest.register_tool("primitive:shovel", {
	description = "Stone Shovel",
	inventory_image = "shovel.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			crumbly={times={[4]=5.4}, uses=20, maxlevel=4},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {shovel = 1},
})

minetest.register_tool("primitive:bowdrill", {
	description = "Bow Drill",
	inventory_image = "bowdrill.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			snappy={times={[4]=5.4}, uses=20, maxlevel=4},
		},
		damage_groups = {fleshy=1},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {bowdrill = 1},
})

minetest.register_craft({
    type = "shaped",
    output = "primitive:bowdrill",
    recipe = {
        {'group:stick', 'group:stick', 'group:stick'},
        {"group:grass", 'group:stick', "group:grass"},
		{"", "primitive:flint", ""},
    }
})

minetest.register_craft({
    type = "shaped",
    output = "primitive:knife",
    recipe = {
        {"primitive:knife_head"},
        {"default:stick"}
    }
})
minetest.register_craft({
    type = "shaped",
    output = "primitive:spear",
    recipe = {
        {"primitive:spear_head"},
        {"default:stick"}
    }
})
minetest.register_craft({
    type = "shaped",
    output = "primitive:hatchet",
    recipe = {
        {"primitive:hatchet_head"},
        {"default:stick"}
    }
})
minetest.register_craft({
    type = "shaped",
    output = "primitive:hoe",
    recipe = {
        {"primitive:hoe_head"},
        {"default:stick"}
    }
})
minetest.register_craft({
    type = "shaped",
    output = "primitive:shovel",
    recipe = {
        {"primitive:shovel_head"},
        {"default:stick"}
    }
})