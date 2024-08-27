--functions
local function pos_to_str(pos)
	return pos.x .. ":" .. pos.y .. ":" .. pos.z
end

--leafdrops
minetest.override_item("default:leaves", {
	drop = {
		max_items = 1,
		items = {
			{items = {"default:sapling"}, rarity = 20},
			{items = {"default:stick"}, rarity = 10},
		}
	}
})

minetest.override_item("default:pine_needles", {
	drop = {
		max_items = 1,
		items = {
			{items = {"default:pine_sapling"}, rarity = 20},
			{items = {"default:stick"}, rarity = 10},
		}
	}
})

minetest.override_item("default:aspen_leaves", {
	drop = {
		max_items = 1,
		items = {
			{items = {"default:aspen_sapling"}, rarity = 20},
			{items = {"default:stick"}, rarity = 10},
		}
	}
})

minetest.override_item("default:acacia_leaves", {
	drop = {
		max_items = 1,
		items = {
			{items = {"default:acacia_sapling"}, rarity = 20},
			{items = {"default:stick"}, rarity = 10},
		}
	}
})

minetest.override_item("default:aspen_leaves", {
	drop = {
		max_items = 1,
		items = {
			{items = {"default:aspen_sapling"}, rarity = 20},
			{items = {"default:stick"}, rarity = 10},
		}
	}
})

--note jungle has no _ for some reason
minetest.override_item("default:jungleleaves", { 
	drop = {
		max_items = 1,
		items = {
			{items = {"default:junglesapling"}, rarity = 20},
			{items = {"default:stick"}, rarity = 10},
		}
	}
})


--tree felling
for i, node in pairs(minetest.registered_nodes) do
    if string.match(node.name, "tree") then 
        minetest.override_item(node.name, {
			on_punch =function(pos, node, puncher, pointed_thing)
				local checked = {}
				local parts = {}
				--the tree parts starting with the trunk
				parts[pos_to_str(pos)] = {name = node.name, pos = pos}
				table.insert(checked, table.copy(pos))
				local found = 0
				local oPos = pos
				local meta = minetest.get_meta(pos)
				--this recursive function travels upward on the trunk
				--at each level it checks up to 3 blocks away in the x/z direction from the trunk
				--teach time it finds a tree it adds it to the parts list for a max of 250 parts
				local function trace(pos)
					for x = -1, 1 do
						for y = 0, 1 do
							for z = -1, 1 do
								local checkPos = {x=pos.x+x, y=pos.y+y, z=pos.z+z}
								local over = math.abs(checkPos.x-oPos.x) < 3 and math.abs(checkPos.z-oPos.z) < 3
								if not checked[pos_to_str(checkPos)] and found < 250 and over then
									checked[pos_to_str(checkPos)] = true
									local check = minetest.get_node(checkPos)
									if string.match(check.name, "tree") then
										found = found + 1
										parts[pos_to_str(checkPos)] = {name = check.name, pos = checkPos}
										trace(checkPos)
									end
								end
								
							end
						end
					end
				end
				
				--trace adds all the connected parts to the parts table
				trace(pos)
				
				--replace the parts with harder parts based on the quant of parts
				for i, node in pairs(parts) do
					local pos = node.pos
					local shortName = (node.name):gsub("default:", "")
					shortName = (shortName):gsub("primitive:", "")
					for level  = 10, 1, -1 do
						shortName = (shortName):gsub("_hard_" .. level, "")
					end
       				local name = "primitive:" .. shortName
					local level = math.floor(found/2)
					if level <=2 then
						level = 0
					elseif level > 10 then
						level = 10
					end
					if level > 0 then
						--debounced
						if not meta:get_string("swapped_hardness") then
							meta:set_string("swapped_hardness", true)
							--store the original_name for the inventory later
							meta:set_string("original_name", node.name) 
						end
						name = name .. "_hard_" .. level
						minetest.swap_node(pos, { name = name })
					end
					
				end
				
				--minetest.log("found to chop: ".. tostring(found))
				--package the parts for later in on_dig
				meta:set_string("connected_parts", minetest.serialize(parts))
				
			end,

            on_dig = function(pos, node, digger)
				local meta = minetest.get_meta(pos)
				local orig_name = meta:get_string("original_name")
				--get the parts back out
				local parts = minetest.deserialize(meta:get_string("connected_parts"))
				local y = pos.y
				
				local count = 0
				for i, data in pairs(parts) do
					count=count+1
					local pos = data.pos
					--animate the action upwards
					minetest.after(0.3*(pos.y-y), function()
						--this applies the node drop rate
						minetest.handle_node_drops(pos, {orig_name}, digger)
						--this applies tool wear
						minetest.node_dig(pos, node, digger)
					end)
				end
				--play a long or short tree falling sound
				local sound = "tree_drops_tree_falling"
				if count <=4 then
					sound = "tree_drops_tree_falling_short"
				end
				if count >1 then
					minetest.sound_play(sound, {
						pos = pos,
						gain = 1.0,
						max_hear_distance = 5,
					})
				end
				return false
			end
        })
    end
end