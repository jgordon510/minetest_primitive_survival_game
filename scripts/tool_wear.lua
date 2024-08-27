
--these belongs here
--registers the tool wear recipe
minetest.log("tool_wear")
minetest.register_craft({
    output = "primitive:log_pile_9 9",
    recipe = {
        {"group:tree"},
        {"primitive:hatchet"},
    },
    replacements = {
        {"primitive:hatchet", "primitive:hatchet"},
    },
})


--executes the tool wear
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
    local craft_grid = craft_inv:get_list("craft")
    for i, stack in pairs(craft_grid) do
        local name = stack:get_name()
        --check for other requirements as neeeded
        --but if this is the only valid recipe with a hatchet, then
        --this will be limited to here, since it only fires after a 
        --valid craft is completed
        if name == "primitive:hatchet" then
            local max = 65536
            local uses = 100
            local wear = old_craft_grid[i]:get_wear() + max/uses
            stack:set_wear(wear)
            craft_inv:set_stack("craft", i, stack)
        end
    end
end)