for i, node in pairs(minetest.registered_nodes) do
    if string.match(node.name, "fence") then
        
        if node.name ~= "default:fence_wood"  and node.name ~= "default:fence_rail_wood"then
            minetest.clear_craft({
                output = node.name
            })
            minetest.unregister_item(node.name)
        else
            local desc = ""
            if string.match(node.name, "rail") then
                desc = "Wood Fence Rail"
            else
                desc = "Wood Fence"
            end
            minetest.log(node.name)
            minetest.override_item(node.name,{
                description = desc
            })
        end
    end
end

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
