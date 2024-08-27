primitive = {}

primitive.updateHud = function(meta)
	
	local playerName = meta:get_string("player")
	local player = minetest.get_player_by_name(playerName)
	local drilling = meta:get_int("drilling") == 1
	local lightingTorch =  meta:get_int('torch_heat_val') > 0
	--hb.hide_hudbar(player, "campfire-drilling")
	hb.hide_hudbar(player, "campfire-active")
	hb.hide_hudbar(player, "campfire-cooking")
	hb.hide_hudbar(player, "campfire-torch")
	if drilling then
		hb.unhide_hudbar(player, "campfire-drilling")

		local heat = meta:get_int('heat_val');
		if heat > 20 then 
			heat = 20 
			hb.hide_hudbar(player, "campfire-drilling")
			hb.unhide_hudbar(player, "campfire-active")	
		end

		hb.change_hudbar(player, "campfire-drilling", heat)
	end
	if lightingTorch then

        hb.unhide_hudbar(player, "campfire-torch")

		local heat = meta:get_int('torch_heat_val')
		
		heat = math.min(heat, 500)
		hb.change_hudbar(player, "campfire-torch", heat/5)
	end
	if not drilling and primitive_campfire.limited and primitive_campfire.flames_ttl > 0 then
		local it_val = meta:get_int("it_val");
		if it_val > primitive_campfire.flames_ttl then it_val = primitive_campfire.flames_ttl end
		hb.change_hudbar(player, "campfire-active", it_val/primitive_campfire.flames_ttl*100)
		hb.unhide_hudbar(player, "campfire-active")
	end
	
	local cooked_time = meta:get_int('cooked_time');
	if primitive_campfire.cooking and cooked_time ~= 0 then
		local cooked_cur_time = meta:get_int('cooked_cur_time');
		hb.change_hudbar(player, "campfire-cooking", cooked_cur_time/cooked_time*100)
		hb.unhide_hudbar(player, "campfire-cooking")
	end
end

primitive.get_pointed_thing = function(player)
    local eye_pos = player:get_pos()
    eye_pos.y = eye_pos.y + player:get_properties().eye_height  -- Adjust for the player's eye height

    local look_dir = player:get_look_dir()
    local offset = 0.5  -- Offset to move the start point forward to avoid self-intersection
    local start_pos = vector.add(eye_pos, vector.multiply(look_dir, offset))
    local range = 10  -- Max distance to check for pointed things
    local end_pos = vector.add(start_pos, vector.multiply(look_dir, range))
    local ray = minetest.raycast(start_pos, end_pos, true, true)
    local type = nil
    for pointed_thing in ray do
        if pointed_thing.type == "node" then
			type = "node"
            return pointed_thing, type
        elseif pointed_thing.type == "object" then
            local object = pointed_thing.ref
            if object:is_player() then
				type = "object_player"
                return object, type
            else
				type = "object"
                return object, type
            end
        end
    end
    return nil, nil
end

primitive.table_contains = function(table, element)
	for _, value in pairs(table) do
	  if value == element then
		return true
	  end
	end
	return false
  end