--todo credit the author
local YAW_OFFSET = -math.pi/2
throwing = {}

throwing.throws = {}

throwing.target_object = 1
throwing.target_node = 2
throwing.target_both = 3
throwing.realistic_trajectory = true

throwing.modname = minetest.get_current_modname()
local S = minetest.get_translator("throwing")



mcl_fovapi.register_modifier({
	name = "throwcomplete",
	fov_factor = 0.7,
	time = 1,
	reset_time = 0.3,
	is_multiplier = true,
})

controls.register_on_hold(function(player, key, time)
	local name = player:get_player_name()
	local creative = minetest.is_creative_enabled(name)
	if (key ~= "RMB" and key ~= "zoom")  then
		return
	end
	local wielditem = player:get_wielded_item()
	local name = wielditem:get_name()
	
	if not (name =="primitive:flint" or name =="primitive:spear") then
		return
	end
	mcl_fovapi.apply_modifier(player, "throwcomplete")
	local hud_flags = player:hud_get_flags()
	hud_flags.wielditem = false
	player:hud_set_flags(hud_flags)
end)

controls.register_on_release(function(player, key, time)
	local hud_flags = player:hud_get_flags()
	hud_flags.wielditem = true
	player:hud_set_flags(hud_flags)
	if key~="RMB" and key~="zoom" then return end
	local wielditem = player:get_wielded_item()
	local name = wielditem:get_name()
	if not (name =="primitive:flint" or name =="primitive:spear") then
		return
	end
	mcl_fovapi.remove_modifier(player, "throwcomplete")
	local elapsed = time
	if not elapsed or elapsed < 0.2 then
		return
	end
	if elapsed > 1 then
		elapsed = 2
	end

	local def = {
		strength = elapsed/2,
	}
	launch_throw(def, {}, player, player:get_wield_index(), true, nil)
	wielditem.take_item(wielditem, 1)
	minetest.after(0.1, function()
		player:set_wielded_item(wielditem)
	end)
	
end)

--------- throws functions ---------
function throwing.is_throw(itemstack)
	return throwing.throws[ItemStack(itemstack):get_name()]
end

local function dir_to_pitch(dir)
	--local dir2 = vector.normalize(dir)
	local xz = math.abs(dir.x) + math.abs(dir.z)
	return -math.atan2(-dir.y, xz)
end

function throwing.spawn_throw_entity(pos, throw, player)
	return minetest.add_entity(pos, "__builtin:item", throw)
end

local function apply_realistic_acceleration(obj, mass)
	if not minetest.settings:get_bool("throwing.realistic_trajectory", false) then
		return
	end

	local vertical_acceleration = tonumber(minetest.settings:get("throwing.vertical_acceleration")) or -10
	local friction_coef = tonumber(minetest.settings:get("throwing.frictional_coefficient")) or -3

	local velocity = obj:get_velocity()
	obj:set_acceleration({
		x = friction_coef * velocity.x / mass,
		y = friction_coef * velocity.y / mass + vertical_acceleration,
		z = friction_coef * velocity.z / mass
	})
end

function launch_throw(def, toolranks_data, player, bow_index, throw_itself, new_stack)
	local inventory = player:get_inventory()
	local throw_index
	throw_index = bow_index --throw_itself
	
	local throw_stack = inventory:get_stack("main", throw_index)
	local throw = throw_stack:get_name()

	local playerpos = player:get_pos()
	local pos = {x=playerpos.x, y=playerpos.y+1.5, z=playerpos.z}
	local obj = (def.spawn_throw_entity or throwing.spawn_throw_entity)(pos, throw, player)
	
	local luaentity = obj:get_luaentity()

	-- Set custom data in the entity
	luaentity.player = player:get_player_name()
	if not luaentity.item then
		luaentity.item = throw
	end
	luaentity.data = {}
	luaentity.timer = 0

	luaentity.on_step = throwing.throw_step
	luaentity.on_hit = function (self, pos, last_pos, node, obj, hitter, data) 
		if obj ~= nil and obj:get_hp() > 0 and obj:get_luaentity() then
			local damage = 2
			if throw == "primitive:spear" then
				damage = 4
			end
			obj:punch(player, 1.0, {
				--full_punch_interval=1.0,
				damage_groups={fleshy=damage},
			}, self.object:get_velocity())
		end
		luaentity.on_step = nil
	end

	local dir = player:get_look_dir()
	local vertical_acceleration = tonumber(minetest.settings:get("throwing.vertical_acceleration")) or -10
	local velocity_factor = tonumber(minetest.settings:get("throwing.velocity_factor")) or 19
	local velocity_mode = minetest.settings:get("throwing.velocity_mode") or "strength"

	local velocity
	if velocity_mode == "simple" then
		velocity = velocity_factor
	elseif velocity_mode == "momentum" then
		velocity = def.strength * velocity_factor / luaentity.mass
	else
		velocity = def.strength * velocity_factor
	end

	obj:set_velocity({
		x = dir.x * velocity,
		y = dir.y * velocity,
		z = dir.z * velocity
	})
	obj:set_acceleration({x = 0, y = vertical_acceleration, z = 0})
	obj:set_yaw(player:get_look_horizontal()-math.pi/2)
	
	

	apply_realistic_acceleration(obj, luaentity.mass)

	if luaentity.on_throw_sound ~= "" then
		minetest.sound_play(luaentity.on_throw_sound or "throwing_sound", {pos=playerpos, gain = 0.5})
	end

	if not minetest.settings:get_bool("creative_mode") then
		--inventory:set_stack("main", throw_index, new_stack)
	end
	return true
