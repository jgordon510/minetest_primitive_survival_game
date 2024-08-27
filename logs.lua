local S = minetest.get_translator("primitive")
--these are the nodes for each of the 9 logs in the stack
local logNodes = {
    {-0.50,-0.50,-0.50,-0.17,-0.17,0.50},--1
    {-0.17,-0.50,-0.50,0.17,-0.17,0.50},--2
    {0.17,-0.50,-0.50,0.50,-0.17,0.50},--3
    {-0.50,-0.17,-0.50,-0.17,0.17,0.50},--4
    {-0.17,-0.17,-0.50,0.17,0.17,0.50},--5
    {0.17,-0.17,-0.50,0.50,0.17,0.50},--6
    {-0.50,0.17,-0.50,-0.17,0.50,0.50},--7
    {-0.17,0.17,-0.50,0.17,0.50,0.50},--8
    {0.17,0.17,-0.50,0.50,0.50,0.50},--9
}

--three levels of selection boxes
local selectionBoxes = {
    box1 = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5 , 0.5 , -0.17, 0.5},
	},
    box2 = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5 , 0.5 , 0.17, 0.5},
	},
    box3 = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5 , 0.5, 0.5 , 0.5},
	},
}

local function get_first_n_items(tbl, n)
    local result = {}
    for i = 1, n do
        if tbl[i] == nil then
            break -- Stop if we run out of items in the table
        end
        table.insert(result, tbl[i])
    end
    return result
end

--climbs nodes until if finds air, then returns the y below that

local function top_pile_y(pos) 
    local top = false
    local lim = 25
    local level = 1
    local testPos = table.copy(pos)
    local lastPos = pos
    while not top and level < lim do
        level = level + 1
        testPos.y = testPos.y + 1
        local testNode = minetest.get_node(testPos)
        minetest.log("checking y:" .. testPos.y)
        if(not string.match(testNode.name, "log_pile")) then --check for not logs maybe?testNode.name=="air"
           return testPos.y-1
        end
        lastPos = testPos
    end
    return nil
end

--tricky little recursive function to climb the stack
--places 1 or 9 at the top of it
local function on_place(itemstack, placer, pointed_thing)	
    minetest.log("placing..")
    local pos = pointed_thing.under
   
    local param2 =  0
    if placer then
        --face the block in the player's direction
        param2 = minetest.dir_to_facedir(placer:get_look_dir())
    end

    local quant = math.min(itemstack:get_count(), 9)
    
    local node = minetest.get_node(pos)
    local base = string.sub(itemstack:get_name(), 1, #itemstack:get_name()-1)
    minetest.log(node.name)
    if string.match(node.name, "log_pile_9") then
        --clicked on a full pile
        --go one block above in the y
        pointed_thing.under.y = pointed_thing.under.y+1
        pointed_thing.above.y = pointed_thing.above.y+1
        local quant = math.min(itemstack:get_count(),9)
        if placer:get_player_control().zoom then
            quant = 1
        end
        local newName = base..quant
        itemstack:set_name(newName)
        --this mark allows us to tell whether we're placing directly on the ground
        --or if we've climbed up to the ceiling
        pointed_thing.climbed = true 
        return on_place(itemstack, placer,pointed_thing) --this must return!
    elseif string.match(node.name, "log_pile") then
            quant = 1
    elseif string.match(node.name, "air") then
        if placer:get_player_control().zoom then
            quant = 1
        end
    elseif string.match(node.name, "campfire") then
        if string.match(node.name, "active") or string.match(node.name, "embers") then
            quant = 1
        else
            return
        end
    else
        if placer:get_player_control().zoom then
            --place one on ground
            quant = 1
        end
        if pointed_thing.climbed then
            return --too tall and couldn't fint a spot
        end
    end
    local newName = base .. quant
    
    if not string.match(node.name, "log_pile") and not string.match(node.name, "air") then
        --new pile
        itemstack:set_name(newName)
    end
    minetest.item_place(itemstack, placer, pointed_thing, param2)
    itemstack.take_item(itemstack, quant)
    itemstack:set_name("primitive:log_pile_9") --9 is the generic version
    return itemstack --must return itemstack to change it
end

local def =  {
    description = "Log Pile" ..
    minetest.colorize("#ababab", "\n" .. S("Hold sneak and right/left click to add/remove one at a time.")),
    tiles = {
        "primitive_log_pile_side.png",
        "primitive_log_pile_side.png",
        "primitive_log_pile_top.png",
        "primitive_log_pile_top.png",
        "primitive_log_pile_front.png",
        "primitive_log_pile_front.png",
    },
    drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = logNodes
	},
    paramtype2 = "facedir",
    groups =  {flammable=1, log=1 },
    on_place = on_place,
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if not string.match(itemstack:get_name(), "log_pile") then return end
        local zoom = clicker:get_player_control().zoom
        local n = tonumber(string.sub(node.name, -1))
        if zoom then --place one log on the stack
            if n == 9 then 
                return 
            end
            minetest.log("taking")
            local base = string.sub(node.name, 1, #node.name-1)
            local newName = base .. (n+1)
            local oldParam2 = node.param2
            minetest.swap_node(pos, {name = newName, param2 = oldParam2})
            local count = itemstack:get_count()
            itemstack:set_count(count)
        else --fill the rest of the stack up
            local count = itemstack:get_count()
            local take = math.min(count, 9)
            take = math.min(9-n, take)
            local base = string.sub(node.name, 1, #node.name-1)
            local newName = base .. (n+take)
            local oldParam2 = minetest.get_node(pos).param2
            minetest.swap_node(pos, {name = newName, param2 = oldParam2})
            itemstack:set_count(count-(take-1))
            minetest.log("yoho")
        end
    end,
    on_punch = function(pos, node, puncher, pointed_thing)
        local zoom = puncher:get_player_control().zoom
        pos.y= top_pile_y(pos)
        node = minetest.get_node(pos)
        local n = tonumber(string.sub(node.name, -1))
        minetest.log(node.name)
        if node == nil then
            return
        end
        local itemstack = puncher:get_wielded_item()
        
        if zoom then
            --take one from stack
            local base = string.sub(node.name, 1, #node.name-1)
            local newName = base .. (n-1)
            puncher:get_inventory():add_item("main", "primitive:log_pile_9")
            if n > 1 then 
                local oldParam2 = minetest.get_node(pos).param2
                minetest.swap_node(pos, {name = newName, param2 = oldParam2})
            else
                minetest.remove_node(pos)
            end
        else
            --take all from the stack
            puncher:get_inventory():add_item("main", "primitive:log_pile_9 " .. n)
            minetest.remove_node(pos)
            return --todo test: this does nothing?
        end
    end
}

--register the log nodes
for i = 1, 9 do
    local newDef = table.copy(def)
    if i < 9 then
        newDef.description = newDef.description .. " " .. i
        newDef.groups.not_in_creative_inventory=1
    end
    
    newDef.node_box.fixed = get_first_n_items(logNodes, i)
    newDef.pileN = i
    if i == 1 or i == 2 or i == 3 then
        newDef.selection_box = selectionBoxes.box1
    end
    if i == 4 or i == 5 or i == 6 then
        newDef.selection_box = selectionBoxes.box2
    end
    if i == 7 or i == 8 or i == 9 then
        newDef.selection_box = selectionBoxes.box3
    end
    minetest.register_node("primitive:log_pile_" .. i, newDef)
end
