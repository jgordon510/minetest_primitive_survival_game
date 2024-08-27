--override dirt so that it can't be dug with hands
for i, node in pairs(minetest.registered_nodes) do
    if string.match(node.name, "dirt") then 
        minetest.override_item(node.name, {
            groups = {crumbly = 4, soil = 1},
        })
    end
end

