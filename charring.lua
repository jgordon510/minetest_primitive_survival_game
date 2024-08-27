--a charred version of every meat
local meats = {"beef", "mutton", "porkchop" , "poultry", "rat", "venison"}
for i, meat in pairs(meats) do
	local name = "primitive:" .. meat .. "_charred"
	local eats = {}
	eats.beef = 4
	eats.mutton = 3
	eats.porkchop = 3
	eats.poultry = 2
	eats.venison = 5
	eats.rat = 1

	local cookedItem = minetest.registered_items["animalia:" .. meat .. "_cooked"]
	
	local def = table.copy(cookedItem)
	def.description = def.description .. " (charred)"
	def.inventory_image = "survival_campfire_" .. meat .. "_charred.png"
	def.on_use = minetest.item_eat(eats[meat])
	local charredName = "primitive:" .. meat .. "_charred"
	minetest.register_craftitem(charredName, def)
	
	minetest.register_craft({
		type = "cooking",
		output = charredName,
		recipe = name,
		cooktime = 10,
	})
	
end


--override charring recipes to give charred versions of meat
local old_get_craft_result = minetest.get_craft_result
minetest.get_craft_result = old_get_craft_result
minetest.get_craft_result = function(input)
	local result1, result2 = old_get_craft_result(input)
	if input.method == "charring" then
		local name = input.items[1]:get_name()
		name = string.gsub(name, "animalia", "survival_campfire", 1)
		name = string.gsub(name, "raw", "charred", 1)
		result1.item = ItemStack(name)
		result1.time = 10
	end
	return result1, result2
end