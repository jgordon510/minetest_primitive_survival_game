--for now, we remove all fences except 
for i, node in pairs(minetest.registered_nodes) do
    if string.match(node.name, "fence") then
        --remove all default recipes for fences
        minetest.clear_craft({
            output = node.name
        })
        --non default fences get removed entirely
        if node.name ~= "default:fence_wood"  and node.name ~= "default:fence_rail_wood" then
            minetest.unregister_item(node.name)
        else
            --default fences get "apple" removed
            local desc = ""
            if string.match(node.name, "rail") then
                desc = "Wood Fence Rail"
            else
                desc = "Wood Fence"
            end
            minetest.override_item(node.name,{
                description = desc
            })
        end
    end
end

--register recipes with logs instead of planks
minetest.register_craft({
    type = "shaped",
    output = "default:fence_wood 4",
    recipe = {
        {"primitive:log_pile_9", "default:stick","primitive:log_pile_9"},
        {"primitive:log_pile_9", "default:stick","primitive:log_pile_9"},
    }
})
minetest.register_craft({
    type = "shaped",
    output = "default:fence_rail_wood 4",
    recipe = {
        {"primitive:log_pile_9","primitive:log_pile_9"},
        {"",""},
        {"primitive:log_pile_9","primitive:log_pile_9"},
    }
})
