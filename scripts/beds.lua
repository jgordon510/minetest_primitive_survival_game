--test
local S = minetest.get_translator("primitive")
beds.register_bed("primitive:straw_bed", {
	description = S("Straw Bed"),
	inventory_image = "beds_bed.png", --todo make an inventory_image
	wield_image = "beds_bed.png",
	tiles = {
		bottom = {
			"primitive_beds_straw_bed.png",
		},
		top = {
			"primitive_beds_straw_bed.png",
		}
	},
	nodebox = {
		bottom ={-0.5, -0.5, -0.5, 0.5, -0.1875, 0.5}, -- box
        top ={-0.5, -0.5, -0.5, 0.5, -0.1875, 0.5}, -- box
	},
	selectionbox = {-0.5, -0.5, -0.5, 0.5, -0.1875, 1.5},
	recipe = {
        {"group:grass", "group:grass", "group:grass"}
    }
})