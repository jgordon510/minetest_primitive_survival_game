local LIGHT_LEVEL_TO_STOP_PURSUIT = 7
local NIGHT_MAX  = 0.25
local NIGHT_MIN = 0.85
local DAY_TRACKING_RANGE = 10
local NIGHT_TRACKING_RANGE = 30
local PURSUIT_MAX_SPEED = 8
local PURSUIT_SPEED_UP = 3
local FLEE_AT_HEALTH = 0.2
local WOLF_BASE_SPEED = 6
--vector stuff for stuff
local vec_add, vec_dir, vec_dist, vec_divide, vec_len, vec_multi, vec_normal,
	vec_round, vec_sub = vector.add, vector.direction, vector.distance, vector.divide,
	vector.length, vector.multiply, vector.normalize, vector.round, vector.subtract

--functions

--used to check enemylist
local function is_value_in_table(tbl, val)
	for _, v in pairs(tbl) do
		if v == val then
			return true
		end
	end
	return false
end

--this 
function on_punch(self, puncher, ...)

    creatura.basic_punch_func(self, puncher, ...)
     --flee at FLEE_AT health
     if self.hp/self.max_health < FLEE_AT_HEALTH then
        self._puncher = puncher
        return --early exit
    end
    --attack otherwise
    local name = puncher:is_player() and puncher:get_player_name() --this is opaque todo: clear it up
    if name then
        --unchanged logic
        self.enemies = self.enemies or {}
        if self.owner
        and name == self.owner then
            return
        elseif not is_value_in_table(self.enemies, name) then
            table.insert(self.enemies, name)
            if #self.enemies > 15 then
                table.remove(self.enemies, 1)
            end
            self.enemies = self:memorize("enemies", self.enemies)
        else
            table.remove(self.enemies, 1)
            table.insert(self.enemies, name)
            self.enemies = self:memorize("enemies", self.enemies)
        end
        --speed up when punched; debounced and limited
        if not self.sped_up and self.speed < PURSUIT_MAX_SPEED then
            self.sped_up = true
            self.speed = self.speed + PURSUIT_SPEED_UP
        end
    end
    --attack until FLEE_AT health
    self._target = puncher
end

--give attack behavior to all animals
local names = {"bat", "cat", "chicken", "cow", "horse", "opossum", "owl", "pig", "reindeer", "sheep", "turkey"}
for i, name in pairs(names) do
    local entName = "animalia:" .. name
    local def = minetest.registered_entities[entName]
    assert(def, entName .. " not found")
    def.flee_puncher = true --puncher only gets set at FLEE_AT

    def.damage = math.min(def.damage, 1)
    def.on_punch = on_punch  --register the on_punch above
    table.insert(def.utility_stack, animalia.mob_ai.basic_attack) --give them attack 
end

--wolves are special
--they run (but fight back) when close during the day but hunt from far away at night
local wolf = minetest.registered_entities["animalia:wolf"]
wolf.attacks_players = true
wolf.speed = WOLF_BASE_SPEED
wolf.tracking_range = DAY_TRACKING_RANGE
wolf.attack_list = {"animalia:chicken", "animalia:turkey", "animalia:sheep"}

local on_activate = wolf.on_activate
local function check_tracking_range(self)
    local time = minetest.get_timeofday()
    local night = time < NIGHT_MAX or time > NIGHT_MIN
    if night then
        self.tracking_range = NIGHT_TRACKING_RANGE
    else
        self.speed = WOLF_BASE_SPEED
        self.tracking_range = DAY_TRACKING_RANGE
    end
    minetest.after(30, check_tracking_range, self)
end

wolf.on_activate = function(self, staticdata, dtime_s)
    local meta = minetest:get_meta(self)
    on_activate(self, staticdata, dtime_s)
    check_tracking_range(self)
end
local logged = false
--this replaces animalia's get_attack_score
function animalia.get_attack_score(entity, attack_list)
	local pos = entity.stand_pos
	if not pos then return end

	local order = entity.order or "wander"
	if order ~= "wander" then return 0 end

	local target = entity._target or (entity.attacks_players and creatura.get_nearby_player(entity))
	local tgt_pos = target and target:get_pos()

	if not tgt_pos
	or not entity:is_pos_safe(tgt_pos)
	or (target:is_player()
	and minetest.is_creative_enabled(target:get_player_name())) then
		target = creatura.get_nearby_object(entity, attack_list)
		tgt_pos = target and target:get_pos()
	end

	if not tgt_pos then entity._target = nil return 0 end

	if target == entity.object then entity._target = nil return 0 end

	if animalia.has_shared_owner(entity.object, target) then entity._target = nil return 0 end

	local dist = vec_dist(pos, tgt_pos)
	local score = (entity.tracking_range - dist) / entity.tracking_range

	if entity.trust
	and target:is_player()
	and entity.trust[target:get_player_name()] then
		local trust = entity.trust[target:get_player_name()]
		local trust_score = ((entity.max_trust or 10) - trust) / (entity.max_trust or 10)

		score = score - trust_score
	end
    --changed code here
    --this calls of targetting if player is near a campfire or carrying torch
    --todo test torch here?
	
    local wolf = entity.object:get_entity_name() == "animalia:wolf"
    if wolf then
        local time = minetest.get_timeofday()
        local night = time < NIGHT_MAX or time > NIGHT_MIN
        local fleeing = 0
        if target:is_player() and night then
            local light_level = minetest.get_node_light(tgt_pos)
            if light_level > LIGHT_LEVEL_TO_STOP_PURSUIT then
                score = 0
                fleeing = 1
            end
        end
        local is_enemy = primitive.table_contains(entity.enemies, target:get_player_name())

        if not night and not is_enemy then
            entity.speed = WOLF_BASE_SPEED *3
            fleeing = 2
            score = 0
        end
        local close = vec_dist(tgt_pos, pos) < DAY_TRACKING_RANGE
        if fleeing > 0 and close then
            minetest.log("fleeing: ".. fleeing)
            local gait = "walk"
            if fleeing == 2 then gait = "run" end
            local center = vec_add(entity.object:get_pos(), vec_multi(vec_dir(tgt_pos, pos), 10))
            animalia.action_walk(entity, entity.speed, 0.2, gait, center)
        end
    end
    
	entity._target = target
	return score * 0.5, {entity, target}
end