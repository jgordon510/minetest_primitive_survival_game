-- This is based on the mod by Skamiz
-- codeAtorium changed the behavior of the knapping so that it will remove any pieces
-- not connected to the main tool
-- this is achieved with a flood fill algorithm
minetest.log("knapping api loading...")
local modname = minetest.get_current_modname()

local S = minetest.get_translator("primitive")

-- time after which the knapping proccess gets aborted,
-- to prevent players from cluttering a world with thousands of entities
local TIMEOUT = tonumber(minetest.settings:get("knapping_timeout")) or 300

-- how many knapping proccesses can run simultaneously,
-- again, to prevent players from cluttering a world with entities
local MAX_CRAFTS = tonumber(minetest.settings:get("knapping_max_crafts")) or 25

knapping = {}
local registered_recipes = {}
local registered_callbacks = {}
local crafting_processes = {}

local fallback_texture = "primitive_knapping_stone.png"
local initial_properties = {
	visual = "cube",
	collisionbox = {-0.5/8, -0.5/8, -0.5/8, 0.5/8, 0.5/8, 0.5/8},
	textures = {fallback_texture, fallback_texture, fallback_texture,
			fallback_texture, fallback_texture, fallback_texture},
	visual_size = {x = 1/8, y = 1/8, z = 1/8},
	physical = false,
	static_save = false,
}
minetest.register_entity(modname .. ":stone_piece_go", {
	initial_properties = initial_properties,
	on_punch = function(self, puncher)
		if puncher:get_wielded_item():get_name() ~= self.material then return end
		self.get_removed()
		self.object:remove()
		minetest.sound_play("primitive_thunk", {gain = 0.3, to_player = puncher:get_player_name()}, true)
	end,
})

minetest.register_entity(modname .. ":stone_piece", {
	initial_properties = initial_properties,
})

local function get_empty_slot(t)
	local i = 1
	while t[i] do
		i = i + 1
	end
	return i
end
local function clear_craft(id, cp_table)

	-- first check if this crafting proccess even stil exists
	if not crafting_processes[id] then return end
	if cp_table and crafting_processes[id] ~= cp_table then	return end

	if cp_table and crafting_processes[id] == cp_table then
		minetest.chat_send_player(cp_table.player, S("The knapping proccess you started at: @1 crumbled away due to time.", minetest.pos_to_string(cp_table.pos)))
	end

	local pos = crafting_processes[id].pos
	local bits = minetest.get_objects_inside_radius(pos, 1)
	for _, v in pairs(bits) do
		if not v:is_player() and v:get_luaentity().id == id then
			v:remove()
		end
	end
	crafting_processes[id] = nil
end

local function finish_craft(id)
	if not crafting_processes[id] then
		return
	end
	crafting_processes[id].finished = true
	print("final id" .. tostring(id))
	print(dump(crafting_processes[id].pos))
	local pos = crafting_processes[id].pos
	minetest.add_item(pos, crafting_processes[id].recipe.output)
	for _, func in pairs(registered_callbacks) do
		func(recipe, pos, crafting_processes[id].player)
	end
	clear_craft(id)
end

local function printMap(id)
	local node_pos = crafting_processes[id].pos
	local meta = minetest.get_meta(node_pos)
	local data = minetest.deserialize(meta:get_string("knap_map"))
	local n = 0
	for x=1,8 do
		local row = ""
		for z=1,8 do
			n = n+1
			row  = row .. tostring(data[n])
		end
		minetest.log(row)
	end
end