end

function throwing.throw_step(self, dtime)
	local obj = self.object
	
	if self.item == "primitive:spear" then
		local yaw = minetest.dir_to_yaw(obj:get_velocity())+YAW_OFFSET
		local pitch = dir_to_pitch(obj:get_velocity()) - 3.14/2
		obj:set_rotation({ x = 0, y = yaw, z = pitch })
	else
		local rot = obj:get_rotation()
		obj:set_rotation({ x = rot.x, y = rot.y, z = rot.z+0.15 })
	end
	

	if not self.timer or not self.player then
		return
	end
	
	self.timer = self.timer + dtime


	local pos = self.object:get_pos()
	local logging = function(message, level)
		minetest.log(level or "action", "[throwing] throw "..(self.item or self.name).." throwed by player "..self.player.." "..tostring(self.timer).."s ago "..message)
	end
	
	local hit = function(pos1, node1, obj)
		--logging = minetest.log
		if obj then
			if obj:is_player() then
				if obj:get_player_name() == self.player then -- Avoid hitting the hitter
					logging("Avoid hitting the hitter")
					return false
				end
			end
		end

		local player = minetest.get_player_by_name(self.player)
		if not player then -- Possible if the player disconnected
			logging("Possible if the player disconnected")
			return
		end

		local function hit_failed()
			if not minetest.settings:get_bool("creative_mode") and self.item then
				player:get_inventory():add_item("main", self.item)
			end
			if self.on_hit_fails then
				self:on_hit_fails(pos1, player, self.data)
			end
		end

		if not self.last_pos then
			logging("hitted a node during its first call to the step function")
			hit_failed()
			return
		end

		if node1 and minetest.is_protected(pos1, self.player) and not self.allow_protected then -- Forbid hitting nodes in protected areas
			minetest.record_protection_violation(pos1, self.player)
			logging("hitted a node into a protected area")
			return
		end
		
		if self.on_hit then
			local ret, reason = self:on_hit(pos1, self.last_pos, node1, obj, player, self.data)
			if ret == false then
				if reason then
					logging(": on_hit function failed for reason: "..reason)
				else
					logging(": on_hit function failed")
				end

				hit_failed()
				return
			end
		end

		if self.on_hit_sound then
			minetest.sound_play(self.on_hit_sound, {pos = pos1, gain = 0.8})
		end

		local identifier
		if node1 then
			identifier = "node " .. node1.name
		elseif obj then
			if obj:get_luaentity() then
				identifier = "luaentity " .. obj:get_luaentity().name
			elseif obj:is_player() then
				identifier = "player " .. obj:get_player_name()
			else
				identifier = "unknown object"
			end
		end
		if identifier then
			logging("collided with " .. identifier .. " at " .. minetest.pos_to_string(pos1) .. ")")
		end

	end
	
	-- Collision with an object

	local objs = minetest.get_objects_inside_radius(pos, 2)
	for k, obj in pairs(objs) do
		if obj:get_luaentity() then
			--ignore my own entity
			if obj:get_luaentity().name ~= self.name and obj:get_luaentity().name ~= "__builtin:item" then
				hit(pos, nil, obj)
			end
		else
			hit(pos, nil, obj)
		end
	end
	
	-- Collision with a node
	local node1 = minetest.get_node(pos)
	if node1.name == "ignore" then
		self.object:remove()
		logging("reached ignore. Removing.")
		return
	elseif (minetest.registered_items[node1.name] or {}).drawtype ~= "airlike" then
		if self.target ~= throwing.target_object then -- throwing.target_both, nil, throwing.target_node, or any invalid value
			hit(pos, node1, nil)
		end
		return
	end

	apply_realistic_acceleration(self.object, self.mass) -- Physics: air friction

	self.last_pos = pos -- Used by the build throw
end