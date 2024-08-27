--grass only drops when cut with a knife
for name, item in pairs(minetest.registered_items) do
	if string.match(name, "grass") then
		local dropName = item.drop
		if not dropName or dropName == "" then
			dropName = name
		end
		local quant = tonumber(string.sub(name, -1))
		if quant == 1 then
			quant = 0
		elseif not quant then
			quant = 1
		else
			math.randomseed(os.time())
			quant = math.random(1, quant)
		end
		minetest.override_item(name, {
			drop = '',
			on_dig = function(pos, node, digger, ...)
				if( digger:get_wielded_item():get_name()== "primitive:knife") then minetest.handle_node_drops(pos, {dropName .. " " .. quant}, digger) end
				return minetest.node_dig(pos, node, digger, ...)
			end
		})
	end
end