local function checkConnections(map, id, entTable, craftID, meta)
	if not map[id] then
		return
	end
	-- if entTable[id] then 
	-- 	entTable[id].object:remove()
	-- end
	-- if true then
	-- 	return
	-- end
	local q = {}
	local checked = {}
	table.insert(q, id)
	checked[id] = true
	
	local found = false
	while(#q > 0 ) do
		local id = table.remove(q, 1)
		local n = map[id]
		if n == 1 then
			found = true
		end
		if n== 0 then
			if not checked[id-1] and (id-1)%8>0 and map[id-1] then
				checked[id-1] = true
				table.insert(q, id-1)
			end
			if not checked[id+1] and (id-1)%8<7 and map[id+1] then
				checked[id+1] = true
				table.insert(q, id+1)
			end
			if not checked[id+8] and id < 57 then
				checked[id+8] = true
				table.insert(q, id+8)
			end
			if not checked[id-8] and id>8 then
				checked[id-8] = true
				table.insert(q, id-8)
			end
		end
		
	end
	if not found then
		for id, state in pairs(checked) do
			if(entTable[id]) then
				entTable[id].object:remove()
			else
				-- minetest.log("bad id: " .. id)
			end
			
			map[id] = "X"
		end
	end
	meta:set_string("knap_map", minetest.serialize(map))
	local done = true
	for id, n in pairs(map) do
		if n == 0 then
			done = false
		end
	end
	if done then
		finish_craft(craftID)
	end
	--printMap(craftID)
end





local function place_knapping_plane(id, player_name)
	local recipe = crafting_processes[id].recipe
	local node_pos = crafting_processes[id].pos
	local meta = minetest.get_meta(node_pos)
	local start_pos = vector.add(node_pos, -7/16)

	-- instead of matching the inworld patern to the recipe, we just count up
	-- how many diggable pieces there are and finnish once they are gone
	local to_remove = 0
	local n = 0
	local entTable = {}
	for x=1,8 do
		for z=1,8 do
			local data = minetest.deserialize(meta:get_string("knap_map"))
			n = n+1
			data[n] = recipe.recipe[x][z]
			meta:set_string("knap_map", minetest.serialize(data))
			local pos = {x=start_pos.x + (1/8) * (x-1), y=start_pos.y, z=start_pos.z+ (1/8) * (z-1)}

			local texture = recipe.texture and recipe.texture .. "^[sheet:8x8:" .. x-1 .. "," .. 8-z or "primitive_knapping_stone.png"

			if recipe.recipe[x][z] == 1 then
				local objref = minetest.add_entity(pos, modname .. ":stone_piece")
				objref:set_properties({textures = {texture, texture, texture, texture, texture, texture}})

				local luaent = objref:get_luaentity()
				--used during cleanup so recipes in adjenced nodes don't get messed up
				luaent.id = id
				
			else
				to_remove = to_remove + 1
				local objref = minetest.add_entity(pos, modname .. ":stone_piece_go")
				texture = texture .. "^[multiply:#b0b0b0" -- darken texture to distinguish the patern
				objref:set_properties({textures = {texture, texture, texture, texture, texture, texture}})

				local luaent = objref:get_luaentity()
				luaent.id = id
				luaent.n = n
				luaent.material = recipe.input
				entTable[n] = luaent
				luaent.get_removed = function()
					local n = luaent.n
					minetest.log(n)
					to_remove = to_remove - 1
					local data = minetest.deserialize(meta:get_string("knap_map"))
					data[n] = 'X'
					meta:set_string("knap_map", minetest.serialize(data))
					
					if (n-1)%8 > 0 then
						checkConnections(data, luaent.n - 1, entTable, id, meta)
					end
					if (n-1)%8 < 7 then
						checkConnections(data, luaent.n + 1, entTable, id, meta)
					end
					checkConnections(data, luaent.n - 8, entTable, id, meta)
					checkConnections(data, luaent.n + 8, entTable, id, meta)
					--printMap(id)
					
					if to_remove == 0 then
						--finish_craft(id)
					end
				end
			end
		end
	end



	
	-- so the map doesn't get cluttered, this isn't supposed to be a permanent decoration afterall
	minetest.after(TIMEOUT, clear_craft, id, crafting_processes[id])
end

local function get_knapping_formspec(itemname, pos)
	local spos = minetest.pos_to_string(pos)
	local recipes = registered_recipes[itemname]
	local formspec = {}
		formspec[#formspec + 1] = "size["
		formspec[#formspec + 1] = #recipes
		formspec[#formspec + 1] = ",1]"

	local x = 0
	for _, v in pairs(recipes) do
		formspec[#formspec + 1] = "item_image_button["
		formspec[#formspec + 1] = x
		formspec[#formspec + 1] = ",0.125;1,1;"
		formspec[#formspec + 1] = v.output
		formspec[#formspec + 1] = ";"
		-- is there a a way to avoid passing the position through the formspec?
		formspec[#formspec + 1] = itemname .. "|" .. v.output .. "|" .. spos
		formspec[#formspec + 1] = ";]"
		x = x + 1
	end

	return table.concat(formspec)
end

local function handle_input(player, formname, fields)
	minetest.log("handle input")
	if formname ~= "primitive:choose_recipe" then return end
	if fields.quit then return end

	local player_name = player:get_player_name()

	for k, v in pairs(fields) do
		if v then
			local a = k:find("|")
			local b = k:find("|", a+1)
			local itemname, output, pos = k:sub(1, a-1), k:sub(a+1,b-1), minetest.string_to_pos(k:sub(b+1,-1))
			local recipe
			for _, v in pairs(registered_recipes[itemname]) do
				if v.output == output then recipe = v end
			end

			minetest.close_formspec(player_name, formname)

			local id = get_empty_slot(crafting_processes)
			
			if id > MAX_CRAFTS then
				minetest.chat_send_player(player_name, S("There are too many knapping proccesses going on at once."))
				minetest.chat_send_player(player_name, S("Try again in a few minutes."))
				return true
			end

			crafting_processes[id] = {
				pos = pos,
				recipe = recipe,
				player = player_name,
			}

			--my stuff
			local node_pos = crafting_processes[id].pos
			local meta = minetest.get_meta(node_pos)
			local data = {  }
			meta:set_string("knap_map", minetest.serialize(data))
			
			place_knapping_plane(id, player_name)

			local data = minetest.deserialize(meta:get_string("knap_map"))

			
			-- remove input item if not creative
			if not minetest.settings:get_bool("creative_mode") and
					not minetest.check_player_privs(player_name, {creative = true}) then
				local itemstack = player:get_wielded_item()
				itemstack:take_item()
				player:set_wielded_item(itemstack)
			end
		end
	end
	return true
end
minetest.register_on_player_receive_fields(handle_input)

local function can_knapp(placer, pointed_thing)
	if pointed_thing.under.y ~= pointed_thing.above.y-1 then return false end
	if minetest.get_node(pointed_thing.above).name ~= "air" then return false end
	if minetest.registered_nodes[minetest.get_node(pointed_thing.under).name].walkable ~= true then return false end
	if not placer:get_player_control().sneak then return false end
	return true
end

local function add_knapping(itemname)
	assert(minetest.registered_items[itemname], "Trying to register a knapping recipe using the nonexistent item: '" .. itemname .. "'")
	local og_on_place = minetest.registered_items[itemname].on_place
	minetest.override_item(itemname, {
		description = minetest.registered_items[itemname].description ..
				minetest.colorize("#ababab", "\n" .. S("Use on the top of a surface while sneaking to start knapping.")),
		on_place = function(itemstack, placer, pointed_thing)
			if can_knapp(placer, pointed_thing) then
				minetest.show_formspec(placer:get_player_name(), "primitive:choose_recipe", get_knapping_formspec(itemname, pointed_thing.above))
			else
				return og_on_place(itemstack, placer, pointed_thing)
			end
		end,
	})
end

function knapping.register_on_craft(func)
	assert(type(func) == "function", "'register_on_craft' expects a function, got: '" .. type(func) .. "'")
	table.insert(registered_callbacks, func)
end

function knapping.register_recipe(recipe)
	if not registered_recipes[recipe.input] then
		registered_recipes[recipe.input] = {}
		add_knapping(recipe.input)
	end
	table.insert(registered_recipes[recipe.input], recipe)
end
